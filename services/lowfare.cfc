<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="UAPIFactory">
	<cfproperty name="uAPISchemas">
	<cfproperty name="AirParse">
	<cfproperty name="KrakenService">

	<cffunction name="init" output="false" hint="Init method.">
		<cfargument name="UAPIFactory">
		<cfargument name="uAPISchemas">
		<cfargument name="AirParse">
		<cfargument name="KrakenService">

		<cfset setUAPIFactory(arguments.UAPIFactory)>
		<cfset setUAPISchemas(arguments.uAPISchemas)>
		<cfset setAirParse(arguments.AirParse)>
		<cfset setKrakenService(arguments.KrakenService)>

		<cfreturn this>
	</cffunction>

	<cffunction name="removeFlight" output="false" hint="I remove a flight from the session based on searchID.">
		<cfargument name="searchID">

		<cfset StructDelete(session.searches, arguments.searchID)>
		<cfset StructDelete(session.filters, arguments.searchID)>

		<cfreturn  />
	</cffunction>

	<cffunction name="selectAir" output="false" hint="I set stItinerary into the session scope.">
		<cfargument name="SearchID">
		<cfargument name="nTrip">

		<!--- Initialize or overwrite the CouldYou air section --->
		<cfset session.searches[arguments.SearchID].CouldYou.Air = {} />
		<cfset session.searches[arguments.SearchID]['Air'] = true />
		<!--- Move over the information into the stItinerary --->
		<cfset session.searches[arguments.SearchID].stItinerary.Air = session.searches[arguments.SearchID].stTrips[arguments.nTrip]>

		<cfquery datasource="booking">
			INSERT INTO Logs
				( Search_ID
				, ElapsedTime
				, Service
				, Request
				, Response
				, Timestamp )
			VALUES
				( #arguments.searchID#
				, 0
				, 'A'
				, 'Selection for lowfare'
				, '#serializeJSON(session.searches[arguments.SearchID].stItinerary.Air)#'
				, getDate() )
		</cfquery>

		<cfset session.searches[arguments.SearchID].stItinerary.Air.nTrip = arguments.nTrip>
		<cfset session.searches[arguments.SearchID].RequestedRefundable = session.searches[arguments.SearchID].stItinerary.Air.RequestedRefundable />
		<cfset session.searches[arguments.SearchID].PassedRefCheck = 0 />
		<!--- Loop through the searches structure and delete all other searches --->
		<cfloop collection="#session.searches#" index="local.nKey">
			<cfif IsNumeric(local.nKey) AND local.nKey NEQ arguments.SearchID>
				<cfset StructDelete(session.searches, local.nKey)>
			</cfif>
		</cfloop>

		<cfreturn />
	</cffunction>

	<cffunction name="unSelectAir" output="false">
		<cfargument name="SearchID">
		<cfargument name="nTrip">
		<cfset session.searches[arguments.SearchID].stItinerary.Air = "">
		<cfset session.searches[arguments.SearchID]['Air'] = false />
		<cfset StructDelete(session.searches[arguments.searchID].stTrips,arguments.nTrip)>
		<cfset StructDelete(session.searches[arguments.searchID],"stPricedTrips")>
		<cfset StructDelete(session.searches[arguments.searchID].stLowFareDetails.stPriced,arguments.nTrip)>
	</cffunction>

	<cffunction name="threadLowFare" output="false">
		<!--- arguments getting passed in from RC --->
		<cfargument name="sPriority" required="false" default="HIGH">
		<cfargument name="bRefundable" required="false" default="false">
		<cfargument name="Filter" required="false" default="X">
		<cfargument name="stPricing" required="true">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="sCabins" default="">
		<cfargument name="reQuery" default="false">

		<cfif arguments.reQuery OR !StructKeyExists(session.searches[arguments.Filter.getSearchID()],'stTrips')>
				<cfset local.stTrips = getLowFareResultsNew(argumentcollection=arguments)>
		<cfelse>
			<!---Used session cached version of the trips--->
			<cfset local.stTrips = session.searches[arguments.Filter.getSearchID()].stTrips>
		</cfif>
		<!---Merge any selected / 'priced' trips from indv leg selection--->
		<cfif StructKeyExists(session.searches[arguments.Filter.getSearchID()],'stPricedTrips') AND StructCount(session.searches[arguments.Filter.getSearchID()].stPricedTrips) GT 0>
			<cfset local.stTrips = getAirParse().mergeTrips(local.stTrips, session.searches[arguments.Filter.getSearchID()].stPricedTrips)>
		</cfif>
		<cfset session.searches[arguments.Filter.getSearchID()].stTrips = getAirParse().mergeTrips(session.searches[arguments.Filter.getSearchID()].stTrips,local.stTrips)>
		<!--- Finish up the results - finishLowFare sets data into session.searches[searchid] --->
		<cfset getAirParse().finishLowFare(arguments.Filter.getSearchID(), arguments.Account, arguments.Policy)>
		<cfreturn />
	</cffunction>

	<cffunction name="getLowFareResultsNew" output="false">
		<cfargument name="sPriority" required="false" default="HIGH">
		<cfargument name="bRefundable" required="false" default="false">
		<cfargument name="Filter" required="false" default="X">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="sCabins" default="">

		<!---<cfset local.bRefundable = (arguments.bRefundable NEQ 'X' AND arguments.bRefundable ? 'true' : 'false')>

		<cfif arguments.Policy.Policy_AirRefRule EQ 1 AND arguments.Policy.Policy_AirRefDisp EQ 1>
			<cfset local.bRefundable = true>
		</cfif>--->

		<cfscript>

			var stTrips = {};
			var requestBody = "";
			var airlines = "";
			var mergedTrips = {};

			if (NOT(StructKeyExists(session, "KrakenSearchResults"))) {

				if (len(trim(arguments.Filter.getAirlines()))) {

					airlines = [arguments.Filter.getAirlines()];

				} else {

					airlines = ['ALL','AA','UA','DL'];
				}

				for(local.i = 1; local.i LTE ArrayLen(local.airlines); local.i++) {

					requestBody = getKrakenService().getRequestSearchBody(Filter = arguments.Filter,
																																 Account = arguments.Account,
																																 sCabins = arguments.sCabins,
																																 airlines = [local.airlines[i]]);

					mergedTrips = getKrakenService().mergeResults(mergedTrips,getKrakenService().FlightSearch(requestBody));

				}

				session.KrakenSearchResults = mergedTrips;

			}

		</cfscript>

		<cfset local.BlackListedCarrierPairing = application.BlackListedCarrierPairing>

		<cfset local.stTrips = parseTrips()>

		<cfset local.stTrips = getAirParse().addGroups( stTrips = local.stTrips, Filter=arguments.Filter )>

		<cfset local.stTrips = getAirParse().removeInvalidTrips(trips=local.stTrips, filter=arguments.Filter)>

		<cfset local.stTrips = getAirParse().removeBlackListedCarrierPairings( trips = local.stTrips, blackListedCarriers = local.blackListedCarrierPairing )>

		<cfset local.stTrips = getAirParse().removeMultiCarrierPrivateFares( trips = local.stTrips )>

		<cfset local.stTrips = getAirParse().addPreferred( stTrips = local.stTrips, Account = arguments.Account)>

		<cfreturn local.stTrips>

 	</cffunction>


	<cffunction name="parseTrips" output="false" returntype="struct">

			<cfscript>

				local.stTrips = structNew('linked');
				local.route = 0;
				local.j = 1;

				local.stTrips[local.route] = structNew();
				local.stTrips[local.route]["Segments"] = structNew('linked');

				arraySort(session.KrakenSearchResults.FlightSearchResults,
					function (e1, e2) {
						if(e1.TotalFare LT e2.TotalFare) return -1;
						else if(e1.TotalFare EQ e2.TotalFare) return 0;
						else return 1;
					}
				);

				for (var t = 1; t <= MIN(application.lowFareResultsLimit,arrayLen(session.KrakenSearchResults.FlightSearchResults)); t++) {

					local.sourceX = session.KrakenSearchResults.FlightSearchResults[t].FlightSearchResultSource;
					local.Base = session.KrakenSearchResults.FlightSearchResults[t].BaseFare;
					local.ApproximateBase = session.KrakenSearchResults.FlightSearchResults[t].BaseFare;
					local.Taxes = session.KrakenSearchResults.FlightSearchResults[t].Taxes;
					local.Total = session.KrakenSearchResults.FlightSearchResults[t].TotalFare;
					local.Ref = StructKeyExists(session.KrakenSearchResults.FlightSearchResults[t], "Refundable") ? session.KrakenSearchResults.FlightSearchResults[t].Refundable : 0;
					local.RequestedRefundable = StructKeyExists(session.KrakenSearchResults.FlightSearchResults[t], "RequestedRefundable") ? session.KrakenSearchResults.FlightSearchResults[t].RequestedRefundable : 0;
					local.privateFare = StructKeyExists(session.KrakenSearchResults.FlightSearchResults[t], "privateFare") ? session.KrakenSearchResults.FlightSearchResults[t].privateFare : false;
					local.Class = StructKeyExists(session.KrakenSearchResults.FlightSearchResults[t], "Class") ? session.KrakenSearchResults.FlightSearchResults[t].Class : "Y";
					local.cabinClass = getKrakenService().CabinClassMap(local.Class);
					local.changePenalty = StructKeyExists(session.KrakenSearchResults.FlightSearchResults[t], "changePenalty") ? session.KrakenSearchResults.FlightSearchResults[t].changePenalty : 200;
					local.PTC = StructKeyExists(session.KrakenSearchResults.FlightSearchResults[t], "PassengerTypeCode") ? session.KrakenSearchResults.FlightSearchResults[t].PassengerTypeCode : "ADT";

					local.stTrips[local.route].Base = local.Base;
					local.stTrips[local.route].ApproximateBase = local.ApproximateBase;
					local.stTrips[local.route].Taxes = local.Taxes;
					local.stTrips[local.route].Total = local.Total;
					local.stTrips[local.route].cabinClass = local.cabinClass;
					local.stTrips[local.route].Class = local.Class;
					local.stTrips[local.route].privateFare = local.privateFare;
					local.stTrips[local.route].changePenalty = local.changePenalty;
					local.stTrips[local.route].PTC = local.PTC;
					local.stTrips[local.route].Ref = local.Ref;
					local.stTrips[local.route].RequestedRefundable = local.RequestedRefundable;
					local.stTrips[local.route].Xml = "";

					for (var s = 1; s <= arrayLen(session.KrakenSearchResults.FlightSearchResults[t].TripSegments); s++) {

						local.Group = session.KrakenSearchResults.FlightSearchResults[t].TripSegments[s].Group;

						local.TravelTime = session.KrakenSearchResults.FlightSearchResults[t].TripSegments[s].TotalTravelTimeInMinutes;

						for (var f = 1; f <= arrayLen(session.KrakenSearchResults.FlightSearchResults[t].TripSegments[s].Flights); f++) {

							local.flight = session.KrakenSearchResults.FlightSearchResults[t].TripSegments[s].FLights[f];

							local.cabinClass = local.flight.cabinClass;
							local.ChangeOfPlane = local.flight.ChangeOfPlane;
							local.dArrival = local.flight.ArrivalTime;
							local.dArrivalGMT = parseDateTime(dateFormat(local.dArrival,"yyyy-mm-dd") & "T" & timeFormat(local.dArrival,"HH:mm:ss"));
							local.dArrivalTime = parseDateTime(ListDeleteAt(local.dArrival, listLen(local.dArrival,"-"),"-"));
							local.dDeparture = local.flight.DepartureTime;
							local.dDepartureGMT = parseDateTime(dateFormat(local.dDeparture,"yyyy-mm-dd") & "T" & timeFormat(local.dDeparture,"HH:mm:ss"));
							local.dDepartureTime =  parseDateTime(ListDeleteAt(local.dDeparture, listLen(local.dDeparture,"-"),"-"));

							local.stTrips[local.route]["Segments"][local.j] = {
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
								Cabin		: local.cabinClass,
								Group			: local.Group,
								Origin			: local.flight.OriginAirportCode,
								PolledAvailabilityOption: '',
								Class: 'L',
								Xml: '',
								Source 			: local.sourceX
							};

							local.j++;
						}

					}

					if (arraylen(structKeyArray(local.stTrips[local.route]["Segments"])) GT 0) {
							 local.route++;
							 local.j = 1;
							 local.stTrips[local.route] = structNew('linked');
							 local.stTrips[local.route]["Segments"] = structNew('linked');
					}
				}

				if (arraylen(structKeyArray(local.stTrips[local.route]["Segments"])) EQ 0) {

					structDelete(local.stTrips, local.route);

				}

			</cfscript>

			<cfreturn local.stTrips>

	</cffunction>

</cfcomponent>
