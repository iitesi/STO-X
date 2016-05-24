<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfset local.errorMessage = []> <!--- variable used to display an error on the summary page to the traveler --->
		<cfset local.errorType = ''> <!--- air, car, hotel, terminal, etc --->

		<cfloop collection="#session.searches[rc.searchID].Travelers#" index="local.travelerNumber" item="local.Traveler">
			<cfif arrayIsEmpty(errorMessage) AND NOT Traveler.getBookingDetail().getPurchaseCompleted()>
				<cfset local.providerLocatorCode = ''>
				<cfset local.universalLocatorCode = ''>
				<!--- Version needs to be set and updated based on how many times the universal record is used. --->
				<cfset local.version = -1>
				<!--- If a similar trip has been selected --->
				<cfif structKeyExists(rc, "recLoc") AND len(rc.recLoc)>
					<cfset Traveler.getBookingDetail().setSimilarTripSelected( true )>
					<cfset local.providerLocatorCode = rc.recLoc />
					<!--- <cfset local.providerLocatorCode = "J8G1KA" /> --->
					<cfset local.universalLocatorCode = fw.getBeanFactory().getBean('UniversalAdapter').searchUR( local.providerLocatorCode ) />
					<cfif NOT len(local.universalLocatorCode)>
						<cfset local.universalLocatorCode = fw.getBeanFactory().getBean('UniversalAdapter').importUR( targetBranch = rc.Account.sBranch
																													, locatorCode = local.providerLocatorCode ) />						
					</cfif>
					<cfif len(local.universalLocatorCode)>
						<cfset local.version = fw.getBeanFactory().getBean('UniversalAdapter').retrieveUR( targetBranch = rc.Account.sBranch
																										 , urLocatorCode = local.universalLocatorCode ) />
					</cfif>
				</cfif>
				<!--- Based on the "The parameter userID to function loadBasicUser is required but was not passed in." error that was being generated on occasion, checking first to see if the userID has a value. --->
				<cfif NOT len(Traveler.getUserID()) OR NOT isNumeric(Traveler.getUserID()) OR (Traveler.getUserID() EQ 0 AND Traveler.getBookingDetail().getSaveProfile())>
					<cfset Traveler.setUserID(rc.filter.getUserID()) />
				</cfif>
				<!--- Looks odd, but this is used to compare differences between their profile and what information
				they entered into the summary page. --->
				<cfset local.Profile = fw.getBeanFactory().getBean('UserService').loadBasicUser( userID = rc.Filter.getUserID() )>
				<cfset local.itinerary = session.searches[rc.searchID].stItinerary>
				<cfset local.airSelected = (structKeyExists(itinerary, 'Air') ? true : false)>
				<cfset local.Air = (structKeyExists(itinerary, 'Air') ? itinerary.Air : '')>
				<cfset local.hotelSelected = (structKeyExists(itinerary, 'Hotel') ? true : false)>
				<cfset local.Hotel = (structKeyExists(itinerary, 'Hotel') ? itinerary.Hotel : '')>
				<cfset local.vehicleSelected = (structKeyExists(itinerary, 'Vehicle') ? true : false)>
				<cfset local.Vehicle = (structKeyExists(itinerary, 'Vehicle') ? itinerary.Vehicle : '')>
				<cfset local.specialCarReservation = false />
				<cfif Traveler.getHomeAirport() EQ ''>
					<cfset Traveler.setHomeAirport('STO')>
				</cfif>
				<!--- Populate sort fields --->
				<cfset local.sort1 = ''>
				<cfset local.sort2 = ''>
				<cfset local.sort3 = ''>
				<cfset local.sort4 = ''>
				<cfset local.udids = {}>
				<cfloop array="#Traveler.getOrgUnit()#" index="local.orgUnitIndex" item="local.orgUnit">
					<cfif orgUnit.getOUType() EQ 'sort'>
						<cfset local['sort#orgUnit.getOUPosition()#'] = orgUnit.getValueReport()>
					<cfelseif orgUnit.getOUType() EQ 'udid'>
						<cfset local.udids[orgUnit.getOUPosition()] = orgUnit.getValueReport()>
					</cfif>
				</cfloop>
				<cfset local.statmentInformation = sort1&' '&sort2&' '&sort3&' '&sort4>
				<cfset statmentInformation = trim(statmentInformation)>

				<!--- LSU can charge to a different department cc which means the accountid needs to also change. --->
				<cfif rc.Filter.getAcctID() EQ 255>
					<cfset Traveler.setAccountID( fw.getBeanFactory().getBean('Summary').getLSUAccountID( Traveler = Traveler ) )>
					<cfset local.statmentInformation = fw.getBeanFactory().getBean('Summary').getLSUValueReportID( AccountID = Traveler.getAccountID() ) />
				</cfif>

				<!--- If new air or hotel credit card entered, make airFOPID or hotelFOPID EQ 0. --->
				<!--- <cfif Traveler.getBookingDetail().getNewAirCC() EQ 1>
					<cfset Traveler.getBookingDetail().setAirFOPID(0) />
				</cfif>
				<cfif Traveler.getBookingDetail().getNewHotelCC() EQ 1>
					<cfset Traveler.getBookingDetail().setHotelFOPID(0) />
				</cfif> --->

				<!--- Determine if pre trip approval is needed. --->
				<cfset local.approval = fw.getBeanFactory().getBean('Summary').determineApproval( Policy = rc.Policy
																								, Filter = rc.Filter
																								, Traveler = Traveler
																								, Itinerary = local.itinerary )>
				<cfset Traveler.getBookingDetail().setApprovalNeeded( approval.approvalNeeded )>
				<cfset Traveler.getBookingDetail().setApprovalNeededReasons( approval.approvalNeededReasons )>
				<cfset Traveler.getBookingDetail().setApprovers( approval.approvers )>

				<!--- Custom code for State of LA and LSU to book WN in another PCC/target branch --->
				<cfif airSelected
					AND (rc.Filter.getAcctID() EQ 254
					OR rc.Filter.getAcctID() EQ 255)
					AND Air.Carriers[1] EQ 'WN'>
					<cfset rc.Account.sBranch = 'P1601400'>
					<cfset rc.Account.PCC_Booking = '1H7M'>
				<cfelseif airSelected
					AND (rc.Filter.getAcctID() EQ 254
					OR rc.Filter.getAcctID() EQ 255)
					AND Air.Carriers[1] NEQ 'WN'>
					<cfset rc.Account.sBranch = 'P1601396'>
					<cfset rc.Account.PCC_Booking = '2B2C'>
				</cfif>

				<cfset local.datetimestamp = now() />
				<cfset local.string = "acctID=#rc.Filter.getAcctID()#&userID=#rc.Filter.getUserID()#&searchID=#rc.searchID#&date=#dateFormat(local.datetimestamp, 'mm/dd/yyyy')#&time=#timeFormat(local.datetimestamp, 'HH:mm:ss')#" />
				<cfset local.token = hash(local.string&rc.account.SecurityCode) />

				<!--- Open terminal session --->
				<cfset local.hostToken = fw.getBeanFactory().getBean('TerminalEntry').openSession( targetBranch = rc.Account.sBranch
																								, searchID = rc.searchID )>

				<cfif hostToken EQ ''>
					<cfset arrayAppend(errorMessage, 'Terminal - open session failed')>
					<cfset errorType = 'TerminalEntry.openSession'>
				</cfif>

				<!--- Find the profile in the GDS --->
				<cfset local.profileFound = true>
				<cfif left(Traveler.getPAR(), 14) EQ 'STODEFAULTUSER'>
					<cfset Traveler.setPAR('') />
				</cfif>
				<cfif arrayIsEmpty(errorMessage)
					AND Traveler.getPAR() NEQ ''>
					<cfset parResponse = fw.getBeanFactory().getBean('TerminalEntry').readPAR( targetBranch = rc.Account.sBranch
																								, hostToken = hostToken
																								, pcc = Traveler.getBAR()[1].PCC
																								, bar = Traveler.getBAR()[1].Name
																								, par = Traveler.getPAR()
																								, searchID = rc.searchID)>
					<cfif parResponse.error>
						<cfset profileFound = false>
					</cfif>
				<cfelse>
					<cfset profileFound = false>
				</cfif>

				<!--- Price Air --->
				<cfif airSelected
					AND Traveler.getBookingDetail().getAirNeeded()>

					<cfset local.bRefundable = 0 />
					<cfif structKeyExists(session.searches[rc.SearchID], "RequestedRefundable")>
						<cfset local.bRefundable = session.searches[rc.SearchID].RequestedRefundable />
					</cfif>

					<cfset local.bGovtRate = 0 />
					<cfset local.sFaresIndicator = "PublicAndPrivateFares" />
					<cfif Air.PTC EQ "GST">
						<cfset local.bGovtRate = 1 />
						<cfset local.sFaresIndicator = "PublicOrPrivateFares" />
					</cfif>

					<cfset local.originalAirfare = Air.Total />

					<cfif (NOT structKeyExists(Air, 'PricingSolution')
						OR NOT isObject(Air.PricingSolution))
						AND session.searches[rc.SearchID].PassedRefCheck EQ 0>

						<cfset local.trip = fw.getBeanFactory().getBean('AirPrice').doAirPrice( searchID = rc.searchID
																							, Account = rc.Account
																							, Policy = rc.Policy
																							, sCabin = Air.Class
																							, bRefundable = bRefundable
																							, bRestricted = 0
																							, sFaresIndicator = sFaresIndicator
																							, bAccountCodes = 1
																							, nTrip = Air.nTrip
																							, nCouldYou = 0
																							, bSaveAirPrice = 1
																							, findIt = rc.Filter.getFindIt()
																							, bIncludeClass = 1
																							, bIncludeCabin = 1
																							, totalOnly = 0
																							, bIncludeBookingCodes = 1
																							, bGovtRate = bGovtRate
																							, bFirstPrice = 1
																						)>
						<cfif structIsEmpty(trip) OR structKeyExists(trip, 'faultMessage')>
							<cfset arrayAppend( errorMessage, 'Fare type selected is unavailable for pricing.' )>
							<cfset errorType = 'Air.airPrice'>
						<cfelseif NOT structKeyExists(trip, 'faultMessage')>
							<cfset local.doAirPrice.Total = 0 />
							<cfset local.tripKey = 0 />
							<cfloop list="#structKeyList(trip)#" index="local.thisTrip">
								<cfif ((trip[local.thisTrip].Class EQ Air.Class) AND
									(trip[local.thisTrip].PrivateFare EQ Air.PrivateFare) AND
									(trip[local.thisTrip].Ref EQ Air.Ref))>
									<cfset local.doAirPrice.Total = trip[local.thisTrip].Total />
									<cfset local.tripKey = local.thisTrip />
								</cfif>
							</cfloop>

							<cfif local.doAirPrice.Total NEQ 0 AND (local.doAirPrice.Total LTE originalAirfare)>
								<cfset local.nTrip = Air.nTrip>
								<cfset local.aPolicies = Air.aPolicies>
								<cfset local.policy = Air.policy>
								<cfset Air = trip[local.tripKey]>
								<cfset Air.nTrip = nTrip>
								<cfset Air.aPolicies = aPolicies>
								<cfset Air.policy = policy>
							<cfelse>
								<cfset arrayAppend( errorMessage, 'The price quoted is no longer available online. Please select another flight or contact us to complete your reservation.  Price was #dollarFormat(originalAirfare)# and now is #dollarFormat(trip[structKeyList(trip)].Total)#.' )>
								<cfset errorType = 'Air.airPrice'>
							</cfif>
						</cfif>
					</cfif>
					<cfset Traveler.getBookingDetail().setAirRefundableFare(Air.total) />

					<cfif arrayIsEmpty(errorMessage)>
						<!--- Do a lowest refundable air price before air create for U6 --->
						<cfset local.refundableTrip = fw.getBeanFactory().getBean('AirPrice').doAirPrice( searchID = rc.searchID
																						, Account = rc.Account
																						, Policy = rc.Policy
																						, sCabin = Air.Class
																						, bRefundable = 1
																						, bRestricted = 0
																						, sFaresIndicator = "PublicAndPrivateFares"
																						, bAccountCodes = 1
																						, nTrip = Air.nTrip
																						, nCouldYou = 0
																						, bSaveAirPrice = 0
																						, findIt = rc.Filter.getFindIt()
																						, totalOnly = 1
																						, fullAirPrice = 0
																					)>
						<cfif NOT structIsEmpty(refundableTrip) AND NOT structKeyExists(refundableTrip, 'faultMessage')>
							<cfset Traveler.getBookingDetail().setAirRefundableFare(refundableTrip[structKeyList(refundableTrip)].Total) />
						</cfif>

						<!--- Check to see if this is a contracted Southwest flight --->
						<cfset local.contractedSWFlight = false />
						<cfif Air.platingCarrier IS 'WN'>
							<cfset local.privateCarriers = '' />
							<cfloop array="#rc.Account.Air_PF#" item="local.privateCarrier" index="local.privateCarrierIndex">
								<cfset privateCarriers = listAppend(privateCarriers, listGetAt(privateCarrier, 2)) />
							</cfloop>

							<!--- If the account policy has Southwest listed as a private fare --->
							<cfif listFindNoCase(privateCarriers, 'WN')>
								<cfset local.contractedSWFlight = true />
							</cfif>
						</cfif>

						<cfset Traveler.getBookingDetail().setAirLowestPublicFare(Air.total) />
						<!--- If private fare, do a lowest public air price before air create for U12 --->
						<!--- If a contracted Southwest flight, do a lowest private air price for U12 --->
						<cfif (Air.privateFare AND Air.platingCarrier IS NOT 'WN') OR contractedSWFlight>
							<cfset local.faresIndicator = 'PublicFaresOnly' />
							<cfif contractedSWFlight>
								<cfset local.faresIndicator = 'PrivateFaresOnly' />
							</cfif>

							<cfset local.lowestPublicTrip = fw.getBeanFactory().getBean('AirPrice').doAirPrice( searchID = rc.searchID
																							, Account = rc.Account
																							, Policy = rc.Policy
																							, sCabin = Air.Class
																							, bRefundable = 0
																							, bRestricted = 0
																							, sFaresIndicator = faresIndicator
																							, bAccountCodes = 0
																							, nTrip = Air.nTrip
																							, nCouldYou = 0
																							, bSaveAirPrice = 0
																							, findIt = rc.Filter.getFindIt()
																							, bIncludeClass = 1
																							, totalOnly = 1
																							, fullAirPrice = 0
																						)>
							<cfif NOT structIsEmpty(lowestPublicTrip) AND NOT structKeyExists(lowestPublicTrip, 'faultMessage')>
								<cfset Traveler.getBookingDetail().setAirLowestPublicFare(lowestPublicTrip[structKeyList(lowestPublicTrip)].Total) />
							</cfif>
						</cfif>

						<cfif hostToken EQ ''>
							<cfset listAppend(errorMessage, 'Terminal - open session failed')>
							<cfset errorType = 'TerminalEntry.openSession'>
						<cfelse>
							<cfset local.LowestAir = session.searches[rc.searchID].stTrips[session.searches[rc.searchID].stLowFareDetails.aSortFare[1]] />

							<!--- Sell air --->
							<cfset local.airFOPID = Traveler.getBookingDetail().getAirFOPID() />
							<!--- Get last 4 digits of air payment card for U231 and card type for confirmation page --->
							<cfif NOT len(Traveler.getBookingDetail().getAirCCNumber())>
								<cfloop array="#Traveler.getPayment()#" index="local.paymentIndex" item="local.Payment">
									<cfif Payment.getAirUse()
										AND ((Payment.getBTAID() NEQ ''
											AND Traveler.getBookingDetail().getAirFOPID() EQ 'bta_'&Payment.getPCIID())
										OR (Payment.getFOPID() NEQ ''
											AND Traveler.getBookingDetail().getAirFOPID() EQ 'fop_'&Payment.getPCIID())
										OR (Payment.getFOPID() NEQ ''
											AND Traveler.getBookingDetail().getAirFOPID() EQ 'fop_-1'))>
										<cfset Traveler.getBookingDetail().setAirCCNumber(Payment.getAcctNum()) />
										<cfset Traveler.getBookingDetail().setAirCCType(Payment.getFopCode()) />
									</cfif>
								</cfloop>
							</cfif>
							<cfset local.cardNumber = right(Traveler.getBookingDetail().getAirCCNumber(), 4) />

							<cfset local.airResponse = fw.getBeanFactory().getBean('AirAdapter').create( targetBranch = rc.Account.sBranch
																										, bookingPCC = rc.Account.PCC_Booking
																										, Traveler = Traveler
																										, Profile = Profile
																										, Account = rc.Account
																										, Air = Air
																										, LowestAir = LowestAir
																										, bRefundable = bRefundable
																										, Filter = rc.Filter
																										, statmentInformation = statmentInformation
																										, udids = udids
																										, cardNumber = local.cardNumber
																										, profileFound = profileFound
																										, developer = (listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID()) ? true : false)
																										, airFOPID = local.airFOPID
																										, datetimestamp = local.datetimestamp
																										, token = local.token
																									 )>

							<cfset Air.ProviderLocatorCode = ''>
							<cfset Air.UniversalLocatorCode = ''>
							<cfset Air.SupplierLocatorCode = ''>
							<cfset Air.ReservationLocatorCode = ''>
							<cfset Air.PricingInfoKey = ''>
							<cfset Air.BookingTravelerKey = ''>
							<cfset Air.Total = 0>
							<cfset Air.BookingTravelerSeats = [] />

							<cfset Air.AirITNumber = '' />
							<!--- Add the plating carrier's air IT number, if one exists for this account --->
							<cfif structKeyExists(rc.Account, 'AirITNumbers') AND arrayLen(rc.Account.AirITNumbers)>
								<cfloop array="#rc.Account.AirITNumbers#" index="local.numberIndex" item="local.number">
									<cfif number.carrier EQ Air.PlatingCarrier>
										<cfset Air.AirITNumber = number.ITNumber />
									</cfif>
								</cfloop>
							</cfif>

							<!--- Parse sell results --->
							<cfset Air = fw.getBeanFactory().getBean('AirAdapter').parseAirRsp( Air = Air
																							, response = airResponse )>

							<!--- If the fare increased at AirCreate, cancel the PNR and run AirCreate one more time without the plating carrier --->
							<cfif Air.Total GT originalAirfare>
								<cfset local.runAgain = true />
								<cfif len(Air.UniversalLocatorCode)>
									<cfset cancelResponse = fw.getBeanFactory().getBean('UniversalAdapter').cancelUR( targetBranch = rc.Account.sBranch
																									, universalRecordLocatorCode = Air.UniversalLocatorCode
																									, Filter = rc.Filter
																									, Version = version )>
									<cfif NOT cancelResponse.status>
										<cfset local.runAgain = false />
									</cfif>
								</cfif>

								<cfif runAgain>
									<cfset local.airResponse = fw.getBeanFactory().getBean('AirAdapter').create( targetBranch = rc.Account.sBranch
																										, bookingPCC = rc.Account.PCC_Booking
																										, Traveler = Traveler
																										, Profile = Profile
																										, Account = rc.Account
																										, Air = Air
																										, LowestAir = LowestAir
																										, bRefundable = bRefundable
																										, bPlatingCarrier = 0
																										, Filter = rc.Filter
																										, statmentInformation = statmentInformation
																										, udids = udids
																										, cardNumber = local.cardNumber
																										, profileFound = profileFound
																										, developer = (listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID()) ? true : false)
																										, airFOPID = local.airFOPID
																										, datetimestamp = local.datetimestamp
																										, token = local.token
																									 )>

									<cfset Air = fw.getBeanFactory().getBean('AirAdapter').parseAirRsp( Air = Air
																							, response = airResponse
																							, runAgain = true )>
								<cfelse>
									<cfset arrayAppend( errorMessage, 'The price quoted is no longer available online. Please select another flight or contact us to complete your reservation.  Price was #dollarFormat(originalAirfare)# and now is #dollarFormat(Air.Total)#.' )>
								</cfif>
							</cfif>

							<!--- If Southwest, change KK segments to HK before queue
							Command = .IHK --->
							<!--- STM-2961: Confirm the segments before File Finishing --->
							<cfif Air.platingCarrier IS 'WN' AND len(Air.ProviderLocatorCode)>
								<cfset local.originalNumSegments = arrayLen(Air.PricingSolution.getSegment()) />
								<cfset local.responseNumSegments = 0 />
								<cfset local.confirmSegmentsError = false />
								<cfset local.checkSegmentStatusAgain = false />

								<!--- Sleep for two seconds before starting this process --->
								<cfset sleep(2000) />
								<!--- <cfset fw.getBeanFactory().getBean('UniversalAdapter').queuePlace( targetBranch = rc.Account.sBranch
																						, Filter = rc.Filter
																						, pccBooking = rc.Account.PCC_Booking
																						, providerLocatorCode = Air.ProviderLocatorCode )> --->

								<!--- Display PNR --->
								<cfset local.displayPNRResponse = fw.getBeanFactory().getBean('TerminalEntry').displayPNR( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, pnr = Air.ProviderLocatorCode
																										, searchID = rc.searchID )>

								<cfif NOT displayPNRResponse.error>
									<!--- STM-3845: Check the status of all segments before .IHK --->
									<!--- Check segment statuses --->
									<cfset local.checkSegmentStatusResponse = fw.getBeanFactory().getBean('TerminalEntry').checkSegmentStatus( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, searchID = rc.searchID )>

									<cfif isArray(checkSegmentStatusResponse.message)>
										<!--- Sample response:
										" 1 WN 36N 06AUG MSYATL KK1 815A 1245P WE"
										" 2 ARNK"
										" 3 WN 137N 07AUG ATLHOU KK1 635A 735A TH"
										" 4 WN1934N 07AUG HOUMSY KK1 820A 925A TH"
										"><" --->
										<cfloop array="#checkSegmentStatusResponse.message#" index="local.stTerminalText">
											<cfif isNumeric(left(trim(stTerminalText), 1)) AND findNoCase("ARNK", stTerminalText) EQ 0>
												<!--- Get rid of the first number and the "WN" text --->
												<cfset local.segmentStatus = removeChars(trim(stTerminalText), 1, 4) />
												<!--- Now get the fourth item in the list --->
												<cfset local.segmentStatus = listGetAt(trim(segmentStatus), 4, ' ') />
												<!--- Trim off the number from the status --->
												<cfset local.segmentStatus = removeChars(segmentStatus, 3, 1) />

												<cfif local.segmentStatus NEQ 'KK'>
													<cfif local.segmentStatus EQ 'UC'>
														<cfset confirmSegmentsError = true />
													<cfelseif local.segmentStatus EQ 'PN'>
														<cfset checkSegmentStatusAgain = true />
													</cfif>
													<cfbreak />
												</cfif>
											</cfif>
										</cfloop>
									<cfelse>
										<cfset confirmSegmentsError = true />
									</cfif>

									<cfif checkSegmentStatusAgain AND NOT confirmSegmentsError>
										<cfset sleep(2000) />

										<!--- When we see PN status, we need to do a TERMINAL COMMAND "I" before we display the record again. --->
										<cfset fw.getBeanFactory().getBean('TerminalEntry').ignorePNR( targetBranch = rc.Account.sBranch
																						, hostToken = hostToken
																						, searchID = rc.searchID )>

										<cfset sleep(2000) />

										<cfset local.displayPNRResponse = fw.getBeanFactory().getBean('TerminalEntry').displayPNR( targetBranch = rc.Account.sBranch
																						, hostToken = hostToken
																						, pnr = Air.ProviderLocatorCode
																						, searchID = rc.searchID )>
										<cfif NOT displayPNRResponse.error>
											<cfset local.checkSegmentStatusResponse = fw.getBeanFactory().getBean('TerminalEntry').checkSegmentStatus( targetBranch = rc.Account.sBranch
																												, hostToken = hostToken
																												, searchID = rc.searchID )>

											<cfif isArray(checkSegmentStatusResponse.message)>
												<cfloop array="#checkSegmentStatusResponse.message#" index="local.stTerminalText">
													<cfif isNumeric(left(trim(stTerminalText), 1)) AND findNoCase("ARNK", stTerminalText) EQ 0>
														<!--- Get rid of the first number and the "WN" text --->
														<cfset local.segmentStatus = removeChars(trim(stTerminalText), 1, 4) />
														<!--- Now get the fourth item in the list --->
														<cfset local.segmentStatus = listGetAt(trim(segmentStatus), 4, ' ') />
														<!--- Trim off the number from the status --->
														<cfset local.segmentStatus = removeChars(segmentStatus, 3, 1) />

														<cfif local.segmentStatus NEQ 'KK'>
															<cfif local.segmentStatus EQ 'UC'>
																<cfset confirmSegmentsError = true />
															<cfelseif local.segmentStatus EQ 'PN'>
																<cfset checkSegmentStatusAgain = true />
															</cfif>
															<cfbreak />
														</cfif>
													</cfif>
												</cfloop>
											<cfelse>
												<cfset confirmSegmentsError = true />
											</cfif>
										<cfelse>
											<cfset confirmSegmentsError = true />
										</cfif>
									</cfif>

									<cfif checkSegmentStatusAgain AND NOT confirmSegmentsError>
										<cfset sleep(2000) />

										<!--- When we see PN status, we need to do a TERMINAL COMMAND "I" before we display the record again. --->
										<cfset fw.getBeanFactory().getBean('TerminalEntry').ignorePNR( targetBranch = rc.Account.sBranch
																						, hostToken = hostToken
																						, searchID = rc.searchID )>

										<cfset sleep(2000) />

										<cfset local.displayPNRResponse = fw.getBeanFactory().getBean('TerminalEntry').displayPNR( targetBranch = rc.Account.sBranch
																						, hostToken = hostToken
																						, pnr = Air.ProviderLocatorCode
																						, searchID = rc.searchID )>
										<cfif NOT displayPNRResponse.error>
											<cfset local.checkSegmentStatusResponse = fw.getBeanFactory().getBean('TerminalEntry').checkSegmentStatus( targetBranch = rc.Account.sBranch
																												, hostToken = hostToken
																												, searchID = rc.searchID )>

											<cfif isArray(checkSegmentStatusResponse.message)>
												<cfloop array="#checkSegmentStatusResponse.message#" index="local.stTerminalText">
													<cfif isNumeric(left(trim(stTerminalText), 1)) AND findNoCase("ARNK", stTerminalText) EQ 0>
														<!--- Get rid of the first number and the "WN" text --->
														<cfset local.segmentStatus = removeChars(trim(stTerminalText), 1, 4) />
														<!--- Now get the fourth item in the list --->
														<cfset local.segmentStatus = listGetAt(trim(segmentStatus), 4, ' ') />
														<!--- Trim off the number from the status --->
														<cfset local.segmentStatus = removeChars(segmentStatus, 3, 1) />

														<cfif local.segmentStatus NEQ 'KK'>
															<cfset confirmSegmentsError = true />
															<cfbreak />
														</cfif>
													</cfif>
												</cfloop>
											<cfelse>
												<cfset confirmSegmentsError = true />
											</cfif>
										<cfelse>
											<cfset confirmSegmentsError = true />
										</cfif>
									</cfif>

 									<cfif NOT confirmSegmentsError>
										<!--- Confirm segments --->
										<cfset local.segmentResponse = fw.getBeanFactory().getBean('TerminalEntry').confirmSegments( targetBranch = rc.Account.sBranch
																											, hostToken = hostToken
																											, searchID = rc.searchID )>

										<cfif NOT segmentResponse.error>
											<!--- Confirm that the number of segments returned is not less than the number of segments contained in the original request --->
											<cfif arrayLen(segmentResponse.message)>
												<cfloop array="#segmentResponse.message#" index="local.segmentIndex" item="local.segment">
													<cfif isNumeric(left(trim(segment), 1))>
														<cfset responseNumSegments++ />
													</cfif>
												</cfloop>
											</cfif>
										</cfif>

										<cfif responseNumSegments LT originalNumSegments>
											<cfset confirmSegmentsError = true />
	 									</cfif>
 									</cfif>

									<cfif NOT confirmSegmentsError>
										<!--- Only need to T:R if a fare was stored --->
										<cfif Air.Total NEQ 0>
											<!--- T:R --->
											<cfset local.verifyStoredFareResponse = fw.getBeanFactory().getBean('TerminalEntry').verifyStoredFare( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, searchID = rc.searchID
																										, Air = Air
																										, airSelected = airSelected
																										, command = 'T:R' )>
										</cfif>

										<cfif Air.Total EQ 0 OR NOT verifyStoredFareResponse.error>
											<!--- Add received by STO.CONFIRMED.SEGMENTS line --->
											<cfset local.verifyStoredFareResponse = fw.getBeanFactory().getBean('TerminalEntry').addReceivedBy( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, userID = rc.Filter.getUserID()
																										, searchID = rc.searchID
																										, receivedBy = 'STO.CONFIRMED.SEGMENTS' )>

											<!--- E --->
											<cfset local.erRecordResponse = fw.getBeanFactory().getBean('TerminalEntry').erRecord( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, searchID = rc.searchID
																										, command = 'E' )>
											<!--- If error, E again --->
											<cfif erRecordResponse.error>
												<cfset local.erRecordResponse = fw.getBeanFactory().getBean('TerminalEntry').erRecord( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, searchID = rc.searchID
																										, command = 'E' )>
												<cfif erRecordResponse.error>
													<cfset confirmSegmentsError = true />
												</cfif>
											</cfif>
										<cfelse>
											<cfset confirmSegmentsError = true />
										</cfif>
									</cfif>
								<cfelse>
									<cfset confirmSegmentsError = true />
								</cfif>

								<cfif confirmSegmentsError>
									<cfset arrayAppend( errorMessage, 'The fare for the flight you found is no longer available. Please select another flight.' )>
									<cfset errorType = 'Air.confirmSegments' />
								</cfif>
							</cfif>

							<!--- Parse error --->
							<cfif (Air.UniversalLocatorCode EQ '')
								OR Air.error
								OR (Air.Total GT originalAirfare)>
								<cfif (Air.Total GT originalAirfare) OR (Air.error AND len(Air.UniversalLocatorCode))>
									<cfif len(Air.UniversalLocatorCode)>
										<cfset cancelResponse = fw.getBeanFactory().getBean('UniversalAdapter').cancelUR( targetBranch = rc.Account.sBranch
																									, universalRecordLocatorCode = Air.UniversalLocatorCode
																									, Filter = rc.Filter
																									, Version = version )>
										<cfif cancelResponse.status>
											<cfset fw.getBeanFactory().getBean('Purchase').cancelInvoice( searchID = rc.Filter.getSearchID()
																									, urRecloc = Air.UniversalLocatorCode )>
										</cfif>
									</cfif>
									<cfset arrayAppend( errorMessage, 'The price quoted is no longer available online. Please select another flight or contact us to complete your reservation.  Price was #dollarFormat(originalAirfare)# and now is #dollarFormat(Air.Total)#.' )>
								<cfelse>
									<cfset errorMessage = Air.messages>
								</cfif>
								<cfset errorType = 'Air'>
								<cfset Traveler.getBookingDetail().setAirConfirmation( '' )>
								<cfset Traveler.getBookingDetail().setSeats( '' )>
							<cfelse>
								<cfset universalLocatorCode = Air.UniversalLocatorCode>
								<cfset Traveler.getBookingDetail().setSeatAssignmentNeeded( Air.seatAssignmentNeeded )>
							</cfif>

							<!--- Update session with new Air record --->
							<cfset session.searches[rc.SearchID].stItinerary.Air = Air>
							<cfset providerLocatorCode = Air.ProviderLocatorCode>
							<cfset Traveler.getBookingDetail().setAirConfirmation(Air.SupplierLocatorCode) />
							<cfset Traveler.getBookingDetail().setSeats(Air.BookingTravelerSeats) />
							<!--- Update universal version --->
							<cfif providerLocatorCode NEQ ''>
								<cfset version++>
							</cfif>
						</cfif>
					</cfif>
				</cfif>

				<!--- Sell Vehicle --->
				<cfif vehicleSelected
					AND Traveler.getBookingDetail().getCarNeeded()
					AND arrayIsEmpty(errorMessage)>
					<cfset local.lowestRateOffered = session.searches[rc.searchID].lowestCarRate>
					<!--- Find the correct direct bill and corporate discount numbers --->
					<cfset local.directBillNumber = ''>
					<cfset local.corporateDiscountNumber = ''>
					<cfset local.directBillType = ''>
					<cfloop array="#Traveler.getPayment()#" index="local.paymentIndex" item="local.payment">
						<cfif payment.getCarUse() EQ 1>
							<cfif len(payment.getDirectBillNumber()) GT 0
								AND Traveler.getBookingDetail().getCarFOPID() EQ 'DB_'&payment.getDirectBillNumber()>
								<cfset directBillNumber = payment.getDirectBillNumber()>
								<cfset corporateDiscountNumber = payment.getCorporateDiscountNumber()>
								<cfset directBillType = payment.getDirectBillType()>
							<cfelseif len(payment.getCorporateDiscountNumber()) GT 0
								AND Traveler.getBookingDetail().getCarFOPID() EQ 'CD_'&payment.getCorporateDiscountNumber()>
								<cfset directBillNumber = ''>
								<cfset corporateDiscountNumber = payment.getCorporateDiscountNumber()>
								<cfset directBillType = payment.getDirectBillType()>
							</cfif>
						</cfif>
					</cfloop>
					<!--- If NASCAR National car rental with direct bill and loyalty card --->
					<cfif directBillType EQ 'ID'
							AND directBillNumber NEQ ''
							AND Vehicle.getVendorCode() IS 'ZL'
							AND Traveler.getBookingDetail().getCarFF() NEQ ''>
						<cfset local.specialCarReservation = true />
					</cfif>
					<cfset Traveler.getBookingDetail().setSpecialCarReservation(specialCarReservation) />
					<!--- Find arriving flight details --->
					<cfset local.carrier = ''>
					<cfset local.flightNumber = ''>
					<cfif isStruct(Air)>
						<cfloop collection="#Air.Groups[0].Segments#" index="local.segmentIndex" item="local.segment">
							<cfset carrier = segment.carrier>
							<cfset flightNumber = segment.flightNumber>
						</cfloop>
					</cfif>
					<!--- Sell vehicle --->
					<cfset local.vehicleResponse = fw.getBeanFactory().getBean('VehicleAdapter').create( targetBranch = rc.Account.sBranch
																										, bookingPCC = rc.Account.PCC_Booking
																										, Traveler = Traveler
																										, Profile = Profile
																										, Account = rc.Account
																										, Vehicle = Vehicle
																										, Filter = rc.Filter
																										, directBillNumber = directBillNumber
																										, corporateDiscountNumber = corporateDiscountNumber
																										, directBillType = directBillType
																										, carrier = carrier
																										, flightNumber = flightNumber
																										, statmentInformation = statmentInformation
																										, udids = udids
																										, providerLocatorCode = providerLocatorCode
																										, universalLocatorCode = universalLocatorCode
																										, version = version
																										, profileFound = profileFound
																										, lowestRateOffered = lowestRateOffered
																										, developer =  (listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID()) ? true : false)
																										, specialCarReservation = specialCarReservation
																									)>
					<cfset Vehicle.setProviderLocatorCode('')>
					<cfset Vehicle.setUniversalLocatorCode('')>
					<!--- Parse the vehicle --->
					<cfset Vehicle = fw.getBeanFactory().getBean('VehicleAdapter').parseVehicleRsp( Vehicle = Vehicle
																									, response = vehicleResponse )>
					<cfset Traveler.getBookingDetail().setCarConfirmation(Vehicle.getConfirmation()) />

					<!--- If the VERIFY ATFQ error occurs, do terminal commands to verify the stored fare, then do VehicleCreate again --->
					<cfif Vehicle.error>
						<!--- Display PNR --->
						<cfset local.displayPNRResponse = fw.getBeanFactory().getBean('TerminalEntry').displayPNR( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, pnr = providerLocatorCode
																										, searchID = rc.searchID )>
						<cfif NOT displayPNRResponse.error>
							<!--- T:R --->
							<cfset local.verifyStoredFareResponse = fw.getBeanFactory().getBean('TerminalEntry').verifyStoredFare( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, searchID = rc.searchID
																										, Air = Air
																										, airSelected = airSelected
																										, command = 'T:R' )>
							<cfif NOT verifyStoredFareResponse.error>
								<!--- ER --->
								<cfset local.erRecordResponse = fw.getBeanFactory().getBean('TerminalEntry').erRecord( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, searchID = rc.searchID )>
								<!--- If error, ER again --->
								<cfif erRecordResponse.error>
									<cfset local.erRecordResponse = fw.getBeanFactory().getBean('TerminalEntry').erRecord( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, searchID = rc.searchID )>

								</cfif>
								<cfif NOT erRecordResponse.error>
									<!--- Sell vehicle --->
									<cfset local.vehicleResponse = fw.getBeanFactory().getBean('VehicleAdapter').create( targetBranch = rc.Account.sBranch
																										, bookingPCC = rc.Account.PCC_Booking
																										, Traveler = Traveler
																										, Profile = Profile
																										, Account = rc.Account
																										, Vehicle = Vehicle
																										, Filter = rc.Filter
																										, directBillNumber = directBillNumber
																										, corporateDiscountNumber = corporateDiscountNumber
																										, directBillType = directBillType
																										, carrier = carrier
																										, flightNumber = flightNumber
																										, statmentInformation = statmentInformation
																										, udids = udids
																										, providerLocatorCode = providerLocatorCode
																										, universalLocatorCode = universalLocatorCode
																										, version = version
																										, profileFound = profileFound
																										, lowestRateOffered = lowestRateOffered
																										, developer =  (listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID()) ? true : false)
																										, specialCarReservation = specialCarReservation
																									)>
									<!--- Parse the vehicle --->
									<cfset Vehicle = fw.getBeanFactory().getBean('VehicleAdapter').parseVehicleRsp( Vehicle = Vehicle
																											, response = vehicleResponse )>
									<cfset Traveler.getBookingDetail().setCarConfirmation(Vehicle.getConfirmation()) />
								</cfif>
							</cfif>
						</cfif>
					</cfif>

					<!--- Parse error --->
					<cfif Vehicle.getUniversalLocatorCode() EQ ''>
						<cfset errorMessage = fw.getBeanFactory().getBean('UAPIFactory').load( rc.Account.TMC ).parseError( vehicleResponse )>
						<cfset errorType = 'Vehicle'>
					<cfelse>
						<cfset universalLocatorCode = Vehicle.getUniversalLocatorCode()>
					</cfif>
					<cfset providerLocatorCode = Vehicle.getProviderLocatorCode()>
					<!--- Update universal version --->
					<cfif providerLocatorCode NEQ ''>
						<cfset version++>
					</cfif>
					<!--- Update session with new Vehicle record --->
					<cfset session.searches[rc.SearchID].stItinerary.Vehicle = Vehicle>
				</cfif>

				<!--- Sell Hotel --->
				 <cfif hotelSelected
					AND Traveler.getBookingDetail().getHotelNeeded()
					AND arrayIsEmpty(errorMessage)>
					<!--- Sell hotel --->
					<cfset local.hotelFOPID = Traveler.getBookingDetail().getHotelFOPID() />
					<!--- If the hotel form of payment details were copied from air --->
					<cfif (NOT len(hotelFOPID) OR hotelFOPID EQ 0) AND isNumeric(Traveler.getBookingDetail().getAirFOPID())>
						<cfset local.hotelFOPID = Traveler.getBookingDetail().getAirFOPID() />
					</cfif>

					<!--- Get last 4 digits of hotel payment card and card type for confirmation page --->
					<cfif NOT len(Traveler.getBookingDetail().getHotelCCNumber())>
						<cfloop array="#Traveler.getPayment()#" index="local.paymentIndex" item="local.Payment">
							<cfif Payment.getHotelUse()
								AND ((Payment.getBTAID() NEQ ''
									AND Traveler.getBookingDetail().getHotelFOPID() EQ 'bta_'&Payment.getPCIID())
								OR (Payment.getFOPID() NEQ ''
									AND Traveler.getBookingDetail().getHotelFOPID() EQ 'fop_'&Payment.getPCIID())
								OR (Payment.getFOPID() NEQ ''
									AND Traveler.getBookingDetail().getHotelFOPID() EQ 'fop_-1'))>
								<cfset Traveler.getBookingDetail().setHotelCCNumber(Payment.getAcctNum()) />
								<cfset Traveler.getBookingDetail().setHotelCCType(Payment.getFopCode()) />
								<cfset Traveler.getBookingDetail().setHotelCCName(Payment.getFopDescription()) />
							</cfif>
						</cfloop>
					</cfif>

					<cfset Hotel.setProviderLocatorCode('')>
					<cfset Hotel.setUniversalLocatorCode('')>
					<cfset Hotel.setPassiveLocatorCode('')>
					<cfset Hotel.setPassiveSegmentRef('')>
					<cfset Hotel.setProviderReservationInfoRef('')>

					<!--- If a Priceline hotel --->
					<cfif Hotel.getRooms()[1].getAPISource() EQ "Priceline" AND len(Hotel.getRooms()[1].getPPNBundle())>
						<cfset local.hotelResponse = fw.getBeanFactory().getBean('PPNHotelAdapter').book( Traveler = Traveler
																										, Profile = Profile
																										, Hotel = Hotel
																										, Filter = rc.Filter
																										, hotelFOPID = local.hotelFOPID
																										, datetimestamp = local.datetimestamp
																										, token = local.token
																									)>

						<!--- Parse book results --->
						<cfset Hotel = fw.getBeanFactory().getBean('PPNHotelAdapter').parseHotelRsp( Hotel = Hotel
																									, response = hotelResponse )>

						<cfif NOT Hotel.getError()>
							<cfset local.passiveResponse = fw.getBeanFactory().getBean('PassiveAdapter').create( targetBranch = rc.Account.sBranch
																											, bookingPCC = rc.Account.PCC_Booking
																											, airSelected = (airSelected AND Traveler.getBookingDetail().getAirNeeded() ? true : false)
																											, Traveler = Traveler
																											, Profile = Profile
																											, Account = rc.Account
																											, Hotel = Hotel
																											, Filter = rc.Filter
																											, statmentInformation = statmentInformation
																											, udids = udids
																											, providerLocatorCode = providerLocatorCode
																											, universalLocatorCode = universalLocatorCode
																											, version = version
																											, profileFound = profileFound
																											, developer = (listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID()) ? true : false)
																											, hotelFOPID = local.hotelFOPID
																											, datetimestamp = local.datetimestamp
																											, token = local.token
																										)>

							<!--- Parse passive create results --->
							<cfset Hotel = fw.getBeanFactory().getBean('PassiveAdapter').parseHotelRsp( Hotel = Hotel
																										, response = passiveResponse )>
						</cfif>
					<!--- If a Travelport hotel --->
					<cfelse>
						<cfset local.hotelResponse = fw.getBeanFactory().getBean('HotelAdapter').create( targetBranch = rc.Account.sBranch
																										, bookingPCC = rc.Account.PCC_Booking
																										, Traveler = Traveler
																										, Profile = Profile
																										, Account = rc.Account
																										, Hotel = Hotel
																										, Filter = rc.Filter
																										, statmentInformation = statmentInformation
																										, udids = udids
																										, providerLocatorCode = providerLocatorCode
																										, universalLocatorCode = universalLocatorCode
																										, version = version
																										, profileFound = profileFound
																										, developer =  (listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID()) ? true : false)
																										, hotelFOPID = local.hotelFOPID
																										, datetimestamp = local.datetimestamp
																										, token = local.token
																									)>
						<!--- Parse sell results --->
						<cfset Hotel = fw.getBeanFactory().getBean('HotelAdapter').parseHotelRsp( Hotel = Hotel
																								, response = hotelResponse )>

						<!--- If simultaneous changes occurred, clear the errors and run HotelCreate again --->
						<cfif Hotel.getSimultChgsError()>
							<cfset Hotel.setError( false ) />
							<cfset Hotel.setMessages( [] ) />
							<cfset Hotel.setSimultChgsError( false ) />

							<cfset local.hotelResponse = fw.getBeanFactory().getBean('HotelAdapter').create( targetBranch = rc.Account.sBranch
																											, bookingPCC = rc.Account.PCC_Booking
																											, Traveler = Traveler
																											, Profile = Profile
																											, Account = rc.Account
																											, Hotel = Hotel
																											, Filter = rc.Filter
																											, statmentInformation = statmentInformation
																											, udids = udids
																											, providerLocatorCode = providerLocatorCode
																											, universalLocatorCode = universalLocatorCode
																											, version = version
																											, profileFound = profileFound
																											, developer = (listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID()) ? true : false)
																											, hotelFOPID = local.hotelFOPID
																											, datetimestamp = local.datetimestamp
																											, token = local.token
																										)>

							<!--- Parse sell results --->
							<cfset Hotel = fw.getBeanFactory().getBean('HotelAdapter').parseHotelRsp( Hotel = Hotel
																									, response = hotelResponse )>
						</cfif>
					</cfif>

					<!--- Parse error --->
					<cfif Hotel.getUniversalLocatorCode() EQ '' OR Hotel.getError()>
						<cfset errorMessage = Hotel.getMessages()>
						<cfset errorType = 'Hotel'>
						<cfset Traveler.getBookingDetail().setHotelConfirmation('') />
					<cfelse>
						<cfset universalLocatorCode = Hotel.getUniversalLocatorCode()>
						<cfset providerLocatorCode = Hotel.getProviderLocatorCode()>
						<cfset Traveler.getBookingDetail().setHotelConfirmation(Hotel.getConfirmation()) />
					</cfif>

					<!--- Update session with new Hotel record --->
					<cfset session.searches[rc.SearchID].stItinerary.Hotel = Hotel>
					<!--- Update universal version --->
					<cfif Hotel.getProviderLocatorCode() NEQ ''>
						<cfset version++>
					</cfif>

				</cfif>
				<cfset Traveler.getBookingDetail().setReservationCode(providerLocatorCode) />

				<!--- For unknown reasons, occasionally a blank record locator goes all the way to the confirmation page --->
				<cfif len(trim(universalLocatorCode))>
					<cfset Traveler.getBookingDetail().setUniversalLocatorCode( universalLocatorCode ) />
				<cfelseif arrayIsEmpty(errorMessage)>
					<cfset errorType = 'Misc' />
					<cfset arrayAppend( errorMessage, 'The system encountered a connectivity issue. Please try again or contact us to complete your reservation.' ) />
				</cfif>

				<cfif arrayIsEmpty(errorMessage)>

					<!--- Short's Travel/Internal TMCs only --->
					<cfif NOT rc.Account.tmc.getIsExternal()>
						<cfset fw.getBeanFactory().getBean('UniversalAdapter').queuePlace( targetBranch = rc.Account.sBranch
																						, Filter = rc.Filter
																						, pccBooking = rc.Account.PCC_Booking
																						, providerLocatorCode = providerLocatorCode  )>
					</cfif>

					<cfset local.threadName = 'purchase#rc.searchID##minute(now())##second(now())#'>
					<cfthread
						name="#threadName#"
						action="run"
						targetBranch="#rc.Account.sBranch#"
						hostToken="#hostToken#"
						pccBooking="#rc.Account.PCC_Booking#"
						providerLocatorCode="#providerLocatorCode#"
						searchID="#rc.searchID#"
						airSelected="#airSelected#"
						hotelSelected="#hotelSelected#"
						vehicleSelected="#vehicleSelected#"
						Traveler="#Traveler#"
						Filter="#rc.Filter#"
						lowestCarRate="#(structKeyExists(session.searches[rc.searchID], 'lowestCarRate') ? session.searches[rc.searchID].lowestCarRate : 0)#"
						Air="#Air#"
						Hotel="#Hotel#"
						statmentInformation="#statmentInformation#"
						developer="#(listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID()) ? true : false)#"
						version="#version#"
						Account="#rc.Account#">

						<cfset fw.getBeanFactory().getBean('Purchase').fileFinishing( targetBranch = arguments.targetBranch
																					, hostToken = arguments.hostToken
																					, pccBooking = arguments.pccBooking
																					, providerLocatorCode = arguments.providerLocatorCode
																					, searchID = arguments.searchID
																					, airSelected = arguments.airSelected
																					, hotelSelected = arguments.hotelSelected
																					, vehicleSelected = arguments.vehicleSelected
																					, Traveler = arguments.Traveler
																					, Filter = arguments.Filter
																					, lowestCarRate = arguments.lowestCarRate
																					, Air = arguments.Air
																					, Hotel = arguments.Hotel
																					, statmentInformation = arguments.statmentInformation
																					, developer =  arguments.developer
																					, version = arguments.version
																					, Account = arguments.Account )>

					</cfthread>

				<!--- Sign out of session if error or normal purchase flow --->
				<cfelseif hostToken NEQ ''>
					<cfset fw.getBeanFactory().getBean('TerminalEntry').closeSession( targetBranch = rc.Account.sBranch
																									, hostToken = hostToken
																									, searchID = rc.searchID )>
				</cfif>

				<cfif arrayIsEmpty(errorMessage)>
					<!--- Save profile to database --->
					<cfif Traveler.getBookingDetail().getSaveProfile()>
						<cfset fw.getBeanFactory().getBean('UserService').saveProfile( User = Traveler
																						, OriginalUser = Profile
																						, Account = rc.Account
																						, acctID = rc.Filter.getAcctID()
																						, searchID = rc.searchID )>
					</cfif>
					<!--- Create profile in database --->
					<cfif Traveler.getBookingDetail().getCreateProfile() AND Traveler.getUserID() EQ 0>
						<cfset rc.Filter.setUserID(fw.getBeanFactory().getBean('UserService').createProfile( User = Traveler
																						, Account = rc.Account
																						, acctID = rc.Filter.getAcctID()
																						, searchID = rc.searchID )) />
					</cfif>

					<cfset fw.getBeanFactory().getBean('Purchase').databaseInvoices( Traveler = Traveler
																					, itinerary = itinerary
																					, Filter = rc.Filter
																					, Account = rc.Account )>

				<cfelse>
					<cfset fw.getBeanFactory().getBean('UAPIFactory').load( rc.Account.TMC ).databaseErrors( errorMessage = errorMessage
																				, searchID = rc.searchID
																				, errorType = errorType )>
					<cfset local.message = fw.getBeanFactory().getBean('Purchase').getErrorMessage( errorMessage = errorMessage
																							, errorContact = rc.Account.Error_Contact )>
					<cfset local.errorList = message>
					<!--- If account has Purchase Error Contact Info in STO Admin --->
					<cfif len(rc.Account.Error_Contact)>
						<cfset errorList = listAppend(errorList, rc.Account.Error_Contact)>
					</cfif>
					<cfif rc.Filter.getSTMEmployee()
						OR listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID())>
						<cfset errorList = listAppend(errorList, arrayToList(errorMessage))>
					</cfif>
					<cfif errorType EQ 'Hotel'
						AND (find('NEED GUEST CREDIT CARD IN CARD DEPOSIT FORMAT TO BOOK', errorList)
						OR find('INVALID /G- TYPE OR FORMAT', errorList)
						OR find('INVALID NEED DEPOSIT IN /G- FIELD', errorList)
						OR find('INVALID GUARANTEE INDICATOR', errorList)
						OR find('DEPOSIT REQ', errorList)
						OR find('NEED GUEST CREDIT CARD IN CARD DEPOSIT', errorList))>
						<cfset session.searches[rc.searchID].stItinerary.Hotel.getRooms()[1].setDepositRequired( true )>
					</cfif>
					<cfset rc.message.addError(errorList)>
					<cfset variables.fw.redirect('summary?searchID=#rc.searchID#')>
				</cfif>
			</cfif>
		</cfloop>

		<cfif arrayIsEmpty(errorMessage)>
			<cfloop collection="#session.searches[rc.searchID].Travelers#" index="local.travelerNumber" item="local.Traveler">
				<cfset Traveler.getBookingDetail().setPurchaseCompleted( true )>
			</cfloop>
			<cfset variables.fw.redirect('confirmation?searchID=#rc.searchID#')>
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="cancel" output="false">
		<cfargument name="rc">

		<cfset local.cancelResponse.status = false>
		<cfset cancelResponse.message = ''>
		<cfif structKeyExists(session.searches[rc.searchID], 'Travelers')>
			<cfloop collection="#session.searches[rc.searchID].Travelers#" index="local.travelerNumber" item="local.Traveler">
				<cfif Traveler.getBookingDetail().getUniversalLocatorCode() NEQ ''>
					<cfset cancelResponse = fw.getBeanFactory().getBean('UniversalAdapter').cancelUR( targetBranch = rc.Account.sBranch
																									, universalRecordLocatorCode = Traveler.getBookingDetail().getUniversalLocatorCode()
																									, Filter = rc.Filter
																									, Version = Traveler.getBookingDetail().getVersion() )>
					<cfif cancelResponse.status>
						<cfset cancelResponse.message = listPrepend(cancelResponse.message, 'Reservation has successfully been cancelled.')>


						<cfset fw.getBeanFactory().getBean('Purchase').cancelInvoice( searchID = rc.Filter.getSearchID()
																					, urRecloc = Traveler.getBookingDetail().getUniversalLocatorCode() )>

						<cfset Traveler.getBookingDetail().setUniversalLocatorCode( '' )>

					</cfif>
					<cfif cancelResponse.message NEQ ''>
						<cfset rc.message.addError(cancelResponse.message)>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>

		<cfset variables.fw.redirect('confirmation?searchID=#rc.searchID#&cancelled=#cancelResponse.status#')>

	</cffunction>

	<!--- For manual cancellations --->
	<!--- <cffunction name="cancel" output="false">
		<cfargument name="rc">

		<cfset local.cancelResponse.status = false>
		<cfset cancelResponse.message = ''>

		<cfset cancelResponse = fw.getBeanFactory().getBean('UniversalAdapter').cancelUR( targetBranch = rc.Account.sBranch
																						, universalRecordLocatorCode = "LRNBUQ"
																						, Filter = rc.Filter
																						, Version = "0" )>
		<cfif cancelResponse.status>
			<cfset cancelResponse.message = listPrepend(cancelResponse.message, 'Reservation has successfully been cancelled.')>


			<cfset fw.getBeanFactory().getBean('Purchase').cancelInvoice( searchID = "451998"
																		, urRecloc = "LRNBUQ" )>

			<!--- <cfset Traveler.getBookingDetail().setUniversalLocatorCode( '' )> --->

		</cfif>
		<cfif cancelResponse.message NEQ ''>
			<cfset rc.message.addError(cancelResponse.message)>
		</cfif>

		<cfset variables.fw.redirect('confirmation?searchID=451998&cancelled=#cancelResponse.status#')>

	</cffunction> --->

	<!--- <cffunction name="cancelPPN" output="false">
		<cfargument name="rc" />

		<cfset local.cancelResponse.status = false />
		<cfset local.cancelResponse.message = "" />
		<cfset local.assistanceNeeded = false />

		<!--- Retrieve the universal record version --->
		<cfset local.urVersion = fw.getBeanFactory().getBean("UniversalAdapter").retrieveUR( targetBranch = "P1601405"
																							, urLocatorCode = "ASFF83"
																							, searchID = "453111"
																							, acctID = "1"
																							, userID = "443" )>

		<cfif isNumeric(local.urVersion)>
			<!--- Cancel the passive segment --->
			<cfset local.cancelPassiveResponse = fw.getBeanFactory().getBean("PassiveAdapter").cancelPassive( targetBranch = "P1601405"
																											, urLocatorCode = "ASFF83"
																											, providerLocatorCode = "KCR63Q"
																											, passiveLocatorCode = "JU20DE"
																											, passiveSegmentRef = "jHXhw2HmTASCmcgXZqLZ6A=="
																											, version = local.urVersion
																											, searchID = "453111"
																											, acctID = "1"
																											, userID = "443" )>
		</cfif>

		<cfset variables.fw.redirect('confirmation?searchID=453729&hotelCancelled=true')>

	</cffunction> --->

	<cffunction name="cancelPPN" output="false">
		<cfargument name="rc" />

		<cfset local.cancelResponse.status = false />
		<cfset local.cancelResponse.message = "" />
		<cfset local.assistanceNeeded = false />

		<cfset local.invoice = fw.getBeanFactory().getBean("Purchase").retrieveInvoice( searchID = arguments.rc.searchID ) />

		<cfif isQuery(invoice) AND invoice.recordCount AND len(invoice.passiveRecloc)>
			<cfset local.Hotel = deserializeJSON(invoice.hotelSelection) />
			<cfset local.Filter = deserializeJSON(invoice.filter) />
			<cfset local.Traveler = deserializeJSON(invoice.traveler) />
			<cfset local.BookingDetail = deserializeJSON(invoice.bookingDetail) />

			<!--- Four possible cancellation scenarios after an invoice is retrieved
			1. getCancel successful, PassiveCancelReq successful, UniversalRecordModifyReq successful
				User gets success message, no additional queueing needed
			2. getCancel successful, PassiveCancelReq successful, UniversalRecordModifyReq unsuccessful
				User gets success message, no additional queueing needed
			3. getCancel successful, PassiveCancelReq unsuccessful, UniversalRecordModifyReq unsuccessful
				User gets success message, queue to 34*CQC
			4. getCancel unsuccessful, PassiveCancelReq unsuccessful, UniversalRecordModifyReq unsuccessful
				User gets failed message --->

			<!--- Cancel the Priceline reservation --->
			<cfset local.cancelResponse = fw.getBeanFactory().getBean("PPNHotelAdapter").cancel( Hotel = Hotel
																								, Filter = Filter )>
			<cfif cancelResponse.status>
				<!--- Retrieve the universal record version --->
				<cfset local.urVersion = fw.getBeanFactory().getBean("UniversalAdapter").retrieveUR( targetBranch = invoice.targetBranch
																									, urLocatorCode = invoice.urRecloc
																									, searchID = invoice.searchID
																									, acctID = Filter.acctID
																									, userID = invoice.userID )>

				<cfif isNumeric(local.urVersion)>
					<!--- Cancel the passive segment --->
					<cfset local.cancelPassiveResponse = fw.getBeanFactory().getBean("PassiveAdapter").cancelPassive( targetBranch = invoice.targetBranch
																													, urLocatorCode = invoice.urRecloc
																													, providerLocatorCode = invoice.recloc
																													, passiveLocatorCode = invoice.passiveRecloc
																													, passiveSegmentRef = invoice.passiveSegmentRef
																													, version = local.urVersion
																													, searchID = invoice.searchID
																													, acctID = Filter.acctID
																													, userID = invoice.userID )>

					<cfif cancelPassiveResponse.status>
						<cfset local.urVersion++ />

						<!--- Modify the universal record --->
						<cfset local.modifyURResponse = fw.getBeanFactory().getBean("UniversalAdapter").modifyUR( targetBranch = invoice.targetBranch
																												, urLocatorCode = invoice.urRecloc
																												, providerLocatorCode = invoice.recloc
																												, providerReservationInfoRef = invoice.providerReservationInfoRef
																												, categoryType = "A"
																												, ppnTripID = Hotel.ppnTripID
																												, username = Filter.username
																												, version = local.urVersion
																												, searchID = invoice.searchID
																												, acctID = Filter.acctID
																												, userID = invoice.userID )>

						<!--- Per FH-22: The invoice cancellation fee functionality is no longer needed right now --->
						<!--- Get agent touch fee --->
						<!--- <cfset local.agentTouchFee = fw.getBeanFactory().getBean("AccountService").getAgentTouchFee( acctID = Filter.acctID )>

						<!--- Open terminal session --->
						<cfset local.hostToken = fw.getBeanFactory().getBean("TerminalEntry").openSession( targetBranch = invoice.targetBranch
																											, searchID = invoice.searchID )>

						<cfif hostToken EQ ''>
							<cfset arrayAppend(errorMessage, 'Terminal - open session failed')>
							<cfset errorType = 'TerminalEntry.openSession'>
						<cfelse>
							<!--- Invoice service fee --->
							<cfset local.serviceFeeResponse = fw.getBeanFactory().getBean("TerminalEntry").invoiceServiceFee( targetBranch = invoice.targetBranch
																															, hostToken = hostToken
																															, searchID = invoice.searchID )>

							<cfset fw.getBeanFactory().getBean("TerminalEntry").closeSession( targetBranch = invoice.targetBranch
																							, hostToken = hostToken
																							, searchID = invoice.searchID )>
						</cfif> --->

						<!--- <cfset cancelResponse.message = listPrepend(cancelResponse.message, "Reservation has successfully been cancelled.") /> --->

						<!--- <cfif NOT modifyURResponse.status>
							<cfset assistanceNeeded = true />
						</cfif> --->
					<cfelse>
						<cfset assistanceNeeded = true />
					</cfif>
				<cfelse>
					<cfset assistanceNeeded = true />
				</cfif>

				<cfif assistanceNeeded>
					<!--- Modify the universal record --->
					<cfset local.modifyURResponse = fw.getBeanFactory().getBean("UniversalAdapter").modifyUR( targetBranch = invoice.targetBranch
																											, urLocatorCode = invoice.urRecloc
																											, providerLocatorCode = invoice.recloc
																											, providerReservationInfoRef = invoice.providerReservationInfoRef
																											, categoryType = "Q"
																											, ppnTripID = Hotel.ppnTripID
																											, username = Filter.username
																											, version = local.urVersion
																											, searchID = invoice.searchID
																											, acctID = Filter.acctID
																											, userID = invoice.userID )>
					<!--- Queue to 34*CQC --->
					<cfif modifyURResponse.status>
						<cfset local.account = fw.getBeanFactory().getBean("AccountService").load( accountID = Filter.acctID
																								, returnType = "query" )>
						<cfset local.pccBooking = account.PCC_Booking />
						<cfset fw.getBeanFactory().getBean("UniversalAdapter").queuePlace( targetBranch = invoice.targetBranch
																							, Filter = Filter
																							, pccBooking = local.pccBooking
																							, providerLocatorCode = invoice.recloc
																							, queue = "34"
																							, category = "QC" )>
					</cfif>
				</cfif>

				<!--- The reservation has been successfully cancelled with Priceline; cancel the invoice --->
				<cfif invoice.air EQ 0 AND invoice.car EQ 0>
					<cfset fw.getBeanFactory().getBean("Purchase").cancelInvoice( searchID = invoice.searchID
																				, urRecloc = invoice.urRecloc ) />
				</cfif>

				<cfset structDelete(session.searches[invoice.searchID].stItinerary, "Hotel") />
				<cfset session.searches[invoice.searchID].Travelers[1].getBookingDetail().setBookingFee(0) />

				<!--- Send the traveler a cancellation email --->
				<cfset fw.getBeanFactory().getBean("Email").cancelEmail( email = Traveler.email
																		, ppnTripID = Hotel.ppnTripID
																		, propertyName = Hotel.propertyName )>
			</cfif>
		<cfelse>
			<cfset cancelResponse.message = listPrepend(cancelResponse.message, "We were unable to retrieve your reservation.") />
		</cfif>

		<cfif cancelResponse.message NEQ "">
			<cfset rc.message.addError(cancelResponse.message) />
		</cfif>

		<cfset variables.fw.redirect('confirmation?searchID=#rc.searchID#&hotelCancelled=#cancelResponse.status#')>

	</cffunction>

</cfcomponent>