<cfcomponent>
	
<!--- doAirAvailability --->
	<cffunction name="doAirAvailability" returntype="string" output="false">
		<cfargument name="airparse">
		<cfargument name="nSearchID">
		<cfargument name="Group">
		<cfargument name="stAccount" 	default="#application.stAccounts[session.Acct_ID]#">
		<cfargument name="stPolicy" 	default="#application.stPolicies[session.searches[url.Search_ID].Policy_ID]#">
		<cfargument name="sAPIAuth" 	default="#application.sAPIAuth#">
		
		<cfset local.sMessage 			= 	prepareSoapHeader(arguments.stAccount, arguments.stPolicy, arguments.nSearchID, arguments.Group)>
		<cfset local.sResponse 			= 	arguments.airparse.callAPI('AirService', sMessage, arguments.sAPIAuth, arguments.nSearchID)>
		<cfset local.aResponse 			= 	arguments.airparse.formatResponse(sResponse)>
		<cfset local.stSegmentKeys 		= 	arguments.airparse.parseSegmentKeys(aResponse)>
		<cfset stSegmentKeys 			= 	arguments.airparse.addSegmentRefs(aResponse, stSegmentKeys)>
		<cfset local.stSegments 		= 	arguments.airparse.parseSegments(aResponse, stSegmentKeys)>
		<cfset stSegments 				= 	arguments.airparse.mergeSegments(session.searches[nSearchID].stSegments, stSegments)>
		<cfset local.stSegmentKeyLookUp = 	arguments.airparse.parseKeyLookUp(stSegmentKeys)>
		<cfset local.stAvailTrips 		= 	arguments.airparse.parseConnections(aResponse, stSegments, stSegmentKeys, stSegmentKeyLookUp)>
		<cfset local.stAvailTrips 		= 	addPreferred(stAvailTrips, stAccount)>
		<cfset local.stCarriers 		= 	getCarriers(stAvailTrips)>
		
		<cfset session.searches[nSearchID].stSegments = stSegments>
		<cfset session.searches[nSearchID].stAvailTrips = stAvailTrips>
		<cfset session.searches[nSearchID].stCarriers = stCarriers>
		
		<cfset session.searches[nSearchID].stSortSegments = StructKeyArray(session.searches[nSearchID].stAvailTrips)>
		
		<cfreturn >
	</cffunction>

<!--- prepareSoapHeader --->
	<cffunction name="prepareSoapHeader" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="stPolicy" 	required="true">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="Group"	 	required="true">
		
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
		
		<cfsavecontent variable="local.message">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<air:AvailabilitySearchReq TargetBranch="#arguments.stAccount.sBranch#" xmlns:air="http://www.travelport.com/schema/air_v18_0" xmlns:com="http://www.travelport.com/schema/common_v15_0">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
							<cfif arguments.Group EQ 0>
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
							<cfif arguments.Group EQ 1 AND getsearch.Air_Type EQ 'RT'>
								<air:SearchAirLeg>
									<air:SearchOrigin>
										<com:Airport Code="#getsearch.Arrival_City#" />
									</air:SearchOrigin>
									<air:SearchDestination>
										<com:Airport Code="#getsearch.Depart_City#" />
									</air:SearchDestination>
									<air:SearchDepTime PreferredTime="#DateFormat(getsearch.Arrival_DateTime, 'yyyy-mm-dd')#" />
								</air:SearchAirLeg>
							<cfelseif arguments.Group NEQ 0 AND getsearch.Air_Type EQ 'MD'>
								<cfset local.cnt = 0>
								<cfloop query="getsearchlegs">
									<cfset cnt++>
									<cfif arguments.Group EQ cnt>
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
	
<!--- sortSegments --->
	<cffunction name="sortSegments" returntype="array" output="false">
		<cfargument name="stSegments" 	required="true">
		<cfargument name="sField" 	required="true">
				
		<cfreturn StructSort(arguments.stSegments, 'numeric', 'asc', arguments.sField )/>
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