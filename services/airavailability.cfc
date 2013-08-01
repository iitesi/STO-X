<cfcomponent output="false" accessors="true">

	<cfproperty name="UAPI">
	<cfproperty name="uAPISchemas" />
	<cfproperty name="AirParse">

	<cffunction name="init" output="false">
		<cfargument name="UAPI">
    	<cfargument name="uAPISchemas" type="any" required="true" />
		<cfargument name="AirParse">

		<cfset setUAPI(arguments.UAPI)>
    	<cfset setUAPISchemas( arguments.uAPISchemas ) />
		<cfset setAirParse(arguments.AirParse)>

		<cfreturn this>
	</cffunction>

	<cffunction name="selectLeg" output="false">
		<cfargument name="SearchID">
		<cfargument name="Group">
		<cfargument name="nTrip">

		<cfset session.searches[arguments.SearchID].stSelected[arguments.Group] = session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTrip]>

		<cfreturn />
	</cffunction>

	<cffunction name="threadAvailability" output="false">
		<cfargument name="Filter"	required="true">
		<cfargument name="Account"  required="true">
		<cfargument name="Policy"   required="true">
		<cfargument name="Group"	required="false">

		<cfset local.stThreads = {}>
		<cfset local.sThreadName = ''>
		<cfset local.sPriority = ''>

		<!--- Create a thread for every leg.  Give priority to the group specifically selected. --->
		<cfloop collection="#arguments.Filter.getLegs()#" item="local.nLeg">
			<cfif arguments.Group EQ nLeg>
				<cfset local.sPriority = 'HIGH'>
			<cfelse>
				<cfset local.sPriority = 'LOW'>
			</cfif>
			<cfset sThreadName = doAvailability(arguments.Filter, nLeg-1, arguments.Account, arguments.Policy, sPriority)>

			<cfif sPriority EQ 'HIGH' AND sThreadName NEQ ''>
				<cfset stThreads[sThreadName] = ''>
			</cfif>
		</cfloop>

		<!--- Join only if threads where thrown out. --->
		<cfif NOT StructIsEmpty(stThreads)
			AND sPriority EQ 'HIGH'>
			<cfthread action="join" name="#structKeyList(stThreads)#" />
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="doAvailability" output="false">
		<cfargument name="Filter" required="true">
		<cfargument name="Group" required="true">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="sPriority" required="false"	default="HIGH">
		<cfargument name="stGroups" required="false" default="#structNew()#">

		<cfset local.sThreadName = "">

		<!--- Don't go back to the getUAPI if we already got the data. --->
		<cfif NOT StructKeyExists(arguments.stGroups, arguments.Group)>
			<cfset local.sThreadName = 'Group'&arguments.Group>
			<cfset local[local.sThreadName] = {}>

			<!--- Note:  To debug: comment out opening and closing cfthread tags and
			dump sMessage or sResponse to see what uAPI is getting and sending back --->

			<cfthread
				action="run"
				name="#local.sThreadName#"
				priority="#arguments.sPriority#"
				Filter="#arguments.Filter#"
				Group="#arguments.Group#"
				Account="#arguments.Account#"
				Policy="#arguments.Policy#">

 				<cfset attributes.sNextRef = 'ROUNDONE'>
				<cfset attributes.nCount = 0>
				<cfloop condition="attributes.sNextRef NEQ ''">
					<cfset attributes.nCount++>
					<!--- Put together the SOAP message. --->
					<cfset attributes.sMessage = prepareSoapHeader(arguments.Filter, arguments.Group, (attributes.sNextRef NEQ 'ROUNDONE' ? attributes.sNextRef : ''), arguments.Account)>
					<!--- Call the getUAPI. --->
					<cfset attributes.sResponse = getUAPI().callUAPI('AirService', attributes.sMessage, arguments.Filter.getSearchID(), arguments.Filter.getAcctID(), arguments.Filter.getUserID())>

					<!--- Format the getUAPI response. --->
					<cfset attributes.aResponse = getUAPI().formatUAPIRsp(attributes.sResponse)>

					<!--- Create unique segment keys. --->
					<cfset attributes.sNextRef =	getAirParse().parseNextReference(attributes.aResponse)>
					<cfif attributes.nCount GT 3>
						<cfset attributes.sNextRef	= ''>
					</cfif>
					<!--- Create unique segment keys. --->
					<cfset attributes.stSegmentKeys = parseSegmentKeys(attributes.aResponse)>
					<!--- Add in the connection references --->
					<cfset attributes.stSegmentKeys = addSegmentRefs(attributes.aResponse, attributes.stSegmentKeys)>
					<!--- Parse the segments. --->
					<cfset attributes.stSegments = parseSegments(attributes.aResponse, attributes.stSegmentKeys)>
					<!--- Create a look up list opposite of the stSegmentKeys --->
					<cfset attributes.stSegmentKeyLookUp = parseKeyLookUp(attributes.stSegmentKeys)>
					<!--- Parse the trips. --->
					<cfset attributes.stAvailTrips = parseConnections(attributes.aResponse, attributes.stSegments, attributes.stSegmentKeys, attributes.stSegmentKeyLookUp)>
					<!--- Add group node --->
					<cfset attributes.stAvailTrips	= getAirParse().addGroups(attributes.stAvailTrips, 'Avail')>
					<!--- Mark preferred carriers. --->
					<cfset attributes.stAvailTrips = getAirParse().addPreferred(attributes.stAvailTrips, arguments.Account)>
					<!--- Run policy on all the results --->
					<cfset attributes.stAvailTrips	= getAirParse().checkPolicy(attributes.stAvailTrips, arguments.Filter.getSearchID(), '', 'Avail', arguments.Account, arguments.Policy)>
					<!--- Create javascript structure per trip. --->
					<cfset attributes.stAvailTrips	=	getAirParse().addJavascript(attributes.stAvailTrips, 'Avail')>
					<!--- Merge information into the current session structures. --->
					<cfset session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group] = getAirParse().mergeTrips(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], attributes.stAvailTrips)>
				</cfloop>

				<!--- Add list of available carriers per leg --->
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.stCarriers[arguments.Group] = getAirParse().getCarriers(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group])>
				<!--- Add sorting per leg --->
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortDepart[arguments.Group] = StructSort(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], 'numeric', 'asc', 'Depart')>
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortArrival[arguments.Group] = StructSort(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], 'numeric', 'asc', 'Arrival')>
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortDuration[arguments.Group]	= StructSort(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], 'numeric', 'asc', 'Duration')>
				<!--- Mark this leg as priced --->
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.stGroups[arguments.Group] = 1>
			</cfthread>
		</cfif>

		<cfreturn local.sThreadName>
	</cffunction>

	<cffunction name="prepareSoapHeader" access="private" returntype="string" output="false" hint="I prepare the SOAP header.">
		<cfargument name="Filter" required="true">
		<cfargument name="Group" required="true">
		<cfargument name="sNextRef" required="true">
		<cfargument name="Account" required="true">

		<cfif arguments.Filter.getAirType() EQ 'MD'>
			<!--- grab leg query out of filter --->
			<cfset local.qSearchLegs = arguments.filter.getLegs()[1]>
		</cfif>

<!---
****************************************************************************
				ANY CHANGES MADE BELOW PROBABLY NEED TO ALSO BE MADE IN
						   lowfare.cfc   prepareSoapHeader()
****************************************************************************
--->

		<cfsavecontent variable="local.message">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<air:AvailabilitySearchReq TargetBranch="#arguments.Account.sBranch#"
							xmlns:air="#getUAPISchemas().air#"
							xmlns:com="#getUAPISchemas().common#">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
							<cfif arguments.sNextRef NEQ ''>
								<com:NextResultReference>#arguments.sNextRef#</com:NextResultReference>
							</cfif>
							<cfif arguments.Group EQ 0>
								<air:SearchAirLeg>
									<air:SearchOrigin>
										<cfif arguments.filter.getAirFromCityCode() EQ 1>
											<com:City Code="#arguments.Filter.getDepartCity()#" />
										<cfelse>
											<com:Airport Code="#arguments.Filter.getDepartCity()#" />
										</cfif>
									</air:SearchOrigin>
									<air:SearchDestination>
										<cfif arguments.filter.getAirToCityCode() EQ 1>
											<com:City Code="#arguments.Filter.getArrivalCity()#" />
										<cfelse>
											<com:Airport Code="#arguments.Filter.getArrivalCity()#" />
										</cfif>
									</air:SearchDestination>

									<cfif arguments.filter.getDepartDateTimeActual() EQ "Anytime">
										<air:SearchArvTime PreferredTime="#DateFormat(arguments.filter.getDepartDateTime(), 'yyyy-mm-dd')#" />
									<cfelse>
										<cfif arguments.filter.getDepartTimeType() EQ "A">
											<air:SearchArvTime PreferredTime="#DateFormat(arguments.filter.getDepartDateTime(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTime(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#">
												<!--- <com:TimeRange EarliestTime="#DateFormat(arguments.filter.getDepartDateTimeStart(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTimeStart(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" LatestTime="#DateFormat(arguments.filter.getDepartDateTimeEnd(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTimeEnd(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" /> --->
											</air:SearchArvTime>
										<cfelse>
											<air:SearchDepTime PreferredTime="#DateFormat(arguments.filter.getDepartDateTime(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTime(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#">
												<!--- <com:TimeRange EarliestTime="#DateFormat(arguments.filter.getDepartDateTimeStart(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTimeStart(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" LatestTime="#DateFormat(arguments.filter.getDepartDateTimeEnd(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTimeEnd(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" /> --->
											</air:SearchDepTime>
										</cfif>
									</cfif>

									<!---
									<air:AirLegModifiers>
										<cfif NOT arrayIsEmpty(aCabins)>
											<air:PermittedCabins>
												<cfloop array="#aCabins#" index="local.sCabin">
													<air:CabinClass Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
												</cfloop>
											</air:PermittedCabins>
										</cfif>
									</air:AirLegModifiers>
								--->

								</air:SearchAirLeg>
							</cfif>

							<cfif arguments.Group EQ 1 AND arguments.Filter.getAirType() EQ 'RT'>
								<air:SearchAirLeg>
									<air:SearchOrigin>
										<cfif arguments.filter.getAirToCityCode() EQ 1>
											<com:City Code="#arguments.Filter.getArrivalCity()#" />
										<cfelse>
											<com:Airport Code="#arguments.Filter.getArrivalCity()#" />
										</cfif>
									</air:SearchOrigin>
									<air:SearchDestination>
										<cfif arguments.filter.getAirFromCityCode() EQ 1>
											<com:City Code="#arguments.Filter.getDepartCity()#" />
										<cfelse>
											<com:Airport Code="#arguments.Filter.getDepartCity()#" />
										</cfif>
									</air:SearchDestination>
									<cfif arguments.filter.getArrivalDateTimeActual() EQ "Anytime">
										<air:SearchArvTime PreferredTime="#DateFormat(arguments.filter.getArrivalDateTime(), 'yyyy-mm-dd')#" />
									<cfelse>
										<cfif arguments.filter.getDepartTimeType() EQ "A">
											<air:SearchArvTime PreferredTime="#DateFormat(arguments.filter.getArrivalDateTime(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTime(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#">
												<!--- <com:TimeRange EarliestTime="#DateFormat(arguments.filter.getArrivalDateTimeStart(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTimeStart(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" LatestTime="#DateFormat(arguments.filter.getArrivalDateTimeEnd(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTimeEnd(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" /> --->
											</air:SearchArvTime>
										<cfelse>
											<air:SearchDepTime PreferredTime="#DateFormat(arguments.filter.getArrivalDateTime(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTime(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#">
												<!--- <com:TimeRange EarliestTime="#DateFormat(arguments.filter.getArrivalDateTimeStart(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTimeStart(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" LatestTime="#DateFormat(arguments.filter.getArrivalDateTimeEnd(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTimeEnd(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" /> --->
											</air:SearchDepTime>
										</cfif>
									</cfif>
									<!---
									<air:AirLegModifiers>
										<cfif NOT arrayIsEmpty(aCabins)>
											<air:PermittedCabins>
												<cfloop array="#aCabins#" index="local.sCabin">
													<air:CabinClass  Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
												</cfloop>
											</air:PermittedCabins>
										</cfif>
									</air:AirLegModifiers>
								--->
								</air:SearchAirLeg>

							<!--- for multi-city trips loop over SearchesLegs --->
							<cfelseif arguments.Group NEQ 0 AND arguments.Filter.getAirType() EQ 'MD'>
								<cfset local.cnt = 0>
								<cfloop query="local.qSearchLegs">
									<cfset cnt++>
									<cfif arguments.Group EQ cnt>
										<air:SearchAirLeg>
											<air:SearchOrigin>
												<cfif arguments.filter.getAirFromCityCode() EQ 1>
													<com:City Code="#depart_city#" />
												<cfelse>
													<com:Airport Code="#depart_city#" />
												</cfif>
											</air:SearchOrigin>
											<air:SearchDestination>
												<cfif arguments.filter.getAirToCityCode() EQ 1>
													<com:City Code="#arrival_city#" />
												<cfelse>
													<com:Airport Code="#arrival_city#" />
												</cfif>
											</air:SearchDestination>

											<cfif local.qSearchLegs.Depart_DateTimeActual EQ "Anytime">
												<air:SearchArvTime PreferredTime="#DateFormat(local.qSearchLegs.Depart_DateTime, 'yyyy-mm-dd')#" />
											<cfelse>
												<air:SearchDepTime PreferredTime="#DateFormat(local.qSearchLegs.Depart_DateTime, 'yyyy-mm-dd') & 'T' & TimeFormat(local.qSearchLegs.Depart_DateTime, 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#">
													<com:TimeRange EarliestTime="#DateFormat(local.qSearchLegs.Depart_DateTimeStart, 'yyyy-mm-dd') & 'T' & TimeFormat(local.qSearchLegs.Depart_DateTimeStart, 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" LatestTime="#DateFormat(local.qSearchLegs.Depart_DateTimeEnd, 'yyyy-mm-dd') & 'T' & TimeFormat(local.qSearchLegs.Depart_DateTimeEnd, 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" />
												</air:SearchDepTime>
											</cfif>

											<!---
											<air:AirLegModifiers>
												<cfif NOT arrayIsEmpty(aCabins)>
													<air:PermittedCabins>
														<cfloop array="#aCabins#" index="local.sCabin">
															<air:CabinClass  Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
														</cfloop>
													</air:PermittedCabins>
												</cfif>
											</air:AirLegModifiers>
											--->

										</air:SearchAirLeg>
									</cfif>
								</cfloop>
							</cfif>
							<cfif arguments.sNextRef EQ ''>
								<air:AirSearchModifiers
									DistanceType="MI"
									IncludeFlightDetails="false"
									AllowChangeOfAirport="false"
									ProhibitOvernightLayovers="true"
									ProhibitMultiAirportConnection="true"
									PreferNonStop="true">
									<cfif Len(arguments.filter.getAirlines()) EQ 2>
										<air:PermittedCarriers>
											<com:Carrier Code="#arguments.filter.getAirlines()#"/>
										</air:PermittedCarriers>
									<cfelse>
										<air:ProhibitedCarriers>
											<com:Carrier Code="G4"/>
											<com:Carrier Code="NK"/>
											<com:Carrier Code="VX"/>
											<com:Carrier Code="ZK"/>
										</air:ProhibitedCarriers>
									</cfif>
								</air:AirSearchModifiers>
								<com:SearchPassenger Code="ADT" />
								<!---
								<air:AirPricingModifiers ProhibitNonRefundableFares="#bProhibitNonRefundableFares#" FaresIndicator="PublicAndPrivateFares" ProhibitMinStayFares="false" ProhibitMaxStayFares="false" CurrencyType="USD" ProhibitAdvancePurchaseFares="false" ProhibitRestrictedFares="false" ETicketability="Required" ProhibitNonExchangeableFares="false" ForceSegmentSelect="false">
								</air:AirPricingModifiers>
								--->
								<com:PointOfSale ProviderCode="1V" PseudoCityCode="1M98" />
							</cfif>
						</air:AvailabilitySearchReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>

		<cfreturn message/>
	</cffunction>

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
						HashIndex	: 	getUAPI().HashNumeric(sIndex),
						Index		: 	sIndex
					}>
				</cfloop>
			</cfif>
		</cfloop>

		<cfreturn stSegmentKeys />
	</cffunction>

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

	<cffunction name="parseKeyLookup" output="false">
		<cfargument name="stSegmentKeys">

		<cfset local.stSegmentKeyLookUp = {}>
		<cfloop collection="#arguments.stSegmentKeys#" item="local.sKey">
			<cfset stSegmentKeyLookUp[stSegmentKeys[sKey].nLocation] = sKey>
		</cfloop>

		<cfreturn stSegmentKeyLookUp />
	</cffunction>

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
			<cfset nHashNumeric = getUAPI().hashNumeric(sIndex)>
			<cfset stTrips[nHashNumeric].Segments = stSegmentIndex[nIndex]>
			<cfset stTrips[nHashNumeric].Class = 'X'>
			<cfset stTrips[nHashNumeric].Ref = 'X'>
		</cfloop>

		<cfreturn stTrips />
	</cffunction>

</cfcomponent>