<cfcomponent output="false" accessors="true">

	<cfproperty name="UAPI">
	<cfproperty name="uAPISchemas">
	<cfproperty name="AirParse">

	<cffunction name="init" output="false" hint="Init method.">
		<cfargument name="UAPI">
		<cfargument name="uAPISchemas">
		<cfargument name="AirParse">

		<cfset setUAPI(arguments.UAPI)>
		<cfset setUAPISchemas(arguments.uAPISchemas)>
		<cfset setAirParse(arguments.AirParse)>

		<cfreturn this>
	</cffunction>

	<cffunction name="removeFlight" output="false" hint="I remove a flight from the database based on searchID.">
		<cfargument name="searchID">
		<cfset var result = 'true'>

		<cftransaction action="begin">
			<cftry>
				<cfquery>
					DELETE
					FROM Searches
					WHERE Search_ID = <cfqueryparam value="#arguments.searchID#" cfsqltype="cf_sql_numeric" />
				</cfquery>

				<cfquery>
					DELETE
					FROM Searches_Legs
					WHERE Search_ID = <cfqueryparam value="#arguments.searchID#" cfsqltype="cf_sql_numeric" />
				</cfquery>

				<!---
				TODO: we should really NOT be touching session here!
				4:04 PM Wednesday, June 26, 2013 - Jim Priest - jpriest@shortstravel.com
 				--->
				<cfset StructDelete(session.searches, arguments.searchID)>
				<cfset StructDelete(session.filters, arguments.searchID)>

				<cfcatch type="any">
					<cftransaction action="rollback" />
					<cfset result = false>
				</cfcatch>
			</cftry>
		</cftransaction>

		<cfreturn result />
	</cffunction>

	<cffunction name="selectAir" output="false" hint="I set stItinerary into the session scope.">
		<cfargument name="SearchID">
		<cfargument name="nTrip">

		<!--- Initialize or overwrite the CouldYou air section --->
		<cfset session.searches[arguments.SearchID].CouldYou.Air = {} />
		<cfset session.searches[arguments.SearchID]['Air'] = true />
		<!--- Move over the information into the stItinerary --->
		<cfset session.searches[arguments.SearchID].stItinerary.Air = session.searches[arguments.SearchID].stTrips[arguments.nTrip]>
		<cfset session.searches[arguments.SearchID].stItinerary.Air.nTrip = arguments.nTrip>
		<!--- Loop through the searches structure and delete all other searches --->
		<cfloop collection="#session.searches#" index="local.nKey">
			<cfif IsNumeric(nKey) AND nKey NEQ arguments.SearchID>
				<cfset StructDelete(session.searches, nKey)>
			</cfif>
		</cfloop>

		<cfreturn />
	</cffunction>


	<cffunction name="threadLowFare" output="false" hint="I assemble info to pass to thread.">
		<!--- arguments getting passed in from RC --->
		<cfargument name="sPriority" required="false" default="HIGH">
		<cfargument name="bRefundable" required="false" default="X">
		<cfargument name="Filter" required="false" default="X">
		<cfargument name="stPricing" required="true">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="BlackListedCarrierPairing" required="false">

		<!--- grab class from widget form --->
		<cfset local.sCabins = arguments.filter.getClassOfService()>
		<!--- if find more class is clicked from filter bar - rc.sCabins will exist --->
		<cfif StructKeyExists(arguments, "sCabins")>
			<cfset local.sCabins = arguments.sCabins>
		</cfif>

		<cfset local.aCabins = ListToArray(local.sCabins)>
		<cfset local.aRefundable = ListToArray(arguments.bRefundable)>
		<cfset local.sThreadName = ''>
		<cfset local.stThreads = {}>
		<cfset local.BlackListedCarrierPairing = arguments.BlackListedCarrierPairing>


		<!--- Create a thread for every combination of cabin, fares and PTC. --->
		<cfloop array="#aCabins#" index="local.sCabin">
			<cfloop array="#aRefundable#" index="local.bRefundable">
				<cfset local.sThreadName = doLowFare(arguments.Filter, local.sCabin, local.bRefundable, arguments.sPriority, arguments.stPricing, arguments.Account, arguments.Policy, local.BlackListedCarrierPairing)>
				<cfset local.stThreads[local.sThreadName] = ''>
			</cfloop>
		</cfloop>

		<!--- Join only if threads where thrown out. --->
		<cfif NOT StructIsEmpty(stThreads) AND arguments.sPriority EQ 'HIGH'>
			<cfthread action="join" name="#structKeyList(stThreads)#" />
		</cfif>

		<cfreturn />
	</cffunction>

<!--- PRIVATE METHODS ===================================================== --->

	<cffunction name="doLowFare" access="private" output="false" hint="I kick off thread to hit uAPI.">
		<cfargument name="Filter" required="true">
		<cfargument name="sCabin" required="true">
		<cfargument name="bRefundable" required="true">
		<cfargument name="sPriority" required="true">
		<cfargument name="stPricing" required="true">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="BlackListedCarrierPairing" required="false">
		<cfargument name="sLowFareSearchID"	required="false" default="">

		<cfset local.sThreadName = "">

		<!--- Don't go back to the UAPI if we already got the data. --->
		<cfif NOT StructKeyExists(arguments.stPricing, arguments.sCabin&arguments.bRefundable)>
			<cfset sThreadName = arguments.sCabin&arguments.bRefundable>
			<cfset local[local.sThreadName] = {}>

			<!--- Note:  To debug: comment out opening and closing cfthread tags and
			dump sMessage or sResponse to see what uAPI is getting and sending back --->

			<cfthread
				action="run"
				name="#sThreadName#"
				priority="#arguments.sPriority#"
				Filter="#arguments.Filter#"
				sCabin="#arguments.sCabin#"
				Account="#arguments.Account#"
				Policy="#arguments.Policy#"
				bRefundable="#arguments.bRefundable#"
				blackListedCarrierPairing="#arguments.blackListedCarrierPairing#">

				<!--- Put together the SOAP message. --->
				<cfset attributes.sMessage = prepareSoapHeader(arguments.Filter, arguments.sCabin, arguments.bRefundable, '', arguments.Account)>
				<!--- Call the UAPI. --->
				<cfset attributes.sResponse = getUAPI().callUAPI('AirService', attributes.sMessage, arguments.Filter.getSearchID(), arguments.Filter.getAcctID(), arguments.Filter.getUserID())>

				<!--- use to spoof a bad request with faultcode--->
				<!--- <cfsavecontent variable="attributes.sResponse">
					<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/"><SOAP:Body><SOAP:Fault><faultcode>Server.Business</faultcode><faultstring>UNABLE TO FARE QUOTE</faultstring><detail><common_v19_0:ErrorInfo xmlns:common_v19_0="http://www.travelport.com/schema/common_v19_0"><common_v19_0:Code>3037</common_v19_0:Code><common_v19_0:Service>AIRSVC</common_v19_0:Service><common_v19_0:Type>Business</common_v19_0:Type><common_v19_0:Description>No availability on chosen flights.</common_v19_0:Description><common_v19_0:TransactionId>36A045550A07611150AD782E48FF4450</common_v19_0:TransactionId></common_v19_0:ErrorInfo></detail></SOAP:Fault></SOAP:Body></SOAP:Envelope>
				</cfsavecontent> --->

				<!--- Format the UAPI response. --->
				<cfset attributes.aResponse = getUAPI().formatUAPIRsp(attributes.sResponse)>

				<!--- If the UAPI gives an error then don't continue and send an error to BugLog instead. --->
				<cfif FindNoCase('faultstring', attributes.sResponse) EQ 0>
					<!--- Parse the segments. --->
					<cfset attributes.stSegments = getAirParse().parseSegments(attributes.aResponse)>
					<!--- Parse the trips. --->
					<cfset attributes.stTrips = getAirParse().parseTrips(response = attributes.aResponse, stSegments = attributes.stSegments)>
					<!--- Add group node --->
					<cfset attributes.stTrips = getAirParse().addGroups(attributes.stTrips)>


					<cfif ArrayLen(attributes.blackListedCarrierPairing)>
						<!--- Remove BlackListed Carriers --->
						<cfset attributes.stTrips = getAirParse().removeBlackListedCarriers(attributes.stTrips, attributes.blackListedCarrierPairing)>
					</cfif>

					<!--- Add preferred node from account --->
					<cfset attributes.stTrips = getAirParse().addPreferred(attributes.stTrips, arguments.Account)>

					<!--- Merge all data into the current session structures. --->
					<cfset session.searches[arguments.Filter.getSearchID()].stTrips = getAirParse().mergeTrips(session.searches[arguments.Filter.getSearchID()].stTrips, attributes.stTrips)>
					<!--- Finish up the results - finishLowFare sets data into session.searches[searchid] --->
					<cfset getAirParse().finishLowFare(arguments.Filter.getSearchID(), arguments.Account, arguments.Policy)>
				<cfelse>
					<cfif application.fw.factory.getBean( 'EnvironmentService' ).getEnableBugLog() IS true>
						<cfset errorMessage = "uAPI Faultcode Error">
						<cfset errorException = {searchID=arguments.Filter.getSearchID(), request=xmlFormat(attributes.sMessage), response=xmlFormat(attributes.sResponse)}>
						<cfset application.fw.factory.getBean('BugLogService').notifyService( message=errorMessage, exception=errorException, severityCode='Error' ) />
					</cfif>
				</cfif>

				<!--- 3:18 PM Thursday, September 19, 2013 - Jim Priest - jpriest@shortstravel.com
				I don't think this is being used? Commenting it out to see if any issues arise.

				<cfset thread.stTrips =	session.searches[arguments.Filter.getSearchID()].stTrips>
				--->

				<!--- flag this as being processed so we don't return to uAPI in future --->
				<cfset session.searches[arguments.Filter.getSearchID()].stLowFareDetails.stPricing[arguments.sCabin&arguments.bRefundable] = 1>
			</cfthread>
		</cfif>
		<cfreturn sThreadName>
	</cffunction>

	<cffunction name="prepareSOAPHeader" access="private" returntype="string" output="false" hint="I prepare the SOAP header.">
		<cfargument name="Filter" required="true">
		<cfargument name="sCabins"  required="true">
		<cfargument name="bRefundable" required="true">
		<cfargument name="sLowFareSearchID"	required="false" default="">
		<cfargument name="Account" required="false"	default="">

		<cfif arguments.Filter.getAirType() EQ 'MD'>
			<!--- grab leg query out of filter --->
			<cfset local.qSearchLegs = arguments.filter.getLegs()[1]>
		</cfif>

		<cfset local.bProhibitNonRefundableFares = (arguments.bRefundable NEQ 'X' AND arguments.bRefundable ? 'true' : 'false')><!--- false = non refundable - true = refundable --->
		<cfset local.aCabins = (arguments.sCabins NEQ 'X' ? ListToArray(arguments.sCabins) : [])>

<!---
****************************************************************************
				ANY CHANGES MADE BELOW PROBABLY NEED TO ALSO BE MADE IN
						   airAvailability.cfc   prepareSoapHeader()
****************************************************************************
--->
		<cfsavecontent variable="local.sMessage">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<cfif arguments.sLowFareSearchID EQ ''>
							<air:LowFareSearchReq TargetBranch="#arguments.Account.sBranch#"
								xmlns:air="#getUAPISchemas().air#"
								xmlns:com="#getUAPISchemas().common#">
								<com:BillingPointOfSaleInfo OriginApplication="UAPI" />

								<!--- For one way and first leg of rounttrip we get depart info --->
								<cfif arguments.Filter.getAirType() EQ 'RT'	OR arguments.Filter.getAirType() EQ 'OW'>
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
														<air:CabinClass Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
													</cfloop>
												</air:PermittedCabins>
											</cfif>
										</air:AirLegModifiers>
									</air:SearchAirLeg>
								</cfif>

								<!--- for second leg of round trip we get return info--->
								<cfif arguments.Filter.getAirType() EQ 'RT'>
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
														<air:CabinClass Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
													</cfloop>
												</air:PermittedCabins>
											</cfif>
										</air:AirLegModifiers>
									</air:SearchAirLeg>

								<!--- for multi-city trips loop over SearchesLegs --->
								<cfelseif arguments.Filter.getAirType() EQ 'MD'>
									<cfloop query="local.qSearchLegs">
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
															<air:CabinClass Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
														</cfloop>
													</air:PermittedCabins>
												</cfif>
											</air:AirLegModifiers>
										</air:SearchAirLeg>
									</cfloop>
								</cfif>

	<!--- MaxSolutions="1" --->

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
											<com:Carrier Code="ZK"/>
										</air:ProhibitedCarriers>
									</cfif>
									<air:FlightType MaxStops="1" MaxConnections="1" RequireSingleCarrier="false"/>
								</air:AirSearchModifiers>
								<com:SearchPassenger
									Code="ADT" />
								<air:AirPricingModifiers
									ProhibitNonRefundableFares="#bProhibitNonRefundableFares#"
									FaresIndicator="PublicAndPrivateFares"
									ProhibitMinStayFares="false"
									ProhibitMaxStayFares="false"
									CurrencyType="USD"
									ProhibitAdvancePurchaseFares="false"
									ProhibitRestrictedFares="false"
									ETicketability="Required"
									ProhibitNonExchangeableFares="false"
									ForceSegmentSelect="false">
									<cfif NOT ArrayIsEmpty(arguments.Account.Air_PF)>
										<air:AccountCodes>
											<cfloop array="#arguments.Account.Air_PF#" index="local.sPF">
												<com:AccountCode Code="#GetToken(sPF, 3, ',')#" ProviderCode="1V" SupplierCode="#GetToken(sPF, 2, ',')#" />
											</cfloop>
										</air:AccountCodes>
									</cfif>
								</air:AirPricingModifiers>
								<com:PointOfSale
									ProviderCode="1V"
									PseudoCityCode="1M98" />
							</air:LowFareSearchReq>
						<cfelse>
							<air:RetrieveLowFareSearchReq
								TargetBranch="#arguments.stAccount.sBranch#"
								SearchId="#arguments.sLowFareSearchID#"
								ProviderCode="1V"
								PartNumber="1">
								<com:BillingPointOfSaleInfo
									OriginApplication="UAPI" />
							</air:RetrieveLowFareSearchReq>
						</cfif>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>

		<cfreturn sMessage/>
	</cffunction>

</cfcomponent>