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

	<cffunction name="doAvailabilitySearch" output="false">
		<cfargument name="Account" required="true">
		<cfargument name="Filter" required="false" default="X">
		<cfargument name="SearchID" default="">
		<cfargument name="Group" default="">

		<cfset local.requestBody = getFlightSearchAvailabilityRequest( 	Filter = arguments.Filter,
																		Group = arguments.Group )>

		<cfset local.response = getStorage().getStorage(	searchID = arguments.searchID,
															request = local.requestBody )>

		<cfif structIsEmpty(local.response)>
			<cfset local.response = getKrakenService().FlightSearchAvailability(body = local.requestBody,
																				SearchID = arguments.SearchID,
																				Group = arguments.Group)>

			<cfset getStorage().store(	searchID = arguments.searchID,
											request = local.requestBody,
											storage = local.response )>
		</cfif>

		<cfreturn local.response>
 	</cffunction>

	<cffunction name="getFlightSearchAvailabilityRequest" returnType="struct" access="public">
		<cfargument name="Filter" type="struct" required="yes">
		<cfargument name="Group" type="numeric" required="yes">

		<cfscript>
			var requestBody = {};
			var leg = {};
			requestBody.Identity = {
				ArrangerId = Filter.getUserID(),
				TravelerName = Filter.getProfileUsername(),
				SearchId = Filter.getSearchID(),
				AccountId = Filter.getAcctID(),
				TravelerId = Filter.getProfileID(),
				IsGuestTraveler = Filter.getProfileID() EQ 0 ? true : false,
				GuestTravelerDepartmentId = Filter.getValueID(),
				//CandidateTravelerId = '',
				//CandidateTravelerDepartmentId = '',
				TravelerDepartmentId = Filter.getValueID()
			};
			requestBody["FlightSearchOptions"] = {};
			if (arguments.Filter.getAirlines() NEQ '') {
				requestBody.FlightSearchOptions.AirLinesWhiteList = [arguments.Filter.getAirlines()];
			}
			requestBody["Leg"] = [];
			arrayappend(requestBody["Leg"], getLeg(arguments.Filter, arguments.Group) );

			requestBody.FlightSearchOptions = {

				DoubleInterlineCon : false,
				DoubleOnlineCon : true,
				MaxConnections : 1,
				MaxStops : 1,
				NonStopDirects : true,
				RequireSingleCarrier : true,
				SingleInterlineCon : true,
				SingleOnlineCon : true,
				StopDirects : true,
				TripleInterlineCon : false,
				TripleOnlineCon : false,
				AllowChangeOfAirport : false,
				DistanceType : "MI",
				ExcludeGroundTransportation : false, 
				ExcludeOpenJawAirport : false, 
				IncludeExtraSolutions : false,
				IncludeFlightDetails : true,
				JetServiceOnly : false,
				MaxConnectionTime : 300, //Conn time in minutes
				MaxJourneyTime : 20, //Journey time in hours
				OrderBy : "JourneyTime" , //Can be ommitted, journey time is default
				PreferNonStop : true,
				ProhibitMultiAirportConnection : true,
				ProhibitOvernightLayovers : false,
				SearchWeekends : false
			}
			
		</cfscript>

		<cfreturn requestBody>
	</cffunction>

	<cffunction name="getLeg" returnType="struct" access="public">
		<cfargument name="Filter" type="struct" required="yes">
		<cfargument name="legIndex" type="numeric" required="yes">

		<cfscript>

			var leg = {};

			if (arguments.LegIndex EQ 0) {

				leg["TimeRangeType"]	= arguments.filter.getDepartTimeType() EQ "A" ? "ArrivalTime" : "DepartureTime";

				if (arguments.filter.getDepartDateTimeActual() EQ "Anytime") {

					leg["TimeRangeStart"] =	dateFormat(arguments.filter.getDepartDateTime(), 'yyyy-mm-dd') & "T00:00:00.000Z";
					leg["TimeRangeEnd"] =	dateFormat(arguments.filter.getDepartDateTime(), 'yyyy-mm-dd') & "T23:59:00.000Z";

				} else {

					leg["TimeRangeStart"] =	dateFormat(arguments.filter.getDepartDateTimeStart(), 'yyyy-mm-dd') & 'T' & timeFormat(arguments.filter.getDepartDateTimeStart(), 'HH:mm:ss.lll') & "Z";
					leg["TimeRangeEnd"] =	dateFormat(arguments.filter.getDepartDateTimeEnd(), 'yyyy-mm-dd') & 'T' & timeFormat(arguments.filter.getDepartDateTimeEnd(), 'HH:mm:ss.lll') & "Z";

				}

				leg["OriginAirportCode"] = { "Code": arguments.Filter.getDepartCity(), "IsCity": isBoolean(arguments.filter.getAirFromCityCode()) && arguments.filter.getAirFromCityCode() ? true : false};
				leg["DestinationAirportCode"] = { "Code": arguments.Filter.getArrivalCity(), "IsCity": isBoolean(arguments.filter.getAirToCityCode()) && arguments.filter.getAirToCityCode() ? true : false};

			} else {

				leg["TimeRangeType"]	= arguments.filter.getDepartTimeType() EQ "A" ? "ArrivalTime" : "DepartureTime";

				if (arguments.filter.getDepartDateTimeActual() EQ "Anytime") {

					leg["TimeRangeStart"] =	dateFormat(arguments.filter.getArrivalDateTime(), 'yyyy-mm-dd') & "T00:00:00.000Z";
					leg["TimeRangeEnd"] =	dateFormat(arguments.filter.getArrivalDateTime(), 'yyyy-mm-dd') & "T23:59:00.000Z";

				} else {

					leg["TimeRangeStart"] =	dateFormat(arguments.filter.getArrivalDateTimeStart(), 'yyyy-mm-dd') & 'T' & timeFormat(arguments.filter.getArrivalDateTimeStart(), 'HH:mm:ss.lll') & "Z";
					leg["TimeRangeEnd"] = dateFormat(arguments.filter.getArrivalDateTimeEnd(), 'yyyy-mm-dd') & 'T' & timeFormat(arguments.filter.getArrivalDateTimeEnd(), 'HH:mm:ss.lll') & "Z";

				}

				leg["OriginAirportCode"] = { "Code" :arguments.Filter.getArrivalCity(), "IsCity": isBoolean(arguments.filter.getAirToCityCode()) && arguments.filter.getAirToCityCode() ? true : false};
				leg["DestinationAirportCode"] = { "Code" :arguments.Filter.getDepartCity(), "IsCity": isBoolean(arguments.filter.getAirFromCityCode()) && arguments.filter.getAirFromCityCode() ? true : false};

			}

		</cfscript>

		<cfreturn leg>

	</cffunction>

	<cffunction name="parseSegments" returnType="struct" access="public">
		<cfargument name="Segments" type="any" required="true">
		<cfargument name="response" type="any" required="true">
		<cfargument name="Group" type="any" required="true">
		<cfargument name="CarrierCode" type="any" required="false" default="">

		<cfset var CarrierCode = arguments.CarrierCode>
		<cfset var CarriersToDisplay = 'All'>
		<cfset var NonArc = ''>
		<cfset var segmentIndex = ''>
		<cfset var segmentItem = ''>
		<cfset var SegmentId = ''>
		<cfset var flightIndex = ''>
		<cfset var flightItem = ''>
		<cfset var flightCount = ''>
		<cfset var Carrier = ''>
		<cfset var Connections = ''>
		<cfset var FlightNumbers = ''>
		<cfset var Codeshare = ''>
		<cfset var Flights = []>
		<cfset var Flight = {}>
		<cfset var BookingCodeIndex = ''>
		<cfset var BookingCode = ''>

		<cfset var segmentCount = ''>
		<cfset var Segments = arguments.Segments>

		<cfif listFind('WN,F9,NK,G4', CarrierCode)>
			<cfset CarriersToDisplay = 'NonArc Only'>
		<cfelseif CarrierCode NEQ ''>
			<cfset CarriersToDisplay = 'Hide NonArc'>
		</cfif>

		<!--- <cfdump var=#response# abort="true"> --->

		<!--- response.Segments : Create a distinct structure of available segments by reference key. --->
		<!--- response.Segments[G0-B6.124] = Full segment structure --->
		<cfloop collection="#arguments.response.Results#" index="segmentIndex" item="segmentItem">

			<cfset local.SegmentId = ''>
			<cfset local.Carriers = ''>
			<cfloop collection="#segmentItem#" index="flightIndex" item="flightItem">
				<cfset SegmentId = listAppend(SegmentId, flightItem.Carrier&'.'&flightItem.FlightNumber, '-')>
				<cfset Carriers = listAppend(Carriers, flightItem.Carrier)>
			</cfloop>
			<cfset SegmentId = 'G'&arguments.Group&'-'&SegmentId>

			<cfset NonArc = false>
			<cfif listFind('WN,F9,NK,G4', listRemoveDuplicates(Carriers))>
				<cfset NonArc = true>
			</cfif>

			<cfif NOT structKeyExists(Segments, SegmentId)
					AND (CarriersToDisplay EQ 'All'
						OR (CarriersToDisplay EQ 'NonArc Only'
							AND listRemoveDuplicates(Carriers) EQ arguments.CarrierCode)
						OR (CarriersToDisplay EQ 'Hide NonArc'
							AND NOT NonArc))>

				<cfset flightCount = arrayLen(segmentItem)>
				<!--- Create the distinct list of legs.  Also add in some overall leg information for display purposes. --->
				<cfset Flights = []>
				<cfset Carrier = ''>
				<cfset Connections = ''>
				<cfset FlightNumbers = ''>
				<cfset Codeshare = ''>

				<!--- Determine the overall carrier(s) and connection(s). --->
				<cfloop collection="#segmentItem#" index="flightIndex" item="flightItem">

					<cfset Flight = {}>
					<cfset Flight = {
									OriginAirportCode = flightItem.Origin,
									DepartureTimeGMT = flightItem.DepartureTime,
									DepartureTime = left(flightItem.DepartureTime, 19),
									DestinationAirportCode = flightItem.Destination,
									ArrivalTimeGMT = flightItem.ArrivalTime,
									ArrivalTime = left(flightItem.ArrivalTime, 19),
									FlightDurationInMinutes = flightItem.FlightTime,
									FlightNumber = flightItem.FlightNumber,
									CarrierCode = flightItem.Carrier,
									IsPreferred = '',
									Equipment = flightItem.Equipment,
									CabinClass = '',
									ChangeOfPlane = arrayLen(flightItem.FlightDetails) EQ 1 ? false : true,
									BookingCode = '',
									OutOfPolicy = flightItem.OutOfPolicy,
									OutOfPolicyReason = flightItem.OutOfPolicyReason,
									FlightId = flightItem.Carrier&'.'&flightItem.FlightNumber,
									FlightTime = int(flightItem.FlightTime/60) &'H '&flightItem.FlightTime%60&'M',
									Codeshare =  structKeyExists(flightItem, 'CodeshareInfo') AND structKeyExists(flightItem.CodeshareInfo, 'Value') ? flightItem.CodeshareInfo.Value : ''
								}>

					<cfset Carrier = listAppend(Carrier, flightItem.Carrier)>
					<cfif structKeyExists(flightItem, 'CodeshareInfo')
						AND structKeyExists(flightItem.CodeshareInfo, 'Value')>
						<cfset Codeshare = listAppend(Codeshare, flightItem.CodeshareInfo.Value)>
					<cfelse>
						<cfset Codeshare = ''>
					</cfif>
					<cfif flightCount NEQ flightIndex>
						<cfset Connections = listAppend(Connections, flightItem.Destination)>
					</cfif>
					<cfset FlightNumbers = listAppend(FlightNumbers, flightItem.Carrier&flightItem.FlightNumber)>
					<cfset arrayAppend(Flights, Flight)>

				</cfloop>

				<cfset Segments[SegmentId] = {
									DepartureTimeGMT : segmentItem[1].DepartureTime,
									DepartureTime : left(segmentItem[1].DepartureTime, 19),
									OriginAirportCode : segmentItem[1].Origin,
									ArrivalTimeGMT : segmentItem[flightCount].ArrivalTime,
									ArrivalTime : left(segmentItem[flightCount].ArrivalTime, 19),
									DestinationAirportCode : segmentItem[flightCount].Destination,
									TravelTime : int(segmentItem[1].TravelTime/60) &'H '&segmentItem[1].TravelTime%60&'M',
									TotalTravelTimeInMinutes : segmentItem[1].TravelTime,
									Stops : flightCount-1,
									Days : dateDiff('d', segmentItem[1].DepartureTime, segmentItem[flightCount].ArrivalTime),
									PlatingCarrier : flightItem.Carrier,
									Flights : Flights,
									CarrierCode = listLen(listRemoveDuplicates(Carrier)) EQ 1 ? listRemoveDuplicates(Carrier) : 'Mult',
									Codeshare = replace(listRemoveDuplicates(Codeshare), ',', ', ', 'ALL'),
									Connections = replace(Connections, ',', ', ', 'ALL'),
									FlightNumbers = replace(FlightNumbers, ',', ' / ', 'ALL'),
									IsLongAndExpensive = false,
									IsLongSegment = false,
									Group = arguments.Group,
									Results = 'Availability',
									SegmentId = SegmentId
								}>

			<cfelse>

				<cfset Segments[SegmentId].Results = 'Both'>

			</cfif>

			<cfloop collection="#segmentItem#" index="flightIndex" item="flightItem">

				<cfloop collection="#flightItem.AvailabilityInfos#" index="BookingCodeInfosIndex" item="BookingCodeInfos">

					<!--- <cfif BookingCodeInfos.ProviderCode EQ '1V'> --->

						<cfloop collection="#BookingCodeInfos.BookingCodeInfos#" index="BookingCodeIndex" item="BookingCode">

							<cfset Segments[SegmentId].Availability[BookingCode.CabinClass][flightItem.Carrier&'.'&flightItem.FlightNumber].String = replace(arrayToList(BookingCode.BookingCounts), ',', ', ', 'ALL')>
							<cfloop collection="#BookingCode.BookingCounts#" index="CodeIndex" item="CodeItem">
								<cfif right(CodeItem, 1) GT 0>
									<cfset Segments[SegmentId].Availability[BookingCode.CabinClass][flightItem.Carrier&'.'&flightItem.FlightNumber].Available = true>
								</cfif>
							</cfloop>

						</cfloop>

					<!--- </cfif> --->

				</cfloop>

			</cfloop>

			<cfloop collection="#Segments[SegmentId].Availability#" index="ClassIndex" item="ClassItem">

				<cfif structKeyExists(Segments, SegmentId)
					AND structKeyExists(Segments[SegmentId], 'Flights')>

					<cfset Available = 0>
					<cfset FlightCount = 0>

					<cfloop collection="#Segments[SegmentId].Flights#" index="FlightIndex" item="FlightItem">

						<cfset FlightCount++>
						<cfif structKeyExists(ClassItem, FlightItem.FlightId) 
							AND structKeyExists(ClassItem[FlightItem.FlightId], 'Available') 
							AND ClassItem[FlightItem.FlightId].Available>
							<cfset Available++>
						</cfif>

					</cfloop>

					<cfset ClassItem.Available = Available EQ FlightCount ? true : false>

				<cfelse>

					<cfset StructDelete(Segments, SegmentId)>

				</cfif>

			</cfloop>

		</cfloop>

		<cfreturn Segments>
	</cffunction>
 	
</cfcomponent>