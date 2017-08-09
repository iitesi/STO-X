/**
 * AirAvailability
 *
 * @author gkernen/eperez
 * @date 6/22/17
 **/
component name="AirAvailability" extends="airavailability_old" accessors=true output=false

{

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

		required any Refundable,
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

		local.Refundable = (arguments.Refundable NEQ 'X' AND arguments.Refundable) ? true : false;

		if (arguments.Policy.Policy_AirRefRule EQ 1 AND arguments.Policy.Policy_AirRefDisp EQ 1) {
			local.Refundable = true;
		}

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

		local.mergedTrips = {};

		local.key = getKrakenService().getKey(Refundable = local.Refundable,
																		 Filter = arguments.Filter,
																		 Account = arguments.Account,
																		 sCabins = arguments.sCabins);

		if ( NOT(StructKeyExists(session, "KrakenSearchResults")) OR
				 NOT(StructKeyExists(session.KrakenSearchResults, "key")) OR
				 session.KrakenSearchResults.key NEQ local.key OR
         arguments.Group EQ 0 ) {

			if (len(trim(arguments.Filter.getAirlines()))) {

				local.airlines = [arguments.Filter.getAirlines()];

			} else {

				local.airlines = ['ALL','AA','UA','DL','WN'];

			}

			for(local.i = 1; local.i LTE ArrayLen(local.airlines); i++) {

				local.requestBody = getKrakenService().getRequestSearchBody( AllowNonRefundable = !local.Refundable,
																																		 Filter = arguments.Filter,
																																		 Account = arguments.Account,
																																		 sCabins = arguments.sCabins,
																																		 airlines = [local.airlines[i]]);


				local.mergedTrips = getKrakenService().mergeResults(local.mergedTrips,getKrakenService().FlightSearch(local.requestBody));

			}

			session.KrakenSearchResults = StructNew();
			session.KrakenSearchResults.trips = local.mergedTrips;
			session.KrakenSearchResults.key = local.key;

		}

		local.stSegments = parseSegmentsNew(arguments.Group);

		local.tempTrips = parseConnectionsNew(local.stSegments);

		local.tempTrips	= getAirParse().addGroups(local.tempTrips, 'Avail', arguments.Filter);

		local.tempTrips = getAirParse().removeInvalidTrips(trips=local.tempTrips, filter=arguments.Filter, tripTypeOverride='OW', chosenGroup=arguments.group);

		local.tempTrips = getAirParse().addPreferred(local.tempTrips, arguments.Account);

		local.tempTrips	= getAirParse().checkPolicy(local.tempTrips, arguments.Filter.getSearchID(), '', 'Avail', arguments.Account, arguments.Policy);

		local.tempTrips	= getAirParse().addJavascript(local.tempTrips, 'Avail');

		local.tempTrips = getAirParse().removeBlackListedCarriers(local.tempTrips, local.BlackListedCarriers);

		local.stTrips = local.tempTrips;

		return local.stTrips;

	}

	public struct function parseSegmentsNew (

		required any Group

	) {

		var stSegments = structNew('linked');
		var route = 0;
		var j = 1;

		stSegments[local.route] = structNew('linked');

		for (var t = 1; t <= arrayLen(session.KrakenSearchResults.trips.FlightSearchResults); t++) {

			local.sourceX = session.KrakenSearchResults.trips.FlightSearchResults[t].FlightSearchResultSource;

			for (var s = 1; s <= arrayLen(session.KrakenSearchResults.trips.FlightSearchResults[t].TripSegments); s++) {

				local.Group = session.KrakenSearchResults.trips.FlightSearchResults[t].TripSegments[s].Group;

				local.TravelTime = session.KrakenSearchResults.trips.FlightSearchResults[t].TripSegments[s].TotalTravelTimeInMinutes;

				if (local.Group EQ arguments.group) {

					for (var f = 1; f <= arrayLen(session.KrakenSearchResults.trips.FlightSearchResults[t].TripSegments[s].Flights); f++) {

						local.flight = session.KrakenSearchResults.trips.FlightSearchResults[t].TripSegments[s].FLights[f];

						local.cabinClass = local.flight.cabinClass;
						local.ChangeOfPlane = local.flight.ChangeOfPlane;
						local.dArrival = local.flight.ArrivalTime;
						local.dArrivalGMT = parseDateTime(dateFormat(local.dArrival,"yyyy-mm-dd") & "T" & timeFormat(local.dArrival,"HH:mm:ss"));
						local.dArrivalTime = parseDateTime(ListDeleteAt(local.dArrival, listLen(local.dArrival,"-"),"-"));
						local.dDeparture = local.flight.DepartureTime;
						local.dDepartureGMT = parseDateTime(dateFormat(local.dDeparture,"yyyy-mm-dd") & "T" & timeFormat(local.dDeparture,"HH:mm:ss"));
						local.dDepartureTime =  parseDateTime(ListDeleteAt(local.dDeparture, listLen(local.dDeparture,"-"),"-"));

						local.stSegments[local.route][local.j] = {
							Arrival			: local.dArrival,
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
							FlightTime		: local.flight.FlightDurationInMinutes,
							TravelTime		: local.TravelTime,
							CabinClass		: local.cabinClass,
							Group			: local.Group,
							Origin			: local.flight.OriginAirportCode,
							Source 			: local.sourceX
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

		return local.stSegments;
	}

}
