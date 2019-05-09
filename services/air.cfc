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

			<!--- <cfdump var=#AirSearchResponse.AirAvailabilityResponses# abort> --->
			<!--- <cfdump var=#AirSearchResponse.HasErrors# label="Errors"> --->
			<!--- <cfdump var=#serializeJSON(AirSearchResponse.AirAvailabilityResponses)# abort> --->
			<cfset AvailabilityResponse = {}>
			<cfif arrayLen(AirSearchResponse.AirAvailabilityResponses)>
				<cfif IsDefined("AirSearchResponse.AirAvailabilityResponses[#arguments.Group+1#]")>
					<cfif isStruct(AirSearchResponse.AirAvailabilityResponses[arguments.Group+1])>
						<cfset AvailabilityResponse = AirSearchResponse.AirAvailabilityResponses[arguments.Group+1]>
					</cfif>
				</cfif>
			</cfif>

			<cfset LowFareResponse = AirSearchResponse.LowFareResponse>
			<!--- <cfdump var=#AirSearchResponse.LowFareResponse.HasErrors# label="Errors">
			<cfdump var=#ArrayLen(AirSearchResponse.LowFareResponse.FlightSearchResults)# abort> --->

		</cfif>

		<cfif arguments.SearchType EQ 'LowFare'
			OR arguments.SearchType EQ 'AirSearch'
			OR arguments.SearchType EQ 'Both'>

			<cfset start = getTickCount()>
			<cfset trips.BrandedFares = LowFare.parseBrandedFares( response = local.LowFareResponse )>
			<cfset trips.Profiling.BrandedFares = (getTickCount() - start) / 1000>

			<cfset start = getTickCount()>
			<cfset trips.Segments = LowFare.parseSegments( 	response = local.LowFareResponse,
															Group = arguments.Group,
															CarrierCode = arguments.Group NEQ 0 ? arguments.SelectedTrip[0].CarrierCode : '' )>
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
															Group = arguments.Group,
															CarrierCode = arguments.Group NEQ 0 ? arguments.SelectedTrip[0].CarrierCode : '' )>
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

		<cfset local.Segments = applyModifiers(Segments = StructCopy(trips.Segments),
												Leg = Filter.getLegsForTrip()[Group+1])>

		<!--- Make sure that not all flights are cleared out. --->
		<cfif NOT structIsEmpty(local.Segments)>
			<cfset trips.Segments = local.Segments>
		<cfelse>
			<cfset trips.Segments = applyMinModifiers(Segments = StructCopy(trips.Segments),
													Leg = Filter.getLegsForTrip()[Group+1])>
		</cfif>

		<cfif arguments.Group EQ 0>
			<cfset session.LowestFare = LowFare.getLowestFare(SegmentFares = trips.SegmentFares)>
		</cfif>

		<cfreturn trips>
 	</cffunction>

	<cffunction name="applyModifiers" output="false">
		<cfargument name="Segments" required="true">
		<cfargument name="Leg" required="true">

		<cfset var Segments = arguments.Segments>
		<cfset var Leg = arguments.Leg>
		<cfset var HideSegments = ''>
		<cfset var Hide = false>
		<cfset var Count = 0>
		<cfset var PreviousFlight = ''>

		<cfloop collection="#Segments#" index="local.SegmentIndex" item="local.Segment">

			<cfset Hide = false>

			<!--- Hide Two Layovers/Three Flights --->
			<cfif arrayLen(Segment.Flights) GTE 3>
				<cfset Hide = true>
				<cfset HideSegments = ListAppend(HideSegments, SegmentIndex, '|')>
			</cfif>

			<!--- Hide Segments Over 24 Hours --->
			<cfif NOT Hide
				AND Segment.TotalTravelTimeInMinutes GT 1440>
				<cfset Hide = true>
				<cfset HideSegments = ListAppend(HideSegments, SegmentIndex, '|')>
			</cfif>

			<!--- Hide Multi Carrier Segments --->
			<cfif NOT Hide
				AND Segment.CarrierCode EQ 'Mult'>
				<cfset Hide = true>
				<cfset HideSegments = ListAppend(HideSegments, SegmentIndex, '|')>
			</cfif>

			<!--- Hide Layovers Longer Than 5 Hours --->
			<cfif NOT Hide
				AND arrayLen(Segment.Flights) GT 1>

				<cfloop collection="#Segment.Flights#" index="flightIndex" item="Flight">
					<cfset Count++>
					<cfif Count NEQ 1>
						<cfif dateDiff('n', previousFlight.ArrivalTime, Flight.DepartureTime) GT 300>
							<cfset Hide = true>
							<cfset HideSegments = ListAppend(HideSegments, SegmentIndex, '|')>
						</cfif>
					</cfif>
					<cfset PreviousFlight = Flight>
				</cfloop>

			</cfif>

			<!--- Hide Incorrect City Pairs --->
			<!--- <cfif NOT Hide
				AND Leg DOES NOT CONTAIN Segment.OriginAirportCode&' - '&Segment.DestinationAirportCode>
				<cfset Hide = true>
				<cfset HideSegments = ListAppend(HideSegments, SegmentIndex, '|')>
			</cfif> --->

			<!--- Hide Results In Availability Only --->
			<cfif NOT Hide
				AND Segment.Results EQ 'Availability'>
				<cfset Hide = true>
				<cfset HideSegments = ListAppend(HideSegments, SegmentIndex, '|')>
			</cfif>

			<!--- Hide Results In LowFare Only --->
			<cfif NOT Hide
				AND Segment.Results EQ 'LowFare'>
				<cfset Hide = true>
				<cfset HideSegments = ListAppend(HideSegments, SegmentIndex, '|')>
			</cfif>

		</cfloop>

		<cfloop list="#HideSegments#" index="local.SegmentId" delimiters="|">
			<cfset StructDelete(Segments, SegmentId)>
		</cfloop>

		<!--- <cfdump var=#Segments# abort> --->

		<cfreturn Segments>
 	</cffunction>

	<cffunction name="applyMinModifiers" output="false">
		<cfargument name="Segments" required="true">
		<cfargument name="Leg" required="true">

		<cfset var Segments = arguments.Segments>
		<cfset var Leg = arguments.Leg>
		<cfset var HideSegments = ''>
		<cfset var Hide = false>
		<cfset var Count = 0>
		<cfset var PreviousFlight = ''>

		<cfloop collection="#Segments#" index="local.SegmentIndex" item="local.Segment">

			<cfset Hide = false>

			<!--- Hide Incorrect City Pairs --->
			<cfif NOT Hide
				AND Leg DOES NOT CONTAIN Segment.OriginAirportCode&' - '&Segment.DestinationAirportCode>
				<cfset Hide = true>
				<cfset HideSegments = ListAppend(HideSegments, SegmentIndex, '|')>
			</cfif>

			<!--- Hide Results In Availability Only --->
			<cfif NOT Hide
				AND Segment.Results EQ 'Availability'>
				<cfset Hide = true>
				<cfset HideSegments = ListAppend(HideSegments, SegmentIndex, '|')>
			</cfif>

			<!--- Hide Results In LowFare Only --->
			<cfif NOT Hide
				AND Segment.Results EQ 'LowFare'>
				<cfset Hide = true>
				<cfset HideSegments = ListAppend(HideSegments, SegmentIndex, '|')>
			</cfif>

		</cfloop>

		<cfloop list="#HideSegments#" index="local.SegmentId" delimiters="|">
			<cfset StructDelete(Segments, SegmentId)>
		</cfloop>

		<!--- <cfdump var=#Segments# abort> --->

		<cfreturn Segments>
 	</cffunction>
 	
</cfcomponent>