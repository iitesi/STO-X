<cfcomponent output="false">

<!---
selectCar
--->
	<cffunction name="selectCar" output="false">
		<cfargument name="SearchID">
		<cfargument name="sCategory">
		<cfargument name="sVendor">

		<!--- Initialize or overwrite the CouldYou car section --->
		<cfset session.searches[arguments.SearchID].CouldYou.Car = {} />
		<cfset session.searches[arguments.SearchID]['Car'] = true />
		<!--- Move over the information into the stItinerary --->
		<cfset session.searches[arguments.SearchID].stItinerary.Car = session.searches[arguments.SearchID].stCars[arguments.sCategory][arguments.sVendor]>
		<cfset session.searches[arguments.SearchID].stItinerary.Car.VendorCode = arguments.sVendor>

		<cfreturn />
	</cffunction>
	
<!---
doAvailability
--->
	<cffunction name="doAvailability" output="false">
		<cfargument name="SearchID">
		<cfargument name="nCouldYou"	default="0">
		<cfargument name="stPolicy"		default="#application.Policies[session.searches[url.Search_ID].PolicyID]#">
		
		<cfset StructDelete(session.searches[SearchID], 'stCars')>

		<cfset local.nUniqueThreadName = arguments.nCouldYou + 100 /><!--- nCouldYou is negative at times, so make sure it's positive so cfthread can read the names properly --->

		<cfif NOT structKeyExists(session.searches[SearchID], 'stCars') OR StructIsEmpty(session.searches[SearchID].stCars)>
			<cfset local.stThreads = {}>
			<cfif NOT StructKeyExists(stPolicy, 'stCDNumbers')>
				<cfset stPolicy.stCDNumbers = searchCDNumbers(session.searches[arguments.SearchID].ValueID)>
				<cfset application.Policies[session.searches[url.Search_ID].PolicyID].stCDNumbers = stPolicy.stCDNumbers>
			</cfif>
			<cfif NOT structIsEmpty(stPolicy.stCDNumbers)>
				<cfset stThreads['stCorporateRates'&nUniqueThreadName] = ''>
				<cfthread name="stCorporateRates#nUniqueThreadName#" SearchID="#arguments.SearchID#" stCDNumbers="#stPolicy.stCDNumbers#" nCouldYou="#arguments.nCouldYou#">
					<cfset sMessage		= prepareSoapHeader(SearchID, arguments.nCouldYou, stCDNumbers)>
					<cfset sResponse 	= application.objUAPI.callUAPI('VehicleService', sMessage, arguments.SearchID)>
					<cfset aResponse 	= application.objUAPI.formatUAPIRsp(sResponse)>
					<cfset thread.stCars= parseCars(aResponse, 1)>
				</cfthread>
			</cfif>
			
			<cfset stThreads['stPublicRates'&nUniqueThreadName] = ''>
			<cfthread name="stPublicRates#nUniqueThreadName#" SearchID="#arguments.SearchID#" nCouldYou="#arguments.nCouldYou#">
				<cfset sMessage		= prepareSoapHeader(arguments.SearchID, arguments.nCouldYou)>
				<cfset sResponse 	= application.objUAPI.callUAPI('VehicleService', sMessage, arguments.SearchID)>
				<cfset aResponse 	= application.objUAPI.formatUAPIRsp(sResponse)>
				<cfset thread.stCars= parseCars(aResponse, 0)>
			</cfthread>

			<cfthread action="join" name="#StructKeyList(stThreads)#" />

			<!--- <cfdump var="#cfthread#" abort> --->
			<cfif ArrayLen(StructKeyArray(stThreads)) GT 1>
				<cfset local.stCars = mergeCars(cfthread['stCorporateRates'&nUniqueThreadName].stCars, cfthread['stPublicRates'&nUniqueThreadName].stCars)>
			<cfelse>
				<cfset local.stCars = cfthread['stPublicRates'&nUniqueThreadName].stCars>
			</cfif>

			<cfif arguments.nCouldYou EQ 0>
<!--- Move to cfthread --->
				<cfset stCars = checkPolicy(stCars, arguments.SearchID)>
				<cfset session.searches[SearchID].stCarVendors = getVendors(stCars)>
				<cfset session.searches[SearchID].stCarCategories = getCategories(stCars)>
				<cfset session.searches[SearchID].stCars = addJavascript(stCars)>
			</cfif>
			<!--- <cfdump var="#stCars#" abort> --->
		</cfif>

		<!---<cfset session.searches[SearchID].stTrips = addJavascript(stTrips)>--->
		<cfset CarAvailability = nCouldYou NEQ 0 ? stCars : '' />
		
		<cfreturn CarAvailability>
	</cffunction>

<!--- searchCDNumbers --->
	<cffunction name="searchCDNumbers" output="false">
		<cfargument name="ValueID" 	required="true">
		<cfargument name="Acct_ID"		required="false"	default="#session.AcctID#">
		
		<cfquery name="local.qCDNumbers">
		SELECT Vendor_Code, CD_Number, DB_Number, DB_Type
		FROM CD_Numbers
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_numeric" />
		AND (Value_ID = <cfqueryparam value="#arguments.ValueID#" cfsqltype="cf_sql_numeric" />
		OR Value_ID IS NULL)
		</cfquery>
		<cfset local.stCDNumbers = {}>
		<cfloop query="qCDNumbers">
			<cfset stCDNumbers[Vendor_Code].CD = CD_Number>
			<cfset stCDNumbers[Vendor_Code].DB = DB_Number>
			<cfset stCDNumbers[Vendor_Code].DBType = DB_Type>
		</cfloop>
		
		<cfreturn stCDNumbers>
	</cffunction>

<!--- prepareSOAPHeader --->
	<cffunction name="prepareSOAPHeader" output="false">
		<cfargument name="SearchID" 		required="true">
		<cfargument name="nCouldYou"		required="false"	default="0">
		<cfargument name="stCDNumbers" 		required="false"	default="">
		<cfargument name="bFullRequest" 	required="false"	default="false">
		<cfargument name="stAccount"		required="false"	default="#application.Accounts[session.AcctID]#">
		<cfargument name="stPolicy" 		required="false"	default="#application.Policies[session.searches[url.Search_ID].PolicyID]#">
		
		<cfquery name="local.getsearch">
		SELECT Depart_DateTime, Arrival_City, Arrival_DateTime, Air_Type
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.SearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		
		<cfif session.searches[arguments.SearchID].Air EQ 1>
			<cfset local.dPickUp = session.searches[arguments.SearchID].stItinerary.Air.Groups[0].ArrivalTime>
			<cfif getsearch.Air_Type EQ 'RT'>
				<cfset local.dDropOff = session.searches[arguments.SearchID].stItinerary.Air.Groups[1].DepartureTime>
			<cfelseif getsearch.Air_Type EQ 'OW'>
				<cfset local.dDropOff = getsearch.Arrival_DateTime>
			<cfelseif getsearch.Air_Type EQ 'MD'>
				<!--- Not allowed at this time --->
			</cfif>
		<cfelse>
			<cfset local.dPickUp = getsearch.Depart_DateTime>
			<cfset local.dDropOff = getsearch.Arrival_DateTime>
		</cfif>
		<cfset session.searches[arguments.SearchID].dPickUp = dPickUp>
		<cfset session.searches[arguments.SearchID].dDropOff = dDropOff>
		
		<cfsavecontent variable="local.sMessage">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<veh:VehicleSearchAvailabilityReq TargetBranch="#arguments.stAccount.sBranch#" xmlns:com="http://www.travelport.com/schema/common_v15_0" xmlns:veh="http://www.travelport.com/schema/vehicle_v17_0" ReturnExtraRateInfo="true" ReturnApproximateTotal="true" ReturnAllRates="true">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
							<veh:VehicleDateLocation
								ReturnLocationType="Airport"
								PickupLocation="#getsearch.Arrival_City#"
								PickupDateTime="#DateFormat(DateAdd('d',arguments.nCouldYou,dPickUp), 'yyyy-mm-dd')#T#TimeFormat(dPickUp, 'HH:mm')#:00" 
								PickupLocationType="Airport"
								ReturnLocation="#getsearch.Arrival_City#"
								ReturnDateTime="#DateFormat(DateAdd('d',arguments.nCouldYou,dDropOff), 'yyyy-mm-dd')#T#TimeFormat(dDropOff, 'HH:mm')#:00" />
							<veh:VehicleSearchModifiers>
								<veh:VehicleModifier AirConditioning="true" TransmissionType="Automatic" />
								<cfif IsStruct(arguments.stCDNumbers) >
									<cfloop collection="#arguments.stCDNumbers#" index="local.sVendorCode">
										<!--- Can have up to 10 --->
										<veh:RateModifiers DiscountNumber="#arguments.stCDNumbers[sVendorCode].CD#" VendorCode="#sVendorCode#" />
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
		<cfargument name="stCorporate" 	required="true">
		<cfargument name="stPublic" 	required="true">
		
		<cfset local.stCars = arguments.stPublic>
		<cfif IsStruct(stCars) AND IsStruct(arguments.stCorporate)>
			<cfloop collection="#arguments.stCorporate#" item="local.stClassCategory" index="local.sClassCategory">
				<cfif structKeyExists(stCars, sClassCategory)>
					<cfloop collection="#stClassCategory#" item="local.stVendor" index="local.sVendor">
						<cfset stCars[sClassCategory][sVendor] = stVendor>
					</cfloop>
				<cfelse>
					<cfset stCars[sClassCategory] = arguments.stCorporate[sClassCategory]>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset stCars = arguments.stCorporate>
		</cfif>
		<cfif NOT IsStruct(stCars)>
			<cfset stCars = {}>
		</cfif>

		<cfreturn stCars/>
	</cffunction>
	
<!---
checkPolicy
--->
	<cffunction name="checkPolicy" output="true">
		<cfargument name="stCars"  		required="true">
		<cfargument name="SearchID"	required="true">
		<cfargument name="stAccount"	required="false"	default="#application.Accounts[session.AcctID]#">
		<cfargument name="stPolicy" 	required="false"	default="#application.Policies[session.searches[url.Search_ID].PolicyID]#">
		
		<cfset local.stCars = arguments.stCars>
		<cfset local.aPolicy = {}>
		<cfset local.bActive = 1>
		<cfset local.bBlacklisted = (ArrayLen(arguments.stAccount.aNonPolicyCar) GT 0 ? 1 : 0)>
		
		<cfquery name="local.getsearch">
			SELECT 	Depart_DateTime, Arrival_DateTime
			FROM 	Searches
			WHERE 	Search_ID = <cfqueryparam value="#arguments.SearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<cfset local.nDays = Int(getSearch.Arrival_DateTime - getsearch.Depart_DateTime)>
		
		<cfloop collection="#stCars#" item="local.sCategory">
			<cfloop collection="#stCars[sCategory]#" item="local.sVendor">
				<cfset aPolicy = []>
				<cfset bActive = 1>
				<!--- Out of policy if they cannot book non preferred vendors. --->
				<cfif arguments.stPolicy.Policy_CarPrefRule EQ 1
				AND NOT ArrayFindNoCase(arguments.stAccount.aPreferredCar, sVendor)>
					<cfset ArrayAppend(aPolicy, 'Not a preferred vendor')>
					<cfif arguments.stPolicy.Policy_CarPrefDisp EQ 1>
						<cfset bActive = 0>
					</cfif>
				</cfif>
				<!--- Out of policy if the car type is not allowed.--->
				<cfif arguments.stPolicy.Policy_CarTypeRule EQ 1
				AND NOT ArrayFindNoCase(arguments.stPolicy.aCarSizes, sCategory)>
					<cfset ArrayAppend(aPolicy, 'Car type not preferred')>
					<cfif arguments.stPolicy.Policy_CarTypeDisp EQ 1>
						<cfset bActive = 0>
					</cfif>
				</cfif>
				<!--- Out of policy if the car vendor is blacklisted (still shows though).  --->
				<cfif bBlacklisted
				AND ArrayFindNoCase(arguments.stAccount.aNonPolicyCar, sVendor)>
					<cfset ArrayAppend(aPolicy, 'Out of policy vendor')>
				</cfif>
				<cfif bActive>
					<cfset stCars[sCategory][sVendor].Policy = (ArrayIsEmpty(aPolicy) ? 1 : 0)>
					<cfset stCars[sCategory][sVendor].aPolicies = aPolicy>
				<cfelse>
					<cfset temp = StructDelete(stCars[sCategory], sVendor)>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn stCars/>
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
		<cfargument name="stCars" 	required="true">
		
		<cfset local.stCars = arguments.stCars>
		<cfset local.stCarVendors = StructNew('linked')>
		<cfloop collection="#stCars#" item="local.sClassCategory">
			<cfloop collection="#stCars[sClassCategory]#" item="local.sVendor">
				<cfif ArrayFind(application.Accounts[session.AcctID].aPreferredCar, sVendor)>
					<cfset stCarVendors[sVendor] = ''>
				</cfif>
			</cfloop>
		</cfloop>
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
		<cfargument name="stCars" 	required="true">
		
		<!--- If you update this list, update it in parseCars too --->
		<cfset local.aClassCategories = ['EconomyCar','CompactCar','IntermediateCar','StandardCar','FullsizeCar','LuxuryCar','PremiumCar','SpecialCar','MiniVan','MinivanVan','StandardVan','FullsizeVan','LuxuryVan','PremiumVan','SpecialVan','OversizeVan','TwelvePassengerVanVan','FifteenPassengerVanVan','SmallSUVSUV','MediumSUVSUV','IntermediateSUV','StandardSUV','FullsizeSUV','LargeSUVSUV','LuxurySUV','PremiumSUV','SpecialSUV','OversizeSUV']>
		<cfset local.stCars = arguments.stCars>
		<cfset local.stCarCategories = StructNew('linked')>
		<cfloop array="#aClassCategories#" index="local.sCategory">
			<cfif StructKeyExists(stCars, sCategory)>
				<cfset stCarCategories[sCategory] = ''>
			</cfif>
		</cfloop>
		
		<cfreturn stCarCategories/>
	</cffunction>
	
</cfcomponent>