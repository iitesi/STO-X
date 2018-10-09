<cfcomponent output="false" accessors="true">

	<cfproperty name="BookingDSN">
	<cfproperty name="VehicleAdapter">

	<cffunction name="init" output="false">
		<cfargument name="BookingDSN" type="string" required="true" />
		<cfargument name="VehicleAdapter" type="any" required="true" />

		<cfset setBookingDSN( arguments.BookingDSN ) />
		<cfset setVehicleAdapter(arguments.VehicleAdapter)>

		<cfreturn this>
	</cffunction>

	<cffunction name="doAvailability" output="false">
		<cfargument name="Filter" 	required="true">
		<cfargument name="Account"	required="true">
		<cfargument name="Policy"   required="true">
		<cfargument name="sCarChain"	required="false"    default="">
		<cfargument name="sCarType" 	required="false"    default="">
		<cfargument name="nCouldYou"	required="false"    default="0">
		<cfargument name="sPriority"	required="false"    default="LOW">
		<cfargument name="nFromHotel"	required="false"    default="0">
		<cfargument name="pickUpLocation" 	required="false"    default="">
		<cfargument name="dropOffLocation" 	required="false"    default="">

		<cfset local.SearchID = arguments.Filter.getSearchID()>
		<cfset local.CarRate = 0>
		<cfset local.stCars = structNew() />

		<cfparam name="session.searches[ searchID ].vehicleLocations" default="#structNew()#">

		<!--- If coming from the "Change Your Search" form, destroy the car-related sessions and build anew. --->
		<cfif structKeyExists(arguments, "requery")>
			<cfif structKeyExists(session.searches[SearchID].stItinerary, "Vehicle")>
				<cfset structDelete(session.searches[SearchID].stItinerary, "Vehicle") />
			</cfif>
			<cfif structKeyExists(session.searches[SearchID], "stCars")>
				<cfset structDelete(session.searches[SearchID], "stCars") />
			</cfif>
			<cfif structKeyExists(session.searches[SearchID], "CouldYou") AND structKeyExists(session.searches[SearchID].CouldYou, "Car")>
				<cfset structDelete(session.searches[SearchID].CouldYou, "Car") />
			</cfif>
		</cfif>

		<cfif arguments.Filter.getAir()
			AND structKeyExists(session.searches[SearchID].stItinerary, 'Air')
			AND (arguments.Filter.getDepartDateTimeActual() IS "Anytime"
				OR arguments.Filter.getDepartDateTime() EQ arguments.Filter.getCarPickupDateTime()
				OR arguments.Filter.getDepartDateTime() GT arguments.Filter.getCarPickupDateTime())>

			<cfset arguments.Filter.setCarPickupDateTime( session.searches[SearchID].stItinerary.Air.Groups[0].ArrivalTime )>
		</cfif>

		<cfif arguments.Filter.getAir()
			AND structKeyExists(session.searches[SearchID].stItinerary, 'Air')
			AND (arguments.Filter.getArrivalDateTimeActual() IS "Anytime"
				OR arguments.Filter.getArrivalDateTime() EQ arguments.Filter.getCarDropoffDateTime()
				OR arguments.Filter.getArrivalDateTime() LT arguments.Filter.getCarDropoffDateTime())
			AND arguments.Filter.getAirType() EQ 'RT'>

			<cfset arguments.Filter.setCarDropoffDateTime( session.searches[SearchID].stItinerary.Air.Groups[1].DepartureTime )>
		</cfif>

		<cfset session.Filters[ searchID ] = arguments.Filter>

		<cfif isStruct(arguments.pickUpLocation)
			OR isStruct(arguments.dropOffLocation)>
			<cfset structDelete(session.searches[SearchID], 'stCars')>
		</cfif>

		<cfif NOT structKeyExists(session.searches[SearchID], 'stCars')
			OR StructIsEmpty(session.searches[SearchID].stCars)
			OR arguments.nCouldYou NEQ 0>

			<cfif NOT structKeyExists(session.searches[ searchId ].vehicleLocations, arguments.Filter.getCarPickupAirport())>
				<cfset session.searches[ searchId ].vehicleLocations[arguments.Filter.getCarPickupAirport()] = VehicleAdapter.getVehicleLocations( targetBranch = arguments.Account.sBranch
																																				, date = arguments.Filter.getCarPickupDateTime()
																																				, airport = arguments.Filter.getCarPickupAirport()
																																				, Filter = arguments.Filter
																																				, carPrefDisp = (StructKeyExists(arguments.Policy,'Policy_CarPrefDisp') ? arguments.Policy.Policy_CarPrefDisp : 0)
																																				, preferredCars = arguments.Account.aPreferredCar )>
			</cfif>

			<cfif NOT structKeyExists(session.searches[ searchId ].vehicleLocations, arguments.Filter.getCarDropoffAirport())>
				<cfset session.searches[ searchId ].vehicleLocations[arguments.Filter.getCarDropoffAirport()] = VehicleAdapter.getVehicleLocations( targetBranch = arguments.Account.sBranch
																																				, date = arguments.Filter.getCarPickupDateTime()
																																				, airport = arguments.Filter.getCarDropoffAirport()
																																				, Filter = arguments.Filter
																																				, carPrefDisp = (StructKeyExists(arguments.Policy,'Policy_CarPrefDisp') ? arguments.Policy.Policy_CarPrefDisp : 0)
																																				, preferredCars = arguments.Account.aPreferredCar )>
			</cfif>

			<cfset local.threadNames = ''>
			<cfset local.stCars = ''>

			<cfset local.CDNumbers = (structKeyExists(arguments.Policy.CDNumbers, arguments.Filter.getValueID()) ? arguments.Policy.CDNumbers[arguments.Filter.getValueID()] : (structKeyExists(arguments.Policy.CDNumbers, 0) ? arguments.Policy.CDNumbers[0] : []))>
			<cfif isStruct(CDNumbers)
				AND NOT structIsEmpty(CDNumbers)>
				<cfset local.threadNames = 'corporateRates'>
				<cfset local.corporateRates = ''>
				<cfthread
					name="corporateRates"
					Filter="#arguments.Filter#"
					Account="#arguments.Account#"
					Policy="#arguments.Policy#"
					nCouldYou="#arguments.nCouldYou#"
					CDNumbers="#CDNumbers#"
					sCarChain="#arguments.sCarChain#"
					sCarType="#arguments.sCarType#"
					pickUpLocation="#arguments.pickUpLocation#"
					dropOffLocation="#arguments.dropOffLocation#">
					<cfif arguments.nCouldYou EQ 0>
						<cfset local.response = VehicleAdapter.getVehicles( Filter = arguments.Filter
																			, Account = arguments.Account
																			, pickUpLocation = arguments.pickUpLocation
																			, dropOffLocation = arguments.dropOffLocation
																			, corporateDiscount = CDNumbers) />
					<cfelse>
						<cfset local.response = VehicleAdapter.getVehicles(Filter = arguments.Filter
																			, Account = arguments.Account
																			, pickUpLocation = arguments.pickUpLocation
																			, dropOffLocation = arguments.dropOffLocation
																			, couldYou = arguments.nCouldYou
																			, corporateDiscount = CDNumbers
																			, carChain = arguments.sCarChain
																			, carType = arguments.sCarType) />
					</cfif>
					<cfset local.vehicleLocations = VehicleAdapter.parseVendorLocations(response)>
					<cfif len(arguments.sCarType)>
						<cfset local.stCars = VehicleAdapter.parseVehicles(response, vehicleLocations, true, arguments.sCarType) />
					<cfelse>
						<cfset local.stCars = VehicleAdapter.parseVehicles(response, vehicleLocations, true) />
					</cfif>
					<cfif arguments.nCouldYou EQ 0>
						<cfset local.stCars = checkPolicy(stCars, arguments.Filter.getSearchID(), arguments.Account, arguments.Policy)>
					</cfif>
					<cfset thread.stCars = addJavascript(stCars)>
				</cfthread>
			</cfif>

			<cfset local.threadNames = listAppend(local.threadNames, 'publicRates')>
			<cfset local.publicRates = ''>
			<cfthread
				name="publicRates"
				Filter="#arguments.Filter#"
				Account="#arguments.Account#"
				Policy="#arguments.Policy#"
				nCouldYou="#arguments.nCouldYou#"
				sCarChain="#arguments.sCarChain#"
				sCarType="#arguments.sCarType#"
				pickUpLocation="#arguments.pickUpLocation#"
				dropOffLocation="#arguments.dropOffLocation#">

				<cfif arguments.nCouldYou EQ 0>
					<cfset local.response = VehicleAdapter.getVehicles( Filter = arguments.Filter
																		, Account = arguments.Account
																		, pickUpLocation = arguments.pickUpLocation
																		, dropOffLocation = arguments.dropOffLocation ) />
				<cfelse>
					<cfset local.response = VehicleAdapter.getVehicles( Filter = arguments.Filter
																		, Account = arguments.Account
																		, couldYou = arguments.nCouldYou
																		, pickUpLocation = arguments.pickUpLocation
																		, dropOffLocation = arguments.dropOffLocation
																		, carChain = arguments.sCarChain
																		, carType = arguments.sCarType) />
				</cfif>
				<cfset local.vehicleLocations = VehicleAdapter.parseVendorLocations(local.response)>
				<cfif len(arguments.sCarType)>
					<cfset local.stCars = VehicleAdapter.parseVehicles(response, vehicleLocations, false, arguments.sCarType) />
				<cfelse>
					<cfset local.stCars = VehicleAdapter.parseVehicles(response, vehicleLocations, false) />
				</cfif>
				<cfif arguments.nCouldYou EQ 0>
					<cfset local.stCars = checkPolicy(local.stCars, arguments.Filter.getSearchID(), arguments.Account, arguments.Policy)>
				</cfif>
				<cfset thread.stCars = addJavascript(local.stCars)>
			</cfthread>

			<cfif arguments.sPriority EQ 'HIGH'
				OR arguments.nCouldYou NEQ 0
				OR arguments.nFromHotel NEQ 0>

				<cfthread action="join" name="#local.threadNames#" />

				<cfset local.threadError = false>
				<cfloop list="#local.threadNames#" index="local.thread">
					<cfif NOT structKeyExists(cfthread[local.thread], 'stCars')>
						<cfdump var="#cfthread[local.thread]#">
						<cfset local.threadError = true>
					</cfif>
				</cfloop>
				<cfif local.threadError>
					<cfabort>
				</cfif>

				<cfset local.stCars = mergeCars((structKeyExists(cfthread, 'corporateRates') AND structKeyExists(cfthread.corporateRates, 'stCars') ? cfthread.corporateRates.stCars : ''), (structKeyExists(cfthread.publicRates, 'stCars') ? cfthread.publicRates.stCars : ''))>
				<cfif arguments.nCouldYou EQ 0>
					<cfset session.searches[SearchID].stCarVendors = getVendors(local.stCars, arguments.Account)>
					<cfset session.searches[SearchID].stCarCategories = getCategories(local.stCars)>
					<cfset session.searches[SearchID].stCars = local.stCars>
				<cfelse>
					<cfset session.searches[SearchID].stCarsCouldYou = local.stCars>
				</cfif>

				<cfif arguments.nCouldYou NEQ 0>
					<cfif structKeyExists(cfthread.corporateRates.stCars, arguments.sCarType)
					AND structKeyExists(cfthread.corporateRates.stCars[arguments.sCarType], arguments.sCarChain)>
						<cfset local.CarRate = cfthread.corporateRates.stCars[arguments.sCarType][arguments.sCarChain].EstimatedTotalAmount>
					<cfelseif structKeyExists(cfthread.publicRates.stCars, arguments.sCarType)
					AND structKeyExists(cfthread.publicRates.stCars[arguments.sCarType], arguments.sCarChain)>
						<cfset local.CarRate = cfthread.publicRates.stCars[arguments.sCarType][arguments.sCarChain].EstimatedTotalAmount>
					</cfif>
				</cfif>
			</cfif>

			<cfif structKeyExists(session.searches[SearchID], 'stCars')>
				<cfset session.searches[SearchID].lowestCarRate = findLowestCarRate(session.searches[SearchID].stCars) />
			</cfif>
		</cfif>

		<cfreturn local.stCars>
	</cffunction>

	<cffunction name="mergeCars" output="false">
		<cfargument name="corporateRates">
		<cfargument name="publicRates">

		<cfset local.corporateRates = arguments.corporateRates>
		<cfset local.cars = arguments.publicRates>
		<!---If they are both structs that contain values--->
		<cfif isStruct(local.corporateRates) AND isStruct(local.cars)>
			<!---Loop through the corporate struct --->
			<cfloop collection="#local.corporateRates#" item="local.classItem" index="local.corporateClass">
				<!---If the car category already exists--->
				<cfif structKeyExists(local.cars, local.corporateClass)>
					<!---Loop through each vendor--->
					<cfloop collection="#local.classItem#" item="local.vendorItem" index="local.coporateVendor">
						<!---If the new one is a corporate rate, just add/override it.--->
						<cfset local.cars[local.corporateClass][local.coporateVendor] = local.vendorItem>
					</cfloop>
				<!---If the car category doesn't exists just add the whole struct for that category--->
				<cfelse>
					<cfset local.cars[local.corporateClass] = local.classItem>
				</cfif>
			</cfloop>
		<cfelseif isStruct(local.corporateRates)>
			<cfset local.cars = local.corporateRates>
		</cfif>
		<cfif NOT isStruct(local.cars)>
			<cfset local.cars = {}>
		</cfif>

		<cfreturn local.cars/>
	</cffunction>

	<cffunction name="checkPolicy" output="false">
		<cfargument name="stCars"  	required="true">
		<cfargument name="SearchID"	required="true">
		<cfargument name="Account"	required="false">
		<cfargument name="Policy" 	required="false">

		<cfset local.stCars = arguments.stCars>
		<cfset local.aPolicy = {}>
		<cfset local.bActive = 1>
		<cfset local.bBlacklisted = (ArrayLen(arguments.Account.aNonPolicyCar) GT 0 ? 1 : 0)>
		<cfset local.preferred = ''>

		<cfquery name="local.getsearch" datasource="#getBookingDSN()#">
			SELECT 	CarPickup_DateTime, CarDropoff_DateTime
			FROM 	Searches
			WHERE 	Search_ID = <cfqueryparam value="#arguments.SearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<cfset local.nDays = Int(getSearch.CarPickup_DateTime - getsearch.CarDropoff_DateTime)>

		<cfloop collection="#local.stCars#" item="local.sCategory">
			<cfloop collection="#local.stCars[local.sCategory]#" item="local.sVendor">
				<cfset local.aPolicy = []>
				<cfset local.bActive = 1>
				<cfset local.preferred = 0>
				<cfif ArrayFindNoCase(arguments.Account.aPreferredCar, local.sVendor)
				AND ArrayFindNoCase(arguments.Policy.aCarSizes, local.sCategory)>
					<cfset local.preferred = 1>
				</cfif>

				<!--- Out of policy if they cannot book non preferred vendors. --->
				<cfif arguments.Policy.Policy_CarPrefRule EQ 1
				AND NOT ArrayFindNoCase(arguments.Account.aPreferredCar, local.sVendor)>
					<cfset ArrayAppend(local.aPolicy, 'Not a preferred vendor')>
					<cfset local.dispCarPref = StructKeyExists(arguments.Policy,'Policy_CarPrefDisp') ? arguments.Policy.Policy_CarPrefDisp : 0>
					<cfif local.dispCarPref EQ 1>
						<cfset local.bActive = 0>
					</cfif>
				</cfif>
				<!--- Out of policy if the car type is not allowed.--->
				<cfif arguments.Policy.Policy_CarTypeRule EQ 1
				AND NOT ArrayFindNoCase(arguments.Policy.aCarSizes, local.sCategory)>
					<cfset ArrayAppend(aPolicy, 'Car type not preferred')>
					<cfif arguments.Policy.Policy_CarTypeDisp EQ 1>
						<cfset local.bActive = 0>
					</cfif>
				</cfif>
				<!--- Out of policy if the car vendor is blacklisted (still shows though).  --->
				<cfif local.bBlacklisted
				AND ArrayFindNoCase(arguments.Account.aNonPolicyCar, local.sVendor)>
					<cfset ArrayAppend(aPolicy, 'Out of policy vendor')>
				</cfif>
				<cfif local.bActive>
					<cfset local.stCars[local.sCategory][local.sVendor].preferred = local.preferred>
					<cfset local.stCars[local.sCategory][local.sVendor].Policy = (ArrayIsEmpty(local.aPolicy) ? true : false)>
					<cfset local.stCars[local.sCategory][local.sVendor].aPolicies = local.aPolicy>
				<cfelse>
					<cfset local.temp = StructDelete(local.stCars[local.sCategory], local.sVendor)>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn local.stCars/>
	</cffunction>

	<cffunction name="findLowestCarRate" output="false">
		<cfargument name="stCars"    required="true">

		<cfset local.fLowestCarRate = 999999 />
		<cfset local.stCars = arguments.stCars />

		<!--- Loop through the cars and find the lowest rate of all. --->
		<cfloop collection="#local.stCars#" item="local.sClassCategory">
			<cfloop collection="#local.stCars[local.sClassCategory]#" item="local.sVendor">
				<cfset local.stCarJavaScript = local.stCars[local.sClassCategory][local.sVendor].sJavascript />
				<cfif Len(Trim(local.stCarJavaScript))>
					<cfset local.fEstimatedTotalAmount = Trim(ListLast(local.stCarJavaScript)) />
					<!--- Get the last item in the JavaScript string, which is the estimated total amount. --->
					<cfif IsNumeric(local.fEstimatedTotalAmount) AND (local.fEstimatedTotalAmount LT fLowestCarRate)>
						<cfset local.fLowestCarRate = local.fEstimatedTotalAmount />
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn local.fLowestCarRate />
	</cffunction>

	<cffunction name="addJavascript" output="false">
		<cfargument name="stCars" 	required="true">

		<cfset local.stCars = arguments.stCars>
		<!--- Loop through all the trips --->
		<cfloop collection="#local.stCars#" item="local.sClassCategory">
			<cfloop collection="#local.stCars[local.sClassCategory]#" item="local.sVendor">
				<cfset local.stCar = local.stCars[local.sClassCategory][local.sVendor]>
				<cfset local.sJavascript = '"#LCase(local.sClassCategory)##LCase(local.sVendor)#"'><!--- Token  --->
				<cfset local.sJavascript = ListAppend(sJavascript, '"#local.sClassCategory#"')><!--- Class and Category --->
				<cfset local.sJavascript = ListAppend(sJavascript, '"#local.sVendor#"')><!--- Vendor --->
				<cfset local.sJavascript = ListAppend(sJavascript, local.stCar.Policy)><!--- Policy --->
				<cfset local.sJavascript = ListAppend(sJavascript, (Left(local.stCar.EstimatedTotalAmount, 3) EQ 'USD' ? Replace(Mid(local.stCar.EstimatedTotalAmount, 4), ',', '', 'ALL') : Replace(local.stCar.EstimatedTotalAmount, ',', '', 'ALL')))><!--- Amount --->
				<cfset local.stCars[local.sClassCategory][local.sVendor].sJavascript = LCase(local.sJavascript)>
			</cfloop>
		</cfloop>

		<cfreturn local.stCars/>
	</cffunction>

	<cffunction name="getVendors" output="false">
		<cfargument name="stCars" required="true">
		<cfargument name="Account" required="true">

		<cfset local.stCars = arguments.stCars>
		<cfset local.stCarVendors = StructNew('linked')>
		<cfloop collection="#local.stCars#" item="local.sClassCategory">
			<cfloop collection="#local.stCars[sClassCategory]#" item="local.sVendor">
				<!---Add preferred vendors first--->
				<cfif ArrayFind(arguments.Account.aPreferredCar, local.sVendor)>
					<cfset local.stCarVendors[local.sVendor] = ''>
				</cfif>
			</cfloop>
		</cfloop>
		<!---Add all other vendors--->
		<cfloop collection="#local.stCars#" item="local.sClassCategory">
			<cfloop collection="#local.stCars[sClassCategory]#" item="local.sVendor">
				<cfset local.stCarVendors[local.sVendor] = ''>
				<cfset local.stCarVendors[local.sVendor] = StructNew()>
				<cfset local.stCarVendors[local.sVendor].Location = local.stCars[sClassCategory][local.sVendor].Location>
			</cfloop>
		</cfloop>

		<cfreturn local.stCarVendors/>
	</cffunction>

	<cffunction name="getCategories" output="false">
		<cfargument name="stCars" required="true">

		<cfset local.stCars = arguments.stCars>
		<cfset local.stCarCategories = StructNew('linked')>
		<!--- If you update this list, update it in parseCars too --->
		<cfset local.aClassCategories = ['EconomyCar','CompactCar','IntermediateCar','StandardCar','FullsizeCar','LuxuryCar','PremiumCar','SpecialCar','MiniVan','MinivanVan','StandardVan','FullsizeVan','LuxuryVan','PremiumVan','SpecialVan','OversizeVan','TwelvePassengerVanVan','FifteenPassengerVanVan','SmallSUVSUV','MediumSUVSUV','IntermediateSUV','StandardSUV','FullsizeSUV','LargeSUVSUV','LuxurySUV','PremiumSUV','SpecialSUV','OversizeSUV','StandardRegularCabPickup','PremiumRegularCabPickup']>
		<cfloop array="#local.aClassCategories#" index="local.sCategory">
			<cfif StructKeyExists(local.stCars, local.sCategory)>
				<cfset local.stCarCategories[local.sCategory] = ''>
			</cfif>
		</cfloop>

		<cfreturn local.stCarCategories/>
	</cffunction>

	<cffunction name="getSearchCriteria" output="false">
		<cfargument name="search" required="true" />

		<cfset var carPickupAirport = arguments.search.getCarPickupAirport() />
		<cfset var carDropoffAirport = arguments.search.getCarDropoffAirport() />
		<cfset var carDifferentLocations = arguments.search.getCarDifferentLocations() />
		<cfset var carPickupDateTime = arguments.search.getCarPickupDateTime() />
		<cfset var carPickupDateTimeActual = arguments.search.getCarPickupDateTimeActual() />
		<cfset var carDropoffDateTime = arguments.search.getCarDropoffDateTime() />
		<cfset var carDropoffDateTimeActual = arguments.search.getCarDropoffDateTimeActual() />
		<cfset var formData = {} />

		<!--- Pre-set the form variables in the car change search form with the old search parameters. --->
		<cfif len(trim(carPickupAirport))>
			<cfset formData.carPickupAirport = carPickupAirport />
		</cfif>
		<cfif len(trim(carDropoffAirport))>
			<cfset formData.carDropoffAirport = carDropoffAirport />
		</cfif>
		<cfset formData.carDifferentLocations = carDifferentLocations />

		<cfset formData.carPickupDate = (isDate(carPickupDateTime) ? dateFormat(carPickupDateTime, 'mm/dd/yyyy') : 'pick up date') />
		<cfif isNumeric(left(trim(carPickupDateTimeActual), 1))>
			<cfset formData.carPickupTimeValue = timeFormat(carPickupDateTime, 'HH:mm') />
			<cfset formData.carPickupTimeDisplay = timeFormat(carPickupDateTime, 'hh:mm tt') />
		<cfelseif len(trim(carPickupDateTimeActual))>
			<cfset formData.carPickupTimeValue = carPickupDateTimeActual />
			<cfset formData.carPickupTimeDisplay = carPickupDateTimeActual />
		<cfelse>
			<cfset formData.carPickupTimeValue = '08:00' />
			<cfset formData.carPickupTimeDisplay = '08:00 AM' />
		</cfif>

		<cfset formData.carDropoffDate = (isDate(carDropoffDateTime) ? dateFormat(carDropoffDateTime, 'mm/dd/yyyy') : 'drop off date') />
		<cfif isNumeric(left(trim(carDropoffDateTimeActual), 1))>
			<cfset formData.carDropoffTimeValue = timeFormat(carDropoffDateTime, 'HH:mm') />
			<cfset formData.carDropoffTimeDisplay = timeFormat(carDropoffDateTime, 'hh:mm tt') />
		<cfelseif len(trim(carDropoffDateTimeActual))>
			<cfset formData.carDropoffTimeValue = carDropoffDateTimeActual />
			<cfset formData.carDropoffTimeDisplay = carDropoffDateTimeActual />
		<cfelse>
			<cfset formData.carDropoffTimeValue = '08:00' />
			<cfset formData.carDropoffTimeDisplay = '08:00 AM' />
		</cfif>

		<cfreturn formData />
	</cffunction>

	<cffunction name="doCouldYouSearch" access="public" output="false" returntype="any" hint="">
		<cfargument name="Search" type="any" required="true" />
		<cfargument name="requestedDate" type="date" required="true" />
		<cfargument name="requery" type="boolean" required="false" default="false" />

		<cfset var PreviouslySelectedCar = session.searches[ arguments.Search.getSearchID() ].stItinerary.Vehicle />
		<cfset var Car = "" />
		<cfset var carArgs = structNew() />
		<cfset carArgs.Filter = arguments.Search />
		<cfset carArgs.Account = application.accounts[ arguments.Search.getAcctID() ] />
		<cfset carArgs.Policy = application.policies[ arguments.Search.getPolicyId() ] />
		<cfset carArgs.sCarChain = session.searches[ arguments.Search.getSearchId() ].stItinerary.Vehicle.getVendorCode() />
		<cfset carArgs.sCarType = session.searches[ arguments.Search.getSearchId() ].stItinerary.Vehicle.getVehicleClass()&session.searches[ arguments.Search.getSearchId() ].stItinerary.Vehicle.getCategory() />
		<cfset carArgs.nCouldYou = dateDiff( 'd', arguments.requestedDate, arguments.Search.getCarPickupDateTime() ) />

		<cfset var cars = this.doAvailability( argumentCollection = carArgs ) />

		<cfif NOT structKeyExists( session.searches[ arguments.Search.getSearchID() ], "couldYou" ) >
			<cfset session.searches[ arguments.Search.getSearchID() ].couldYou = structNew() />
		</cfif>

		<cfif NOT structKeyExists( session.searches[ arguments.Search.getSearchID() ].couldYou, "vehicle" ) >
			<cfset session.searches[ arguments.Search.getSearchID() ].couldYou.vehicle = structNew() />
		</cfif>

		<cfif isStruct( Cars )
			AND structKeyExists( Cars, "#PreviouslySelectedCar.getVehicleClass()#Car")
			AND structKeyExists( Cars[ "#PreviouslySelectedCar.getVehicleClass()#Car" ], PreviouslySelectedCar.getVendorCode() )>

			<cfset Car = new com.shortstravel.vehicle.Vehicle() />
			<cfset Car.setVendorCode( PreviouslySelectedCar.getVendorCode() ) />
			<cfset Car.populateFromStruct( Cars[ "#PreviouslySelectedCar.getVehicleClass()#Car" ][ PreviouslySelectedCar.getVendorCode() ] ) />
		</cfif>

		<cfset session.searches[ arguments.Search.getSearchID() ].couldYou.vehicle[ dateFormat( arguments.requestedDate, 'mm-dd-yyyy' ) ] = Car />

		<cfreturn car />
	</cffunction>
</cfcomponent>
