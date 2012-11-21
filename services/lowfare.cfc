<cfcomponent output="false">
	
<!---
doLowFare
--->
	<cffunction name="doLowFare" output="false">
		<cfargument name="objUAPI"		required="true">
		<cfargument name="objAirParse"	required="true">
		<cfargument name="nSearchID"	required="true">
		<cfargument name="stAccount"	required="false"	default="#application.stAccounts[session.Acct_ID]#">
		<cfargument name="stPolicy" 	required="false"	default="#application.stPolicies[session.searches[url.Search_ID].Policy_ID]#">
		<cfargument name="sCabins" 		required="false"	default="X"><!--- Options (list or one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable"	required="false"	default="X"><!--- Options (list or one item) - 0, 1 --->
		<cfargument name="bThread"		required="false"	default="1"><!--- Skip threading if you need to troubleshoot an individual function --->
		
		<cfset local.sCabins = Replace(Replace(Replace(arguments.sCabins, 'Economy', 'Y'), 'Business', 'C'), 'First', 'F')><!--- Handles the words or codes for classes. --->
		<cfset local.aCabins = ListToArray(sCabins)>
		<cfset local.aRefundable = ListToArray(arguments.bRefundable)>
		<cfset local.sJoinThread = ''>
		<cfset local.bUAPICall = 0>

		<cfif NOT arguments.bThread>
			<!--- Create a thread for every combination of cabin and fares. --->
			<cfloop array="#aCabins#" index="local.sCabin">
				<cfloop array="#aRefundable#" index="local.bRefundable">
					<!--- Don't go back to the UAPI if we already got the data. --->
					<cfif NOT StructKeyExists(session.searches[nSearchID].FareDetails.stPricing, sCabin&bRefundable)>
						<!--- Note that STO did go out to Apollo for results. --->
						<cfset bUAPICall = 1>
						<!--- Remember what threads where thrown out there. --->
						<cfset sJoinThread = (sJoinThread EQ '' ? sCabin&bRefundable : '')>
						<!--- Kick off the thread. --->
						<cfthread
							action="run"
							name="#sCabin##bRefundable#"
							objUAPI="#arguments.objUAPI#"
							objAirParse="#arguments.objAirParse#"
							stAccount="#arguments.stAccount#"
							stPolicy="#arguments.stPolicy#"
							nSearchID="#arguments.nSearchID#"
							sCabin="#sCabin#"
							bRefundable="#bRefundable#"> 
							<!--- Define. --->
							<cfset thread.stSegments = 	{}>
							<cfset thread.stTrips = 	{}>
							<!--- Put together the SOAP message. --->
							<cfset thread.sMessage = 	prepareSoapHeader(stAccount, stPolicy, nSearchID, sCabin, bRefundable)>
							<!--- Call the UAPI. --->
							<cfset thread.sResponse = 	arguments.objUAPI.callUAPI('AirService', thread.sMessage, nSearchID)>
							<!--- Format the UAPI response. --->
							<cfset local.aResponse = 	arguments.objUAPI.formatUAPIRsp(thread.sResponse)>
							<!--- Parse the segments. --->
							<cfset thread.stSegments = 	arguments.objAirParse.parseSegments(aResponse)>
							<!--- Parse the trips. --->
							<cfset local.stTrips = 		parseTrips(aResponse, thread.stSegments)>
							<!--- Add group node --->
							<cfset stTrips	= 			arguments.objAirParse.addGroups(stTrips)>
							<!--- If the UAPI gives an error then add these to the thread so it is visible to the developer. --->
							<cfif StructIsEmpty(stTrips)>
								<cfset thread.aResponse = 	aResponse>
								<cfset thread.sMessage =	sMessage>
							</cfif>
							<!--- Merge all data into the current session structures. --->
							<cfset session.searches[nSearchID].stTrips = arguments.objAirParse.mergeTrips(session.searches[nSearchID].stTrips, stTrips)>
							<cfset session.searches[nSearchID].FareDetails.stPricing[arguments.sCabin&arguments.bRefundable] = ''>
						</cfthread>
					</cfif>
				</cfloop>
			</cfloop>
		<cfelse>
			<!--- Default to Y and 0 since it is for development purposes.  No looping. --->
			<cfset local.sCabin = arguments.sCabins>
			<cfset local.bRefundable = arguments.bRefundable>
			<cfif NOT StructKeyExists(session.searches[nSearchID].FareDetails.stPricing, sCabin&bRefundable)>
				<!--- Note that STO did go out to Apollo for results. --->
				<cfset bUAPICall = 1>
				<!--- Define. --->
				<cfset local.stSegments = 	{}>
				<cfset local.stTrips = 		{}>
				<!--- Put together the SOAP message. --->
				<cfset local.sMessage = 	prepareSoapHeader(stAccount, stPolicy, nSearchID, sCabin, bRefundable)>
				<!--- Call the UAPI. --->
				<cfset local.sResponse = 	arguments.objUAPI.callUAPI('AirService', sMessage, nSearchID)>
				<!--- Format the UAPI response. --->
				<cfset local.aResponse = 	arguments.objUAPI.formatUAPIRsp(sResponse)>
				<!--- Parse the segments. --->
				<cfset stSegments = 		arguments.objAirParse.parseSegments(aResponse)>
				<!--- Parse the trips. --->
				<cfset stTrips = 			parseTrips(aResponse, stSegments)>
				<!--- Add group node --->
				<cfset stTrips	= 			arguments.objAirParse.addGroups(stTrips)>
				<!--- Merge all data into the current session structures. --->
				<cfset session.searches[nSearchID].stTrips = arguments.objAirParse.mergeTrips(session.searches[nSearchID].stTrips, stTrips)>
				<!--- Mark cabin and refundable and searched --->
				<cfset session.searches[nSearchID].FareDetails.stPricing[sCabin&bRefundable] = ''>
			</cfif>
		</cfif>

		<!--- Join only if threads where thrown out. --->
		<cfif sJoinThread NEQ ''>
			<cfthread action="join" name="#sJoinThread#" />
			<cfif StructKeyExists(cfthread[sJoinThread], 'Error')>
				<cfdump eval=cfthread[sJoinThread] abort>
			</cfif>
		</cfif>

		<!--- Configure/reconfigure session variables with newly added trips. --->
		<cfif bUAPICall AND NOT StructIsEmpty(session.searches[nSearchID].stTrips)>
			<!--- Check low fare. --->
			<cfset local.stTrips 								= addTotalBagFare(session.searches[nSearchID].stTrips)>
			<!--- Check low fare. --->
			<cfset session.searches[nSearchID].FareDetails.stResults = findResults(session.searches[nSearchID].stTrips)>
			<!--- Mark preferred carriers. --->
			<cfset stTrips 										= arguments.objAirParse.addPreferred(stTrips, stAccount)>
			<!--- Create javascript structure per trip. --->
			<cfset stTrips 										= arguments.objAirParse.addJavascript(stTrips)>
			<!--- Get list of all carriers returned. --->
			<cfset session.searches[nSearchID].FareDetails.stCarriers 		= arguments.objAirParse.getCarriers(stTrips)>
			<!--- Sort the results in different mannors. --->
			<cfset session.searches[nSearchID].FareDetails.stSortFare 		= arguments.objUAPI.sortStructure(stTrips, 'Total')>
			<cfset session.searches[nSearchID].FareDetails.stSortDepart 	= arguments.objUAPI.sortStructure(stTrips, 'Depart')>
			<cfset session.searches[nSearchID].FareDetails.stSortArrival 	= arguments.objUAPI.sortStructure(stTrips, 'Arrival')>
			<cfset session.searches[nSearchID].FareDetails.stSortDuration 	= arguments.objUAPI.sortStructure(stTrips, 'Duration')>
			<cfset session.searches[nSearchID].FareDetails.stSortBag 		= arguments.objUAPI.sortStructure(stTrips, 'TotalBag')>
			<!--- Run policy on all the results --->
			<!--- <cfset session.searches[nSearchID].stTrips 			= arguments.objAirParse.checkPolicy(stTrips, nSearchID, session.searches[nSearchID].FareDetails.stSortFare[1])> --->
			<!--- Get all segments found in the fare search --->
			<cfset session.searches[nSearchID].stAvailTrips 	= 	arguments.objAirParse.mergeTripsToAvail(session.searches[nSearchID].stTrips, session.searches[nSearchID].stAvailTrips)>
		</cfif>

		
		<cfreturn >
	</cffunction>

<!---
prepareSOAPHeader
--->
	<cffunction name="prepareSOAPHeader" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="stPolicy" 	required="true">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="sCabins" 		required="true"><!--- Options (one item) - Economy, Y, Business, C, First, F (this is coded for a list but none of the calls actually send a list) --->
		<cfargument name="bRefundable"	required="true"><!--- Options (one item) - 0, 1 (this is coded for a list but none of the calls actually send a list) --->
		
		<cfquery name="local.qSearch">
		SELECT Air_Type, Airlines, International, Depart_City, Depart_DateTime, Depart_TimeType, Arrival_City, Arrival_DateTime, Arrival_TimeType, ClassOfService
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<cfif qSearch.Air_Type EQ 'MD'>
			<cfquery name="local.qSearchLegs">
			SELECT Depart_City, Arrival_City, Depart_DateTime, Depart_TimeType
			FROM Searches_Legs
			WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
			</cfquery>
		</cfif>
		
		<cfset local.bProhibitNonRefundableFares = (arguments.bRefundable NEQ 'X' AND arguments.bRefundable ? 'true' : 'false')><!--- false = non refundable - true = refundable --->
		<cfif arguments.sCabins NEQ 'X'>
			<cfset local.aCabins = ListToArray(arguments.sCabins)>
		<cfelse>
			<cfset local.aCabins = []>
		</cfif>
		
		<cfsavecontent variable="local.sMessage">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<air:LowFareSearchReq TargetBranch="#arguments.stAccount.sBranch#" xmlns:air="http://www.travelport.com/schema/air_v18_0" xmlns:com="http://www.travelport.com/schema/common_v15_0" AuthorizedBy="Test">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
							<air:SearchAirLeg>
								<air:SearchOrigin>
									<com:Airport Code="#qSearch.Depart_City#" />
								</air:SearchOrigin>
								<air:SearchDestination>
									<com:Airport Code="#qSearch.Arrival_City#" />
								</air:SearchDestination>
								<air:SearchDepTime PreferredTime="#DateFormat(qSearch.Depart_DateTime, 'yyyy-mm-dd')#" />
								<air:AirLegModifiers>
									<cfif NOT arrayIsEmpty(aCabins)>
										<air:PermittedCabins>
											<cfloop array="#aCabins#" index="local.sCabin">
												<air:CabinClass  Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
											</cfloop>
										</air:PermittedCabins>
									</cfif>
								</air:AirLegModifiers>
							</air:SearchAirLeg>
							<cfif qSearch.Air_Type EQ 'RT'>
								<air:SearchAirLeg>
									<air:SearchOrigin>
										<com:Airport Code="#qSearch.Arrival_City#" />
									</air:SearchOrigin>
									<air:SearchDestination>
										<com:Airport Code="#qSearch.Depart_City#" />
									</air:SearchDestination>
									<air:SearchDepTime PreferredTime="#DateFormat(qSearch.Arrival_DateTime, 'yyyy-mm-dd')#" />
									<air:AirLegModifiers>
										<cfif NOT arrayIsEmpty(aCabins)>
											<air:PermittedCabins>
												<cfloop array="#aCabins#" index="local.sCabin">
													<air:CabinClass  Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
												</cfloop>
											</air:PermittedCabins>
										</cfif>
									</air:AirLegModifiers>
								</air:SearchAirLeg>
							<cfelseif qSearch.Air_Type EQ 'MD'>
								<cfloop query="qSearchLegs">
									<air:SearchAirLeg>
										<air:SearchOrigin>
											<com:Airport Code="#qSearchLegs.Depart_City#" />
										</air:SearchOrigin>
										<air:SearchDestination>
											<com:Airport Code="#qSearchLegs.Arrival_City#" />
										</air:SearchDestination>
										<air:SearchDepTime PreferredTime="#DateFormat(qSearchLegs.Depart_DateTime, 'yyyy-mm-dd')#" />
										<air:AirLegModifiers>
											<cfif NOT arrayIsEmpty(aCabins)>
												<air:PermittedCabins>
													<cfloop array="#aCabins#" index="local.sCabin">
														<air:CabinClass  Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
													</cfloop>
												</air:PermittedCabins>
											</cfif>
										</air:AirLegModifiers>
									</air:SearchAirLeg>
								</cfloop>
							</cfif>
							<air:AirSearchModifiers DistanceType="MI" IncludeFlightDetails="false" RequireSingleCarrier="false" AllowChangeOfAirport="false" ProhibitOvernightLayovers="true" MaxSolutions="300" MaxConnections="1" MaxStops="1" ProhibitMultiAirportConnection="true" PreferNonStop="true">
								<air:ProhibitedCarriers>
									<com:Carrier Code="ZK"/>
									<com:Carrier Code="SY"/>
									<com:Carrier Code="NK"/>
									<com:Carrier Code="G4"/>
								</air:ProhibitedCarriers>
							</air:AirSearchModifiers>
							<com:SearchPassenger Code="ADT" />
							<air:AirPricingModifiers ProhibitNonRefundableFares="#bProhibitNonRefundableFares#" FaresIndicator="PublicAndPrivateFares" ProhibitMinStayFares="false" ProhibitMaxStayFares="false" CurrencyType="USD" ProhibitAdvancePurchaseFares="false" ProhibitRestrictedFares="false" ETicketability="Required" ProhibitNonExchangeableFares="false" ForceSegmentSelect="false">
								<cfif NOT ArrayIsEmpty(arguments.stAccount.Air_PF)>
									<air:AccountCodes>
										<cfloop array="#arguments.stAccount.Air_PF#" index="local.sPF">
											<com:AccountCode Code="#GetToken(sPF, 3, ',')#" ProviderCode="1V" SupplierCode="#GetToken(sPF, 2, ',')#" />
										</cfloop>
									</air:AccountCodes>
								</cfif>
							</air:AirPricingModifiers>
							<com:PointOfSale ProviderCode="1V" PseudoCityCode="#arguments.stAccount.PCC_Booking#" />
						</air:LowFareSearchReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn sMessage/>
	</cffunction>
	
<!---
parseFares - fare

	<cffunction name="parseFares" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stFares = {}>
		<cfloop array="#arguments.stResponse#" index="local.stFareInfoList">
			<cfif stFareInfoList.XMLName EQ 'air:FareInfoList'>
				<cfloop array="#stFareInfoList.XMLChildren#" index="local.stFareInfo">
					<cfset stFares[stFareInfo.XMLAttributes.Key] = {
						PrivateFare			: (StructKeyExists(stFareInfo.XMLAttributes, 'PrivateFare') ? stFareInfo.XMLAttributes.PrivateFare EQ 'true' : false),
						NegotiatedFare		: stFareInfo.XMLAttributes.NegotiatedFare EQ 'true'
					}>
				</cfloop>
			</cfif>
		</cfloop>
			
		<cfreturn stFares />
	</cffunction>
--->	

<!---
parseTrips - fare
--->
	<cffunction name="parseTrips" output="false">
		<cfargument name="stResponse"	required="true">
		<cfargument name="stSegments"	required="true">
		
		<cfset local.stTrips = {}>
		<cfset local.stTrip = {}>
		<cfset local.sTripKey = ''>
		<cfset local.nCount = 0>
		<cfset local.sSegmentKey = 0>
		<cfset local.sIndex = ''>
		<cfset local.aIndexKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>

		<cfloop array="#arguments.stResponse#" index="local.stAirPricingSolution">
			
			<cfif stAirPricingSolution.XMLName EQ 'air:AirPricingSolution'>
				
				<cfset local.stTrip = {}>

				<cfset stTrip.Segments = StructNew('linked')>
				<cfset nCount = 0>
				<cfset nDuration = 0>
				<cfloop array="#stAirPricingSolution.XMLChildren#" index="local.stAirPricingNode">
					
					<cfset sSegmentKey = (StructKeyExists(stAirPricingNode.XMLAttributes, 'Key') ? stAirPricingNode.XMLAttributes.Key : 0)>
				
					<cfif stAirPricingNode.XMLName EQ 'air:AirSegmentRef'>
						
						<cfset stTrip.Segments[sSegmentKey] = arguments.stSegments[sSegmentKey]>
						
					<cfelseif stAirPricingNode.XMLName EQ 'air:AirPricingInfo'>
						<cfset local.sOverallClass = 'E'>
						<cfset local.sPTC = ''>
						<cfset local.nCount = 0>
						<cfloop array="#stAirPricingNode.XMLChildren#" index="local.stAirPricingNode2">
							<cfset local.bRefundable = 1>
							<cfif stAirPricingNode2.XMLName EQ 'air:PassengerType'>
								<!--- Passenger type codes --->
								<cfset sPTC = stAirPricingNode2.XMLAttributes.Code>
							<cfelseif stAirPricingNode2.XMLName EQ 'air:BookingInfo'>
								<!--- Pricing cabin class --->
								<cfset local.sClass = (StructKeyExists(stAirPricingNode2.XMLAttributes, 'CabinClass') ? stAirPricingNode2.XMLAttributes.CabinClass : 'Economy')>
								<cfset stTrip.Segments[stAirPricingNode2.XMLAttributes.SegmentRef].Class = stAirPricingNode2.XMLAttributes.BookingCode>
								<cfset stTrip.Segments[stAirPricingNode2.XMLAttributes.SegmentRef].Cabin = local.sClass>
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
						<cfset stTrip.Base = Mid(stAirPricingNode.XMLAttributes.BasePrice, 4)>
						<cfset stTrip.Total = Mid(stAirPricingNode.XMLAttributes.TotalPrice, 4)>
						<cfset stTrip.Taxes = Mid(stAirPricingNode.XMLAttributes.Taxes, 4)>
						<cfset stTrip.PTC = sPTC>
						<cfset stTrip.Class = sOverallClass>
						<cfset stTrip.Ref = bRefundable>
					</cfif>
				</cfloop>
				<!---
				TRIP KEY
				--->
				<cfset sIndex = ''>
				<cfloop array="#stAirPricingSolution.XMLChildren#" index="local.stAirSegmentRef">
					<cfif stAirSegmentRef.XMLName EQ 'air:AirSegmentRef'>
						<cfloop array="#aIndexKeys#" index="local.stSegment">
							<cfset sIndex &= arguments.stSegments[stAirSegmentRef.XMLAttributes.Key][stSegment]>
						</cfloop>
					</cfif>
				</cfloop>
				<cfset sTripKey = HashNumeric(sIndex&sOverallClass&bRefundable)>
				<cfset stTrips[sTripKey] = stTrip>
			</cfif>
		</cfloop>
		
		<cfreturn  stTrips/>
	</cffunction>

<!---
addTotalBagFare
--->
	<cffunction name="addTotalBagFare" output="false">
		<cfargument name="stTrips" 	required="true">
		
		<cfloop collection="#arguments.stTrips#" item="local.sTrip">
			<cfset stTrips[sTrip].TotalBag = stTrips[sTrip].Total + application.stAirVendors[GetToken(stTrips[sTrip].Carriers, 1, ',')].Bag1>
		</cfloop>
		
		<cfreturn stTrips/>
	</cffunction>

<!---
findResults
--->
	<cffunction name="findResults" output="false">
		<cfargument name="stTrips" 	required="true">
		
		<cfset local.stResults = {}>
		<cfloop collection="#arguments.stTrips#" item="local.sTrip">
			<cfset stResults[arguments.stTrips[sTrip].Class] = 1>
			<cfset stResults[arguments.stTrips[sTrip].Ref] = 1>
		</cfloop>
		
		<cfreturn stResults/>
	</cffunction>

</cfcomponent>