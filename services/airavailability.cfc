/**
 * AirAvailability
 *
 * @author gkernen/eperez
 * @date 6/22/17
 **/
component name="AirAvailability" extends="airavailability_old" accessors=true output=false

{
	//
	property KrakenService;
	property UAPIFactory;
	property uAPISchemas;
	property AirParse;

	public AirAvailability function init (

		required any KrakenService,
		required any UAPIFactory,
		required any uAPISchemas,
		required any AirParse

	) {

		setKrakenService(arguments.KrakenService);
		setUAPIFactory(arguments.UAPIFactory);
		setUAPISchemas(arguments.uAPISchemas);
		setAirParse(arguments.AirParse);

		return this;
	}

	public void function selectLeg (

		required numeric Group,
		required numeric SearchId,
		required any nTrip

	) {

		session.searches[arguments.SearchId].stSelected[arguments.Group] = session.searches[arguments.SearchId].stAvailTrips[arguments.Group][arguments.nTrip];

	}

	public struct function doAvailabilityNew (

		required any Filter,
		required any Group,
		required any Account,
		required any Policy,
		required any sPriority = 'High',
		required any sCabins = ''

	) {

		local.blackListedCarrierPairing = application.blackListedCarrierPairing;
		local.selectedCarriers = '';
		local.blackListedCarriers = '';

		if (structKeyExists(session.searches, arguments.Filter.getSearchID()) AND structKeyExists(session.searches[arguments.Filter.getSearchID()], "stSelected")) {

			for (var group in session.searches[arguments.Filter.getSearchID()].stSelected) {
				if (isStruct(group) AND NOT structIsEmpty(group) AND structKeyExists(group, "platingCarrier")) {
					local.selectedCarriers = listAppend(local.selectedCarriers, group.platingCarrier);
				}
			}

			for (var pairing in blackListedCarrierPairing) {
				if (listFindNoCase(local.selectedCarriers, pairing[1])) {
					local.blackListedCarriers = listAppend(local.blackListedCarriers, pairing[2]);
				}
			}
		}

		var requestBody = getRequestBody(Filter = arguments.Filter,
																		 Group = arguments.Group,
																		 Account = arguments.Account,
																		 sCabins = arguments.sCabins);
		var stTrips = {};

		if (arguments.Group EQ 0 OR NOT(StructKeyExists(session, "ktrips"))) {
			session.ktrips = getKrakenService().FlightSearch(requestBody);		
		}

		var stSegments = parseSegmentsNew(arguments.Group);

		local.tempTrips = parseConnectionsNew(stSegments);

		local.tempTrips	= getAirParse().addGroups(local.tempTrips, 'Avail', arguments.Filter);

		local.tempTrips = getAirParse().removeInvalidTrips(trips=local.tempTrips, filter=arguments.Filter, tripTypeOverride='OW', chosenGroup=arguments.group);

		local.tempTrips = getAirParse().addPreferred(local.tempTrips, arguments.Account);

		local.tempTrips	= getAirParse().checkPolicy(local.tempTrips, arguments.Filter.getSearchID(), '', 'Avail', arguments.Account, arguments.Policy);

		local.tempTrips	= getAirParse().addJavascript(local.tempTrips, 'Avail');

		local.tempTrips = getAirParse().removeBlackListedCarriers(local.tempTrips, local.BlackListedCarriers);

		local.stTrips = local.tempTrips;

		return local.stTrips;

	}

	public struct function getRequestBody (

		required any Filter,
		required any Group,
		required any Account,
		required any sCabins = ''

	) {

		var requestBody = {};
		var leg = {};

		local.airlines = [];

		if ( len(trim(arguments.Filter.getAirlines())) ) {

			local.airlines = arguments.Filter.getAirlines();

		}

		if (isArray(arguments.sCabins)) {

			 local.aCabins = arguments.sCabins;

		} else if  (ListLen(arguments.sCabins) GT 0) {

			 local.aCabins = ListToArray(arguments.sCabins);

		} else {

			 local.aCabins =[];

		}

		requestBody["TravelerAccountId"] = arguments.Filter.getAcctID();
		requestBody["TargetBranch"] = arguments.Account.sBranch;
		requestBody["TravelerName"] = "John Doe";
		requestBody["DetailLevel"] = "Full";
		requestBody["FlightSearchOptions"] = {};
		requestBody["FlightSearchOptions"]["AirLinesWhiteList"]	= local.airlines;
		requestBody["FlightSearchOptions"]["PreferredCabinClass"] = CabinClassMap(arguments.sCabins[1]);
		requestBody["Legs"] = [];

		if (arguments.Filter.getAirType() EQ 'OW') {

			arrayappend(requestBody["Legs"],getLeg(arguments.Filter,0));

		} else if (arguments.Filter.getAirType() EQ 'RT') {

			arrayappend(requestBody["Legs"],getLeg(arguments.Filter,0));
			arrayappend(requestBody["Legs"],getLeg(arguments.Filter,1));

		} else if (arguments.Filter.getAirType() EQ 'MD') {

			local.qLegs = arguments.filter.getLegs();

			for (var i = 1; i <= local.qLegs.recordCount; i++) {

				leg = {};

				leg["TimeRangeType"] = "DepartureTime";

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


		return requestBody;
	}

	public struct function getLeg (

		required any Filter,
		required any legIndex

	) {

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

			leg["OriginAirportCode"] = { "Code": arguments.Filter.getDepartCity(), "IsCity": arguments.filter.getAirFromCityCode()  ? true : false};
			leg["DestinationAirportCode"] = { "Code": arguments.Filter.getArrivalCity(), "IsCity": arguments.filter.getAirToCityCode()  ? true : false};

		} else {

			leg["TimeRangeType"]	= arguments.filter.getDepartTimeType() EQ "A" ? "ArrivalTime" : "DepartureTime";

			if (arguments.filter.getDepartDateTimeActual() EQ "Anytime") {

				leg["TimeRangeStart"] =	dateFormat(arguments.filter.getArrivalDateTime(), 'yyyy-mm-dd') & "T00:00:00.000Z";
				leg["TimeRangeEnd"] =	dateFormat(arguments.filter.getArrivalDateTime(), 'yyyy-mm-dd') & "T23:59:00.000Z";

			} else {

				leg["TimeRangeStart"] =	dateFormat(arguments.filter.getArrivalDateTimeStart(), 'yyyy-mm-dd') & 'T' & timeFormat(arguments.filter.getArrivalDateTimeStart(), 'HH:mm:ss.lll') & "Z";
				leg["TimeRangeEnd"] =	dateFormat(arguments.filter.getArrivalDateTimeEnd(), 'yyyy-mm-dd') & 'T' & timeFormat(arguments.filter.getArrivalDateTimeEnd(), 'HH:mm:ss.lll') & "Z";

			}

			leg["OriginAirportCode"] = {"Code" :arguments.Filter.getArrivalCity(), "IsCity": arguments.filter.getAirToCityCode()  ? true : false};
			leg["DestinationAirportCode"] = { "Code" :arguments.Filter.getDepartCity(), "IsCity": arguments.filter.getAirFromCityCode()  ? true : false};

		}

		return leg;
	}

	public struct function parseSegmentsNew (

		required any Group

	) {

		var stSegments = structNew('linked');
		var route = 0;
		var j = 1;

		stSegments[local.route] = structNew('linked');

		for (var t = 1; t <= arrayLen(session.ktrips.FlightSearchResults); t++) {

			var source = session.ktrips.FlightSearchResults[t].FlightSearchResultSource;

			for (var s = 1; s <= arrayLen(session.ktrips.FlightSearchResults[t].TripSegments); s++) {

				local.Group = session.ktrips.FlightSearchResults[t].TripSegments[s].Group;

				if (local.Group EQ arguments.group) {

					for (var f = 1; f <= arrayLen(session.ktrips.FlightSearchResults[t].TripSegments[s].Flights); f++) {

						local.flight = session.ktrips.FlightSearchResults[t].TripSegments[s].FLights[f];

						local.cabinClass = local.flight.cabinClass;
						local.ChangeOfPlane = local.flight.ChangeOfPlane;
						local.dArrival = local.flight.ArrivalTime;
						local.dArrivalGMT = parseDateTime(dateFormat(local.dArrival,"yyyy-mm-dd") & "T" & timeFormat(local.dArrival,"HH:mm:ss"));
						local.dArrivalTime = parseDateTime(ListDeleteAt(local.dArrival, listLen(local.dArrival,"-"),"-"));
						local.dDeparture = local.flight.DepartureTime;
						local.dDepartureGMT = parseDateTime(dateFormat(local.dDeparture,"yyyy-mm-dd") & "T" & timeFormat(local.dDeparture,"HH:mm:ss"));
						local.dDepartureTime =  parseDateTime(ListDeleteAt(local.dDeparture, listLen(local.dDeparture,"-"),"-"));

						local.stSegments[local.route][local.j] = {
							Arrival			: local.dArrivalGMT,
							ArrivalTime		: local.dArrivalTime,
							ArrivalGMT		: local.dArrivalGMT,
							Carrier 		: local.flight.CarrierCode,
							ChangeOfPlane	: local.ChangeOfPlane,
							Departure		: local.dDeparture,
							DepartureTime	: local.dDepartureTime,
							DepartureGMT	: local.dDepartureGMT,
							Destination		: local.flight.DestinationAirportCode,
							Equipment		: local.flight.Equipment,
							FlightNumber	: local.flight.FlightNumber,
							FlightTime		: val(listGetAt(local.flight.FlightDuration,1,':')) * 60 + val(listGetAt(local.flight.FlightDuration,2,':')),
							TravelTime		: val(listGetAt(local.flight.FlightDuration,1,':')) * 60 + val(listGetAt(local.flight.FlightDuration,2,':')),
							CabinClass		: local.cabinClass,
							Group			: local.Group,
							Origin			: local.flight.OriginAirportCode,
							Source : local.source
						};

						local.j++;
					}

					if (arraylen(structKeyArray(local.stSegments[local.route])) GT 0) {

		                 local.route++;
		                 local.j = 1;
		                 local.stSegments[local.route] = structNew('linked');
		             }
				}
			}
		}

		if (arraylen(structKeyArray(local.stSegments[local.route])) EQ 0) {

			structDelete(local.stSegments, local.route);

		}

		//writeDump(local.stSegments);
		//abort;

		return local.stSegments;
	}

}
