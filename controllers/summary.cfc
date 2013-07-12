<cfcomponent>

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<!--- for testing purposes --->
		<cfparam name="session.searches[rc.searchID].stItinerary" default="#structNew()#">
		<!--- for testing purposes --->

		<!--- <cfdump var="#session.searches[rc.searchID].stItinerary#" abort="true" /> --->
		<!--- <cfset structDelete(session.searches[rc.SearchID], 'travelers')> --->

		<cfset rc.travelerNumber = 1>
		<cfset rc.itinerary = session.searches[rc.searchID].stItinerary>

		<cfset rc.hotelSelected = (structKeyExists(rc.itinerary, 'Hotel') ? true : false)>
		<cfset rc.Hotel = (structKeyExists(rc.itinerary, 'Hotel') ? rc.itinerary.Hotel : '')>

		<cfset rc.vehicleSelected = (structKeyExists(rc.itinerary, 'Vehicle') ? true : false)>
		<cfset rc.Vehicle = (structKeyExists(rc.itinerary, 'Vehicle') ? rc.itinerary.Vehicle : '')>

		<cfset rc.allTravelers = fw.getBeanFactory().getBean('UserService').getAuthorizedTravelers( rc.Filter.getProfileID(), rc.Filter.getAcctID() )>
		<cfset rc.qOutOfPolicy = fw.getBeanFactory().getBean('Summary').getOutOfPolicy( acctID = rc.Filter.getAcctID() )>
		<cfset rc.qStates = fw.getBeanFactory().getBean('Summary').getStates()>
		<cfset rc.qTXExceptionCodes = fw.getBeanFactory().getBean('Summary').getTXExceptionCodes()>

		<cfif NOT structKeyExists(session.searches[rc.SearchID], 'travelers')
			OR NOT structKeyExists(session.searches[rc.SearchID].travelers, rc.travelerNumber)>
			<!--- Stand up the default profile into an object --->
			<cfset rc.Traveler = fw.getBeanFactory().getBean('UserService').loadFullUser( rc.Filter.getProfileID(), rc.Filter.getAcctID() )>
			<cfset local.BookingDetail = createObject('component', 'booking.model.BookingDetail').init()>
			<cfset rc.Traveler.setBookingDetail( BookingDetail )>
			<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber] = rc.Traveler>
		<cfelse>
			<!--- Traveler is already in an object --->
			<cfset rc.Traveler = session.searches[rc.SearchID].travelers[rc.travelerNumber]>
		</cfif>

		<cfif structKeyExists(rc, 'trigger')>
			
			<cfset rc.Traveler.populateFromStruct( rc )>
			<cfif rc.userID NEQ 0>
				<cfset rc.Traveler.setFirstName( rc.firstName2 )>
				<cfset rc.Traveler.setLastName( rc.lastName2 )>
			</cfif>
			<cfset rc.Traveler.getBookingDetail().populateFromStruct( rc )>
			<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber] = rc.Traveler>

		</cfif>
		<!--- <cfdump var="#session.searches[rc.SearchID].travelers[rc.travelerNumber]#" abort="true" /> --->
		<!--- <cfdump var="#session.searches[rc.SearchID].travelers[rc.travelerNumber].getBookingDetail()#" abort="true" /> --->
		
		<cfreturn />
	</cffunction>

</cfcomponent>