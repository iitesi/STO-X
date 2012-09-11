<cfcomponent output="false">
	
<!--- doLowFare --->
	<cffunction name="doLowFare" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="stPolicy" 	required="true">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="sAPIAuth" 	required="true">
		<cfargument name="sCabins" 		required="false"	default="Y"><!--- Options (list or one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable"	required="false"	default="0"><!--- Options (list or one item) - 0, 1 --->
		<cfargument name="bThread"		required="false"><!--- Skip threading if you need to troubleshoot an individual function --->
		
		<cfset local.sCabins = Replace(Replace(Replace(arguments.sCabins, 'Economy', 'Y'), 'Business', 'C'), 'First', 'F')>
		<cfset local.aCabins = ListToArray(sCabins)>
		<cfset local.aRefundable = ListToArray(arguments.bRefundable)>
		
		<cfset local.sJoinThread = ''>
		<cfif NOT StructKeyExists(arguments, 'bThread')>
			<cfloop array="#aCabins#" index="local.sCabin">
				<cfloop array="#aRefundable#" index="local.bRefundable">
					<cfif NOT StructKeyExists(session.searches[nSearchID].Pricing, sCabin)
					OR NOT StructKeyExists(session.searches[nSearchID].Pricing[sCabin], bRefundable)>
						<cfset sJoinThread = (sJoinThread EQ '' ? sCabin&bRefundable : '')>
						<cfthread
							action="run"
							name="#sCabin##bRefundable#"
							stAccount="#stAccount#"
							stPolicy="#stPolicy#"
							nSearchID="#nSearchID#"
							sAPIAuth="#sAPIAuth#"
							sCabin="#sCabin#"
							bRefundable="#bRefundable#"> 
							
							<cfset thread.stSegments = {}>
							<cfset thread.stTrips = {}>
							<cfset local.sMessage = prepareSoapHeader(stAccount, stPolicy, nSearchID, sCabin, bRefundable)>
							<cfset thread.sMessage = sMessage>
							<cfset local.sResponse = callAPI('AirService', sMessage, sAPIAuth, nSearchID)>
							<cfset local.aResponse = formatResponse(sResponse)>
							<cfset local.stSegmentKeys = parseSegmentKeys(aResponse)>
							<cfset thread.stSegments = parseSegments(aResponse, stSegmentKeys)>
							<cfset local.stTripKeys = parseTripKeys(aResponse, thread.stSegments, stSegmentKeys)>
							<cfset local.stFares = parseFares(aResponse)>
							<cfset thread.stTrips = parseTrips(aResponse, thread.stSegments, stSegmentKeys, stTripKeys, stFares)>
							<cfif StructIsEmpty(thread.stTrips)>
								<cfset thread.aResponse = aResponse>
								<cfset thread.sMessage = sMessage>
							</cfif>
							
							<cfset session.searches[nSearchID].stSegments = mergeSegments(session.searches[nSearchID].stSegments, thread.stSegments)>
							<cfset session.searches[nSearchID].stTrips = mergeTrips(session.searches[nSearchID].stTrips, thread.stTrips)>
							<cfset session.searches[nSearchID].Pricing[sCabin][bRefundable] = 1>
						</cfthread>
					</cfif>
				</cfloop>
			</cfloop>
		<cfelse>
			<cfset local.sCabin = 'Y'>
			<cfset local.bRefundable = 0>
			<cfset stSegments = {}>
			<cfset stTrips = {}>
			<cfset local.sMessage = prepareSoapHeader(stAccount, stPolicy, nSearchID, sCabin, bRefundable)>
			<cfset sMessage = sMessage>
			<cfset local.sResponse = callAPI('AirService', sMessage, sAPIAuth, nSearchID)>
			<cfset local.aResponse = formatResponse(sResponse)>
			<cfset local.stSegmentKeys = parseSegmentKeys(aResponse)>
			<cfset stSegments = parseSegments(aResponse, stSegmentKeys)>
			<cfset local.stTripKeys = parseTripKeys(aResponse, stSegments, stSegmentKeys)>
			<cfset local.stFares = parseFares(aResponse)>
			<cfset stTrips = parseTrips(aResponse, stSegments, stSegmentKeys, stTripKeys, stFares)>
			<cfset session.searches[nSearchID].stSegments = mergeSegments(session.searches[nSearchID].stSegments, stSegments)>
			<cfset session.searches[nSearchID].stTrips = mergeTrips(session.searches[nSearchID].stTrips, stTrips)>
			<cfset session.searches[nSearchID].Pricing[sCabin][bRefundable] = 1>
			<cfabort>
		</cfif>
		
		<cfif sJoinThread NEQ ''>
			<cfthread action="join" name="#sJoinThread#" />
			<cfif StructKeyExists(cfthread[sJoinThread], 'Error')>
				<cfdump eval=cfthread[sJoinThread] abort>
			</cfif>
			<!---<cfdump eval=cfthread[sJoinThread] abort>--->
		</cfif>
		
		<cfset local.stTrips = addTripLowFare(session.searches[nSearchID].stTrips)>
		<cfset stTrips = addPreferred(stTrips, stAccount)>
		<cfset session.searches[nSearchID].stTrips = addJavascript(stTrips)>
		<cfset session.searches[nSearchID].stCarriers = getCarriers(session.searches[nSearchID].stTrips)>
		<cfset session.searches[nSearchID].stSortFare = sortTrips(session.searches[nSearchID].stTrips, 'LowFare')>
		<cfset session.searches[nSearchID].stSortDepart = sortTrips(session.searches[nSearchID].stTrips, 'Depart')>
		<cfset session.searches[nSearchID].stSortArrival = sortTrips(session.searches[nSearchID].stTrips, 'Arrival')>
		<cfset session.searches[nSearchID].stSortDuration = sortTrips(session.searches[nSearchID].stTrips, 'Duration')>
		<cfset session.searches[nSearchID].stSortBag = sortTrips(session.searches[nSearchID].stTrips, 'LowFareBag')>
		<cfset session.searches[nSearchID].stTrips = checkPolicy(session.searches[nSearchID].stTrips, nSearchID, stPolicy, stAccount, session.searches[nSearchID].stSortFare[1])>
		
		<cfreturn >
	</cffunction>

<!--- prepareSOAPHeader --->
	<cffunction name="prepareSOAPHeader" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="stPolicy" 	required="true">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="sCabins" 		required="false"	default="Y"><!--- Options (list or one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable"	required="false"	default="0"><!--- Options (list or one item) - 0, 1 --->
		
		<cfquery name="local.getsearch" datasource="book">
		SELECT Air_Type, Airlines, International, Depart_City, Depart_DateTime, Depart_TimeType, Arrival_City, Arrival_DateTime, Arrival_TimeType, ClassOfService
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<cfif getsearch.Air_Type EQ 'MD'>
			<cfquery name="local.getsearchlegs" datasource="book">
			SELECT Depart_City, Arrival_City, Depart_DateTime, Depart_TimeType
			FROM Searches_Legs
			WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
			</cfquery>
		</cfif>
		
		<cfset local.ProhibitNonRefundableFares = (arguments.bRefundable EQ 0 ? 'false' : 'true')><!--- false = non refundable - true = refundable --->
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
									<com:Airport Code="#getsearch.Depart_City#" />
								</air:SearchOrigin>
								<air:SearchDestination>
									<com:Airport Code="#getsearch.Arrival_City#" />
								</air:SearchDestination>
								<air:SearchDepTime PreferredTime="#DateFormat(getsearch.Depart_DateTime, 'yyyy-mm-dd')#" />
								<air:AirLegModifiers>
									<air:PermittedCabins>
										<cfloop array="#aCabins#" index="local.sCabin">
											<air:CabinClass  Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
										</cfloop>
									</air:PermittedCabins>
								</air:AirLegModifiers>
							</air:SearchAirLeg>
							<cfif getsearch.Air_Type EQ 'RT'>
								<air:SearchAirLeg>
									<air:SearchOrigin>
										<com:Airport Code="#getsearch.Arrival_City#" />
									</air:SearchOrigin>
									<air:SearchDestination>
										<com:Airport Code="#getsearch.Depart_City#" />
									</air:SearchDestination>
									<air:SearchDepTime PreferredTime="#DateFormat(getsearch.Arrival_DateTime, 'yyyy-mm-dd')#" />
									<air:AirLegModifiers>
										<air:PermittedCabins>
											<cfloop array="#aCabins#" index="local.sCabin">
												<air:CabinClass  Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
											</cfloop>
										</air:PermittedCabins>
									</air:AirLegModifiers>
								</air:SearchAirLeg>
							<cfelseif getsearch.Air_Type EQ 'MD'>
								<cfloop query="getsearchlegs">
									<air:SearchAirLeg>
										<air:SearchOrigin>
											<com:Airport Code="#getsearchlegs.Depart_City#" />
										</air:SearchOrigin>
										<air:SearchDestination>
											<com:Airport Code="#getsearchlegs.Arrival_City#" />
										</air:SearchDestination>
										<air:SearchDepTime PreferredTime="#DateFormat(getsearchlegs.Depart_DateTime, 'yyyy-mm-dd')#" />
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
							<air:AirPricingModifiers ProhibitNonRefundableFares="#ProhibitNonRefundableFares#" FaresIndicator="PublicAndPrivateFares" ProhibitMinStayFares="false" ProhibitMaxStayFares="false" CurrencyType="USD" ProhibitAdvancePurchaseFares="false" ProhibitRestrictedFares="false" ETicketability="Required" ProhibitNonExchangeableFares="false" ForceSegmentSelect="false">
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
	
<!--- parseSegmentKeys --->
	<cffunction name="parseSegmentKeys" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stSegmentKeys = {}>
		<cfset local.sIndex = ''>
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<cfif stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<cfset sIndex = ''>
					<cfloop array="#aSegmentKeys#" index="local.sCol">
						<cfset sIndex &= stAirSegment.XMLAttributes[sCol]>
					</cfloop>
					<cfset stSegmentKeys[stAirSegment.XMLAttributes.Key] = {
						HashIndex	: 	HashNumeric(sIndex),
						Index		: 	sIndex
					}>
				</cfloop>
			</cfif>
		</cfloop>
			
		<cfreturn stSegmentKeys />
	</cffunction>
	
<!--- parseSegments --->
	<cffunction name="parseSegments" output="false">
		<cfargument name="stResponse"	required="true">
		<cfargument name="stSegmentKeys"required="true">
		
		<cfset local.stSegments = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<cfif stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<cfset local.sAPIKey = stAirSegment.XMLAttributes.Key>
					<cfset stSegments[arguments.stSegmentKeys[sAPIKey].HashIndex] = {
						ArrivalTime			: ParseDateTime(stAirSegment.XMLAttributes.ArrivalTime),
						Carrier 			: stAirSegment.XMLAttributes.Carrier,
						ChangeOfPlane		: stAirSegment.XMLAttributes.ChangeOfPlane EQ 'true',
						DepartureTime		: ParseDateTime(stAirSegment.XMLAttributes.DepartureTime),
						Destination			: stAirSegment.XMLAttributes.Destination,
						Equipment			: stAirSegment.XMLAttributes.Equipment,
						FlightNumber		: stAirSegment.XMLAttributes.FlightNumber,
						FlightTime			: stAirSegment.XMLAttributes.FlightTime,
						Group				: stAirSegment.XMLAttributes.Group,
						Origin				: stAirSegment.XMLAttributes.Origin,
						TravelTime			: stAirSegment.XMLAttributes.TravelTime
					}>
					<!---<cfloop array="#stAirSegment.XMLChildren#" index="local.stCodeshareInfo">
						<cfif stCodeshareInfo.XMLName EQ 'air:CodeshareInfo'>
							<cfset stSegments[arguments.stSegmentKeys[sAPIKey].HashIndex].OperatingCarrier = stCodeshareInfo.XMLAttributes.OperatingCarrier>
						</cfif>
					</cfloop>--->
				</cfloop>
			</cfif>
		</cfloop>
			
		<cfreturn stSegments />
	</cffunction>

<!--- lowfare : parseTripKeys --->
	<cffunction name="parseTripKeys" output="false">
		<cfargument name="stResponse"	required="true">
		<cfargument name="stSegments"	required="true">
		<cfargument name="stSegmentKeys"required="true">
		
		<cfset local.stTripKeys = {}>
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<cfloop array="#arguments.stResponse#" index="local.stAirPricingSolution">
			<cfif stAirPricingSolution.XMLName EQ 'air:AirPricingSolution'>
				<cfset local.sTripKey = stAirPricingSolution.XMLAttributes.Key>
				<cfset local.sIndex = ''>
				<cfloop array="#stAirPricingSolution.XMLChildren#" index="local.stAirSegmentRef">
					<cfif stAirSegmentRef.XMLName EQ 'air:AirSegmentRef'>
						<cfloop array="#aSegmentKeys#" index="local.stSegment">
							<cfset sIndex &= arguments.stSegments[arguments.stSegmentKeys[stAirSegmentRef.XMLAttributes.Key].HashIndex][stSegment]>
						</cfloop>
					</cfif>
				</cfloop>
				<cfset stTripKeys[sTripKey] = {
					HashIndex	: 	HashNumeric(sIndex)
				}>
			</cfif>
		</cfloop>
			
		<cfreturn stTripKeys />
	</cffunction>
	
<!--- lowfare : parseFares --->
	<cffunction name="parseFares" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stFares = {}>
		<cfloop array="#arguments.stResponse#" index="local.stFareInfoList">
			<cfif stFareInfoList.XMLName EQ 'air:FareInfoList'>
				<cfloop array="#stFareInfoList.XMLChildren#" index="local.stFareInfo">
					<cfset stFares[stFareInfo.XMLAttributes.Key] = {
						PrivateFare			: stFareInfo.XMLAttributes.PrivateFare EQ 'true',
						NegotiatedFare		: stFareInfo.XMLAttributes.NegotiatedFare EQ 'true'
					}>
				</cfloop>
			</cfif>
		</cfloop>
			
		<cfreturn stFares />
	</cffunction>
	
<!--- lowfare : parseTrips --->
	<cffunction name="parseTrips" output="false">
		<cfargument name="stResponse"	required="true">
		<cfargument name="stSegments"	required="true">
		<cfargument name="stSegmentKeys"required="true">
		<cfargument name="stTripKeys"	required="true">
		<cfargument name="stFares"		required="true">
		
		<cfset local.stTrips = {}>
		<cfset local.sTripKey = ''>
		<cfset local.stCarriers = {}>
		<cfset local.nTempGroup = -1>
		<cfset local.stStops = {}>
		<cfset local.nPreHash = -1>
		<cfset local.nCount = 0>
		<cfset local.sSegmentKey = 0>
		<cfset local.nLayover = ''>
		<cfset local.nDuration = 0>
		
		<cfloop array="#arguments.stResponse#" index="local.stAirPricingSolution">
			<cfif stAirPricingSolution.XMLName EQ 'air:AirPricingSolution'>
				
				<cfset sTripKey = arguments.stTripKeys[stAirPricingSolution.XMLAttributes.key].HashIndex>
				<cfset stTrips[sTripKey].Segments = StructNew('linked')>
				<cfset stCarriers = {}>
				<cfset nTempGroup = -1>
				<cfset stStops = {}>
				<cfset nPreHash = -1>
				<cfset nCount = 0>
				<cfset stSegment = ''>
				<cfset nDuration = 0>
				<cfloop array="#stAirPricingSolution.XMLChildren#" index="local.stAirPricingNode">
					
					<cfset sSegmentKey = (StructKeyExists(stAirPricingNode.XMLAttributes, 'Key') ? stAirPricingNode.XMLAttributes.Key : 0)>
					
					<cfif stAirPricingNode.XMLName EQ 'air:AirSegmentRef'>
						<cfset nCount++>
						<cfparam name="stTrips[#sTripKey#].Groups" default="#StructNew('linked')#">
						
						<cfset stSegment = arguments.stSegments[arguments.stSegmentKeys[sSegmentKey].HashIndex]>
						<cfset stTrips[sTripKey].Segments[nCount] = stSegment>
						<cfset stCarriers[stSegment.Carrier] = ''>
						
						<!--- first segment --->
						<cfif nTempGroup EQ -1>
							<cfset stTrips[sTripKey].Groups[0].Origin = stSegment.Origin>
							<cfset stTrips[sTripKey].Groups[0].DepartureTime = stSegment.DepartureTime>
						</cfif>
						<!--- layover --->
						<cfif nTempGroup NEQ -1 AND nTempGroup EQ stSegment.Group>
							<cfparam name="stStops[#stSegment.Group#].nStopCount" default="0">
							<cfset stStops[stSegment.Group].nStopCount = stStops[stSegment.Group].nStopCount + 1>
						</cfif>
						<!--- destination segment --->
						<cfif nTempGroup NEQ -1 AND nTempGroup NEQ stSegment.Group>
							<cfset stTrips[sTripKey].Groups[nTempGroup].Destination = stPreSegment.Destination>
							<cfset stTrips[sTripKey].Groups[nTempGroup].ArrivalTime = stPreSegment.ArrivalTime>
							<cfset stTrips[sTripKey].Groups[nTempGroup+1].Origin = stSegment.Origin>
							<cfset stTrips[sTripKey].Groups[nTempGroup+1].DepartureTime = stSegment.DepartureTime>
						</cfif>
						<cfset nDuration = nDuration + stSegment.TravelTime>
						<cfset nTempGroup = stSegment.Group>
						<cfparam name="stTrips[#sTripKey#].Groups[#nTempGroup#].Flights" default="">
						<cfset stTrips[sTripKey].Groups[nTempGroup].TravelTime = '#int(stSegment.TravelTime/60)#h #stSegment.TravelTime%60#m'>
						<cfset stPreSegment = stSegment>
						
					<cfelseif stAirPricingNode.XMLName EQ 'air:AirPricingInfo'>
						<cfset local.sOverallClass = 'E'>
						<cfset local.stClass = StructNew('linked')>
						<cfset local.sPTC = ''>
						<cfset local.nCount = 0>
						<cfset local.dDepartDate = ''>
						<cfset local.dArrivalDate = ''>
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
								<cfset dDepartDate = (nCount EQ 1 ? arguments.stSegments[HashIndex].DepartureTime : dDepartDate)>
								<cfset dArrivalDate = (arguments.stSegments[HashIndex].Group EQ 0 ? arguments.stSegments[HashIndex].ArrivalTime : dArrivalDate)>
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
						AND StructKeyExists(stTrips[sTripKey][sOverallClass][bRefundable], TotalPrice)>
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
				
				<cfset local.nStops = 0>
				<cfloop collection="#stStops#" item="local.nGroup">
					<cfset nStops = (stStops[nGroup].nStopCount GT nStops ? stStops[nGroup].nStopCount : nStops)>
				</cfloop>
				
				<cfset stTrips[sTripKey].Groups[nTempGroup].Destination = stSegment.Destination>
				<cfset stTrips[sTripKey].Groups[nTempGroup].ArrivalTime = stSegment.ArrivalTime>
				<cfset stTrips[sTripKey].Stops = nStops>
				<cfset stTrips[sTripKey].Duration = nDuration>
				<cfset stTrips[sTripKey].Depart = dDepartDate>
				<cfset stTrips[sTripKey].Arrival = dArrivalDate>
				<cfset stTrips[sTripKey].Carriers = StructKeyList(stCarriers)>
			</cfif>
		</cfloop>
		
		<cfreturn  stTrips/>
	</cffunction>
	
<!--- lowfare : sortTrips --->
	<cffunction name="sortTrips" returntype="array" output="false">
		<cfargument name="stTrips" 	required="true">
		<cfargument name="sField" 	required="true">
				
		<cfreturn StructSort(arguments.stTrips, 'numeric', 'asc', arguments.sField )/>
	</cffunction>
	
<!--- lowfare : addTripLowFare --->
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
	
<!--- addPreferred --->
	<cffunction name="addPreferred" output="false">
		<cfargument name="stTrips">
		<cfargument name="stAccount">
		
		<cfset local.stTrips = arguments.stTrips>
		<cfloop collection="#stTrips#" item="local.sTrip">
			<cfset stTrips[sTrip].Preferred = 0>
			<cfloop collection="#stTrips[sTrip].Segments#" item="local.nSegment">
				<cfif ArrayFindNoCase(arguments.stAccount.aPreferredAir, arguments.stTrips[sTrip].Segments[nSegment].Carrier)>
					<cfset stTrips[sTrip].Preferred = 1>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn stTrips/>
	</cffunction>
	
<!--- lowfare : addJavascript --->
	<cffunction name="addJavascript" output="false">
		<cfargument name="stTrips" 	required="true">
		
		<!---
			 * 	0	Token				DL0211DL1123UA221
			 * 	1	Policy				1/0
			 * 	2 	Multiple Carriers	1/0
			 * 	3 	Carriers			"DL","AA","UA"
			 * 	4	Refundable			1/0
			 * 	5	Preferred			1/0
			 * 	6	Cabin Class			Y, C, F
			 * 	7	Stops				0/1/2
		--->
		<cfset local.aAllCabins = ['Y','C','F']>
		<cfset local.aRefundable = [0,1]>
		<cfloop collection="#arguments.stTrips#" item="local.sTrip">
			<cfset sCarriers = '"#Replace(arguments.stTrips[sTrip].Carriers, ',', '","', 'ALL')#"'>
			<cfloop array="#aAllCabins#" index="local.sCabin">
				<cfif StructKeyExists(arguments.stTrips[sTrip], sCabin)>
					<cfif StructKeyExists(arguments.stTrips[sTrip][sCabin], 0)>
						<cfset stTrips[sTrip].sJavascript = "#sTrip#,1,#(ListLen(arguments.stTrips[sTrip].Carriers) EQ 1 ? 0 : 1)#,[#sCarriers#],0,0,'#sCabin#',#arguments.stTrips[sTrip].Stops#">
					</cfif>
					<cfif StructKeyExists(arguments.stTrips[sTrip][sCabin], 1)>
						<cfset stTrips[sTrip].sJavascript = "#sTrip#,1,#(ListLen(arguments.stTrips[sTrip].Carriers) EQ 1 ? 0 : 1)#,[#sCarriers#],1,0,'#sCabin#',#arguments.stTrips[sTrip].Stops#">
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn stTrips/>
	</cffunction>
	
<!--- lowfare : mergeSegments --->
	<cffunction name="mergeSegments" output="false">
		<cfargument name="stSegments1" 	required="true">
		<cfargument name="stSegments2" 	required="true">
		
		<cfset local.stSegments = arguments.stSegments1>
		<cfif IsStruct(stSegments) AND IsStruct(arguments.stSegments2)>
			<cfloop collection="#arguments.stSegments2#" item="local.sSegmentKey">
				<cfif NOT StructKeyExists(stSegments, sSegmentKey)>
					<cfset stSegments[sSegmentKey] = arguments.stSegments2[sSegmentKey]>	
				</cfif>
			</cfloop>
		<cfelse>
			<cfset stSegments = arguments.stSegments2>
		</cfif>
		<cfif NOT IsStruct(stSegments)>
			<cfset stSegments = {}>
		</cfif>
		
		<cfreturn stSegments/>
	</cffunction>

<!--- lowfare : mergeTrips --->
	<cffunction name="mergeTrips" output="false">
		<cfargument name="stTrips1" 	required="true">
		<cfargument name="stTrips2" 	required="true">
		
		<cfset local.stTrips = arguments.stTrips1>
		<cfif IsStruct(stTrips) AND IsStruct(arguments.stTrips2)>
			<cfloop collection="#arguments.stTrips2#" item="local.sTripKey">
				<cfif StructKeyExists(stTrips, sTripKey)>
					<cfloop collection="#arguments.stTrips2[sTripKey]#" item="local.sFareKey">
						<cfset stTrips[sTripKey][sFareKey] = arguments.stTrips2[sTripKey][sFareKey]>
					</cfloop>
				<cfelse>
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

<!--- getCarriers --->
	<cffunction name="getCarriers" output="false">
		<cfargument name="stTrips">
		
		<cfset local.stCarriers = []>
		<cfloop collection="#arguments.stTrips#" item="local.sTripKey">
			<cfloop collection="#arguments.stTrips[sTripKey].Segments#" item="local.nSegment">
				<cfif NOT ArrayFind(stCarriers, arguments.stTrips[sTripKey].Segments[nSegment].Carrier)>
					<cfset ArrayAppend(stCarriers, arguments.stTrips[sTripKey].Segments[nSegment].Carrier)>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn stCarriers/>
	</cffunction>
	
<!--- checkPolicy --->
	<cffunction name="checkPolicy" output="true">
		<cfargument name="stTrips">
		<cfargument name="nSearchID">
		<cfargument name="stPolicy">
		<cfargument name="stAccount">
		<cfargument name="nLowFareTripKey">
		
		<cfset local.stTrips = arguments.stTrips>
		<cfset local.aPolicy = {}>
		<cfset local.bActive = 1>
		<cfset local.bBlacklisted = (ArrayLen(arguments.stAccount.aNonPolicyAir) GT 0 ? 1 : 0)>
		<cfset local.aCOS = ["Y","C","F"]>
		<cfset local.aFares = ["0","1"]>
		<cfset local.cnt = 0>
		<cfif arguments.stPolicy.Policy_AirLowRule EQ 1
		AND IsNumeric(arguments.stPolicy.Policy_AirLowPad)>
			<cfset local.nLowFare = stTrips[arguments.nLowFareTripKey].Y[0].Total+arguments.stPolicy.Policy_AirLowPad>
		</cfif>
		
		<cfloop collection="#stTrips#" item="local.sTripKey">
			<cfloop array="#aCOS#" index="local.sCOS">
				<cfloop array="#aFares#" index="local.bRef">
					<cfif StructKeyExists(stTrips[sTripKey], sCOS)
					AND StructKeyExists(stTrips[sTripKey][sCOS], bRef)>
						<cfset stFare = stTrips[sTripKey][sCOS][bRef]>
						<cfset aPolicy = []>
						<cfset bActive = 1>
						
						<!--- Out of policy if the fare plus the padding is greater than the lowest available fare. --->
						<cfif arguments.stPolicy.Policy_AirLowRule EQ 1
						AND IsNumeric(arguments.stPolicy.Policy_AirLowPad)
						AND stFare.Total GT nLowFare>
							<cfset ArrayAppend(aPolicy, 'Not the lowest fare')>
							<cfif arguments.stPolicy.Policy_AirLowDisp EQ 1>
								<cfset bActive = 0>
							</cfif>
						</cfif>
						<!--- Out of policy if the total fare is over the maximum allowed fare. --->
						<cfif arguments.stPolicy.Policy_AirMaxRule EQ 1
						AND IsNumeric(arguments.stPolicy.Policy_AirMaxTotal)
						AND stFare.Total GT arguments.stPolicy.Policy_AirMaxTotal>
							<cfset ArrayAppend(aPolicy, 'Fare greater than #DollarFormat(arguments.stPolicy.Policy_AirMaxTotal)#')>
							<cfif arguments.stPolicy.Policy_AirMaxDisp EQ 1>
								<cfset bActive = 0>
							</cfif>
						</cfif>
						<!--- Don't display when non refundable --->
						<cfif arguments.stPolicy.Policy_AirRefRule EQ 1
						AND arguments.stPolicy.Policy_AirRefDisp EQ 1
						AND stFare.bRef EQ 0>
							<cfset ArrayAppend(aPolicy, 'Hide non refundable fares')>
							<cfset bActive = 0>
						</cfif>
						<!--- Don't display when refundable --->
						<cfif arguments.stPolicy.Policy_AirNonRefRule EQ 1
						AND arguments.stPolicy.Policy_AirNonRefDisp EQ 1
						AND stFare.bRef EQ 1>
							<cfset ArrayAppend(aPolicy, 'Hide refundable fares')>
							<cfset bActive = 0>
						</cfif>
						<!--- Out of policy if they cannot book non preferred carriers. --->
						<cfif arguments.stPolicy.Policy_AirPrefRule EQ 1
						AND stTrips[sTripKey].Preferred EQ 0>
							<cfset ArrayAppend(aPolicy, 'Not a preferred carrier')>
							<cfif arguments.stPolicy.Policy_AirPrefDisp EQ 1>
								<cfset bActive = 0>
							</cfif>
						</cfif>
						<!--- Remove first refundable fares --->
						<cfif sCOS EQ 'F'
						AND bRef EQ 1>
							<cfset ArrayAppend(aPolicy, 'Hide UP fares')>
							<cfset bActive = 0>
						</cfif>
						<!--- Out of policy if the carrier is blacklisted (still shows though).  --->
						<cfif bBlacklisted
						AND ArrayFindNoCase(arguments.stAccount.aNonPolicyAir, 'aa
							
							
							
							
							
							')>
							<cfset ArrayAppend(aPolicy, 'Out of policy carrier')>
						</cfif>
						<cfif bActive EQ 1>
							<cfset stTrips[sTripKey][sCOS][bRef].Policy = (ArrayIsEmpty(aPolicy) ? 1 : 0)>
							<cfset stTrips[sTripKey][sCOS][bRef].aPolicies = aPolicy>
						<cfelse>
							<cfset temp = StructDelete(stTrips[sTripKey][sCOS], bRef)>
						</cfif>
					</cfif>
				</cfloop>
			</cfloop>
		</cfloop>
		
		<cfset local.bAllInactive = 0>
		<!--- Out of policy if the depart date is less than the advance purchase requirement. --->
		<cfif arguments.stPolicy.Policy_AirAdvRule EQ 1
		AND DateDiff('d', session.searches[arguments.nSearchID].Depart_DateTime, Now()) GT arguments.stPolicy.Policy_AirAdv>
			<cfset bAllInactive = 1>
			<cfif arguments.stPolicy.Policy_AirAdvDisp EQ 1>
				<cfset stTrips = {}>
			</cfif>
			
		</cfif>
		
		<!--- Departure time is too close to current time.
		UPDATE Air_Trips
		SET Active = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />,
		Policy = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		AND Outbound_Depart <= #CreateODBCDateTime(DateAdd('h', 2, Now()))#
		
		UPDATE Air_Trips
		SET Policy = <cfqueryparam value="0" cfsqltype="cf_sql_integer">,
		Policy_Text = IsNull(Policy_Text, '')+'Out of policy carrier'
		FROM Air_Segments
		WHERE Air_Trips.Air_ID = Air_Segments.Air_ID
		AND Air_Trips.Air_Type = Air_Segments.Air_Type
		AND Air_Trips.Search_ID = Air_Segments.Search_ID
		AND Air_Trips.Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_integer">
		AND Carrier IN (SELECT Vendor_ID
						FROM OutofPolicy_Vendors
						WHERE Acct_ID = <cfqueryparam value="#search.Acct_ID#" cfsqltype="cf_sql_integer">
						AND Type = 'A')
		</cfquery> --->
		
		<cfreturn stTrips/>
	</cffunction>
	
</cfcomponent>