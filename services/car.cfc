<cfcomponent output="false">
	
<!--- doAvailability --->
	<cffunction name="doAvailability" output="false">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="vendor" 		required="faluse" default="">
		<cfargument name="stAccount"	required="false"	default="#application.stAccounts[session.Acct_ID]#">
		<cfargument name="stPolicy" 	required="false"	default="#application.stPolicies[session.searches[url.Search_ID].Policy_ID]#">
		
		<cfif NOT structKeyExists( session.searches[nSearchID], "stCars")
		OR StructIsEmpty(session.searches[nSearchID].stCars)>
			<cfset local.qCDNumbers = searchCDNumbers(session.searches[arguments.nSearchID].Value_ID, session.Acct_ID)>
			<cfset local.sMessage = prepareSoapHeader(arguments.stAccount, arguments.stPolicy, nSearchID, qCDNumbers)>
			<cfset local.sResponse = application.objUAPI.callUAPI('VehicleService', sMessage, nSearchID)>
			<cfset local.aResponse = application.objUAPI.formatUAPIRsp(sResponse)>
			<cfset local.stCars = parseCars(aResponse)>
			<cfset session.searches[nSearchID].stCarVendors = sortVendors(stCars, aResponse, arguments.stAccount)>
			<cfset session.searches[nSearchID].stCarCategories = sortCategories(stCars, arguments.nSearchID, arguments.stPolicy)>
			<cfset session.searches[nSearchID].stCars = checkPolicy(stCars, arguments.nSearchID, arguments.stPolicy, arguments.stAccount)>
		</cfif>
		<!---<cfset session.searches[nSearchID].stTrips = addJavascript(stTrips)>--->
		
		<cfreturn >
	</cffunction>
	
<!--- searchCDNumbers --->
	<cffunction name="searchCDNumbers" output="false">
		<cfargument name="Value_ID" 	required="true">
		<cfargument name="Acct_ID"		default="#session.Acct_ID#">
		
		<cfquery name="local.qCDNumbers" datasource="book">
		SELECT Vendor_Code, CD_Number
		FROM CD_Numbers
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_numeric" />
		AND (Value_ID = <cfqueryparam value="#arguments.Value_ID#" cfsqltype="cf_sql_numeric" />
		OR Value_ID IS NULL)
		</cfquery>
		
		<cfreturn qCDNumbers>
	</cffunction>

<!--- prepareSOAPHeader --->
	<cffunction name="prepareSOAPHeader" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="stPolicy" 	required="true">
		<cfargument name="vendor" 	required="true">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="qCDNumbers" 	required="true">
		
		<cfquery name="local.getsearch" datasource="book">
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
								PickupDateTime="#DateFormat(getsearch.Depart_DateTime, 'yyyy-mm-dd')#T08:00:00.000+01:00"
								PickupLocationType="Airport"
								ReturnLocation="#getsearch.Arrival_City#"
								ReturnDateTime="#DateFormat(getsearch.Arrival_DateTime, 'yyyy-mm-dd')#T17:00:00.000+01:00" />
							<veh:VehicleSearchModifiers>
								<veh:VehicleModifier AirConditioning="true" TransmissionType="Automatic" />
								<cfloop query="arguments.qCDNumbers">
									<veh:RateModifiers DiscountNumber="#arguments.qCDNumbers.CD_Number#" VendorCode="#arguments.qCDNumbers.Vendor_Code#" />
								</cfloop>
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
		
		<cfset local.stCars = StructNew('linked')>
		<cfset local.sVendorClass = ''>
		<cfset local.sVendorCode = ''>
		<cfloop array="#arguments.stResponse#" index="local.stVehicle">
			<cfif stVehicle.XMLName EQ 'vehicle:Vehicle'>
				<cfset sVendorClass = stVehicle.XMLAttributes.VehicleClass>
				<cfset sVendorCode = stVehicle.XMLAttributes.VendorCode>
				<cfset stCars[sVendorClass][sVendorCode] = {
					DoorCount			: 	(StructKeyExists(stVehicle.XMLAttributes, 'DoorCount') ? stVehicle.XMLAttributes.DoorCount : ''),
					Location			: 	stVehicle.XMLAttributes.Location,
					TransmissionType	: 	stVehicle.XMLAttributes.TransmissionType,
					Category			: 	stVehicle.XMLAttributes.Category,
					VendorLocationKey	: 	stVehicle.XMLAttributes.VendorLocationKey
				}>
				<cfloop array="#stVehicle.XMLChildren#" index="local.stVehicleRate">
					<cfif stVehicleRate.XMLName EQ 'vehicle:VehicleRate'>
						<cfif NOT StructKeyExists(stCars[sVendorClass][sVendorCode], 'EstimatedTotalAmount')
						OR stCars[sVendorClass][sVendorCode].EstimatedTotalAmount GT stVehicleRate.XMLAttributes.EstimatedTotalAmount>
							<cfset stCars[sVendorClass][sVendorCode].Policy = RandRange(0,1)>
							<cfset stCars[sVendorClass][sVendorCode].EstimatedTotalAmount = stVehicleRate.XMLAttributes.EstimatedTotalAmount>
							<cfset stCars[sVendorClass][sVendorCode].RateAvailability = stVehicleRate.XMLAttributes.RateAvailability>
							<cfset stCars[sVendorClass][sVendorCode].RateCategory = stVehicleRate.XMLAttributes.RateCategory>
							<cfset stCars[sVendorClass][sVendorCode].RateCode = stVehicleRate.XMLAttributes.RateCode>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfreturn stCars />
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
	
<!--- sortCategories --->
	<cffunction name="sortCategories" output="false">
		<cfargument name="stCars"		required="true">
		<cfargument name="nSearchID">
		<cfargument name="stPolicy">
		
		<cfset local.stCarCategories = StructNew('linked')>
		
		<!--- Standard sorting for car categories --->
		<cfset local.stOrder = ['ECONOMY', 'ECONOMYELITE', 'COMPACT', 'COMPACTELITE', 'INTERMEDIATE', 'INTERMEDIATEELITE', 'STANDARD', 'STANDARDELITE', 'FULLSIZE', 'FULLSIZEELITE', 'PREMIUM', 'PREMIUMELITE', 'LUXURY', 'LUXURYELITE', 'SUV', 'MINI', 'MINIELITE', 'VAN', 'OVERSIZE', 'SPECIAL']>
		<!--- Loop through the correct order and add if that category was returned --->
		<cfloop array="#stOrder#" index="local.sOrder" >
			<cfif StructKeyExists(arguments.stCars, sOrder)>
				<cfset stCarCategories[sOrder] = ''>
			</cfif>
		</cfloop>
		<!--- Loop through the results and add to the end of the list if it isn't in the standard list/order --->
		<cfloop array="#StructKeyArray(stCars)#" index="local.sCategory" >
			<cfif StructKeyExists(stCarCategories, sCategory)>
				<cfset stCarCategories[sCategory] = ''>
			</cfif>
		</cfloop>
		
		<cfreturn stCarCategories />
	</cffunction>
	
<!--- checkPolicy --->
	<cffunction name="checkPolicy" output="true">
		<cfargument name="stCars" type="any" required="false">
		<cfargument name="nSearchID">
		<cfargument name="stPolicy">
		<cfargument name="stAccount">
		
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
				<!--- Out of policy if the car type is not allowed.  --->
				<cfif arguments.stPolicy.Policy_CarTypeRule EQ 1
				AND NOT ArrayFindNoCase(arguments.stPolicy.aCarSizes, sCategory)>
					<cfset ArrayAppend(aPolicy, 'Car type not preferred')>
					<cfif arguments.stPolicy.Policy_CarPrefDisp EQ 1>
						<cfset bActive = 0>
					</cfif>
				</cfif>
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
	
</cfcomponent>