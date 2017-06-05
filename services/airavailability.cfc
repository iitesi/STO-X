<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="UAPIFactory">
	<cfproperty name="uAPISchemas" />
	<cfproperty name="AirParse">

	<cffunction name="init" output="false">
		<cfargument name="UAPIFactory">
		<cfargument name="uAPISchemas" type="any" required="true" />
		<cfargument name="AirParse">

		<cfset setUAPIFactory(arguments.UAPIFactory)>
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
		<cfargument name="Filter" required="true">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="Group" required="false">
		<cfargument name="sCabins" required="false">
		<cfargument name="reQuery" default="false">
		<cfset local.stThreads = {}>
		<cfset local.sThreadName = ''>
		<cfset local.sPriority = ''>
		<cfset local.stTrips = {}>
		<cfif IsNumeric(arguments.Group)>
			<cfif arguments.reQuery OR !StructKeyExists(session.searches[arguments.Filter.getSearchID()],'stAvailTrips')
						OR (StructKeyExists(session.searches[arguments.Filter.getSearchID()],'stAvailTrips') AND !StructKeyExists(session.searches[arguments.Filter.getSearchID()].stAvailTrips,arguments.Group))
						OR (StructKeyExists(session.searches[arguments.Filter.getSearchID()].stAvailTrips,arguments.Group) AND !StructCount(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group]))>

				<!--- Create a thread for every leg. Give priority to the group specifically selected. --->
				<cfif arguments.Filter.getClassOfService() EQ ''>
					<cfset local.aCabins = ['X']>
				<cfelseif Len(arguments.sCabins)>
					<!--- if find more class is clicked from filter bar - arguments.sCabins (from rc.cabins) will exist --->
					<cfset local.aCabins = [arguments.sCabins]>
				<cfelse>
					<!--- otherwise get the class/cabin passed from the widget --->
					<cfset local.aCabins = [arguments.Filter.getClassOfService()]>
				</cfif>

				<cfset local.stTrips = doAvailability( Filter = arguments.Filter
													, Group = arguments.Group
													, Account = arguments.Account
													, Policy = arguments.Policy
													, sPriority = 'HIGH'
													, sCabins = local.aCabins)>
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group] = getAirParse().mergeTrips(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], local.stTrips)>
				<!--- Add list of available carriers per leg --->
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.stCarriers[arguments.Group] = getAirParse().getCarriers(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group])>
				<!--- Add sorting per leg --->
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortDepart[arguments.Group] = StructSort(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], 'numeric', 'asc', 'Depart')>
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortArrival[arguments.Group] = StructSort(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], 'numeric', 'asc', 'Arrival')>
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortDuration[arguments.Group]	= StructSort(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], 'numeric', 'asc', 'Duration')>
				<!--- Sorting with preferred departure or arrival time taken into account --->
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortDepartPreferred[arguments.Group] = sortByPreferredTime("aSortDepart", arguments.Filter.getSearchID(), arguments.Group, arguments.Filter) />
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortArrivalPreferred[arguments.Group] = sortByPreferredTime("aSortArrival", arguments.Filter.getSearchID(), arguments.Group, arguments.Filter) />
				<!--- Mark this leg as priced --->
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.stGroups[arguments.Group] = 1>
			</cfif>
		</cfif>
		<cfreturn />
	</cffunction>

	<cffunction name="doAvailability" output="false">
		<cfargument name="Filter" required="true">
		<cfargument name="Group" required="true">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="sPriority" required="false"	default="HIGH">
		<cfargument name="sCabins" default="">

		<cfset local = {}>
		<cfset local.sThreadName = "">

		<!--- Checking to see if a carrier, if selected, has any blacklisted pairings --->
		<cfset local.blackListedCarrierPairing = application.blackListedCarrierPairing />
		<cfset local.selectedCarriers = "" />
		<cfset local.blackListedCarriers = "" />

		<cfif structKeyExists(session.searches, arguments.Filter.getSearchID()) AND structKeyExists(session.searches[arguments.Filter.getSearchID()], "stSelected")>
			<cfloop collection="#session.searches[arguments.Filter.getSearchID()].stSelected#" item="local.group" index="local.groupIndex">
				<cfif isStruct(local.group) AND NOT structIsEmpty(local.group) AND structKeyExists(local.group, "platingCarrier")>
					<cfset local.selectedCarriers = listAppend(local.selectedCarriers, local.group.platingCarrier) />
				</cfif>
			</cfloop>

			<cfloop list="#local.selectedCarriers#" index="local.carrier">
				<cfloop collection="#local.blackListedCarrierPairing#" item="local.pairing" index="local.pairingIndex">
					<cfif listFindNoCase(local.selectedCarriers, local.pairing[1])>
						<cfset local.blackListedCarriers = listAppend(local.blackListedCarriers, local.pairing[2]) />
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
		<cfscript>
  	local.sThreadName = 'Group'&arguments.Group;
		local = {};
		local.name="#local.sThreadName#";
		local.priority="#arguments.sPriority#";
		local.Filter="#arguments.Filter#";
		local.Group="#arguments.Group#";
		local.Account="#arguments.Account#";
		local.Policy="#arguments.Policy#";

		local.sNextRef = 'ROUNDONE';
		local.nCount = 0;
		local.stTrips = {};

		</cfscript>
		<cfloop condition="local.sNextRef NEQ ''">
			<cfset local.tempTrips = {}>
			<cfset local.nCount++>
			<!--- Put together the SOAP message. --->
			<cfset local.sMessage = prepareSoapHeader(arguments.Filter, arguments.Group, (local.sNextRef NEQ 'ROUNDONE' ? local.sNextRef : ''), arguments.Account, arguments.sCabins)>
			<!--- Call the getUAPI. --->
			<cfset local.sResponse = getUAPI().callUAPI('AirService', local.sMessage, arguments.Filter.getSearchID(), arguments.Filter.getAcctID(), arguments.Filter.getUserID())>
			<!--- Format the getUAPI response. --->
			<cfset local.aResponse = getUAPI().formatUAPIRsp(local.sResponse)>
			<!--- Create unique segment keys. --->
			<cfset local.sNextRef =	getAirParse().parseNextReference(local.aResponse)>
			<cfif local.nCount GT 25> <!---This number was 3 and I found increasing this brought back more results in availability.--->
				<cfset local.sNextRef	= ''>
			</cfif>


			<!--- Create unique segment keys. --->
			<cfset local.stSegmentKeys = parseSegmentKeys(local.aResponse)>
			<!--- Parse the segments. --->
			<cfset local.stSegments = parseSegments(local.aResponse, local.stSegmentKeys)>
			<!--- Create a look up list opposite of the stSegmentKeys --->
			<!---<cfset local.stSegmentKeyLookUp = parseKeyLookUp(local.stSegmentKeys)>--->
			<cfset local.stSegmentKeyLookUp = parseKeyLookUp(local.aResponse,local.stSegmentKeys)>
			<!--- Parse the trips. --->
			<cfset local.tempTrips = parseConnections(local.aResponse, local.stSegments, local.stSegmentKeys, local.stSegmentKeyLookUp, arguments.filter, arguments.group,arraylen(StructKeyArray( local.stTrips )) + 1)>

			<!--- Add group node --->
			<cfset local.tempTrips	= getAirParse().addGroups(local.tempTrips, 'Avail', arguments.Filter)>

			<!--- STM-7375 check--->
			<cfset local.tempTrips = getAirParse().removeInvalidTrips(trips=local.tempTrips, filter=arguments.Filter, tripTypeOverride='OW',chosenGroup=arguments.group)>
			<!--- Mark preferred carriers. --->
			<cfset local.tempTrips = getAirParse().addPreferred(local.tempTrips, arguments.Account)>
			<!--- Run policy on all the results --->
			<cfset local.tempTrips	= getAirParse().checkPolicy(local.tempTrips, arguments.Filter.getSearchID(), '', 'Avail', arguments.Account, arguments.Policy)>
			<!--- Create javascript structure per trip. --->
			<cfset local.tempTrips	=	getAirParse().addJavascript(local.tempTrips, 'Avail')>
			<!--- Merge information into the current session structures. --->
			<cfset local.stTrips = getAirParse().mergeTrips(local.stTrips, local.tempTrips)>
		</cfloop>
		<!--- Remove all blackListed carriers that may have been added during this and previous calls --->
		<cfset local.stTrips = getAirParse().removeBlackListedCarriers(local.stTrips, local.BlackListedCarriers)>
		<cfreturn local.stTrips>
	</cffunction>

	<cffunction name="prepareSoapHeader" access="private" returntype="string" output="false" hint="I prepare the SOAP header.">
		<cfargument name="Filter" required="true">
		<cfargument name="Group" required="true">
		<cfargument name="sNextRef" required="true">
		<cfargument name="Account" required="true">
		<cfargument name="sCabins" required="false" default="">

		<cfif arguments.Filter.getAirType() EQ 'MD'>
			<!--- grab leg query out of filter --->
			<cfset local.qSearchLegs = arguments.filter.getLegs()[1]>
		</cfif>

		<!--- Code needs to be reworked and put in a better location --->
		<cfset local.targetBranch = arguments.Account.sBranch>
		<cfif arguments.Filter.getAcctID() EQ 254
			OR arguments.Filter.getAcctID() EQ 255>
			<cfset local.targetBranch = 'P1601396'>
		</cfif>
		<cfif IsArray(arguments.sCabins)>
			 <cfset local.aCabins = arguments.sCabins>
		<cfelseif ListLen(arguments.sCabins) GT 0>
			 <cfset local.aCabins = ListToArray(arguments.sCabins)>
		<cfelse>
			 <cfset local.aCabins = ArrayNew(1)>
		</cfif>
<!---
****************************************************************************
				ANY CHANGES MADE BELOW PROBABLY NEED TO ALSO BE MADE IN
					lowfare.cfc prepareSoapHeader()
****************************************************************************
--->

		<cfsavecontent variable="local.message">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<air:AvailabilitySearchReq TargetBranch="#local.targetBranch#"
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
										<air:SearchDepTime PreferredTime="#DateFormat(arguments.filter.getDepartDateTime(), 'yyyy-mm-dd')#" />
									<cfelse>
										<cfif arguments.filter.getDepartTimeType() EQ "A">
											<air:SearchArvTime PreferredTime="#DateFormat(arguments.filter.getDepartDateTime(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTime(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#">
												<com:TimeRange EarliestTime="#DateFormat(arguments.filter.getDepartDateTimeStart(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTimeStart(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" LatestTime="#DateFormat(arguments.filter.getDepartDateTimeEnd(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTimeEnd(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" />
											</air:SearchArvTime>
										<cfelse>
											<air:SearchDepTime PreferredTime="#DateFormat(arguments.filter.getDepartDateTime(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTime(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#">
												<com:TimeRange EarliestTime="#DateFormat(arguments.filter.getDepartDateTimeStart(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTimeStart(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" LatestTime="#DateFormat(arguments.filter.getDepartDateTimeEnd(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTimeEnd(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" />
											</air:SearchDepTime>
										</cfif>
									</cfif>
									<air:AirLegModifiers>
										<cfif NOT arrayIsEmpty(aCabins)>
											<air:PermittedCabins>
												<cfloop array="#aCabins#" index="local.sCabin">
													<com:CabinClass Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
												</cfloop>
											</air:PermittedCabins>
										</cfif>
									</air:AirLegModifiers>
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
										<air:SearchDepTime PreferredTime="#DateFormat(arguments.filter.getArrivalDateTime(), 'yyyy-mm-dd')#" />
									<cfelse>
										<cfif arguments.filter.getDepartTimeType() EQ "A">
											<air:SearchArvTime PreferredTime="#DateFormat(arguments.filter.getArrivalDateTime(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTime(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#">
												<com:TimeRange EarliestTime="#DateFormat(arguments.filter.getArrivalDateTimeStart(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTimeStart(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" LatestTime="#DateFormat(arguments.filter.getArrivalDateTimeEnd(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTimeEnd(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" />
											</air:SearchArvTime>
										<cfelse>
											<air:SearchDepTime PreferredTime="#DateFormat(arguments.filter.getArrivalDateTime(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTime(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#">
												<com:TimeRange EarliestTime="#DateFormat(arguments.filter.getArrivalDateTimeStart(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTimeStart(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" LatestTime="#DateFormat(arguments.filter.getArrivalDateTimeEnd(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTimeEnd(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" />
											</air:SearchDepTime>
										</cfif>
									</cfif>
									<air:AirLegModifiers>
										<cfif NOT arrayIsEmpty(aCabins)>
											<air:PermittedCabins>
												<cfloop array="#aCabins#" index="local.sCabin">
													<com:CabinClass Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
												</cfloop>
											</air:PermittedCabins>
										</cfif>
									</air:AirLegModifiers>
								</air:SearchAirLeg>

							<!--- for multi-city trips loop over SearchesLegs --->
							<cfelseif arguments.Group NEQ 0
								AND arguments.Filter.getAirType() EQ 'MD'>
								<cfset local.cnt = 0>
								<cfloop query="local.qSearchLegs">
									<cfset cnt++>
									<cfif arguments.Group+1 EQ cnt>
										<air:SearchAirLeg>
											<air:SearchOrigin>
												<cfif airFrom_CityCode EQ 1>
													<com:City Code="#depart_city#" />
												<cfelse>
													<com:Airport Code="#depart_city#" />
												</cfif>
											</air:SearchOrigin>
											<air:SearchDestination>
												<cfif airTo_CityCode EQ 1>
													<com:City Code="#arrival_city#" />
												<cfelse>
													<com:Airport Code="#arrival_city#" />
												</cfif>
											</air:SearchDestination>

											<cfif local.qSearchLegs.Depart_DateTimeActual EQ "Anytime">
												<air:SearchDepTime PreferredTime="#DateFormat(local.qSearchLegs.Depart_DateTime, 'yyyy-mm-dd')#" />
											<cfelse>
												<air:SearchDepTime PreferredTime="#DateFormat(local.qSearchLegs.Depart_DateTime, 'yyyy-mm-dd') & 'T' & TimeFormat(local.qSearchLegs.Depart_DateTime, 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#">
													<com:TimeRange EarliestTime="#DateFormat(local.qSearchLegs.Depart_DateTimeStart, 'yyyy-mm-dd') & 'T' & TimeFormat(local.qSearchLegs.Depart_DateTimeStart, 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" LatestTime="#DateFormat(local.qSearchLegs.Depart_DateTimeEnd, 'yyyy-mm-dd') & 'T' & TimeFormat(local.qSearchLegs.Depart_DateTimeEnd, 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" />
												</air:SearchDepTime>
											</cfif>
											<air:AirLegModifiers>
												<cfif NOT arrayIsEmpty(aCabins)>
													<air:PermittedCabins>
														<cfloop array="#aCabins#" index="local.sCabin">
															<com:CabinClass Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
														</cfloop>
													</air:PermittedCabins>
												</cfif>
											</air:AirLegModifiers>
										</air:SearchAirLeg>
									</cfif>
								</cfloop>
							</cfif>

<!--- MaxSolutions="1" --->

							<cfif arguments.sNextRef EQ ''>
								<air:AirSearchModifiers
									DistanceType="MI"
									IncludeFlightDetails="false"
									AllowChangeOfAirport="false"
									ProhibitOvernightLayovers="true"
									<cfif arguments.filter.getIsDomesticTrip() IS "true">
										MaxConnectionTime="300"
									</cfif>
									ProhibitMultiAirportConnection="true"
									PreferNonStop="true">
									<cfif Len(arguments.filter.getAirlines()) EQ 2>
										<air:PermittedCarriers>
											<com:Carrier Code="#arguments.filter.getAirlines()#"/>
										</air:PermittedCarriers>
									<cfelse>
										<!--- blacklisted carriers --->
										<air:ProhibitedCarriers>
											<com:Carrier Code="3M"/>
											<com:Carrier Code="DE"/>
											<com:Carrier Code="DN"/>
											<com:Carrier Code="G4"/>
											<com:Carrier Code="JU"/>
											<com:Carrier Code="NK"/>
											<com:Carrier Code="ZK"/>
										</air:ProhibitedCarriers>
									</cfif>
								</air:AirSearchModifiers>
								<com:SearchPassenger Code="ADT" />
								<!---
								<air:AirPricingModifiers ProhibitNonRefundableFares="#bProhibitNonRefundableFares#" FaresIndicator="PublicAndPrivateFares" ProhibitMinStayFares="false" ProhibitMaxStayFares="false" CurrencyType="USD" ProhibitAdvancePurchaseFares="false" ProhibitRestrictedFares="false" ETicketability="Required" ProhibitNonExchangeableFares="false" ForceSegmentSelect="false">
								</air:AirPricingModifiers>
								--->
								<!--- <com:PointOfSale ProviderCode="1V" PseudoCityCode="1M98" /> --->
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
			<cfif local.stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<!--- Build up the distinct segment string. --->
					<cfset local.sIndex = ''>
					<cfloop array="#aSegmentKeys#" index="local.sCol">
						<cfset local.sIndex &= local.stAirSegment.XMLAttributes[local.sCol]>
					</cfloop>
					<!--- Create a look up structure for the primary key. --->
					<cfset local.tempKey = getUAPI().HashNumeric(local.stAirSegment.XMLAttributes.Key)>
					<cfset local.stSegmentKeys[tempKey] = {
						HashIndex	: 	getUAPI().HashNumeric(local.sIndex),
						Index		: 	local.sIndex
					}>
				</cfloop>
			</cfif>
		</cfloop>
		<cfreturn local.stSegmentKeys />
	</cffunction>

	<cffunction name="addSegmentRefs" output="false">
		<cfargument name="stResponse">
		<cfargument name="stSegmentKeys">

		<cfset local.sAPIKey = ''>
		<cfset local.cnt = 0>
		<cfloop array="#arguments.stResponse#" index="local.stAirItinerarySolution">
			<cfif local.stAirItinerarySolution.XMLName EQ 'air:AirItinerarySolution'>
				<cfloop array="#stAirItinerarySolution.XMLChildren#" index="local.stAirSegmentRef">
					<cfif local.stAirSegmentRef.XMLName EQ 'air:AirSegmentRef'>
						<cfset local.sAPIKey = local.stAirSegmentRef.XMLAttributes.Key>
						<cfset local.tempKey = getUAPI().HashNumeric(local.sAPIKey)>
						<cfset arguments.stSegmentKeys[local.tempKey].nLocation = local.cnt>
						<cfset local.cnt++>
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
			<cfset local.stSegmentKeyLookUp[arguments.stSegmentKeys[local.sKey].nLocation] = local.sKey>
		</cfloop>

		<cfreturn local.stSegmentKeyLookUp />
	</cffunction>

	<cffunction name="parseSegments" output="false">
		<cfargument name="stResponse"		required="true">
		<cfargument name="stSegmentKeys"	required="true">

		<cfset local.stSegments = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<cfif local.stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#local.stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<cfset local.cabinClass = findCabinClassFromBookingInfo(local.stAirSegment)>
					<cfset local.dArrivalGMT = local.stAirSegment.XMLAttributes.ArrivalTime>
					<cfset local.dArrivalTime = GetToken(local.dArrivalGMT, 1, '.')>
					<cfset local.dArrivalOffset = GetToken(GetToken(local.dArrivalGMT, 2, '-'), 1, ':')>
					<cfset local.dDepartGMT = local.stAirSegment.XMLAttributes.DepartureTime>
					<cfset local.dDepartTime = GetToken(local.dDepartGMT, 1, '.')>
					<cfset local.dDepartOffset = GetToken(GetToken(local.dDepartGMT, 2, '-'), 1, ':')>
					<cfset local.tempKey = getUAPI().HashNumeric(local.stAirSegment.XMLAttributes.Key)>
					<cfset local.stSegments[arguments.stSegmentKeys[tempKey].HashIndex] = {
						Arrival					: local.dArrivalGMT,
						ArrivalTime			: ParseDateTime(local.dArrivalTime),
						ArrivalGMT			: ParseDateTime(DateAdd('h', local.dArrivalOffset, local.dArrivalTime)),
						Carrier 				: local.stAirSegment.XMLAttributes.Carrier,
						ChangeOfPlane		: local.stAirSegment.XMLAttributes.ChangeOfPlane EQ 'true',
						Departure				: local.dDepartGMT,
						DepartureTime		: ParseDateTime(local.dDepartTime),
						DepartureGMT		: ParseDateTime(DateAdd('h', local.dDepartOffset, local.dDepartTime)),
						Destination			: local.stAirSegment.XMLAttributes.Destination,
						Equipment				: local.stAirSegment.XMLAttributes.Equipment,
						FlightNumber		: local.stAirSegment.XMLAttributes.FlightNumber,
						FlightTime			: local.stAirSegment.XMLAttributes.FlightTime,
						Group						: local.stAirSegment.XMLAttributes.Group,
						Origin					: local.stAirSegment.XMLAttributes.Origin,
						TravelTime			: local.stAirSegment.XMLAttributes.TravelTime,
						CabinClass		  : local.cabinClass
					}>
				</cfloop>
			</cfif>
		</cfloop>
		<cfreturn local.stSegments />
	</cffunction>

	<cffunction name="findCabinClassFromBookingInfo">
		<cfargument name="segment" required="true"/>
		<cfloop array="#arguments.segment.XMLChildren#" index="local.xmlChild">
			<cfif local.xmlChild.XMLName EQ 'air:AirAvailInfo'>
				<cfloop array="#local.xmlChild.XMLChildren#" index="local.xmlChild2">
						<cfif local.xmlChild2.XMLName EQ 'air:BookingCodeInfo'>
							<cftry>
								<cfreturn local.xmlChild2.XMLAttributes.CabinClass />
								<cfcatch type="any">
									<cfreturn 'Unavail' />
								</cfcatch>
							</cftry>
						</cfif>
					</cfloop>
				</cfif>
		</cfloop>
		<cfreturn 'Unavail'/>
	</cffunction>

	<cffunction name="parseConnections" output="false">
		<cfargument name="stResponse">
		<cfargument name="stSegments">
		<cfargument name="stSegmentKeys">
		<cfargument name="stSegmentKeyLookUp">
		<cfargument name="filter">
		<cfargument name="group">
<!--- <cfdump var="#arguments#" abort/> --->
		<!--- Create a structure to hold FIRST connection points --->
		<cfset local.stSegmentIndex = {}>
		<cfset local.firstSegmentIndex = ''>
		<cfloop array="#arguments.stResponse#" index="local.stAirItinerarySolution">
			<cfif local.stAirItinerarySolution.XMLName EQ 'air:AirItinerarySolution'>
				<cfloop array="#local.stAirItinerarySolution.XMLChildren#" index="local.stConnection">
					<cfif local.stConnection.XMLName EQ 'air:Connection'>
						<cfif local.firstSegmentIndex EQ ''>
							<cfset local.firstSegmentIndex = local.stConnection.XMLAttributes.SegmentIndex>
						</cfif>
						<cftry>
							<cfset local.stSegmentIndex["#local.stConnection.XMLAttributes.SegmentIndex#"] = StructNew('linked')>
							<cfset local.stSegKeyLookup = arguments.stSegmentKeyLookUp["#local.stConnection.XMLAttributes.SegmentIndex#"]>
							<cfset local.stSegKeyHash = arguments.stSegmentKeys["#local.stSegKeyLookup#"].HashIndex>
							<cfset local.stSegmentIndex["#local.stConnection.XMLAttributes.SegmentIndex#"][1] = arguments.stSegments["#local.stSegKeyHash#"]>
						<cfcatch type="any"></cfcatch>
					 </cftry>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		<cfif local.firstSegmentIndex EQ ''>
			<cfset local.firstSegmentIndex = arrayLen(structKeyArray(arguments.stSegmentKeyLookUp))-1>
		</cfif>

		<!--- Backfill with nonstops --->
		<cfloop from="0" to="#local.firstSegmentIndex-1#" index="local.segmentIndex">
			<cftry>
				<cfset local.stSegmentIndex[ "#local.segmentIndex#" ] = StructNew('linked')>
				<cfset local.stSegKeyLookupNS = arguments.stSegmentKeyLookUp["#local.segmentIndex#"]>
				<cfset local.stSegKeyHashNS = arguments.stSegmentKeys["#local.stSegKeyLookupNS#"].HashIndex>
				<cfset local.stSegmentIndex[ "#local.segmentIndex#" ][1] = arguments.stSegments["#local.stSegKeyHashNS#"]>
			<cfcatch type="any"></cfcatch>
			</cftry>
		</cfloop>

		<!--- Add to that structure the missing connection points --->
		<cfset local.stTrips = {}>
		<cfset local.nCount = 0>
		<cfset local.nSegNum = 1>
		<cfset local.nMaxCount = arrayLen(structKeyArray(arguments.stSegmentKeys))>
		<cfloop collection="#local.stSegmentIndex#" item="local.nIndex">
			<cfset local.nCount = local.nIndex>
			<cfset local.nSegNum = 1>
			<cfloop condition="NOT StructKeyExists(local.stSegmentIndex, local.nCount+1) AND local.nCount LT nMaxCount AND StructKeyExists(arguments.stSegmentKeyLookUp, local.nCount+1)">
				<cfset local.nSegNum++>
				<cfset local.stSegmentIndex[local.nIndex][local.nSegNum] = arguments.stSegments[arguments.stSegmentKeys[arguments.stSegmentKeyLookUp[local.nCount+1]].HashIndex]>
				<cfset local.nCount++>
			</cfloop>
		</cfloop>

		<!--- Create an appropriate trip key --->
		<cfset local.stTrips = {}>
		<cfset local.sIndex = ''>
		<cfset local.aCarriers = {}>
		<cfset local.nHashNumeric = ''>
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<cfloop collection="#local.stSegmentIndex#" item="local.nIndex">
			<cfloop collection="#local.stSegmentIndex[local.nIndex]#" item="local.sSegment">
				<cfset local.sIndex = ''>
				<cfloop array="#aSegmentKeys#" index="local.stSegment">
					<cfset local.sIndex &= local.stSegmentIndex[local.nIndex][sSegment][local.stSegment]>
				</cfloop>
			</cfloop>
			<cfset local.nHashNumeric = getUAPI().hashNumeric(local.sIndex)>
			<cfset local.stTrips[nHashNumeric].Segments = local.stSegmentIndex[local.nIndex]>
			<cfset local.stTrips[nHashNumeric].Class = 'X'>
			<cfset local.stTrips[nHashNumeric].Ref = 'X'>
		</cfloop>

		<!--- STM-2254 Hack
		5:31 PM Friday, October 04, 2013 - Jim Priest - jpriest@shortstravel.com
		junk code to remove flights not matching original arrival/departure

		Also see below for methods relating to city codes included in this hack


			<!--- get selected origin/destination from the filter --->
			<cfset local.original.departure = Left(arguments.filter.getLegsForTrip()[arguments.group+1], 3)>
			<cfset local.original.arrival = Mid(arguments.filter.getLegsForTrip()[arguments.group+1], 7, 3)>

			<!--- now check those first to see if they are a city code, if so get the related airport codes --->
			<cfset local.toCheck.departure = listToArray(local.original.departure)>
			<cfif IsCityCode(local.original.departure)>
				<cfset local.toCheck.departure = getCityCodeAirportCodes(local.original.departure)>
			</cfif>

			<cfset local.toCheck.arrival = listToArray(local.original.arrival)>
			<cfif IsCityCode(local.original.arrival)>
				<cfset local.toCheck.arrival = getCityCodeAirportCodes(local.original.arrival)>
			</cfif>

			<cfset local.badList = "">--->

			<!--- loop over stTrips and compare chosen origin/destination against the airport codes returned from the uAPI --->
			<!--- <cfloop collection="#local.stTrips#" index="local.tripIndex" item="local.tripItem">
				<cfset local.origin = ''>
				<cfset local.destination = ''>
				<cfloop collection="#local.tripItem.segments#" index="local.segmentIndex" item="local.segment">
					<cfif local.origin EQ ''>
						<cfset local.origin = local.segment.origin>
					</cfif>
					<cfset local.destination = local.segment.destination>
				</cfloop>

				<cfif NOT arrayFindNoCase(local.toCheck.arrival, local.destination)
						OR NOT arrayFindNoCase(local.toCheck.departure, local.origin)>
					<cfset local.badList = listAppend(local.badList, local.tripIndex)>
				</cfif>
			</cfloop>

			delete the trips containing bad origin/destination cities from stTrips
			<cfloop list="#local.badList#" index="local.badListIndex" item="local.badListItem">
				<cfset structDelete(local.stTrips, local.badListItem)>
			</cfloop>--->

		<!--- // end of STM-2254 hack --->

		<cfreturn local.stTrips />
	</cffunction>


	<cffunction name="sortByPreferredTime" output="false" hint="I take the depart/arrival sorts and weight the legs closest to requested departure or arrival time.">
		<cfargument name="StructToSort" required="true" />
		<cfargument name="SearchID" required="true" />
		<cfargument name="Group" required="true" />
		<cfargument name="Filter" required="true" />

		<cfset local.aSortArray = "session.searches[" & arguments.SearchID & "].stAvailDetails." & arguments.StructToSort & "[" & arguments.Group & "]" />

		<!--- TODO: Get MD working. --->
		<!--- Note: legs start with 1, groups start with 0 --->
		<cfif arguments.Filter.getAirType() IS "MD">
			<cfset local.nLeg = arguments.Group + 1 />
			<cfset local.preferredDepartTime = arguments.Filter.getLegs()[1].Depart_DateTime[local.nLeg] />
			<cfset local.preferredDepartTimeType = arguments.Filter.getLegs()[1].Depart_TimeType[local.nLeg] />
		<cfelse>
			<cfset local.preferredDepartTime = arguments.Filter.getDepartDateTime() />
			<cfset local.preferredDepartTimeType = arguments.Filter.getDepartTimeType() />
		</cfif>

		<cfif arguments.Filter.getAirType() IS "RT">
			<cfset local.preferredArrivalTime = arguments.Filter.getArrivalDateTime() />
			<cfset local.preferredArrivalTimeType = arguments.Filter.getArrivalTimeType() />
		<cfelse>
			<cfset local.preferredArrivalTime = "" />
			<cfset local.preferredArrivalTimeType = "" />
		</cfif>

		<cfset local.aPreferredSort = [] />
		<cfset local.sortQuery = QueryNew("nTripKey, departDiff, arrivalDiff", "varchar, numeric, numeric") />
		<cfset local.newRow = QueryAddRow(sortQuery, arrayLen(Evaluate(local.aSortArray))) />
		<cfset local.queryCounter = 1 />

		<cfloop array="#evaluate(local.aSortArray)#" index="local.nTripKey">
			<cfset local.stTrip = session.searches[arguments.SearchID].stAvailTrips[arguments.Group][local.nTripKey] />

			<cfif arguments.Filter.getDepartTimeType() IS 'A'>
				<cfset local.departDateDiff = abs(dateDiff("n", local.preferredDepartTime, local.stTrip.arrival)) />
			<cfelse>
				<cfset local.departDateDiff = abs(dateDiff("n", local.preferredDepartTime, local.stTrip.depart)) />
			</cfif>
			<cfif arguments.Filter.getAirType() IS "RT">
				<cfif arguments.Filter.getArrivalTimeType() IS 'A'>
					<cfset local.arrivalDateDiff = abs(dateDiff("n", local.preferredArrivalTime, local.stTrip.arrival)) />
				<cfelse>
					<cfset local.arrivalDateDiff = abs(dateDiff("n", local.preferredArrivalTime, local.stTrip.depart)) />
				</cfif>
			<cfelse>
				<cfset local.arrivalDateDiff = 0 />
			</cfif>

			<cfset local.temp = querySetCell(local.sortQuery, "nTripKey", local.nTripKey, local.queryCounter) />
			<cfset local.temp = querySetCell(local.sortQuery, "departDiff", local.departDateDiff, local.queryCounter) />
			<cfset local.temp = querySetCell(local.sortQuery, "arrivalDiff", local.arrivalDateDiff, local.queryCounter) />
			<cfset local.queryCounter++ />
		</cfloop>

		<cfquery name="local.preferredSort" dbtype="query">
			SELECT nTripKey, departDiff, arrivalDiff
			FROM sortQuery
			<cfif (arguments.Filter.getAirType() IS "RT") AND (arguments.Group EQ 1)>
				ORDER BY arrivalDiff
			<cfelse>
				ORDER BY departDiff
			</cfif>
		</cfquery>

		<cfif local.preferredSort.recordCount>
			<cfset local.aPreferredSort = listToArray(valueList(local.preferredSort.nTripKey)) />
		</cfif>

		<cfreturn local.aPreferredSort />
	</cffunction>

	<!---
	Throw away code - STM-2254
	4:54 PM Friday, October 04, 2013 - Jim Priest - jpriest@shortstravel.com
	 --->

	<cffunction name="isCityCode" output="false" hint="I take a code and check if it's a city code or a normal airport code.">
		<cfargument name="CityCode" required="true" />
		<cfset local.cityCodeList = "BER,BJS,BUE,BUH,CHI,DTT,LON,MIL,MOW,NYC,OSA,PAR,ROM,SAO,SEL,SPK,STO,TYO,WAS,YEA,YMQ,YTO">
		<cfset local.isCityCode = false>
		<cfif listFindNoCase(local.cityCodeList, arguments.cityCode)>
			<cfset local.isCityCode = true>
		</cfif>
		<cfreturn local.isCityCode>
	</cffunction>

	<cffunction name="getCityCodeAirportCodes" output="false" hint="This is throw away code to check bad flights for city codes and to return a list of associated airport codes that should not be filtered.">
		<cfargument name="CityCodeToCheck" required="true" />

		<!--- build stuct of cityCodes --->
		<cfset local.cityCode = {}>
		<cfset local.cityCodeList = "BER|TXL,SXF,THF;BJS|PEK,NAY;BUE|EZE,AEP;BUH|OTP,BBU;CHI|ORD,MDW;DTT|DTT,DTW,DET;LON|LGW,LHR;MIL|MXP,LIN;MOW|SVO,DME,VKO,PUW,BKA;NYC|JFK,EWR,LGA;OSA|KIX,ITM;PAR|CDG, ORY;ROM|FCO,CIA;SAO|GRU,CGH,VCP;SEL|ICN,GMP;SPK|CTS,OKD;STO|ARN,NYO,BMA,VST;TYO|NRT,HND;WAS|IAD,DCA,BWI;YEA|YEG,YXD;YMQ|YUL,YMY,YMX;YTO|YYZ,YTZ">

		<cfloop list="#local.cityCodeList#" delimiters=";" index="local.cityCodeListIndex" item="local.cityCodeListItem">
			<cfset local.cityCode[ListFirst(local.cityCodeListItem, '|')] = []>
			<cfset local.TempCityList = ListLast(local.cityCodeListItem, '|')>
			<cfloop list="#local.TempCityList#" index="local.tempCityListIndex" item="local.tempCityListItem">
					<cfset local.cityCode[ListFirst(local.cityCodeListItem, '|')][local.tempCityListIndex] = local.tempCityListItem>
			</cfloop>
		</cfloop>

		<cfset local.airportCodes = StructFindKey(local.cityCode, arguments.cityCodeToCheck)>

		<cfreturn local.airportCodes[1].value>
	</cffunction>
 <!--- // end of STM-2254 hack --->
</cfcomponent>
