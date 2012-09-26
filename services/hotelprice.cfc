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
		<cfset local.stResponse = formatResponse(sResponse)>
		
		<cfset local.stHotels = parseHotelRooms(stResponse, arguments.nHotelCode, arguments.nSearchID)>
		<cfset local.stRates = structKeyExists(stHotels[nHotelCode],'Rooms') ? stHotels[nHotelCode]['Rooms'] : 'Sold Out' />

		<cfif isStruct(stRates)>
			<cfset local.RoomDescriptions = structKeyList(stRates,'|') />
			<cfset local.LowRate = 10000 />
			<cfloop list="#RoomDescriptions#" index="local.HotelDesc" delimiters="|">
				<cfset LowRate = min(stRates[HotelDesc]['HotelRate']['BaseRate'],LowRate) />
			</cfloop>
		<cfelse>
			<cfset local.LowRate = 'Sold Out' />
		</cfif>

		<cfset LowRate = LowRate NEQ 'Sold Out' ? dollarFormat(LowRate) : LowRate />
		<cfset stHotels[nHotelCode]['LowRate'] = LowRate />
		<cfset local.HotelAddress = stHotels[nHotelCode]['Property']['Address1'] />
		<cfset HotelAddress&= Len(Trim(stHotels[nHotelCode]['Property']['Address2'])) ? ', '&stHotels[nHotelCode]['Property']['Address2'] : '' />		
		<cfset NewResponse = [ LowRate:LowRate,
													HotelAddress:HotelAddress ] />

		<!--- check Policy and add the struct into the session--->
		<cfset stHotels = checkPolicy(stHotels, arguments.nSearchID, stPolicy, stAccount)>

		<cfset session.searches[arguments.nSearchID].stHotels = stHotels />
				
		<cfreturn NewResponse />
	</cffunction>
		
<!--- prepareSoapHeader --->
	<cffunction name="prepareSoapHeader" returntype="string" output="false">
		<cfargument name="stAccount" 		required="true">
		<cfargument name="nSearchID" 		required="true">
		<cfargument name="sHotelChain" 	required="true">
		<cfargument name="nHotelCode" 	required="true">
		
		<cfquery name="local.getSearch" datasource="book">
		SELECT Depart_DateTime, Arrival_City, Arrival_DateTime
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>

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
		
		<cfset local.stHotels = session.searches[nSearchID].stHotels />
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
							<cftry>
								<cfset stHotels[nHotelCode]['Property'].Address2 = sHotelProperty.XMLChildren.2.XMLName EQ 'hotel:Address' ? Trim(sHotelProperty.XMLChildren.2.XMLText) : stHotels[nHotelCode]['Property'].Address2 />
								<cfcatch>
									<cfdump eval=sHotelProperty>
								</cfcatch>
							</cftry>
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

		<cfreturn stHotels />
	</cffunction>	
	
<!--- checkPolicy --->
	<cffunction name="checkPolicy" output="true">
		<cfargument name="stHotels" type="any" required="false">
		<cfargument name="nSearchID">
		<cfargument name="stPolicy">
		<cfargument name="stAccount">
		
		<cfset local.stHotels = arguments.stHotels />
		<cfset local.bActive = 1 />
		<cfset local.bBlacklisted = arguments.stPolicy.Policy_HotelMaxDisp /><!--- are they allowed to book out of policy hotels (regarding max rate)? --->
				
		<cfloop collection="#stHotels#" item="local.sCategory"><!--- Individual Hotels ---->
			<cfset local.aPolicy = StructKeyExists(stHotels[sCategory],'aPolicies') ? stHotels[sCategory]['aPolicies'] : [] /><!--- Need to use existing array --->
			
			<!--- If we don't have a LowRate yet, then don't apply policy, we'll do it later --->
			<cfif StructKeyExists(stHotels[sCategory],'LowRate')>
				<cfset LowRate = StructKeyExists(stHotels[sCategory],'LowRate') ? stHotels[sCategory]['LowRate'] : 0 />

				<cfloop collection="#stHotels[sCategory]#" item="local.sVendor">
					
					<cfif sVendor EQ 'HotelChain'>
						<cfset HotelChain = stHotels[sCategory]['HOTELCHAIN'] />						
						<cfset bActive = 1>
						
						<!--- Max rate turned on and hotel is above max rate. --->
						<cfif arguments.stPolicy.Policy_HotelMaxRule EQ 1 AND LowRate LT  arguments.stPolicy.Policy_HotelMaxRate>
							<cfif NOT ArrayFind(aPolicy,'Too expensive')><!--- Since we're passing in the existing array, a refresh would continually add this message to the array --->
								<cfset ArrayAppend(aPolicy, 'Too expensive')>
							</cfif>
							<cfif arguments.stPolicy.Policy_HotelMaxDisp EQ 1><!--- Only display in policy hotels? --->
								<cfset bActive = 0>
							</cfif>
							<cfbreak />
						</cfif>

						<cfif bActive EQ 1>
							<cfset stHotels[sCategory].Policy = (ArrayIsEmpty(aPolicy) ? 1 : 0)>
							<cfset stHotels[sCategory].aPolicies = aPolicy>
						<cfelse>
							<cfset temp = StructDelete(stHotels[sCategory], HotelChain)>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfreturn stHotels/>
	</cffunction>

</cfcomponent>