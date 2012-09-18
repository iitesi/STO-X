<cfcomponent output="false">
	
<!--- doHotelPrice --->
	<cffunction name="doHotelPrice" access="remote" returnformat="plain" returntype="string" output="false">
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

		<cfset local.stTrips = parseHotelRooms(stResponse, arguments.nHotelCode)>

		stop<cfabort>
		<cfset session.searches[arguments.nSearchID].stTrips = mergeTrips(session.searches[arguments.nSearchID].stTrips, stTrips)>
		<cfif NOT StructKeyExists(session.searches[arguments.nSearchID].stTrips[arguments.nTrip], arguments.sCabin)
		OR NOT StructKeyExists(session.searches[arguments.nSearchID].stTrips[arguments.nTrip][arguments.sCabin], arguments.bRefundable)>
			<cfset session.searches[arguments.nSearchID].stTrips[arguments.nTrip][arguments.sCabin][arguments.bRefundable].Total = 0>
		</cfif>
		<cfset sFare = serializeJSON(session.searches[arguments.nSearchID].stTrips[arguments.nTrip][arguments.sCabin][arguments.bRefundable].Total)>
		
		<cfreturn sFare>
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
		
		<cfset local.stTrips = {} />
		<cfset local.nHotelCode = arguments.nHotelCode />

		<cfloop array="#arguments.stResponse#" index="local.stHotelResults">

			<cfloop array="#stHotelResults.XMLChildren#" index="local.sHotelPriceResult">
				<cfif sHotelPriceResult.XMLName EQ 'hotel:HotelRateDetail'>
					
					<!--- Need to find the room description --->
					<cfloop array="#sHotelPriceResult.XMLChildren#" index="local.sHotelRate">	
						<cfif sHotelRate.XMLName EQ 'hotel:RoomRateDescription'>
							<cfif sHotelRate.XMLAttributes.Name EQ 'Description'>
								<cfset RoomDescription = sHotelRate.XMLChildren.1.XMLText />
								<cfset stTrips[nHotelCode]['Rooms'][RoomDescription] = {
									TotalIncludes : '',
									Description : RoomDescription,
									Commission : '',
									CancelPolicyExist : '',
									MealPlanExist : '',
									RateChangeIndicator : ''
								} />
								<cfbreak />
							</cfif>
						</cfif>
					</cfloop>

					<cfloop array="#sHotelPriceResult.XMLChildren#" index="local.sHotelRate">	
						<cfif sHotelRate.XMLName EQ 'hotel:RoomRateDescription'>
							<cfset stTrips[nHotelCode]['Rooms'][RoomDescription].TotalIncludes = sHotelRate.XMLAttributes.Name EQ 'Total Includes' ? sHotelRate.XMLChildren.1.XMLText : stTrips[nHotelCode]['Rooms'][RoomDescription].TotalIncludes />
							<cfset stTrips[nHotelCode]['Rooms'][RoomDescription].Commission = sHotelRate.XMLAttributes.Name EQ 'Commission' ? sHotelRate.XMLChildren.1.XMLText : stTrips[nHotelCode]['Rooms'][RoomDescription].Commission />
							<cfset stTrips[nHotelCode]['Rooms'][RoomDescription].CancelPolicyExist = sHotelRate.XMLAttributes.Name EQ 'Cancel Policy Exist' ? sHotelRate.XMLChildren.1.XMLText : stTrips[nHotelCode]['Rooms'][RoomDescription].CancelPolicyExist />
							<cfset stTrips[nHotelCode]['Rooms'][RoomDescription].MealPlanExist = sHotelRate.XMLAttributes.Name EQ 'Meal Plan Exist' ? sHotelRate.XMLChildren.1.XMLText : stTrips[nHotelCode]['Rooms'][RoomDescription].MealPlanExist />
							<cfset stTrips[nHotelCode]['Rooms'][RoomDescription].RateChangeIndicator = sHotelRate.XMLAttributes.Name EQ 'Rate Change Indicator' ? sHotelRate.XMLChildren.1.XMLText : stTrips[nHotelCode]['Rooms'][RoomDescription].RateChangeIndicator />							
						</cfif>

						<cfif sHotelRate.XMLName EQ 'hotel:HotelRateByDate'>
							<cfset stTrips[nHotelCode]['Rooms'][RoomDescription].HotelRate.BaseRate = sHotelRate.XMLAttributes.Base />
							<cfset stTrips[nHotelCode]['Rooms'][RoomDescription].HotelRate.EffectiveRate = sHotelRate.XMLAttributes.EffectiveDate />
							<cfset stTrips[nHotelCode]['Rooms'][RoomDescription].HotelRate.ExpireRate = sHotelRate.XMLAttributes.ExpireDate />
						</cfif>

					</cfloop>
				</cfif>

				<cfif sHotelPriceResult.XMLName EQ 'hotel:HotelProperty'>
					<cfset stTrips[nHotelCode]['Property'] = {
						Address1 : '',
						Address2 : '',
						BusinessPhone : '',
						FaxPhone : '',
						Direction : '',
						Distance : ''
					} />

					<cfloop array="#sHotelPriceResult.XMLChildren#" index="local.sHotelProperty">
						<cfif sHotelProperty.xmlName EQ 'hotel:PropertyAddress'>
							<cfset stTrips[nHotelCode]['Property'].Address1 = sHotelProperty.XMLChildren.1.XMLName EQ 'hotel:Address' ? sHotelProperty.XMLChildren.1.XMLText : stTrips[nHotelCode]['Property'].Address1 />
							<cfset stTrips[nHotelCode]['Property'].Address2 = sHotelProperty.XMLChildren.2.XMLName EQ 'hotel:Address' ? sHotelProperty.XMLChildren.2.XMLText : stTrips[nHotelCode]['Property'].Address2 />
						</cfif>
						<cfif sHotelProperty.xmlName CONTAINS 'PhoneNumber'>
							<cfset stTrips[nHotelCode]['Property'].BusinessPhone = sHotelProperty.XMLAttributes.Type EQ 'Business' ? sHotelProperty.XMLAttributes.Number : stTrips[nHotelCode]['Property'].BusinessPhone />
							<cfset stTrips[nHotelCode]['Property'].FaxPhone = sHotelProperty.XMLAttributes.Type EQ 'Fax' ? sHotelProperty.XMLAttributes.Number : stTrips[nHotelCode]['Property'].FaxPhone />
						</cfif>
						<cfif sHotelProperty.xmlName CONTAINS 'Distance'>
							<cfset stTrips[nHotelCode]['Property'].Direction = StructKeyExists(sHotelProperty.XMLAttributes,'Direction') ? sHotelProperty.XMLAttributes.Direction : stTrips[nHotelCode]['Property'].Direction />
							<cfset stTrips[nHotelCode]['Property'].Distance = StructKeyExists(sHotelProperty.XMLAttributes,'Value') ? sHotelProperty.XMLAttributes.Value : stTrips[nHotelCode]['Property'].Distance />
						</cfif>
						
					</cfloop>

				</cfif>
			</cfloop>

			<cfdump eval=stTrips>
		</cfloop>
		<cfabort>
		<cfreturn parseHotelRooms />
	</cffunction>	
	
</cfcomponent>