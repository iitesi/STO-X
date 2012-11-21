<cfcomponent output="false">
	
<!---
init
--->
	<cffunction name="init" output="false">
		<cfreturn this>
	</cffunction>

<!---
parseSegments - both
--->
	<cffunction name="parseSegments" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stSegments = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<cfif stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<cfset stSegments[stAirSegment.XMLAttributes.Key] = {
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
	
<!---
mergeSegments
--->
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

<!---
mergeTrips
--->
	<cffunction name="mergeTrips" output="false">
		<cfargument name="stTrips1" 	required="true">
		<cfargument name="stTrips2" 	required="true">
		
		<cfset local.stCombinedTrips = arguments.stTrips1>
		<cfif IsStruct(stCombinedTrips) AND IsStruct(arguments.stTrips2)>
			<cfloop collection="#arguments.stTrips2#" item="local.sTripKey">
				<cfif StructKeyExists(stCombinedTrips, sTripKey)>
					<cfloop collection="#arguments.stTrips2[sTripKey]#" item="local.sFareKey">
						<cfset stCombinedTrips[sTripKey][sFareKey] = arguments.stTrips2[sTripKey][sFareKey]>
					</cfloop>
				<cfelse>
					<cfset stCombinedTrips[sTripKey] = arguments.stTrips2[sTripKey]>
				</cfif>
			</cfloop>
		<cfelseif IsStruct(arguments.stTrips2)>
			<cfset stCombinedTrips = arguments.stTrips2>
		</cfif>
		<cfif NOT IsStruct(stCombinedTrips)>
			<cfset stCombinedTrips = {}>
		</cfif>

		<cfreturn stCombinedTrips/>
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
addGroups
--->
	<cffunction name="addGroups" output="false">
		<cfargument name="stTrips" 	required="true">
		<cfargument name="sType" 	required="false"	default="Fare">
		
		<cfset local.stGroups = {}>
		<cfset local.stCarriers = {}>
		<cfset local.stSegment = ''>
		<cfset local.nStops = ''>
		<cfset local.nTotalStops = ''>
		<cfset local.nDuration = ''>
		<cfset local.nOverrideGroup = 0>
		<!--- Loop through all the trips --->
		<cfloop collection="#arguments.stTrips#" item="local.sTrip">
			<cfset stGroups = {}>
			<cfset stCarriers = {}>
			<cfset nDuration = 0>
			<cfset nTotalStops = 0>
			<cfloop collection="#arguments.stTrips[sTrip].Segments#" item="local.nSegment">
				<cfset stSegment = arguments.stTrips[sTrip].Segments[nSegment]>
				<cfset nOverrideGroup = stSegment.Group>
				<cfset stSegment.Group = nOverrideGroup>
				<cfif NOT structKeyExists(stGroups, nOverrideGroup)>
					<cfset stGroups[nOverrideGroup].DepartureTime 	= stSegment.DepartureTime>
					<cfset stGroups[nOverrideGroup].Origin			= stSegment.Origin>
					<cfset stGroups[nOverrideGroup].TravelTime		= '#int(stSegment.TravelTime/60)#h #stSegment.TravelTime%60#m'>
					<cfset nDuration = stSegment.TravelTime + nDuration>
					<cfset nStops = -1>
				</cfif>
				<cfset stGroups[nOverrideGroup].ArrivalTime	 	= stSegment.ArrivalTime>
				<cfset stGroups[nOverrideGroup].Destination		= stSegment.Destination>
				<cfset local.stCarriers[stSegment.Carrier] = ''>
				<cfset nStops++>
				<cfset stGroups[nOverrideGroup].Stops				= nStops>
				<cfif nStops GT nTotalStops>
					<cfset nTotalStops = nStops>
				</cfif>
			</cfloop>
			<cfset stTrips[sTrip].Groups 	= stGroups>
			<cfset stTrips[sTrip].Duration 	= nDuration>
			<cfset stTrips[sTrip].Stops 	= nTotalStops>
			<cfif arguments.sType EQ 'Avail'>
				<cfset stTrips[sTrip].Depart= stGroups[nOverrideGroup].DepartureTime>
			<cfelse>
				<cfset stTrips[sTrip].Depart= stGroups[0].DepartureTime>
			</cfif>
			<cfset stTrips[sTrip].Arrival 	= stGroups[nOverrideGroup].ArrivalTime>
			<cfset stTrips[sTrip].Carriers 	= structKeyList(stCarriers)>
		</cfloop>
		
		<cfreturn stTrips/>
	</cffunction>

<!---
addJavascript
--->
	<cffunction name="addJavascript" output="false">
		<cfargument name="stTrips" 	required="true">
		<cfargument name="sType" 	required="false"	default="Fare">
		
		<cfif arguments.sType EQ 'Fare'>
			<cfset local.aAllCabins = ['Y','C','F']>
			<cfset local.aRefundable = [0,1]>
		</cfif>
		<!--- Loop through all the trips --->
		<cfloop collection="#arguments.stTrips#" item="local.sTrip">
			<cfset sCarriers = '"#Replace(arguments.stTrips[sTrip].Carriers, ',', '","', 'ALL')#"'>
			<cfset stTrips[sTrip].sJavascript = addJavascriptPerTrip(sTrip, arguments.stTrips[sTrip], arguments.stTrips[sTrip].Class, arguments.stTrips[sTrip].Ref, sCarriers)>
		</cfloop>
		
		<cfreturn stTrips/>
	</cffunction>

<!---
addJavascriptPerTrip - used only in the above function
--->
	<cffunction name="addJavascriptPerTrip" output="false">
		<cfargument name="sTrip" 	required="true">
		<cfargument name="stTrip" 	required="true">
		<cfargument name="sCabin" 	required="true">
		<cfargument name="bRef" 	required="true">
		<cfargument name="sCarriers"required="true">
		
		<cfset local.sJavascript = "">
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
		<cfset sJavascript = '"#arguments.sTrip#"'><!--- Token  --->
		<cfset sJavascript = ListAppend(sJavascript, 1)><!--- Policy --->
		<cfset sJavascript = ListAppend(sJavascript, (ListLen(arguments.sCarriers) EQ 1 ? 0 : 1))><!--- Multi Carriers --->
		<cfset sJavascript = ListAppend(sJavascript, '[#arguments.sCarriers#]')><!--- All Carriers --->
		<cfset sJavascript = ListAppend(sJavascript, '"#arguments.bRef#"')><!--- Refundable --->
		<cfset sJavascript = ListAppend(sJavascript, arguments.stTrip.Preferred)><!--- Preferred --->
		<cfset sJavascript = ListAppend(sJavascript, '"#arguments.sCabin#"')><!--- Cabin Class --->
		<cfset sJavascript = ListAppend(sJavascript, arguments.stTrip.Stops)><!--- Stops --->
		
		<cfreturn sJavascript/>
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

<!---
mergeTripsToAvail
--->
	<cffunction name="mergeTripsToAvail" output="false">
		<cfargument name="stTrips"		required="true">
		<cfargument name="stAvailTrips"	required="true">
		
		<cfset local.stTempTrips = {}>
		<cfset local.nGroup = ''>
		<cfloop collection="#arguments.stTrips#" item="local.sTripKey">
			<cfloop collection="#arguments.stTrips[sTripKey].Segments#" item="local.nSegment">
				<cfset nGroup = arguments.stTrips[sTripKey].Segments[nSegment].Group>
				<cfif NOT structKeyExists(stTempTrips, nGroup)
				OR NOT structKeyExists(stTempTrips[nGroup], sTripKey)>
					<cfset stTempTrips[nGroup][sTripKey] = StructNew('linked')>
				</cfif>
				<cfset stTempTrips[nGroup][sTripKey][nSegment] = arguments.stTrips[sTripKey].Segments[nSegment]>
			</cfloop>
		</cfloop>
		<cfset local.sIndex = ''>
		<cfset local.nHashNumeric = ''>
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<cfloop collection="#stTempTrips#" item="local.nGroup">
			<cfloop collection="#stTempTrips[nGroup]#" item="local.sTripKey">
				<cfset sIndex = ''>
				<cfloop collection="#stTempTrips[nGroup][sTripKey]#" item="local.sSegment">
					<cfloop array="#aSegmentKeys#" index="local.stSegment">
						<cfset sIndex &= stTempTrips[nGroup][sTripKey][sSegment][stSegment]>
					</cfloop>
				</cfloop>
				<cfset nHashNumeric = HashNumeric(sIndex)>
				<cfif NOT structKeyExists(arguments.stAvailTrips[nGroup], nHashNumeric)>
					<cfset arguments.stAvailTrips[nGroup][nHashNumeric].Segments = stTempTrips[nGroup][sTripKey]>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn arguments.stAvailTrips/>
	</cffunction>

<!---
checkPolicy
--->
	<cffunction name="checkPolicy" output="false">
		<cfargument name="stTrips"			required="true">
		<cfargument name="nSearchID"		required="true">
		<cfargument name="nLowFareTripKey"	required="true">
		<cfargument name="stAccount"		required="false"	default="#application.stAccounts[session.Acct_ID]#">
		<cfargument name="stPolicy" 		required="false"	default="#application.stPolicies[session.searches[url.Search_ID].Policy_ID]#">
		
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