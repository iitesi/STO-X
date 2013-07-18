<cfcomponent output="false" accessors="true">

	<cfproperty name="VehicleAdapter">

	<cffunction name="init" output="false">
		<cfargument name="VehicleAdapter">

		<cfset setVehicleAdapter(arguments.VehicleAdapter)>

		<cfreturn this>
	</cffunction>
	
	<cffunction name="doAvailability" output="false">
		<cfargument name="Filter" 	required="true">
		<cfargument name="Account"	required="true">
		<cfargument name="Policy"   required="true">
		<cfargument name="sCarChain"required="false"    default="">
		<cfargument name="sCarType" required="false"    default="">
		<cfargument name="nCouldYou"required="false"    default="0">
		<cfargument name="sPriority"required="false"    default="LOW">

		<cfset local.SearchID = arguments.Filter.getSearchID()>
		<cfset local.CarRate = 0>

		<!--- If coming from the "Change Your Search" form, destroy the session and build anew. --->
		<cfif structKeyExists(arguments, "requery")>
			<cfset StructDelete(session.searches, SearchID) />
			<cfset session.searches[SearchID] = {} />
		</cfif>

		<!--- <cfset arguments.nCouldYou = 2 />
		<cfset arguments.sCarChain = 'ZE' />
		<cfset arguments.sCarType = 'EconomyCar' /> --->

		<!--- <cfset session.searches[SearchID].stCars = {}> --->

		<!--- <cfif arguments.Filter.getAir()
			AND structKeyExists(session.searches[SearchID].stItinerary, 'Air')
			AND arguments.Filter.getDepartDateTime() EQ arguments.Filter.getCarPickupDateTime()>

			<cfset arguments.Filter.setCarPickupDateTime( session.searches[SearchID].stItinerary.Air.Groups[0].ArrivalTime )>

		</cfif>

		<cfif arguments.Filter.getAir()
			AND structKeyExists(session.searches[SearchID].stItinerary, 'Air')
			AND arguments.Filter.getArrivalDateTime() EQ arguments.Filter.getCarDropoffDateTime()
			AND arguments.Filter.getAirType() EQ 'RT'>

			<cfset arguments.Filter.setCarDropoffDateTime( session.searches[SearchID].stItinerary.Air.Groups[1].DepartureTime )>

		</cfif>

		<cfset session.Filters[arguments.SearchID] = arguments.Filter> --->

		<cfset structDelete(session.searches[SearchID], 'stCars')>

		<cfif NOT structKeyExists(session.searches[SearchID], 'stCars')
			OR StructIsEmpty(session.searches[SearchID].stCars)
			OR arguments.nCouldYou NEQ 0>

			<cfset local.threadNames = ''>
			<cfset local.stCars = ''>

			<cfset local.CDNumbers = (structKeyExists(arguments.Policy.CDNumbers, arguments.Filter.getValueID()) ? arguments.Policy.CDNumbers[arguments.Filter.getValueID()] : (structKeyExists(arguments.Policy.CDNumbers, 0) ? arguments.Policy.CDNumbers[0] : []))>
			<cfif isStruct(CDNumbers) 
				AND NOT structIsEmpty(CDNumbers)>
				<cfset threadNames = 'corporateRates'>
				<cfset local.corporateRates = ''>
				<cfthread
					name="corporateRates"
					Filter="#arguments.Filter#"
					Account="#arguments.Account#"
					Policy="#arguments.Policy#"
					nCouldYou="#arguments.nCouldYou#"
					CDNumbers="#CDNumbers#"
					sCarChain="#arguments.sCarChain#"
					sCarType="#arguments.sCarType#">
					<cfif arguments.nCouldYou EQ 0>
						<cfset local.response = VehicleAdapter.getVehicles(arguments.Filter, arguments.Account, arguments.nCouldYou, CDNumbers) />
					<cfelse>
						<cfset local.response = VehicleAdapter.getVehicles(arguments.Filter, arguments.Account, arguments.nCouldYou, CDNumbers, arguments.sCarChain, arguments.sCarType) />
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
			
			<cfset threadNames = listAppend(threadNames, 'publicRates')>
			<cfset local.publicRates = ''>
			<cfthread
				name="publicRates"
				Filter="#arguments.Filter#"
				Account="#arguments.Account#"
				Policy="#arguments.Policy#"
				nCouldYou="#arguments.nCouldYou#"
				sCarChain="#arguments.sCarChain#"
				sCarType="#arguments.sCarType#">
				<cfif arguments.nCouldYou EQ 0>
					<cfset local.response = VehicleAdapter.getVehicles(arguments.Filter, arguments.Account, arguments.nCouldYou) />
				<cfelse>
					<cfset local.response = VehicleAdapter.getVehicles(arguments.Filter, arguments.Account, arguments.nCouldYou, arguments.sCarChain, arguments.sCarType) />
				</cfif>
				<cfset local.vehicleLocations = VehicleAdapter.parseVendorLocations(response)>
				<cfif len(arguments.sCarType)>
					<cfset local.stCars = VehicleAdapter.parseVehicles(response, vehicleLocations, false, arguments.sCarType) />
				<cfelse>
					<cfset local.stCars = VehicleAdapter.parseVehicles(response, vehicleLocations, false) />
				</cfif>
				<cfif arguments.nCouldYou EQ 0>
					<cfset local.stCars = checkPolicy(stCars, arguments.Filter.getSearchID(), arguments.Account, arguments.Policy)>
				</cfif>
				<cfset thread.stCars = addJavascript(stCars)>
			</cfthread>

			<cfif arguments.sPriority EQ 'HIGH'
				OR arguments.nCouldYou NEQ 0>

				<cfthread action="join" name="#threadNames#" />
					
				<cfset local.threadError = false>						
				<cfloop list="#threadNames#" index="local.thread">
					<cfif NOT structKeyExists(cfthread[thread], 'stCars')>
						<cfdump var="#cfthread[thread]#">
						<cfset threadError = true>						
					</cfif>
				</cfloop>
				<cfif threadError>
					<cfabort>
				</cfif>

				<cfset stCars = mergeCars((structKeyExists(cfthread.corporateRates, 'stCars') ? cfthread.corporateRates.stCars : ''), (structKeyExists(cfthread.publicRates, 'stCars') ? cfthread.publicRates.stCars : ''))>
				<cfset session.searches[SearchID].stCarVendors = getVendors(stCars, arguments.Account)>
				<cfset session.searches[SearchID].stCarCategories = getCategories(stCars)>
				<cfset session.searches[SearchID].stCars = stCars>
				
				<cfif arguments.nCouldYou NEQ 0>
					<cfif structKeyExists(cfthread.corporateRates.stCars, sCarType)
					AND structKeyExists(cfthread.corporateRates.stCars[sCarType], sCarChain)>
						<cfset CarRate = cfthread.corporateRates.stCars[sCarType][sCarChain].EstimatedTotalAmount>
					<cfelseif structKeyExists(cfthread.publicRates.stCars, sCarType)
					AND structKeyExists(cfthread.publicRates.stCars[sCarType], sCarChain)>
						<cfset CarRate = cfthread.publicRates.stCars[sCarType][sCarChain].EstimatedTotalAmount>
					</cfif>
				</cfif>
			</cfif>

			<cfset session.searches[SearchID].stCars.fLowestCarRate = findLowestCarRate(session.searches[SearchID].stCars) />
		</cfif>

		<cfreturn stCars>
	</cffunction>

	<cffunction name="mergeCars" output="false">
		<cfargument name="corporateRates">
		<cfargument name="publicRates">

		<cfset local.corporateRates = arguments.corporateRates>
		<cfset local.cars = arguments.publicRates>
		<!---If they are both structs that contain values--->
		<cfif isStruct(corporateRates) AND isStruct(publicRates)>
			<!---Loop through the corporate struct --->
			<cfloop collection="#corporateRates#" item="local.classItem" index="local.corporateClass">
				<!---If the car category already exists--->
				<cfif structKeyExists(cars, corporateClass)>
					<!---Loop through each vendor--->
					<cfloop collection="#classItem#" item="local.vendorItem" index="local.coporateVendor">
						<!---If the new one is a corporate rate, just add/override it.--->
						<cfset cars[corporateClass][coporateVendor] = vendorItem>
					</cfloop>
				<!---If the car category doesn't exists just add the whole struct for that category--->
				<cfelse>
					<cfset cars[corporateClass] = classItem>
				</cfif>
			</cfloop>
		<cfelseif isStruct(corporateRates)>
			<cfset cars = corporateRates>
		</cfif>
		<cfif NOT isStruct(cars)>
			<cfset cars = {}>
		</cfif>

		<cfreturn cars/>
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
		
		<cfquery name="local.getsearch">
			SELECT 	CarPickup_DateTime, CarDropoff_DateTime
			FROM 	Searches
			WHERE 	Search_ID = <cfqueryparam value="#arguments.SearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<cfset local.nDays = Int(getSearch.CarPickup_DateTime - getsearch.CarDropoff_DateTime)>
		
		<cfloop collection="#stCars#" item="local.sCategory">
			<cfloop collection="#stCars[sCategory]#" item="local.sVendor">
				<cfset aPolicy = []>
				<cfset bActive = 1>
				<cfset preferred = 0>
				<cfif ArrayFindNoCase(arguments.Account.aPreferredCar, sVendor)
				AND ArrayFindNoCase(arguments.Policy.aCarSizes, sCategory)>
					<cfset preferred = 1>
				</cfif>
				<!--- Out of policy if they cannot book non preferred vendors. --->
				<cfif arguments.Policy.Policy_CarPrefRule EQ 1
				AND NOT ArrayFindNoCase(arguments.Account.aPreferredCar, sVendor)>
					<cfset ArrayAppend(aPolicy, 'Not a preferred vendor')>
					<cfif arguments.Policy.Policy_CarPrefDisp EQ 1>
						<cfset bActive = 0>
					</cfif>
				</cfif>
				<!--- Out of policy if the car type is not allowed.--->
				<cfif arguments.Policy.Policy_CarTypeRule EQ 1
				AND NOT ArrayFindNoCase(arguments.Policy.aCarSizes, sCategory)>
					<cfset ArrayAppend(aPolicy, 'Car type not preferred')>
					<cfif arguments.Policy.Policy_CarTypeDisp EQ 1>
						<cfset bActive = 0>
					</cfif>
				</cfif>
				<!--- Out of policy if the car vendor is blacklisted (still shows though).  --->
				<cfif bBlacklisted
				AND ArrayFindNoCase(arguments.Account.aNonPolicyCar, sVendor)>
					<cfset ArrayAppend(aPolicy, 'Out of policy vendor')>
				</cfif>
				<cfif bActive>
					<cfset stCars[sCategory][sVendor].preferred = preferred>
					<cfset stCars[sCategory][sVendor].Policy = (ArrayIsEmpty(aPolicy) ? true : false)>
					<cfset stCars[sCategory][sVendor].aPolicies = aPolicy>
				<cfelse>
					<cfset temp = StructDelete(stCars[sCategory], sVendor)>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn stCars/>
	</cffunction>

	<cffunction name="findLowestCarRate" output="false">
		<cfargument name="stCars"    required="true">

		<cfset local.fLowestCarRate = 999999 />
		<cfset local.stCars = arguments.stCars />

		<!--- Loop through the cars and find the lowest rate of all. --->
		<cfloop collection="#stCars#" item="local.sClassCategory">
			<cfloop collection="#stCars[sClassCategory]#" item="local.sVendor">
				<cfset local.stCarJavaScript = stCars[sClassCategory][sVendor].sJavascript />
				<cfif Len(Trim(stCarJavaScript))>
					<cfset local.fEstimatedTotalAmount = Trim(ListLast(stCarJavaScript)) />
					Get the last item in the JavaScript string, which is the estimated total amount.
					<cfif IsNumeric(fEstimatedTotalAmount) AND (fEstimatedTotalAmount LT fLowestCarRate)>
						<cfset fLowestCarRate = fEstimatedTotalAmount />
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn fLowestCarRate />
	</cffunction>

	<cffunction name="addJavascript" output="false">
		<cfargument name="stCars" 	required="true">
		
		<cfset local.stCars = arguments.stCars>
		<!--- Loop through all the trips --->
		<cfloop collection="#stCars#" item="local.sClassCategory">
			<cfloop collection="#stCars[sClassCategory]#" item="local.sVendor">
				<cfset local.stCar = stCars[sClassCategory][sVendor]>
				<cfset local.sJavascript = '"#LCase(sClassCategory)##LCase(sVendor)#"'><!--- Token  --->
				<cfset sJavascript = ListAppend(sJavascript, '"#sClassCategory#"')><!--- Class and Category --->
				<cfset sJavascript = ListAppend(sJavascript, '"#sVendor#"')><!--- Vendor --->
				<cfset sJavascript = ListAppend(sJavascript, stCar.Policy)><!--- Policy --->
				<cfset sJavascript = ListAppend(sJavascript, (Left(stCar.EstimatedTotalAmount, 3) EQ 'USD' ? Replace(Mid(stCar.EstimatedTotalAmount, 4), ',', '', 'ALL') : Replace(stCar.EstimatedTotalAmount, ',', '', 'ALL')))><!--- Amount --->
				<cfset stCars[sClassCategory][sVendor].sJavascript = LCase(sJavascript)>
			</cfloop>
		</cfloop>
		
		<cfreturn stCars/>
	</cffunction>

	<cffunction name="getVendors" output="false">
		<cfargument name="stCars" required="true">
		<cfargument name="Account" required="true">
		
		<cfset local.stCars = arguments.stCars>
		<cfset local.stCarVendors = StructNew('linked')>
		<cfloop collection="#stCars#" item="local.sClassCategory">
			<cfloop collection="#stCars[sClassCategory]#" item="local.sVendor">
				<!---Add preferred vendors first--->
				<cfif ArrayFind(arguments.Account.aPreferredCar, sVendor)>
					<cfset stCarVendors[sVendor] = ''>
				</cfif>
			</cfloop>
		</cfloop>
		<!---Add all other vendors--->
		<cfloop collection="#stCars#" item="local.sClassCategory">
			<cfloop collection="#stCars[sClassCategory]#" item="local.sVendor">
				<cfset stCarVendors[sVendor] = ''>
			</cfloop>
		</cfloop>
		
		<cfreturn stCarVendors/>
	</cffunction>

	<cffunction name="getCategories" output="false">
		<cfargument name="stCars" required="true">

		<cfset local.stCars = arguments.stCars>
		<cfset local.stCarCategories = StructNew('linked')>
		<!--- If you update this list, update it in parseCars too --->
		<cfset local.aClassCategories = ['EconomyCar','CompactCar','IntermediateCar','StandardCar','FullsizeCar','LuxuryCar','PremiumCar','SpecialCar','MiniVan','MinivanVan','StandardVan','FullsizeVan','LuxuryVan','PremiumVan','SpecialVan','OversizeVan','TwelvePassengerVanVan','FifteenPassengerVanVan','SmallSUVSUV','MediumSUVSUV','IntermediateSUV','StandardSUV','FullsizeSUV','LargeSUVSUV','LuxurySUV','PremiumSUV','SpecialSUV','OversizeSUV']>
		<cfloop array="#aClassCategories#" index="local.sCategory">
			<cfif StructKeyExists(stCars, sCategory)>
				<cfset stCarCategories[sCategory] = ''>
			</cfif>
		</cfloop>
		
		<cfreturn stCarCategories/>
	</cffunction>

	<cffunction name="getSearchCriteria" output="false">
		<cfargument name="search" required="true" />

		<cfset var carPickupAirport = arguments.search.getCarPickupAirport() />
		<cfset var carPickupDateTime = arguments.search.getCarPickupDateTime() />
		<cfset var carPickupDateTimeActual = arguments.search.getCarPickupDateTimeActual() />
		<cfset var carDropoffDateTime = arguments.search.getCarDropoffDateTime() />
		<cfset var carDropoffDateTimeActual = arguments.search.getCarDropoffDateTimeActual() />
		<cfset var formData = {} />

		<!--- Pre-set the form variables in the car change search form with the old search parameters. --->
		<cfif len(trim(carPickupAirport))>
			<cfset formData.carPickupAirport = carPickupAirport />
		</cfif>

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

		<cfif structKeyExists( session.searches[ arguments.Search.getSearchID() ].couldYou )
			AND isStruct( session.searches[ arguments.Search.getSearchID() ].couldYou )
			AND structKeyExists( session.searches[ arguments.Search.getSearchID() ].couldYou.vehicle )
			AND isStruct( session.searches[ arguments.Search.getSearchID() ].couldYou.vehicle )
			AND structKeyExists( session.searches[ arguments.Search.getSearchID() ].couldYou.vehicle[ dateFormat( arguments.requestedDate, 'mm-dd-yyyy' ) ])
			AND arguments.requery IS false>

			<cfreturn session.searches[ arguments.Search.getSearchID() ].couldYou.vehicle[ dateFormat( arguments.requestedDate, 'mm-dd-yyyy' ) ] />

		<cfelse>

			<cfset var PreviouslySelectedCar = session.searches[ arguments.Search.getSearchID() ].stItinerary.Vehicle />
			<cfset var Car = "" />
			<cfset var carArgs = structNew() />
			<cfset carArgs.Filter = arguments.Search />
			<cfset carArgs.Account = application.accounts[ arguments.Search.getAcctID() ] />
			<cfset carArgs.Policy = application.policies[ arguments.Search.getPolicyId() ] />
			<cfset carArgs.sCarChain = session.searches[ arguments.Search.getSearchId() ].stItinerary.Vehicle.getVendorCode() />
			<cfset carArgs.sCarType = session.searches[ arguments.Search.getSearchId() ].stItinerary.Vehicle.getVehicleClass() />
			<cfset carArgs.nCouldYou = dateDiff( 'd', arguments.requestedDate, arguments.Search.getDepartDateTime() ) />

			<cfset var cars = this.doAvailability( argumentCollection = carArgs ) />

			<cfif NOT structKeyExists( session.searches[ arguments.Search.getSearchID() ], "couldYou" ) >
				<cfset session.searches[ arguments.Search.getSearchID() ].couldYou = structNew() />
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

		</cfif>
	</cffunction>
</cfcomponent>