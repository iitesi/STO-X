<cfcomponent output="false">
	
<!--- lowfare : doSearch --->
	<cffunction name="doLowFare" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="stPolicy" 	required="true">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="sAPIAuth" 	required="true">
		<cfargument name="sCabins" 		required="false"	default="Y"><!--- Options (list or one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable"	required="false"	default="0"><!--- Options (list or one item) - 0, 1 --->
		
		<cfset local.sCabins = Replace(Replace(Replace(arguments.sCabins, 'Economy', 'Y'), 'Business', 'C'), 'First', 'F')>
		<cfset local.aCabins = ListToArray(sCabins)>
		<cfset local.aRefundable = ListToArray(arguments.bRefundable)>
		
		<cfset local.sJoinThread = ''>
		
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
						<cfset local.sResponse = callAPI('AirService', sMessage, sAPIAuth, nSearchID)>
						<cfset local.aResponse = formatResponse(sResponse)>
						<cfset local.stSegmentKeys = parseSegmentKeys(aResponse)>
						<cfset local.stTripKeys = parseTripKeys(aResponse, stSegmentKeys)>
						<cfset thread.stSegments = parseSegments(aResponse, stSegmentKeys)>
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
		
		<cfif sJoinThread NEQ ''>
			<cfthread action="join" name="#sJoinThread#" />
			<cfif StructKeyExists(cfthread[sJoinThread], 'Error')>
				<cfdump eval=cfthread[sJoinThread] abort>
			</cfif>
			<!---<cfdump eval=cfthread[sJoinThread] abort>--->
		</cfif>
		
		<cfset session.searches[nSearchID].stTrips = addTripLowFare(session.searches[nSearchID].stTrips)>
		
		<cfset session.searches[nSearchID].stSortFare = sortTrips(session.searches[nSearchID].stTrips, 'LowFare')>
		<cfset session.searches[nSearchID].stSortDepart = sortTrips(session.searches[nSearchID].stTrips, 'Depart')>
		<cfset session.searches[nSearchID].stSortArrival = sortTrips(session.searches[nSearchID].stTrips, 'Arrival')>
		
		<cfreturn >
	</cffunction>

<!--- lowfare : prepareSOAPHeader --->
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
							<com:SearchPassenger Code="ADT" />
							<air:AirPricingModifiers ProhibitNonRefundableFares="#ProhibitNonRefundableFares#" FaresIndicator="PublicAndPrivateFares" ProhibitMinStayFares="false" ProhibitMaxStayFares="false" CurrencyType="USD" ProhibitAdvancePurchaseFares="false" ProhibitRestrictedFares="false" ETicketability="Required" ProhibitNonExchangeableFares="false" ForceSegmentSelect="false">
								<!---<cfif NOT ArrayIsEmpty(arguments.stAccount.Air_PF)>
									<air:AccountCodes>
										<cfloop array="#arguments.stAccount.Air_PF#" index="local.sPF">
											<com:AccountCode Code="#GetToken(sPF, 3, ',')#" ProviderCode="#GetToken(sPF, 2, ',')#" SupplierCode="1V" />
										</cfloop>
									</air:AccountCodes>
								</cfif>--->
							</air:AirPricingModifiers>
							<com:PointOfSale ProviderCode="1V" PseudoCityCode="#arguments.stAccount.PCC_Booking#" />
						</air:LowFareSearchReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn sMessage/>
	</cffunction>
	
<!--- lowfare : callAPI --->
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
	
<!--- lowfare : formatResponse --->
	<cffunction name="formatResponse" returntype="array" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stResponse = XMLParse(arguments.stResponse)>
		
		<cfreturn stResponse.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren />
	</cffunction>
	
<!--- lowfare : parseSegmentKeys --->
	<cffunction name="parseSegmentKeys" returntype="struct" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.aSegmentKey = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<cfset local.stSegmentKeys = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<cfif stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<cfset local.sIndex = ''>
					<cfloop array="#aSegmentKey#" index="local.sCol">
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

<!--- lowfare : parseTripKeys --->
	<cffunction name="parseTripKeys" returntype="struct" output="false">
		<cfargument name="stResponse"	required="true">
		<cfargument name="stSegmentKeys"required="true">
		
		<cfset local.stTripKeys = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirPricingSolution">
			<cfif stAirPricingSolution.XMLName EQ 'air:AirPricingSolution'>
				<cfset local.sTripKey = stAirPricingSolution.XMLAttributes.Key>
				<cfset local.sIndex = ''>
				<cfloop array="#stAirPricingSolution.XMLChildren#" index="local.stAirSegmentRef">
					<cfif stAirSegmentRef.XMLName EQ 'air:AirSegmentRef'>
						<cfset sIndex &= arguments.stSegmentKeys[stAirSegmentRef.XMLAttributes.Key].Index>
					</cfif>
				</cfloop>
				<cfset stTripKeys[sTripKey] = {
					HashIndex	: 	HashNumeric(sIndex)
				}>
			</cfif>
		</cfloop>
			
		<cfreturn stTripKeys />
	</cffunction>
	
<!--- lowfare : parseSegments --->
	<cffunction name="parseSegments" returntype="struct" output="false">
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
					<cfloop array="#stAirSegment.XMLChildren#" index="local.stCodeshareInfo">
						<cfif stCodeshareInfo.XMLName EQ 'air:CodeshareInfo'>
							<cfset stSegments[arguments.stSegmentKeys[sAPIKey].HashIndex].OperatingCarrier = stCodeshareInfo.XMLAttributes.OperatingCarrier>
						</cfif>
					</cfloop>
				</cfloop>
			</cfif>
		</cfloop>
			
		<cfreturn stSegments />
	</cffunction>
	
<!--- lowfare : parseFares --->
	<cffunction name="parseFares" returntype="struct" output="false">
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
	<cffunction name="parseTrips" returntype="struct" output="false">
		<cfargument name="stResponse"	required="true">
		<cfargument name="stSegments"	required="true">
		<cfargument name="stSegmentKeys"required="true">
		<cfargument name="stTripKeys"	required="true">
		<cfargument name="stFares"		required="true">
		
		<cfset local.stTrips = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirPricingSolution">
			<cfif stAirPricingSolution.XMLName EQ 'air:AirPricingSolution'>
				<cfset local.sTripKey = arguments.stTripKeys[stAirPricingSolution.XMLAttributes.key].HashIndex>
				<cfset stTrips[sTripKey].Segments = StructNew('linked')>
				<cfset local.stCarriers = {}>
				<cfset local.nTempGroup = -1>
				<cfset local.nPreHash = -1>
				<cfset local.Flights = StructNew('linked')>
				<cfloop array="#stAirPricingSolution.XMLChildren#" index="local.stAirPricingNode">
					<cfset local.sSegmentKey = (StructKeyExists(stAirPricingNode.XMLAttributes, 'Key') ? stAirPricingNode.XMLAttributes.Key : 0)>
					<cfif stAirPricingNode.XMLName EQ 'air:AirSegmentRef'>
						<!--- Segment key and class of service --->
						<cfset local.HashIndex = arguments.stSegmentKeys[sSegmentKey].HashIndex>
						<cfset stTrips[sTripKey].Segments[HashIndex] = arguments.stSegments[HashIndex]>
						<cfset stCarriers[arguments.stSegments[HashIndex].Carrier] = ''>
						<cfif nTempGroup EQ -1>
							<cfset stTrips[sTripKey].Segments[HashIndex].Start = 1>
							<cfset Flights = StructNew('linked')>
						</cfif>
						<cfif nTempGroup NEQ -1 AND nTempGroup EQ arguments.stSegments[HashIndex].Group>
							<cfset local.nLayover = DateDiff('n', arguments.stSegments[nPreHash].ArrivalTime, arguments.stSegments[HashIndex].DepartureTime)>
							<cfset stTrips[sTripKey].Segments[nPreHash].Layover = '#int(nLayover/60)#h #nLayover%60#m'>
						</cfif>
						<cfif nTempGroup NEQ -1 AND nTempGroup NEQ arguments.stSegments[HashIndex].Group>
							<cfset stTrips[sTripKey].Segments[nPreHash].Dest = 1>
							<cfset stTrips[sTripKey].Segments[nPreHash].Flights = StructKeyList(Flights)>
							<cfset stTrips[sTripKey].Segments[HashIndex].Start = 1>
							<cfset Flights = StructNew('linked')>
						</cfif>
						<cfset Flights[arguments.stSegments[HashIndex].Carrier&arguments.stSegments[HashIndex].FlightNumber] = ''>
						<cfset nTempGroup = arguments.stSegments[HashIndex].Group>
						<cfset nPreHash = HashIndex>
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
				<cfset stTrips[sTripKey].Segments[HashIndex].Flights = StructKeyList(Flights)>
				<cfset stTrips[sTripKey].Segments[HashIndex].Dest = 1>
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
	<cffunction name="addTripLowFare" returntype="struct" output="false">
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
		</cfloop>
		
		<cfreturn stTrips/>
	</cffunction>
	
<!--- lowfare : mergeSegments --->
	<cffunction name="mergeSegments" returntype="struct" output="false">
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
	<cffunction name="mergeTrips" returntype="struct" output="false">
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
	
</cfcomponent>