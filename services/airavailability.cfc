<cfcomponent output="false" accessors="true">

	<cfproperty name="uapi">
	<cfproperty name="airparse">

<!---
init
--->
	<cffunction name="init" output="false">
		<cfargument name="uapi">
		<cfargument name="airparse">

		<cfset setUAPI(arguments.uapi)>
		<cfset setAirParse(arguments.airparse)>
		
		<cfreturn this>
	</cffunction>
	
<!---
selectLeg
--->
	<cffunction name="selectLeg" output="false">
		<cfargument name="nSearchID">
		<cfargument name="nGroup">
		<cfargument name="nTrip">

		<cfset session.searches[arguments.nSearchID].stSelected[arguments.nGroup] = session.searches[arguments.nSearchID].stAvailTrips[arguments.nGroup][arguments.nTrip]>
				
		<cfreturn />
	</cffunction>
	
<!---
threadAvailability
--->
	<cffunction name="threadAvailability" output="false">
		<cfargument name="nSearchID"	required="true">
		<cfargument name="nGroup"		required="false"	default="">
		<cfargument name="stLegs"		required="false"	default="#session.searches[url.Search_ID].stLegs#">

		<cfset local.stThreads = {}>
		<cfset local.sThreadName = ''>
		<cfset local.sPriority = ''>

		<!--- Create a thread for every leg.  Give priority to the group specifically selected. --->
		<cfloop collection="#arguments.stLegs#" item="local.nLeg">
			<cfif arguments.nGroup EQ nLeg>
				<cfset sPriority = 'HIGH'>
			<cfelse>
				<cfset sPriority = 'LOW'>
			</cfif>
			<cfset sThreadName = doAvailability(arguments.nSearchID, nLeg, sPriority)>
			<cfif sPriority EQ 'HIGH' AND sThreadName NEQ ''>
				<cfset stThreads[sThreadName] = ''>
			</cfif>
		</cfloop>

		<!--- Join only if threads where thrown out. --->
		<cfif NOT StructIsEmpty(stThreads)>
			<cfthread action="join" name="#structKeyList(stThreads)#" />
			<!--- <cfdump eval=stThreads> --->
			<!--- <cfdump eval=cfthread abort> --->
		</cfif>

		<cfreturn >
	</cffunction>

<!---
doAirAvailability
--->
	<cffunction name="doAvailability" output="false">
		<cfargument name="nSearchID"	required="true">
		<cfargument name="nGroup"		required="true">
		<cfargument name="sPriority"	required="false"	default="NORMAL">
		<cfargument name="stGroups"		required="false"	default="#session.searches[nSearchID].stAvailDetails.stGroups#">

		<cfset local.sThreadName = ''>
		<!--- Don't go back to the getUAPI if we already got the data. --->
		<cfif NOT StructKeyExists(arguments.stGroups, nGroup)>
			<!--- Name of the thread thrown out. --->
			<cfset sThreadName = 'Group'&arguments.nGroup>
			<!--- Kick off the thread. --->
			<cfthread
			action="run"
			name="#sThreadName#"
			priority="#arguments.sPriority#"
			nSearchID="#arguments.nSearchID#"
			nGroup="#arguments.nGroup#">
				<cfset local.sNextRef = 'ROUNDONE'>
				<cfset local.nCount = 0>
				<cfloop condition="sNextRef NEQ ''">
					<cfset local.nCount++>
					<!--- Put together the SOAP message. --->
					<cfset local.sMessage 			= 	prepareSoapHeader(arguments.nSearchID, arguments.nGroup, (sNextRef NEQ 'ROUNDONE' ? sNextRef : ''))>
					<!--- Call the getUAPI. --->
					<cfset local.sResponse 			= 	getgetUAPI().callgetUAPI('AirService', sMessage, arguments.nSearchID)>
					<!--- Format the getUAPI response. --->
					<cfset local.aResponse 			= 	getgetUAPI().formatgetUAPIRsp(sResponse)>
					<!--- Create unique segment keys. --->
					<cfset sNextRef 				= 	getAirParse().parseNextReference(aResponse)>
					<cfif nCount GT 3>
						<cfset sNextRef				= ''>
					</cfif>
					<!--- <cfdump eval=sNextRef> --->
					<!--- Create unique segment keys. --->
					<cfset local.stSegmentKeys 		= 	parseSegmentKeys(aResponse)>
					<!--- Add in the connection references --->
					<cfset stSegmentKeys 			= 	addSegmentRefs(aResponse, stSegmentKeys)>
					<!--- Parse the segments. --->
					<cfset local.stSegments 		= 	parseSegments(aResponse, stSegmentKeys)>
					<!--- Create a look up list opposite of the stSegmentKeys --->
					<cfset local.stSegmentKeyLookUp = 	parseKeyLookUp(stSegmentKeys)>
					<!--- Parse the trips. --->
					<cfset local.stAvailTrips 		= 	parseConnections(aResponse, stSegments, stSegmentKeys, stSegmentKeyLookUp)>
					<!--- Add group node --->
					<cfset stAvailTrips				= 	getAirParse().addGroups(stAvailTrips, 'Avail')>
					<!--- Mark preferred carriers. --->
					<cfset stAvailTrips 			= 	getAirParse().addPreferred(stAvailTrips)>
					<!--- Run policy on all the results --->
					<cfset stAvailTrips				= 	getAirParse().checkPolicy(stAvailTrips, arguments.nSearchID, '', 'Avail')>
					<!--- Create javascript structure per trip. --->
					<cfset stAvailTrips				= 	getAirParse().addJavascript(stAvailTrips, 'Avail')>
					<!--- Merge information into the current session structures. --->
					<cfset session.searches[arguments.nSearchID].stAvailTrips[arguments.nGroup] = getAirParse().mergeTrips(session.searches[arguments.nSearchID].stAvailTrips[arguments.nGroup], stAvailTrips)>
				</cfloop>
				<!--- Add list of available carriers per leg --->
				<cfset session.searches[arguments.nSearchID].stAvailDetails.stCarriers[arguments.nGroup]	= getAirParse().getCarriers(session.searches[arguments.nSearchID].stAvailTrips[arguments.nGroup])>
				<!--- Add sorting per leg --->
				<cfset session.searches[arguments.nSearchID].stAvailDetails.aSortDepart[arguments.nGroup] 	= StructSort(session.searches[arguments.nSearchID].stAvailTrips[arguments.nGroup], 'numeric', 'asc', 'Depart')>
				<cfset session.searches[arguments.nSearchID].stAvailDetails.aSortArrival[arguments.nGroup] 	= StructSort(session.searches[arguments.nSearchID].stAvailTrips[arguments.nGroup], 'numeric', 'asc', 'Arrival')>
				<cfset session.searches[arguments.nSearchID].stAvailDetails.aSortDuration[arguments.nGroup]	= StructSort(session.searches[arguments.nSearchID].stAvailTrips[arguments.nGroup], 'numeric', 'asc', 'Duration')>
				<!--- Mark this leg as priced --->
				<cfset session.searches[arguments.nSearchID].stAvailDetails.stGroups[arguments.nGroup] 		= 1>
			</cfthread>
		</cfif>

		<cfreturn sThreadName>
	</cffunction>

<!---
prepareSoapHeader
--->
	<cffunction name="prepareSoapHeader" returntype="string" output="false">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="nGroup"	 	required="true">
		<cfargument name="sNextRef"	 	required="false" 	default="">
		<cfargument name="stAccount"	required="false" 	default="#application.stAccounts[session.Acct_ID]#">
		<cfargument name="stPolicy"		required="false"	default="#application.stPolicies[session.searches[url.Search_ID].nPolicyID]#">
		<cfargument name="stSearch" 			required="false"	default="#session.searches[url.Search_ID]#">
		
		<cfif arguments.stSearch.sAirType EQ 'MD'>
			<cfquery name="local.qSearchLegs">
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
							<cfif arguments.sNextRef NEQ ''>
								<com:NextResultReference>#arguments.sNextRef#</com:NextResultReference>
							</cfif>
							<cfif arguments.nGroup EQ 0>
								<air:SearchAirLeg>
									<air:SearchOrigin>
										<com:Airport Code="#arguments.stSearch.sDepartCity#" />
									</air:SearchOrigin>
									<air:SearchDestination>
										<com:Airport Code="#arguments.stSearch.sArrivalCity#" />
									</air:SearchDestination>
									<air:SearchDepTime PreferredTime="#DateFormat(arguments.stSearch.dDepartDate, 'yyyy-mm-dd')#" />
								</air:SearchAirLeg>
							</cfif>
							<cfif arguments.nGroup EQ 1 AND arguments.stSearch.sAirType EQ 'RT'>
								<air:SearchAirLeg>
									<air:SearchOrigin>
										<com:Airport Code="#arguments.stSearch.sArrivalCity#" />
									</air:SearchOrigin>
									<air:SearchDestination>
										<com:Airport Code="#arguments.stSearch.sDepartCity#" />
									</air:SearchDestination>
									<air:SearchDepTime PreferredTime="#DateFormat(arguments.stSearch.dArrivalDate, 'yyyy-mm-dd')#" />
								</air:SearchAirLeg>
							<cfelseif arguments.nGroup NEQ 0 AND arguments.stSearch.sAirType EQ 'MD'>
								<cfset local.cnt = 0>
								<cfloop query="qSearchLegs">
									<cfset cnt++>
									<cfif arguments.nGroup EQ cnt>
										<air:SearchAirLeg>
											<air:SearchOrigin>
												<com:Airport Code="#qSearchLegs.Depart_City#" />
											</air:SearchOrigin>
											<air:SearchDestination>
												<com:Airport Code="#qSearchLegs.Arrival_City#" />
											</air:SearchDestination>
											<air:SearchDepTime PreferredTime="#DateFormat(qSearchLegs.Depart_DateTime, 'yyyy-mm-dd')#" />
										</air:SearchAirLeg>
									</cfif>
								</cfloop>
							</cfif>
							<cfif arguments.sNextRef EQ ''>
								<air:AirSearchModifiers DistanceType="MI" IncludeFlightDetails="false" RequireSingleCarrier="true" AllowChangeOfAirport="false" ProhibitOvernightLayovers="true" MaxSolutions="300" MaxConnections="1" MaxStops="1" ProhibitMultiAirportConnection="true" PreferNonStop="true">
								</air:AirSearchModifiers>
								<com:PointOfSale ProviderCode="1V" PseudoCityCode="1M98" />
							</cfif>
						</air:AvailabilitySearchReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>

		<cfreturn message/>
	</cffunction>

<!---
parseSegmentKeys
--->
	<cffunction name="parseSegmentKeys" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stSegmentKeys = {}>
		<cfset local.sIndex = ''>
		<!--- Create list of fields that make up a distint segment. --->
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber','TravelTime']>
		<!--- Loop through results. --->
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<cfif stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<!--- Build up the distinct segment string. --->
					<cfset sIndex = ''>
					<cfloop array="#aSegmentKeys#" index="local.sCol">
						<cfset sIndex &= stAirSegment.XMLAttributes[sCol]>
					</cfloop>
					<!--- Create a look up structure for the primary key. --->
					<cfset stSegmentKeys[stAirSegment.XMLAttributes.Key] = {
						HashIndex	: 	getUAPI.HashNumeric(sIndex),
						Index		: 	sIndex
					}>
				</cfloop>
			</cfif>
		</cfloop>
			
		<cfreturn stSegmentKeys />
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
parseSegments
--->
	<cffunction name="parseSegments" output="false">
		<cfargument name="stResponse"		required="true">
		<cfargument name="stSegmentKeys"	required="true">
		
		<cfset local.stSegments = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<cfif stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<cfset local.dArrivalGMT = stAirSegment.XMLAttributes.ArrivalTime>
					<cfset local.dArrivalTime = GetToken(dArrivalGMT, 1, '.')>
					<cfset local.dArrivalOffset = GetToken(GetToken(dArrivalGMT, 2, '-'), 1, ':')>
					<cfset local.dDepartGMT = stAirSegment.XMLAttributes.DepartureTime>
					<cfset local.dDepartTime = GetToken(dDepartGMT, 1, '.')>
					<cfset local.dDepartOffset = GetToken(GetToken(dDepartGMT, 2, '-'), 1, ':')>
					<cfset stSegments[arguments.stSegmentKeys[stAirSegment.XMLAttributes.Key].HashIndex] = {
						Arrival				: dArrivalGMT,
						ArrivalTime			: ParseDateTime(dArrivalTime),
						ArrivalGMT			: ParseDateTime(DateAdd('h', dArrivalOffset, dArrivalTime)),
						Carrier 			: stAirSegment.XMLAttributes.Carrier,
						ChangeOfPlane		: stAirSegment.XMLAttributes.ChangeOfPlane EQ 'true',
						Departure			: dDepartGMT,
						DepartureTime		: ParseDateTime(dDepartTime),
						DepartureGMT		: ParseDateTime(DateAdd('h', dDepartOffset, dDepartTime)),
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
		<cfset local.aCarriers = {}>
		<cfset local.nHashNumeric = ''>
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<cfloop collection="#stSegmentIndex#" item="local.nIndex">
			<cfloop collection="#stSegmentIndex[nIndex]#" item="local.sSegment">
				<cfset sIndex = ''>
				<cfloop array="#aSegmentKeys#" index="local.stSegment">
					<cfset sIndex &= stSegmentIndex[nIndex][sSegment][stSegment]>
				</cfloop>
			</cfloop>
			<cfset nHashNumeric = getUAPI.hashNumeric(sIndex)>
			<cfset stTrips[nHashNumeric].Segments = stSegmentIndex[nIndex]>
			<cfset stTrips[nHashNumeric].Class = 'X'>
			<cfset stTrips[nHashNumeric].Ref = 'X'>
		</cfloop>
		
		<cfreturn stTrips />
	</cffunction>
	
</cfcomponent>