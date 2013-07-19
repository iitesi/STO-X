<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<!--- for testing purposes --->
		<cfparam name="session.searches[rc.searchID].stItinerary" default="#structNew()#">
		<!--- <cfdump var="#session.searches[rc.searchID].stItinerary#" abort="true" /> --->
		<!--- <cfset structDelete(session.searches[rc.SearchID], 'travelers')> --->
		<!--- for testing purposes --->

		<cfparam name="rc.travelerNumber" default="1">
		<cfset rc.errors = {}>

		<cfif structKeyExists(rc, 'remove')
			AND rc.remove EQ 1>
			<cfset structDelete(session.searches[rc.searchID].Travelers, rc.travelerNumber)>
			<cfset variables.fw.redirect('summary?searchID=#rc.searchID#&travelerNumber=1')>
		</cfif>
		<cfif NOT listFind('1,2,3,4', rc.travelerNumber)>
			<cfset variables.fw.redirect('summary?searchID=#rc.searchID#&travelerNumber=1')>
		</cfif>

		<!--- <cfset local.count = 0>
		<cfloop collection="#session.searches[rc.searchID].Travelers#" index="local.travIndex" index="local.trav">
			<cfset count++>
		</cfloop> --->

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

		<cfif structKeyExists(rc, 'trigger')>
			<cfparam name="rc.noMiddleName" default="0">
			<cfparam name="rc.createProfile" default="0">
			<cfparam name="rc.saveProfile" default="0">
			<cfparam name="rc.airSaveCard" default="0">
			<cfparam name="rc.hotelSaveCard" default="0">
			<cfparam name="rc.airNeeded" default="0">
			<cfparam name="rc.hotelNeeded" default="0">
			<cfparam name="rc.carNeeded" default="0">
			<cfset rc.Traveler.populateFromStruct( rc )>
			<cfset rc.Traveler.getBookingDetail().populateFromStruct( rc )>
			<cfif len(rc.year) GT 0 AND len(rc.month) AND len(rc.day)>
				<cfset local.birthDate = createDate(rc.year, rc.month, rc.day)>
			<cfelse>
				<cfset local.birthDate = ''>
			</cfif>
			<cfif rc.airSelected>
				<cfset local.airFound = false>
				<cfloop array="#rc.Air.Carriers#" item="local.carrier">
					<cfset airFound = false>
					<cfloop array="#rc.Traveler.getLoyaltyProgram()#" item="local.program" index="programIndex">
						<cfif program.getShortCode() EQ carrier
							AND program.getCustType() EQ 'A'>
							<cfset rc.Traveler.getLoyaltyProgram()[programIndex].setAcctNum( rc['airFF#carrier#'] )>
							<cfset airFound = true>
						</cfif>
					</cfloop>
					<cfif NOT airFound>
						<cfset rc.LoyaltyProgram = fw.getBeanFactory().getBean('LoyaltyProgramService').new()>
						<cfset rc.LoyaltyProgram.setShortCode( carrier )>
						<cfset rc.LoyaltyProgram.setCustType( 'A' )>
						<cfset rc.LoyaltyProgram.setAcctNum( rc['airFF#carrier#'] )>
						<cfset arrayAppend( rc.Traveler.getLoyaltyProgram(), rc.LoyaltyProgram )>
					</cfif>
				</cfloop>
			</cfif>
			<cfif rc.hotelSelected
				OR rc.vehicleSelected>
				<cfset local.hotelFound = false>
				<cfset local.vehicleFound = false>
				<cfloop array="#rc.Traveler.getLoyaltyProgram()#" item="local.program" index="programIndex">
					<cfif rc.hotelSelected
						AND program.getShortCode() EQ rc.Hotel.getChainCode()
						AND program.getCustType() EQ 'H'>
						<cfset rc.Traveler.getLoyaltyProgram()[programIndex].setAcctNum( rc.hotelFF )>
						<cfset hotelFound = true>
					<cfelseif rc.vehicleSelected
						AND program.getShortCode() EQ rc.Vehicle.getVendorCode()
						AND program.getCustType() EQ 'C'>
						<cfset rc.Traveler.getLoyaltyProgram()[programIndex].setAcctNum( rc.carFF )>
						<cfset vehicleFound = true>
					</cfif>
				</cfloop>
				<cfif rc.hotelSelected
					AND NOT hotelFound>
					<cfset rc.LoyaltyProgram = fw.getBeanFactory().getBean('LoyaltyProgramService').new()>
					<cfset rc.LoyaltyProgram.setShortCode( rc.Hotel.getChainCode() )>
					<cfset rc.LoyaltyProgram.setCustType( 'H' )>
					<cfset rc.LoyaltyProgram.setAcctNum( rc.hotelFF )>
					<cfset arrayAppend( rc.Traveler.getLoyaltyProgram(), rc.LoyaltyProgram )>
				</cfif>
				<cfif rc.vehicleSelected
					AND NOT vehicleFound>
					<cfset rc.LoyaltyProgram = fw.getBeanFactory().getBean('LoyaltyProgramService').new()>
					<cfset rc.LoyaltyProgram.setShortCode( rc.Vehicle.getVendorCode() )>
					<cfset rc.LoyaltyProgram.setCustType( 'C' )>
					<cfset rc.LoyaltyProgram.setAcctNum( rc.carFF )>
					<cfset arrayAppend( rc.Traveler.getLoyaltyProgram(), rc.LoyaltyProgram )>
				</cfif>
			</cfif>
			<cfset local.inputName = ''>
			<cfloop array="#rc.Traveler.getOrgUnit()#" item="local.orgUnit" index="orgUnitIndex">
				<cfset inputName = orgUnit.getOUType() & orgUnit.getOUPosition()>
				<cfif orgunit.getOUFreeform()>
					<cfset rc.Traveler.getOrgUnit()[orgUnitIndex].setValueReport( rc[inputName] )>
				<cfelse>
					<cfset rc.Traveler.getOrgUnit()[orgUnitIndex].setValueID( rc[inputName] )>
				</cfif>
			</cfloop>
			<cfset rc.Traveler.setBirthdate( birthdate )>
			<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber] = rc.Traveler>
			<cfset rc.errors = fw.getBeanFactory().getBean('Summary').error( Traveler = rc.Traveler
																			, Air = rc.Air 
																			, Hotel = rc.Hotel
																			, Vehicle = rc.Vehicle
																			, Policy = rc.Policy
																			, acctID = rc.Filter.getAcctID()
																			, searchID = rc.searchID )>
			<cfif structIsEmpty(rc.errors)>
				<cfif rc.saveProfile>
					<cfset fw.getBeanFactory().getBean('UserService').saveProfile( User = rc.Traveler )>
				</cfif>
				<cfif rc.trigger EQ 'ADD A TRAVELER'>
					<cfset rc.travelerNumber = arrayLen(structKeyArray(session.searches[rc.searchID].Travelers))+1>
					<cfif rc.travelerNumber LTE 4>
						<cfset rc.travelerNumber = rc.travelerNumber>
					<cfelse>
						<cfset rc.travelerNumber = 1>
					</cfif>
					<cfset variables.fw.redirect('summary?searchID=#rc.searchID#&travelerNumber=#rc.travelerNumber#')>
				</cfif>
			</cfif>
		</cfif>
		<!--- <cfdump var="#session.searches[rc.SearchID].travelers#" abort="true" /> --->
		<!--- <cfdump var="#session.searches[rc.SearchID].travelers[rc.travelerNumber]#" abort="true" /> --->
		<!--- <cfdump var="#session.searches[rc.SearchID].travelers[rc.travelerNumber].getBookingDetail()#" abort="true" /> --->
		
		<cfreturn />
	</cffunction>

</cfcomponent>