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

		<cfset local.stTrips = getLowFareResultsNew(argumentcollection=arguments)>

		<!---Merge any selected / 'priced' trips from indv leg selection--->
		<cfif StructKeyExists(session.searches[arguments.Filter.getSearchID()],'stPricedTrips') AND StructCount(session.searches[arguments.Filter.getSearchID()].stPricedTrips) GT 0>
			<cfset local.stTrips = getAirParse().mergeTrips(local.stTrips, session.searches[arguments.Filter.getSearchID()].stPricedTrips)>
		</cfif>

		<cfset session.searches[arguments.Filter.getSearchID()].stTrips = local.stTrips>
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
		<cfargument name="SearchID" default="">

		<cfset local.Refundable = (arguments.bRefundable NEQ 'X' AND arguments.bRefundable) ? true : false>
		<cfset local.classOfService = (len(arguments.sCabins)) ? arguments.sCabins : (len(arguments.Filter.getClassOfService()) ? arguments.Filter.getClassOfService() : 'Y')> 
		<cfif arguments.Policy.Policy_AirRefRule EQ 1 AND arguments.Policy.Policy_AirNonRefRule EQ 0>
			<cfset local.Refundable = true>
		</cfif>

		<cfscript>

			local.mergedTrips = {};

			local.key = getKrakenService().getKey(OnlyRefundableFares = local.Refundable,
																					  Filter = arguments.Filter,
																					  Account = arguments.Account,
																					  sCabins = local.classOfService);

			if ( NOT(StructKeyExists(session, "KrakenSearchResults")) OR
					 NOT(StructKeyExists(session.KrakenSearchResults, "key")) OR
					 session.KrakenSearchResults.key NEQ local.key ) {

				if (len(trim(arguments.Filter.getAirlines()))) {

					local.airlines = [arguments.Filter.getAirlines()];

				} else {

					local.airlines = ['ALL'];
				}

				local.requestBody = getKrakenService().getRequestSearchBody( OnlyRefundableFares  = local.Refundable,
																																		 Filter = arguments.Filter,
																																		 Account = arguments.Account,
																																		 sCabins = local.classOfService,
																																		 airlines = local.airlines );

				local.mergedTrips = getKrakenService().FlightSearch(local.requestBody,arguments.SearchID);



				session.KrakenSearchResults = StructNew();
				session.KrakenSearchResults.trips = local.mergedTrips;
				session.KrakenSearchResults.key = getKrakenService().hashNumeric(local.key);

			}

		</cfscript>

		<cfset local.BlackListedCarrierPairing = application.BlackListedCarrierPairing>

		<cfset local.stTrips = parseTrips(local.Refundable,arguments.Policy,local.classOfService)>

		<cfset local.stTrips = getAirParse().addGroups( stTrips = local.stTrips, Filter=arguments.Filter )>

		<cfset local.stTrips = addPricePerMinute(local.stTrips)>

		<cfset local.stTrips = getAirParse().removeInvalidTrips(trips=local.stTrips, filter=arguments.Filter)>

		<cfset local.stTrips = getAirParse().removeBlackListedCarrierPairings( trips = local.stTrips, blackListedCarriers = local.blackListedCarrierPairing )>

		<cfset local.stTrips = getAirParse().removeMultiCarrierPrivateFares( trips = local.stTrips )>

		<cfset local.stTrips = getAirParse().addPreferred( stTrips = local.stTrips, Account = arguments.Account)>

		<cfreturn local.stTrips>

 	</cffunction>


	<cffunction name="parseTrips" output="false" returntype="struct" access="private">
			<cfargument name="Refundable" required="true">
			<cfargument name="Policy" required="false">
			<cfargument name="classOfService" required="false">
			<cfscript> 
				local.stTrips = structNew('linked');
				local.route = 0;
				local.j = 1;

				local.stTrips[local.route] = structNew();
				local.stTrips[local.route]["Segments"] = structNew('linked');
				local.classOfService = arguments.classOfService;
				local.allTrips = arraynew(1);
				local.contractedTrips = arraynew(1);
				local.nonstop = arraynew(1);	
				local.twoSegments = arraynew(1);	
				local.threeSegments = arraynew(1);	
				local.fourSegments = arraynew(1);	
				local.SegmentIDArray = arraynew(1);		
				local.nonStopSegmentIDArray = arraynew(1);		
				if (structKeyExists(session.KrakenSearchResults.trips,"FlightSearchResults") AND arrayLen(session.KrakenSearchResults.trips.FlightSearchResults) GT 0) { 
						// Loop over the Flight Search Results object
						for (local.t = 1; local.t <= arrayLen(session.KrakenSearchResults.trips.FlightSearchResults); local.t++) { 
            				if (session.KrakenSearchResults.trips.FlightSearchResults[t].TripSegments[1].FLights[1].cabinClass EQ getKrakenService().CabinClassMap(local.classOfService,false)){ 
            					// If arguments.Refundable, only add refundable flights to the alltrips array   
								if ((arguments.Refundable AND StructKeyExists(session.KrakenSearchResults.trips.FlightSearchResults[t], "IsRefundable") AND session.KrakenSearchResults.trips.FlightSearchResults[t].IsRefundable) 
									OR 
										(!arguments.Refundable AND !(StructKeyExists(session.KrakenSearchResults.trips.FlightSearchResults[t], "IsRefundable") AND session.KrakenSearchResults.trips.FlightSearchResults[t].IsRefundable))) {	
									// Initialize segmentIDList with the boolean value of IsPrivateFare 
									local.segmentIDList = session.KrakenSearchResults.trips.FlightSearchResults[t].IsPrivateFare;
									// Loop over trip segments and create an list of all segment IDs for TripSegment
									for (x =1; x <=arrayLen(session.KrakenSearchResults.trips.FlightSearchResults[t].TripSegments); x++){ 
											local.segmentIDList = ListAppend(local.segmentIDList,session.KrakenSearchResults.trips.FlightSearchResults[t].TripSegments[x].SegmentId); 
									} 
									//Append the segmentIDList to SegmentIDArray; This array is a pointer to allTrips
									ArrayAppend(local.SegmentIDArray,local.segmentIDList);	
		            				// Append Flight Result to allTrips array
		            				ArrayAppend(local.allTrips, session.KrakenSearchResults.trips.FlightSearchResults[t]);	
		            				// Append to contractedTrips array if this is a private fare				
		            				if 	(session.KrakenSearchResults.trips.FlightSearchResults[t].IsPrivateFare) 
		            					ArrayAppend(local.contractedTrips, session.KrakenSearchResults.trips.FlightSearchResults[t]);
		            				// Create a UUID as a unique identifier to be attached to each flight result
		            				local.allTrips[arraylen(local.allTrips)].uniquekey = CreateUUID();   
		            				// set segmentCount to largest number of segments of all legs
									local.segmentCount = getSegmentCount(session.KrakenSearchResults.trips.FlightSearchResults[t].TripSegments);
									local.allTrips[arraylen(local.allTrips)].segmentCount = local.segmentCount;
									// Add Flight to corresponding segment count array
									switch (local.segmentCount) {
										case "1" : 
										//Append the segmentIDList to nonStopSegmentIDArray; This array is a pointer to nonStop
										ArrayAppend(local.nonStopSegmentIDArray,local.segmentIDList);	
										ArrayAppend(local.nonstop,session.KrakenSearchResults.trips.FlightSearchResults[t]);
										break;
										case "2" : 
										ArrayAppend(local.twoSegments,session.KrakenSearchResults.trips.FlightSearchResults[t]);
										break;
										case "3" : 
										ArrayAppend(local.threeSegments,session.KrakenSearchResults.trips.FlightSearchResults[t]);
										break;
										case "4" : 
										ArrayAppend(local.fourSegments,session.KrakenSearchResults.trips.FlightSearchResults[t]);
										break;
									}
								} // end if refundable/nonrefundable
							} // end if cabin class	 
						} // end if there is an arraylen of flight results 
 					// Remove NONContracted Trips from all arrays of trips
					for (local.ct=1; ct <=arraylen(local.contractedTrips); ct++){ 
						local.segmentIDList = 'false'; 
 							// Loop over trip segments and create an object of all segment IDs
 							for (x =1; x <=arrayLen(contractedTrips[ct].TripSegments); x++){ 
 									local.segmentIDList = ListAppend(segmentIDList,contractedTrips[ct].TripSegments[x].SegmentId);  
 							}
						local.arrayPosition = ArrayFind(local.SegmentIDArray,local.segmentIDList);
						local.arrayPositionNonStop = ArrayFind(local.nonStopSegmentIDArray,local.segmentIDList);
						if (local.arrayPosition gt 0) { 
 					 		arrayDeleteAt(local.allTrips, local.arrayPosition); 
 					 		arrayDeleteAt(local.SegmentIDArray, local.arrayPosition); 
 					 	}
 					 	if (local.arrayPositionNonStop gt 0) { 	 
 					 		arrayDeleteAt(local.nonStop, local.arrayPositionNonStop); 
 					 		arrayDeleteAt(local.nonStopSegmentIDArray, local.arrayPositionNonStop); 
 					 	}
					}    
					// Sort arrays
					local.nonstop = SortArray(local.nonstop); 
					local.twoSegments = SortArray(local.twoSegments); 
					local.threeSegments = SortArray(local.threeSegments); 
					local.fourSegments = SortArray(local.fourSegments); 
					// Remove multiple connection flights
					if (arraylen(nonstop) && arraylen(twoSegments)) {
						for (local.i = 1; local.i <= arraylen(threeSegments); local.i++) {
                            ArrayDelete(local.allTrips, threeSegments[local.i] );

                        }							
						for (local.i = 1; local.i <= arraylen(fourSegments); local.i++) {
                             ArrayDelete(local.allTrips, fourSegments[local.i] );

                        }

					}
					else if (arraylen(local.twoSegments) && arraylen(local.threeSegments)) {							
						for (local.i = 1; local.i <= arraylen(fourSegments); local.i++) {
                             ArrayDelete(local.allTrips, fourSegments[local.i] );

                        }
					}	  
					local.allTrips = SortArray(local.allTrips); 
                    // Move all nonstop flights to front of array
                    for (local.i = 1; local.i <= arraylen(nonstop); local.i++) {  
                            ArrayDelete(local.allTrips, nonstop[local.i] );
                            ArrayPrepend(local.allTrips, nonstop[local.i] );
                        }

							local.sliceArray = arraylen(local.allTrips) GT application.lowFareResultsLimit ? ArraySlice(local.allTrips,1,application.lowFareResultsLimit) : local.allTrips; 
				}	else
					local.sliceArray = [];  
							
				for (local.t = 1; local.t <= arrayLen(local.sliceArray); local.t++) {

					local.sourceX = local.sliceArray[t].FlightSearchResultSource;
					local.Base = local.sliceArray[t].BaseFare.Value;
					local.ApproximateBase = local.sliceArray[t].ApproximateBaseFare.Value;
					local.Taxes = local.sliceArray[t].Taxes.Value;
					local.Total = local.sliceArray[t].TotalFare.Value;
					local.Ref = StructKeyExists(local.sliceArray[t], "IsRefundable") ? local.sliceArray[t].IsRefundable  : 0;
					local.RequestedRefundable = arguments.Refundable;
					local.privateFare = StructKeyExists(local.sliceArray[t], "IsPrivateFare") ? local.sliceArray[t].IsPrivateFare : false;
					local.cabinClass = local.sliceArray[t].TripSegments[1].FLights[1].cabinClass;
					local.Class = getKrakenService().CabinClassMap(local.cabinClass,true);
					local.Key = StructKeyExists(local.sliceArray[t], "TripPricingKey") ? local.sliceArray[t].TripPricingKey : "";
					local.changePenalty = StructKeyExists(local.sliceArray[t], "changePenalty") ? local.sliceArray[t].changePenalty.Value : 0;
					local.PTC = StructKeyExists(local.sliceArray[t], "PassengerType") ? local.sliceArray[t].PassengerType : "ADT";

					local.stTrips[local.route].Base = local.Base;
					local.stTrips[local.route].ApproximateBase = local.ApproximateBase;
					local.stTrips[local.route].Taxes = local.Taxes;
					local.stTrips[local.route].Total = local.Total;
					local.stTrips[local.route].cabinClass = local.cabinClass;
					local.stTrips[local.route].Class = local.Class;
					local.stTrips[local.route].Key = local.Key;
					local.stTrips[local.route].privateFare = local.privateFare;
					local.stTrips[local.route].changePenalty = local.changePenalty;
					local.stTrips[local.route].PTC = local.PTC;
					local.stTrips[local.route].Ref = local.Ref;
					local.stTrips[local.route].RequestedRefundable = local.RequestedRefundable;
					local.stTrips[local.route].TotalBag = 0;
					local.stTrips[local.route].TotalBag2 = 0;
					local.stTrips[local.route].Xml = "";

					for (var s = 1; s <= arrayLen(local.sliceArray[t].TripSegments); s++) {

						local.Group = local.sliceArray[t].TripSegments[s].Group;

						local.TravelTime = local.sliceArray[t].TripSegments[s].TotalTravelTimeInMinutes;

						for (var f = 1; f <= arrayLen(local.sliceArray[t].TripSegments[s].Flights); f++) {

							local.flight = local.sliceArray[t].TripSegments[s].FLights[f];

							local.cabinClass = local.flight.cabinClass;
							local.BookingCode = local.flight.BookingCode;
							local.ChangeOfPlane = local.flight.ChangeOfPlane;

							local.dArrival = local.flight.ArrivalTime;
							local.dArrivalGMT = this.getAirParse().fromGMTStringToDateObj(local.dArrival);

							if(Find("+", local.dArrival)) {
								local.dArrivalTime = parseDateTime(ListDeleteAt(local.dArrival, listLen(local.dArrival,"+"),"+"));
							} else {
								local.dArrivalTime = parseDateTime(ListDeleteAt(local.dArrival, listLen(local.dArrival,"-"),"-"));
							}

							local.dDeparture = local.flight.DepartureTime;
							local.dDepartureGMT = this.getAirParse().fromGMTStringToDateObj(local.dDeparture);

							if(Find("+", local.dDeparture)) {
								local.dDepartureTime =  parseDateTime(ListDeleteAt(local.dDeparture, listLen(local.dDeparture,"+"),"+"));
							} else {
								local.dDepartureTime =  parseDateTime(ListDeleteAt(local.dDeparture, listLen(local.dDeparture,"-"),"-"));
							}

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
								Class: local.BookingCode,
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

	<cffunction name ="addPricePerMinute" output="false" returnType = "struct" access="private">
		<cfargument name="stTrips" type="struct" required="true">

			<cfscript>

				for(key in arguments.stTrips) {
					arguments.stTrips[key].pricePerMinute = arguments.stTrips[key].Total / arguments.stTrips[key].Duration;
				}

				return arguments.stTrips;

			</cfscript>

	</cffunction>
	<cffunction name="getSegmentCount" output="false" returntype="numeric" access = "private">
		<cfargument name="TripSegments" type="array" required="true">
		<cfscript>
			local.segmentCount = 1;
			// Loop over TripSegments
			for (local.flightIndex = 1; local.flightIndex <= arrayLen(arguments.TripSegments); local.flightIndex++) {
				// Set temp segment count to the current number of segments for group
				local.tempsegmentCount = arrayLen(arguments.TripSegments[flightIndex].Flights);
				// Set Segment Count to the greatest of arraylen of Flights
				// If the latest segment count is larger than the previous segment count, then update segment count
				// This will get the largest segment count in the flights
				local.segmentCount = (local.tempsegmentCount > local.segmentCount ? local.tempsegmentCount : local.segmentCount);
				
			} // end for loop over TripSegements
			return local.segmentCount;
		</cfscript>
	</cffunction>	
	<cffunction name="SortArray" output="false" returntype="array" access="private">
		<cfargument name="ArrayToSort" type="array" array="required">
		<cfscript> 
		local.sortedArray = arguments.ArrayToSort
		arraySort(local.sortedArray,
						 			function (e1, e2) {
						 				if(e1.TotalFare.Value LT e2.TotalFare.Value) return -1;
						 				else if(e1.TotalFare.Value EQ e2.TotalFare.Value) return 0;
						 				else return 1;
						 			}
						 		);
		return local.sortedArray;
		</cfscript>
	</cffunction>
</cfcomponent>
