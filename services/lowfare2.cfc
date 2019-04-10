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
		<cfargument name="allCabinClasses" required="false" default="false">

		<cfif arguments.allCabinClasses>

			<cfset arguments.sCabins = 'Y'>
			<cfset local.stTrips = getLowFareResultsNew(argumentcollection=arguments)>

			<cfset arguments.sCabins = 'C'>
			<cfset local.stCTrips = getLowFareResultsNew(argumentcollection=arguments)>
			<cfset local.structCount = structCount(local.stTrips)>
			<cfloop collection="#local.stCTrips#" index="local.tripIndex" item="local.tripItem">
				<cfset local.structCount++>
				<cfset local.stTrips[local.structCount] = local.tripItem>
			</cfloop>

			<cfset arguments.sCabins = 'F'>
			<cfset local.stFTrips = getLowFareResultsNew(argumentcollection=arguments)>
			<cfloop collection="#local.stFTrips#" index="local.tripIndex" item="local.tripItem">
				<cfset local.structCount++>
				<cfset local.stTrips[local.structCount] = local.tripItem>
			</cfloop>

		<cfelse>
			<cfset local.stTrips = getLowFareResultsNew(argumentcollection=arguments)>
		</cfif>

		<!---Merge any selected / 'priced' trips from indv leg selection--->
		<cfif StructKeyExists(session.searches[arguments.Filter.getSearchID()],'stPricedTrips') AND StructCount(session.searches[arguments.Filter.getSearchID()].stPricedTrips) GT 0>
			<cfset local.stTrips = getAirParse().mergeTrips(local.stTrips, session.searches[arguments.Filter.getSearchID()].stPricedTrips)>
		</cfif>

		<cfset session.searches[arguments.SearchID].stLowFareDetails.aCarriers = getAirParse().getCarriers(local.stTrips)>

		<cfreturn local.stTrips />
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
		<cfset local.airlines = (len(trim(arguments.Filter.getAirlines())) ? [arguments.Filter.getAirlines()] : ['ALL'])> 

		<cfset local.stTrips = {}>

		<cfset local.requestBody = getKrakenService().getRequestSearchBody( OnlyRefundableFares  = local.Refundable,
																			Filter = arguments.Filter,
																			Account = arguments.Account,
																			sCabins = local.classOfService,
																			airlines = local.airlines )>

		<cfset local.stTrips = getStorage().getStorage(	searchID = arguments.searchID,
														structure = 'stTrips',
														request = local.requestBody )>

		<cfif structIsEmpty(local.stTrips)>
			<cfset local.BlackListedCarrierPairing = application.BlackListedCarrierPairing>

			<cfset local.stTrips = getKrakenService().FlightSearch(local.requestBody,arguments.SearchID)>

			<cfset local.stTrips = parseTrips(	response = local.stTrips,
												Refundable = local.Refundable,
												classOfService = local.classOfService )>

			<cfset local.stTrips = getAirParse().addGroups( stTrips = local.stTrips,
															Filter=arguments.Filter )>

			<!---<cfset local.stTrips = addPricePerMinute(local.stTrips)>--->

			<cfset local.stTrips = getAirParse().removeInvalidTrips(trips=local.stTrips, 
																	filter=arguments.Filter)>

			<cfset local.stTrips = getAirParse().removeBlackListedCarrierPairings( 	trips = local.stTrips, 
																					blackListedCarriers = local.blackListedCarrierPairing )>

			<cfset local.stTrips = getAirParse().removeMultiCarrierPrivateFares( trips = local.stTrips )>

			<cfset local.stTrips = getAirParse().addPreferred( 	stTrips = local.stTrips,
																Account = arguments.Account)>

			<cfset local.stTrips = addInfoTostTrips(stTrips = local.stTrips)>
	
			<cfset local.stTrips = getAirParse().checkPolicy( 	local.stTrips,
															arguments.SearchID,
															0,
															'Fare',
															arguments.Account,
															arguments.Policy)>

			<cfset getStorage().storeAir(	searchID = arguments.searchID,
											structure = 'stTrips',
											request = local.requestBody,
											storage = local.stTrips )>
		</cfif>

		<cfreturn local.stTrips>
 	</cffunction>

	<cffunction name="parseTrips" output="false" returntype="struct" access="private">
			<cfargument name="response" required="true">
			<cfargument name="Refundable" required="true">
			<cfargument name="classOfService" required="false">

			<cfset var responseIndex = ''>
			<cfset var responseItem = ''>
			<cfset var segmentIndex = ''>
			<cfset var segmentItem = ''>
			<cfset var segments = {}>

<cfdump var=#response#>
			<cfloop collection="#arguments.response.FlightSearchResults#" index="responseIndex" item="responseItem">
				<cfloop collection="#responseItem.TripSegments#" index="segmentIndex" item="segmentItem">
					<cfset segments[segmentItem.segmentid] = segmentItem>
					<cfdump var=#segmentItem#>
				</cfloop>
			</cfloop>

<cfdump var=#segments# abort>

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
				if (structKeyExists(arguments.response,"FlightSearchResults") AND arrayLen(arguments.response.FlightSearchResults) GT 0) { 
						// Loop over the Flight Search Results object
						for (local.t = 1; local.t <= arrayLen(arguments.response.FlightSearchResults); local.t++) { 
            				if (arguments.response.FlightSearchResults[t].TripSegments[1].FLights[1].cabinClass EQ getKrakenService().CabinClassMap(local.classOfService,false)){ 
            					// If arguments.Refundable, only add refundable flights to the alltrips array   
								if ((arguments.Refundable AND StructKeyExists(arguments.response.FlightSearchResults[t], "IsRefundable") AND arguments.response.FlightSearchResults[t].IsRefundable) 
									OR 
										(!arguments.Refundable AND !(StructKeyExists(arguments.response.FlightSearchResults[t], "IsRefundable") AND arguments.response.FlightSearchResults[t].IsRefundable))) {	
									// Initialize segmentIDList with the boolean value of IsPrivateFare 
									local.segmentIDList = arguments.response.FlightSearchResults[t].IsPrivateFare;
									// Loop over trip segments and create an list of all segment IDs for TripSegment
									for (x =1; x <=arrayLen(arguments.response.FlightSearchResults[t].TripSegments); x++){ 
											local.segmentIDList = ListAppend(local.segmentIDList,arguments.response.FlightSearchResults[t].TripSegments[x].SegmentId); 
									} 
									//Append the segmentIDList to SegmentIDArray; This array is a pointer to allTrips
									ArrayAppend(local.SegmentIDArray,local.segmentIDList);	
		            				// Append Flight Result to allTrips array
		            				ArrayAppend(local.allTrips, arguments.response.FlightSearchResults[t]);	
		            				// Append to contractedTrips array if this is a private fare				
		            				if 	(arguments.response.FlightSearchResults[t].IsPrivateFare) 
		            					ArrayAppend(local.contractedTrips, arguments.response.FlightSearchResults[t]);
		            				// Create a UUID as a unique identifier to be attached to each flight result
		            				local.allTrips[arraylen(local.allTrips)].uniquekey = CreateUUID();   
		            				// set segmentCount to largest number of segments of all legs
									local.segmentCount = getSegmentCount(arguments.response.FlightSearchResults[t].TripSegments);
									local.allTrips[arraylen(local.allTrips)].segmentCount = local.segmentCount;
									// Add Flight to corresponding segment count array
									switch (local.segmentCount) {
										case "1" : 
										//Append the segmentIDList to nonStopSegmentIDArray; This array is a pointer to nonStop
										ArrayAppend(local.nonStopSegmentIDArray,local.segmentIDList);	
										ArrayAppend(local.nonstop,arguments.response.FlightSearchResults[t]);
										break;
										case "2" : 
										ArrayAppend(local.twoSegments,arguments.response.FlightSearchResults[t]);
										break;
										case "3" : 
										ArrayAppend(local.threeSegments,arguments.response.FlightSearchResults[t]);
										break;
										case "4" : 
										ArrayAppend(local.fourSegments,arguments.response.FlightSearchResults[t]);
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

							if(Find("+", local.dArrival)) {
								local.dArrivalTime = createODBCDateTime(parseDateTime(ListDeleteAt(local.dArrival, listLen(local.dArrival,"+"),"+")));
							} else {
								local.dArrivalTime = createODBCDateTime(parseDateTime(ListDeleteAt(local.dArrival, listLen(local.dArrival,"-"),"-")));
							}

							local.dDeparture = local.flight.DepartureTime;

							if(Find("+", local.dDeparture)) {
								local.dDepartureTime =  createODBCDateTime(parseDateTime(ListDeleteAt(local.dDeparture, listLen(local.dDeparture,"+"),"+")));
							} else {
								local.dDepartureTime =  createODBCDateTime(parseDateTime(ListDeleteAt(local.dDeparture, listLen(local.dDeparture,"-"),"-")));
							}

							local.stTrips[local.route]["Segments"][local.j] = {
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

	<cffunction name="addInfoTostTrips" output="false">
		<cfargument name="stTrips" required="true">

		<!--- Add a tripID to each group of each trip --->
		<cfloop collection="#arguments.stTrips#" index="local.tripIndex" item="local.tripItem">
			<cfset arguments.stTrips[local.tripIndex].TotalBag = arguments.stTrips[local.tripIndex].Total + application.stAirVendors[arguments.stTrips[local.tripIndex].Carriers[1]].Bag1>
			<cfset arguments.stTrips[local.tripIndex].TotalBag2 = arguments.stTrips[local.tripIndex].Total + application.stAirVendors[arguments.stTrips[local.tripIndex].Carriers[1]].Bag2>
			<cfloop collection="#local.tripItem.Groups#" index="local.groupIndex" item="local.groupItem">
				<cfset local.tripID = ''>
				<cfloop collection="#local.groupItem.Segments#" index="local.segmentIndex" item="local.segmentItem">
					<cfset local.tripID = listAppend(local.tripID, local.segmentItem.Carrier&local.segmentItem.FlightNumber&' '&local.segmentItem.Origin&'-'&local.segmentItem.Destination, ',')>
				</cfloop>
				<cfset arguments.stTrips[local.tripIndex].Groups[local.groupIndex].tripID = local.tripID>
			</cfloop>
		</cfloop>

		<cfreturn arguments.stTrips/>
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
