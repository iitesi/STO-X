<cfcomponent>
	
<!---
doAirAvailability
--->
	<cffunction name="doAirAvailability" returntype="string" output="false">
		<cfargument name="objUAPI"		required="true">
		<cfargument name="objAirParse"	required="true">
		<cfargument name="nSearchID"	required="true">
		<cfargument name="nGroup"		required="true">
		<cfargument name="stAccount"	required="false" 	default="#application.stAccounts[session.Acct_ID]#">
		<cfargument name="stPolicy"		required="false"	default="#application.stPolicies[session.searches[url.Search_ID].Policy_ID]#">
		
		<cfset local.sMessage 			= 	prepareSoapHeader(arguments.stAccount, arguments.stPolicy, arguments.nSearchID, arguments.nGroup)>
		<cfset local.sResponse 			= 	arguments.objUAPI.callUAPI('AirService', sMessage, arguments.nSearchID)>
		<cfset local.aResponse 			= 	arguments.objUAPI.formatUAPIRsp(sResponse)>
		<cfset local.stSegmentKeys 		= 	arguments.objAirParse.parseSegmentKeys(aResponse)>
		<cfset stSegmentKeys 			= 	addSegmentRefs(aResponse, stSegmentKeys)>
		<cfset local.stSegments 		= 	arguments.objAirParse.parseSegments(aResponse, stSegmentKeys)>
		<cfset stSegments 				= 	arguments.objAirParse.mergeSegments(session.searches[nSearchID].stSegments, stSegments)>
		<cfset local.stSegmentKeyLookUp = 	parseKeyLookUp(stSegmentKeys)>
		<cfset local.stAvailTrips 		= 	parseConnections(aResponse, stSegments, stSegmentKeys, stSegmentKeyLookUp)>
		<cfset local.stAvailTrips 		= 	addPreferred(stAvailTrips, stAccount)>
		<cfset local.stCarriers 		= 	getCarriers(stAvailTrips)>
		
		<cfset session.searches[nSearchID].stSegments 	= stSegments>
		<cfset session.searches[nSearchID].stAvailTrips = stAvailTrips>
		<cfset session.searches[nSearchID].stCarriers 	= stCarriers>
		
		<cfset session.searches[nSearchID].stSortSegments = StructKeyArray(session.searches[nSearchID].stAvailTrips)>
		
		<cfreturn >
	</cffunction>

<!---
prepareSoapHeader
--->
	<cffunction name="prepareSoapHeader" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="stPolicy" 	required="true">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="nGroup"	 	required="true">
		
		<cfquery name="local.getsearch">
		SELECT Air_Type, Airlines, International, Depart_City, Depart_DateTime, Depart_TimeType, Arrival_City, Arrival_DateTime, Arrival_TimeType, ClassOfService
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<cfif getsearch.Air_Type EQ 'MD'>
			<cfquery name="local.getsearchlegs">
			SELECT Depart_City, Arrival_City, Depart_DateTime, Depart_TimeType
			FROM Searches_Legs
			WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
			</cfquery>
		</cfif>
		
		<cfsavecontent variable="local.message">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<air:AvailabilitySearchReq TargetBranch="#arguments.stAccount.sBranch#" xmlns:air="http://www.travelport.com/schema/air_v18_0" xmlns:com="http://www.travelport.com/schema/common_v15_0">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
							<cfif arguments.nGroup EQ 0>
								<air:SearchAirLeg>
									<air:SearchOrigin>
										<com:Airport Code="#getsearch.Depart_City#" />
									</air:SearchOrigin>
									<air:SearchDestination>
										<com:Airport Code="#getsearch.Arrival_City#" />
									</air:SearchDestination>
									<air:SearchDepTime PreferredTime="#DateFormat(getsearch.Depart_DateTime, 'yyyy-mm-dd')#" />
								</air:SearchAirLeg>
							</cfif>
							<cfif arguments.nGroup EQ 1 AND getsearch.Air_Type EQ 'RT'>
								<air:SearchAirLeg>
									<air:SearchOrigin>
										<com:Airport Code="#getsearch.Arrival_City#" />
									</air:SearchOrigin>
									<air:SearchDestination>
										<com:Airport Code="#getsearch.Depart_City#" />
									</air:SearchDestination>
									<air:SearchDepTime PreferredTime="#DateFormat(getsearch.Arrival_DateTime, 'yyyy-mm-dd')#" />
								</air:SearchAirLeg>
							<cfelseif arguments.nGroup NEQ 0 AND getsearch.Air_Type EQ 'MD'>
								<cfset local.cnt = 0>
								<cfloop query="getsearchlegs">
									<cfset cnt++>
									<cfif arguments.nGroup EQ cnt>
										<air:SearchAirLeg>
											<air:SearchOrigin>
												<com:Airport Code="#getsearchlegs.Depart_City#" />
											</air:SearchOrigin>
											<air:SearchDestination>
												<com:Airport Code="#getsearchlegs.Arrival_City#" />
											</air:SearchDestination>
											<air:SearchDepTime PreferredTime="#DateFormat(getsearchlegs.Depart_DateTime, 'yyyy-mm-dd')#" />
										</air:SearchAirLeg>
									</cfif>
								</cfloop>
							</cfif>
							<air:AirSearchModifiers DistanceType="MI" IncludeFlightDetails="false" RequireSingleCarrier="false" AllowChangeOfAirport="false" ProhibitOvernightLayovers="false" MaxSolutions="300" MaxConnections="1" MaxStops="1" ProhibitMultiAirportConnection="true" PreferNonStop="true">
							</air:AirSearchModifiers>
							<com:SearchPassenger Code="ADT" />
							<com:PointOfSale ProviderCode="1V" PseudoCityCode="1M98" />
						</air:AvailabilitySearchReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn message/>
	</cffunction>

<!---
addSegmentRefs
--->
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


<!---
parseKeyLookup - schedule
--->
	<cffunction name="parseKeyLookup" output="false">
		<cfargument name="stSegmentKeys">
		
		<cfset local.stSegmentKeyLookUp = {}>
		<cfloop collection="#arguments.stSegmentKeys#" item="local.sKey">
			<cfset stSegmentKeyLookUp[stSegmentKeys[sKey].nLocation] = sKey>
		</cfloop>
		
		<cfreturn stSegmentKeyLookUp />
	</cffunction>

<!---
parseConnections - schedule
--->
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
	
<!---
addPreferred
--->
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

<!---
getCarriers
--->
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
	
</cfcomponent>