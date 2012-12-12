<cfcomponent output="false">
	
<!--- doAvailability --->
	<cffunction name="doAvailability" output="false">
		<cfargument name="nSearchID" 	required="true">
		
		<cfset StructDelete(session.searches[nSearchID], 'stCars')>

		<cfif NOT structKeyExists(session.searches[nSearchID], "stCars")
		OR StructIsEmpty(session.searches[nSearchID].stCars)>
			<cfset local.stThreads = {}>
			<cfset local.qCDNumbers = searchCDNumbers(session.searches[arguments.nSearchID].nValueID)>
			<cfif NOT qCDNumbers.RecordCount>
				<cfset stThreads.stCorporateRates = ''>
				<cfthread
				name="stCorporateRates"
				nSearchID="#arguments.nSearchID#"
				qCDNumbers="#qCDNumbers#">
					<cfset local.sMessage	= prepareSoapHeader(nSearchID, qCDNumbers)>
					<cfset local.sResponse 	= application.objUAPI.callUAPI('VehicleService', sMessage, arguments.nSearchID)>
					<cfset local.aResponse 	= application.objUAPI.formatUAPIRsp(sResponse)>
					<cfset thread.stCars  	= parseCars(aResponse, 1)>
				</cfthread>
			</cfif>
			<cfset stThreads.stPublicRates = ''>
			<cfthread
			name="stPublicRates"
			nSearchID="#arguments.nSearchID#">
				<cfset local.sMessage	= prepareSoapHeader(nSearchID)>
				<cfset local.sResponse 	= application.objUAPI.callUAPI('VehicleService', sMessage, arguments.nSearchID)>
				<cfset local.aResponse 	= application.objUAPI.formatUAPIRsp(sResponse)>
				<cfset thread.stCars  	= parseCars(aResponse, 0)>
			</cfthread>
			
			<cfthread action="join" name="#StructKeyList(stThreads)#" />
			<cfif ArrayLen(StructKeyArray(stThreads)) GT 1>
				<cfset local.stCars = mergeCars(stCorporateRates.stCars, stPublicRates.stCars)>
			<cfelse>
				<cfset local.stCars = stPublicRates.stCars>
			</cfif>

			<cfset stCars = checkPolicy(stCars, arguments.nSearchID)>
			<cfset session.searches[nSearchID].stCarVendors = getVendors(stCars)>
			<cfset session.searches[nSearchID].stCarCategories = getCategories(stCars)>
			<cfset session.searches[nSearchID].stCars = addJavascript(stCars)>
			<!--- <cfdump var="#stCars#" abort> --->
		</cfif>

		<!---<cfset session.searches[nSearchID].stTrips = addJavascript(stTrips)>--->
		
		<cfreturn >
	</cffunction>

<!--- searchCDNumbers --->
	<cffunction name="searchCDNumbers" output="false">
		<cfargument name="nValueID" 	required="true">
		<cfargument name="Acct_ID"		required="false"	default="#session.Acct_ID#">
		
		<cfquery name="local.qCDNumbers">
		SELECT Vendor_Code, CD_Number
		FROM CD_Numbers
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_numeric" />
		AND (Value_ID = <cfqueryparam value="#arguments.nValueID#" cfsqltype="cf_sql_numeric" />
		OR Value_ID IS NULL)
		</cfquery>
		
		<cfreturn qCDNumbers>
	</cffunction>

<!--- prepareSOAPHeader --->
	<cffunction name="prepareSOAPHeader" output="false">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="qCDNumbers" 	required="false"	default="">
		<cfargument name="bFullRequest" required="false"	default="false">
		<cfargument name="stAccount"	required="false"	default="#application.stAccounts[session.Acct_ID]#">
		<cfargument name="stPolicy" 	required="false"	default="#application.stPolicies[session.searches[url.Search_ID].nPolicyID]#">
		
		<cfquery name="local.getsearch">
		SELECT Depart_DateTime, Arrival_City, Arrival_DateTime
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		
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
								PickupDateTime="#DateFormat(getsearch.Depart_DateTime, 'yyyy-mm-dd')#T08:00:00" 
								PickupLocationType="Airport"
								ReturnLocation="#getsearch.Arrival_City#"
								ReturnDateTime="#DateFormat(getsearch.Arrival_DateTime, 'yyyy-mm-dd')#T17:00:00" />
							<veh:VehicleSearchModifiers>
								<veh:VehicleModifier AirConditioning="true" TransmissionType="Automatic" />
								<cfif IsQuery(arguments.qCDNumbers) >
									<cfloop query="arguments.qCDNumbers">
										<veh:RateModifiers DiscountNumber="#arguments.qCDNumbers.CD_Number#" VendorCode="#arguments.qCDNumbers.Vendor_Code#" />
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
		
		<cfset local.aClassCategories = ['CompactCar','CompactSUV','EconomyCar','FullsizeCar', 'FullsizeSUV', 'FullsizeVan', 'IntermediateCar','IntermediateSUV','IntermediateVan','LuxuryCar','LuxurySUV','MiniVan','PremiumCar','PremiumSUV','PremiumVan','StandardCar','StandardSUV','StandardVan']>
		<cfset local.stCars = {}>
		<cfset local.sVendorClassCategory = ''>
		<cfset local.sVendorCode = ''>
		<cfloop array="#arguments.stResponse#" index="local.stVehicle">
			<cfif stVehicle.XMLName EQ 'vehicle:Vehicle'>
				<cfset sVendorClassCategory = stVehicle.XMLAttributes.VehicleClass&stVehicle.XMLAttributes.Category>
				<cfif ArrayFindNoCase(aClassCategories, sVendorClassCategory)>
					<cfset sVendorCode = stVehicle.XMLAttributes.VendorCode>
					<cfset stCars[sVendorClassCategory][sVendorCode] = {
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
							<cfif NOT StructKeyExists(stCars[sVendorClassCategory][sVendorCode], 'EstimatedTotalAmount')
							OR stCars[sVendorClassCategory][sVendorCode].EstimatedTotalAmount GT stVehicleRate.XMLAttributes.EstimatedTotalAmount>
								<cfset stCars[sVendorClassCategory][sVendorCode].Policy = 1>
								<cfset stCars[sVendorClassCategory][sVendorCode].EstimatedTotalAmount = stVehicleRate.XMLAttributes.EstimatedTotalAmount>
								<cfset stCars[sVendorClassCategory][sVendorCode].RateAvailability = stVehicleRate.XMLAttributes.RateAvailability>
								<cfset stCars[sVendorClassCategory][sVendorCode].RateCategory = stVehicleRate.XMLAttributes.RateCategory>
								<cfset stCars[sVendorClassCategory][sVendorCode].RateCode = stVehicleRate.XMLAttributes.RateCode>
							</cfif>
						</cfif>
					</cfloop>
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
		
		<cfset local.stCars = arguments.stCorporate>
		<cfif IsStruct(stCars) AND IsStruct(arguments.stPublic)>
			<cfloop collection="#arguments.stPublic#" item="local.sClassCategory">
				<cfif structKeyExists(stCars, sClassCategory)>
					<cfloop collection="#arguments.stPublic[sClassCategory]#" item="local.sVendor">
						<cfif NOT structKeyExists(stCars[sClassCategory], sVendor)>
							<cfset stCars[sClassCategory][sVendor] = arguments.stPublic[sClassCategory][sVendor]>
						</cfif>
					</cfloop>
				<cfelse>
					<cfset stCars[sClassCategory] = arguments.stPublic[sClassCategory]>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset stCars = arguments.stPublic>
		</cfif>
		<cfif NOT IsStruct(stCars)>
			<cfset stCars = {}>
		</cfif>
		
		<cfreturn stCars/>
	</cffunction>
	
<!--- sortVendors --->
	<cffunction name="sortVendors" output="false">
		<cfargument name="stCars"			required="true">
		<cfargument name="stResponse"		required="true">
		<cfargument name="stAccount">
		
		<cfset local.stCarVendors = StructNew('linked')>
		<!--- Find preferred vendors first --->
		<cfset local.aPreferredCar = arguments.stAccount.aPreferredCar>
		<cfloop collection="#arguments.stCars#" item="local.sCategory">
			<cfloop collection="#arguments.stCars[sCategory]#" item="local.sVendor">
				<cfif ArrayFindNoCase(aPreferredCar, sVendor)
				AND NOT StructKeyExists(stCarVendors, sVendor)>
					<cfset stCarVendors[sVendor] = ''>
				</cfif>
			</cfloop>
		</cfloop>
		<!--- Add all other vendors in order of lowest to highest rates --->
		<cfloop array="#arguments.stResponse#" index="local.stVehicle">
			<cfif stVehicle.XMLName EQ 'vehicle:Vehicle'>
				<cfset sVendorCode = stVehicle.XMLAttributes.VendorCode>
				<cfloop array="#stVehicle.XMLChildren#" index="local.stVehicleRate">
					<cfif stVehicleRate.XMLName EQ 'vehicle:VehicleRate'>
						<cfif NOT StructKeyExists(stCarVendors, sVendorCode)>
							<cfset stCarVendors[sVendorCode] = ''>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfreturn stCarVendors />
	</cffunction>
	
<!--- checkPolicy --->
	<cffunction name="checkPolicy" output="true">
		<cfargument name="stCars"  		required="true">
		<cfargument name="nSearchID"	required="true">
		<cfargument name="stAccount"	required="false"	default="#application.stAccounts[session.Acct_ID]#">
		<cfargument name="stPolicy" 	required="false"	default="#application.stPolicies[session.searches[url.Search_ID].nPolicyID]#">
		
		<cfset local.stCars = arguments.stCars>
		<cfset local.aPolicy = {}>
		<cfset local.bActive = 1>
		<cfset local.bBlacklisted = (ArrayLen(arguments.stAccount.aNonPolicyCar) GT 0 ? 1 : 0)>
		
		<cfquery name="local.getsearch" datasource="book">
		SELECT Depart_DateTime, Arrival_DateTime
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<cfset local.nDays = DateDiff('d', getsearch.Depart_DateTime, getSearch.Arrival_DateTime)>
		
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
				<!--- Out of policy if the car type is not allowed.
				<cfif arguments.stPolicy.Policy_CarTypeRule EQ 1
				AND NOT ArrayFindNoCase(arguments.stPolicy.aCarSizes, sCategory)>
					<cfset ArrayAppend(aPolicy, 'Car type not preferred')>
					<cfif arguments.stPolicy.Policy_CarPrefDisp EQ 1>
						<cfset bActive = 0>
					</cfif>
				</cfif>  --->
				<!--- Out of policy if the car vendor is blacklisted (still shows though).  --->
				<cfif bBlacklisted
				AND ArrayFindNoCase(arguments.stAccount.aNonPolicyCar, sVendor)>
					<cfset ArrayAppend(aPolicy, 'Out of policy vendor')>
				</cfif>
				<cfif bActive EQ 1>
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
				<cfset sJavascript = ListAppend(sJavascript, (Left(stCar.EstimatedTotalAmount, 3) EQ 'USD' ? Mid(stCar.EstimatedTotalAmount, 4) : stCar.EstimatedTotalAmount))><!--- Amount --->
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
				<cfif ArrayFind(application.stAccounts[session.Acct_ID].aPreferredCar, sVendor)>
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
		
		<cfset local.stCars = arguments.stCars>
		<cfset local.stCarCategories = {}>
		<cfloop collection="#stCars#" item="local.sClassCategory">
			<cfset stCarVendors[sClassCategory] = ''>
		</cfloop>
		
		<cfreturn stCarVendors/>
	</cffunction>
	
</cfcomponent>