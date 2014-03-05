<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfset local.errorMessage = []> <!--- variable used to display an error on the summary page to the traveler --->
		<cfset local.errorType = ''> <!--- air, car, hotel, terminal, etc --->
			
		<cfloop collection="#session.searches[rc.searchID].Travelers#" index="local.travelerNumber" item="local.Traveler">
			<cfif arrayIsEmpty(errorMessage)
				AND NOT Traveler.getBookingDetail().getPurchaseCompleted()>
				<cfset local.providerLocatorCode = ''>
				<cfset local.universalLocatorCode = ''>
				<!--- Based on the "The parameter userID to function loadBasicUser is required but was not passed in." error that was being generated on occasion, checking first to see if the userID has a value. --->
				<cfif NOT len(Traveler.getUserID()) OR NOT isNumeric(Traveler.getUserID())>
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
				<!--- Version needs to be set and updated based on how many times the universal record is used. --->
				<cfset local.version = -1>
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
				</cfif>

				<!--- If new air or hotel credit card entered, make airFOPID or hotelFOPID EQ 0. --->
				<cfif Traveler.getBookingDetail().getNewAirCC() EQ 1>
					<cfset Traveler.getBookingDetail().setAirFOPID(0) />
				</cfif>
				<cfif Traveler.getBookingDetail().getNewHotelCC() EQ 1>
					<cfset Traveler.getBookingDetail().setHotelFOPID(0) />
				</cfif>

				<!--- Determine if pre trip approval is needed. --->
				<cfset local.approval = fw.getBeanFactory().getBean('Summary').determineApproval( Policy = rc.Policy
																								, Filter = rc.Filter
																								, Traveler = Traveler )>
				<cfset Traveler.getBookingDetail().setApprovalNeeded( approval.approvalNeeded )>
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

						<cfif NOT structKeyExists(Air, 'PricingSolution')
						OR NOT isObject(Air.PricingSolution)>

						<cfset local.originalAirfare = Air.Total />
						<cfset local.trip = fw.getBeanFactory().getBean('AirPrice').doAirPrice( searchID = rc.searchID
																							, Account = rc.Account
																							, Policy = rc.Policy
																							, sCabin = Air.Class
																							, bRefundable = bRefundable
																							, bRestricted = 0
																							, sFaresIndicator = "PublicAndPrivateFares"
																							, bAccountCodes = 1
																							, nTrip = Air.nTrip
																							, nCouldYou = 0
																							, bSaveAirPrice = 1
																							, findIt = rc.Filter.getFindIt()
																							, bIncludeClass = 1
																							, bIncludeCabin = 1
																							, totalOnly = 0
																							, bIncludeBookingCodes = 1
																						)>						
						<cfif structIsEmpty(trip)>
							<cfset arrayAppend( errorMessage, 'Could not price record.' )>
							<cfset errorType = 'Air.airPrice'>
						<cfelseif NOT structKeyExists(trip, 'faultMessage') AND trip[structKeyList(trip)].Total EQ originalAirfare>
							<cfset local.nTrip = Air.nTrip>
							<cfset local.aPolicies = Air.aPolicies>
							<cfset local.policy = Air.policy>
							<cfset Air = trip[structKeyList(trip)]>
							<cfset Air.nTrip = nTrip>
							<cfset Air.aPolicies = aPolicies>
							<cfset Air.policy = policy>
						<cfelse>
							<cfset arrayAppend( errorMessage, 'The price quoted is no longer available online. Please select another flight, or contact us to complete your reservation.' )>
							<cfset errorType = 'Air.airPrice'>
						</cfif>

						<cfset Traveler.getBookingDetail().setAirRefundableFare(Air.total) />
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
																						)>
							<cfif NOT structIsEmpty(lowestPublicTrip) AND NOT structKeyExists(lowestPublicTrip, 'faultMessage')>
								<cfset Traveler.getBookingDetail().setAirLowestPublicFare(lowestPublicTrip[structKeyList(lowestPublicTrip)].Total) />
							</cfif>
						</cfif>
					</cfif>

					<cfif arrayIsEmpty(errorMessage)>

						<!--- Parse credit card information --->
						<cfset local.cardNumber = ''>
						<cfset local.cardCVV = ''>
						<cfset local.cardExpiration = ''>
						<cfset local.cardType = 'VI'>
						<cfif Traveler.getBookingDetail().getAirFOPID() EQ 0 OR Traveler.getBookingDetail().getNewAirCC() EQ 1>
							<cfset cardNumber = Traveler.getBookingDetail().getAirCCNumber()>
							<cfset cardCVV = Traveler.getBookingDetail().getAirCCCVV()>
							<cfset cardExpiration = Traveler.getBookingDetail().getAirCCYear()&'-'&numberFormat(Traveler.getBookingDetail().getAirCCMonth(), '00')>
						<cfelse>
							<cfloop array="#Traveler.getPayment()#" index="local.paymentIndex" item="local.Payment">
								<cfif Payment.getAirUse()
									AND ((Payment.getBTAID() NEQ ''
										AND Traveler.getBookingDetail().getAirFOPID() EQ 'bta_'&Payment.getBTAID())
									OR (Payment.getFOPID() NEQ ''
										AND Traveler.getBookingDetail().getAirFOPID() EQ 'fop_'&Payment.getFOPID())
									OR (Payment.getFOPID() NEQ ''
										AND Traveler.getBookingDetail().getAirFOPID() EQ 'fop_-1'))>
									<cfset cardNumber = fw.getBeanFactory().getBean('PaymentService').decryption( Payment.getAcctNum() )>
									<cfif NOT isDate(Payment.getExpireDate())>
										<cfset Payment.setExpireDate( fw.getBeanFactory().getBean('PaymentService').decryption( Payment.getExpireDate() ) )>
										<cfset Payment.setExpireDate( createDate( right(Payment.getExpireDate(), 4), left(Payment.getExpireDate(), 2), mid(Payment.getExpireDate(), 3, 2)) )>
									</cfif>
									<cfset cardExpiration = dateFormat(Payment.getExpireDate(), 'yyyy-mm')>
									<cfset Traveler.getBookingDetail().setAirCCNumber(cardNumber) />
								</cfif>
							</cfloop>
						</cfif>
						<cfif LEFT(cardNumber, 1) EQ 5>
							<cfset cardType = 'CA'>
						<cfelseif LEFT(cardNumber, 1) EQ 6>
							<cfset cardType = 'DS'>
						<cfelseif LEFT(cardNumber, 1) EQ 3>
							<cfset cardType = 'AX'>
						</cfif>
						
						<cfif hostToken EQ ''>
							<cfset listAppend(errorMessage, 'Terminal - open session failed')>
							<cfset errorType = 'TerminalEntry.openSession'>
						<cfelse>
							<cfset local.LowestAir = session.searches[rc.searchID].stTrips[session.searches[rc.searchID].stLowFareDetails.aSortFare[1]] />

							<!--- Sell air --->
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
																										, cardNumber = cardNumber
																										, cardType = cardType
																										, cardExpiration = cardExpiration
																										, cardCVV = cardCVV
																										, profileFound = profileFound
																										, developer =  (listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID()) ? true : false)
																									 )>

							<cfset Air.ProviderLocatorCode = ''>
							<cfset Air.UniversalLocatorCode = ''>
							<cfset Air.ReservationLocatorCode = ''>
							<cfset Air.BookingTravelerSeats = [] />

							<!--- Parse sell results --->
							<cfset Air = fw.getBeanFactory().getBean('AirAdapter').parseAirRsp( Air = Air
																							, response = airResponse )>

							<!--- Parse error --->
							<cfif Air.UniversalLocatorCode EQ ''
								OR Air.error>

								<cfset errorMessage = Air.messages>
								<cfset errorType = 'Air'>
								<cfset Traveler.getBookingDetail().setAirConfirmation( '' )>
								<cfset Traveler.getBookingDetail().setSeats( '' )>
							<cfelse>
								<cfset universalLocatorCode = Air.UniversalLocatorCode>
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

				<!--- Sell Hotel --->
				 <cfif hotelSelected
					AND Traveler.getBookingDetail().getHotelNeeded()
					AND arrayIsEmpty(errorMessage)>
					<!--- Sell hotel --->
					<cfset local.hotelResponse = fw.getBeanFactory().getBean('HotelAdapter').create( targetBranch = rc.Account.sBranch 
																										, bookingPCC = rc.Account.PCC_Booking
																										, searchID = rc.searchID
																										, Traveler = Traveler
																										, Profile = Profile
																										, Hotel = Hotel
																										, Filter = rc.Filter
																										, statmentInformation = statmentInformation
																										, udids = udids
																										, providerLocatorCode = providerLocatorCode
																										, universalLocatorCode = universalLocatorCode
																										, version = version
																										, profileFound = profileFound
																										, developer =  (listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID()) ? true : false)
																									)>


					<cfset Hotel.setProviderLocatorCode('')>
					<cfset Hotel.setUniversalLocatorCode('')>

					<!--- Parse sell results --->
					<cfset Hotel = fw.getBeanFactory().getBean('HotelAdapter').parseHotelRsp( Hotel = Hotel
																							, response = hotelResponse )>


					<!--- Parse error --->
					<cfif Hotel.getUniversalLocatorCode() EQ ''
						OR Hotel.getError()>

						<cfset errorMessage = Hotel.getMessages()>
						<cfset errorType = 'Hotel'>
						<cfset Traveler.getBookingDetail().setHotelConfirmation('') />
					<cfelse>
						<cfset universalLocatorCode = Hotel.getUniversalLocatorCode()>
					</cfif>

					<!--- Update session with new Hotel record --->
					<cfset session.searches[rc.SearchID].stItinerary.Hotel = Hotel>
					<cfset providerLocatorCode = Hotel.getProviderLocatorCode()>
					<cfset Traveler.getBookingDetail().setHotelConfirmation(Hotel.getConfirmation()) />
					<!--- Update universal version --->
					<cfif providerLocatorCode NEQ ''>
						<cfset version++>
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
				<cfset Traveler.getBookingDetail().setReservationCode(providerLocatorCode) />

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

				<cfset Traveler.getBookingDetail().setUniversalLocatorCode( universalLocatorCode )>
				<cfif arrayIsEmpty(errorMessage)>
					<!--- Save profile to database --->
					<cfif Traveler.getBookingDetail().getSaveProfile()>
						<cfset fw.getBeanFactory().getBean('UserService').saveProfile( User = Traveler
																						, OriginalUser = Profile
																						, Account = rc.Account )>
					</cfif>
					<!--- Create profile in database --->
					<cfif Traveler.getBookingDetail().getCreateProfile() AND Traveler.getUserID() EQ 0>
						<cfset rc.Filter.setUserID(fw.getBeanFactory().getBean('UserService').createProfile( User = Traveler
																						, acctID = rc.Filter.getAcctID()
																						, Account = rc.Account )) />
					</cfif>

					<cfset fw.getBeanFactory().getBean('Purchase').databaseInvoices( Traveler = Traveler
																					, itinerary = itinerary
																					, Filter = rc.Filter )>

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

</cfcomponent>