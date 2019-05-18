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

	<cffunction name="doLowFareSearch" output="false">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="Filter" required="false" default="X">
		<cfargument name="SearchID" default="">
		<cfargument name="Group" default="">
		<cfargument name="SelectedTrip" default="">

		<cfset local.requestBody = getFlightSearchRequest( 	Policy = arguments.Policy,
															Filter = arguments.Filter )>

		<cfset local.response = getStorage().getStorage(	searchID = arguments.searchID,
															request = local.requestBody )>

		<cfif structIsEmpty(local.response)>
			<cfset local.response = getKrakenService().FlightSearch(	body = local.requestBody,
																		SearchID = arguments.SearchID,
																		Group = arguments.Group,
																		SelectedTrip = arguments.SelectedTrip )>

			<cfif structIsEmpty(response)>
				Known error.  Waiting on log access before this can be fixed.
				<cfdump var=#serializeJSON(local.requestBody)#>
				<cfdump var=#local.requestBody#>
				<cfdump var=#local.response# abort>
			</cfif>

			<cfset getStorage().store(	searchID = arguments.searchID,
											request = local.requestBody,
											storage = local.response )>
		</cfif>

		<cfreturn local.response>
 	</cffunction>

	<cffunction name="getFlightSearchRequest" returnType="struct" access="public">
		<cfargument name="Policy" type="struct" required="yes">
		<cfargument name="Filter" type="struct" required="yes">

		<cfscript>
			var requestBody = {};
			var leg = {};

			local.Refundable = false;
			if (arguments.Policy.Policy_AirRefRule EQ 1 AND arguments.Policy.Policy_AirNonRefRule EQ 0) {
				local.Refundable = true;
			}

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

			requestBody["Legs"] = [];

			if (arguments.Filter.getAirType() EQ 'OW') {

				arrayappend(requestBody["Legs"],getLeg(arguments.Filter,0));

			} else if (arguments.Filter.getAirType() EQ 'RT') {

				arrayappend(requestBody["Legs"],getLeg(arguments.Filter,0));
				arrayappend(requestBody["Legs"],getLeg(arguments.Filter,1));

			} else if (arguments.Filter.getAirType() EQ 'MD') {

				local.qLegs = arguments.filter.getLegs()[1];

				for (var i = 1; i <= local.qLegs.recordCount; i++) {

					leg = {};

					leg["TimeRangeType"]="DepartureTime";

					if (local.qLegs["Depart_DateTimeActual"][i] EQ "Anytime") {

						leg["TimeRangeStart"] =	dateFormat(local.qLegs["Depart_DateTime"][i], 'yyyy-mm-dd') & "T00:00:00.000Z";
						leg["TimeRangeEnd"] =	dateFormat(local.qLegs["Depart_DateTime"][i], 'yyyy-mm-dd') & "T23:59:00.000Z";

					} else {

						leg["TimeRangeStart"] =	dateFormat(local.qLegs["Depart_DateTimeStart"][i], 'yyyy-mm-dd') & 'T' & timeFormat(local.qLegs["Depart_DateTimeStart"][i], 'HH:mm:ss.lll') & "Z";
						leg["TimeRangeEnd"] =	dateFormat(local.qLegs["Depart_DateTimeEnd"][i], 'yyyy-mm-dd') & 'T' & timeFormat(local.qLegs["Depart_DateTimeEnd"][i], 'HH:mm:ss.lll') & "Z";
					}

					leg["OriginAirportCode"] = { "Code" : local.qLegs["Depart_City"][i] , "IsCity": local.qLegs["airFrom_CityCode"][i] ? true : false};
					leg["DestinationAirportCode"] = { "Code" : local.qLegs["Arrival_City"][i] , "IsCity": local.qLegs["airTo_CityCode"][i] ? true : false};

					arrayAppend(requestBody["Legs"], leg);

				}

			}

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
				SearchWeekends : false,
				OnlyRefundableFares = local.Refundable
			}

			if (arguments.Filter.getAirlines() NEQ '') {
				requestBody.FlightSearchOptions.AirLinesWhiteList = [arguments.Filter.getAirlines()];
			}
		</cfscript>

		<!--- <cfdump var=#serializeJSON(requestBody)# abort> --->

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

	<cffunction name="parseBrandedFares" returnType="struct" access="public">
		<cfargument name="response" type="any" required="true">

		<cfset var index = ''>
		<cfset var item = ''>
		<cfset var BrandedFares = {}>

		<cftry>
			<!--- response.brandedfarenames : Create a lookup table for branded fare names. --->
			<!--- response.brandedfarenames[207174] = Branded Fare Details --->
			<cfset BrandedFares[0].Name = ''>
			<cfset BrandedFares[0].LongDescription = ''>
			<cfset BrandedFares[0].ShortDescription = ''>
			<cfloop collection="#arguments.response.BrandedFareDetails#" index="index" item="item">
				<cfset BrandedFares[item.BrandId] = item>
			</cfloop>
			<cfcatch>
				<cfdump var=#serializeJSON(response)#>
				<cfdump var=#response# abort>
			</cfcatch>
		</cftry>

		<!--- <cfdump var=#BrandedFares# abort> --->

		<cfreturn BrandedFares>
	</cffunction>

	<cffunction name="parseSegments" returnType="struct" access="public">
		<cfargument name="response" type="any" required="true">
		<cfargument name="Group" type="any" required="true">
		<cfargument name="CarrierCode" type="any" required="true">

		<cfset var CarrierCode = arguments.CarrierCode>
		<cfset var CarriersToDisplay = 'All'>
		<cfset var NonArc = ''>
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
		<cfset var Layover = ''>
		<cfset var LayoverTime = ''>
		<cfset var Segments = {}>

		<cfif listFind('WN,F9,NK,G4', CarrierCode)>
			<cfset CarriersToDisplay = 'NonArc Only'>
		<cfelseif CarrierCode NEQ ''>
			<cfset CarriersToDisplay = 'Hide NonArc'>
		</cfif>

		<!--- response.Segments : Create a distinct structure of available segments by reference key. --->
		<!--- response.Segments[G0-B6.124] = Full segment structure --->
		<cfloop collection="#arguments.response.FlightSearchResults#" index="tripIndex" item="tripItem">

			<cfloop collection="#tripItem.TripSegments#" index="segmentIndex" item="segmentItem">

				<cfset NonArc = false>
				<cfif listFind('WN,F9,NK,G4', segmentItem.Flights[1].CarrierCode)>
					<cfset NonArc = true>
				</cfif>

				<cfif segmentItem.Group EQ arguments.Group
					AND (CarriersToDisplay EQ 'All'
						OR (NOT structKeyExists(application.stBlacklistedCarriers, arguments.CarrierCode)
							OR NOT structKeyExists(application.stBlacklistedCarriers[arguments.CarrierCode], segmentItem.Flights[1].CarrierCode)
							AND ((CarriersToDisplay EQ 'NonArc Only'
									AND segmentItem.Flights[1].CarrierCode EQ arguments.CarrierCode)
								OR (CarriersToDisplay EQ 'Hide NonArc'
									AND NOT NonArc))))>

					<cfset segmentCount = arrayLen(segmentItem.Flights)>
					<!--- Replace the structure with the SegmentId. --->
					<!--- <cfset Segments.TripSegments[segmentIndex] = segmentItem.SegmentId> --->
					<!--- Create the distinct list of legs.  Also add in some overall leg information for display purposes. --->
					<cfset Segments[segmentItem.SegmentId] 						= segmentItem>
					<cfset Segments[segmentItem.SegmentId].DepartureTimeGMT 	= left(segmentItem.Flights[1].DepartureTimeString, 29)>
					<cfset Segments[segmentItem.SegmentId].DepartureTime 		= left(segmentItem.Flights[1].DepartureTimeString, 19)>
					<cfset Segments[segmentItem.SegmentId].OriginAirportCode 	= segmentItem.Flights[1].OriginAirportCode>
					<cfset Segments[segmentItem.SegmentId].ArrivalTimeGMT 		= left(segmentItem.Flights[1].ArrivalTimeString, 29)>
					<cfset Segments[segmentItem.SegmentId].ArrivalTime 			= left(segmentItem.Flights[segmentCount].ArrivalTimeString, 19)>
					<cfset Segments[segmentItem.SegmentId].DestinationAirportCode = segmentItem.Flights[segmentCount].DestinationAirportCode>
					<cfset Segments[segmentItem.SegmentId].TravelTime 			= int(segmentItem.TotalTravelTimeInMinutes/60) &'H '&segmentItem.TotalTravelTimeInMinutes%60&'M'>
					<cfset Segments[segmentItem.SegmentId].Stops 				= segmentCount-1>
					<cfset Segments[segmentItem.SegmentId].Days 				= dateDiff('d', left(segmentItem.Flights[1].DepartureTimeString, 19), left(segmentItem.Flights[segmentCount].ArrivalTimeString, 19))>
					<cfset Segments[segmentItem.SegmentId].PlatingCarrier		= segmentItem.Flights[segmentCount].CarrierCode>
					<!--- Determine the overall carrier(s) and connection(s). --->
					<cfset Carrier = ''>
					<cfset Connections = ''>
					<cfset FlightNumbers = ''>
					<cfset Codeshare = ''>
					<cfset Layover = ''>
					<cfloop collection="#segmentItem.Flights#" index="flightIndex" item="flightItem">
						<cfset Carrier = listAppend(Carrier, flightItem.CarrierCode)>
						<cfif structKeyExists(flightItem, 'CodeshareInfo')
							AND structKeyExists(flightItem.CodeshareInfo, 'Value')>
							<cfset Codeshare = listAppend(Codeshare, flightItem.CodeshareInfo.Value)>
						<cfelse>
							<cfset Codeshare = ''>
						</cfif>
						<cfif segmentCount NEQ flightIndex>
							<cfset Connections = listAppend(Connections, flightItem.DestinationAirportCode)>
						</cfif>
						<cfset flightItem.FlightTime = int(flightItem.FlightDurationInMinutes/60) &'H '&flightItem.FlightDurationInMinutes%60&'M'>
						<cfset FlightNumbers = listAppend(FlightNumbers, flightItem.CarrierCode&flightItem.FlightNumber)>
						<cfset flightItem.DepartureTimeGMT		= left(flightItem.DepartureTimeString, 29)>
						<cfset flightItem.DepartureTime 		= left(flightItem.DepartureTimeString, 19)>
						<cfset flightItem.ArrivalTimeGMT		= left(flightItem.ArrivalTimeString, 29)>
						<cfset flightItem.ArrivalTime 			= left(flightItem.ArrivalTimeString, 19)>
						<cfif flightIndex NEQ 1>
							<cfset LayoverTime = dateDiff('n', segmentItem.Flights[flightIndex-1].ArrivalTime, FlightItem.DepartureTime)>
							<cfset Layover = listAppend(Layover, segmentItem.Flights[flightIndex-1].DestinationAirportCode & ' ' & int(LayoverTime/60) & 'H ' & LayoverTime%60 & 'M')>
						</cfif>
						<cfset structDelete(flightItem, 'DepartureTimeString')>
						<cfset structDelete(flightItem, 'ArrivalTimeString')>
					</cfloop>
					<cfset Carrier = listRemoveDuplicates(Carrier)>
					<cfset Segments[segmentItem.SegmentId].CarrierCode = listLen(Carrier) EQ 1 ? Carrier : 'Mult'>
					<cfset Segments[segmentItem.SegmentId].Codeshare = replace(listRemoveDuplicates(Codeshare), ',', ', ', 'ALL')>
					<cfset Segments[segmentItem.SegmentId].Connections = replace(Connections, ',', ', ', 'ALL')>
					<cfset Segments[segmentItem.SegmentId].FlightNumbers = replace(FlightNumbers, ',', ' / ', 'ALL')>
					<cfset Segments[segmentItem.SegmentId].Layover = replace(Layover, ',', ' <br> ', 'ALL')>
					<cfset Segments[segmentItem.SegmentId].IsLongAndExpensive = false>
					<cfset Segments[segmentItem.SegmentId].IsLongSegment = false>
					<cfset Segments[segmentItem.SegmentId].Results = 'LowFare'>
					<!--- <cfdump var=#Segments[segmentItem.SegmentId]# abort> --->
				</cfif>
			</cfloop>
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

			<!--- <cfif tripItem.TripSegments[1].Flights[1].FlightNumber EQ '1991'>
				<cfdump var=#tripItem# abort>
			</cfif> --->

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
					<cfset Details[SegmentFareId].SegmentFareId = SegmentFareId>

				</cfloop>
				<cfset structDelete(fareItem, 'SegmentFareIds')>
				<cfset structDelete(fareItem, 'BookingDetails')>
				<cfset FareKey = structKeyList(Details, '|')>
				<cfset Fares[FareKey] = fareItem>
				<cfset Fares[FareKey].BookingDetails = Details>

			</cfloop>

		</cfloop>

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
			<cfif NOT structIsEmpty(selectedGroupItem)
				AND selectedGroupIndex LT arguments.Group>
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
		<!--- <cfdump var=#SelectedSegmentFareID# abort> --->
		<cfif arguments.Group EQ 0
			OR SelectedSegmentFareID NEQ ''>
			<cfloop collection="#arguments.Fares#" index="fareIndex" item="fareItem">
				<!--- <cfif fareIndex CONTAINS 'DL.3862'
					AND fareIndex CONTAINS 'DL.3513'>
					<cfdump var=#fareIndex#>
					<cfdump var=#fareItem#>
				</cfif> --->
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
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].IsPrivateFare = fareItem.IsPrivateFare>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].OutOfPolicy = fareItem.OutOfPolicy>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].OutOfPolicyReason = fareItem.OutOfPolicyReason>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].BrandedFareId = groupItem.BrandedFareId>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].Bookable = fareItem.IsBookable>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].SegmentFareId = groupItem.SegmentFareId>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].Details = groupItem.Details>
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
		<cfset var ShortestTravelTime = 100000>

		<!--- Mark segments as poor if they are longer and more expensive. --->
		<cfloop collection="#arguments.SegmentFares#" index="fareIndex" item="fareItem">
			<cfif structKeyExists(fareItem, 'Economy')>
				<cfset Economy = {
					TotalFare = fareItem.Economy.TotalFare,
					SegmentId = fareItem.Economy.SegmentId,
					TotalTravelTimeInMinutes = '',
					CarrierCode = ''
				}/>
				<cfset DepartureTime = ''/>
				<cfif structKeyExists(Segments, fareItem.Economy.SegmentId)>>
					<cfset Economy.TotalTravelTimeInMinutes = Segments[fareItem.Economy.SegmentId].TotalTravelTimeInMinutes/>
					<cfset Economy.CarrierCode = Segments[fareItem.Economy.SegmentId].CarrierCode/>
					<cfset DepartureTime = Segments[fareItem.Economy.SegmentId].DepartureTime/>
				</cfif>
				<cfparam name="TempSegments['#Segments[#fareItem.Economy.SegmentId#].DepartureTime&Economy.CarrierCode#']" default="#arrayNew()#">
				<cfset arrayAppend(TempSegments[Segments[fareItem.Economy.SegmentId].DepartureTime&Economy.CarrierCode], Economy)>
			</cfif>
		</cfloop>

		<cfloop collection="#TempSegments#" index="depatureIndex" item="depatureItem">
			<cfloop collection="#depatureItem#" index="segmentIndex" item="segmentItem">
				<cfif NOT structKeyExists(Lowest, depatureIndex)
					OR Lowest[depatureIndex].TotalFare GT segmentItem.TotalFare
					OR (Lowest[depatureIndex].TotalFare EQ segmentItem.TotalFare
						AND Lowest[depatureIndex].TotalTravelTimeInMinutes GT segmentItem.TotalTravelTimeInMinutes)>
					<cfset Lowest[depatureIndex].TotalFare = segmentItem.TotalFare>
					<cfset Lowest[depatureIndex].TotalTravelTimeInMinutes = segmentItem.TotalTravelTimeInMinutes>
					<cfset Lowest[depatureIndex].SegmentId = segmentItem.SegmentId>
				</cfif>
			</cfloop>
		</cfloop>

		<cfloop collection="#arguments.SegmentFares#" index="segmentIndex" item="segmentItem">
			<cfif structKeyExists(segmentItem, 'Economy')
				AND segmentItem.Economy.SegmentId CONTAINS '2544'>
				<cfset departureIndex = Segments[segmentItem.Economy.SegmentId].DepartureTime&Segments[segmentItem.Economy.SegmentId].CarrierCode>
				<cfif Lowest[departureIndex].TotalFare LTE segmentItem.Economy.TotalFare
					AND Lowest[departureIndex].TotalTravelTimeInMinutes LT Segments[segmentItem.Economy.SegmentId].TotalTravelTimeInMinutes>
					<cfset arguments.Segments[segmentItem.Economy.SegmentId].IsLongAndExpensive = true>
				</cfif>
			</cfif>
		</cfloop>

		<!--- Mark segments as poor if they are twice as long as the shortest route. --->

		<cfloop collection="#Segments#" index="segmentIndex" item="segmentItem">
			<cftry>
			<cfif ShortestTravelTime GT segmentItem.TotalTravelTimeInMinutes>
				<cfset ShortestTravelTime = segmentItem.TotalTravelTimeInMinutes>
			</cfif>
			<cfcatch>
			<cfdump var=#Segments# abort>
			</cfcatch>
		</cftry>
		</cfloop>

		<cfset ShortestTravelTime = ShortestTravelTime * 2>

		<cfloop collection="#Segments#" index="segmentIndex" item="segmentItem">
			<cfif ShortestTravelTime LTE segmentItem.TotalTravelTimeInMinutes>
				<cfset arguments.Segments[segmentIndex].IsLongSegment = true>
			</cfif>
		</cfloop>

		<cfreturn arguments.Segments>
	</cffunction>

	<cffunction name="getLowestFare" returnType="any" access="public">
		<cfargument name="SegmentFares" type="any" required="true">

		<cfset var SegmentFares = arguments.SegmentFares>
		<cfset var LowestFare = 1000000>
		<cfset var TripIndex = ''>
		<cfset var TripItem = ''>
		<cfset var CabinIndex = ''>
		<cfset var CabinItem = ''>

		<cfloop collection="#SegmentFares#" index="TripIndex" item="TripItem">

			<cfloop collection="#TripItem#" index="CabinIndex" item="CabinItem">

				<cfif CabinItem.TotalFare LTE LowestFare>
					<cfset LowestFare = CabinItem.TotalFare>
				</cfif>

			</cfloop>

		</cfloop>

		<cfreturn LowestFare />
	</cffunction>
 	
</cfcomponent>