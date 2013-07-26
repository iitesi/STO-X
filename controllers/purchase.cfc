<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfparam name="rc.travelerNumber" default="1">
		<cfset local.errorMessage = []>
		<cfset local.errorType = ''>

		<cfset rc.Traveler = session.searches[rc.searchID].Travelers[rc.travelerNumber]>
		<cfset local.Profile = fw.getBeanFactory().getBean('UserService').loadBasicUser( userID = rc.Traveler.getUserID() )>
		<cfset rc.itinerary = session.searches[rc.searchID].stItinerary>
		<cfset rc.airSelected = (structKeyExists(rc.itinerary, 'Air') ? true : false)>
		<cfset rc.Air = (structKeyExists(session.searches[rc.SearchID].stItinerary, 'Air') ? session.searches[rc.SearchID].stItinerary.Air : '')>
		<cfset rc.hotelSelected = (structKeyExists(rc.itinerary, 'Hotel') ? true : false)>
		<cfset rc.Hotel = (structKeyExists(session.searches[rc.SearchID].stItinerary, 'Hotel') ? session.searches[rc.SearchID].stItinerary.Hotel : '')>
		<cfset rc.vehicleSelected = (structKeyExists(rc.itinerary, 'Vehicle') ? true : false)>
		<cfset rc.Vehicle = (structKeyExists(session.searches[rc.SearchID].stItinerary, 'Vehicle') ? session.searches[rc.SearchID].stItinerary.Vehicle : '')>
		<cfset local.providerLocatorCode = ''>
		<cfset local.universalLocatorCode = ''>
		<cfset local.version = -1>

		<!--- Populate sort fields --->
		<cfset local.sort1 = ''>
		<cfset local.sort2 = ''>
		<cfset local.sort3 = ''>
		<cfset local.sort4 = ''>
		<cfloop array="#rc.Traveler.getOrgUnit()#" index="local.orgUnitIndex" item="local.orgUnit">
			<cfif orgUnit.getOUType() EQ 'sort'>
				<cfset local['sort#orgUnit.getOUPosition()#'] = orgUnit.getValueReport()>
			</cfif>
		</cfloop>
		<cfset local.statmentInformation = sort1&' '&sort2&' '&sort3&' '&sort4>
		<cfset statmentInformation = trim(statmentInformation)>

		<cfset local.approval = fw.getBeanFactory().getBean('Summary').determineApproval( Policy = rc.Policy
																						, Filter = rc.Filter
																						, Traveler = rc.Traveler )>

		<cfset rc.Traveler.getBookingDetail().setApprovalNeeded( approval.approvalNeeded )>
		<cfset rc.Traveler.getBookingDetail().setApprovers( approval.approvers )>

		<cfset local.responseMessage = ''>
		<cfset local.hostToken = fw.getBeanFactory().getBean('TerminalEntry').openSession( targetBranch = rc.Account.sBranch
																						, searchID = rc.searchID )>

		<cfset local.profileFound = true>
		<!--- <cfif rc.Traveler.getPAR() NEQ ''>
			<cfset parResponse = fw.getBeanFactory().getBean('TerminalEntry').readPAR( targetBranch = rc.Account.sBranch
																						, hostToken = hostToken
																						, pcc = rc.Traveler.getBAR()[1].PCC
																						, bar = rc.Traveler.getBAR()[1].Name
																						, par = rc.Traveler.getPAR()
																						, searchID = rc.searchID)>
			parResponse<br>
			<cfdump var="#parResponse#" />
			<cfif parResponse.error>
				<cfset profileFound = false>
			</cfif>
		<cfelse>
			<cfset profileFound = false>
		</cfif> --->
		profileFound<br>
		<cfdump var="#profileFound#" />

		<!--- Sell Air --->
		<cfif rc.airSelected
			AND rc.Traveler.getBookingDetail().getAirNeeded()>

			<cfset local.trip = fw.getBeanFactory().getBean('AirPrice').doAirPrice( searchID = rc.searchID
																					, Account = rc.Account
																					, Policy = rc.Policy
																					, Class = rc.Air.Class
																					, Ref = rc.Air.Ref
																					, nTrip = rc.Air.nTrip
																					, nCouldYou = 0
																					, bSaveAirPrice = 1
																				)>

			<cfif NOT structIsEmpty(trip)>
				<cfset local.airPricing = fw.getBeanFactory().getBean('AirCreate').parseTripForPurchase( sXML = trip[rc.Air.nTrip].sXML )>

				<cfset rc.response = fw.getBeanFactory().getBean('AirAdapter').create( targetBranch = rc.Account.sBranch 
																					, Traveler = rc.Traveler
																					, Profile = Profile
																					, Air = rc.Air
																					, airPricing = airPricing
																					, Filter = rc.Filter
																					, statmentInformation = statmentInformation
																					, profileFound = profileFound
																				 )>

	<!--- <cfdump var="#rc.response#" /><cfabort /> --->
				<cfset rc.Air.UniversalLocatorCode = ''>
				<cfset rc.Air = fw.getBeanFactory().getBean('AirAdapter').parseAirRsp( Air = rc.Air
																						, response = rc.response )>

				<cfif rc.Air.UniversalLocatorCode EQ ''>
					<cfset errorMessage = fw.getBeanFactory().getBean('UAPI').parseError( rc.response )>
					<cfdump var="#errorMessage#">
					<cfset errorType = 'air'><cfabort />
				<cfelse>
					<cfset providerLocatorCode = rc.Air.ProviderLocatorCode>
					<cfset universalLocatorCode = rc.Air.UniversalLocatorCode>
					Air<br>
					providerLocatorCode<br>
					<cfdump var="#providerLocatorCode#">
					universalLocatorCode<br>
					<cfdump var="#universalLocatorCode#">
				</cfif>
				<cfset session.searches[rc.SearchID].stItinerary.Air = rc.Air>

				<cfif providerLocatorCode NEQ ''>
					<cfset version++>
				</cfif>
			<cfelse>
				<cfset arrayAppend( errorMessage, 'Could not price record.' )>
			</cfif>
		</cfif>

		<!--- Sell Hotel --->
		<cfif rc.hotelSelected
			AND rc.Traveler.getBookingDetail().getHotelNeeded()
			AND arrayIsEmpty(errorMessage)>

			<cfset rc.Hotel.setProviderLocatorCode('')>
			<cfset rc.Hotel.setUniversalLocatorCode('')>

			<cfset rc.response = fw.getBeanFactory().getBean('HotelAdapter').create( targetBranch = rc.Account.sBranch 
																					, searchID = rc.searchID
																					, Traveler = rc.Traveler
																					, Profile = Profile
																					, Hotel = rc.Hotel
																					, Filter = rc.Filter
																					, statmentInformation = statmentInformation
																					, providerLocatorCode = providerLocatorCode
																					, universalLocatorCode = universalLocatorCode
																					, version = version
																					, profileFound = profileFound
																				)>

			<cfset rc.Hotel = fw.getBeanFactory().getBean('HotelAdapter').parseHotelRsp( Hotel = rc.Hotel
																					, response = rc.response )>

			<cfif rc.Hotel.getConfirmation() EQ ''>
				<cfset errorMessage = fw.getBeanFactory().getBean('UAPI').parseError( rc.response )>
				<cfset errorType = 'hotel'>
			<cfelse>
				<cfset providerLocatorCode = rc.Hotel.getProviderLocatorCode()>
				<cfset universalLocatorCode = rc.Hotel.getUniversalLocatorCode()>
				Hotel<br>
				providerLocatorCode<br>
				<cfdump var="#providerLocatorCode#">
				universalLocatorCode<br>
				<cfdump var="#universalLocatorCode#">
			</cfif>
			<cfset session.searches[rc.SearchID].stItinerary.Hotel = rc.Hotel>

			<cfif providerLocatorCode NEQ ''>
				<cfset version++>	
			</cfif>
		</cfif>

		<!--- Sell Vehicle --->
		<cfif rc.vehicleSelected
			AND rc.Traveler.getBookingDetail().getCarNeeded()
			AND arrayIsEmpty(errorMessage)>

			<cfset rc.Vehicle.setProviderLocatorCode('')>
			<cfset rc.Vehicle.setUniversalLocatorCode('')>
			<cfset local.lowestRateOffered = session.searches[rc.searchID].lowestCarRate>

			<!--- Find the correct direct bill and corporate discount numbers --->
			<cfset local.directBillNumber = ''>
			<cfset local.corporateDiscountNumber = ''>
			<cfset local.directBillType = ''>
			<cfloop array="#rc.Traveler.getPayment()#" index="local.paymentIndex" item="local.payment">
				<cfif payment.getCarUse() EQ 1>
					<cfif len(payment.getDirectBillNumber()) GT 0
						AND rc.Traveler.getBookingDetail().getCarFOPID() EQ 'DB_'&payment.getDirectBillNumber()>
						<cfset directBillNumber = payment.getDirectBillNumber()>
						<cfset corporateDiscountNumber = payment.getCorporateDiscountNumber()>
						<cfset directBillType = payment.getDirectBillType()>
					<cfelseif len(payment.getCorporateDiscountNumber()) GT 0
						AND rc.Traveler.getBookingDetail().getCarFOPID() EQ 'CD_'&payment.getDirectBillNumber()>
						<cfset directBillNumber = ''>
						<cfset corporateDiscountNumber = payment.getCorporateDiscountNumber()>
						<cfset directBillType = payment.getDirectBillType()>
					</cfif>
				</cfif>
			</cfloop>

			<!--- Find arriving flight details --->
			<cfset local.carrier = ''>
			<cfset local.flightNumber = ''>
			<cfif isStruct(rc.Air)>
				<cfloop collection="#rc.Air.Groups[0].Segments#" index="local.segmentIndex" item="local.segment">
					<cfset carrier = segment.carrier>
					<cfset flightNumber = segment.flightNumber>
				</cfloop>
			</cfif>
			
			<!--- Sell vehicle --->
			<cfset rc.response = fw.getBeanFactory().getBean('VehicleAdapter').create( targetBranch = rc.Account.sBranch 
																					, Traveler = rc.Traveler
																					, Profile = Profile
																					, Vehicle = rc.Vehicle
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
			<!--- Parse the vehicle --->
			<cfset rc.Vehicle = fw.getBeanFactory().getBean('VehicleAdapter').parseVehicleRsp( Vehicle = rc.Vehicle
																							, response = rc.response )>
			<!--- Validate the confirmation --->
			<cfif rc.Vehicle.getConfirmation() EQ ''>
				<cfset errorMessage = fw.getBeanFactory().getBean('UAPI').parseError( rc.response )>
				<cfset errorType = 'vehicle'>
			<cfelse>
				<!--- <cfdump var="#rc.Vehicle#"> --->
				<cfset providerLocatorCode = rc.Vehicle.getProviderLocatorCode()>
				<cfset universalLocatorCode = rc.Vehicle.getUniversalLocatorCode()>
				Vehicle<br>
				providerLocatorCode<br>
				<cfdump var="#providerLocatorCode#">
				universalLocatorCode<br>
				<cfdump var="#universalLocatorCode#">
			</cfif>
			<cfset session.searches[rc.SearchID].stItinerary.Vehicle = rc.Vehicle>

			<cfif providerLocatorCode NEQ ''>
				<cfset version++>
			</cfif>
		</cfif>

		<cfif arrayIsEmpty(errorMessage)>
			<cfset responseMessage = fw.getBeanFactory().getBean('TerminalEntry').displayPNR( targetBranch = rc.Account.sBranch
																							, hostToken = hostToken
																							, pnr = providerLocatorCode
																							, searchID = rc.searchID )>
		
			displayPNR<br>
			<cfdump var="#responseMessage#" />

			<cfset responseMessage = fw.getBeanFactory().getBean('TerminalEntry').moveBARPAR( targetBranch = rc.Account.sBranch
																							, hostToken = hostToken
																							, pcc = rc.Traveler.getBAR()[1].PCC
																							, bar = rc.Traveler.getBAR()[1].Name
																							, par = rc.Traveler.getPAR()
																							, searchID = rc.searchID )>

			moveBARPAR<br>
			<cfdump var="#responseMessage#" />

			<cfset responseMessage = fw.getBeanFactory().getBean('TerminalEntry').addReceivedBy( targetBranch = rc.Account.sBranch
																							, hostToken = hostToken
																							, userID = rc.Filter.getUserID()
																							, searchID = rc.searchID )>

			addReceivedBy<br>
			<cfdump var="#responseMessage#" />

			<cfset responseMessage = fw.getBeanFactory().getBean('TerminalEntry').removeSecondName( targetBranch = rc.Account.sBranch
																							, hostToken = hostToken
																							, searchID = rc.searchID )>
		
			removeSecondName<br>
			<cfdump var="#responseMessage#" />
			<cfif rc.airSelected>
				<cfset responseMessage = fw.getBeanFactory().getBean('TerminalEntry').verifyStoredFare( targetBranch = rc.Account.sBranch
																								, hostToken = hostToken
																								, searchID = rc.searchID )>
			
				verifyStoredFare<br>
				<cfdump var="#responseMessage#" />
			</cfif>

			<cfif NOT rc.Traveler.getBookingDetail().getApprovalNeeded()
				AND rc.Traveler.getBookingDetail().getSpecialRequests() EQ ''>
				<cfset responseMessage = fw.getBeanFactory().getBean('TerminalEntry').queueRecord( targetBranch = rc.Account.sBranch
																								, hostToken = hostToken
																								, bookingPCC = rc.Account.PCC_Booking
																								, queue = '90'
																								, searchID = rc.searchID )>
			
				queueRecord<br>
				<cfdump var="#responseMessage#" />
			<cfelseif rc.Traveler.getBookingDetail().getApprovalNeeded()>
				<cfset responseMessage = fw.getBeanFactory().getBean('TerminalEntry').queueRecord( targetBranch = rc.Account.sBranch
																								, hostToken = hostToken
																								, bookingPCC = rc.Account.PCC_Booking
																								, queue = '34*CHA'
																								, searchID = rc.searchID )>
			
				queueRecord<br>
				<cfdump var="#responseMessage#" />
			<cfelse>
				<cfset responseMessage = fw.getBeanFactory().getBean('TerminalEntry').queueRecord( targetBranch = rc.Account.sBranch
																								, hostToken = hostToken
																								, bookingPCC = rc.Account.PCC_Booking
																								, queue = '34*CSR'
																								, searchID = rc.searchID )>
			
				queueRecord<br>
				<cfdump var="#responseMessage#" />
			</cfif>
			
			<cfset local.hostToken = fw.getBeanFactory().getBean('TerminalEntry').closeSession( targetBranch = rc.Account.sBranch
																							, hostToken = hostToken
																							, searchID = rc.searchID )>

			<cfabort />
		</cfif>

		<cfif arrayIsEmpty(errorMessage)>
			<cfset variables.fw.redirect('confirmation?searchID=#rc.searchID#')>
		<cfelse>
			<cfset local.errorList = arrayToList(errorMessage)>
			<cfif errorType EQ 'hotel'
				AND (find('NEED GUEST CREDIT CARD IN CARD DEPOSIT FORMAT TO BOOK', errorList)
				OR find('INVALID /G- TYPE OR FORMAT', errorList)
				OR find('INVALID NEED DEPOSIT IN /G- FIELD', errorList)
				OR find('ADVANCED DEPOSIT REQUIRED', errorList)
				OR find('INVALID GUARANTEE INDICATOR', errorList)
				OR find('DEPOSIT REQ', errorList)
				OR find('NEED GUEST CREDIT CARD IN CARD DEPOSIT', errorList)
				OR find('DEPOSIT REQUIRED PLEASE CORRECT', errorList))>
				<cfset session.searches[rc.searchID].stItinerary.Hotel.getRooms()[1].setDepositRequired( true )>
				<cfset rc.message.addError('It appears the property you are trying to book requires a prepayment. Please review the hotel payment and cancellation policy and submit your booking again.')>
			<cfelse>
				<cfset rc.message.addError(errorList)>
			</cfif>
			<!--- <cfif rc.saveProfile>
				<cfset fw.getBeanFactory().getBean('UserService').saveProfile( User = rc.Traveler )>
			</cfif> --->
			<cfset variables.fw.redirect('summary?searchID=#rc.searchID#')>
		</cfif>

<cfabort />

		<cfreturn />
	</cffunction>

</cfcomponent>