<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<!--- for testing purposes --->
		<cfparam name="session.searches[rc.searchID].stItinerary" default="#structNew()#">
		<!--- <cfdump var="#session.searches[rc.searchID].stItinerary#" abort="true" /> --->
		<!--- <cfset structDelete(session.searches[rc.SearchID], 'travelers')> --->
		<!--- for testing purposes --->

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
				<cfif Traveler.getBookingDetail().getUniversalLocatorCode() NEQ ''>
					<cfset fw.getBeanFactory().getBean('UniversalAdapter').cancelUR( targetBranch = rc.Account.sBranch
																					, universalRecordLocatorCode = Traveler.getBookingDetail().getUniversalLocatorCode()
																					, Filter = rc.Filter )>
					<cfset fw.getBeanFactory().getBean('Purchase').cancelInvoice( searchID = rc.searchID
																					, urRecloc = Traveler.getBookingDetail().getUniversalLocatorCode() )>
					<cfset Traveler.getBookingDetail().setUniversalLocatorCode( '' )>
					<cfset Traveler.getBookingDetail().setReservationCode( '' )>
					<cfset Traveler.getBookingDetail().setAirConfirmation( '' )>
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
		<cfset rc.qOutOfPolicy = fw.getBeanFactory().getBean('Summary').getOutOfPolicy( acctID = rc.Filter.getAcctID() )>
		<cfset rc.qStates = fw.getBeanFactory().getBean('Summary').getStates()>
		<cfset rc.qTXExceptionCodes = fw.getBeanFactory().getBean('Summary').getTXExceptionCodes()>
		<cfset rc.fees = fw.getBeanFactory().getBean('Summary').determineFees(userID = rc.Filter.getUserID()
																			, acctID = rc.Filter.getAcctID()
																			, Air = rc.Air
																			, Filter = rc.Filter)>

		<cfif rc.travelerNumber EQ 1
			AND (NOT structKeyExists(session.searches[rc.SearchID], 'travelers')
			OR NOT structKeyExists(session.searches[rc.SearchID].travelers, rc.travelerNumber))>
			<!--- Stand up the default profile into an object --->
			<cfset rc.Traveler = fw.getBeanFactory().getBean('UserService').loadFullUser(userID = rc.Filter.getProfileID()
																						, acctID = rc.Filter.getAcctID()
																						, valueID = rc.Filter.getValueID()
																						, arrangerID = rc.Filter.getUserID()
																						, vendor = (rc.vehicleSelected ? rc.Vehicle.getVendorCode() : ''))>
			<cfset local.BookingDetail = createObject('component', 'booking.model.BookingDetail').init()>
			<cfset rc.Traveler.setBookingDetail( BookingDetail )>
			<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber] = rc.Traveler>
		<cfelseif NOT structKeyExists(session.searches[rc.SearchID], 'travelers')
			OR NOT structKeyExists(session.searches[rc.SearchID].travelers, rc.travelerNumber)>
			<!--- Stand up the default profile into an object --->
			<cfset rc.Traveler = fw.getBeanFactory().getBean('UserService').loadFullUser(userID = 0
																						, acctID = rc.Filter.getAcctID()
																						, valueID = rc.Filter.getValueID()
																						, arrangerID = rc.Filter.getUserID()
																						, vendor = (rc.vehicleSelected ? rc.Vehicle.getVendorCode() : ''))>
			<cfset local.BookingDetail = createObject('component', 'booking.model.BookingDetail').init()>
			<cfset rc.Traveler.setBookingDetail( BookingDetail )>
			<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber] = rc.Traveler>
		<cfelse>
			<!--- Traveler is already in an object --->
			<cfset rc.Traveler = session.searches[rc.SearchID].travelers[rc.travelerNumber]>
		</cfif>
		<cfif rc.travelerNumber EQ 1>
			<cfset rc.Traveler.getBookingDetail().setAirNeeded( (rc.airSelected ? 1 : 0) )>
			<cfset rc.Traveler.getBookingDetail().setHotelNeeded( (rc.hotelSelected ? 1 : 0) )>
			<cfset rc.Traveler.getBookingDetail().setCarNeeded( (rc.vehicleSelected ? 1 : 0) )>
		</cfif>

		<!---
		FORM SELECTED
		--->
		<cfif structKeyExists(rc, 'trigger')>
			<cfset rc.Traveler = fw.getBeanFactory().getBean('UserService').loadFullUser(userID = rc.userID
																						, acctID = rc.Filter.getAcctID()
																						, valueID = rc.Filter.getValueID()
																						, arrangerID = rc.Filter.getUserID()
																						, vendor = (rc.vehicleSelected ? rc.Vehicle.getVendorCode() : ''))>
			<cfset local.BookingDetail = createObject('component', 'booking.model.BookingDetail').init()>
			<cfset rc.Traveler.setBookingDetail( BookingDetail )>
			<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber] = rc.Traveler>
			<cfset local.originalMiddleName = rc.Traveler.getMiddleName() />
			<cfparam name="rc.noMiddleName" default="0">
			<cfparam name="rc.nameChange" default="0">
			<cfparam name="rc.createProfile" default="0">
			<cfparam name="rc.saveProfile" default="0">
			<cfparam name="rc.airSaveCard" default="0">
			<cfparam name="rc.hotelSaveCard" default="0">
			<cfparam name="rc.airNeeded" default="0">
			<cfparam name="rc.hotelNeeded" default="0">
			<cfparam name="rc.carNeeded" default="0">
			<cfset rc.Traveler.populateFromStruct( rc )>
			<cfset local.currentMiddleName = rc.Traveler.getMiddleName() />
			<!--- If profile exists and middle name has been changed --->
			<cfif isDefined("originalMiddleName") AND (currentMiddleName NEQ originalMiddleName)>
				<cfset rc.nameChange = 1 />
			</cfif>
			<cfset rc.Traveler.getBookingDetail().populateFromStruct( rc )>
			<cfif (structKeyExists(rc, "year") AND len(rc.year))
				AND (structKeyExists(rc, "month") AND len(rc.month))
				AND (structKeyExists(rc, "day") AND len(rc.day))>
				<cfset local.birthDate = createDate(rc.year, rc.month, rc.day)>
			<cfelse>
				<cfset local.birthDate = ''>
			</cfif>
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
			</cfloop>
			<cfset rc.Traveler.setBirthdate( birthdate )>
			<cfset rc.Traveler.setFirstName( REReplace(rc.Traveler.getFirstName(), '[^0-9A-Za-z]', '', 'ALL') )>
			<cfset rc.Traveler.setMiddleName( REReplace(rc.Traveler.getMiddleName(), '[^0-9A-Za-z]', '', 'ALL') )>
			<cfset rc.Traveler.setLastName( REReplace(rc.Traveler.getLastName(), '[^0-9A-Za-z]', '', 'ALL') )>
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
					<cfset variables.fw.redirect('purchase?searchID=#rc.searchID#')>
				<cfelseif rc.trigger EQ 'CREATE PROFILE'>
					<cfset local.newUserID = fw.getBeanFactory().getBean('UserService').createProfile( User = rc.Traveler
																						, acctID = rc.Filter.getAcctID() ) />
					<cfset rc.Filter.setUserID(newUserID) />
					<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber].setUserID(newUserID) />
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