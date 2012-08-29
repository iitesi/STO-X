<cfcomponent output="false">
	
<!--- doAirPrice --->
	<cffunction name="doAirPrice" access="remote" returnformat="plain" returntype="string" output="false">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="nTrip"	 	required="true">
		<cfargument name="sCabin" 		required="true"><!--- Options (one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable"	required="true"><!--- Options (one item) - 0, 1 --->
		<cfargument name="sAPIAuth" 	required="false"	default="#application.sAPIAuth#">
		<cfargument name="stPolicy" 	required="false"	default="#application.stPolicies[session.Acct_ID]#">
		<cfargument name="stAccount" 	required="false"	default="#application.stAccounts[session.Acct_ID]#">
		
		<cfset local.stTrip = session.searches[arguments.nSearchID].stTrips[nTrip]>
		
		<cfset local.sMessage = prepareSoapHeader(arguments.stAccount, stTrip, arguments.sCabin, arguments.bRefundable)>
		<cfset local.sResponse = callAPI('AirService', sMessage, sAPIAuth, nSearchID)>
		<cfset stResponse = formatResponse(sResponse)>
		<cfset local.stTrips = parseTrips(stResponse, arguments.nTrip)>
		<cfset session.searches[arguments.nSearchID].stTrips = mergeTrips(session.searches[arguments.nSearchID].stTrips, stTrips)>
		<cfif NOT StructKeyExists(session.searches[arguments.nSearchID].stTrips[arguments.nTrip], arguments.sCabin)
		OR NOT StructKeyExists(session.searches[arguments.nSearchID].stTrips[arguments.nTrip][arguments.sCabin], arguments.bRefundable)>
			<cfset session.searches[arguments.nSearchID].stTrips[arguments.nTrip][arguments.sCabin][arguments.bRefundable].Total = 0>
		</cfif>
		<cfset sFare = serializeJSON(session.searches[arguments.nSearchID].stTrips[arguments.nTrip][arguments.sCabin][arguments.bRefundable].Total)>
		
		<cfreturn sFare>
	</cffunction>
	
<!--- doAirPrice --->
	<cffunction name="doAirPriceTesting" access="remote" returntype="string" output="false">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="nTrip"	 	required="true">
		<cfargument name="sCabin" 		required="true"><!--- Options (one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable"	required="true"><!--- Options (one item) - 0, 1 --->
		<cfargument name="sAPIAuth" 	required="false"	default="#application.sAPIAuth#">
		<cfargument name="stPolicy" 	required="false"	default="#application.stPolicies[session.Acct_ID]#">
		<cfargument name="stAccount" 	required="false"	default="#application.stAccounts[session.Acct_ID]#">
		
		<cfset local.stTrip = session.searches[arguments.nSearchID].stTrips[nTrip]>
		<cfdump eval=stTrip>
		<cfset local.sMessage = prepareSoapHeader(arguments.stAccount, stTrip, arguments.sCabin, arguments.bRefundable)>
		<cfdump eval=sMessage>
		<cfset local.sResponse = callAPI('AirService', sMessage, sAPIAuth, nSearchID)>
		<cfset stResponse = formatResponse(sResponse)>
		<cfdump eval=stResponse>
		<cfset local.stTrips = parseTrips(stResponse, arguments.nTrip)>
		<cfdump eval=stTrips>
		<cfset session.searches[arguments.nSearchID].stTrips = mergeTrips(session.searches[arguments.nSearchID].stTrips, stTrips)>
		<cfdump eval=session.searches[arguments.nSearchID].stTrips[nTrip] abort>
		<cfset sFare = 'N/A'>
		<cfif StructKeyExists(session.searches[arguments.nSearchID].stTrips[arguments.nTrip], arguments.sCabin)
		AND StructKeyExists(session.searches[arguments.nSearchID].stTrips[arguments.nTrip][arguments.sCabin], arguments.bRefundable)>
			<cfset sFare = session.searches[arguments.nSearchID].stTrips[arguments.nTrip][arguments.sCabin][arguments.bRefundable].Total>
		</cfif>
		<cfset sFare = serializeJSON(sFare)>
		
		<cfreturn sFare>
	</cffunction>
	
<!--- prepareSOAPHeader --->
	<cffunction name="prepareSOAPHeader" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="stTrip"	 	required="true">
		<cfargument name="sCabin" 		required="false"	default="Y"><!--- Options (one item) - Y, C, F --->
		<cfargument name="bRefundable"	required="false"	default="0"><!--- Options (one item) - 0, 1 --->
		
		<cfset local.ProhibitNonRefundableFares = (arguments.bRefundable EQ 0 ? 'false' : 'true')><!--- false = non refundable - true = refundable --->
		<cfset local.aCabins = ListToArray(arguments.sCabin)>
		
		<cfsavecontent variable="local.sMessage">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<air:AirPriceReq TargetBranch="#arguments.stAccount.sBranch#" xmlns:air="http://www.travelport.com/schema/air_v18_0" xmlns:com="http://www.travelport.com/schema/common_v15_0">
							<com:BillingPointOfSaleInfo OriginApplication="uAPI"/>
							<air:AirItinerary>
								<cfloop collection="#arguments.stTrip.Segments#" item="local.nSegment" >
									<air:AirSegment
									Key="#nSegment#T"
									Origin="#arguments.stTrip.Segments[nSegment].Origin#"
									Destination="#arguments.stTrip.Segments[nSegment].Destination#"
									DepartureTime="#DateFormat(arguments.stTrip.Segments[nSegment].DepartureTime, 'yyyy-mm-dd')#T#TimeFormat(arguments.stTrip.Segments[nSegment].DepartureTime, 'HH:mm:ss')#"
									Group="#arguments.stTrip.Segments[nSegment].Group#"
									FlightNumber="#arguments.stTrip.Segments[nSegment].FlightNumber#"
									Carrier="#arguments.stTrip.Segments[nSegment].Carrier#"
									ArrivalTime="#DateFormat(arguments.stTrip.Segments[nSegment].ArrivalTime, 'yyyy-mm-dd')#T#TimeFormat(arguments.stTrip.Segments[nSegment].ArrivalTime, 'HH:mm:ss')#"
									ProviderCode="1V">
										<air:AirAvailInfo>
											<cfloop array="#aCabins#" index="local.sCabin">
												<air:BookingCodeInfo BookingCounts="1" CabinClass="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
											</cfloop>
										</air:AirAvailInfo>
									</air:AirSegment>
								</cfloop>
							</air:AirItinerary>
							<air:AirPricingModifiers ProhibitNonRefundableFares="#ProhibitNonRefundableFares#" FaresIndicator="PublicAndPrivateFares" ProhibitMinStayFares="false" ProhibitMaxStayFares="false" CurrencyType="USD" ProhibitAdvancePurchaseFares="false" ProhibitRestrictedFares="false" ETicketability="Required" ProhibitNonExchangeableFares="false" ForceSegmentSelect="false">
								<cfif NOT ArrayIsEmpty(arguments.stAccount.Air_PF)>
									<air:AccountCodes>
										<cfloop array="#arguments.stAccount.Air_PF#" index="local.sPF">
											<com:AccountCode Code="#GetToken(sPF, 3, ',')#" ProviderCode="1V" SupplierCode="#GetToken(sPF, 2, ',')#" />
										</cfloop>
									</air:AccountCodes>
								</cfif>
							</air:AirPricingModifiers>
							<com:SearchPassenger PricePTCOnly="false" Code="ADT"/>
							<air:AirPricingCommand/>
						</air:AirPriceReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn sMessage/>
	</cffunction>
	
<!--- callAPI --->
	<cffunction name="callAPI" returntype="string" output="true">
		<cfargument name="sService"		required="true">
		<cfargument name="sMessage"		required="true">
		<cfargument name="sAPIAuth"		required="true">
		<cfargument name="nSearchID"	required="true">
		
		<cfset local.bSessionStorage = 0>
		
		<cfif NOT bSessionStorage OR NOT StructKeyExists(session.searches[nSearchID], 'sFileContent')>
			<cfhttp method="post" url="https://americas.copy-webservices.travelport.com/B2BGateway/connect/uAPI/#arguments.sService#">
				<cfhttpparam type="header" name="Authorization" value="Basic #arguments.sAPIAuth#" />
				<cfhttpparam type="header" name="Content-Type" value="text/xml;charset=UTF-8" />
				<cfhttpparam type="header" name="Accept" value="gzip,deflate" />
				<cfhttpparam type="header" name="Cache-Control" value="no-cache" />
				<cfhttpparam type="header" name="Pragma" value="no-cache" />
				<cfhttpparam type="header" name="SOAPAction" value="" />
				<cfhttpparam type="body" name="message" value="#Trim(arguments.sMessage)#" />
			</cfhttp>
			<cfif bSessionStorage>
				<cfset session.searches[nSearchID].sFileContent = cfhttp.filecontent>
			</cfif>
		<cfelse>
			<cfset cfhttp.filecontent = session.searches[nSearchID].sFileContent>
		</cfif>
		
		<cfreturn cfhttp.filecontent />
	</cffunction>
	
<!--- formatResponse --->
	<cffunction name="formatResponse" returntype="array" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stResponse = XMLParse(arguments.stResponse)>
		
		<cfreturn stResponse.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren />
	</cffunction>
	
<!--- parseTrips --->
	<cffunction name="parseTrips" returntype="struct" output="false">
		<cfargument name="stResponse"	required="true">
		<cfargument name="nTrip"		required="true">
		
		<cfset local.stTrips = {}>
		<cfset local.sOverallClass = 'E'>
		<cfset local.stClass = StructNew('linked')>
		<cfset local.sPTC = ''>
		<cfset local.nCount = 0>
		<cfset local.bRefundable = 1>
		<cfset local.sClass = ''>
		<cfset local.nTotal = 1000000>
		<cfloop array="#arguments.stResponse#" index="local.stAirPriceResult">
			<cfif stAirPriceResult.XMLName EQ 'air:AirPriceResult'>
				<cfloop array="#stAirPriceResult.XMLChildren#" index="local.stAirPricingSolution">
					<cfif stAirPricingSolution.XMLName EQ 'air:AirPricingSolution'>
						<cfloop array="#stAirPricingSolution.XMLChildren#" index="local.stAirPricingNode">
							<cfif stAirPricingNode.XMLName EQ 'air:AirPricingInfo'>
								<cfset sOverallClass = 'E'>
								<cfset stClass = StructNew('linked')>
								<cfset sPTC = ''>
								<cfset nCount = 0>
								<cfloop array="#stAirPricingNode.XMLChildren#" index="local.stAirPricingNode2">
									<cfset bRefundable = 1>
									<cfif stAirPricingNode2.XMLName EQ 'air:PassengerType'>
										<!--- Passenger type codes --->
										<cfset sPTC = stAirPricingNode2.XMLAttributes.Code>
									<cfelseif stAirPricingNode2.XMLName EQ 'air:BookingInfo'>
										<!--- Pricing cabin class --->
										<cfset nCount++>
										<cfset sClass = (StructKeyExists(stAirPricingNode2.XMLAttributes, 'CabinClass') ? stAirPricingNode2.XMLAttributes.CabinClass : 'Economy')>
										<cfset stClass[nCount] = {
											Cabin	:	sClass,
											Class	:	stAirPricingNode2.XMLAttributes.BookingCode
										}>
										<cfif sClass EQ 'First'>
											<cfset sOverallClass = 'F'>
										<cfelseif sOverallClass NEQ 'F' AND sClass EQ 'Business'>
											<cfset sOverallClass = 'C'>
										<cfelseif sOverallClass NEQ 'F' AND sOverallClass NEQ 'C'>
											<cfset sOverallClass = 'Y'>
										</cfif>
									<cfelseif stAirPricingNode2.XMLName EQ 'air:ChangePenalty'>
										<!--- Refundable or non refundable --->
										<cfloop array="#stAirPricingNode2.XMLChildren#" index="local.stFare">
											<cfset bRefundable = (bRefundable EQ 1 AND stFare.XMLText GT 0 ? 0 : 1)>
										</cfloop>
									</cfif>
								</cfloop>
								<cfset nTotal = 1000000>
								<cfif StructKeyExists(stTrips, nTrip)
								AND StructKeyExists(stTrips[nTrip], sOverallClass)
								AND StructKeyExists(stTrips[nTrip][sOverallClass], bRefundable)
								AND StructKeyExists(stTrips[nTrip][sOverallClass][bRefundable], TotalPrice)>
									<cfset nTotal = stTrips[nTrip][sOverallClass][bRefundable].Total>
								</cfif>
								<cfif nTotal GT Mid(stAirPricingNode.XMLAttributes.TotalPrice, 4)>
									<cfset stTrips[nTrip][sOverallClass][bRefundable] = {
										Base		: 	Mid(stAirPricingNode.XMLAttributes.BasePrice, 4),
										Total 		: 	Mid(stAirPricingNode.XMLAttributes.TotalPrice, 4),
										Taxes 		: 	Mid(stAirPricingNode.XMLAttributes.Taxes, 4),
										PTC			:	sPTC,
										Class		: 	stClass
									}>
								</cfif>
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfreturn  stTrips/>
	</cffunction>	
	
<!--- mergeTrips --->
	<cffunction name="mergeTrips" returntype="struct" output="false">
		<cfargument name="stTrips1" 	required="true">
		<cfargument name="stTrips2" 	required="true">
		
		<cfset local.stTrips = arguments.stTrips1>
		<cfif IsStruct(stTrips) AND IsStruct(arguments.stTrips2)>
			<!--- Loop trips --->
			<cfloop collection="#arguments.stTrips2#" item="local.sTripKey">
				<cfif StructKeyExists(stTrips, sTripKey)>
					<!--- Loop fares [Y,B,F]--->
					<cfloop collection="#arguments.stTrips2[sTripKey]#" item="local.sFareKey">
						<cfif StructKeyExists(stTrips[sTripKey], sFareKey)>
							<!--- Loop refundable [1,0] --->
							<cfloop collection="#arguments.stTrips2[sTripKey][sFareKey]#" item="local.sRefKey">
								<cfif StructKeyExists(stTrips[sTripKey][sFareKey], sRefKey)>11111111111
									<cfif stTrips[sTripKey][sFareKey][sRefKey].Total GT arguments.stTrips2[sTripKey][sFareKey][sRefKey].Total>
										<!--- If the fare exists but it more expensive - replace it --->
										<cfset stTrips[sTripKey][sFareKey][sRefKey] = arguments.stTrips2[sTripKey][sFareKey][sRefKey]>
									</cfif>
								<cfelse>
									<cfset stTrips[sTripKey][sFareKey][sRefKey] = arguments.stTrips2[sTripKey][sFareKey][sRefKey]>
								</cfif>
							</cfloop>
						<cfelse>
							<!--- If Y class doesn't exist - place both Y.0 and Y.1 in the struct --->
							<cfset stTrips[sTripKey][sFareKey] = arguments.stTrips2[sTripKey][sFareKey]>
						</cfif>
					</cfloop>
				<cfelse>
					<!--- If the trip doesn't exist - add it to the struct --->
					<cfset stTrips[sTripKey] = arguments.stTrips2[sTripKey]>
				</cfif>
			</cfloop>
		<cfelseif IsStruct(arguments.stTrips2)>
			<cfset stTrips = arguments.stTrips2>
		</cfif>
		<cfif NOT IsStruct(stTrips)>
			<cfset stTrips = {}>
		</cfif>
		
		<cfreturn stTrips/>
	</cffunction>
	
</cfcomponent>