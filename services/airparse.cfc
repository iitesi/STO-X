<cfcomponent output="false">
	
<!---
init
--->
	<cffunction name="init" output="false">
		<cfreturn this>
	</cffunction>
	
<!---
parseSegmentKeys - both
--->
	<cffunction name="parseSegmentKeys" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stSegmentKeys = {}>
		<cfset local.sIndex = ''>
		<!--- Create list of fields that make up a distint segment. --->
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
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
						HashIndex	: 	HashNumeric(sIndex),
						Index		: 	sIndex
					}>
				</cfloop>
			</cfif>
		</cfloop>
			
		<cfreturn stSegmentKeys />
	</cffunction>

<!---
parseSegments - both
--->
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