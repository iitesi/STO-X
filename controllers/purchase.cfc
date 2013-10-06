<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfset local.errorMessage = []> <!--- variable used to display an error on the summary page to the traveler --->
		<cfset local.errorType = ''> <!--- air, car, hotel, terminal, etc --->
			
		<cfloop collection="#session.searches[rc.searchID].Travelers#" index="local.travelerNumber" item="local.Traveler">
			<cfif arrayIsEmpty(errorMessage)>
				<cfset local.providerLocatorCode = ''>
				<cfset local.universalLocatorCode = ''>
				<!--- Looks odd, but this is used to compare differences between their profile and what information
				they entered into the summary page. --->
				<cfset local.Profile = fw.getBeanFactory().getBean('UserService').loadBasicUser( userID = Traveler.getUserID() )>
				<cfset local.itinerary = session.searches[rc.searchID].stItinerary>
				<cfset local.airSelected = (structKeyExists(itinerary, 'Air') ? true : false)>
				<cfset local.Air = (structKeyExists(itinerary, 'Air') ? itinerary.Air : '')>
				<cfset local.hotelSelected = (structKeyExists(itinerary, 'Hotel') ? true : false)>
				<cfset local.Hotel = (structKeyExists(itinerary, 'Hotel') ? itinerary.Hotel : '')>
				<cfset local.vehicleSelected = (structKeyExists(itinerary, 'Vehicle') ? true : false)>
				<cfset local.Vehicle = (structKeyExists(itinerary, 'Vehicle') ? itinerary.Vehicle : '')>
				<!--- Version needs to be set and updated based on how many times the universal record is used. --->
				<cfset local.version = -1>
				
				<!--- Populate sort fields --->
				<cfset local.sort1 = ''>
				<cfset local.sort2 = ''>
				<cfset local.sort3 = ''>
				<cfset local.sort4 = ''>
				<cfloop array="#Traveler.getOrgUnit()#" index="local.orgUnitIndex" item="local.orgUnit">
					<cfif orgUnit.getOUType() EQ 'sort'>
						<cfset local['sort#orgUnit.getOUPosition()#'] = orgUnit.getValueReport()>
					</cfif>
				</cfloop>
				<cfset local.statmentInformation = sort1&' '&sort2&' '&sort3&' '&sort4>
				<cfset statmentInformation = trim(statmentInformation)>
				
				<!--- Determine if pre trip approval is needed. --->
				<cfset local.approval = fw.getBeanFactory().getBean('Summary').determineApproval( Policy = rc.Policy
																								, Filter = rc.Filter
																								, Traveler = Traveler )>
				<cfset Traveler.getBookingDetail().setApprovalNeeded( approval.approvalNeeded )>
				<cfset Traveler.getBookingDetail().setApprovers( approval.approvers )>

				<!--- Custom code for State of LA and LSU to book WN in another PCC/target branch --->
				<cfif (rc.Filter.getAcctID() EQ 254
					OR rc.Filter.getAcctID() EQ 255)
					AND Air.Carriers[1] EQ 'WN'>
					<cfset rc.Account.sBranch = 'P1601400'>
					<cfset rc.Account.PCC_Booking = '1H7M'>
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

				<!--- Sell Air --->
				<cfif airSelected
					AND Traveler.getBookingDetail().getAirNeeded()>

					<cfif NOT structKeyExists(Air, 'PricingSolution')
						OR NOT isObject(Air.PricingSolution)>
						<cfset local.trip = fw.getBeanFactory().getBean('AirPrice').doAirPrice( searchID = rc.searchID
																							, Account = rc.Account
																							, Policy = rc.Policy
																							, sCabin = Air.Class
																							, bRefundable = Air.Ref
																							, nTrip = Air.nTrip
																							, nCouldYou = 0
																							, bSaveAirPrice = 1
																							, findIt = rc.Filter.getFindIt()
																						)>
						<cfif structIsEmpty(trip)>
							<cfset arrayAppend( errorMessage, 'Could not price record.' )>
							<cfset errorType = 'Air.airPrice'>
						<cfelse>
							<cfset local.nTrip = Air.nTrip>
							<cfset local.aPolicies = Air.aPolicies>
							<cfset local.policy = Air.policy>
							<cfset Air = trip[structKeyList(trip)]>
							<cfset Air.nTrip = nTrip>
							<cfset Air.aPolicies = aPolicies>
							<cfset Air.policy = policy>
						</cfif>
					</cfif>

					<cfif arrayIsEmpty(errorMessage)>

						<!--- Parse credit card information --->
						<cfset local.cardNumber = ''>
						<cfset local.cardCVV = ''>
						<cfset local.cardExpiration = ''>
						<cfset local.cardType = 'VI'>
						<cfif Traveler.getBookingDetail().getAirFOPID() NEQ 0>
							<cfloop array="#Traveler.getPayment()#" index="local.paymentIndex" item="local.Payment">
								<cfif (Payment.getBTAID() NEQ ''
									AND Traveler.getBookingDetail().getAirFOPID() EQ 'bta_'&Payment.getBTAID())
									OR (Payment.getFOPID() NEQ ''
										AND Traveler.getBookingDetail().getAirFOPID() EQ 'fop_'&Payment.getFOPID())>
									<cfset cardNumber = fw.getBeanFactory().getBean('PaymentService').decryption( Payment.getAcctNum() )>
									<cfset cardExpiration = dateFormat(Payment.getExpireDate(), 'yyyy-mm')>
									<cfset Traveler.getBookingDetail().setAirCCNumber(cardNumber) />
								</cfif>
							</cfloop>
						<cfelse>
							<cfset cardNumber = Traveler.getBookingDetail().getAirCCNumber()>
							<cfset cardCVV = Traveler.getBookingDetail().getAirCCCVV()>
							<cfset cardExpiration = Traveler.getBookingDetail().getAirCCYear()&'-'&numberFormat(Traveler.getBookingDetail().getAirCCMonth(), '00')>
						</cfif>
						<cfif LEFT(cardNumber, 1) EQ 5>
							<cfset cardType = 'MC'>
						<cfelseif LEFT(cardNumber, 1) EQ 6>
							<cfset cardType = 'DS'>
						<cfelseif LEFT(cardNumber, 1) EQ 3>
							<cfset cardType = 'AX'>
						</cfif>
						<cfif cardNumber NEQ ''>
							<!--- Get credit card authorization --->
							<cfset local.authResponse = fw.getBeanFactory().getBean('TerminalEntry').getCCAuth( targetBranch = rc.Account.sBranch
																												, hostToken = hostToken
																												, Air = Air
																												, cardNumber = cardNumber
																												, cardType = cardType
																												, cardExpiration = cardExpiration
																												, searchID = rc.searchID)>
						<cfelse>
							<cfset authResponse.error = 0>
							<cfset authResponse.message = ''>
						</cfif>
						<cfif authResponse.error>
							<cfset arrayAppend( errorMessage, 'Credit card authorization error' )>
							<cfset errorType = 'TerminalEntry.getCCAuth'>
						<cfelse>
							<cfset local.cardAuth = ''>
							<cfif authResponse.message NEQ ''>
								<cfset cardAuth = authResponse.message>
							</cfif>
							<!--- Start new session due to credit card/emulation --->
							<cfset fw.getBeanFactory().getBean('TerminalEntry').closeSession( targetBranch = rc.Account.sBranch
																							, hostToken = hostToken
																							, searchID = rc.searchID )>
							<cfset local.hostToken = fw.getBeanFactory().getBean('TerminalEntry').openSession( targetBranch = rc.Account.sBranch
																											, searchID = rc.searchID )>
							
							<cfif hostToken EQ ''>
								<cfset listAppend(errorMessage, 'Terminal - open session failed')>
								<cfset errorType = 'TerminalEntry.openSession'>
							<cfelse>
								<!--- Sell air --->
								<cfset local.airResponse = fw.getBeanFactory().getBean('AirAdapter').create( targetBranch = rc.Account.sBranch 
																											, bookingPCC = rc.Account.PCC_Booking
																											, Traveler = Traveler
																											, Profile = Profile
																											, Account = rc.Account
																											, Air = Air
																											, Filter = rc.Filter
																											, statmentInformation = statmentInformation
																											, cardNumber = cardNumber
																											, cardType = cardType
																											, cardExpiration = cardExpiration
																											, cardCVV = cardCVV
																											, cardAuth = cardAuth
																											, profileFound = profileFound
																										 )>

								<cfset Air.ProviderLocatorCode = ''>
								<cfset Air.UniversalLocatorCode = ''>
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
								</cfif>

								<!--- Update session with new Air record --->
								<cfset session.searches[rc.SearchID].stItinerary.Air = Air>
								<cfset providerLocatorCode = Air.ProviderLocatorCode>
								<cfset universalLocatorCode = Air.UniversalLocatorCode>
								<cfset Traveler.getBookingDetail().setAirConfirmation(Air.SupplierLocatorCode) />
								<cfset Traveler.getBookingDetail().setSeats(Air.BookingTravelerSeats) />
								<!--- Update universal version --->
								<cfif providerLocatorCode NEQ ''>
									<cfset version++>
								</cfif>

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
																										, providerLocatorCode = providerLocatorCode
																										, universalLocatorCode = universalLocatorCode
																										, version = version
																										, profileFound = profileFound
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
					</cfif>

					<!--- Update session with new Air record --->
					<cfset session.searches[rc.SearchID].stItinerary.Hotel = Hotel>
					<cfset providerLocatorCode = Hotel.getProviderLocatorCode()>
					<cfset universalLocatorCode = Hotel.getUniversalLocatorCode()>
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
																										, providerLocatorCode = providerLocatorCode
																										, universalLocatorCode = universalLocatorCode
																										, version = version
																										, profileFound = profileFound
																										, lowestRateOffered = lowestRateOffered
																									)>
					<cfset Vehicle.setProviderLocatorCode('')>
					<cfset Vehicle.setUniversalLocatorCode('')>
					<!--- Parse the vehicle --->
					<cfset Vehicle = fw.getBeanFactory().getBean('VehicleAdapter').parseVehicleRsp( Vehicle = Vehicle
																									, response = vehicleResponse )>
					<cfset Traveler.getBookingDetail().setCarConfirmation(Vehicle.getConfirmation()) />
					<!--- Parse error --->
					<cfif Vehicle.getUniversalLocatorCode() EQ ''>
						<cfset errorMessage = fw.getBeanFactory().getBean('UAPI').parseError( vehicleResponse )>
						<cfset errorType = 'Vehicle'>
					</cfif>
					<cfset providerLocatorCode = Vehicle.getProviderLocatorCode()>
					<cfset universalLocatorCode = Vehicle.getUniversalLocatorCode()>
					<!--- Update session with new Hotel record --->
					<cfset session.searches[rc.SearchID].stItinerary.Vehicle = Vehicle>
				</cfif>
				<cfset Traveler.getBookingDetail().setReservationCode(providerLocatorCode) />
				<cfif arrayIsEmpty(errorMessage)>
					<!--- Pull up the PNR for the terminal entry commands --->
					<cfset local.responseMessage = fw.getBeanFactory().getBean('TerminalEntry').displayPNR( targetBranch = rc.Account.sBranch
																											, hostToken = hostToken
																											, pnr = providerLocatorCode
																											, searchID = rc.searchID )>
					<cfif responseMessage.error>
						<cfset errorMessage = responseMessage.message>
						<cfset errorType = 'TerminalEntry.displayPNR'>
					<cfelse>
						<!--- Move PAR and BAR or just BAR --->
						<cfset responseMessage = fw.getBeanFactory().getBean('TerminalEntry').moveBARPAR( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, pcc = Traveler.getBAR()[1].PCC
																										, bar = Traveler.getBAR()[1].Name
																										, par = Traveler.getPAR()
																										, searchID = rc.searchID )>
					</cfif>
					<cfif responseMessage.error>
						<cfset errorMessage = responseMessage.message>
						<cfset errorType = 'TerminalEntry.moveBARPAR'>
					<cfelse>
						<!--- Add auto ticketing remarks : no error response --->
						<cfset fw.getBeanFactory().getBean('TerminalEntry').addAutoTicketRemark( targetBranch = rc.Account.sBranch
																												, hostToken = hostToken
																												, bookingPCC = rc.Account.PCC_Booking
																												, searchID = rc.searchID )>
					</cfif>
					<cfif NOT responseMessage.error>
						<!--- Add ticketing date : no error response --->
						<cfset fw.getBeanFactory().getBean('TerminalEntry').addTicketDate( targetBranch = rc.Account.sBranch
																												, hostToken = hostToken
																												, searchID = rc.searchID )>
					</cfif>
					<cfif NOT responseMessage.error
						AND hotelSelected>
						<!--- Add hotel lost savings code : no error response --->
						<cfset fw.getBeanFactory().getBean('TerminalEntry').addLostSavings( targetBranch = rc.Account.sBranch
																												, hostToken = hostToken
																												, serviceType = 'H'
																												, startDate = rc.Filter.getCheckInDate()
																												, reasonCode = Traveler.getBookingDetail().getCarReasonCode()
																												, lowestRateOffered = 0
																												, searchID = rc.searchID )>

					</cfif>
					<cfif NOT responseMessage.error
						AND vehicleSelected>
						<!--- Add vehicle lost savings code : no error response --->
						<cfset fw.getBeanFactory().getBean('TerminalEntry').addLostSavings( targetBranch = rc.Account.sBranch
																												, hostToken = hostToken
																												, serviceType = 'C'
																												, startDate = rc.Filter.getCarPickupDateTime()
																												, reasonCode = Traveler.getBookingDetail().getHotelReasonCode()
																												, lowestRateOffered = session.searches[rc.searchID].lowestCarRate
																												, searchID = rc.searchID )>

					</cfif>
					<cfif NOT responseMessage.error>
						<!--- Add received by : no error response --->
						<cfset fw.getBeanFactory().getBean('TerminalEntry').addReceivedBy( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, userID = rc.Filter.getUserID()
																										, searchID = rc.searchID )>
					</cfif>
					<cfif NOT responseMessage.error
						AND profileFound>
						<!--- Remove second name : no error response --->
						<cfset fw.getBeanFactory().getBean('TerminalEntry').removeSecondName( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, searchID = rc.searchID )>
					</cfif>

					<cfset responseMessage = fw.getBeanFactory().getBean('TerminalEntry').updateATFQ( targetBranch = rc.Account.sBranch
																									, hostToken = hostToken
																									, Air = Air
																									, pcc = Traveler.getBAR()[1].PCC
																									, cardNumber = cardNumber
																									, cardType = cardType
																									, cardExpiration = cardExpiration
																									, cardAuth = cardAuth
																									, searchID = rc.searchID )>
				
					removeSecondName<br>
					<cfdump var="#responseMessage#" />
					<cfif responseMessage.error>
						<cfset errorMessage = responseMessage.message>
						<cfset errorType = 'TerminalEntry.updateATFQ'>
					<cfelseif airSelected>
						<!--- Verify stored fare --->
						<cfset responseMessage = fw.getBeanFactory().getBean('TerminalEntry').verifyStoredFare( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, searchID = rc.searchID
																										, Air = Air )>
					</cfif>
					<cfif responseMessage.error>
						<cfset errorMessage = responseMessage.message>
						<cfset errorType = 'TerminalEntry.verifyStoredFare'>
					<cfelse>
						<!--- Remove duplicate accounting line : no error response --->
						<cfset fw.getBeanFactory().getBean('TerminalEntry').removeDuplicateAccounting( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, searchID = rc.searchID )>
					</cfif>
					<cfif NOT responseMessage.error>
						<!--- Determine appropriate queue --->
						<cfset local.queue = ''>
						<cfif NOT Traveler.getBookingDetail().getApprovalNeeded()
							AND Traveler.getBookingDetail().getSpecialRequests() EQ ''>
							<cfset queue = '90'>
						<cfelseif Traveler.getBookingDetail().getApprovalNeeded()>
							<cfset queue = '34*CHA'>
						<cfelse>
							<cfset queue = '34*CSR'>
						</cfif>
						<cfset responseMessage = fw.getBeanFactory().getBean('TerminalEntry').queueRecord( targetBranch = rc.Account.sBranch
																										, hostToken = hostToken
																										, bookingPCC = rc.Account.PCC_Booking
																										, queue = queue
																										, searchID = rc.searchID )>
						<cfif responseMessage.error>
							<cfset errorMessage = responseMessage.message>
							<cfset errorType = 'TerminalEntry.queueRecord'>
						</cfif>
					</cfif>
				</cfif>
				<!--- Sign out of session if error or normal purchase flow --->
				<cfif hostToken NEQ ''>
					<cfset fw.getBeanFactory().getBean('TerminalEntry').closeSession( targetBranch = rc.Account.sBranch
																									, hostToken = hostToken
																									, searchID = rc.searchID )>
				</cfif>
				<cfset Traveler.getBookingDetail().setUniversalLocatorCode( universalLocatorCode )>
				<cfif arrayIsEmpty(errorMessage)>
					<!--- Save profile to database --->
					<cfif Traveler.getBookingDetail().getSaveProfile()>
						<cfset fw.getBeanFactory().getBean('UserService').saveProfile( User = Traveler )>
					</cfif>
					<!--- Create profile in database --->
					<cfif Traveler.getBookingDetail().getCreateProfile()>
						<cfset fw.getBeanFactory().getBean('UserService').createProfile( User = Traveler
																						, acctID = rc.Filter.getAcctID() )>
					</cfif>

					<cfset fw.getBeanFactory().getBean('Purchase').databaseInvoices( Traveler = Traveler
																					, itinerary = itinerary
																					, Filter = rc.Filter )>

				<cfelse>
					<cfset fw.getBeanFactory().getBean('UAPI').databaseErrors( errorMessage = errorMessage
																				, searchID = rc.searchID
																				, errorType = errorType )>
					<cfset local.message = fw.getBeanFactory().getBean('Purchase').getErrorMessage( errorMessage = errorMessage )>
					<cfset local.errorList = message>
					<cfif rc.Filter.getSTMEmployee()>
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
		<!--- Moved the redirect to outside the travelers loop. --->
		<cfif arrayIsEmpty(errorMessage)>
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