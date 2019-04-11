<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="UAPIFactory">
	<cfproperty name="uAPISchemas">
	<cfproperty name="AirParse">
	<cfproperty name="KrakenService">
	<cfproperty name="Storage">

	<cffunction name="init" output="false" hint="Init method.">
		<cfargument name="UAPIFactory">
		<cfargument name="uAPISchemas">
		<cfargument name="AirParse">
		<cfargument name="KrakenService">
		<cfargument name="Storage">

		<cfset setUAPIFactory(arguments.UAPIFactory)>
		<cfset setUAPISchemas(arguments.uAPISchemas)>
		<cfset setAirParse(arguments.AirParse)>
		<cfset setKrakenService(arguments.KrakenService)>
		<cfset setStorage(arguments.Storage)>

		<cfreturn this>
	</cffunction>

	<cffunction name="doAirSearch" output="false">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="Filter" required="false" default="X">
		<cfargument name="SearchID" default="">
		<cfargument name="Group" default="">
		<cfargument name="SelectedTrip" default="">
		<cfargument name="refundable" required="false" default="false">
		<cfargument name="cabins" default="">

		<cfset start = getTickCount()>
		<cfset local.ScheduleResponse = doAirSchedule(Account = arguments.Account,
												Filter = arguments.Filter,
												SearchID = arguments.SearchID,
												Group = arguments.Group )>
		<cfset trips.Profiling.KrakenFlightSearchAvailability = (getTickCount() - start) / 1000>

		<cfset start = getTickCount()>
		<cfset local.LowFareResponse = doAirLowFare(Account = arguments.Account,
												Policy = arguments.Policy,
												Filter = arguments.Filter,
												SearchID = arguments.SearchID,
												Group = arguments.Group,
												SelectedTrip = arguments.SelectedTrip,
												refundable = arguments.refundable )>
		<cfset trips.Profiling.KrakenFlightSearchByTrip = (getTickCount() - start) / 1000>

		<cfset start = getTickCount()>
		<cfset trips.BrandedFares = parseBrandedFares( response = local.LowFareResponse )>
		<cfset trips.Profiling.BrandedFares = (getTickCount() - start) / 1000>

		<cfset start = getTickCount()>
		<cfset trips.Segments = parseLowFareSegments( 	response = local.LowFareResponse,
														Group = arguments.Group )>
		<cfset trips.Profiling.Segments = (getTickCount() - start) / 1000>

		<cfset start = getTickCount()>
		<cfset trips.Segments = parseScheduleSegments( 	Segments = trips.Segments,
														response = local.ScheduleResponse,
														Group = arguments.Group )>
		<cfset trips.Profiling.Segments = (getTickCount() - start) / 1000>

		<cfset start = getTickCount()>
		<cfset trips.Fares = parseFares( response = local.LowFareResponse,
										BrandedFares = trips.BrandedFares )>
		<cfset trips.Profiling.Fares = (getTickCount() - start) / 1000>

		<cfset start = getTickCount()>
		<cfset trips.SegmentFares = parseSegmentFares(	response = local.LowFareResponse,
													Fares = trips.Fares,
													Group = arguments.Group,
													SelectedTrip = arguments.SelectedTrip )>
		<cfset trips.Profiling.SegmentFares = (getTickCount() - start) / 1000>

		<cfset start = getTickCount()>
		<cfset trips.Segments = parsePoorSegments(	Segments = trips.Segments,
													SegmentFares = trips.SegmentFares,
													Group = arguments.Group )>
		<cfset trips.Profiling.SegmentFares = (getTickCount() - start) / 1000>

		<cfreturn trips>
 	</cffunction>

	<cffunction name="doAirLowFare" output="false">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="Filter" required="false" default="X">
		<cfargument name="SearchID" default="">
		<cfargument name="Group" default="">
		<cfargument name="SelectedTrip" default="">

		<cfset local.requestBody = getKrakenService().getFlightSearchRequest( 	Policy = arguments.Policy,
																				Filter = arguments.Filter )>

		<cfset local.response = getStorage().getStorage(	searchID = arguments.searchID,
															request = local.requestBody )>

		<cfif structIsEmpty(local.response)>
			<cfset local.response = getKrakenService().FlightSearch(	body = local.requestBody,
																		SearchID = arguments.SearchID,
																		Group = arguments.Group,
																		SelectedTrip = arguments.SelectedTrip )>

			<cfset getStorage().storeAir(	searchID = arguments.searchID,
											request = local.requestBody,
											storage = local.response )>
		</cfif>

		<cfreturn local.response>
 	</cffunction>

	<cffunction name="doAirSchedule" output="false">
		<cfargument name="Account" required="true">
		<cfargument name="Filter" required="false" default="X">
		<cfargument name="SearchID" default="">
		<cfargument name="Group" default="">

		<cfset local.requestBody = getKrakenService().getFlightSearchAvailabilityRequest( 	Filter = arguments.Filter,
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
		</cfif>

		<cfreturn local.response>
 	</cffunction>

	<cffunction name="parseBrandedFares" returnType="struct" access="public">
		<cfargument name="response" type="any" required="true">

		<cfset var index = ''>
		<cfset var item = ''>
		<cfset var BrandedFares = {}>

		<!--- response.brandedfarenames : Create a lookup table for branded fare names. --->
		<!--- response.brandedfarenames[207174] = Branded Fare Details --->
		<cfset BrandedFares[0].Name = ''>
		<cfset BrandedFares[0].LongDescription = ''>
		<cfset BrandedFares[0].ShortDescription = ''>
		<cfloop collection="#arguments.response.BrandedFareDetails#" index="index" item="item">
			<cfset BrandedFares[item.BrandId] = item>
		</cfloop>

		<!--- <cfdump var=#BrandedFares# abort> --->

		<cfreturn BrandedFares>
	</cffunction>

	<cffunction name="parseLowFareSegments" returnType="struct" access="public">
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
		<cfset var Segments = {}>

		<!--- response.Segments : Create a distinct structure of available segments by reference key. --->
		<!--- response.Segments[G0-B6.124] = Full segment structure --->
		<cfloop collection="#arguments.response.FlightSearchResults#" index="tripIndex" item="tripItem">
			<cfloop collection="#tripItem.TripSegments#" index="segmentIndex" item="segmentItem">
				<cfif segmentItem.Group EQ arguments.Group>
					<cfset segmentCount = arrayLen(segmentItem.Flights)>
					<!--- Replace the structure with the SegmentId. --->
					<cfset Segments.TripSegments[segmentIndex] = segmentItem.SegmentId>
					<!--- Create the distinct list of legs.  Also add in some overall leg information for display purposes. --->
					<cfset Segments[segmentItem.SegmentId] 						= segmentItem>
					<cfset Segments[segmentItem.SegmentId].DepartureTime 		= segmentItem.Flights[1].DepartureTime>
					<cfset Segments[segmentItem.SegmentId].OriginAirportCode 	= segmentItem.Flights[1].OriginAirportCode>
					<cfset Segments[segmentItem.SegmentId].ArrivalTime 			= segmentItem.Flights[segmentCount].ArrivalTime>
					<cfset Segments[segmentItem.SegmentId].DestinationAirportCode = segmentItem.Flights[segmentCount].DestinationAirportCode>
					<cfset Segments[segmentItem.SegmentId].TravelTime 			= int(segmentItem.TotalTravelTimeInMinutes/60) &'H '&segmentItem.TotalTravelTimeInMinutes%60&'M'>
					<cfset Segments[segmentItem.SegmentId].Stops 				= segmentCount-1>
					<cfset Segments[segmentItem.SegmentId].Days 				= dateDiff('d', segmentItem.Flights[1].DepartureTime, segmentItem.Flights[segmentCount].ArrivalTime)>
					<cfset Segments[segmentItem.SegmentId].PlatingCarrier		= structKeyExists(tripItem.AvailableFareOptions[1], 'PlatingCarrier') ? tripItem.AvailableFareOptions[1].PlatingCarrier : segmentItem.Flights[1].CarrierCode>
					<!--- Determine the overall carrier(s) and connection(s). --->
					<cfset Carrier = ''>
					<cfset Connections = ''>
					<cfset FlightNumbers = ''>
					<cfset Codeshare = ''>
					<cfloop collection="#segmentItem.Flights#" index="flightIndex" item="flightItem">
						<cfset Carrier = listAppend(Carrier, flightItem.CarrierCode)>
						<cfif structKeyExists(flightItem, 'CodeshareInfo')>
							<cfset Codeshare = listAppend(Codeshare, flightItem.CodeshareInfo.Value)>
						</cfif>
						<cfif segmentCount NEQ flightIndex>
							<cfset Connections = listAppend(Connections, flightItem.DestinationAirportCode)>
						</cfif>
						<cfset flightItem.FlightTime = int(flightItem.FlightDurationInMinutes/60) &'H '&flightItem.FlightDurationInMinutes%60&'M'>
						<cfset structDelete(flightItem, 'DepartureTimeString')>
						<cfset structDelete(flightItem, 'ArrivalTimeString')>
						<cfset FlightNumbers = listAppend(FlightNumbers, flightItem.CarrierCode&flightItem.FlightNumber)>
					</cfloop>
					<cfset Carrier = listRemoveDuplicates(Carrier)>
					<cfset Segments[segmentItem.SegmentId].CarrierCode = listLen(Carrier) EQ 1 ? Carrier : 'Mult'>
					<cfset Segments[segmentItem.SegmentId].Codeshare = listRemoveDuplicates(Codeshare)>
					<cfset Segments[segmentItem.SegmentId].Connections = replace(Connections, ',', ', ', 'ALL')>
					<cfset Segments[segmentItem.SegmentId].FlightNumbers = replace(FlightNumbers, ',', ' / ', 'ALL')>
					<cfset Segments[segmentItem.SegmentId].IsPoorSegment = false>
					<cfset Segments[segmentItem.SegmentId].Results = 'LowFare'>
					<!--- <cfdump var=#Segments[segmentItem.SegmentId]# abort> --->
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn Segments>
	</cffunction>

	<cffunction name="parseScheduleSegments" returnType="struct" access="public">
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
				<cfset Segment.DepartureTime 		= segmentItem[1].DepartureTime>
				<cfset Segment.OriginAirportCode 	= segmentItem[1].Origin>
				<cfset Segment.ArrivalTime 			= segmentItem[flightCount].ArrivalTime>
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
					<cfset local.Flight.OriginAirportCode = flightItem.Origin>
					<cfset Flight.DepartureTime = flightItem.DepartureTime>
					<cfset Flight.DestinationAirportCode = flightItem.Destination>
					<cfset Flight.ArrivalTime = flightItem.ArrivalTime>
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
			<cfelse>
				<cfset Segments[SegmentId].ScheduleOnly = 'Both'>
			</cfif>
		</cfloop>

		<cfreturn Segments>
	</cffunction>

	<cffunction name="parseFares" returnType="struct" access="public">
		<cfargument name="response" type="any" required="true">
		<cfargument name="BrandedFares" type="any" required="true">

		<cfset var tripIndex = ''>
		<cfset var tripItem = ''>
		<cfset var fareIndex = ''>
		<cfset var fareItem = ''>
		<cfset var bookingIndex = ''>
		<cfset var bookingItem = ''>
		<cfset var groupIndex = ''>
		<cfset var groupItem = ''>
		<cfset var flightIndex = ''>
		<cfset var flightItem = ''>
		<cfset var segmentCount = ''>
		<cfset var Carrier = ''>
		<cfset var Connections = ''>
		<cfset var FlightNumbers = ''>
		<cfset var SegmentFareId = ''>
		<cfset var BookingDetails = {}>
		<cfset var CabinDetails = {}>
		<cfset var Details = {}>
		<cfset var Fares = {}>

		<!--- response.Fares : Create a distinct structure of available fares by reference key. --->
		<!--- response.Fares[G0-B6.124.S|G1-B6.23.S] = Full fare structure. --->
		<cfloop collection="#arguments.response.FlightSearchResults#" index="tripIndex" item="tripItem">
			<cfloop collection="#tripItem.AvailableFareOptions#" index="fareIndex" item="fareItem">
				<cfset BookingDetails = structNew('linked')>
				<cfset CabinDetails = structNew()>
				<cfloop collection="#fareItem.BookingDetails#" index="bookingIndex" item="bookingItem">
					<cfset bookingItem.PartOfSegmentFareId = bookingItem.CarrierCode&'.'&bookingItem.FlightNumber&'.'&bookingItem.BookingCode>
					<cfset bookingItem.PartOfSegmentId = bookingItem.CarrierCode&'.'&bookingItem.FlightNumber>
					<cfparam name="BookingDetails[#bookingItem.Group#]" default="#structNew('linked')#">
					<cfparam name="CabinDetails[#bookingItem.Group#].CabinCodes" default="">
					<cfparam name="CabinDetails[#bookingItem.Group#].BrandedFareNames" default="">
					<cfparam name="CabinDetails[#bookingItem.Group#].SegmentId" default="">
					<cfparam name="CabinDetails[#bookingItem.Group#].BrandedFareIds" default="">
					<cfset BookingDetails[bookingItem.Group][bookingItem.PartOfSegmentFareId] = bookingItem>
					<cfset BrandedFareBrandId = structKeyExists(bookingItem, 'BrandedFareBrandId') ? bookingItem.BrandedFareBrandId : 0>
					<cfset BookingDetails[bookingItem.Group][bookingItem.PartOfSegmentFareId].BrandedFareName = arguments.BrandedFares[BrandedFareBrandId].Name>
					<cfset CabinDetails[bookingItem.Group].CabinCodes = listAppend(CabinDetails[bookingItem.Group].CabinCodes, bookingItem.CabinClass)>
					<cfset CabinDetails[bookingItem.Group].BrandedFareNames = listAppend(CabinDetails[bookingItem.Group].BrandedFareNames, arguments.BrandedFares[BrandedFareBrandId].Name)>
					<cfset CabinDetails[bookingItem.Group].BrandedFareIds = listAppend(CabinDetails[bookingItem.Group].BrandedFareIds, BrandedFareBrandId)>
					<cfset CabinDetails[bookingItem.Group].SegmentId = listAppend(CabinDetails[bookingItem.Group].SegmentId, bookingItem.PartOfSegmentId, '-')>
				</cfloop>
				<cfset Details = structNew('linked')>
				<cfloop collection="#BookingDetails#" index="groupIndex" item="groupItem">
					<cfset SegmentFareId = 'G#groupIndex#-'&structKeyList(groupItem, '-')>
					<cfset Details[SegmentFareId].Details = []>
					<cfloop collection="#groupItem#" index="flightIndex" item="flightItem">
						<cfset arrayAppend(Details[SegmentFareId].Details, flightItem)>
					</cfloop>
					<cfset Details[SegmentFareId].CabinCode = listRemoveDuplicates(CabinDetails[groupIndex].CabinCodes)>
					<cfset Details[SegmentFareId].BrandedFareName = listRemoveDuplicates(CabinDetails[groupIndex].BrandedFareNames)>
					<cfset Details[SegmentFareId].BrandedFareId = listRemoveDuplicates(CabinDetails[groupIndex].BrandedFareIds)>
					<cfset Details[SegmentFareId].SegmentId = 'G#groupIndex#-'&CabinDetails[groupIndex].SegmentId>
				</cfloop>
				<cfset structDelete(fareItem, 'SegmentFareIds')>
				<cfset structDelete(fareItem, 'BookingDetails')>
				<cfset FareKey = structKeyList(Details, '|')>
				<cfset Fares[FareKey] = fareItem>
				<cfset Fares[FareKey].BookingDetails = Details>
			</cfloop>
		</cfloop>

		<!--- <cfdump var=#Fares# abort> --->

		<cfreturn Fares>
	</cffunction>

	<cffunction name="parseSegmentFares" returnType="struct" access="public">
		<cfargument name="response" type="any" required="true">
		<cfargument name="Fares" type="any" required="true">
		<cfargument name="Group" type="any" required="true">
		<cfargument name="SelectedTrip" type="any" required="true">

		<cfset var fareIndex = ''>
		<cfset var fareItem = ''>
		<cfset var groupIndex = ''>
		<cfset var groupItem = ''>
		<cfset var SegmentFares = {}>

		<cfset SelectedSegmentFareID = ''>
		<cfset SelectedSegmentID = ''>
		<cfset SelectedRefundable = ''>
		<cfloop collection="#arguments.SelectedTrip#" index="selectedGroupIndex" item="selectedGroupItem">
			<cfif NOT structIsEmpty(selectedGroupItem)>
				<cfset SelectedSegmentFareID = listAppend(SelectedSegmentFareID, selectedGroupItem.SegmentFareID, '|')>
				<cfset SelectedSegmentID = listAppend(SelectedSegmentID, selectedGroupItem.SegmentID, '|')>
				<cfset SelectedRefundable = selectedGroupItem.Refundable>
			</cfif>
		</cfloop>
		<!--- response.SegmentFares : Create a table for G0 lowest fares by cabin and branded fare. --->
		<!--- response.SegmentFares[AS.2289,AS.1076][Economy][RefundableMain][TotalFare] = 1369.6 --->
		<cfset var SegmentFares = {}>
		<!--- <cfset SelectedSegmentFareId = 'G0-AS.2075.B-AS.1424.B-AS.6308.B'> --->
		<!--- G0-AS.2289.B-AS.442.H-AS.4624.H --->
		<cfif arguments.Group EQ 0
			OR SelectedSegmentFareID NEQ ''>
			<cfloop collection="#arguments.Fares#" index="fareIndex" item="fareItem">
				<cfif fareIndex CONTAINS SelectedSegmentFareID>
					<cfloop collection="#fareItem.BookingDetails#" index="groupIndex" item="groupItem">
						<cfif left(groupIndex, 2) EQ 'G#arguments.Group#'
							AND (SelectedRefundable EQ ''
									OR SelectedRefundable EQ fareItem.IsRefundable ? 1 : 0)>
							<!--- Branded fare level : Lowest economy comfort prices. --->
							<cfif NOT structKeyExists(SegmentFares, groupItem.SegmentId)
								OR NOT structKeyExists(SegmentFares[groupItem.SegmentId], groupItem.CabinCode)
								OR NOT structKeyExists(SegmentFares[groupItem.SegmentId][groupItem.CabinCode], groupItem.BrandedFareName)
								OR ( SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].TotalFare GT fareItem.TotalFare.Value
									AND fareItem.IsBookable )>

								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].TotalFare = fareItem.TotalFare.Value>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].Refundable = fareItem.IsRefundable ? 1 : 0>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].PrivateFare = fareItem.IsPrivateFare>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].OutOfPolicy = fareItem.OutOfPolicy>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].OutOfPolicyReason = fareItem.OutOfPolicyReason>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].BrandedFareId = groupItem.BrandedFareId>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].Bookable = fareItem.IsBookable>
							</cfif>
							<!--- Cabin level : Lowest economy/business/first prices. --->
							<cfif NOT structKeyExists(SegmentFares, groupItem.SegmentId)
								OR NOT structKeyExists(SegmentFares[groupItem.SegmentId], groupItem.CabinCode)
								OR NOT structKeyExists(SegmentFares[groupItem.SegmentId][groupItem.CabinCode], 'TotalFare')
								OR ( SegmentFares[groupItem.SegmentId][groupItem.CabinCode].TotalFare GT fareItem.TotalFare.Value
									AND fareItem.IsBookable )>

								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode].TotalFare = fareItem.TotalFare.Value>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode].SegmentFareId = groupIndex>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode].SegmentId = groupItem.SegmentId>

							</cfif>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn SegmentFares>
	</cffunction>

	<cffunction name="parsePoorSegments" returnType="struct" access="public">
		<cfargument name="Segments" type="any" required="true">
		<cfargument name="SegmentFares" type="any" required="true">
		<cfargument name="Group" type="any" required="true">

		<cfset var fareIndex = ''>
		<cfset var fareItem = ''>
		<cfset var cabinIndex = ''>
		<cfset var cabinItem = ''>
		<cfset var segmentIndex = ''>
		<cfset var segmentItem = ''>
		<cfset var SegmentIdAlt = ''>
		<cfset var TempSegments = {}>
		<cfset var Economy = {}>
		<cfset var Lowest = {}>

		<cfloop collection="#arguments.SegmentFares#" index="fareIndex" item="fareItem">
			<cfif structKeyExists(fareItem, 'Economy')>
				<cfset Economy = {}>
				<cfset Economy.TotalFare = fareItem.Economy.TotalFare>
				<cfset Economy.TotalTravelTimeInMinutes = Segments[fareItem.Economy.SegmentId].TotalTravelTimeInMinutes>
				<cfset Economy.CarrierCode =Segments[fareItem.Economy.SegmentId].CarrierCode>
				<cfset Economy.SegmentId = fareItem.Economy.SegmentId>
				<cfset DepartureTime = Segments[fareItem.Economy.SegmentId].DepartureTime>
				<cfparam name="TempSegments['#Segments[#fareItem.Economy.SegmentId#].DepartureTime&Economy.CarrierCode#']" default="#arrayNew()#">
				<cfset arrayAppend(TempSegments[Segments[fareItem.Economy.SegmentId].DepartureTime&Economy.CarrierCode], Economy)>
			</cfif>
		</cfloop>

		<cfloop collection="#TempSegments#" index="depatureIndex" item="depatureItem">
			<cfloop collection="#depatureItem#" index="segmentIndex" item="segmentItem">
				<cfif NOT structKeyExists(Lowest, depatureIndex)
					OR Lowest[depatureIndex].TotalFare GT segmentItem.TotalFare>
					<cfset Lowest[depatureIndex].TotalFare = segmentItem.TotalFare>
					<cfset Lowest[depatureIndex].TotalTravelTimeInMinutes = segmentItem.TotalTravelTimeInMinutes>
					<cfset Lowest[depatureIndex].SegmentId = segmentItem.SegmentId>
				</cfif>
			</cfloop>
		</cfloop>

		<cfloop collection="#arguments.SegmentFares#" index="segmentIndex" item="segmentItem">
			<cfif structKeyExists(segmentItem, 'Economy')>
				<cfset departureIndex = Segments[segmentItem.Economy.SegmentId].DepartureTime&Segments[segmentItem.Economy.SegmentId].CarrierCode>
				<cfif structKeyExists(segmentItem, 'Economy')
					AND Lowest[departureIndex].TotalFare LT segmentItem.Economy.TotalFare
					AND Lowest[departureIndex].TotalTravelTimeInMinutes LT Segments[segmentItem.Economy.SegmentId].TotalTravelTimeInMinutes>
					<cfset arguments.Segments[segmentItem.Economy.SegmentId].IsPoorSegment = true>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn arguments.Segments>
	</cffunction>
 	
</cfcomponent>
