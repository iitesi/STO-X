<cfcomponent output="false" accessors="true">

	<cfproperty name="CouldYouManager"/>
	<cfproperty name="SearchManager"/>

	<cffunction name="init" access="public" output="false" returntype="any" hint="">
		<cfargument name="SearchManager" type="any" required="true" />
		<cfargument name="CouldYouManager" type="any" required="true" />

		<cfset setSearchManager( arguments.SearchManager ) />
		<cfset setCouldYouManager( arguments.CouldYouManager ) />

		<cfreturn this>
	</cffunction>

	<cffunction name="selectTrip" access="public" output="false" returntype="void" hint="">
		<cfargument name="searchId" type="numeric" required="true" />
		<cfargument name="requestedDate" type="date" required="true" />

		<cfset getCouldYouManager().selectTrip( arguments.searchId, arguments.requestedDate ) />

	</cffunction>

	<cffunction name="deleteTripsForSearch" access="public" output="false" returntype="void" hint="">
		<cfargument name="searchId" type="numeric" required="true" />

		<cfset getCouldYouManager().deleteTrips( arguments.searchId ) />

	</cffunction>

	<cffunction name="logOriginalTrip" access="public" output="false" returntype="any" hint="">
		<cfargument name="searchId" type="any" required="true" hint="Search object with original search parameters" />
		<cfargument name="trip" type="struct" required="true" hint="I am the structure of originally selected air, hotel and vehicle options for a search" />

		<cfset var Search = getSearchManager().load( arguments.searchId ) />
		<cfset var originalDepartDate = determineOriginalDepartureDate( Search ) />
		<cfset var args = structNew() />

		<cfset args.searchId = arguments.searchId />
		<cfset args.isOriginal = true />
		<cfset args.isSelected = true />
		<cfset args.isWeekendDeparture = iif( ( dayOfWeek( originalDepartDate ) EQ 1 OR dayOfWeek( originalDepartDate ) EQ 7 ), DE( true ), DE( false ) ) />
		<cfset args.departDate = createDate( year( originalDepartDate ), month( originalDepartDate ), day( originalDepartDate ) ) />
		<cfset args.daysFromOriginal = 0 />
		<cfset args.airAvailable = calculateAvailability( arguments.trip, "air" ) />
		<cfset args.hotelAvailable = calculateAvailability( arguments.trip, "hotel" ) />
		<cfset args.vehicleAvailable = calculateAvailability( arguments.trip, "vehicle" ) />

		<cfif args.airAvailable>
			<cfset args.airCost = arguments.trip.air.total  />
		<cfelse>
			<cfset args.airCost = 0  />
		</cfif>

		<cfif args.hotelAvailable>
			<cfset var HotelRoom = arguments.trip.hotel.getRooms()[ 1 ] />
			<cfif HotelRoom.getTotalForStay() NEQ 0>
				<cfset args.hotelCost = HotelRoom.getTotalForStay() />
			<cfelse>
				<cfset var nights = dateDiff( 'd', arguments.trip.hotel.getDepartureDate(), arguments.trip.hotel.getReturnDate() ) />
				<cfset args.hotelCost = arguments.trip.hotel.getRooms()[0].getDailyRate() * nights />
			</cfif>
		<cfelse>
			<cfset args.hotelCost = 0 />
		</cfif>

		<cfif args.vehicleAvailable>
			<cfset args.vehicleCost = arguments.trip.vehicle.getEstimatedTotalAmount() />
		<cfelse>
			<cfset args.vehicleCost = 0 />
		</cfif>

		<cfset args.tripCost = args.airCost + args.hotelCost + args.vehicleCost />

		<cfset getCouldYouManager().logTrip( argumentCollection = args ) />
	</cffunction>

	<cffunction name="logAlternateTrip" access="public" output="false" returntype="any" hint="">
		<cfargument name="searchId" type="any" required="true" hint="Search object with original search parameters" />
		<cfargument name="trip" type="struct" required="true" hint="Structure with air, hotel and vehicle data retrieved during a CouldYou search" />

		<cfset var Search = getSearchManager().load( arguments.searchId ) />
		<cfset var originalDepartDate = determineOriginalDepartureDate( Search ) />
		<cfset var args = structNew() />

		<cfset args.searchId = Search.getSearchID() />
		<cfset args.isOriginal = false />
		<cfset args.isSelected = false />
		<cfset args.isWeekendDeparture = iif( ( dayOfWeek( arguments.trip.requestedDate ) EQ 1 OR dayOfWeek( arguments.trip.requestedDate ) EQ 7 ), DE( true ), DE( false ) ) />
		<cfset args.departDate = createDate( year( arguments.trip.requestedDate ), month( arguments.trip.requestedDate ), day( arguments.trip.requestedDate ) ) />
		<cfset args.daysFromOriginal = calculateTripDaysOffset( originalDepartDate, arguments.trip.requestedDate ) />
		<cfset args.airAvailable = calculateAvailability( arguments.trip, "air" ) />
		<cfset args.hotelAvailable = calculateAvailability( arguments.trip, "hotel" ) />
		<cfset args.vehicleAvailable = calculateAvailability( arguments.trip, "vehicle" ) />

		<cfif structKeyExists(arguments.trip, "air") AND args.airAvailable AND NOT structKeyExists(arguments.trip.air, "FAULTMESSAGE")>
			<cfset args.airCost = arguments.trip.air[ listGetAt( structKeyList( arguments.trip.air ), 1 ) ].total  />
		<cfelse>
			<cfset args.airCost = 0  />
		</cfif>

		<cfif args.hotelAvailable>
			<cfset var HotelRoom = arguments.trip.hotel.getRooms()[ 1 ] />
			<cfif HotelRoom.getTotalForStay() NEQ 0>
				<cfset args.hotelCost = HotelRoom.getTotalForStay() />
			<cfelse>
				<cfset var nights = dateDiff( 'd', arguments.trip.hotel.getDepartureDate(), arguments.trip.hotel.getReturnDate() ) />
				<cfset args.hotelCost = arguments.trip.hotel.getRooms()[0].getDailyRate() * nights />
			</cfif>
		<cfelse>
			<cfset args.hotelCost = 0 />
		</cfif>

		<cfif args.vehicleAvailable>
			<cfset args.vehicleCost = arguments.trip.vehicle.getEstimatedTotalAmount() />
		<cfelse>
			<cfset args.vehicleCost = 0 />
		</cfif>

		<cfset args.tripCost = args.airCost + args.hotelCost + args.vehicleCost />
		<cfset args.searchStarted = arguments.trip.searchStarted  />
		<cfset args.searchEnded = arguments.trip.searchEnded />

		<cfset getCouldYouManager().logTrip( argumentCollection = args ) />

		<cfreturn args />
	</cffunction>

	<cffunction name="calculateAvailability" access="public" output="false" returntype="boolean" hint="">
		<cfargument name="trip" type="struct" required="true" />
		<cfargument name="service" type="string" required="true" hint="air|hotel|vehicle" />

		<cfset var availability = false />

		<cfif arguments.service EQ "air">
			<cfif structKeyExists( arguments.trip, "air" ) AND isStruct( arguments.trip.air )>
				<cfset availability = true />
			</cfif>
		<cfelseif arguments.service EQ "hotel">
			<cfif structKeyExists( arguments.trip, "hotel" ) AND isObject( arguments.trip.hotel )>
				<cfset availability = true />
			</cfif>
		<cfelseif arguments.service EQ "vehicle">
			<cfif structKeyExists( arguments.trip, "vehicle" ) AND isObject( arguments.trip.vehicle )>
				<cfset availability = true />
			</cfif>
		</cfif>

		<cfreturn availability />
	</cffunction>

	<cffunction name="determineOriginalDepartureDate" access="private" output="false" returntype="date" hint="">
		<cfargument name="Search" type="any" required="true" />

		<cfset var departDate = now() />

		<cfif isDate( arguments.Search.getDepartDateTime() ) >
			<cfset departDate = arguments.Search.getDepartDateTime() />
		<cfelseif isDate( arguments.Search.getCheckInDate() ) >
			<cfset departDate = arguments.Search.getCheckInDate() />
		<cfelseif isDate( arguments.Search.getCarPickupDateTime() ) >
			<cfset departDate = arguments.Search.getCarPickupDateTime() />
		<cfelse>
			<cfthrow message="Could not determine departure date for CouldYou trip" />
		</cfif>

		<cfreturn departDate />

	</cffunction>

	<cffunction name="calculateTripDaysOffset" access="private" output="false" returntype="numeric" hint="">
		<cfargument name="originalDepartDate" type="date" required="true" />
		<cfargument name="requestedDate" type="date" required="true" />

		<cfset var offset = 0 />

		<cfset var date1 = createDate( year( arguments.originalDepartDate ), month( arguments.originalDepartDate ), day( arguments.originalDepartDate ) ) />
		<cfset var date2 = createDate( year( arguments.requestedDate ), month( arguments.requestedDate ), day( arguments.requestedDate ) ) />

		<cfset offset = dateDiff( "d", date1, date2 ) />

		<cfreturn offset />
	</cffunction>
</cfcomponent>