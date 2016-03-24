<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfset local.datetimestamp = now() />
		<cfset local.string = "acctID=#rc.Filter.getAcctID()#&userID=#rc.Filter.getUserID()#&searchID=#rc.searchID#&date=#dateFormat(local.datetimestamp, 'mm/dd/yyyy')#&time=#timeFormat(local.datetimestamp, 'HH:mm:ss')#" />
		<cfset local.token = hash(local.string&rc.account.SecurityCode) />

		<!--- If the user entered or removed a new credit card that was processed in secure-sto --->
		<cfif structKeyExists(rc, 'data')>
			<!--- Had too many complications with urlEncodedFormat on the way over --->
			<cfset local.cleanData = replace(rc.data, " ", "+", "ALL") />
			<cfset fw.getBeanFactory().getBean('Summary').updateTraveler( datetimestamp = local.datetimestamp
																		, token = local.token
																		, acctID = rc.Filter.getAcctID()
																		, userID = rc.Filter.getUserID()
																		, searchID = rc.searchID
																		, ccData = local.cleanData ) />
		</cfif>

		<cfparam name="session.searches[rc.searchID].stItinerary" default="#structNew()#">
		<cfparam name="rc.travelerNumber" default="1">
		<cfparam name="rc.remove" default="">
		<cfparam name="rc.add" default="">
		<cfparam name="rc.createProfile" default="0" />
		<cfparam name="rc.password" default="" />
		<cfparam name="rc.passwordConfirm" default="" />

		<cfset rc.errors = {}>
		<cfif rc.remove EQ 1>
			<cfset structDelete(session.searches[rc.searchID].Travelers, rc.travelerNumber)>
			<cfset variables.fw.redirect('summary?searchID=#rc.searchID#&travelerNumber=1')>
		</cfif>

		<cfif rc.add EQ 'hotel'>
			<cfset session.Filters[rc.searchID].setHotel(true)>
			<cfset variables.fw.redirect('hotel.search?SearchID=#rc.searchID#')>
		</cfif>

		<cfif rc.add EQ 'car'>
			<cfset session.Filters[rc.searchID].setCar(true)>
			<cfset variables.fw.redirect('car.availability?searchID=#rc.searchID#')>
		</cfif>

		<cfif NOT listFind('1,2,3,4', rc.travelerNumber)>
			<cfset variables.fw.redirect('summary?searchID=#rc.searchID#&travelerNumber=1')>
		</cfif>

		<cfif structKeyExists(session.searches[rc.searchID], 'Travelers')>
			<cfloop collection="#session.searches[rc.searchID].Travelers#" index="local.travelerNumber" item="local.Traveler">
				<cfif Traveler.getBookingDetail().getUniversalLocatorCode() NEQ ''
					AND NOT Traveler.getBookingDetail().getPurchaseCompleted()
					AND NOT Traveler.getBookingDetail().getSimilarTripSelected()>
					<cfset fw.getBeanFactory().getBean('UniversalAdapter').cancelUR( targetBranch = rc.Account.sBranch
																					, universalRecordLocatorCode = Traveler.getBookingDetail().getUniversalLocatorCode()
																					, Filter = rc.Filter )>
					<cfset fw.getBeanFactory().getBean('Purchase').cancelInvoice( searchID = rc.searchID
																					, urRecloc = Traveler.getBookingDetail().getUniversalLocatorCode() )>
					<cfset Traveler.getBookingDetail().setUniversalLocatorCode( '' )>
					<cfset Traveler.getBookingDetail().setReservationCode( '' )>
					<cfset Traveler.getBookingDetail().setAirConfirmation( '' )>
				</cfif>
				<cfif Traveler.getBookingDetail().getPurchaseCompleted()>
					<cfset variables.fw.redirect('confirmation?searchID=#rc.searchID#')>
				</cfif>
			</cfloop>
		</cfif>

		<cfset rc.itinerary = session.searches[rc.searchID].stItinerary>

		<cfset rc.airSelected = (structKeyExists(rc.itinerary, 'Air') ? true : false)>
		<cfset rc.Air = (structKeyExists(rc.itinerary, 'Air') ? rc.itinerary.Air : '')>

		<cfset rc.hotelSelected = (structKeyExists(rc.itinerary, 'Hotel') ? true : false)>
		<cfset rc.Hotel = (structKeyExists(rc.itinerary, 'Hotel') ? rc.itinerary.Hotel : '')>

		<cfset rc.vehicleSelected = (structKeyExists(rc.itinerary, 'Vehicle') ? true : false)>
		<cfset rc.Vehicle = (structKeyExists(rc.itinerary, 'Vehicle') ? rc.itinerary.Vehicle : '')>

		<cfset rc.allTravelers = fw.getBeanFactory().getBean('UserService').getAuthorizedTravelers( userID = rc.Filter.getUserID()
																								, acctID = rc.Filter.getAcctID() )>
		<cfset rc.qOutOfPolicy = fw.getBeanFactory().getBean('Summary').getOutOfPolicy( acctID = rc.Filter.getAcctID()
																						, tmcID = rc.Account.tmc.getTMCID() )>
		<cfset rc.qStates = fw.getBeanFactory().getBean('Summary').getStates()>
		<cfset rc.qTXExceptionCodes = fw.getBeanFactory().getBean('Summary').getTXExceptionCodes()>
		<cfset rc.fees = fw.getBeanFactory().getBean('Summary').determineFees(userID = rc.Filter.getUserID()
																			, acctID = rc.Filter.getAcctID()
																			, Air = rc.Air
																			, Filter = rc.Filter)>
		<cfif rc.airSelected>
			<cfset rc.KTLinks = fw.getBeanFactory().getBean('Summary').setKTLinks(Air = rc.Air)>
		</cfif>

		<!--- Determine whether the traveler is coming from an internal or external TMC --->
		<!--- TODO: Replace below logic with the true logic after testing is over --->
		<!--- <cfif listFind('46144,198731,213137,215289,215292,217035,217041', rc.filter.getUserID())>
			<cfset local.internalTMC = false />
		<cfelse>
			<cfset local.internalTMC = true />
		</cfif> --->
		<!--- Short's Travel/Internal TMC --->
		<cfif NOT rc.Account.tmc.getIsExternal()>
			<cfset local.internalTMC = true />
		<!--- External TMC --->
		<cfelse>
			<cfset local.internalTMC = false />
		</cfif>

		<cfif rc.travelerNumber EQ 1
			AND (NOT structKeyExists(session.searches[rc.SearchID], 'travelers')
			OR NOT structKeyExists(session.searches[rc.SearchID].travelers, rc.travelerNumber))>

			<!--- Stand up the default profile into an object --->
			<!--- If user is booking through Short's --->
			<cfif internalTMC>
				<cfset rc.Traveler = fw.getBeanFactory().getBean('UserService').loadFullUser(userID = rc.Filter.getProfileID()
																						, acctID = rc.Filter.getAcctID()
																						, valueID = rc.Filter.getValueID()
																						, arrangerID = rc.Filter.getUserID()
																						, vendor = (rc.vehicleSelected ? rc.Vehicle.getVendorCode() : ''))>
			<!--- If user is booking through another TMC --->
			<cfelse>
				<cfset rc.Traveler = fw.getBeanFactory().getBean('UserService').loadTMCUser(userID = rc.Filter.getProfileID()
																						, acctID = rc.Filter.getAcctID()
																						, valueID = rc.Filter.getValueID())>
			</cfif>
			<cfset local.BookingDetail = createObject('component', 'booking.model.BookingDetail').init()>
			<cfset rc.Traveler.setBookingDetail( BookingDetail )>
			<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber] = rc.Traveler>
		<cfelseif NOT structKeyExists(session.searches[rc.SearchID], 'travelers')
			OR NOT structKeyExists(session.searches[rc.SearchID].travelers, rc.travelerNumber)>
			<!--- Stand up the default profile into an object --->
			<!--- If user is booking through Short's --->
			<cfif internalTMC>
				<cfset rc.Traveler = fw.getBeanFactory().getBean('UserService').loadFullUser(userID = 0
																						, acctID = rc.Filter.getAcctID()
																						, valueID = rc.Filter.getValueID()
																						, arrangerID = rc.Filter.getUserID()
																						, vendor = (rc.vehicleSelected ? rc.Vehicle.getVendorCode() : ''))>
			<!--- If user is booking through another TMC --->
			<cfelse>
				<cfset rc.Traveler = fw.getBeanFactory().getBean('UserService').loadTMCUser(userID = 0
																						, acctID = rc.Filter.getAcctID()
																						, valueID = rc.Filter.getValueID())>
			</cfif>
			<cfset local.BookingDetail = createObject('component', 'booking.model.BookingDetail').init()>
			<cfset rc.Traveler.setBookingDetail( BookingDetail )>
			<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber] = rc.Traveler>
		<cfelse>
			<!--- Traveler is already in an object --->
			<cfset rc.Traveler = session.searches[rc.SearchID].travelers[rc.travelerNumber]>
		</cfif>

		<!--- If user is booking through another TMC, create a shell PNR and parse through it --->
		<cfif NOT internalTMC>
			<!--- If air has been selected and air details have not been pulled or hotel has been selected and hotel details
				have not been pulled or car has been selected and car details have not been pulled --->
			<cfif (rc.airSelected AND NOT structKeyExists(rc.Traveler, 'airProfileParsed'))
				OR (rc.hotelSelected AND NOT structKeyExists(rc.Traveler, 'hotelProfileParsed'))
				OR (rc.vehicleSelected AND NOT structKeyExists(rc.Traveler, 'vehicleProfileParsed'))>

				<cfset local.errorMessage = []>
				<!--- Create shell PNR for traveler --->
				<!--- Open terminal session --->
				<cfset local.hostToken = fw.getBeanFactory().getBean('TerminalEntry').openSession( targetBranch = rc.Account.sBranch
																						, searchID = rc.searchID )>

				<cfif hostToken EQ ''>
					<cfset arrayAppend(errorMessage, 'Terminal - open session failed')>
					<cfset errorType = 'TerminalEntry.openSession'>
				</cfif>

				<!---
				Sell passive air segment to create shell PNR
				Command = 0XX1Y30DECALOMCIBK1
				--->
				<cfif rc.airSelected AND NOT structKeyExists(rc.Traveler, 'airProfileParsed')>
					<cfset local.sellPassiveAirSegmentResponse = fw.getBeanFactory().getBean('TerminalEntry').sellPassiveAirSegment( targetBranch = rc.Account.sBranch
																						, hostToken = hostToken
																						, searchID = rc.searchID)>

					<cfif sellPassiveAirSegmentResponse.error>
						<cfset arrayAppend( errorMessage, 'Could not sell passive air segment.' )>
						<cfset errorType = 'TerminalEntry.sellPassiveAirSegment'>
					</cfif>
				</cfif>

				<cfif arrayIsEmpty(errorMessage)>
					<!---
					Get the profile into the terminal session
					Command = S*1M98/SHORTS-DOHMEN/CHRISTINE L05
					--->
					<cfset local.readPARResponse = fw.getBeanFactory().getBean('TerminalEntry').readPAR( targetBranch = rc.Account.sBranch
																						, hostToken = hostToken
																						, pcc = rc.Traveler.getBAR()[1].PCC
																						, bar = rc.Traveler.getBAR()[1].Name
																						, par = rc.Traveler.getPAR()
																						, searchID = rc.searchID)>

					<cfif readPARResponse.error>
						<cfset arrayAppend( errorMessage, 'Could not read profile.' )>
						<cfset errorType = 'TerminalEntry.readPAR'>
					</cfif>
				</cfif>

				<cfif arrayIsEmpty(errorMessage)>
					<!---
					Move over profile and TravelScreen
					Command = MVP/
					Command = SPE
					--->
					<cfset local.moveProfileResponse = fw.getBeanFactory().getBean('TerminalEntry').moveProfile( targetBranch = rc.Account.sBranch
																						, hostToken = hostToken
																						, searchID = rc.searchID)>

					<cfif moveProfileResponse.error>
						<cfset arrayAppend( errorMessage, 'Could not move profile.' )>
						<cfset errorType = 'TerminalEntry.moveProfile'>
					</cfif>
				</cfif>

				<!--- Read through the profile and parse for information --->
				<cfif arrayIsEmpty(errorMessage)>
					<!--- Air parsing --->
					<cfif rc.airSelected AND NOT structKeyExists(session.searches[rc.SearchID].travelers[rc.travelerNumber], 'airProfileParsed')>
						<!---
						Display name field
						Command = *N
						--->
						<cfset local.displayNameFieldResponse = fw.getBeanFactory().getBean('TerminalEntry').displayNameField( targetBranch = rc.Account.sBranch
																							, hostToken = hostToken
																							, searchID = rc.searchID)>

						<cfif displayNameFieldResponse.error>
							<cfset arrayAppend( errorMessage, 'Could not display name field.' )>
							<cfset errorType = 'TerminalEntry.displayNameField'>
						<cfelse>
							<!--- Parse names --->
							<cfset local.parseNameFieldResponse = fw.getBeanFactory().getBean('UserService').parseNames(userNames = displayNameFieldResponse.message)>

							<cfset rc.Traveler.setFirstName(parseNameFieldResponse.firstName) />
							<cfset rc.Traveler.setMiddleName(parseNameFieldResponse.middleName) />
							<cfset rc.Traveler.setLastName(parseNameFieldResponse.lastName) />
						</cfif>

						<!---
						Display phone and email fields
						Command = *PP
						--->
						<cfset local.displayPhoneFieldResponse = fw.getBeanFactory().getBean('TerminalEntry').displayPhoneField( targetBranch = rc.Account.sBranch
																							, hostToken = hostToken
																							, searchID = rc.searchID)>

						<cfif displayPhoneFieldResponse.error>
							<cfset arrayAppend( errorMessage, 'Could not display phone fields.' )>
							<cfset errorType = 'TerminalEntry.displayPhoneField'>
						<cfelse>
							<!--- Parse phone numbers and email address --->
							<cfset local.parsePhoneFieldResponse = fw.getBeanFactory().getBean('UserService').parsePhoneNumbers(phoneNumbers = displayPhoneFieldResponse.message)>

							<cfset rc.Traveler.setPhoneNumber(parsePhoneFieldResponse.businessPhone) />
							<cfset rc.Traveler.setHomePhone(parsePhoneFieldResponse.homePhone) />
							<cfset rc.Traveler.setWirelessPhone(parsePhoneFieldResponse.cellPhone) />
							<cfset rc.Traveler.setEmail(parsePhoneFieldResponse.email) />
						</cfif>

						<!---
						Display frequent flyer numbers
						Command = *MP
						--->
						<cfset local.displayFFNumbersResponse = fw.getBeanFactory().getBean('TerminalEntry').displayFFNumbers( targetBranch = rc.Account.sBranch
																							, hostToken = hostToken
																							, searchID = rc.searchID)>

						<cfif displayFFNumbersResponse.error>
							<cfset arrayAppend( errorMessage, 'Could not display frequent flyer numbers.' )>
							<cfset errorType = 'TerminalEntry.displayFFNumbers'>
						<cfelse>
							<!--- Parse frequent flyer numbers --->
							<cfset local.parseFFNumbersResponse = fw.getBeanFactory().getBean('UserService').parseFFNumbers(FFNumbers = displayFFNumbersResponse.message)>

							<cfif isArray(parseFFNumbersResponse) AND arrayLen(parseFFNumbersResponse)>
								<cfloop array="#parseFFNumbersResponse#" item="local.FFNumber" index="local.FFNumberIndex">
									<cfset rc.LoyaltyProgram = fw.getBeanFactory().getBean('LoyaltyProgramService').new() />
									<cfset rc.LoyaltyProgram.setShortCode(parseFFNumbersResponse[FFNumberIndex].shortCode) />
									<cfset rc.LoyaltyProgram.setCustType('A') />
									<cfset rc.LoyaltyProgram.setAcctNum(parseFFNumbersResponse[FFNumberIndex].acctNum) />
									<cfset arrayAppend(rc.Traveler.getLoyaltyProgram(), rc.LoyaltyProgram) />
								</cfloop>
							</cfif>
						</cfif>

						<!---
						Display flight FOP
						Command = *T
						--->
						<cfset local.displayFlightFOPResponse = fw.getBeanFactory().getBean('TerminalEntry').displayFlightFOP( targetBranch = rc.Account.sBranch
																							, hostToken = hostToken
																							, searchID = rc.searchID)>

						<cfif displayFlightFOPResponse.error>
							<cfset arrayAppend( errorMessage, 'Could not display flight form of payment.' )>
							<cfset errorType = 'TerminalEntry.displayFlightFOP'>
						<cfelse>
							<cfset local.parseFlightFOPResponse = fw.getBeanFactory().getBean('UserService').parseFlightFOP(flightFOP = displayFlightFOPResponse.message)>

							<cfif isArray(parseFlightFOPResponse) AND arrayLen(parseFlightFOPResponse)>
								<!--- As of 1/28/14, Short's receives only masked credit card numbers from Apollo. For now, displaying these masked numbers to users, but not using them. --->
								<!--- <cfif isNumeric(parseFlightFOPResponse[1].cardNumber)> --->
									<cfset local.payment = fw.getBeanFactory().getBean('PaymentManager').new() />

									<cfset payment.setAirUse(true) />
									<cfset payment.setHotelUse(false) />
									<cfset payment.setCarUse(false) />
									<cfset payment.setBookItUse(true) />
									<cfset payment.setAcctNum(right(parseFlightFOPResponse[1].cardNumber, 4)) />
									<!--- <cfset payment.setAcctNum(fw.getBeanFactory().getBean('PaymentService').encrypt(parseFlightFOPResponse[1].cardNumber)) /> --->
									<cfset payment.setAcctNum4(right(parseFlightFOPResponse[1].cardNumber, 4)) />
									<cfset local.expirationYear = '20#right(parseFlightFOPResponse[1].cardExpiration, 2)#' />
									<cfset local.expirationMonth = left(parseFlightFOPResponse[1].cardExpiration, 2) />
									<cfset local.expirationDay = '01' />
									<cfset payment.setExpireDate(createDate(expirationYear, expirationMonth, expirationDay)) />
									<cfset payment.setBTAID('') />
									<cfset payment.setFOPID('-1') />
									<cfset payment.setPCIID(0) />
									<cfset payment.setFOPCode(parseFlightFOPResponse[1].cardType) />
									<cfset payment.setFOPDescription('Personal Flight Credit Card') />
									<cfset payment.setPaymentType('Profile') />
									<cfset arrayAppend(rc.traveler.getPayment(), payment) />
								<!--- </cfif> --->
							</cfif>
						</cfif>

						<!---
						Display seat preference
						Command = SP*PI
						--->
						<!--- SP*PI command used for displaying both seat preference and hotel FOP line number --->
						<cfset local.displaySeatPreferenceResponse = fw.getBeanFactory().getBean('TerminalEntry').displaySeatPreferenceHotelFOP( targetBranch = rc.Account.sBranch
																							, hostToken = hostToken
																							, searchID = rc.searchID)>

						<cfif displaySeatPreferenceResponse.error>
							<cfset arrayAppend( errorMessage, 'Could not display seat preference.' )>
							<cfset errorType = 'TerminalEntry.displaySeatPreferenceHotelFOP'>
						<cfelse>
							<cfset rc.Traveler.setWindowAisle(fw.getBeanFactory().getBean('UserService').parseWindowAisle(seatPreferences = displaySeatPreferenceResponse.message)) />
						</cfif>

						<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber].airProfileParsed = true />
					</cfif>

					<!--- Hotel parsing --->
					<cfif rc.hotelSelected AND NOT structKeyExists(rc.Traveler, 'hotelProfileParsed')>
						<!---
						Display hotel loyalty numbers
						Command = SP*MI/HOTEL
						--->
						<cfset local.displayHotelLoyaltyNumbersResponse = fw.getBeanFactory().getBean('TerminalEntry').displayLoyaltyNumbers( targetBranch = rc.Account.sBranch
																							, hostToken = hostToken
																							, searchID = rc.searchID
																							, loyaltyType = 'HOTEL')>

						<cfif displayHotelLoyaltyNumbersResponse.error>
							<cfset arrayAppend( errorMessage, 'Could not display hotel loyalty numbers.' )>
							<cfset errorType = 'TerminalEntry.displayLoyaltyNumbers'>
						<cfelse>
							<!--- Parse hotel loyalty numbers --->
							<cfset local.parseHotelLoyaltyNumbersResponse = fw.getBeanFactory().getBean('UserService').parseLoyaltyNumbers(loyaltyNumbers = displayHotelLoyaltyNumbersResponse.message)>

							<cfif isArray(parseHotelLoyaltyNumbersResponse) AND arrayLen(parseHotelLoyaltyNumbersResponse)>
								<cfloop array="#parseHotelLoyaltyNumbersResponse#" item="local.hotelLoyaltyNumber" index="local.hotelLoyaltyNumberIndex">
									<cfset rc.LoyaltyProgram = fw.getBeanFactory().getBean('LoyaltyProgramService').new() />
									<cfset rc.LoyaltyProgram.setShortCode(parseHotelLoyaltyNumbersResponse[hotelLoyaltyNumberIndex].shortCode) />
									<cfset rc.LoyaltyProgram.setCustType('H') />
									<cfset rc.LoyaltyProgram.setAcctNum(parseHotelLoyaltyNumbersResponse[hotelLoyaltyNumberIndex].acctNum) />
									<cfset arrayAppend(rc.Traveler.getLoyaltyProgram(), rc.LoyaltyProgram) />
								</cfloop>
							</cfif>
						</cfif>

						<!---
						Display hotel FOP
						Command = SP*PI
						Command = SP*GP
						--->
						<!--- SP*PI command used for displaying both seat preference and hotel FOP line number --->
						<cfset local.displayHotelFOPLineNumberResponse = fw.getBeanFactory().getBean('TerminalEntry').displaySeatPreferenceHotelFOP( targetBranch = rc.Account.sBranch
																							, hostToken = hostToken
																							, searchID = rc.searchID)>

						<cfif displayHotelFOPLineNumberResponse.error>
							<cfset arrayAppend( errorMessage, 'Could not display hotel form of payment line number.' )>
							<cfset errorType = 'TerminalEntry.displaySeatPreferenceHotelFOP'>
						<cfelse>
							<cfset local.parseHotelFOPLineNumberResponse = fw.getBeanFactory().getBean('UserService').parseHotelFOPLineNumber(hotelFOP = displayHotelFOPLineNumberResponse.message)>
							<cfif isNumeric(parseHotelFOPLineNumberResponse)>
								<cfset local.hotelFOPResponse = fw.getBeanFactory().getBean('TerminalEntry').displayHotelFOP( datetimestamp = local.datetimestamp
																									, token = local.token
																									, targetBranch = rc.Account.sBranch
																									, hostToken = hostToken
																									, acctID = rc.Filter.getAcctID()
																									, userID = rc.Filter.getUserID()
																									, searchID = rc.searchID
																									, hotelFOPLineNumber = local.parseHotelFOPLineNumberResponse ) />

								<cfif hotelFOPResponse.error>
									<cfset arrayAppend( errorMessage, 'Could not display hotel form of payment.' )>
									<cfset errorType = 'TerminalEntry.displayHotelFOP'>
								<cfelse>
									<cfset local.hotelFOP = deserializeJSON(hotelFOPResponse.message.filecontent) />
									<cfif isStruct(local.hotelFOP) AND structKeyExists(local.hotelFOP, "cardNumber") AND isNumeric(local.hotelFOP.cardNumber)>
										<cfset local.payment = fw.getBeanFactory().getBean('PaymentManager').new() />

										<cfset payment.setAirUse(false) />
										<cfset payment.setHotelUse(true) />
										<cfset payment.setCarUse(false) />
										<cfset payment.setBookItUse(true) />
										<cfset payment.setAcctNum(local.hotelFOP.cardNumberRight4) />
										<cfset payment.setAcctNum4(local.hotelFOP.cardNumberRight4) />
										<cfset local.expirationYear = local.hotelFOP.cardExpirationYear />
										<cfset local.expirationMonth = local.hotelFOP.cardExpirationMonth />
										<cfset local.expirationDay = '01' />
										<cfset payment.setExpireDate(createDate(expirationYear, expirationMonth, expirationDay)) />
										<cfset payment.setBTAID('') />
										<cfset payment.setFOPID('-1') />
										<cfset payment.setPCIID(local.hotelFOP.pciID) />
										<cfset payment.setFOPCode(local.hotelFOP.cardType) />
										<cfset payment.setFOPDescription('Personal Hotel Credit Card') />
										<cfset payment.setPaymentType('Profile') />
										<cfset arrayAppend(rc.traveler.getPayment(), payment) />
									<cfelse>
										<cfset arrayAppend( errorMessage, 'Could not display hotel form of payment.' )>
										<cfset errorType = 'TerminalEntry.displayHotelFOP'>
									</cfif>
								</cfif>
							</cfif>
						</cfif>

						<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber].hotelProfileParsed = true />
					</cfif>

					<!--- Vehicle parsing --->
					<cfif rc.vehicleSelected AND NOT structKeyExists(rc.Traveler, 'vehicleProfileParsed')>
						<!---
						Display car loyalty numbers
						Command = SP*MI/CAR
						--->
						<cfset local.displayCarLoyaltyNumbersResponse = fw.getBeanFactory().getBean('TerminalEntry').displayLoyaltyNumbers( targetBranch = rc.Account.sBranch
																							, hostToken = hostToken
																							, searchID = rc.searchID
																							, loyaltyType = 'CAR')>

						<cfif displayCarLoyaltyNumbersResponse.error>
							<cfset arrayAppend( errorMessage, 'Could not display car loyalty numbers.' )>
							<cfset errorType = 'TerminalEntry.displayLoyaltyNumbers'>
						<cfelse>
							<!--- Parse car loyalty numbers --->
							<cfset local.parseCarLoyaltyNumbersResponse = fw.getBeanFactory().getBean('UserService').parseLoyaltyNumbers(loyaltyNumbers = displayCarLoyaltyNumbersResponse.message)>

							<cfif isArray(parseCarLoyaltyNumbersResponse) AND arrayLen(parseCarLoyaltyNumbersResponse)>
								<cfloop array="#parseCarLoyaltyNumbersResponse#" item="local.carLoyaltyNumber" index="local.carLoyaltyNumberIndex">
									<cfset rc.LoyaltyProgram = fw.getBeanFactory().getBean('LoyaltyProgramService').new() />
									<cfset rc.LoyaltyProgram.setShortCode(parseCarLoyaltyNumbersResponse[carLoyaltyNumberIndex].shortCode) />
									<cfset rc.LoyaltyProgram.setCustType('C') />
									<cfset rc.LoyaltyProgram.setAcctNum(parseCarLoyaltyNumbersResponse[carLoyaltyNumberIndex].acctNum) />
									<cfset arrayAppend(rc.Traveler.getLoyaltyProgram(), rc.LoyaltyProgram) />
								</cfloop>
							</cfif>
						</cfif>

						<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber].vehicleProfileParsed = true />
					</cfif>
				</cfif>

				<!--- Ignore the shell PNR --->
				<cfset fw.getBeanFactory().getBean('TerminalEntry').ignoreShellPNR( targetBranch = rc.Account.sBranch
																					, hostToken = hostToken
																					, hostToken = hostToken
																					, searchID = rc.searchID )>

				<!--- Close terminal session --->
				<cfset fw.getBeanFactory().getBean('TerminalEntry').closeSession( targetBranch = rc.Account.sBranch
																					, hostToken = hostToken
																					, searchID = rc.searchID )>

			</cfif>
		</cfif>
		<cfif rc.travelerNumber EQ 1>
			<cfset rc.Traveler.getBookingDetail().setAirNeeded( (rc.airSelected ? 1 : 0) )>
			<cfset rc.Traveler.getBookingDetail().setHotelNeeded( (rc.hotelSelected ? 1 : 0) )>
			<cfset rc.Traveler.getBookingDetail().setCarNeeded( (rc.vehicleSelected ? 1 : 0) )>
		</cfif>

		<!--- STM-5497: If the user selected a refundable fare, ensure this really is a refundable fare --->
		<cfif rc.airSelected AND structKeyExists(session.searches[rc.searchID], "RequestedRefundable") AND session.searches[rc.searchID].RequestedRefundable>
			<cfset local.bGovtRate = 0 />
			<cfset local.sFaresIndicator = "PublicAndPrivateFares" />
			<cfif rc.Air.PTC EQ "GST">
				<cfset local.bGovtRate = 1 />
				<cfset local.sFaresIndicator = "PublicOrPrivateFares" />
			</cfif>

			<cfset local.originalAirfare = rc.Air.Total />

			<!--- Do the first AirPrice call with bRefundable = 1 --->
			<cfset local.airPriceCheck = fw.getBeanFactory().getBean('AirPrice').doAirPrice( searchID = rc.searchID
																					, Account = rc.Account
																					, Policy = rc.Policy
																					, sCabin = rc.Air.Class
																					, bRefundable = 1
																					, bRestricted = 0
																					, sFaresIndicator = sFaresIndicator
																					, bAccountCodes = 1
																					, nTrip = rc.Air.nTrip
																					, nCouldYou = 0
																					, bSaveAirPrice = 1
																					, findIt = rc.Filter.getFindIt()
																					, bIncludeClass = 1
																					, bIncludeCabin = 1
																					, totalOnly = 0
																					, bIncludeBookingCodes = 1
																					, bGovtRate = bGovtRate
																				)>
			<!--- If the first AirPrice call resulted in an error message, do a second AirPrice call with bRefundable = 0 --->
			<cfif structIsEmpty(airPriceCheck) OR structKeyExists(airPriceCheck, 'faultMessage')>
				<cfset local.airPriceCheck2 = fw.getBeanFactory().getBean('AirPrice').doAirPrice( searchID = rc.searchID
																					, Account = rc.Account
																					, Policy = rc.Policy
																					, sCabin = rc.Air.Class
																					, bRefundable = 0
																					, bRestricted = 0
																					, sFaresIndicator = sFaresIndicator
																					, bAccountCodes = 1
																					, nTrip = rc.Air.nTrip
																					, nCouldYou = 0
																					, bSaveAirPrice = 1
																					, findIt = rc.Filter.getFindIt()
																					, bIncludeClass = 1
																					, bIncludeCabin = 1
																					, totalOnly = 0
																					, bIncludeBookingCodes = 1
																					, bGovtRate = bGovtRate
																				)>
				<!--- If the second AirPrice call still results in an error message, display it --->

				<cfif structIsEmpty(airPriceCheck2) OR structKeyExists(airPriceCheck2, 'faultMessage')>
					<cfset rc.message.addError('Fare type selected is unavailable for pricing.') />
					<cfset session.searches[rc.searchID].PassedRefCheck = 0 />
				<cfelse>
					<cfloop list="#structKeyList(airPriceCheck2)#" index="item">
						<cfif airPriceCheck2[item].Total EQ originalAirfare>
							<!--- Else if the trip really is non-refundable, alert the traveler --->
							<cfif airPriceCheck2[item].ref EQ 0>
								<cfset session.searches[rc.SearchID].RequestedRefundable = 0 />
								<cfset session.searches[rc.searchID].stItinerary.Air.Ref = 0 />
								<cfset session.searches[rc.searchID].stItinerary.Air.RequestedRefundable = 0 />
								<cfset session.searches[rc.searchID].PassedRefCheck = 1 />
								<cfset rc.message.addError('The rules for this fare have changed - this fare is nonrefundable.') />
							</cfif>
							<cfset local.trip = airPriceCheck2 />							
						</cfif>
					</cfloop>
				</cfif>
			<cfelse>
				<cfset session.searches[rc.searchID].PassedRefCheck = 1 />
				<cfset local.trip = airPriceCheck />
			</cfif>

			<cfif session.searches[rc.searchID].PassedRefCheck>
				<cfset local.nTrip = rc.Air.nTrip>
				<cfset local.aPolicies = rc.Air.aPolicies>
				<cfset local.policy = rc.Air.policy>
				<cfloop list="#structKeyList(trip)#" index="local.tripKey">
					<cfif structKeyExists(trip, local.tripKey)>
						<cfset session.searches[rc.searchID].stItinerary.Air = trip[local.tripKey]>
						<cfset session.searches[rc.searchID].stItinerary.Air.nTrip = nTrip>
						<cfset session.searches[rc.searchID].stItinerary.Air.aPolicies = aPolicies>
						<cfset session.searches[rc.searchID].stItinerary.Air.policy = policy>
					</cfif>
				</cfloop>
			</cfif>

			<cfset rc.Air = session.searches[rc.searchID].stItinerary.Air />
		</cfif>

		<!--- <cfif rc.Filter.getFindIt()> --->
			<cfset var similarTrips = fw.getBeanFactory().getBean('Summary').getSimilarTrips(rc.Filter,fw.getBeanFactory().getBean('PNRService'))>
		<!--- </cfif> --->
		<!---
		FORM SELECTED
		--->
		<cfif structKeyExists(rc, 'trigger')>
			<cfparam name="rc.noMiddleName" default="0">
			<cfparam name="rc.nameChange" default="0">
			<cfparam name="rc.createProfile" default="0">
			<cfparam name="rc.saveProfile" default="0">
			<cfparam name="rc.airSaveCard" default="0">
			<cfparam name="rc.hotelSaveCard" default="0">
			<cfparam name="rc.airNeeded" default="0">
			<cfparam name="rc.hotelNeeded" default="0">
			<cfparam name="rc.carNeeded" default="0">
			<!--- Keep track of the fopID's of any new air or hotel cards entered --->
			<cfset local.originalAirFOPID = rc.Traveler.getBookingDetail().getAirFOPID() />
			<cfset local.originalHotelFOPID = rc.Traveler.getBookingDetail().getHotelFOPID() />
			<cfif internalTMC>
				<cfset rc.Traveler = fw.getBeanFactory().getBean('UserService').loadFullUser(userID = rc.userID
																						, acctID = rc.Filter.getAcctID()
																						, valueID = rc.Filter.getValueID()
																						, arrangerID = rc.Filter.getUserID()
																						, vendor = (rc.vehicleSelected ? rc.Vehicle.getVendorCode() : ''))>
				<cfset local.BookingDetail = createObject('component', 'booking.model.BookingDetail').init()>
				<cfset rc.Traveler.setBookingDetail( BookingDetail )>
				<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber] = rc.Traveler>
				<cfset local.originalFirstName = rc.Traveler.getFirstName() />
				<cfset local.originalMiddleName = rc.Traveler.getMiddleName() />
				<cfset local.originalLastName = rc.Traveler.getLastName() />
				<cfset rc.Traveler.populateFromStruct( rc )>
				<cfset local.currentFirstName = rc.Traveler.getFirstName() />
				<cfset local.currentMiddleName = rc.Traveler.getMiddleName() />
				<cfset local.currentLastName = rc.Traveler.getLastName() />
				<!--- If profile exists and name has been changed --->
				<cfif ((isDefined("originalFirstName") AND (currentFirstName NEQ originalFirstName))
					OR (isDefined("originalMiddleName") AND (currentMiddleName NEQ originalMiddleName))
					OR (isDefined("originalLastName") AND (currentLastName NEQ originalLastName)))>
					<cfset rc.nameChange = 1 />
				</cfif>
			<cfelse>
				<cfset rc.Traveler.populateFromStruct( rc )>
			</cfif>
			<cfset rc.Traveler.getBookingDetail().populateFromStruct( rc )>
			<!--- If a new air or hotel credit card was entered, keep the fopID that was returned from the creditCards table --->
			<cfif rc.Traveler.getBookingDetail().getNewAirCC() EQ 1>
				<cfif len(local.originalAirFOPID) AND isNumeric(local.originalAirFOPID) AND local.originalAirFOPID NEQ 0>
					<cfset rc.Traveler.getBookingDetail().setAirFOPID( local.originalAirFOPID ) />
				<cfelseif rc.Traveler.getBookingDetail().getNewAirCCID() NEQ 0>
					<cfset rc.Traveler.getBookingDetail().setAirFOPID( rc.Traveler.getBookingDetail().getNewAirCCID() ) />
				</cfif>
			</cfif>
			<cfif rc.Traveler.getBookingDetail().getNewHotelCC() EQ 1>
				<cfif len(local.originalHotelFOPID) AND isNumeric(local.originalHotelFOPID) AND local.originalHotelFOPID NEQ 0>
					<cfset rc.Traveler.getBookingDetail().setHotelFOPID( local.originalHotelFOPID ) />
				<cfelseif rc.Traveler.getBookingDetail().getNewHotelCCID() NEQ 0>
					<cfset rc.Traveler.getBookingDetail().setHotelFOPID( rc.Traveler.getBookingDetail().getNewHotelCCID() ) />
				</cfif>
			</cfif>
			<cfif (structKeyExists(rc, "year") AND len(rc.year))
				AND (structKeyExists(rc, "month") AND len(rc.month))
				AND (structKeyExists(rc, "day") AND len(rc.day))>
				<cfset local.birthDate = createDate(rc.year, rc.month, rc.day)>
			<cfelse>
				<cfset local.birthDate = ''>
			</cfif>
			<!--- <cfdump var="#rc.Traveler.getBookingDetail().getUnusedTickets()#" /><cfabort /> --->
			<cfif rc.airSelected>
				<cfset local.airFound = false>
				<cfloop array="#rc.Air.Carriers#" item="local.carrier">
					<cfset local.airFound = false>
					<cfloop array="#rc.Traveler.getLoyaltyProgram()#" item="local.program" index="local.programIndex">
						<cfif program.getShortCode() EQ carrier
							AND program.getCustType() EQ 'A'>
							<cfset rc.Traveler.getLoyaltyProgram()[local.programIndex].setAcctNum( rc['airFF#carrier#'] )>
							<cfset local.airFound = true>
						</cfif>
					</cfloop>
					<cfif NOT local.airFound>
						<cfset rc.LoyaltyProgram = fw.getBeanFactory().getBean('LoyaltyProgramService').new()>
						<cfset rc.LoyaltyProgram.setShortCode( carrier )>
						<cfset rc.LoyaltyProgram.setCustType( 'A' )>
						<cfset rc.LoyaltyProgram.setAcctNum( rc['airFF#carrier#'] )>
						<cfset arrayAppend( rc.Traveler.getLoyaltyProgram(), rc.LoyaltyProgram )>
					</cfif>
				</cfloop>
				<cfset local.seats = {}>
				<cfloop list="#rc.seatFieldNames#" index="local.seat">
					<cfset local.seats[local.seat] = uCase( rc[local.seat] )>
				</cfloop>
				<cfset rc.Traveler.getBookingDetail().setSeats( local.seats )>
			</cfif>
			<cfif rc.hotelSelected
				OR rc.vehicleSelected>
				<cfset local.hotelFound = false>
				<cfset local.vehicleFound = false>
				<cfloop array="#rc.Traveler.getLoyaltyProgram()#" item="local.program" index="local.programIndex">
					<cfif rc.hotelSelected
						AND program.getShortCode() EQ rc.Hotel.getChainCode()
						AND program.getCustType() EQ 'H'>
						<cfset rc.Traveler.getLoyaltyProgram()[local.programIndex].setAcctNum( rc.hotelFF )>
						<cfset local.hotelFound = true>
					<cfelseif rc.vehicleSelected
						AND program.getShortCode() EQ rc.Vehicle.getVendorCode()
						AND program.getCustType() EQ 'C'>
						<cfset rc.Traveler.getLoyaltyProgram()[local.programIndex].setAcctNum( rc.carFF )>
						<cfset local.vehicleFound = true>
					</cfif>
				</cfloop>
				<cfif rc.hotelSelected
					AND NOT local.hotelFound>
					<cfset rc.LoyaltyProgram = fw.getBeanFactory().getBean('LoyaltyProgramService').new()>
					<cfset rc.LoyaltyProgram.setShortCode( rc.Hotel.getChainCode() )>
					<cfset rc.LoyaltyProgram.setCustType( 'H' )>
					<cfset rc.LoyaltyProgram.setAcctNum( rc.hotelFF )>
					<cfset arrayAppend( rc.Traveler.getLoyaltyProgram(), rc.LoyaltyProgram )>
				</cfif>
				<cfif rc.vehicleSelected
					AND NOT local.vehicleFound>
					<cfset rc.LoyaltyProgram = fw.getBeanFactory().getBean('LoyaltyProgramService').new()>
					<cfset rc.LoyaltyProgram.setShortCode( rc.Vehicle.getVendorCode() )>
					<cfset rc.LoyaltyProgram.setCustType( 'C' )>
					<cfset rc.LoyaltyProgram.setAcctNum( rc.carFF )>
					<cfset arrayAppend( rc.Traveler.getLoyaltyProgram(), rc.LoyaltyProgram )>
				</cfif>
			</cfif>
			<cfset local.inputName = ''>
			<cfloop array="#rc.Traveler.getOrgUnit()#" item="local.orgUnit" index="local.orgUnitIndex">
				<cfif orgUnit.getOUDisplay() EQ 1>
					<cfset local.inputName = orgUnit.getOUType() & orgUnit.getOUPosition()>
					<cfif local.orgunit.getOUFreeform()>
						<cfset rc.Traveler.getOrgUnit()[local.orgUnitIndex].setValueReport( rc[inputName] )>
						<cfset rc.Traveler.getOrgUnit()[local.orgUnitIndex].setValueDisplay( rc[inputName] )>
					<cfelse>
						<cfif structKeyExists(rc, inputName)>
							<cfset rc.Traveler.getOrgUnit()[local.orgUnitIndex].setValueID( rc[inputName] )>
							<cfset local.qOUValue = fw.getBeanFactory().getBean('OrgUnitService').getOrgUnitValues( ouID = orgUnit.getOUID()
																													, valueID = rc[inputname]
																													, returnFormat = 'query' )>
							<cfset rc.Traveler.getOrgUnit()[local.orgUnitIndex].setValueReport( qOUValue.Value_Report )>
							<cfset rc.Traveler.getOrgUnit()[local.orgUnitIndex].setValueDisplay( qOUValue.Value_Display )>
						</cfif>
					</cfif>
				</cfif>
			</cfloop>

			<cfset rc.Traveler.setBirthdate( birthdate )>
			<cfset rc.Traveler.setFirstName( REReplace(rc.Traveler.getFirstName(), '[^0-9A-Za-z\s]', '', 'ALL') )>
			<cfset rc.Traveler.setMiddleName( REReplace(rc.Traveler.getMiddleName(), '[^0-9A-Za-z\s]', '', 'ALL') )>
			<cfset rc.Traveler.setLastName( REReplace(rc.Traveler.getLastName(), '[^0-9A-Za-z\s]', '', 'ALL') )>
			<cfif len(rc.Traveler.getMiddleName()) AND rc.Traveler.getNoMiddleName() EQ 1>
				<cfset rc.Traveler.setNoMiddleName( 0 )>
			</cfif>
			<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber] = rc.Traveler>
			<cfset rc.errors = fw.getBeanFactory().getBean('Summary').error( Traveler = rc.Traveler
																			, Air = rc.Air
																			, Hotel = rc.Hotel
																			, Vehicle = rc.Vehicle
																			, Policy = rc.Policy
																			, Filter = rc.Filter
																			, acctID = rc.Filter.getAcctID()
																			, searchID = rc.searchID
																			, password = rc.password
																			, passwordConfirm = rc.passwordConfirm
																			, action = rc.trigger )>
			<cfif structIsEmpty(rc.errors)>
				<cfif isNumeric(left(rc.trigger, 1))>
					<cfset variables.fw.redirect('summary?searchID=#rc.searchID#&travelerNumber=#(left(rc.trigger, 1))#')>
				<cfelseif rc.trigger EQ 'ADD A TRAVELER'>
					<cfset rc.travelerNumber = arrayLen(structKeyArray(session.searches[rc.searchID].Travelers))+1>
					<cfif rc.travelerNumber LTE 4>
						<cfset rc.travelerNumber = rc.travelerNumber>
					<cfelse>
						<cfset rc.travelerNumber = 1>
					</cfif>
					<cfset variables.fw.redirect('summary?searchID=#rc.searchID#&travelerNumber=#rc.travelerNumber#')>
				<cfelseif rc.trigger EQ 'CONFIRM PURCHASE'>
					<cfset pnrString = "" />
					<cfif structKeyExists(rc, "recLoc") AND len(rc.recLoc)>
						<cfset pnrString = "&recLoc=#rc.recLoc#" />
					</cfif>
					<cfset variables.fw.redirect('purchase?searchID=#rc.searchID##pnrString#')>
				<cfelseif rc.trigger EQ 'CREATE PROFILE'>
					<cfset local.newUserID = fw.getBeanFactory().getBean('UserService').createProfile( User = rc.Traveler
																						, acctID = rc.Filter.getAcctID()
																						, Account = rc.Account
																						, searchID = rc.searchID ) />
					<cfset rc.Filter.setUserID(newUserID) />
					<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber].setUserID(newUserID) />
					<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber].getBookingDetail().setSaveProfile(true) />
					<cfset rc.message.addInfo('Your profile has been created.') />
				</cfif>
			<cfelse>
				<cfif rc.trigger EQ 'CREATE PROFILE'>
					<cfset rc.message.addError('Your profile has not been saved. Please correct the fields in red below and click "Create Profile" again.') />
				<cfelse>
					<cfset rc.message.addError('Please correct the fields in red below.') />
				</cfif>
			</cfif>
		</cfif>
		<!--- <cfdump var="#session.searches[rc.SearchID].travelers#" abort="true" /> --->
		<!--- <cfdump var="#session.searches[rc.SearchID].travelers[rc.travelerNumber]#" abort="true" /> --->
		<!--- <cfdump var="#session.searches[rc.SearchID].travelers[rc.travelerNumber].getBookingDetail()#" abort="true" /> --->

		<cfreturn />
	</cffunction>

</cfcomponent>
