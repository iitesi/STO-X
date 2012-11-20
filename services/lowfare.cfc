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
		<cfargument name="sCabins" 		required="false"	default="Y"><!--- Options (list or one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable"	required="false"	default="0"><!--- Options (list or one item) - 0, 1 --->
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
					<cfif NOT StructKeyExists(session.searches[nSearchID].FareDetails.stPricing, sCabin)
					OR NOT StructKeyExists(session.searches[nSearchID].FareDetails.stPricing[sCabin], bRefundable)>
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
							<cfset local.sMessage = 	prepareSoapHeader(stAccount, stPolicy, nSearchID, sCabin, bRefundable)>
							<!--- Call the UAPI. --->
							<cfset local.sResponse = 	arguments.objUAPI.callUAPI('AirService', sMessage, nSearchID)>
							<!--- Format the UAPI response. --->
							<cfset local.aResponse = 	arguments.objUAPI.formatUAPIRsp(sResponse)>
							<!--- Create unique segment keys. --->
							<cfset local.stSegmentKeys =arguments.objAirParse.parseSegmentKeys(aResponse)>
							<!--- Parse the segments. --->
							<cfset thread.stSegments = 	arguments.objAirParse.parseSegments(aResponse, stSegmentKeys)>
							<!--- Create unique trip keys. --->
							<cfset local.stTripKeys = 	parseTripKeys(aResponse, thread.stSegments, stSegmentKeys)>
							<!--- Parse the fares. --->
							<cfset local.stFares = 		parseFares(aResponse)>
							<!--- Parse the trips. --->
							<cfset thread.stTrips = 	parseTrips(aResponse, thread.stSegments, stSegmentKeys, stTripKeys, stFares)>
							<!--- Add group node --->
							<cfset stTrips	= 			arguments.objAirParse.addGroups(stTrips)>
							<!--- If the UAPI gives an error then add these to the thread so it is visible to the developer. --->
							<cfif StructIsEmpty(thread.stTrips)>
								<cfset thread.aResponse = 	aResponse>
								<cfset thread.sMessage =	sMessage>
							</cfif>
							<!--- Merge all data into the current session structures. --->
							<cfset session.searches[nSearchID].stTrips 							= mergeTrips(session.searches[nSearchID].stTrips, thread.stTrips)>
							<cfset session.searches[nSearchID].FareDetails.stPricing[sCabin][bRefundable] 	= 1>
						</cfthread>
					</cfif>
				</cfloop>
			</cfloop>
		<cfelse>
			<!--- Default to Y and 0 since it is for development purposes.  No looping. --->
			<cfset local.sCabin = 'Y'>
			<cfset local.bRefundable = 0>
			<cfif NOT StructKeyExists(session.searches[nSearchID].FareDetails.stPricing, sCabin)
			OR NOT StructKeyExists(session.searches[nSearchID].FareDetails.stPricing[sCabin], bRefundable)>
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
				<!--- Create unique segment keys. --->
				<cfset local.stSegmentKeys =arguments.objAirParse.parseSegmentKeys(aResponse)>
				<!--- Parse the segments. --->
				<cfset stSegments = 		arguments.objAirParse.parseSegments(aResponse, stSegmentKeys)>
				<!--- Create unique trip keys. --->
				<cfset local.stTripKeys = 	parseTripKeys(aResponse, stSegments, stSegmentKeys)>
				<!--- Parse the fares. --->
				<cfset local.stFares = 		parseFares(aResponse)>
				<!--- Parse the trips. --->
				<cfset stTrips = 			parseTrips(aResponse, stSegments, stSegmentKeys, stTripKeys, stFares)>
				<!--- Add group node --->
				<cfset stTrips	= 			arguments.objAirParse.addGroups(stTrips)>
				<!--- Merge all data into the current session structures. --->
				<cfset session.searches[nSearchID].stTrips 							= arguments.objAirParse.mergeTrips(session.searches[nSearchID].stTrips, stTrips)>
				<cfset session.searches[nSearchID].FareDetails.stPricing[sCabin][bRefundable] 	= 1>
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
			<cfset local.stTrips 								= addTripLowFare(session.searches[nSearchID].stTrips)>
			<!--- Mark preferred carriers. --->
			<cfset stTrips 										= arguments.objAirParse.addPreferred(stTrips, stAccount)>
			<!--- Create javascript structure per trip. --->
			<cfset stTrips 										= arguments.objAirParse.addJavascript(stTrips)>
			<!--- Get list of all carriers returned. --->
			<cfset session.searches[nSearchID].FareDetails.stCarriers 		= arguments.objAirParse.getCarriers(stTrips)>
			<!--- Sort the results in different mannors. --->
			<cfset session.searches[nSearchID].FareDetails.stSortFare 		= arguments.objUAPI.sortStructure(stTrips, 'LowFare')>
			<cfset session.searches[nSearchID].FareDetails.stSortDepart 	= arguments.objUAPI.sortStructure(stTrips, 'Depart')>
			<cfset session.searches[nSearchID].FareDetails.stSortArrival 	= arguments.objUAPI.sortStructure(stTrips, 'Arrival')>
			<cfset session.searches[nSearchID].FareDetails.stSortDuration 	= arguments.objUAPI.sortStructure(stTrips, 'Duration')>
			<cfset session.searches[nSearchID].FareDetails.stSortBag 		= arguments.objUAPI.sortStructure(stTrips, 'LowFareBag')>
			<!--- Run policy on all the results --->
			<cfset session.searches[nSearchID].stTrips 			= arguments.objAirParse.checkPolicy(stTrips, nSearchID, session.searches[nSearchID].FareDetails.stSortFare[1])>
		</cfif>

		<!--- Get all segments found in the fare search --->
		<cfset session.searches[nSearchID].stAvailTrips 		= 	arguments.objAirParse.mergeTripsToAvail(session.searches[nSearchID].stTrips, session.searches[nSearchID].stAvailTrips)>
		
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
		
		<cfset local.bProhibitNonRefundableFares = (arguments.bRefundable ? 'true' : 'false')><!--- false = non refundable - true = refundable --->
		<cfset local.aCabins = ListToArray(arguments.sCabins)>
		
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
									<air:PermittedCabins>
										<cfloop array="#aCabins#" index="local.sCabin">
											<air:CabinClass  Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
										</cfloop>
									</air:PermittedCabins>
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
										<air:PermittedCabins>
											<cfloop array="#aCabins#" index="local.sCabin">
												<air:CabinClass  Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
											</cfloop>
										</air:PermittedCabins>
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
											<air:PermittedCabins>
												<cfloop array="#aCabins#" index="local.sCabin">
													<air:CabinClass  Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
												</cfloop>
											</air:PermittedCabins>
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
--->
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

<!---
parseTripKeys - fare
--->
	<cffunction name="parseTripKeys" output="false">
		<cfargument name="stResponse"	required="true">
		<cfargument name="stSegments"	required="true">
		<cfargument name="stSegmentKeys"required="true">
		
		<cfset local.stTripKeys = {}>
		<cfset local.sIndex = ''>
		<!--- Create list of fields that make up a distint segment. --->
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<!--- Loop through results. --->
		<cfloop array="#arguments.stResponse#" index="local.stAirPricingSolution">
			<cfif stAirPricingSolution.XMLName EQ 'air:AirPricingSolution'>
				<cfset local.sTripKey = stAirPricingSolution.XMLAttributes.Key>
				<!--- Build up the distinct segment string. --->
				<cfset sIndex = ''>
				<cfloop array="#stAirPricingSolution.XMLChildren#" index="local.stAirSegmentRef">
					<cfif stAirSegmentRef.XMLName EQ 'air:AirSegmentRef'>
						<cfloop array="#aSegmentKeys#" index="local.stSegment">
							<cfset sIndex &= arguments.stSegments[arguments.stSegmentKeys[stAirSegmentRef.XMLAttributes.Key].HashIndex][stSegment]>
						</cfloop>
					</cfif>
				</cfloop>
				<!--- Create a look up structure for the primary key. --->
				<cfset stTripKeys[sTripKey] = {
					HashIndex	: 	HashNumeric(sIndex)
				}>
			</cfif>
		</cfloop>
			
		<cfreturn stTripKeys />
	</cffunction>
	
<!---
parseTrips - fare
--->
	<cffunction name="parseTrips" output="false">
		<cfargument name="stResponse"	required="true">
		<cfargument name="stSegments"	required="true">
		<cfargument name="stSegmentKeys"required="true">
		<cfargument name="stTripKeys"	required="true">
		<cfargument name="stFares"		required="true">
		
		<cfset local.stTrips = {}>
		<cfset local.sTripKey = ''>
		<cfset local.nCount = 0>
		<cfset local.sSegmentKey = 0>
		
		<cfloop array="#arguments.stResponse#" index="local.stAirPricingSolution">
			<cfif stAirPricingSolution.XMLName EQ 'air:AirPricingSolution'>
				
				<cfset sTripKey = arguments.stTripKeys[stAirPricingSolution.XMLAttributes.key].HashIndex>
				<cfset stTrips[sTripKey].Segments = StructNew('linked')>
				<cfset nCount = 0>
				<cfset stSegment = ''>
				<cfset nDuration = 0>
				<cfloop array="#stAirPricingSolution.XMLChildren#" index="local.stAirPricingNode">
					
					<cfset sSegmentKey = (StructKeyExists(stAirPricingNode.XMLAttributes, 'Key') ? stAirPricingNode.XMLAttributes.Key : 0)>
					
					<cfif stAirPricingNode.XMLName EQ 'air:AirSegmentRef'>
						<cfset nCount++>
						
						<cfset stSegment = arguments.stSegments[arguments.stSegmentKeys[sSegmentKey].HashIndex]>
						<cfset stTrips[sTripKey].Segments[nCount] = stSegment>
						
						<cfset stPreSegment = stSegment>
						
					<cfelseif stAirPricingNode.XMLName EQ 'air:AirPricingInfo'>
						<cfset local.sOverallClass = 'E'>
						<cfset local.stClass = StructNew('linked')>
						<cfset local.sPTC = ''>
						<cfset local.nCount = 0>
						<cfloop array="#stAirPricingNode.XMLChildren#" index="local.stAirPricingNode2">
							<cfset local.bRefundable = 1>
							<cfif stAirPricingNode2.XMLName EQ 'air:PassengerType'>
								<!--- Passenger type codes --->
								<cfset sPTC = stAirPricingNode2.XMLAttributes.Code>
							<cfelseif stAirPricingNode2.XMLName EQ 'air:BookingInfo'>
								<!--- Pricing cabin class --->
								<cfset nCount++>
								<cfset local.HashIndex = arguments.stSegmentKeys[stAirPricingNode2.XMLAttributes.SegmentRef].HashIndex>
								<cfset local.sClass = (StructKeyExists(stAirPricingNode2.XMLAttributes, 'CabinClass') ? stAirPricingNode2.XMLAttributes.CabinClass : 'Economy')>
								<cfset stClass[HashIndex] = {
									Cabin	:	local.sClass,
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
						<cfset local.nTotal = 1000000>
						<cfif StructKeyExists(stTrips, sTripKey)
						AND StructKeyExists(stTrips[sTripKey], sOverallClass)
						AND StructKeyExists(stTrips[sTripKey][sOverallClass], bRefundable)
						AND StructKeyExists(stTrips[sTripKey][sOverallClass][bRefundable], 'TotalPrice')>
							<cfset nTotal = stTrips[sTripKey][sOverallClass][bRefundable].Total>
						</cfif>
						<cfif nTotal GT Mid(stAirPricingNode.XMLAttributes.TotalPrice, 4)>
							<cfset stTrips[sTripKey][sOverallClass][bRefundable] = {
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
		
		<cfreturn  stTrips/>
	</cffunction>

<!---
addTripLowFare
--->
	<cffunction name="addTripLowFare" output="false">
		<cfargument name="stTrips" 	required="true">
		
		<cfset local.nMin = 0>
		<cfloop collection="#arguments.stTrips#" item="local.sTrip">
			<cfset nMin = 1000000>
			<cfloop collection="#arguments.stTrips[sTrip]#" item="local.sClass">
				<cfif ListFind('F,C,Y', sClass)>
					<cfloop collection="#arguments.stTrips[sTrip][sClass]#" item="local.sRef">
						<cfset nMin = (nMin GT arguments.stTrips[sTrip][sClass][sRef].Total ? arguments.stTrips[sTrip][sClass][sRef].Total : nMin)>
					</cfloop>
				</cfif>
			</cfloop>
			<cfset stTrips[sTrip].LowFare = nMin>
			<cfset stTrips[sTrip].LowFareBag = nMin + application.stAirVendors[GetToken(arguments.stTrips[sTrip].Carriers, 1, ',')].Bag1>
		</cfloop>
		
		<cfreturn stTrips/>
	</cffunction>

</cfcomponent>