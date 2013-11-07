<cfcomponent extends="mxunit.framework.TestCase"  name="airPriceTest.cfc" output="false" hint="">
   
	<cffunction name="Setup">
		<!---Set up mock objects that the CouldYouService needs--->
     	<cfset variables.SearchManagerMock = mock() />
     	<cfset variables.CouldYouManagerMock = mock() />

     	<!--- Create the component to be tested --->
        <cfset variables.CouldYouService = createObject('component','booking.services.CouldYouService').init( variables.SearchManagerMock, variables.CouldYouManagerMock ) />
	</cffunction>

	<cffunction name="testDetermineOriginalDepartureDate">
		<cfset var airDate = parseDateTime( '2013-11-29 08:00:00.000' ) />
		<cfset var hotelDate = parseDateTime( '2013-11-29 15:00:00.000' ) />
		<cfset var carDate = parseDateTime( '2013-11-29 12:00:00.000' ) />

		<cfset makePublic( variables.CouldYouService, "determineOriginalDepartureDate" )/>

		<cfset var Search = new com.shortstravel.search.Search() />
		<cfset Search.setCarPickupDateTime( carDate ) />
		<cfset var departDate = variables.CouldYouService.determineOriginalDepartureDate( Search ) />
		<cfset assertEquals( departDate, carDate, "The method did not correctly identify the car date as the departure date for the search." ) />

		<cfset Search.setCheckInDate( hotelDate ) />
		<cfset departDate = variables.CouldYouService.determineOriginalDepartureDate( Search ) />
		<cfset assertEquals( departDate, hotelDate, "The method did not correctly identify the hotel date as the departure date for the search." ) />

		<cfset Search.setDepartDateTime( airDate ) />
		<cfset departDate = variables.CouldYouService.determineOriginalDepartureDate( Search ) />
		<cfset assertEquals( departDate, airDate, "The method did not correctly identify the air date as the departure date for the search." ) />

	</cffunction>

	<cffunction name="testCalculateAvailability">
		<cfset var trip = structNew() />
		<cfset makePublic( variables.CouldYouService, "calculateAvailability" )/>

		<cfset assertFalse( variables.CouldYouService.calculateAvailability( trip, "air" ) ) />
		<cfset assertFalse( variables.CouldYouService.calculateAvailability( trip, "hotel" ) ) />
		<cfset assertFalse( variables.CouldYouService.calculateAvailability( trip, "vehicle" ) ) />
		<cfset assertFalse( variables.CouldYouService.calculateAvailability( trip, "foo" ) ) />

		<cfset trip.air = structNew() />
		<cfset assertTrue( variables.CouldYouService.calculateAvailability( trip, "air" ) ) />
		<cfset assertFalse( variables.CouldYouService.calculateAvailability( trip, "hotel" ) ) />
		<cfset assertFalse( variables.CouldYouService.calculateAvailability( trip, "vehicle" ) ) />
		<cfset assertFalse( variables.CouldYouService.calculateAvailability( trip, "foo" ) ) />

		<cfset trip.hotel = new com.shortstravel.hotel.Hotel() />
		<cfset assertTrue( variables.CouldYouService.calculateAvailability( trip, "air" ) ) />
		<cfset assertTrue( variables.CouldYouService.calculateAvailability( trip, "hotel" ) ) />
		<cfset assertFalse( variables.CouldYouService.calculateAvailability( trip, "vehicle" ) ) />
		<cfset assertFalse( variables.CouldYouService.calculateAvailability( trip, "foo" ) ) />

		<cfset trip.vehicle = new com.shortstravel.vehicle.Vehicle() />
		<cfset assertTrue( variables.CouldYouService.calculateAvailability( trip, "air" ) ) />
		<cfset assertTrue( variables.CouldYouService.calculateAvailability( trip, "hotel" ) ) />
		<cfset assertTrue( variables.CouldYouService.calculateAvailability( trip, "vehicle" ) ) />
		<cfset assertFalse( variables.CouldYouService.calculateAvailability( trip, "foo" ) ) />

	</cffunction>

	<cffunction name="testCalculateTripDaysOffset">
		<cfset var originalDepart = createDateTime( 2013, 11, 25, 11, 00, 00 ) />

		<cfset makePublic( variables.CouldYouService, "calculateTripDaysOffset" )/>
		<cfset assertEquals( -1, variables.CouldYouService.calculateTripDaysOffset( originalDepart, createDateTime( 2013, 11, 24, 11, 00, 00 )  ), "2013, 11, 24, 11, 00, 00 failed" )/>
		<cfset assertEquals( 1, variables.CouldYouService.calculateTripDaysOffset( originalDepart, createDateTime( 2013, 11, 26, 11, 00, 00 )  ), "2013, 11, 26, 11, 00, 00 failed" )/>
		<cfset assertEquals( -7, variables.CouldYouService.calculateTripDaysOffset( originalDepart, createDateTime( 2013, 11, 18, 11, 00, 00 )  ), "2013, 11, 18, 11, 00, 00 failed" )/>
		<cfset assertEquals( 7, variables.CouldYouService.calculateTripDaysOffset( originalDepart, createDateTime( 2013, 12, 02, 11, 00, 00 )  ), "2013, 12, 02, 11, 00, 00 failed" )/>
		<cfset assertEquals( -1, variables.CouldYouService.calculateTripDaysOffset( originalDepart, createDateTime( 2013, 11, 24, 08, 00, 00 )  ), "2013, 11, 24, 08, 00, 00 failed" )/>
		<cfset assertEquals( 1, variables.CouldYouService.calculateTripDaysOffset( originalDepart, createDateTime( 2013, 11, 26, 08, 00, 00 )  ), "2013, 11, 26, 08, 00, 00 failed" )/>
		<cfset assertEquals( -7, variables.CouldYouService.calculateTripDaysOffset( originalDepart, createDateTime( 2013, 11, 18, 15, 00, 00 )  ), "2013, 11, 18, 15, 00, 00 failed" ) />
		<cfset assertEquals( 7, variables.CouldYouService.calculateTripDaysOffset( originalDepart, createDateTime( 2013, 12, 02, 15, 00, 00 )  ), "2013, 12, 02, 15, 00, 00 failed" ) />

	</cffunction>

</cfcomponent>
