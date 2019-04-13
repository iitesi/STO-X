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
	property Storage;

	public AirAvailability function init (
		required any KrakenService,
		required any UAPIFactory,
		required any uAPISchemas,
		required any AirParse,
		required any Storage
	) {

		setKrakenService(arguments.KrakenService);
		setUAPIFactory(arguments.UAPIFactory);
		setUAPISchemas(arguments.uAPISchemas);
		setAirParse(arguments.AirParse);
		setStorage(arguments.Storage);

		return this;
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

		local.stTrips = {};

		if (len(trim(arguments.Filter.getAirlines()))) {
			local.airlines = [arguments.Filter.getAirlines()];
		} else {
			local.airlines = ['ALL'];
		}

		local.requestBody = getKrakenService().getRequestSearchBody( OnlyRefundableFares = false,
																	 Filter = arguments.Filter,
																	 Account = arguments.Account,
																	 sCabins = arguments.sCabins,
																	 airlines = local.airlines);
		local.stTrips = getStorage().getStorage(	searchID = arguments.Filter.getSearchID(),
													structure = 'stAvailTrips[#arguments.group#]',
													request = local.requestBody );

		if (structIsEmpty(local.stTrips)) {
			local.stTrips = getKrakenService().FlightSearch(local.requestBody);

			local.stSegments = parseSegments(	response = local.stTrips,
												Group = arguments.Group );

			local.stTrips = parseConnections(local.stSegments);

			local.stTrips	= getAirParse().addGroups(local.stTrips, 'Avail', arguments.Filter);

			local.stTrips = getAirParse().removeInvalidTrips(trips=local.stTrips, filter=arguments.Filter, tripTypeOverride='OW', chosenGroup=arguments.group);

			local.stTrips = getAirParse().addPreferred(local.stTrips, arguments.Account);

			local.stTrips	= getAirParse().checkPolicy(local.stTrips, arguments.Filter.getSearchID(), '', 'Avail', arguments.Account, arguments.Policy);

			local.stTrips = getAirParse().removeBlackListedCarriers(local.stTrips, local.BlackListedCarriers);

			local.stTrips = addTripIDstAvailTrips(stAvailTrips = local.stTrips)

			getStorage().storeAir(	searchID = arguments.Filter.getSearchID(),
									structure = 'stAvailTrips[#arguments.group#]',
									request = local.requestBody,
									storage = local.stTrips );
		}

		return local.stTrips;
	}

	public struct function parseSegments ( required any response, required any Group ) {

		local.stSegments = structNew('linked');
		local.route = 0;
		local.j = 1;

		local.stSegments[local.route] = structNew('linked');

		for (local.t = 1; local.t <= arrayLen(arguments.response.FlightSearchResults); local.t++) {

			local.sourceX = arguments.response.FlightSearchResults[t].FlightSearchResultSource;

			for (local.s = 1; local.s <= arrayLen(arguments.response.FlightSearchResults[t].TripSegments); local.s++) {

				local.Group = arguments.response.FlightSearchResults[t].TripSegments[s].Group;

				local.TravelTime = arguments.response.FlightSearchResults[t].TripSegments[s].TotalTravelTimeInMinutes;

				if (local.Group EQ arguments.group) {

					for (local.f = 1; local.f <= arrayLen(arguments.response.FlightSearchResults[t].TripSegments[s].Flights); local.f++) {

						local.flight = arguments.response.FlightSearchResults[t].TripSegments[s].FLights[f];

						local.cabinClass = local.flight.cabinClass;
						local.ChangeOfPlane = local.flight.ChangeOfPlane;

						local.dArrival = local.flight.ArrivalTime;

						if(Find("+", local.dArrival)) {
							local.dArrivalTime = parseDateTime(ListDeleteAt(local.dArrival, listLen(local.dArrival,"+"),"+"));
						} else {
							local.dArrivalTime = parseDateTime(ListDeleteAt(local.dArrival, listLen(local.dArrival,"-"),"-"));
						}

						local.dDeparture = local.flight.DepartureTime;

						if(Find("+", local.dDeparture)) {
							local.dDepartureTime =  parseDateTime(ListDeleteAt(local.dDeparture, listLen(local.dDeparture,"+"),"+"));
						} else {
							local.dDepartureTime =  parseDateTime(ListDeleteAt(local.dDeparture, listLen(local.dDeparture,"-"),"-"));
						}


						local.stSegments[local.route][local.j] = {
							Arrival			: local.dArrival,
							ArrivalTime		: local.dArrivalTime,
							Carrier 		: local.flight.CarrierCode,
							ChangeOfPlane	: local.ChangeOfPlane,
							Departure		: local.dDeparture,
							DepartureTime	: local.dDepartureTime,
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
