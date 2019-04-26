<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="KrakenService">

	<cffunction name="init" output="false" hint="Init method.">
		<cfargument name="KrakenService">

		<cfset setKrakenService(arguments.KrakenService)>

		<cfreturn this>
	</cffunction>

	<cffunction name="doPurchase" output="false">
		<cfargument name="Filter" requred="true" />
		<cfargument name="Traveler" requred="true" />
		<cfargument name="LowestFare" requred="true" />

		<cfset var Filter = arguments.Filter>
		<cfset var Traveler = arguments.Traveler>
		<cfset var Itinerary = arguments.Itinerary>
		<cfset var Air = structKeyExists(Itinerary, 'Air') ? Itinerary.Air : {}>
		<cfset var Hotel = structKeyExists(Itinerary, 'Hotel') ? Itinerary.Hotel : {}>
		<cfset var Vehicle = structKeyExists(Itinerary, 'Vehicle') ? Itinerary.Vehicle : {}>

		<cfset var TravelPurchase = structNew('linked')>

		<cfset TravelPurchase.TravelerSharedData = createTravelerSharedData(Traveler = Traveler,
																			Air = Air,
																			Hotel = Hotel,
																			Vehicle = Vehicle)>

		<cfset TravelPurchase.OrgUnits = createOrgUnits(Traveler = Traveler)>

		<cfset TravelPurchase.Identity = createIdentity(Filter = Filter)>

		<cfset TravelPurchase.FlightPurchaseRequest = createFlightPurchaseRequest(Filter = Filter,
																		Traveler = Traveler,
																		Air = Air,
																		LowestFare = LowestFare)>

		<cfset TravelPurchase.HotelPurchaseRequest = createHotelPurchaseRequest(Filter = Filter,
																		Traveler = Traveler,
																		Hotel = Hotel)>

		<cfset TravelPurchase.VehiclePurchaseRequest = createVehiclePurchaseRequest(Filter = Filter,
																		Traveler = Traveler,
																		Vehicle = Vehicle)>

		<cfset var Response = getKrakenService().TravelPurchase(body = TravelPurchase,
																searchId = Filter.getSearchId())>

		<cfreturn Response>
	</cffunction>

	<cffunction name="createTravelerSharedData" output="false">
		<cfargument name="Traveler" requred="true" />
		<cfargument name="Air" requred="false" />
		<cfargument name="Hotel" requred="false" />
		<cfargument name="Vehicle" requred="false" />

		<cfif NOT structIsEmpty(arguments.Air)>
			<cfset var AirFF = ''>
			<cfloop collection="#Traveler.getLoyaltyProgram()#" index="local.index" item="local.FFAccount">
				<cfif FFAccount.getShortCode() EQ Air[0].PlatingCarrier
					AND FFAccount.getCustType() EQ 'A'>
					
					<cfset AirFF = FFAccount.getAcctNum()>

				</cfif>
			</cfloop>
		</cfif>

		<cfscript>
			var Traveler = arguments.Traveler;
			var TravelerSharedData = structNew('linked');

			TravelerSharedData = {  
				FirstName : Traveler.getFirstName(),
				MiddleName : Traveler.getMiddleName(),
				LastName : Traveler.getLastName(),
				NameSuffix : len(Traveler.getSuffix()) ? Traveler.getSuffix() : '',
				ContactDetails : [  
					{  
						ContactDetailType : "CellPhone",
						ContactInfo : Traveler.getWirelessPhone()
					},
					{  
						ContactDetailType : "WorkPhone",
						ContactInfo : Traveler.getPhoneNumber()
					},
					{  
						ContactDetailType : "InvoiceEmail",
						ContactInfo : Traveler.getEmail()
					}
				],
				DateOfBirth : isDate(Traveler.getBirthdate()) ? dateFormat(Traveler.getBirthdate(), 'mm/dd/yyyy') : '',
				Gender : Traveler.getGender(),
				DepartmentId : 13514,
				TravelerId : Traveler.getUserId(),
				RedressNumber : Traveler.getRedress(),
				KnownTravelerNumber : Traveler.getTravelNumber()
			};

			if (NOT structIsEmpty(Air) AND len(AirFF)) {
				TravelerSharedData.FrequentFlyerDetailsCard = {
					VendorCode : Air[0].PlatingCarrier,
					Number : AirFF,
					Type : "Flight"
				};
			};

			if (NOT structIsEmpty(Hotel) AND len(Traveler.getBookingDetail().getHotelFF())) {
				TravelerSharedData.HotelLoyaltyCard = {
					VendorCode : Hotel.getChainCode(),
					Number : Traveler.getBookingDetail().getHotelFF(),
					Type : "Hotel"
				};
			};

			if (NOT structIsEmpty(Vehicle) AND len(Traveler.getBookingDetail().getCarFF())) {
				TravelerSharedData.VehicleLoyaltyCard = {
					VendorCode : Vehicle.getVendorCode(),
					Number : Traveler.getBookingDetail().getCarFF(),
					Type : "Vehicle"
				};
			};

		</cfscript>

		<!--- Dohmen DepartmentId --->

		<cfreturn TravelerSharedData>
	</cffunction>

	<cffunction name="createOrgUnits" output="false">
		<cfargument name="Traveler" requred="true" />

		<cfscript>
			var Traveler = arguments.Traveler;

			var OrgUnits = [];

			var OrgUnit = {};
			for (i = 1; i <= arrayLen(Traveler.getOrgUnit()); i++) {
				OrgUnit = {
					id : Traveler.getOrgUnit()[i].getOUID(),
					value : Traveler.getOrgUnit()[i].getValueReport()
				};
				arrayAppend(OrgUnits, OrgUnit);
			};
		</cfscript>

		<cfreturn OrgUnits>
	</cffunction>

	<cffunction name="createIdentity" output="false">
		<cfargument name="Filter" requred="true" />

		<cfscript>
			var Filter = arguments.Filter;
			var Identity = structNew('linked');

			Identity = {  
				TravelerName : Filter.getProfileUsername(),
				TravelerAccountId : Filter.getAcctID(),
				BookingTravelerId : Filter.getProfileID(),
				BookingTravelerDepartmentId : Filter.getValueID(),
				CandidateTravelerId : ""
			}
		</cfscript>

		<cfreturn Identity>
	</cffunction>

	<cffunction name="createFlightPurchaseRequest" output="false">
		<cfargument name="Filter" requred="true" />
		<cfargument name="Traveler" requred="true" />
		<cfargument name="Air" requred="true" />

		<cfset var Filter = arguments.Filter>
		<cfset var Traveler = arguments.Traveler>
		<cfset var Air = arguments.Air>
		<cfset var FlightPricingSegments = []>
		<cfset var Flights = {}>
		<cfset var FlightsArray = []>
		<cfset var FlightStruct = {}>
		<cfset var FlightPurchaseRequest = {}>

		<cfif NOT structIsEmpty(Air) 
			AND Traveler.getBookingDetail().getAirNeeded()>

			<cfloop collection="#Air#" index="local.GroupIndex" item="local.Group">

				<cfloop collection="#Group.Flights#" index="local.index" item="local.Flight">

					<cfset FlightStruct = {}>

					<cfscript>
						FlightStruct = { 
							outOfPolicy : Flight.OutOfPolicy ? false : true,
							originAirportCode : Flight.originAirportCode,
							destinationAirportCode : Flight.destinationAirportCode,
							departureDateTime : Flight.DepartureTimeGMT,
							arrivalDateTime : Flight.ArrivalTimeGMT,
							flightNumber : Flight.flightNumber,
							carrierCode : Flight.carrierCode,
							BookingCode : Flight.BookingCode,
							CabinClass : Flight.CabinClass,
							isPreferred : Flight.IsPreferred,
							DepartureTime : Flight.DepartureTimeGMT,
							ArrivalTime : Flight.ArrivalTimeGMT,
							// SeatAssignment : {
							// 	FlightNumber : "402"
							// },
							IsPrivateFare : false,
							BookingDetail : {
								BrandedFareId : '',
								BookingCode : Flight.BookingCode,
								FareBasis : Flight.FareBasis
							}
						};

						arrayAppend(FlightsArray, FlightStruct);

					</cfscript>

				</cfloop>

				<cfset Flights.Flights = FlightsArray>
				<cfset Flights.Group = GroupIndex>
				<cfset arrayAppend(FlightPricingSegments, Flights)>

				<cfset FlightsArray = []>
				<cfset Flights = {}>

			</cfloop>

			<cfscript>

				if (NOT structIsEmpty(Air)) {

					FlightPurchaseRequest = {
						FlightPricingSegments : FlightPricingSegments,
						SearchId : Filter.getSearchId(),
						AirLowestFare : LowestFare,
						ApplyUnusedTickets : structKeyExists(Filter.getUnusedTicketCarriers(), Air[0].PlatingCarrier),
						AirOutOfPolicyReasonCode : Traveler.getBookingDetail().getAirReasonCode(),
						HotelNotBookedReasonCode : Traveler.getBookingDetail().getHotelNotBooked(),
						FormOfPaymentId : isNumeric(Traveler.getBookingDetail().getAirFOPID()) ? Traveler.getBookingDetail().getAirFOPID() : getToken(Traveler.getBookingDetail().getAirFOPID(), 2, '_')
					}

				};
			</cfscript>

		</cfif>

		<!--- Dohmen to do - IsPrivateFare --->

		<cfreturn FlightPurchaseRequest>
	</cffunction>

	<cffunction name="createHotelPurchaseRequest" output="false">
		<cfargument name="Filter" requred="true" />
		<cfargument name="Traveler" requred="true" />
		<cfargument name="Hotel" requred="true" />

		<cfscript>
			var Filter = arguments.Filter;
			var Traveler = arguments.Traveler;
			var Hotel = arguments.Hotel;
			var HotelPurchaseRequest = {};

			if (NOT structIsEmpty(Hotel) AND Traveler.getBookingDetail().getHotelNeeded()) {

				HotelPurchaseRequest = {
					HotelProperty : {  
							HotelChainCode : Hotel.getChainCode(),
							HotelPropertyId : Hotel.getPropertyID()
						},
					CheckinDate : dateFormat(Filter.getCheckInDate(), 'yyyy-mm-dd'),
					CheckoutDate : dateFormat(Filter.getCheckOutDate(), 'yyyy-mm-dd'),
					RateDetail : {
						totalForStay : {  
							currencyCode : Hotel.getRooms()[1].getTotalForStayCurrency(),
							value : Hotel.getRooms()[1].getTotalForStay()
						},
						isContractedRate : Hotel.getRooms()[1].getIsCorporateRate(),
						isGovermentRate : Hotel.getRooms()[1].getIsGovernmentRate(),
						outOfPolicy : Hotel.getRooms()[1].getIsInPolicy() ? false : true,
						depositRequired : Hotel.getRooms()[1].getDepositRequired(),
						//Dohmen - Question out to Juan on Guarentee logic.
						reservationRequirement : "Guarantee",
						RatePlanType : Hotel.getRooms()[1].getRatePlanType(),
						CorporateDiscount : {
							CorporateDiscountId : Hotel.getRooms()[1].getCorporateDiscountID()
						},
						IsBookable : true,
						AverageRateDuringState : Hotel.getRooms()[1].getDailyRateCurrency()
					},
					SearchId : Filter.getSearchId(),
					HotelOutOfPolicyReasonCode : Traveler.getBookingDetail().getHotelReasonCode(),
					SpecialRequest = Traveler.getBookingDetail().getHotelSpecialRequests(),
					FormOfPaymentId : isNumeric(Traveler.getBookingDetail().getHotelFOPID()) ? Traveler.getBookingDetail().getHotelFOPID() : getToken(Traveler.getBookingDetail().getHotelFOPID(), 2, '_')
				};

			};
		</cfscript>

		<!--- <cfdump var=#Hotel#>
		<cfdump var=#HotelPurchaseRequest# abort> --->

		<cfreturn HotelPurchaseRequest>
	</cffunction>

	<cffunction name="createVehiclePurchaseRequest" output="false">
		<cfargument name="Filter" requred="true" />
		<cfargument name="Traveler" requred="true" />
		<cfargument name="Vehicle" requred="true" />

		<cfscript>
			var Filter = arguments.Filter;
			var Traveler = arguments.Traveler;
			var Vehicle = arguments.Vehicle;
			var VehiclePurchaseRequest = structNew('linked');

			if (NOT structIsEmpty(Vehicle) AND Traveler.getBookingDetail().getCarNeeded()) {
				VehiclePurchaseRequest = {
					AirConditioning : Vehicle.getAirConditioning(),
					Category : "Car",
					TransmissionType : Vehicle.getTransmissionType(),
					VehicleClass : Vehicle.getVehicleClass(),
					VendorCode : Vehicle.getVendorCode(),
					RateCode : Vehicle.getRateCode(),
					IsContractedRate : Vehicle.getCorporate(),
					PickUpDateTime : dateFormat(Filter.getCarPickUpDateTime(), 'yyyy-mm-dd')&'T'&timeFormat(Filter.getCarPickUpDateTime(), 'HH:mm:00'),
					DropOffDateTime : dateFormat(Filter.getCarDropOffDateTime(), 'yyyy-mm-dd')&'T'&timeFormat(Filter.getCarDropOffDateTime(), 'HH:mm:00'),
					PickUpLocation : {
						IataCode : {
							Code :  len(Vehicle.getPickUpLocation()) GT 0 ? Vehicle.getPickUpLocation() : Filter.getCarPickupAirport(),
							IsCity : false//len(Vehicle.getPickUpLocation()) ? false : true
						},
					},
					DropOffLocation : {
						IataCode : {
							Code :  len(Vehicle.getDropOffLocation()) GT 0 ? Vehicle.getDropOffLocation() : Filter.getCarDropOffAirport(),
							IsCity : false//len(Vehicle.getDropOffLocation()) ? false : true
						},
					},
					VehicleOutOfPolicyReasonCode : Traveler.getBookingDetail().getCarReasonCode(),
					// Dohmen To Do
					Carrier : '',
					FlightNumber : '',
					HotelNotBookedReasonCode = Traveler.getBookingDetail().getHotelNotBooked(),
					HotelWhereStayingNotOnItinerary = Traveler.getBookingDetail().getHotelWhereStaying()
				};

				if (len(Vehicle.getPickUpLocationID()) AND Vehicle.getPickUpLocationType() NEQ 'Airport' AND Vehicle.getPickUpLocationType() NEQ 'Terminal' AND Vehicle.getPickUpLocationType() NEQ 'ShuttleOffAirport') {
					var VendorLocation = {
						ProviderCode : "1V",
						Vendor : {
							Code : Vehicle.getVendorCode()
						},
						VendorLocationId: Vehicle.getPickUpLocationID(),
						LocationCode : len(Vehicle.getPickUpLocation()) GT 0 ? Vehicle.getPickUpLocation() : Filter.getCarPickupAirport(),
						LocationType : Vehicle.getPickUpLocationType()
					};
					VehiclePurchaseRequest.PickUpLocation.VendorLocation = VendorLocation;
				};

				if (len(Vehicle.getDropOffLocationID()) AND Vehicle.getDropOffLocationType() NEQ 'Airport' AND Vehicle.getDropOffLocationType() NEQ 'Terminal' AND Vehicle.getDropOffLocationType() NEQ 'ShuttleOffAirport') {
					var VendorLocation = {
						ProviderCode : "1V",
						Vendor : {
							Code : Vehicle.getVendorCode()
						},
						VendorLocationId: Vehicle.getDropOffLocationID(),
						LocationCode : len(Vehicle.getDropOffLocation()) GT 0 ? Vehicle.getDropOffLocation() : Filter.getCarDropOffAirport(),
						LocationType : Vehicle.getDropOffLocationType()
					};
					VehiclePurchaseRequest.DropOffLocation.VendorLocation = VendorLocation;
				};

			}
		</cfscript>

		<!--- <cfdump var=#Vehicle# abort> --->
		<!--- <cfdump var=#VehiclePurchaseRequest# abort> --->

		<cfreturn VehiclePurchaseRequest>
	</cffunction>

	<cffunction name="CancelTrip" output="false">
		<cfargument name="AcctId" requred="true" />
		<cfargument name="UniversalRecordLocatorCode" requred="true" />
		<cfargument name="SearchId" requred="true" />

		<cfset var Response = getKrakenService().CancelTrip(AcctId = arguments.AcctId,
															UniversalRecordLocatorCode = arguments.UniversalRecordLocatorCode,
															SearchId = arguments.SearchId)>
		
		<cfreturn Response>
	</cffunction>

</cfcomponent>