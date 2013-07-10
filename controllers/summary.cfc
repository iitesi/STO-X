<cfcomponent extends="abstract">

<!---
default
--->
	<cffunction name="default" output="false">
		<cfargument name="rc">

		<!--- for testing purposes --->
		<cfparam name="session.searches[rc.searchID].stItinerary" default="#structNew()#">
		<!--- for testing purposes --->

		<cfset rc.travelerNumber = 1>
		<cfset rc.itinerary = session.searches[rc.searchID].stItinerary>

		<cfset rc.airSelected = (structKeyExists(rc.itinerary, 'Air') ? true : false)>
		<cfif structKeyExists(rc.itinerary, 'Air')>
			<!--- Air doesn't have an object to populate yet --->
			<!--- <cfset rc.Air = rc.itinerary.Air> --->
			<cfset rc.Air = ''>
		<cfelse>
			<cfset rc.Air = ''>
		</cfif>

		<cfset rc.hotelSelected = (structKeyExists(rc.itinerary, 'Hotel') ? true : false)>
		<cfif structKeyExists(rc.itinerary, 'Hotel')>
			<!--- Hotel is already in an object --->
			<cfset rc.Hotel = rc.itinerary.Hotel>
		<cfelse>
			<!--- Hotel was not selected --->
			<cfset rc.Hotel = ''>
		</cfif>

		<cfset rc.vehicleSelected = (structKeyExists(rc.itinerary, 'Car') ? true : false)>
		<cfif structKeyExists(rc.itinerary, 'Car')
			AND NOT isObject(rc.itinerary.Car)>
			<!--- Convert car into an object --->
			<cfset rc.Vehicle = fw.getBeanFactory().getBean('VehicleAdapter').load( rc.itinerary.Car )>
			<cfset rc.itinerary.Car = rc.Vehicle>
		<cfelseif structKeyExists(rc.itinerary, 'Car')
			AND isObject(rc.itinerary.Car)>
			<!--- Car is already in an object --->
			<cfset rc.Vehicle = rc.itinerary.Car>
		<cfelse>
			<!--- Car was not selected --->
			<cfset rc.Vehicle = ''>
		</cfif>

		<cfset rc.allTravelers = fw.getBeanFactory().getBean('UserService').getAuthorizedTravelers( rc.Filter.getProfileID(), rc.Filter.getAcctID() )>
		<!--- <cfset rc.OrgUnit = fw.getBeanFactory().getBean('OrgUnitService').load( acctID = rc.Filter.getAcctID()
																				, valueID = rc.Filter.getValueID()
																				, include = 'values' )> --->

<!--- <cfset rc.Payments = fw.getBeanFactory().getBean( "PaymentService" ).getUserPayments( acctID =rc.Filter.getAcctID(), userID =rc.Filter.getProfileID(), valueID = rc.Filter.getValueID() ) />

<cfdump var="#rc.Payments#" abort="true"> --->

		<cfif NOT structKeyExists(session.searches[rc.SearchID], 'travelers')
			OR NOT structKeyExists(session.searches[rc.SearchID].travelers, rc.travelerNumber)>
			<!--- Stand up the default profile into an object --->
			<cfset rc.Traveler = fw.getBeanFactory().getBean('UserService').loadFullUser( rc.Filter.getProfileID(), rc.Filter.getAcctID() )>
			<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber] = rc.Traveler>
		<cfelse>
			<!--- Traveler is already in an object --->
			<cfset rc.Traveler = session.searches[rc.SearchID].travelers[rc.travelerNumber]>
		</cfif>

<!--- <cfset structDelete(session.searches[rc.SearchID], 'travelers')> --->
<!--- <cfdump var="#rc.Traveler#" abort="true"> --->
<!--- <cfdump var="#session.searches[rc.SearchID].travelers[rc.travelerNumber]#" abort="true"> --->

<!--- <cfabort> --->
		
		<cfreturn />
	</cffunction>

</cfcomponent>