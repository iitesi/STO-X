<cfcomponent output="false">
	
<!--- doHotelPrice --->
	<cffunction name="doHotelPrice" output="false" access="remote" returnformat="json" returntype="array">
		<cfargument name="nSearchID" />
		<cfargument name="nHotelCode" />
		<cfargument name="sHotelChain" />
		<cfargument name="nCouldYou"	default="0">
		<cfargument name="sAPIAuth"		default="#application.sAPIAuth#">
    <cfargument name="stPolicy" 	default="#application.stPolicies[session.searches[arguments.nSearchID].nPolicyID]#">
		<cfargument name="stAccount" 	default="#application.stAccounts[session.Acct_ID]#">
		
		<cfset local.nHotelCode	= arguments.nHotelCode />
		<cfset local.sMessage 	= prepareSoapHeader(arguments.stAccount, arguments.nSearchID, arguments.sHotelChain, nHotelCode, arguments.nCouldYou)>
		<cfset local.sResponse 	= callAPI('HotelService', sMessage, arguments.sAPIAuth, arguments.nSearchID, nHotelCode, arguments.nCouldYou)>
		<cfset local.stResponse = formatResponse(sResponse)>
		<cfset local.stHotels 	= parseHotelRooms(stResponse, nHotelCode, arguments.nSearchID)>
		<cfset local.stRates 		= structKeyExists(stHotels,'Rooms') ? stHotels['Rooms'] : 'Sold Out' />
		<!--- <cfdump var="#stRates#"> --->

		<cfif isStruct(stRates)>
			<cfset local.RoomDescriptions = structKeyList(stRates,'|') /><!--- Need to use | as delimiter because hotel names have , --->
			<cfset local.LowRate = 10000 />
			<cfloop list="#RoomDescriptions#" index="local.HotelDesc" delimiters="|">
				<cfif structKeyExists(stRates[HotelDesc].HotelRate,'BaseRate')>
					<cfset LowRate = min(stRates[HotelDesc]['HotelRate']['BaseRate'],LowRate) />
				</cfif>
			</cfloop>
		<cfelse>
			<cfset local.LowRate = 'Sold Out' />
		</cfif>

		<cfset stHotels['LowRate'] = LowRate NEQ 'Sold Out' ? Int(Round(LowRate)) : LowRate />
		<cfset local.HotelAddress = StructKeyExists(stHotels,'Property') ? stHotels['Property']['Address1'] : ''/>
		<cfset HotelAddress			 &= StructKeyExists(stHotels,'Property') AND Len(Trim(stHotels['Property']['Address2'])) ? ', '&stHotels['Property']['Address2'] : '' />		

		<cfset stHotels = checkPolicy(stHotels,arguments.nSearchID,stPolicy,stAccount)>

		<cfset NewResponse = [ LowRate:LowRate,
													HotelAddress:HotelAddress,
													Policy:structKeyExists(stHotels,'Policy') ? stHotels['Policy'] : 0,
													APolicies:structKeyExists(stHotels,'aPolicies') ? stHotels['aPolicies'] : [],
													PreferredVendor:structKeyExists(stHotels,'PreferredVendor') ? stHotels['PreferredVendor'] : false
													] />		

		<cfset session.searches[arguments.nSearchID].stHotels[nHotelCode] = stHotels />

		<cfreturn NewResponse />
	</cffunction>
		
<!--- prepareSoapHeader --->
	<cffunction name="prepareSoapHeader" returntype="string" output="false">
		<cfargument name="stAccount" 		required="true">
		<cfargument name="nSearchID" 		required="true">
		<cfargument name="sHotelChain" 	required="true">
		<cfargument name="nHotelCode" 	required="true">
		<cfargument name="nCouldYou"		default="0">
		
		<cfset local.Search = session.searches[arguments.nSearchID] />

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
									<hot:CheckinDate>#DateFormat(DateAdd('d',arguments.nCouldYou,Search.dDepartDate),'yyyy-mm-dd')#</hot:CheckinDate>
									<hot:CheckoutDate>#DateFormat(DateAdd('d',arguments.nCouldYou,Search.dArrivalDate),'yyyy-mm-dd')#</hot:CheckoutDate>
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
		<cfargument name="nSearchID" />
		<cfargument name="nHotelCode"	/>
		<cfargument name="nCouldYou" default="0" />
		
		<cfset local.bSessionStorage = false /><!--- Testing setting (true - testing, false - live) --->

		<cfif arguments.nCouldYou NEQ 0>
			<cfset local.bSessionStorage = false />
		</cfif>
		<cfset local.httpname = 'http'&arguments.nHotelCode /><!--- need a unique name for each result --->

		<cfif NOT bSessionStorage OR NOT StructKeyExists(session.searches[nSearchID],nHotelCode)>
			<cfhttp method="post" url="https://americas.copy-webservices.travelport.com/B2BGateway/connect/uAPI/#arguments.sService#" result="#httpname#">
				<cfhttpparam type="header" name="Authorization" value="Basic #arguments.sAPIAuth#" />
				<cfhttpparam type="header" name="Content-Type" value="text/xml;charset=UTF-8" />
				<cfhttpparam type="header" name="Accept" value="gzip,deflate" />
				<cfhttpparam type="header" name="Cache-Control" value="no-cache" />
				<cfhttpparam type="header" name="Pragma" value="no-cache" />
				<cfhttpparam type="header" name="SOAPAction" value="" />
				<cfhttpparam type="body" name="message" value="#Trim(arguments.sMessage)#" />
			</cfhttp>
			
			<cfset cfhttp.filecontent = variables[httpname].filecontent />
			<cfset session.searches[nSearchID][nHotelCode] = cfhttp.filecontent />
		<cfelse>
			<cfset cfhttp.filecontent = session.searches[nSearchID][nHotelCode] />
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
		<cfargument name="nSearchID"	required="true">			
		
		<cfset local.stHotels = session.searches[nSearchID].stHotels[arguments.nHotelCode] />

		<cfloop array="#arguments.stResponse#" index="local.stHotelResults">

			<cfloop array="#stHotelResults.XMLChildren#" index="local.sHotelPriceResult">
				<cfif sHotelPriceResult.XMLName EQ 'hotel:HotelRateDetail'>
					
					<cfset RoomRateCategory = structKeyExists(sHotelPriceResult.XMLAttributes,'RateCategory') ? sHotelPriceResult.XMLAttributes.RateCategory : '' />
					<cfset RoomRatePlanType = structKeyExists(sHotelPriceResult.XMLAttributes,'RatePlanType') ? sHotelPriceResult.XMLAttributes.RatePlanType : '' />

					<!--- Need to find the room description --->
					<cfset local.RoomDescription = 'No Description for Hotel' />
					<cfloop array="#sHotelPriceResult.XMLChildren#" index="local.sHotelRate">
						<cfif sHotelRate.XMLName EQ 'hotel:RoomRateDescription'>
							<cfif sHotelRate.XMLAttributes.Name EQ 'Description'>
								<cfset RoomDescription = sHotelRate.XMLChildren.1.XMLText />
								<cfbreak />
							</cfif>
						</cfif>
					</cfloop>

					<cfif RoomDescription NEQ 'No Description for Hotel'>
						
						<!--- Create a struct with the Room Description --->
						<cfset local.stHotels['Rooms'][RoomDescription] = {
							TotalIncludes : '',
							Description : RoomDescription,
							RoomRateCategory : RoomRateCategory,
							RoomRatePlanType : RoomRatePlanType,
							Commission : '',
							CancelPolicyExist : '',
							MealPlanExist : '',
							RateChangeIndicator : '',
							HotelRate : {}
						} />
						
						<cfloop array="#sHotelPriceResult.XMLChildren#" index="local.sHotelRate">	
							<cfif sHotelRate.XMLName EQ 'hotel:RoomRateDescription'>
								<cfset stHotels['Rooms'][RoomDescription].TotalIncludes = sHotelRate.XMLAttributes.Name EQ 'Total Includes' ? sHotelRate.XMLChildren.1.XMLText : stHotels['Rooms'][RoomDescription].TotalIncludes />
								<cfset stHotels['Rooms'][RoomDescription].Commission = sHotelRate.XMLAttributes.Name EQ 'Commission' ? sHotelRate.XMLChildren.1.XMLText : stHotels['Rooms'][RoomDescription].Commission />
								<cfset stHotels['Rooms'][RoomDescription].CancelPolicyExist = sHotelRate.XMLAttributes.Name EQ 'Cancel Policy Exist' ? sHotelRate.XMLChildren.1.XMLText : stHotels['Rooms'][RoomDescription].CancelPolicyExist />
								<cfset stHotels['Rooms'][RoomDescription].MealPlanExist = sHotelRate.XMLAttributes.Name EQ 'Meal Plan Exist' ? sHotelRate.XMLChildren.1.XMLText : stHotels['Rooms'][RoomDescription].MealPlanExist />
								<cfset stHotels['Rooms'][RoomDescription].RateChangeIndicator = sHotelRate.XMLAttributes.Name EQ 'Rate Change Indicator' ? sHotelRate.XMLChildren.1.XMLText : stHotels['Rooms'][RoomDescription].RateChangeIndicator />							
							</cfif>

							<cfif sHotelRate.XMLName EQ 'hotel:HotelRateByDate'>
								<cfset local.CurrencyCode = left(sHotelRate.XMLAttributes.Base,3) />
								<cfset local.Rate = mid(sHotelRate.XMLAttributes.Base,4) />
								<cfset stHotels['Rooms'][RoomDescription].HotelRate.CurrencyCode = CurrencyCode />
								<cfset stHotels['Rooms'][RoomDescription].HotelRate.BaseRate = Rate />
								<cfset stHotels['Rooms'][RoomDescription].HotelRate.EffectiveRate = sHotelRate.XMLAttributes.EffectiveDate />
								<cfset stHotels['Rooms'][RoomDescription].HotelRate.ExpireRate = sHotelRate.XMLAttributes.ExpireDate />
							</cfif>
						</cfloop>

					</cfif>
				</cfif>

				<cfif sHotelPriceResult.XMLName EQ 'hotel:HotelProperty'>
					<cfset stHotels['Property'] = {
						Address1 : '',
						Address2 : '',
						BusinessPhone : '',
						FaxPhone : '',
						Direction : '',
						Distance : ''
					} />

					<cfloop array="#sHotelPriceResult.XMLChildren#" index="local.sHotelProperty">
						<cfif sHotelProperty.xmlName EQ 'hotel:PropertyAddress'>
							<cfset stHotels['Property'].Address1 = sHotelProperty.XMLChildren.1.XMLName EQ 'hotel:Address' ? Trim(sHotelProperty.XMLChildren.1.XMLText) : stHotels['Property'].Address1 />
							<cftry>
								<cfset stHotels['Property'].Address2 = sHotelProperty.XMLChildren.2.XMLName EQ 'hotel:Address' ? Trim(sHotelProperty.XMLChildren.2.XMLText) : stHotels['Property'].Address2 />
								<cfcatch>
									<cfmail to="mbusche@shortstravel.com" from="mbusche@shortstravel.com" subject="error" type="html">									
										<cfdump var="#sHotelProperty#">
									</cfmail>
								</cfcatch>
							</cftry>
						</cfif>
						<cfif sHotelProperty.xmlName CONTAINS 'PhoneNumber'>
							<cfset stHotels['Property'].BusinessPhone = sHotelProperty.XMLAttributes.Type EQ 'Business' ? Trim(sHotelProperty.XMLAttributes.Number) : stHotels['Property'].BusinessPhone />
							<cfset stHotels['Property'].FaxPhone = sHotelProperty.XMLAttributes.Type EQ 'Fax' ? Trim(sHotelProperty.XMLAttributes.Number) : stHotels['Property'].FaxPhone />
						</cfif>
						<cfif sHotelProperty.xmlName CONTAINS 'Distance'>
							<cfset stHotels['Property'].Direction = StructKeyExists(sHotelProperty.XMLAttributes,'Direction') ? Trim(sHotelProperty.XMLAttributes.Direction) : stHotels['Property'].Direction />
							<cfset stHotels['Property'].Distance = StructKeyExists(sHotelProperty.XMLAttributes,'Value') ? Trim(sHotelProperty.XMLAttributes.Value) : stHotels['Property'].Distance />
						</cfif>
						
					</cfloop>

				</cfif>
			</cfloop>

		</cfloop>
		
		<!--- Update the struct so we know we've received rates and we don't pull them again later --->
		<cfset stHotels['RoomsReturned'] = true />

		<cfreturn stHotels />
	</cffunction>	
	
<!--- checkPolicy --->
	<cffunction name="checkPolicy" output="true">
		<cfargument name="stHotels" />
		<cfargument name="nSearchID" />
		<cfargument name="stPolicy" />
		<cfargument name="stAccount" />
		
		<cfset local.stHotels = arguments.stHotels />
		<cfset local.bActive = true />
		<cfset local.bBlacklisted = arguments.stPolicy.Policy_HotelMaxDisp /><!--- are they allowed to book out of policy hotels (regarding max rate)? --->
		
		<cfset local.aPolicy = StructKeyExists(stHotels,'aPolicies') ? stHotels['aPolicies'] : [] /><!--- Need to use existing array --->
		
		<!--- If we don't have a LowRate yet, then don't apply policy, we'll do it later --->
		<cfif StructKeyExists(stHotels,'LowRate')>
			<cfset LowRate = StructKeyExists(stHotels,'LowRate') ? stHotels['LowRate'] : 0 />

			<cfloop collection="#stHotels#" item="local.sVendor">
				
				<cfif sVendor EQ 'HotelChain'>
					<cfset HotelChain = stHotels['HOTELCHAIN'] />						
					<cfset bActive = true>
					
					<!--- Max rate turned on and hotel is above max rate. --->
					<cfif arguments.stPolicy.Policy_HotelMaxRule EQ 1 AND LowRate NEQ 'Sold Out' AND LowRate GT arguments.stPolicy.Policy_HotelMaxRate>
						<cfif NOT ArrayFind(aPolicy,'Too expensive')><!--- Since we're passing in the existing array, a refresh would continually add this message to the array --->
							<cfset ArrayAppend(aPolicy, 'Too expensive')>
						</cfif>
						<cfif arguments.stPolicy.Policy_HotelMaxDisp EQ 1><!--- Only display in policy hotels? --->
							<cfset bActive = false>
						</cfif>
						<cfbreak />
					</cfif>

					<cfif bActive>
						<cfset stHotels.Policy = ArrayIsEmpty(aPolicy) ? true : false />
						<cfset stHotels.aPolicies = aPolicy />
					<cfelse>
						<cfset StructDelete(stHotels, HotelChain)>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>		

		<cfreturn stHotels />
	</cffunction>

</cfcomponent>