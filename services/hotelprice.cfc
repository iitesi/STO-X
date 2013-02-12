<cfcomponent output="false" accessors="true">

	<cfproperty name="UAPI">

<!---
init
--->
	<cffunction name="init" output="false">
		<cfargument name="UAPI">

		<cfset setUAPI(arguments.UAPI)>

		<cfreturn this>
	</cffunction>
	
<!--- doHotelPrice --->
	<cffunction name="doHotelPrice" output="false" access="remote" returnformat="json" returntype="array">
		<cfargument name="SearchID" />
		<cfargument name="nHotelCode" />
		<cfargument name="sHotelChain" />
		<cfargument name="nCouldYou"	default="0">
		<cfargument name="sAPIAuth"		default="#application.sAPIAuth#">
		<cfargument name="Policy"     default="#application.Policies[session.PolicyID]#">
		<cfargument name="Filter"     default="#session.filters[arguments.SearchID]#">

		<cfset local.nHotelCode	= arguments.nHotelCode />
		<cfset local.sMessage 	= prepareSoapHeader(arguments.sHotelChain, nHotelCode, arguments.nCouldYou, arguments.Filter)>
		<cfset local.sResponse 	= callAPI('HotelService', sMessage, arguments.sAPIAuth, arguments.SearchID, nHotelCode, arguments.nCouldYou)>
		<cfset local.stResponse = formatResponse(sResponse)>
		<cfset local.stHotels 	= parseHotelRooms(stResponse, nHotelCode, arguments.SearchID)>
		<cfset local.stRates 		= structKeyExists(stHotels,'Rooms') ? stHotels['Rooms'] : 'Sold Out' />
		<!--- <cfdump var="#stRates#"> --->

		<cfif isStruct(stRates)>
			<cfset local.RoomDescriptions = structKeyList(stRates,'|') /><!--- Need to use | as delimiter because hotel names have , --->
			<cfset local.LowRate = 10000 />
			<cfloop list="#RoomDescriptions#" index="local.HotelDesc" delimiters="|">
				<cfif structKeyExists(stRates[HotelDesc].HotelRate,'BaseRate')>
					<cfset local.LowRate = min(stRates[HotelDesc]['HotelRate']['BaseRate'],LowRate) />
				</cfif>
			</cfloop>
		<cfelse>
			<cfset local.LowRate = 'Sold Out' />
			<!--- Update the HotelInformationQuery that the hotel is sold out for the JavaScript filter --->
			<cfset QuerySetCell(session.searches[SearchID]['HOTELINFORMATIONQUERY'],'SOLDOUT',1,arrayFind(session.searches[SearchID]['stSortHotels'],nHotelCode)) />
		</cfif>

		<cfset local.stHotels['LowRate'] = LowRate NEQ 'Sold Out' ? Int(Round(LowRate)) : LowRate />
		<cfset local.HotelAddress = StructKeyExists(stHotels,'Property') ? stHotels['Property']['Address1'] : ''/>
		<cfset local.HotelAddress&= StructKeyExists(stHotels,'Property') AND Len(Trim(stHotels['Property']['Address2'])) ? ', '&stHotels['Property']['Address2'] : '' />		

		<cfset stHotels = checkPolicy(stHotels,arguments.SearchID,arguments.Policy)>

		<cfset local.NewResponse = [ LowRate:LowRate,
													HotelAddress:HotelAddress,
													Policy:structKeyExists(stHotels,'Policy') ? stHotels['Policy'] : 0,
													APolicies:structKeyExists(stHotels,'aPolicies') ? stHotels['aPolicies'] : [],
													PreferredVendor:structKeyExists(stHotels,'PreferredVendor') ? stHotels['PreferredVendor'] : false
													] />		

		<cfset session.searches[arguments.SearchID].stHotels[nHotelCode] = stHotels />

		<cfreturn NewResponse />
	</cffunction>
		
<!--- prepareSoapHeader --->
	<cffunction name="prepareSoapHeader" returntype="string" output="false">
		<cfargument name="sHotelChain" 	required="true">
		<cfargument name="nHotelCode" 	required="true">
		<cfargument name="nCouldYou"		default="0">
		<cfargument name="Filter" 		required="true">

		<cfsavecontent variable="local.message">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<hot:HotelDetailsReq TargetBranch="P7003155" xmlns:com="http://www.travelport.com/schema/common_v15_0" xmlns:hot="http://www.travelport.com/schema/hotel_v17_0">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
						  <hot:HotelProperty HotelChain="#arguments.sHotelChain#" HotelCode="#arguments.nHotelCode#">
						  </hot:HotelProperty>
						  <hot:HotelDetailsModifiers RateRuleDetail="Complete">
						    <hot:HotelStay>
									<hot:CheckinDate>#DateFormat(DateAdd('d',arguments.nCouldYou,arguments.Filter.getDepartDate()),'yyyy-mm-dd')#</hot:CheckinDate>
									<hot:CheckoutDate>#DateFormat(DateAdd('d',arguments.nCouldYou,arguments.Filter.getArrivalDate()),'yyyy-mm-dd')#</hot:CheckoutDate>
						    </hot:HotelStay>
						    <hot:RateCategory>All</hot:RateCategory>
						  </hot:HotelDetailsModifiers>
						  <com:PointOfSale ProviderCode="1V" PseudoCityCode="1M98" xmlns:com="http://www.travelport.com/schema/common_v15_0" />
						</hot:HotelDetailsReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn message />
	</cffunction>
	
<!--- callAPI --->
	<cffunction name="callAPI" returntype="string" output="true">
		<cfargument name="sService"	/>
		<cfargument name="sMessage"	/>
		<cfargument name="sAPIAuth"	/>
		<cfargument name="SearchID" />
		<cfargument name="nHotelCode"	/>
		<cfargument name="nCouldYou" default="0" />
		
		<cfset local.bSessionStorage = true /><!--- Testing setting (true - testing, false - live) --->

		<cfif arguments.nCouldYou NEQ 0>
			<cfset local.bSessionStorage = false />
		</cfif>
		<cfset local.httpname = 'http'&arguments.nHotelCode /><!--- need a unique name for each result --->

		<cfif NOT bSessionStorage OR NOT StructKeyExists(session.searches[SearchID], 'stHotelsRooms') OR NOT StructKeyExists(session.searches[SearchID].stHotelsRooms,nHotelCode)>
			<cfhttp method="post" url="https://americas.copy-webservices.travelport.com/B2BGateway/connect/UAPI/#arguments.sService#" result="local.#httpname#">
				<cfhttpparam type="header" name="Authorization" value="Basic #arguments.sAPIAuth#" />
				<cfhttpparam type="header" name="Content-Type" value="text/xml;charset=UTF-8" />
				<cfhttpparam type="header" name="Accept" value="gzip,deflate" />
				<cfhttpparam type="header" name="Cache-Control" value="no-cache" />
				<cfhttpparam type="header" name="Pragma" value="no-cache" />
				<cfhttpparam type="header" name="SOAPAction" value="" />
				<cfhttpparam type="body" name="message" value="#Trim(arguments.sMessage)#" />
			</cfhttp>
			
			<cfset cfhttp.filecontent = local[httpname].filecontent />
			<cfset session.searches[SearchID].stHotelsRooms[nHotelCode] = cfhttp.filecontent />
		<cfelse>
			<cfset cfhttp.filecontent = session.searches[SearchID].stHotelsRooms[nHotelCode] />
		</cfif>
		
		<cfreturn cfhttp.filecontent />
	</cffunction>
	
<!--- formatResponse --->
	<cffunction name="formatResponse" returntype="array" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stResponse = XMLParse(arguments.stResponse)>
		
		<cfreturn stResponse.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren />
	</cffunction>
	
<!--- parseHotelRooms --->
	<cffunction name="parseHotelRooms" returntype="struct" output="false">
		<cfargument name="stResponse"	required="true">		
		<cfargument name="nHotelCode"	required="true">		
		<cfargument name="SearchID"	required="true">
		
		<cfset local.stHotels = session.searches[SearchID].stHotels[arguments.nHotelCode] />
		<cfset local.GovernmentRateTypes = ['GVT','GOVERNMENT','MILITARY','GVNMT','GOV-MIL'] />

		<cfloop array="#arguments.stResponse#" index="local.stHotelResults">

			<cfloop array="#stHotelResults.XMLChildren#" index="local.sHotelPriceResult">
				<cfif sHotelPriceResult.XMLName EQ 'hotel:HotelRateDetail'>
					
					<cfset local.RoomRateCategory = structKeyExists(sHotelPriceResult.XMLAttributes,'RateCategory') ? sHotelPriceResult.XMLAttributes.RateCategory : '' />
					<cfset local.RoomRatePlanType = structKeyExists(sHotelPriceResult.XMLAttributes,'RatePlanType') ? sHotelPriceResult.XMLAttributes.RatePlanType : '' />

					<!--- Need to find the room description --->
					<cfset local.RoomDescription = 'No Description for Hotel' />
					<cfloop array="#sHotelPriceResult.XMLChildren#" index="local.sHotelRate">
						<cfif sHotelRate.XMLName EQ 'hotel:RoomRateDescription'>
							<cfif sHotelRate.XMLAttributes.Name EQ 'Description'>
								<cfset local.RoomDescription = sHotelRate.XMLChildren.1.XMLText />
								<cfbreak />
							</cfif>
						</cfif>
					</cfloop>

					<!--- Determine if government rate --->
					<cfset local.GovernmentRate = false />
					<cfif RoomDescription NEQ 'No Description for Hotel'>
						<cfloop array="#local.GovernmentRateTypes#" index="local.GovtRate">
							<cfif local.RoomDescription CONTAINS GovtRate>
								<cfset local.GovernmentRate = true />
							</cfif>
						</cfloop>
						
						<!--- Create a struct with the Room Description --->
						<cfset local.stHotels['Rooms'][RoomDescription] = {
							TotalIncludes : '',
							Description : RoomDescription,
							RoomRateCategory : RoomRateCategory,
							GovernmentRate : GovernmentRate,
							RoomRatePlanType : RoomRatePlanType,
							Commission : '',
							CancelPolicyExist : '',
							MealPlanExist : '',
							RateChangeIndicator : '',
							HotelRate : {}
						} />
						
						<cfloop array="#sHotelPriceResult.XMLChildren#" index="local.sHotelRate">	
							<cfif sHotelRate.XMLName EQ 'hotel:RoomRateDescription'>
								<cfset local.stHotels['Rooms'][RoomDescription].TotalIncludes = sHotelRate.XMLAttributes.Name EQ 'Total Includes' ? sHotelRate.XMLChildren.1.XMLText : local.stHotels['Rooms'][RoomDescription].TotalIncludes />
								<cfset local.stHotels['Rooms'][RoomDescription].Commission = sHotelRate.XMLAttributes.Name EQ 'Commission' ? sHotelRate.XMLChildren.1.XMLText : local.stHotels['Rooms'][RoomDescription].Commission />
								<cfset local.stHotels['Rooms'][RoomDescription].CancelPolicyExist = sHotelRate.XMLAttributes.Name EQ 'Cancel Policy Exist' ? sHotelRate.XMLChildren.1.XMLText : local.stHotels['Rooms'][RoomDescription].CancelPolicyExist />
								<cfset local.stHotels['Rooms'][RoomDescription].MealPlanExist = sHotelRate.XMLAttributes.Name EQ 'Meal Plan Exist' ? sHotelRate.XMLChildren.1.XMLText : local.stHotels['Rooms'][RoomDescription].MealPlanExist />
								<cfset local.stHotels['Rooms'][RoomDescription].RateChangeIndicator = sHotelRate.XMLAttributes.Name EQ 'Rate Change Indicator' ? sHotelRate.XMLChildren.1.XMLText : local.stHotels['Rooms'][RoomDescription].RateChangeIndicator />							
							</cfif>

							<cfif sHotelRate.XMLName EQ 'hotel:HotelRateByDate'>
								<cfset local.CurrencyCode = left(sHotelRate.XMLAttributes.Base,3) />
								<cfset local.Rate = mid(sHotelRate.XMLAttributes.Base,4) />
								<cfset local.stHotels['Rooms'][RoomDescription].HotelRate.CurrencyCode = CurrencyCode />
								<cfset local.stHotels['Rooms'][RoomDescription].HotelRate.BaseRate = Rate />
								<cfset local.stHotels['Rooms'][RoomDescription].HotelRate.EffectiveRate = sHotelRate.XMLAttributes.EffectiveDate />
								<cfset local.stHotels['Rooms'][RoomDescription].HotelRate.ExpireRate = sHotelRate.XMLAttributes.ExpireDate />
							</cfif>
						</cfloop>

					</cfif>
				</cfif>

				<cfif sHotelPriceResult.XMLName EQ 'hotel:HotelProperty'>
					<cfset local.stHotels['Property'] = {
						Address1 : '',
						Address2 : '',
						BusinessPhone : '',
						FaxPhone : '',
						Direction : '',
						Distance : ''
					} />

					<cfloop array="#sHotelPriceResult.XMLChildren#" index="local.sHotelProperty">
						<cfif sHotelProperty.xmlName EQ 'hotel:PropertyAddress'>
							<cfset local.stHotels['Property'].Address1 = sHotelProperty.XMLChildren.1.XMLName EQ 'hotel:Address' ? Trim(sHotelProperty.XMLChildren.1.XMLText) : local.stHotels['Property'].Address1 />
							<!--- <cfif structKeyExists(sHotelProperty.XMLChildren,'2') AND structKeyExists(sHotelProperty.XMLChildren.2,'XMLText')>
								<cfset local.stHotels['Property'].Address2 = sHotelProperty.XMLChildren.2.XMLName EQ 'hotel:Address' ? Trim(sHotelProperty.XMLChildren.2.XMLText) : local.stHotels['Property'].Address2 />
							</cfif> --->
							<cftry>
								<cfset local.stHotels['Property'].Address2 = sHotelProperty.XMLChildren.2.XMLName EQ 'hotel:Address' ? Trim(sHotelProperty.XMLChildren.2.XMLText) : local.stHotels['Property'].Address2 />
								<cfcatch>
									<cfmail to="mbusche@shortstravel.com" from="mbusche@shortstravel.com" subject="error" type="html">									
										<cfdump var="#sHotelProperty#">
									</cfmail>
								</cfcatch>
							</cftry>
						</cfif>
						<cfif sHotelProperty.xmlName CONTAINS 'PhoneNumber'>
							<cfset local.stHotels['Property'].BusinessPhone = sHotelProperty.XMLAttributes.Type EQ 'Business' ? Trim(sHotelProperty.XMLAttributes.Number) : local.stHotels['Property'].BusinessPhone />
							<cfset local.stHotels['Property'].FaxPhone = sHotelProperty.XMLAttributes.Type EQ 'Fax' ? Trim(sHotelProperty.XMLAttributes.Number) : local.stHotels['Property'].FaxPhone />
						</cfif>
						<cfif sHotelProperty.xmlName CONTAINS 'Distance'>
							<cfset local.stHotels['Property'].Direction = StructKeyExists(sHotelProperty.XMLAttributes,'Direction') ? Trim(sHotelProperty.XMLAttributes.Direction) : local.stHotels['Property'].Direction />
							<cfset local.stHotels['Property'].Distance = StructKeyExists(sHotelProperty.XMLAttributes,'Value') ? Trim(sHotelProperty.XMLAttributes.Value) : local.stHotels['Property'].Distance />
						</cfif>
						
					</cfloop>

				</cfif>
			</cfloop>

		</cfloop>
		
		<!--- Update the struct so we know we've received rates and we don't pull them again later --->
		<cfset local.stHotels['RoomsReturned'] = true />

		<cfreturn local.stHotels />
	</cffunction>	
	
<!--- checkPolicy --->
	<cffunction name="checkPolicy" output="true">
		<cfargument name="stHotels" />
		<cfargument name="SearchID" />
		<cfargument name="Policy" />
		
		<cfset local.stHotels = arguments.stHotels />
		<cfset local.bActive = true />
		<cfset local.bBlacklisted = arguments.Policy.Policy_HotelMaxDisp /><!--- are they allowed to book out of policy hotels (regarding max rate)? --->
		
		<cfset local.aPolicy = StructKeyExists(stHotels,'aPolicies') ? stHotels['aPolicies'] : [] /><!--- Need to use existing array --->
		
		<!--- If we don't have a LowRate yet, then don't apply policy, we'll do it later --->
		<cfif StructKeyExists(stHotels,'LowRate')>
			<cfset local.LowRate = StructKeyExists(stHotels,'LowRate') ? stHotels['LowRate'] : 0 />

			<cfloop collection="#stHotels#" item="local.sVendor">
				
				<cfif sVendor EQ 'HotelChain'>
					<cfset local.HotelChain = stHotels['HOTELCHAIN'] />						
					<cfset local.bActive = true>
					
					<!--- Max rate turned on and hotel is above max rate. --->
					<cfif arguments.Policy.Policy_HotelMaxRule EQ 1 AND LowRate NEQ 'Sold Out' AND LowRate GT arguments.Policy.Policy_HotelMaxRate>
						<cfif NOT ArrayFind(aPolicy,'Too expensive')><!--- Since we're passing in the existing array, a refresh would continually add this message to the array --->
							<cfset ArrayAppend(aPolicy, 'Too expensive')>
						</cfif>
						<cfif arguments.Policy.Policy_HotelMaxDisp EQ 1><!--- Only display in policy hotels? --->
							<cfset local.bActive = false>
						</cfif>
						<cfbreak />
					</cfif>

					<cfif bActive>
						<cfset local.stHotels.Policy = ArrayIsEmpty(aPolicy) ? true : false />
						<cfset local.stHotels.aPolicies = aPolicy />
					<cfelse>
						<cfset StructDelete(stHotels, HotelChain)>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>		

		<cfreturn stHotels />
	</cffunction>

</cfcomponent>