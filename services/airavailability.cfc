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
		<cfargument name="nLegs"		required="false"	default="#ArrayLen(session.searches[url.Search_ID].Legs)#">
		<cfargument name="bThread"		required="false"	default="0"><!--- Skip threading if you need to troubleshoot an individual function --->
		
		<cfset local.bUAPICall = 0>

		<cfif NOT arguments.bThread>
			<!--- Create a thread for every leg. --->
			<cfloop from="0" to="#arguments.nLegs-1#" index="local.nLeg">
				<!--- Don't go back to the UAPI if we already got the data. --->
				<cfif NOT StructKeyExists(session.searches[nSearchID].AvailDetails.stGroups, nLeg)>

					<cfif nLeg EQ arguments.nGroup>
						<!--- Note that STO did go out to Apollo for results. --->
						<cfset bUAPICall = 1>
					</cfif>
					
					<!--- Kick off the thread. --->
					<cfthread
						action="run"
						name="Group#nLeg#"
						stAccount="#arguments.stAccount#"
						stPolicy="#arguments.stPolicy#"
						nSearchID="#arguments.nSearchID#"
						nGroup="#arguments.nGroup#"
						objUAPI="#arguments.objUAPI#"
						objAirParse="#arguments.objAirParse#"> 
						
						<!--- Define. --->
						<cfset thread.stAvailTrips = {}>
						<!--- Put together the SOAP message. --->
						<cfset local.sMessage 			= 	prepareSoapHeader(stAccount, stPolicy, nSearchID, nGroup)>
						<!--- Call the UAPI. --->
						<cfset local.sResponse 			= 	objUAPI.callUAPI('AirService', sMessage, nSearchID)>
						<!--- Format the UAPI response. --->
						<cfset local.aResponse 			= 	objUAPI.formatUAPIRsp(sResponse)>
						<!--- Create unique segment keys. --->
						<cfset local.stSegmentKeys 		= 	objAirParse.parseSegmentKeys(aResponse)>
						<!--- Add in the connection references --->
						<cfset stSegmentKeys 			= 	addSegmentRefs(aResponse, stSegmentKeys)>
						<!--- Parse the segments. --->
						<cfset local.stSegments 		= 	objAirParse.parseSegments(aResponse, stSegmentKeys)>
						<!--- Create a look up list opposite of the stSegmentKeys --->
						<cfset local.stSegmentKeyLookUp = 	parseKeyLookUp(stSegmentKeys)>
						<!--- Parse the trips. --->
						<cfset local.stAvailTrips 		= 	parseConnections(aResponse, stSegments, stSegmentKeys, stSegmentKeyLookUp)>
						<!--- Merge with current results --->
						<cfset stAvailTrips 			= 	objAirParse.mergeTrips(session.searches[nSearchID].stAvailTrips[nGroup], stAvailTrips)>
						<!--- Mark preferred carriers. --->
						<cfset stAvailTrips 			= 	objAirParse.addPreferred(stAvailTrips, stAccount)>
						<!--- Add group node --->
						<cfset stAvailTrips				= 	objAirParse.addGroups(stAvailTrips, 'Avail')>
						<!--- Create javascript structure per trip. --->
						<cfset stAvailTrips				= 	objAirParse.addJavascript(stAvailTrips, 'Avail')>
											
						<!--- If the UAPI gives an error then add these to the thread so it is visible to the developer. --->
						<cfif StructIsEmpty(thread.stAvailTrips)>
							<cfset thread.aResponse = 	aResponse>
							<cfset thread.sMessage =	sMessage>
						</cfif>

						<!--- Merge information into the current session structures. --->
						<cfset session.searches[nSearchID].stAvailTrips[nGroup] = stAvailTrips>
						<cfset session.searches[nSearchID].AvailDetails.stCarriers = objAirParse.getCarriers(stAvailTrips)>
						<cfset session.searches[nSearchID].AvailDetails.stSortSegments[nGroup] = StructKeyArray(session.searches[nSearchID].stAvailTrips[nGroup])>

						<cfset session.searches[nSearchID].AvailDetails.stGroups[nGroup] = 1>
					</cfthread>
				</cfif>
			</cfloop>

			<!--- Join only if threads where thrown out. --->
			<cfif bUAPICall>
				<cfthread action="join" name="Group#arguments.nGroup#" />
			</cfif>

		<cfelse>
			<cfset local.nLeg = arguments.nGroup>
			<!--- Don't go back to the UAPI if we already got the data. --->
			<cfif NOT StructKeyExists(session.searches[nSearchID].AvailDetails.stGroups, nLeg)>
				<!--- Note that STO did go out to Apollo for results. --->
				<cfset bUAPICall = 1>
				<!--- Define. --->
				<cfset stAvailTrips = {}>
				<!--- Put together the SOAP message. --->
				<cfset local.sMessage 			= 	prepareSoapHeader(stAccount, stPolicy, nSearchID, nGroup)>
				<!--- Call the UAPI. --->
				<cfset local.sResponse 			= 	objUAPI.callUAPI('AirService', sMessage, nSearchID)>
				<!--- Format the UAPI response. --->
				<cfset local.aResponse 			= 	objUAPI.formatUAPIRsp(sResponse)>
				<!--- Create unique segment keys. --->
				<cfset local.stSegmentKeys 		= 	objAirParse.parseSegmentKeys(aResponse)>
				<!--- Add in the connection references --->
				<cfset stSegmentKeys 			= 	addSegmentRefs(aResponse, stSegmentKeys)>
				<!--- Parse the segments. --->
				<cfset local.stSegments 		= 	objAirParse.parseSegments(aResponse, stSegmentKeys)>
				<!--- Create a look up list opposite of the stSegmentKeys --->
				<cfset local.stSegmentKeyLookUp = 	parseKeyLookUp(stSegmentKeys)>
				<!--- Parse the trips. --->
				<cfset local.stAvailTrips 		= 	parseConnections(aResponse, stSegments, stSegmentKeys, stSegmentKeyLookUp)>
				<!--- Merge with current results --->
				<cfset stAvailTrips 			= 	objAirParse.mergeTrips(session.searches[nSearchID].stAvailTrips[nGroup], stAvailTrips)>
				<!--- Mark preferred carriers. --->
				<cfset stAvailTrips 			= 	objAirParse.addPreferred(stAvailTrips, stAccount)>
				<!--- Add group node --->
				<cfset stAvailTrips				= 	objAirParse.addGroups(stAvailTrips, 'Avail')>
				<!--- Create javascript structure per trip. --->
				<cfset stAvailTrips				= 	objAirParse.addJavascript(stAvailTrips, 'Avail')>


				<!--- Merge information into the current session structures. --->
				<cfset session.searches[nSearchID].stAvailTrips[nGroup] = stAvailTrips>
				<cfset session.searches[nSearchID].AvailDetails.stCarriers = objAirParse.getCarriers(stAvailTrips)>
				<cfset session.searches[nSearchID].AvailDetails.stSortSegments[nGroup] = StructKeyArray(session.searches[nSearchID].stAvailTrips[nGroup])>

				<cfset session.searches[nSearchID].AvailDetails.stGroups[nGroup] = 1>
			</cfif>

		</cfif>

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
			<cfloop collection="#stSegmentIndex[nIndex]#" item="local.sSegment">
				<cfset sIndex = ''>
				<cfloop array="#aSegmentKeys#" index="local.stSegment">
					<cfset sIndex &= stSegmentIndex[nIndex][sSegment][stSegment]>
				</cfloop>
			</cfloop>
			<cfset nHashNumeric = HashNumeric(sIndex)>
			<cfset stTrips[nHashNumeric].Segments = stSegmentIndex[nIndex]>
		</cfloop>
		
		<cfreturn stTrips />
	</cffunction>
	
</cfcomponent>