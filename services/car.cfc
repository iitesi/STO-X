<cfcomponent output="false" accessors="true">

	<cfproperty name="UAPI">

<!---
init
--->
	<cffunction name="init" output="false">
		<cfargument name="UAPI">

		<cfset setUAPI(arguments.UAPI)>

		<cfreturn this>
	</cffunction>
	
<!---
doAvailability
--->
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

		<cfif NOT structKeyExists(session.searches[SearchID], 'stCars')
		OR StructIsEmpty(session.searches[SearchID].stCars)
		OR arguments.nCouldYou NEQ 0>

			<cfset local.nUniqueThreadName = arguments.nCouldYou + 100 /><!--- nCouldYou is negative at times, so make sure it's positive so cfthread can read the names properly --->
			<cfset local.stThreads = {}>
			<cfset local.CDNumbers = (structKeyExists(arguments.Policy.CDNumbers, arguments.Filter.getValueID()) ? arguments.Policy.CDNumbers[arguments.Filter.getValueID()] : (structKeyExists(arguments.Policy.CDNumbers, 0) ? arguments.Policy.CDNumbers[0] : []))>
			<cfif isStruct(CDNumbers) AND NOT structIsEmpty(CDNumbers)>
				<cfset stThreads['stCorporateRates'&nUniqueThreadName] = ''>
				<cfthread
				name="stCorporateRates#nUniqueThreadName#"
				Filter="#arguments.Filter#"
				Account="#arguments.Account#"
				Policy="#arguments.Policy#"
				nCouldYou="#arguments.nCouldYou#"
				CDNumbers="#CDNumbers#">
					<cfset local.sMessage	= prepareSoapHeader(arguments.Filter, arguments.Account, arguments.Policy, arguments.nCouldYou, CDNumbers)>
					<cfset local.sResponse 	= UAPI.callUAPI('VehicleService', sMessage, SearchID)>
					<cfset local.aResponse 	= UAPI.formatUAPIRsp(sResponse)>
					<cfset local.stCars     = parseCars(aResponse, 1)>
					<cfif arguments.nCouldYou EQ 0>
						<cfset local.stCars     = checkPolicy(stCars, arguments.Filter.getSearchID(), arguments.Account, arguments.Policy)>
						<cfset local.stCars     = addJavascript(stCars)>
						<cfset session.searches[SearchID].stCarVendors      = getVendors((structKeyExists(session.searches[SearchID], 'stCarVendors') ? session.searches[SearchID].stCarVendors : StructNew('linked')), stCars, arguments.Account)>
						<cfset session.searches[SearchID].stCarCategories   = getCategories((structKeyExists(session.searches[SearchID], 'stCarCategories') ? session.searches[SearchID].stCarCategories : StructNew('linked')), stCars)>
						<cfset session.searches[SearchID].stCars            = mergeCars(stCars)>
					<cfelse>
						<cfset thread.stCars     = stCars>
					</cfif>
				</cfthread>
			</cfif>
			
			<cfset stThreads['stPublicRates'&nUniqueThreadName] = ''>
			<cfthread
			name="stPublicRates#nUniqueThreadName#"
			Filter="#arguments.Filter#"
			Account="#arguments.Account#"
			Policy="#arguments.Policy#"
			nCouldYou="#arguments.nCouldYou#">
				<cfset local.sMessage	= prepareSoapHeader(arguments.Filter, arguments.Account, arguments.Policy, arguments.nCouldYou)>
				<cfset local.sResponse 	= UAPI.callUAPI('VehicleService', sMessage, SearchID)>
				<cfset local.aResponse 	= UAPI.formatUAPIRsp(sResponse)>
				<cfset local.stCars     = parseCars(aResponse, 0)>
				<cfif arguments.nCouldYou EQ 0>
					<cfset local.stCars     = checkPolicy(stCars, arguments.Filter.getSearchID(), arguments.Account, arguments.Policy)>
					<cfset local.stCars     = addJavascript(stCars)>
					<cfset session.searches[SearchID].stCarVendors      = getVendors((structKeyExists(session.searches[SearchID], 'stCarVendors') ? session.searches[SearchID].stCarVendors : StructNew('linked')), stCars, arguments.Account)>
					<cfset session.searches[SearchID].stCarCategories   = getCategories((structKeyExists(session.searches[SearchID], 'stCarCategories') ? session.searches[SearchID].stCarCategories : StructNew('linked')), stCars)>
					<cfset session.searches[SearchID].stCars            = mergeCars(stCars)>
				<cfelse>
					<cfset thread.stCars     = stCars>
				</cfif>
			</cfthread>

			<cfif arguments.sPriority EQ 'HIGH'
			OR arguments.nCouldYou NEQ 0>
				<cfthread action="join" name="#StructKeyList(stThreads)#" />
				<cfif arguments.nCouldYou NEQ 0>
					<cfif structKeyExists(cfthread['stCorporateRates#nUniqueThreadName#'].stCars, sCarType)
					AND structKeyExists(cfthread['stCorporateRates#nUniqueThreadName#'].stCars[sCarType], sCarChain)>
						<cfset CarRate = cfthread['stCorporateRates#nUniqueThreadName#'].stCars[sCarType][sCarChain].EstimatedTotalAmount>
					<cfelseif structKeyExists(cfthread['stPublicRates#nUniqueThreadName#'].stCars, sCarType)
					AND structKeyExists(cfthread['stPublicRates#nUniqueThreadName#'].stCars[sCarType], sCarChain)>
						<cfset CarRate = cfthread['stPublicRates#nUniqueThreadName#'].stCars[sCarType][sCarChain].EstimatedTotalAmount>
					</cfif>
				</cfif>
			</cfif>

			<cfset session.searches[SearchID].stCars.fLowestCarRate = findLowestCarRate(session.searches[SearchID].stCars) />
		</cfif>

		<cfreturn CarRate>
	</cffunction>

<!--- prepareSOAPHeader --->
	<cffunction name="prepareSOAPHeader" output="false">
		<cfargument name="Filter" 		required="true">
		<cfargument name="Account"	    required="false">
		<cfargument name="Policy" 	    required="false">
		<cfargument name="nCouldYou"	required="false"	default="0">
		<cfargument name="CDNumbers" 	required="false"	default="">
		<cfargument name="bFullRequest" required="false"	default="false">

		<cfset local.SearchID = arguments.Filter.getSearchID()>

		<!--- <cfif arguments.Filter.getAir() AND structKeyExists(session.searches[SearchID].stItinerary, 'Air')>
			<cfset local.dPickUp = session.searches[SearchID].stItinerary.Air.Groups[0].ArrivalTime>
			<cfif arguments.Filter.getAirType() EQ 'RT'>
				<cfset local.dDropOff = session.searches[SearchID].stItinerary.Air.Groups[1].DepartureTime>
			<cfelseif arguments.Filter.getAirType() EQ 'OW'>
				<cfset local.dDropOff = getsearch.Arrival_DateTime>
			<cfelseif arguments.Filter.getAirType() EQ 'MD'>
				<!--- Not allowed at this time --->
			</cfif>
		<cfelse>
			<cfset local.dPickUp = arguments.Filter.getDepartDate()>
			<cfset local.dDropOff = arguments.Filter.getArrivalDate()>
		</cfif> --->
		<cfset local.dPickUp = arguments.Filter.getCarPickupDateTime()>
		<cfset local.dDropOff = arguments.Filter.getCarDropoffDateTime()>
		<cfset session.searches[SearchID].dPickUp = dPickUp>
		<cfset session.searches[SearchID].dDropOff = dDropOff>
		
		<cfsavecontent variable="local.sMessage">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<veh:VehicleSearchAvailabilityReq TargetBranch="#arguments.Account.sBranch#" xmlns:com="http://www.travelport.com/schema/common_v15_0" xmlns:veh="http://www.travelport.com/schema/vehicle_v17_0" ReturnExtraRateInfo="true" ReturnApproximateTotal="true" ReturnAllRates="true">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
							<veh:VehicleDateLocation
								ReturnLocationType="Airport"
								PickupLocation="#arguments.Filter.getCarPickupAirport()#"
								PickupDateTime="#DateFormat(DateAdd('d',arguments.nCouldYou,dPickUp), 'yyyy-mm-dd')#T#TimeFormat(dPickUp, 'HH:mm')#:00" 
								PickupLocationType="Airport"
								ReturnLocation="#arguments.Filter.getCarPickupAirport()#"
								ReturnDateTime="#DateFormat(DateAdd('d',arguments.nCouldYou,dDropOff), 'yyyy-mm-dd')#T#TimeFormat(dDropOff, 'HH:mm')#:00" />
							<veh:VehicleSearchModifiers>
								<veh:VehicleModifier AirConditioning="true" TransmissionType="Automatic" />
								<cfif IsStruct(arguments.CDNumbers) >
									<cfloop collection="#arguments.CDNumbers#" index="local.sVendorCode">
										<veh:RateModifiers DiscountNumber="#arguments.CDNumbers[sVendorCode].CD#" VendorCode="#sVendorCode#" />
									</cfloop>
								</cfif>
							</veh:VehicleSearchModifiers>  
						</veh:VehicleSearchAvailabilityReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn sMessage/>
	</cffunction>
	
<!--- parseCars --->
	<cffunction name="parseCars" output="false">
		<cfargument name="stResponse"	required="true">
		<cfargument name="bCorporate"	required="false"	default="0">
		
		<!--- If you update this list, update it in getCategories too --->
		<cfset local.aClassCategories = ['EconomyCar','CompactCar','IntermediateCar','StandardCar','FullsizeCar','LuxuryCar','PremiumCar','SpecialCar','MiniVan','MinivanVan','StandardVan','FullsizeVan','LuxuryVan','PremiumVan','SpecialVan','OversizeVan','TwelvePassengerVanVan','FifteenPassengerVanVan','SmallSUVSUV','MediumSUVSUV','IntermediateSUV','StandardSUV','FullsizeSUV','LargeSUVSUV','LuxurySUV','PremiumSUV','SpecialSUV','OversizeSUV']>
		<cfset local.stCars = {}>
		<cfset local.stCar = {}>
		<cfset local.sVendorClassCategory = ''>
		<cfset local.sVendorCode = ''>
		<cfloop array="#arguments.stResponse#" index="local.stVehicle">
			<cfif stVehicle.XMLName EQ 'vehicle:Vehicle'>
				<cfset sVendorClassCategory = stVehicle.XMLAttributes.VehicleClass&stVehicle.XMLAttributes.Category>
				<cfif ArrayFindNoCase(aClassCategories, sVendorClassCategory)>
					<cfset sVendorCode = stVehicle.XMLAttributes.VendorCode>
					<cfset stCar = {
						DoorCount			: 	(StructKeyExists(stVehicle.XMLAttributes, 'DoorCount') ? stVehicle.XMLAttributes.DoorCount : ''),
						Location			: 	stVehicle.XMLAttributes.Location,
						TransmissionType	: 	stVehicle.XMLAttributes.TransmissionType,
						VehicleClass		: 	stVehicle.XMLAttributes.VehicleClass,
						Category			: 	stVehicle.XMLAttributes.Category,
						VendorLocationKey	: 	stVehicle.XMLAttributes.VendorLocationKey,
						Corporate 			:	(bCorporate EQ 1 ? true : false)
					}>
					<cfloop array="#stVehicle.XMLChildren#" index="local.stVehicleRate">
						<cfif stVehicleRate.XMLName EQ 'vehicle:VehicleRate'>
							<cfif NOT StructKeyExists(stCar, 'EstimatedTotalAmount')
							OR stCar.EstimatedTotalAmount GT stVehicleRate.XMLAttributes.EstimatedTotalAmount>
								<cfset stCar.Policy = 1>
								<cfset stCar.EstimatedTotalAmount = stVehicleRate.XMLAttributes.EstimatedTotalAmount>
								<cfset stCar.RateAvailability = stVehicleRate.XMLAttributes.RateAvailability>
								<cfset stCar.RateCategory = stVehicleRate.XMLAttributes.RateCategory>
								<cfset stCar.RateCode = stVehicleRate.XMLAttributes.RateCode>
							</cfif>
						</cfif>
					</cfloop>
					<cfset stCars[sVendorClassCategory][sVendorCode] = stCar>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn stCars />
	</cffunction>

<!---
mergeCars
--->
	<cffunction name="mergeCars" output="false">
		<cfargument name="stNewCars"    required="true">

		<cfset local.stCars = (structKeyExists(session.searches[SearchID], 'stCars') ? session.searches[SearchID].stCars : {})>
		<cfset local.stNewCars = arguments.stNewCars>
		<!---If they are both structs that contain values--->
		<cfif IsStruct(stCars) AND IsStruct(stNewCars)>
			<!---Loop through the new car struct to be added to the session--->
			<cfloop collection="#stNewCars#" item="local.stNewClass" index="local.sNewClass">
				<!---If the car category already exists--->
				<cfif structKeyExists(stCars, sNewClass)>
					<!---Loop through each vendor--->
					<cfloop collection="#stNewClass#" item="local.stNewVendor" index="local.sNewVendor">
						<!---If the new one is a corporate rate, just add/override it.--->
						<cfif stNewVendor.Corporate>
							<cfset stCars[sNewClass][sNewVendor] = stNewVendor>
						<!---If it isn't a corporate rate, if it doesn't exist then add it.--->
						<cfelseif NOT structKeyExists(stCars[sNewClass], sNewVendor)>
							<cfset stCars[sNewClass][sNewVendor] = stNewVendor>
						</cfif>
					</cfloop>
				<!---If the car category doesn't exists just add the whole struct for that category--->
				<cfelse>
					<cfset stCars[sNewClass] = stNewClass>
				</cfif>
			</cfloop>
		<cfelseif IsStruct(stNewCars)>
			<cfset stCars = stNewCars>
		</cfif>
		<cfif NOT IsStruct(stCars)>
			<cfset stCars = {}>
		</cfif>

		<cfreturn stCars/>
	</cffunction>
	
<!---
checkPolicy
--->
	<cffunction name="checkPolicy" output="false">
		<cfargument name="stCars"  	required="true">
		<cfargument name="SearchID"	required="true">
		<cfargument name="Account"	required="false">
		<cfargument name="Policy" 	required="false">
		
		<cfset local.stCars = arguments.stCars>
		<cfset local.aPolicy = {}>
		<cfset local.bActive = 1>
		<cfset local.bBlacklisted = (ArrayLen(arguments.Account.aNonPolicyCar) GT 0 ? 1 : 0)>
		
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
					<cfset stCars[sCategory][sVendor].Policy = (ArrayIsEmpty(aPolicy) ? true : false)>
					<cfset stCars[sCategory][sVendor].aPolicies = aPolicy>
				<cfelse>
					<cfset temp = StructDelete(stCars[sCategory], sVendor)>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn stCars/>
	</cffunction>

<!---
findLowestCarRate
--->
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

<!---
addJavascript
--->
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

<!---
getVendors
--->
	<cffunction name="getVendors" output="false">
		<cfargument name="stCarVendors"	required="true">
		<cfargument name="stCars" 	    required="true">
		<cfargument name="Account" 	    required="true">
		
		<cfset local.stCars = arguments.stCars>
		<cfset local.stCarVendors = (IsStruct(arguments.stCarVendors) ? arguments.stCarVendors : StructNew('linked'))>
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

<!---
getCategories
--->
	<cffunction name="getCategories" output="false">
		<cfargument name="stCarCategories"	required="true">
		<cfargument name="stCars" 	        required="true">

		<cfset local.stCars = arguments.stCars>
		<cfset local.stCarCategories = (IsStruct(arguments.stCarCategories) ? arguments.stCarCategories : StructNew('linked'))>
		<!--- If you update this list, update it in parseCars too --->
		<cfset local.aClassCategories = ['EconomyCar','CompactCar','IntermediateCar','StandardCar','FullsizeCar','LuxuryCar','PremiumCar','SpecialCar','MiniVan','MinivanVan','StandardVan','FullsizeVan','LuxuryVan','PremiumVan','SpecialVan','OversizeVan','TwelvePassengerVanVan','FifteenPassengerVanVan','SmallSUVSUV','MediumSUVSUV','IntermediateSUV','StandardSUV','FullsizeSUV','LargeSUVSUV','LuxurySUV','PremiumSUV','SpecialSUV','OversizeSUV']>
		<cfloop array="#aClassCategories#" index="local.sCategory">
			<cfif StructKeyExists(stCars, sCategory)>
				<cfset stCarCategories[sCategory] = ''>
			</cfif>
		</cfloop>
		
		<cfreturn stCarCategories/>
	</cffunction>

<!---
selectCar
--->
	<cffunction name="selectCar" output="false">
		<cfargument name="SearchID">
		<cfargument name="sCategory">
		<cfargument name="sVendor">

		<!--- Initialize or overwrite the CouldYou car section --->
		<cfset session.searches[arguments.SearchID].CouldYou.Car = {} >
		<cfset session.searches[arguments.SearchID].Car = true >
		<!--- Move over the information into the stItinerary --->
		<cfset session.searches[arguments.SearchID].stItinerary.Car = session.searches[arguments.SearchID].stCars[arguments.sCategory][arguments.sVendor]>
		<cfset session.searches[arguments.SearchID].stItinerary.Car.VendorCode = arguments.sVendor>

		<cfreturn />
	</cffunction>

<!---
getSearchCriteria
--->
	<cffunction name="getSearchCriteria" output="false">
		<cfargument name="search" required="true" />

		<cfset var carPickupAirport = arguments.search.getCarPickupAirport() />
		<cfset var carPickupDateTime = arguments.search.getCarPickupDateTime() />
		<cfset var carDropoffDateTime = arguments.search.getCarDropoffDateTime() />
		<cfset var formData = {} />

		<!--- Pre-set the form variables in the car change search form with the old search parameters. --->
		<cfif len(trim(carPickupAirport))>
			<cfset formData.carPickupAirport = carPickupAirport />
		</cfif>

		<cfset formData.carPickupDate = (isDate(carPickupDateTime) ? dateFormat(carPickupDateTime, 'mmm dd, yyyy') : 'pick up date') />
		<cfset formData.carPickupTimeValue = (isDate(carPickupDateTime) ? timeFormat(carPickupDateTime, 'HH:mm') : '08:00') />
		<cfset formData.carPickupTimeDisplay = (isDate(carPickupDateTime) ? timeFormat(carPickupDateTime, 'hh:mm tt') : '08:00 AM') />

		<cfset formData.carDropoffDate = (isDate(carDropoffDateTime) ? dateFormat(carDropoffDateTime, 'mmm dd, yyyy') : 'drop off date') />
		<cfset formData.carDropoffTimeValue = (isDate(carDropoffDateTime) ? timeFormat(carDropoffDateTime, 'HH:mm') : '08:00') />
		<cfset formData.carDropoffTimeDisplay = (isDate(carDropoffDateTime) ? timeFormat(carDropoffDateTime, 'hh:mm tt') : '08:00 AM') />

		<cfreturn formData />
	</cffunction>

<!---
updateSearch
--->
	<!--- <cffunction name="updateSearch" access="remote" output="false" returnformat="json">
		<cfargument name="searchID" required="true" />
		<cfargument name="carPickupAirport" required="true" />
		<cfargument name="carPickupDate" required="true" />
		<cfargument name="carPickupTime" required="true" />
		<cfargument name="carDropoffDate" required="true" />
		<cfargument name="carDropoffTime" required="true" />

		<cfset var result = new com.shortstravel.RemoteResponse() />

		<cfif structKeyExists( arguments, "carPickupDate" ) AND isDate( arguments.carPickupDate )>
			<cftry>
				<cfset arguments.carPickupDateTime = createDateTime( year( arguments.carPickupDate ), month( arguments.carPickupDate ), day( arguments.carPickupDate ), hour( arguments.carPickupTime ), minute( arguments.carPickupTime ), 0 ) />
				<cfcatch type="any">
					<cfset arguments.carPickupDateTime = createDateTime( year( arguments.carPickupDate ), month( arguments.carPickupDate ), day( arguments.carPickupDate ), 0, 0, 0 ) />
				</cfcatch>
			</cftry>
		</cfif>
		<cfif structKeyExists( arguments, "carDropoffDate" ) AND isDate( arguments.carDropoffDate )>
			<cftry>
				<cfset arguments.carDropoffDateTime = createDateTime( year( arguments.carDropoffDate ), month( arguments.carDropoffDate ), day( arguments.carDropoffDate ), hour( arguments.carDropoffTime ), minute( arguments.carDropoffTime ), 0 ) />
				<cfcatch type="any">
					<cfset arguments.carDropoffDateTime = createDateTime( year( arguments.carDropoffDate ), month( arguments.carDropoffDate ), day( arguments.carDropoffDate ), 0, 0, 0 ) />
				</cfcatch>
			</cftry>
		</cfif>

		<cftry>
			<cfquery datasource="book">
				UPDATE Searches
				SET CarPickup_Airport = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carPickupAirport#" />
					,CarPickup_DateTime = 
						<cfif isDate( arguments.carPickupDateTime )>
							<cfqueryparam value="#CreateODBCDateTime(arguments.carPickupDateTime)#" cfsqltype="cf_sql_timestamp" />
						<cfelse>
							NULL
						</cfif>
					,CarDropoff_DateTime = 
						<cfif isDate( arguments.carDropoffDateTime )>
							<cfqueryparam value="#CreateODBCDateTime(arguments.carDropoffDateTime)#" cfsqltype="cf_sql_timestamp">
						<cfelse>
							NULL
						</cfif>
				WHERE Search_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.searchID#" />
			</cfquery>

			<cfcatch type="any">
				<cfset result.addError( "An error occurred while updating your car search." ) />
				<cfset result.setSuccess( false ) />
			</cfcatch>
		</cftry>

        <cfreturn result />
	</cffunction> --->

</cfcomponent>