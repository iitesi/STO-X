<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="UAPIFactory">
	<cfproperty name="uAPISchemas">
	<cfproperty name="AirParse">

	<cffunction name="init" output="false" hint="Init method.">
		<cfargument name="UAPIFactory">
		<cfargument name="uAPISchemas">
		<cfargument name="AirParse">

		<cfset setUAPIFactory(arguments.UAPIFactory)>
		<cfset setUAPISchemas(arguments.uAPISchemas)>
		<cfset setAirParse(arguments.AirParse)>

		<cfreturn this>
	</cffunction>

	<cffunction name="removeFlight" output="false" hint="I remove a flight from the session based on searchID.">
		<cfargument name="searchID">

		<cfset StructDelete(session.searches, arguments.searchID)>
		<cfset StructDelete(session.filters, arguments.searchID)>

		<cfreturn  />
	</cffunction>

	<cffunction name="selectAir" output="false" hint="I set stItinerary into the session scope.">
		<cfargument name="SearchID">
		<cfargument name="nTrip">

		<!--- Initialize or overwrite the CouldYou air section --->
		<cfset session.searches[arguments.SearchID].CouldYou.Air = {} />
		<cfset session.searches[arguments.SearchID]['Air'] = true />
		<!--- Move over the information into the stItinerary --->
		<cfset session.searches[arguments.SearchID].stItinerary.Air = session.searches[arguments.SearchID].stTrips[arguments.nTrip]>

		<cfquery datasource="booking">
			INSERT INTO Logs
				( Search_ID
				, ElapsedTime
				, Service
				, Request
				, Response
				, Timestamp )
			VALUES
				( #arguments.searchID#
				, 0
				, 'A'
				, 'Selection for lowfare'
				, '#serializeJSON(session.searches[arguments.SearchID].stItinerary.Air)#'
				, getDate() )
		</cfquery>

		<cfset session.searches[arguments.SearchID].stItinerary.Air.nTrip = arguments.nTrip>
		<cfset session.searches[arguments.SearchID].RequestedRefundable = session.searches[arguments.SearchID].stItinerary.Air.RequestedRefundable />
		<cfset session.searches[arguments.SearchID].PassedRefCheck = 0 />
		<!--- Loop through the searches structure and delete all other searches --->
		<cfloop collection="#session.searches#" index="local.nKey">
			<cfif IsNumeric(local.nKey) AND local.nKey NEQ arguments.SearchID>
				<cfset StructDelete(session.searches, local.nKey)>
			</cfif>
		</cfloop>

		<!--- <cfif cgi.http_host EQ "r.local" OR cgi.local_host IS "RailoQA"> --->
			<!--- <cfmail to="kmyers@shortstravel.com;klamont@shortstravel.com"
					from="kmyers@shortstravel.com"
					subject="FLIGHT SELECTED FOR SEARCH #arguments.SearchID#"
					type="html">
				<div style="margin:5px;border:1px solid silver;background-color:##ebebeb;font-family:arial;font-size:12px;padding:5px;">
					<cfdump var="#session.searches[arguments.SearchID].stItinerary#">
				</div>
			</cfmail> --->
		<!--- </cfif> --->

		<cfreturn />
	</cffunction>


	<cffunction name="threadLowFare" output="false" hint="I assemble info to pass to thread.">
		<!--- arguments getting passed in from RC --->
		<cfargument name="sPriority" required="false" default="HIGH">
		<cfargument name="bRefundable" required="false" default="false">
		<cfargument name="Filter" required="false" default="X">
		<cfargument name="stPricing" required="true">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="sCabins" default="">

		<cfset local.aRefundable = ListToArray(arguments.bRefundable)>
		<cfset local.sThreadName = ''>
		<cfset local.stThreads = {}>
		<cfset local.BlackListedCarrierPairing = application.BlackListedCarrierPairing>

		<cfset local.airlines = []>
		<cfif arguments.Filter.getAirlines() EQ ''>
			<cfset local.airlines = ['X']>
		<cfelse>
			<cfset local.airlines = [arguments.Filter.getAirlines()]>
		</cfif>

		<cfif arguments.Filter.getClassOfService() EQ ''>
			<cfset local.aCabins = ['X']>
		<cfelseif Len(arguments.sCabins)>
			<!--- if find more class is clicked from filter bar - arguments.sCabins (from rc.cabins) will exist --->
			<cfset local.aCabins = [arguments.sCabins]>
		<cfelse>
			<!--- otherwise get the class/cabin passed from the widget --->
			<cfset local.aCabins = [arguments.Filter.getClassOfService()]>
		</cfif>

		<!--- Create a thread for every combination of cabin, fare and airline. --->
		<cfloop array="#local.aCabins#" index="local.sCabin">
			<cfloop array="#local.aRefundable#" index="local.bRefundable">
				<cfloop array="#local.airlines#" index="local.airlineIndex" item="local.airline">

					<cfset local.wnFound = false>
					<cfloop array="#arguments.Account.Air_PF#" index="local.sPF">
						<cfif local.airline EQ 'X'
							OR local.airline EQ getToken(sPF, 2, ',')>
							<cfif getToken(local.sPF, 2, ',') EQ 'WN'>
								<cfset local.wnFound = true>
							</cfif>
							<cfset local.sThreadName = doLowFare( Filter = arguments.Filter
																, sCabin = local.sCabin
																, bRefundable = local.bRefundable
																, sPriority = arguments.sPriority
																, stPricing = arguments.stPricing
																, Account = arguments.Account
																, Policy = arguments.Policy
																, BlackListedCarrierPairing = local.BlackListedCarrierPairing
																, airline = airline
																, fareType = "PrivateFaresOnly"
																, accountCode = sPF )>
							<cfset local.stThreads[local.sThreadName] = ''>
						</cfif>
					</cfloop>
					<cfif NOT local.wnFound
						AND (local.airline EQ 'X'
							OR local.airline EQ 'WN')>
						<cfset local.sThreadName = doLowFare( Filter = arguments.Filter
															, sCabin = local.sCabin
															, bRefundable = local.bRefundable
															, sPriority = arguments.sPriority
															, stPricing = arguments.stPricing
															, Account = arguments.Account
															, Policy = arguments.Policy
															, BlackListedCarrierPairing = local.BlackListedCarrierPairing
															, airline = 'WN'
															, fareType = "PrivateFaresOnly"
															, accountCode = '' )>
						<cfset local.stThreads[local.sThreadName] = ''>
					</cfif>
					<cfif local.airline NEQ 'WN'>
						<cfset local.sThreadName = doLowFare( Filter = arguments.Filter
															, sCabin = local.sCabin
															, bRefundable = local.bRefundable
															, sPriority = arguments.sPriority
															, stPricing = arguments.stPricing
															, Account = arguments.Account
															, Policy = arguments.Policy
															, BlackListedCarrierPairing = local.BlackListedCarrierPairing
															, airline = local.airline
															, fareType = "PublicFaresOnly" )>
						<cfset local.stThreads[local.sThreadName] = ''>
					</cfif>
				</cfloop>
			</cfloop>
		</cfloop>

		<!--- If State of Texas, get government rates --->
		<!--- Elements specific to this request:
			  SearchPassenger Code="GST" and PricePTCOnly="true"
			  PersonalGeography - CityCode=DFW
			  PublicorPrivateFares, ProhibitNonRefundablefares=false --->
		<cfif arguments.Filter.getAcctID() EQ 235>
			<cfset local.sThreadName = doLowFare( Filter = arguments.Filter
												, sCabin = local.sCabin
												, bRefundable = false
												, sPriority = arguments.sPriority
												, stPricing = arguments.stPricing
												, Account = arguments.Account
												, Policy = arguments.Policy
												, BlackListedCarrierPairing = local.BlackListedCarrierPairing
												, airline = airline
												, fareType = "PublicOrPrivateFares"
												, accountCode = sPF
												, bGovtRate = true )>
			<cfset local.stThreads[local.sThreadName] = ''>
		</cfif>

		<!--- Join only if threads where thrown out. --->
		<cfif NOT StructIsEmpty(stThreads)
			AND structKeyList(stThreads) NEQ ''
			AND arguments.sPriority EQ 'HIGH'>
			<cfthread action="join" name="#structKeyList(stThreads)#" />

			<cfloop collection="#cfthread#" index="local.i" item="local.thread">
				<cfif thread.status NEQ 'COMPLETED'
					AND thread.status NEQ 'RUNNING'
					AND application.fw.factory.getBean( 'EnvironmentService' ).getEnableBugLog()>
					<cfset local.errorException = { searchID=arguments.Filter.getSearchID(), request=thread }>
					<cfset application.fw.factory.getBean('BugLogService').notifyService( message='CFTHREAD: #thread.error.message#', exception=local.errorException, severityCode='Error' ) />
					<!--- <cfdump var="#thread#" /><cfabort /> --->
				<cfelseif structKeyExists(local.thread, 'stTrips')>
					<!--- Merge all data into the current session structures. --->
					<cfset session.searches[arguments.Filter.getSearchID()].stTrips = getAirParse().mergeTrips(session.searches[arguments.Filter.getSearchID()].stTrips, local.thread.stTrips)>
				</cfif>
			</cfloop>
		</cfif>

		<!--- 12:20 PM Saturday, March 29, 2014 - Jim Priest - jpriest@shortstravel.com
					Delete the thread if we are running travelTech report. Please do not remove.
					this prevents thread name error - http://cfmlblog.adamcameron.me/2013/02/thread-longevity-weirdness.html
					<cfset structdelete(cfthread,"#structKeyList(stThreads)#")>
		--->
		<!--- <cfdump var="#session.searches[arguments.Filter.getSearchID()].stTrips#" abort> --->

		<!--- Finish up the results - finishLowFare sets data into session.searches[searchid] --->
		<cfset getAirParse().finishLowFare(arguments.Filter.getSearchID(), arguments.Account, arguments.Policy)>

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
		<cfargument name="airline" required="true">
		<cfargument name="fareType" type="string" required="true" hint="PublicFaresOnly|PrivateFaresOnly" />
		<cfargument name="accountCode" type="string" required="false" default="" />
		<cfargument name="bGovtRate" required="false" default="false" />

		<cfset local.sThreadName = "">

		<!--- Don't go back to the UAPI if we already got the data. --->
		<cfif NOT StructKeyExists(arguments.stPricing, arguments.sCabin&arguments.bRefundable&arguments.airline&arguments.bGovtRate)>
			<cfset local.sThreadName = arguments.sCabin&arguments.bRefundable&arguments.airline&arguments.bGovtRate&arguments.fareType&replace(arguments.accountCode, ',', '', 'all')>
			<cfset local[local.sThreadName] = {}>

			<cfset local.bRefundable = (arguments.bRefundable NEQ 'X' AND arguments.bRefundable ? 'true' : 'false')><!--- false = non refundable - true = refundable --->
			<!--- STM-2434 if the account doesn’t allow nonrefundables, to only call for
			 refundable fares in the uAPI lowfare call --->
			<cfif arguments.Policy.Policy_AirRefRule EQ 1 AND arguments.Policy.Policy_AirRefDisp EQ 1>
				<cfset local.bRefundable = true>
			</cfif>

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
				bRefundable="#local.bRefundable#"
				airline="#arguments.airline#"
				blackListedCarrierPairing="#arguments.blackListedCarrierPairing#"
				accountCode="#arguments.accountCode#"
				fareType="#arguments.fareType#"
				bGovtRate="#arguments.bGovtRate#">

				<!--- Put together the SOAP message. --->
				<cfset attributes.sMessage = prepareSOAPHeader(arguments.Filter, arguments.sCabin, arguments.bRefundable, '', arguments.Account, arguments.airline, arguments.policy, arguments.fareType, arguments.accountCode, arguments.bGovtRate)>

				<!--- Call the UAPI. --->
				<cfset attributes.sResponse = getUAPI().callUAPI('AirService', attributes.sMessage, arguments.Filter.getSearchID(), arguments.Filter.getAcctID(), arguments.Filter.getUserID())>

				<!--- Format the UAPI response. --->
				<cfset attributes.aResponse = getUAPI().formatUAPIRsp(attributes.sResponse)>
				<!--- If the UAPI gives an error then don't continue and send an error to BugLog instead. --->
				<cfif FindNoCase('faultstring', attributes.sResponse) EQ 0>
					<!--- Parse the segments. --->
					<cfset attributes.stSegments = getAirParse().parseSegments( stResponse = attributes.aResponse )>
					<!--- Parse the trips. --->
					<cfset attributes.stTrips = getAirParse().parseTrips( response = attributes.aResponse
																		, stSegments = attributes.stSegments
																		, bRefundable = arguments.bRefundable )>
					<!--- Add group node --->
					<cfset attributes.stTrips = getAirParse().addGroups( stTrips = attributes.stTrips )>

					<!--- Remove BlackListed Carriers --->
					<cfset attributes.stTrips = getAirParse().removeMultiConnections( trips = attributes.stTrips )>

					<!--- Remove BlackListed Carriers --->
					<cfset attributes.stTrips = getAirParse().removeBlackListedCarriers( trips = attributes.stTrips
																						, blackListedCarriers = arguments.blackListedCarrierPairing )>

					<!--- Remove Private Fares --->
					<cfset attributes.stTrips = getAirParse().removeMultiCarrierPrivateFares( trips = attributes.stTrips )>

					<!--- Add preferred node from account --->
					<cfset thread.stTrips = getAirParse().addPreferred( stTrips = attributes.stTrips
																			, Account = arguments.Account)>

				<cfelse> <!--- // faultstring found - let's throw an error --->

					<!--- 12:20 PM Saturday, March 29, 2014 - Jim Priest - jpriest@shortstravel.com
					Grab faultstring if we are running travelTech report. Please do not remove.
					Comment out the error handling below.
					<cfset local.faultstring = ''>
					<cfloop array="#attributes.aResponse#" item="local.faultItem">
						<cfif faultItem.XMLName EQ 'faultstring'>
							<cfset local.faultstring = faultItem.xmlText>
						</cfif>
					</cfloop>
					<cfset session.faultString = 'uAPI Faultcode Error: '&local.faultstring>
					--->

					<cfif application.fw.factory.getBean( 'EnvironmentService' ).getEnableBugLog()>
						<cfset local.faultstring = ''>
						<cfloop array="#attributes.aResponse#" item="local.faultItem">
							<cfif faultItem.XMLName EQ 'faultstring'>
								<cfset local.faultstring = faultItem.xmlText>
							</cfif>
						</cfloop>
						<cfset local.errorMessage = 'uAPI Faultcode Error: '&local.faultstring>
						<cfif local.faultstring DOES NOT CONTAIN 'cannot retrieve TargetBranch information for'
							AND local.faultstring DOES NOT CONTAIN 'NO AVAILABILITY FOR THIS REQUEST'>
							<cfset local.errorException = structNew('linked')>
							<cfset local.errorException = {
														searchID = arguments.Filter.getSearchID()
													, userID = arguments.Filter.getUserID()
													, acctID = arguments.Filter.getAcctID()
													, username = arguments.Filter.getUsername()
													, department = arguments.Filter.getDepartment()
													, faultstring = local.faultstring
													, request = xmlFormat(attributes.sMessage)
													, response = xmlFormat(attributes.sResponse)  }>
							<cfif local.faultstring DOES NOT CONTAIN 'Transaction Error: AppErrorSeverityLevel/1'>
								<cfset severityLevel = "Error" />
								<cfif findNoCase('UNABLE TO FARE QUOTE', local.faultstring)>
									<cfset severityLevel = "Info" />
								</cfif>
								<cfset application.fw.factory.getBean('BugLogService').notifyService( message=local.errorMessage, exception=errorException, severityCode=severityLevel ) />
							</cfif>
						</cfif>
					</cfif>
				</cfif>

				<!--- flag this as being processed so we don't return to uAPI in future --->
				<cfset session.searches[arguments.Filter.getSearchID()].stLowFareDetails.stPricing[arguments.sCabin&arguments.bRefundable&arguments.airline] = 1>
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
		<cfargument name="airline" required="true">
		<cfargument name="policy" required="true">
		<cfargument name="fareType" type="string" required="true" hint="PublicFaresOnly|PrivateFaresOnly|PublicOrPrivateFares" />
		<cfargument name="accountCode" type="string" required="false" default="" />
		<cfargument name="bGovtRate" required="false" default="false" />

		<cfif arguments.Filter.getAirType() EQ 'MD'>
			<!--- grab leg query out of filter --->
			<cfset local.qSearchLegs = arguments.filter.getLegs()[1]>
		</cfif>

		<!--- TODO: Code needs to be reworked and put in a better location --->
		<cfset local.targetBranch = arguments.Account.sBranch>
		<cfif arguments.Filter.getAcctID() EQ 254
			OR arguments.Filter.getAcctID() EQ 255>
			<!--- If Southwest lowfare call --->
			<cfif arguments.fareType EQ 'PrivateFaresOnly' AND (arguments.airline EQ 'WN' OR GetToken(arguments.accountCode, 2, ',') EQ 'WN')>
				<cfset local.targetBranch = 'P1601400'>
			<!--- All other lowfare calls --->
			<cfelse>
				<cfset local.targetBranch = 'P1601396'>
			</cfif>
		</cfif>

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
							<air:LowFareSearchReq TargetBranch="#targetBranch#"
								xmlns:air="#getUAPISchemas().air#"
								xmlns:com="#getUAPISchemas().common#">
								<com:BillingPointOfSaleInfo OriginApplication="UAPI" />

								<!--- For one way and first leg of rounttrip we get depart info --->
								<cfif arguments.Filter.getAirType() EQ 'RT'
									OR arguments.Filter.getAirType() EQ 'OW'>
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
									<cfif arguments.filter.getIsDomesticTrip() IS "true">
										MaxConnectionTime="300"
									</cfif>
									ProhibitMultiAirportConnection="true"
									PreferNonStop="true">

									<cfif arguments.airline NEQ 'X'>
										<air:PermittedCarriers>
											<com:Carrier Code="#arguments.airline#"/>
										</air:PermittedCarriers>
									<cfelseif arguments.fareType EQ 'PrivateFaresOnly'>
										<air:PermittedCarriers>
											<com:Carrier Code="#GetToken(arguments.accountCode, 2, ',')#"/>
										</air:PermittedCarriers>
									<cfelse>
										<air:ProhibitedCarriers>
											<com:Carrier Code="3M"/>
											<com:Carrier Code="G4"/>
											<com:Carrier Code="NK"/>
											<com:Carrier Code="ZK"/>
										</air:ProhibitedCarriers>
									</cfif>
									<cfif arguments.fareType EQ "PrivateFaresOnly">
										<air:FlightType MaxStops="1" MaxConnections="2" RequireSingleCarrier="true"/>
									<cfelse>
										<air:FlightType MaxStops="1" MaxConnections="2" RequireSingleCarrier="false"/>
									</cfif>
								</air:AirSearchModifiers>
								<cfif arguments.bGovtRate>
									<com:SearchPassenger Code="GST" PricePTCOnly="true">
										<com:PersonalGeography>
											<com:CityCode>DFW</com:CityCode>
										</com:PersonalGeography>
									</com:SearchPassenger>
								<cfelse>
									<com:SearchPassenger Code="ADT" />
								</cfif>
								<air:AirPricingModifiers
									ProhibitNonRefundableFares="#arguments.bRefundable#"
									FaresIndicator="#arguments.fareType#"
									ProhibitMinStayFares="false"
									ProhibitMaxStayFares="false"
									CurrencyType="USD"
									ProhibitAdvancePurchaseFares="false"
									ProhibitRestrictedFares="false"
									ETicketability="Required"
									ProhibitNonExchangeableFares="false"
									ForceSegmentSelect="false" >
									<cfif arguments.fareType EQ 'PrivateFaresOnly'
										AND arguments.accountCode NEQ ''>
										<air:AccountCodes>
											<com:AccountCode Code="#getToken(arguments.accountCode, 3, ',')#" ProviderCode="1V" SupplierCode="#getToken(arguments.accountCode, 2, ',')#" />
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