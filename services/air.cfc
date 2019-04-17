<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="LowFare">
	<cfproperty name="Availability">
	<cfproperty name="Rail">

	<cffunction name="init" output="false" hint="Init method.">
		<cfargument name="LowFare">
		<cfargument name="Availability">
		<cfargument name="Rail">

		<cfset setLowFare(arguments.LowFare)>
		<cfset setAvailability(arguments.Availability)>
		<cfset setRail(arguments.Rail)>

		<cfreturn this>
	</cffunction>

	<cffunction name="doSearch" output="false">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="Filter" required="false" default="X">
		<cfargument name="SearchID" default="">
		<cfargument name="Group" default="">
		<cfargument name="SelectedTrip" default="">
		<cfargument name="refundable" required="false" default="false">
		<cfargument name="cabins" default="">

		<cfset start = getTickCount()>
		<cfset local.ScheduleResponse = Availability.doAvailabilitySearch(Account = arguments.Account,
												Filter = arguments.Filter,
												SearchID = arguments.SearchID,
												Group = arguments.Group )>
		<cfset trips.Profiling.KrakenFlightSearchAvailability = (getTickCount() - start) / 1000>

		<cfset start = getTickCount()>
		<cfset local.LowFareResponse = LowFare.doLowFareSearch(Account = arguments.Account,
												Policy = arguments.Policy,
												Filter = arguments.Filter,
												SearchID = arguments.SearchID,
												Group = arguments.Group,
												SelectedTrip = arguments.SelectedTrip,
												refundable = arguments.refundable )>
		<cfset trips.Profiling.KrakenFlightSearchByTrip = (getTickCount() - start) / 1000>

		<!--- <cfdump var=#local.LowFareResponse.FlightSearchResults[1]# abort> --->

		<cfset start = getTickCount()>
		<cfset trips.BrandedFares = LowFare.parseBrandedFares( response = local.LowFareResponse )>
		<cfset trips.Profiling.BrandedFares = (getTickCount() - start) / 1000>

		<cfset start = getTickCount()>
		<cfset trips.Segments = LowFare.parseSegments( 	response = local.LowFareResponse,
														Group = arguments.Group )>
		<cfset trips.Profiling.Segments = (getTickCount() - start) / 1000>

		<cfset start = getTickCount()>
		<cfset trips.Segments = Availability.parseSegments( Segments = trips.Segments,
														response = local.ScheduleResponse,
														Group = arguments.Group )>
		<cfset trips.Profiling.Segments = (getTickCount() - start) / 1000>

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

		<cfreturn trips>
 	</cffunction>
 	
</cfcomponent>