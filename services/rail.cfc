<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="KrakenService">
	<cfproperty name="Storage">

	<cffunction name="init" output="false" hint="Init method.">
		<cfargument name="KrakenService">
		<cfargument name="Storage">

		<cfset setKrakenService(arguments.KrakenService)>
		<cfset setStorage(arguments.Storage)>

		<cfreturn this>
	</cffunction>

	<cffunction name="doRailSearch" output="false">
		<cfargument name="Account" required="true">
		<cfargument name="Filter" required="false" default="X">
		<cfargument name="SearchID" default="">
		<cfargument name="Group" default="">

		<!--- <cfset local.requestBody = getKrakenService().getFlightSearchAvailabilityRequest( 	Filter = arguments.Filter,
																							Group = arguments.Group )>

		<cfset local.response = getStorage().getStorage(	searchID = arguments.searchID,
															request = local.requestBody )>

		<cfif structIsEmpty(local.response)>
			<cfset local.response = getKrakenService().FlightSearchAvailability(body = local.requestBody,
																				SearchID = arguments.SearchID,
																				Group = arguments.Group)>

			<cfset getStorage().storeAir(	searchID = arguments.searchID,
											request = local.requestBody,
											storage = local.response )>
		</cfif> --->

		<cfdump var='Made it to rail' abort>

		<cfreturn local.response>
 	</cffunction>

	<cffunction name="parseSegments" returnType="struct" access="public">
		<cfargument name="Segments" type="any" required="true">
		<cfargument name="response" type="any" required="true">
		<cfargument name="Group" type="any" required="true">

		<cfset var tripIndex = ''>
		<cfset var tripItem = ''>
		<cfset var segmentIndex = ''>
		<cfset var segmentItem = ''>
		<cfset var flightIndex = ''>
		<cfset var flightItem = ''>
		<cfset var segmentCount = ''>
		<cfset var Carrier = ''>
		<cfset var Connections = ''>
		<cfset var FlightNumbers = ''>
		<cfset var Segments = arguments.Segments>

		<!--- response.Segments : Create a distinct structure of available segments by reference key. --->
		<!--- response.Segments[G0-B6.124] = Full segment structure --->
		<cfloop collection="#arguments.response.Results#" index="segmentIndex" item="segmentItem">
			<cfset Segment.DepartureTime = left(segmentItem[1].DepartureTime, 19)>
			<!--- <cfdump var=#segmentItem# abort> --->
			<cfset local.SegmentId = ''>
			<cfloop collection="#segmentItem#" index="flightIndex" item="flightItem">
				<cfset SegmentId = listAppend(SegmentId, flightItem.Carrier&'.'&flightItem.FlightNumber, '-')>
			</cfloop>
			<cfset SegmentId = 'G'&arguments.Group&'-'&SegmentId>
			<cfif NOT structKeyExists(Segments, SegmentId)>
				<cfset local.flightCount = arrayLen(segmentItem)>
				<cfset local.Segment = {}>
				<cfset Segment.Flights = []>
				<!--- Create the distinct list of legs.  Also add in some overall leg information for display purposes. --->
				<cfset Segment.DepartureTime 		= left(segmentItem[1].DepartureTime, 19)>
				<cfset Segment.OriginAirportCode 	= segmentItem[1].Origin>
				<cfset Segment.ArrivalTime 			= left(segmentItem[flightCount].ArrivalTime, 19)>
				<cfset Segment.DestinationAirportCode = segmentItem[flightCount].Destination>
				<cfset Segment.TravelTime 			= int(segmentItem[1].TravelTime/60) &'H '&segmentItem[1].TravelTime%60&'M'>
				<cfset Segment.TotalTravelTimeInMinutes = segmentItem[1].TravelTime>
				<cfset Segment.Stops 				= flightCount-1>
				<cfset Segment.Days 				= dateDiff('d', segmentItem[1].DepartureTime, segmentItem[flightCount].ArrivalTime)>
				<cfset local.Carrier = ''>
				<cfset local.Connections = ''>
				<cfset local.FlightNumbers = ''>
				<cfset local.Codeshare = ''>
				<!--- <cfset Segment.PlatingCarrier		= structKeyExists(tripItem.AvailableFareOptions[1], 'PlatingCarrier') ? tripItem.AvailableFareOptions[1].PlatingCarrier : segmentItem.Flights[1].CarrierCode> --->
				<!--- Determine the overall carrier(s) and connection(s). --->
				<cfloop collection="#segmentItem#" index="flightIndex" item="flightItem">
					<cfset local.Flight = {}>
					<cfset local.Flight.OriginAirportCode = flightItem.Origin>
					<cfset Flight.DepartureTime = left(flightItem.DepartureTime, 19)>
					<cfset Flight.DestinationAirportCode = flightItem.Destination>
					<cfset Flight.ArrivalTime = left(flightItem.ArrivalTime, 19)>
					<cfset Flight.FlightDurationInMinutes = flightItem.FlightTime>
					<cfset Flight.FlightNumber = flightItem.FlightNumber>
					<cfset Flight.CarrierCode = flightItem.Carrier>
					<cfset Flight.IsPreferred = ''>
					<cfset Flight.Equipment = flightItem.Equipment>
					<cfset Flight.CabinClass = ''>
					<cfset Flight.ChangeOfPlane = arrayLen(flightItem.FlightDetails) EQ 1 ? true : false>
					<cfset Flight.BookingCode = ''>
					<cfset Flight.OutOfPolicy = false>
					<cfset Flight.OutOfPolicyReason = []>
					<cfset Flight.FlightId = flightItem.Carrier&'.'&flightItem.FlightNumber>
					<cfset Flight.FlightTime = int(flightItem.FlightTime/60) &'H '&flightItem.FlightTime%60&'M'>
					<cfset Carrier = listAppend(Carrier, flightItem.Carrier)>
					<cfif structKeyExists(flightItem, 'CodeshareInfo')>
						<cfset Codeshare = listAppend(Codeshare, flightItem.CodeshareInfo.Value)>
					</cfif>
					<cfif flightCount NEQ flightIndex>
						<cfset Connections = listAppend(Connections, flightItem.Destination)>
					</cfif>
					<cfset FlightNumbers = listAppend(FlightNumbers, flightItem.Carrier&flightItem.FlightNumber)>
					<cfset arrayAppend(Segment.Flights, Flight)>
				</cfloop>
				<cfset Carrier = listRemoveDuplicates(Carrier)>
				<cfset Segment.CarrierCode = listLen(Carrier) EQ 1 ? Carrier : 'Mult'>
				<cfset Segment.Codeshare = listRemoveDuplicates(Codeshare)>
				<cfset Segment.Connections = replace(Connections, ',', ', ', 'ALL')>
				<cfset Segment.FlightNumbers = replace(FlightNumbers, ',', ' / ', 'ALL')>
				<cfset Segment.IsPoorSegment = false>
				<cfset Segment.Group = arguments.Group>
				<cfset Segment.Results = 'Availability'>
				<cfset Segment.SegmentId = SegmentId>
				<cfset Segments[SegmentId] = Segment>
				<!--- <cfif SegmentId CONTAINS '1957'>
					<cfdump var=#segmentItem#>
					<cfdump var=#Segments[SegmentId]#>
				</cfif> --->
			<cfelse>
				<cfset Segments[SegmentId].Results = 'Both'>
			</cfif>
			<cfloop collection="#SegmentItem[1].AvailabilityInfos[1].BookingCodeInfos#" index="local.bookingCodeIndex" item="local.BookingCode">
				<cfset Segments[SegmentId].Availability[BookingCode.CabinClass].String = replace(arrayToList(BookingCode.BookingCounts), ',', ', ', 'ALL')>
				<cfset Segments[SegmentId].Availability[BookingCode.CabinClass].Count = false>
				<cfloop collection="#BookingCode.BookingCounts#" index="local.codeIndex" item="local.codeItem">
					<cfif right(codeItem, 1) GT 0>
						<cfset Segments[SegmentId].Availability[BookingCode.CabinClass].Count = true>
					</cfif>
				</cfloop>
			</cfloop>
		</cfloop>
		<!--- <cfabort> --->

		<cfreturn Segments>
	</cffunction>
 	
</cfcomponent>