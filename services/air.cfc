<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="LowFare">
	<cfproperty name="Availability">
	<cfproperty name="AirSearch">

	<cffunction name="init" output="false" hint="Init method.">
		<cfargument name="LowFare">
		<cfargument name="Availability">
		<cfargument name="AirSearch">

		<cfset setLowFare(arguments.LowFare)>
		<cfset setAvailability(arguments.Availability)>
		<cfset setAirSearch(arguments.AirSearch)>

		<cfreturn this>
	</cffunction>

	<cffunction name="doSearch" output="false">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="Filter" required="false" default="X">
		<cfargument name="SearchID" default="">
		<cfargument name="Group" default="">
		<cfargument name="SelectedTrip" default="">
		<cfargument name="SearchType" default="AirSearch"><!--- Options:  AirSearch, LowFare, Availability, Both --->
		<cfargument name="refundable" required="false" default="false">

		<cfset var start = 0>
		<cfset var AvailabilityResponse = {}>
		<cfset var LowFareResponse = {}>
		<cfset var AirSearchResponse = {}>
		<cfset var trips = {}>

		<cfif arguments.SearchType EQ 'Availability'
			OR arguments.SearchType EQ 'Both'>

			<cfset start = getTickCount()>
			<cfset AvailabilityResponse = Availability.doAvailabilitySearch(Account = arguments.Account,
													Filter = arguments.Filter,
													SearchID = arguments.SearchID,
													Group = arguments.Group )>
			<cfset trips.Profiling.KrakenFlightSearchAvailability = (getTickCount() - start) / 1000>

		</cfif>

		<cfif arguments.SearchType EQ 'LowFare'
			OR arguments.SearchType EQ 'Both'>

			<cfset start = getTickCount()>
			<cfset LowFareResponse = LowFare.doLowFareSearch(Account = arguments.Account,
													Policy = arguments.Policy,
													Filter = arguments.Filter,
													SearchID = arguments.SearchID,
													Group = arguments.Group,
													SelectedTrip = arguments.SelectedTrip,
													refundable = arguments.refundable )>
			<cfset trips.Profiling.KrakenFlightSearchByTrip = (getTickCount() - start) / 1000>

		</cfif>

		<cfif arguments.SearchType EQ 'AirSearch'>

			<cfset start = getTickCount()>
			<cfset AirSearchResponse = AirSearch.doAirSearch(Account = arguments.Account,
															Policy = arguments.Policy,
															Filter = arguments.Filter,
															SearchID = arguments.SearchID,
															Group = arguments.Group,
															SelectedTrip = arguments.SelectedTrip,
															refundable = arguments.refundable )>
			<cfset trips.Profiling.KrakenAirSearch = (getTickCount() - start) / 1000>

			<!--- <cfdump var=#AirSearchResponse.Errors# abort>
			<cfdump var=#structKeyList(AirSearchResponse)# abort> --->
			<cfset AvailabilityResponse = arrayLen(AirSearchResponse.AirAvailabilityResponses) ? AirSearchResponse.AirAvailabilityResponses[arguments.Group+1] : {}>
			<cfset LowFareResponse = AirSearchResponse.LowFareResponse>

		</cfif>

		<!--- <cfdump var=#local.LowFareResponse.FlightSearchResults[1]# abort> --->

		<cfif arguments.SearchType EQ 'LowFare'
			OR arguments.SearchType EQ 'AirSearch'
			OR arguments.SearchType EQ 'Both'>

			<cfset start = getTickCount()>
			<cfset trips.BrandedFares = LowFare.parseBrandedFares( response = local.LowFareResponse )>
			<cfset trips.Profiling.BrandedFares = (getTickCount() - start) / 1000>

			<cfset start = getTickCount()>
			<cfset trips.Segments = LowFare.parseSegments( 	response = local.LowFareResponse,
															Group = arguments.Group )>
			<cfset trips.Profiling.Segments = (getTickCount() - start) / 1000>

		<cfelse>

			<cfset trips.BrandedFares = {}>
			<cfset trips.Segments = {}>

		</cfif>

		<cfif (arguments.SearchType EQ 'Availability'
			OR arguments.SearchType EQ 'AirSearch'
			OR arguments.SearchType EQ 'Both')
			AND NOT structIsEmpty(AvailabilityResponse)>

			<cfset start = getTickCount()>
			<cfset trips.Segments = Availability.parseSegments( Segments = trips.Segments,
															response = local.AvailabilityResponse,
															Group = arguments.Group )>
			<cfset trips.Profiling.Segments = (getTickCount() - start) / 1000>

		</cfif>

		<cfif arguments.SearchType EQ 'LowFare'
			OR arguments.SearchType EQ 'AirSearch'
			OR arguments.SearchType EQ 'Both'>

			<cfset start = getTickCount()>
			<cfset trips.Fares = LowFare.parseFares( response = local.LowFareResponse,
											BrandedFares = trips.BrandedFares )>
			<cfset trips.Profiling.Fares = (getTickCount() - start) / 1000>

			<cfset start = getTickCount()>
			<cfset trips.SegmentFares = LowFare.parseSegmentFares(	response = local.LowFareResponse,
														Fares = trips.Fares,
														Group = arguments.Group,
														SelectedTrip = arguments.SelectedTrip )>
			<cfset trips.Profiling.SegmentFares = (getTickCount() - start) / 1000>

			<cfset start = getTickCount()>
			<cfset trips.Segments = LowFare.parsePoorSegments(	Segments = trips.Segments,
														SegmentFares = trips.SegmentFares,
														Group = arguments.Group )>
			<cfset trips.Profiling.SegmentFares = (getTickCount() - start) / 1000>

		<cfelse>

			<cfset trips.Fares = {}>
			<cfset trips.SegmentFares = {}>

		</cfif>

		<cfif arguments.Group EQ 0>
			<cfset session.LowestFare = LowFare.getLowestFare(SegmentFares = trips.SegmentFares)>
		</cfif>

		<cfreturn trips>
 	</cffunction>
 	
</cfcomponent>