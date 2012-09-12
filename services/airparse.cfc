<cfcomponent output="false">
	
<!--- init --->
	<cffunction name="init" output="false">
		<cfreturn this>
	</cffunction>
	
<!--- callAPI --->
	<cffunction name="callAPI" output="false">
		<cfargument name="sService">
		<cfargument name="sMessage">
		<cfargument name="sAPIAuth">
		<cfargument name="nSearchID">
		
		<cfset local.bSessionStorage = 1><!--- Testing setting (1 - testing, 0 - live) --->
		
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
	<!--- Both fare and schedule search --->
	<cffunction name="formatResponse" output="false">
		<cfargument name="stResponse">
		
		<cfset local.stResponse = XMLParse(arguments.stResponse)>
		
		<cfreturn stResponse.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren />
	</cffunction>
	
<!--- parseSegmentKeys --->
	<!--- Both fare and schedule search --->
	<cffunction name="parseSegmentKeys" output="false">
		<cfargument name="stResponse">
		
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<cfset local.stSegmentKeys = {}>
		<cfset local.sIndex = ''>
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
	
<!--- addSegmentRefs --->
	<!--- Schedule search --->
	<cffunction name="addSegmentRefs" output="false">
		<cfargument name="stResponse">
		<cfargument name="stSegmentKeys">
		
		<cfset local.sAPIKey = ''>
		<cfset local.cnt = 0>
		<cfloop array="#arguments.stResponse#" index="local.stAirItinerarySolution">
			<cfif stAirItinerarySolution.XMLName EQ 'air:AirItinerarySolution'>
				<cfloop array="#stAirItinerarySolution.XMLChildren#" index="local.stAirSegmentRef">
					<cfif stAirSegmentRef.XMLName EQ 'air:AirSegmentRef'>
						<cfset sAPIKey = stAirSegmentRef.XMLAttributes.Key>
						<cfset arguments.stSegmentKeys[sAPIKey].nLocation = cnt>
						<cfset cnt++>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
			
		<cfreturn arguments.stSegmentKeys />
	</cffunction>
	
<!--- parseSegments --->
	<!--- Both fare and schedule search --->
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
				</cfloop>
			</cfif>
		</cfloop>
			
		<cfreturn stSegments />
	</cffunction>

<!--- parseKeyLookup --->
	<!--- Schedule search --->
	<cffunction name="parseKeyLookup" output="false">
		<cfargument name="stSegmentKeys">
		
		<cfset local.stSegmentKeyLookUp = {}>
		<cfloop collection="#arguments.stSegmentKeys#" item="local.sKey">
			<cfset stSegmentKeyLookUp[stSegmentKeys[sKey].nLocation] = sKey>
		</cfloop>
		
		<cfreturn stSegmentKeyLookUp />
	</cffunction>

<!--- parseConnections --->
	<!--- Schedule search --->
	<cffunction name="parseConnections" output="false">
		<cfargument name="stResponse">
		<cfargument name="stSegments">
		<cfargument name="stSegmentKeys">
		<cfargument name="stSegmentKeyLookUp">
		
		<!--- Create a structure to hold FIRST connection points --->
		<cfset local.stSegmentIndex = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirItinerarySolution">
			<cfif stAirItinerarySolution.XMLName EQ 'air:AirItinerarySolution'>
				<cfloop array="#stAirItinerarySolution.XMLChildren#" index="local.stConnection">
					<cfif stConnection.XMLName EQ 'air:Connection'>
						<cfset stSegmentIndex[stConnection.XMLAttributes.SegmentIndex] = StructNew('linked')>
						<cfset stSegmentIndex[stConnection.XMLAttributes.SegmentIndex][1] = stSegments[stSegmentKeys[stSegmentKeyLookUp[stConnection.XMLAttributes.SegmentIndex]].HashIndex]>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		<!--- Add to that structure the missing connection points --->
		<cfset local.stTrips = {}>
		<cfset local.nCount = 0>
		<cfset local.nSegNum = 1>
		<cfset local.nMaxCount = ArrayLen(StructKeyArray(stSegmentKeys))>
		<cfloop collection="#stSegmentIndex#" item="local.nIndex">
			<cfset nCount = nIndex>
			<cfset nSegNum = 1>
			<cfloop condition="NOT StructKeyExists(stSegmentIndex, nCount+1) AND nCount LT nMaxCount AND StructKeyExists(stSegmentKeyLookUp, nCount+1)">
				<cfset nSegNum++>
				<cfset stSegmentIndex[nIndex][nSegNum] = stSegments[stSegmentKeys[stSegmentKeyLookUp[nCount+1]].HashIndex]>
				<cfset nCount++>
			</cfloop>
		</cfloop>
		<!--- Create an appropriate trip key --->
		<cfset local.stTrips = {}>
		<cfset local.sIndex = ''>
		<cfset local.stCarriers = {}>
		<cfset local.nHashNumeric = ''>
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<cfloop collection="#stSegmentIndex#" item="local.nIndex">
			<cfset stCarriers = {}>
			<cfloop collection="#stSegmentIndex[nIndex]#" item="local.sSegment">
				<cfset sIndex = ''>
				<cfloop array="#aSegmentKeys#" index="local.stSegment">
					<cfset sIndex &= stSegmentIndex[nIndex][sSegment][stSegment]>
				</cfloop>
				<cfset stCarriers[stSegmentIndex[nIndex][sSegment].Carrier] = ''>
			</cfloop>
			<cfset nHashNumeric = HashNumeric(sIndex)>
			<cfset stTrips[nHashNumeric].Segments = stSegmentIndex[nIndex]>
			<cfset stTrips[nHashNumeric].stSortArrival = stTrips[nHashNumeric].Segments[1].ArrivalTime>
			<cfset stTrips[nHashNumeric].stSortArrival = stTrips[nHashNumeric].Segments[sSegment].DepartureTime>
			<cfset stTrips[nHashNumeric].Carriers = StructKeyList(stCarriers)>
		</cfloop>
		
		<cfreturn stTrips />
	</cffunction>

<!--- parseTripKeys --->
	<!--- Fare search --->
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
	
<!--- parseFares --->
	<!--- Fare search --->
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
	
<!--- parseTrips --->
	<!--- Fare search --->
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
	
<!--- mergeSegments --->
	<!--- Both fare and schedule search --->
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

<!--- mergeTrips --->
	<!--- Fare search --->
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
	
</cfcomponent>