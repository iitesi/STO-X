<cfcomponent output="false">
	
<!--- doHotelPrice --->
	<cffunction name="doHotelPrice" output="false" access="remote" returnformat="json" returntype="array">
		<cfargument name="nSearchID" 		required="true">
		<cfargument name="nHotelCode"		required="true">
		<cfargument name="sHotelChain"	required="true">
		<cfargument name="sAPIAuth" 		required="false"	default="#application.sAPIAuth#">
		<cfargument name="stPolicy" 		required="false"	default="#application.stPolicies[session.Acct_ID]#">
		<cfargument name="stAccount" 		required="false"	default="#application.stAccounts[session.Acct_ID]#">
		
		<cfset local.stTrip = session.searches[arguments.nSearchID]>
		<cfset local.sMessage = prepareSoapHeader(arguments.stAccount, arguments.nSearchID, arguments.sHotelChain, arguments.nHotelCode)>
		<cfset local.sResponse = callAPI('HotelService', sMessage, arguments.sAPIAuth, arguments.nSearchID, arguments.nHotelCode)>
		<cfset stResponse = formatResponse(sResponse)>

		<cfset local.stTrips = parseHotelRooms(stResponse, arguments.nHotelCode, arguments.nSearchID)>
		<cfset local.stRates = structKeyExists(stTrips[nHotelCode],'Rooms') ? stTrips[nHotelCode]['Rooms'] : 'Sold Out' />

		<cfif isStruct(stRates)>
			<cfset local.RoomDescriptions = structKeyList(stRates,'|') />
			<cfset local.LowRate = 10000 />
			<cfloop list="#RoomDescriptions#" index="local.HotelDesc" delimiters="|">
				<cfset LowRate = min(stRates[HotelDesc]['HotelRate']['BaseRate'],LowRate) />
				<cfdump var="#stRates[HotelDesc]['HotelRate']['BaseRate']#">
			</cfloop>
		<cfelse>
			<cfset local.LowRate = 'Sold Out' />
		</cfif>

		<cfset stTrips[nHotelCode]['LowFare'] = LowRate />
		<cfset local.HotelAddress = stTrips[nHotelCode]['Property']['Address1'] />
		<cfset HotelAddress&= Len(Trim(stTrips[nHotelCode]['Property']['Address2'])) ? ', '&stTrips[nHotelCode]['Property']['Address2'] : '' />		
		<cfset NewResponse = [ LowRate:LowRate,
													HotelAddress:HotelAddress ] />

		<cfset session.searches[arguments.nSearchID].stTrips = stTrips />
				
		<cfreturn NewResponse />
	</cffunction>
		
<!--- prepareSoapHeader --->
	<cffunction name="prepareSoapHeader" returntype="string" output="false">
		<cfargument name="stAccount" 		required="true">
		<cfargument name="nSearchID" 		required="true">
		<cfargument name="sHotelChain" 	required="true">
		<cfargument name="nHotelCode" 	required="true">
		
		<cfquery name="local.getsearch" datasource="book">
		SELECT Depart_DateTime, Arrival_City, Arrival_DateTime
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>

		<cfsavecontent variable="local.message">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<hot:HotelDetailsReq TargetBranch="P7003155" xmlns:hot="http://www.travelport.com/schema/hotel_v17_0">
						  <com:BillingPointOfSaleInfo OriginApplication="UAPI" xmlns:com="http://www.travelport.com/schema/common_v15_0" />
						  <hot:HotelProperty HotelChain="#arguments.sHotelChain#" HotelCode="#arguments.nHotelCode#">
						  </hot:HotelProperty>
						  <hot:HotelDetailsModifiers RateRuleDetail="Complete">
						    <hot:HotelStay>
									<hot:CheckinDate>#DateFormat(getSearch.Depart_DateTime,'yyyy-mm-dd')#</hot:CheckinDate>
									<hot:CheckoutDate>#DateFormat(getSearch.Arrival_DateTime,'yyyy-mm-dd')#</hot:CheckoutDate>
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
		<cfargument name="sService"		required="true">
		<cfargument name="sMessage"		required="true">
		<cfargument name="sAPIAuth"		required="true">
		<cfargument name="nSearchID"	required="true">
		<cfargument name="nHotelCode"		required="true">
		
		<cfset local.bSessionStorage = 1><!--- Testing setting (1 - testing, 0 - live) --->

		<cfif NOT bSessionStorage OR NOT StructKeyExists(session.searches[nSearchID],nHotelCode)>
			<cfhttp method="post" url="https://americas.copy-webservices.travelport.com/B2BGateway/connect/uAPI/#arguments.sService#">
				<cfhttpparam type="header" name="Authorization" value="Basic #arguments.sAPIAuth#" />
				<cfhttpparam type="header" name="Content-Type" value="text/xml;charset=UTF-8" />
				<cfhttpparam type="header" name="Accept" value="gzip,deflate" />
				<cfhttpparam type="header" name="Cache-Control" value="no-cache" />
				<cfhttpparam type="header" name="Pragma" value="no-cache" />
				<cfhttpparam type="header" name="SOAPAction" value="" />
				<cfhttpparam type="body" name="message" value="#Trim(arguments.sMessage)#" />
			</cfhttp>
			
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
		
		<cfset local.stHotels = session.searches[nSearchID].stHotelProperties />
		<cfset local.nHotelCode = arguments.nHotelCode />

		<cfloop array="#arguments.stResponse#" index="local.stHotelResults">

			<cfloop array="#stHotelResults.XMLChildren#" index="local.sHotelPriceResult">
				<cfif sHotelPriceResult.XMLName EQ 'hotel:HotelRateDetail'>
					
					<!--- Need to find the room description --->
					<cfset RoomDescription = 'No Description for Hotel' />
					<cfloop array="#sHotelPriceResult.XMLChildren#" index="local.sHotelRate">
						<cfif sHotelRate.XMLName EQ 'hotel:RoomRateDescription'>
							<cfif sHotelRate.XMLAttributes.Name EQ 'Description'>
								<cfset RoomDescription = sHotelRate.XMLChildren.1.XMLText />
								<cfbreak />
							</cfif>
						</cfif>
					</cfloop>
					<cfdump var="#RoomDescription#"><br>
					
					<!--- Create a struct with the Room Description --->
					<cfset stHotels[nHotelCode]['Rooms'][RoomDescription] = {
						TotalIncludes : '',
						Description : RoomDescription,
						Commission : '',
						CancelPolicyExist : '',
						MealPlanExist : '',
						RateChangeIndicator : ''
					} />

					<cfloop array="#sHotelPriceResult.XMLChildren#" index="local.sHotelRate">	
						<cfif sHotelRate.XMLName EQ 'hotel:RoomRateDescription'>
							<cfset stHotels[nHotelCode]['Rooms'][RoomDescription].TotalIncludes = sHotelRate.XMLAttributes.Name EQ 'Total Includes' ? sHotelRate.XMLChildren.1.XMLText : stHotels[nHotelCode]['Rooms'][RoomDescription].TotalIncludes />
							<cfset stHotels[nHotelCode]['Rooms'][RoomDescription].Commission = sHotelRate.XMLAttributes.Name EQ 'Commission' ? sHotelRate.XMLChildren.1.XMLText : stHotels[nHotelCode]['Rooms'][RoomDescription].Commission />
							<cfset stHotels[nHotelCode]['Rooms'][RoomDescription].CancelPolicyExist = sHotelRate.XMLAttributes.Name EQ 'Cancel Policy Exist' ? sHotelRate.XMLChildren.1.XMLText : stHotels[nHotelCode]['Rooms'][RoomDescription].CancelPolicyExist />
							<cfset stHotels[nHotelCode]['Rooms'][RoomDescription].MealPlanExist = sHotelRate.XMLAttributes.Name EQ 'Meal Plan Exist' ? sHotelRate.XMLChildren.1.XMLText : stHotels[nHotelCode]['Rooms'][RoomDescription].MealPlanExist />
							<cfset stHotels[nHotelCode]['Rooms'][RoomDescription].RateChangeIndicator = sHotelRate.XMLAttributes.Name EQ 'Rate Change Indicator' ? sHotelRate.XMLChildren.1.XMLText : stHotels[nHotelCode]['Rooms'][RoomDescription].RateChangeIndicator />							
						</cfif>

						<cfif sHotelRate.XMLName EQ 'hotel:HotelRateByDate'>
							<cfset local.CurrencyCode = left(sHotelRate.XMLAttributes.Base,3) />
							<cfset local.Rate = mid(sHotelRate.XMLAttributes.Base,4) />
							<cfset stHotels[nHotelCode]['Rooms'][RoomDescription].HotelRate.CurrencyCode = CurrencyCode />
							<cfset stHotels[nHotelCode]['Rooms'][RoomDescription].HotelRate.BaseRate = Rate />
							<cfset stHotels[nHotelCode]['Rooms'][RoomDescription].HotelRate.EffectiveRate = sHotelRate.XMLAttributes.EffectiveDate />
							<cfset stHotels[nHotelCode]['Rooms'][RoomDescription].HotelRate.ExpireRate = sHotelRate.XMLAttributes.ExpireDate />
						</cfif>

					</cfloop>
				</cfif>

				<cfif sHotelPriceResult.XMLName EQ 'hotel:HotelProperty'>
					<cfset stHotels[nHotelCode]['Property'] = {
						Address1 : '',
						Address2 : '',
						BusinessPhone : '',
						FaxPhone : '',
						Direction : '',
						Distance : ''
					} />

					<cfloop array="#sHotelPriceResult.XMLChildren#" index="local.sHotelProperty">
						<cfif sHotelProperty.xmlName EQ 'hotel:PropertyAddress'>
							<cfset stHotels[nHotelCode]['Property'].Address1 = sHotelProperty.XMLChildren.1.XMLName EQ 'hotel:Address' ? Trim(sHotelProperty.XMLChildren.1.XMLText) : stHotels[nHotelCode]['Property'].Address1 />
							<cfset stHotels[nHotelCode]['Property'].Address2 = sHotelProperty.XMLChildren.2.XMLName EQ 'hotel:Address' ? Trim(sHotelProperty.XMLChildren.2.XMLText) : stHotels[nHotelCode]['Property'].Address2 />
						</cfif>
						<cfif sHotelProperty.xmlName CONTAINS 'PhoneNumber'>
							<cfset stHotels[nHotelCode]['Property'].BusinessPhone = sHotelProperty.XMLAttributes.Type EQ 'Business' ? Trim(sHotelProperty.XMLAttributes.Number) : stHotels[nHotelCode]['Property'].BusinessPhone />
							<cfset stHotels[nHotelCode]['Property'].FaxPhone = sHotelProperty.XMLAttributes.Type EQ 'Fax' ? Trim(sHotelProperty.XMLAttributes.Number) : stHotels[nHotelCode]['Property'].FaxPhone />
						</cfif>
						<cfif sHotelProperty.xmlName CONTAINS 'Distance'>
							<cfset stHotels[nHotelCode]['Property'].Direction = StructKeyExists(sHotelProperty.XMLAttributes,'Direction') ? Trim(sHotelProperty.XMLAttributes.Direction) : stHotels[nHotelCode]['Property'].Direction />
							<cfset stHotels[nHotelCode]['Property'].Distance = StructKeyExists(sHotelProperty.XMLAttributes,'Value') ? Trim(sHotelProperty.XMLAttributes.Value) : stHotels[nHotelCode]['Property'].Distance />
						</cfif>
						
					</cfloop>

				</cfif>
			</cfloop>

		</cfloop>
		
		<!--- Update the struct so we know we've received rates and we don't pull them again later --->
		<cfset stHotels[nHotelCode]['RoomsReturned'] = true />
<br>
		<cfreturn stHotels />
	</cffunction>	
	
</cfcomponent>