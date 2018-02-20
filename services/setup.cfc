<cfcomponent output="false" accessors="true">

	<cfproperty name="assetURL"/>
	<cfproperty name="bookingDSN"/>
	<cfproperty name="corporateProductionDSN"/>
	<cfproperty name="currentEnvironment" />
	<cfproperty name="portalURL"/>
	<cfproperty name="searchService" />
	<cfproperty name="searchWidgetURL" />
	<cfproperty name="useLinkedDatabases" />
	<cfproperty name="userService" />
	<cfproperty name="PolicyService" />
	<cfproperty name="PaymentService" />

	<cffunction name="init" output="false">
		<cfargument name="assetURL" type="string" required="true" />
		<cfargument name="bookingDSN" type="string" required="true" />
		<cfargument name="corporateProductionDSN" type="string" required="true" />
		<cfargument name="currentEnvironment" type="string" required="true" />
		<cfargument name="portalURL" type="string" required="true" />
		<cfargument name="searchService" />
		<cfargument name="searchWidgetURL" type="string" required="true" />
		<cfargument name="useLinkedDatabases" type="boolean" required="true" />
		<cfargument name="userService" />
		<cfargument name="PolicyService" />
		<cfargument name="PaymentService" />

		<cfset setAssetURL( arguments.AssetURL ) />
		<cfset setBookingDSN( arguments.bookingDSN ) />
		<cfset setCorporateProductionDSN( arguments.CorporateProductionDSN ) />
		<cfset setCurrentEnvironment( arguments.currentEnvironment ) />
		<cfset setPortalURL( arguments.portalURL ) />
		<cfset setSearchService( arguments.SearchService ) />
		<cfset setSearchWidgetURL( arguments.searchWidgetURL ) />
		<cfset setUseLinkedDatabases( arguments.useLinkedDatabases ) />
		<cfset setUserService( arguments.userService ) />
		<cfset setPolicyService( arguments.PolicyService ) />
		<cfset setPaymentService( arguments.PaymentService ) />

		<cfreturn this>
	</cffunction>

	<cffunction name="setServerURL" output="false" returntype="void">
		<cfset application.sServerURL = (cgi.https EQ 'on' ? 'https' : 'http')&'://'&cgi.Server_Name&'/booking'>
		<cfreturn />
	</cffunction>

	<!--- Named different to prevent overriding the default setPortalURL from environment service --->
	<cffunction name="setPortalURLLink" output="false" returntype="void">
		<cfset application.sPortalURL = getPortalURL()>
		<cfreturn />
	</cffunction>


	<cffunction name="setWidgetURL" output="false" returntype="void">
		<cfset application.searchWidgetURL = getSearchWidgetURL()>
		<cfreturn />
	</cffunction>

	<cffunction name="setAPIAuth" output="false" returntype="void">
		<cfset application.sAPIAuth = ToBase64('Universal API/UAPI6148916507-02cbc4d4:Qq7?b6*X5B')>
		<cfreturn />
	</cffunction>

	<cffunction name="setFilter" output="false">
		<cfargument name="SearchID" required="true">
		<cfargument name="Append" 	required="false" default="0">
		<cfargument name="requery" required="false" default="false">

		<cfset local.searchfilter = getSearchService().load( arguments.searchId ) />

		<cfif arguments.SearchID NEQ 0>
			<cfquery name="local.getsearch" datasource="#getBookingDSN()#">
				SELECT TOP 1 Acct_ID, Search_ID, Air, Car, CarPickup_Airport, CarPickup_DateTime, CarDropoff_Airport, CarDropoff_DateTime,
				Hotel, Policy_ID, Profile_ID, Value_ID, User_ID, Username, Air_Type, Depart_City, Depart_DateTime, Arrival_City, Arrival_DateTime,
				Airlines, International, Depart_TimeType, Arrival_TimeType, ClassOfService, CheckIn_Date, Arrival_City, CheckOut_Date,
				Hotel_Search, Hotel_Airport, Hotel_Landmark, Hotel_Address, Hotel_City, Hotel_State, Hotel_Zip, Hotel_Country, Office_ID,
				Hotel_Radius, air_heading, car_heading, hotel_heading, findit
				FROM Searches
				WHERE Search_ID = <cfqueryparam value="#arguments.SearchID#" cfsqltype="cf_sql_integer">
				ORDER BY Search_ID DESC
			</cfquery>

			<cfif getsearch.Air_Type EQ 'MD'>
				<cfquery name="local.getsearchlegs" datasource="#getBookingDSN()#" >
					SELECT Depart_City
						, Arrival_City
						, Depart_DateTime
						, Depart_TimeType
					FROM Searches_Legs
					WHERE Search_ID = <cfqueryparam value="#arguments.SearchID#" cfsqltype="cf_sql_numeric" />
					ORDER BY Depart_DateTime
				</cfquery>
			</cfif>

			<cfquery name="local.getCarPickupAirportData" datasource="#getBookingDSN()#">
				SELECT Airport_Name
				, Airport_City
				, Airport_State
				FROM lu_FullAirports
				WHERE Airport_Code = <cfqueryparam value="#getsearch.CarPickup_Airport#" cfsqltype="cf_sql_varchar" />
			</cfquery>

			<cfquery name="local.getCarDropoffAirportData" datasource="#getBookingDSN()#">
				SELECT Airport_Name
				, Airport_City
				, Airport_State
				FROM lu_FullAirports
				WHERE Airport_Code = <cfqueryparam value="#getsearch.CarDropoff_Airport#" cfsqltype="cf_sql_varchar" />
			</cfquery>

			<cfquery name="local.getUserAdmin" datasource="#getCorporateProductionDSN()#">
				SELECT STO_Admin
				FROM Users_Accounts
				WHERE User_ID = <cfqueryparam value="#getsearch.User_ID#" cfsqltype="cf_sql_integer" />
					AND Acct_ID = <cfqueryparam value="#getsearch.Acct_ID#" cfsqltype="cf_sql_integer" />
			</cfquery>
			<cfset local.searchfilter.setUserAdmin(getUserAdmin.STO_Admin) />

			<cfif getsearch.Air>
				<cfswitch expression="#local.getsearch.Air_Type#">

					<!--- Round trip --->
					<cfcase value="RT">
						<cfif DateFormat(local.getsearch.Depart_DateTime) NEQ DateFormat(local.getsearch.Arrival_DateTime)>
							<cfset local.searchfilter.setAirHeading("#application.stAirports[local.getsearch.Depart_City].city# (#local.getsearch.Depart_City#) to #application.stAirports[local.getsearch.Arrival_City].city# (#local.getsearch.Arrival_City#) :: #DateFormat(local.getsearch.Depart_DateTime, 'ddd mmm d')# - #DateFormat(local.getsearch.Arrival_DateTime, 'ddd mmm d')#")>
							<cfset local.searchfilter.setHeading("#local.getsearch.Depart_City# to #local.getsearch.Arrival_City# :: #DateFormat(local.getsearch.Depart_DateTime, 'm/d')# - #DateFormat(local.getsearch.Arrival_DateTime, 'm/d')#")>
						<cfelse>
							<cfset local.searchfilter.setAirHeading("#application.stAirports[local.getsearch.Depart_City].city# (#local.getsearch.Depart_City#) to #application.stAirports[local.getsearch.Arrival_City].city# (#local.getsearch.Arrival_City#) :: #DateFormat(local.getsearch.Depart_DateTime, 'ddd mmm d')#")>
							<cfset local.searchfilter.setHeading("#local.getsearch.Depart_City# to #local.getsearch.Arrival_City# :: #DateFormat(local.getsearch.Depart_DateTime, 'm/d')#")>
						</cfif>
						<cfset local.searchfilter.addLegsForTrip(local.getsearch.Depart_City&' - '&local.getsearch.Arrival_City&' on '&DateFormat(local.getsearch.Depart_DateTime, 'ddd, m/d'))>
						<cfset local.searchfilter.addLegsForTrip(local.getsearch.Arrival_City&' - '&local.getsearch.Depart_City&' on '&DateFormat(local.getsearch.Arrival_DateTime, 'ddd, m/d'))>
						<cfset local.searchfilter.addIsDomesticTrip(getSearchService().getTripType( local.getsearch.Depart_City, local.getsearch.Arrival_City, application.stAirports )) />
					</cfcase>

					<!--- One way --->
					<cfcase value="OW">
						<cfset local.searchfilter.setAirHeading("#application.stAirports[local.getsearch.Depart_City].city# (#local.getsearch.Depart_City#) to #application.stAirports[local.getsearch.Arrival_City].city# (#local.getsearch.Arrival_City#) :: #DateFormat(local.getsearch.Depart_DateTime, 'ddd mmm d')#")>
						<cfset local.searchfilter.setHeading("#local.getsearch.Depart_City# to #local.getsearch.Arrival_City# :: #DateFormat(local.getsearch.Depart_DateTime, 'm/d')#")>
						<cfset local.searchfilter.addLegsForTrip(local.getsearch.Depart_City&' - '&local.getsearch.Arrival_City&' on '&DateFormat(local.getsearch.Depart_DateTime, 'ddd, m/d'))>
						<cfset local.searchfilter.addIsDomesticTrip(getSearchService().getTripType( local.getsearch.Depart_City, local.getsearch.Arrival_City, application.stAirports )) />
					</cfcase>

					<!--- Multi-city --->
					<!--- FYI legs are also added in com/shortstravel/search/searchManager.load() --->
					<cfcase value="MD" >
						<cfset local.breadCrumb = "">
						<cfset local.tripList = "">

						<cfloop query="getsearchlegs">
							<cfif Len(local.breadCrumb)>
								<cfif ListLast(local.breadCrumb, '-') NEQ local.getsearchlegs.depart_city AND local.getsearchlegs.depart_city NEQ local.getsearchlegs.arrival_city>
									<cfset local.breadCrumb = "#local.breadCrumb#-#local.getsearchlegs.depart_city#-#local.getsearchlegs.arrival_city#">
								<cfelse>
									<cfset local.breadCrumb = "#local.breadCrumb#-#local.getsearchlegs.arrival_city#">
								</cfif>
							<cfelse>
								<cfset local.breadCrumb = "#local.getsearchlegs.depart_city#-#local.getsearchlegs.arrival_city#">
							</cfif>
							<cfset local.searchfilter.addLegsForTrip(local.getSearchLegs.Depart_City&' - '&local.getSearchLegs.Arrival_City&' on '&DateFormat(local.getSearchLegs.Depart_DateTime, 'ddd, m/d'))>
							<cfset local.searchfilter.addLegHeader("#application.stAirports[local.getSearchLegs.Depart_City].city# (#local.getSearchLegs.Depart_City#) to #application.stAirports[local.getSearchLegs.Arrival_City].city# (#local.getSearchLegs.Arrival_City#) :: #DateFormat(local.getSearchLegs.Depart_DateTime, 'ddd mmm d')#")>

							<cfset local.isDomesticTripList = getSearchService().getTripType( local.getSearchLegs.Depart_City, local.getSearchLegs.Arrival_City, application.stAirports ) />
							<cfset local.tripList = listAppend(local.tripList, local.isDomesticTripList)>
						</cfloop>
						<!--- populate headings for display --->
						<cfset local.searchfilter.setAirHeading("Multi-city Destinations")>
						<cfset local.searchfilter.setHeading("#local.breadCrumb# :: #DateFormat(local.getSearchLegs.Depart_DateTime[1], 'm/d')#-#DateFormat(local.getSearchLegs.Depart_DateTime[local.getSearchLegs.recordCount], 'm/d')#")>

						<cfset local.searchfilter.addIsDomesticTrip("true")/>
						<cfif listFindNoCase(local.tripList, "false")>
							<cfset local.searchfilter.addIsDomesticTrip("false")/>
						</cfif>
					</cfcase>
				</cfswitch>

			<cfelseif NOT local.getsearch.Air AND Len(Trim(local.getsearch.Arrival_City))>
				<cfset local.searchfilter.setDestination(application.stAirports[local.getsearch.Arrival_City].city)>
			</cfif>

			<!--- Set carHeading. --->
			<cfif structKeyExists(local.getsearch, 'CarPickup_Airport') AND Len(Trim(local.getsearch.CarPickup_Airport))>
				<cfif structKeyExists(local.getsearch, 'CarDropoff_Airport') AND Len(Trim(local.getsearch.CarDropoff_Airport)) AND (local.getsearch.CarDropoff_Airport NEQ local.getsearch.CarPickup_Airport)>
					<cfset local.searchfilter.setCarHeading(getCarPickupAirportData.Airport_Name&' ('&local.getsearch.CarPickup_Airport&') <small>:: '&DateFormat(local.getsearch.CarPickup_DateTime, 'ddd mmm d')&'</small> - ' &local.getCarDropoffAirportData.Airport_Name&' ('&local.getsearch.CarDropoff_Airport&') <small>:: ' &DateFormat(local.getsearch.CarDropoff_DateTime, 'ddd mmm d')&'</small>') />
				<cfelse>
					<cfset local.searchfilter.setCarHeading(getCarPickupAirportData.Airport_Name&' ('&local.getsearch.CarPickup_Airport&') <small>:: '&DateFormat(local.getsearch.CarPickup_DateTime, 'ddd mmm d')&' - '&DateFormat(local.getsearch.CarDropoff_DateTime, 'ddd mmm d')&'</small>') />
				</cfif>
			</cfif>

			<!--- Set searchFilters into the session as session.filters! =================================== --->
			<cfset session.Filters[arguments.SearchID] = searchfilter>
			<!--- ================================================================================================ --->

			<!---Set session variables--->
			<cfset session.UserID = local.getSearch.User_ID>
			<cfset session.AcctID = local.getSearch.Acct_ID>
			<cfset session.policyID = local.getSearch.Policy_ID>
			<cfset session.DepartmentPreferences = getUserService().getUserDepartment( session.UserID, session.AcctID ) />

			<!--- If coming from any of the change search forms, don't wipe out other (air, hotel, or car) data --->
			<cfif NOT arguments.requery
				OR NOT structKeyExists(session.searches, arguments.searchID)
				OR NOT structKeyExists(session.searches[arguments.SearchID], "stAvailDetails")>
				<!--- Otherwise, default the search session struct --->
				<cfset session.searches[arguments.SearchID].stItinerary = {}>
				<cfset session.searches[arguments.SearchID].stAvailTrips[0] = {}>
				<cfset session.searches[arguments.SearchID].stAvailTrips[1] = {}>
				<cfset session.searches[arguments.SearchID].stAvailTrips[2] = {}>
				<cfset session.searches[arguments.SearchID].stAvailTrips[3] = {}>
				<cfset session.searches[arguments.SearchID].stAvailDetails = {}>
				<cfset session.searches[arguments.SearchID].stAvailDetails.stGroups = {}>
				<cfset session.searches[arguments.SearchID].stTrips = {}>
				<cfset session.searches[arguments.SearchID].stLowFareDetails.stPricing = {}>
				<cfset session.searches[arguments.SearchID].stLowFareDetails.stPriced = {}>
				<cfset session.searches[arguments.SearchID].stLowFareDetails.aCarriers = {}>
				<cfset session.searches[arguments.SearchID].stLowFareDetails.stResults = {}>
				<cfset session.searches[arguments.SearchID].stSelected = StructNew("linked")>
				<cfset session.searches[arguments.SearchID].stSelected[0] = {}>
				<cfset session.searches[arguments.SearchID].stSelected[1] = {}>
				<cfset session.searches[arguments.SearchID].stSelected[2] = {}>
				<cfset session.searches[arguments.SearchID].stSelected[3] = {}>
			</cfif>
			<cfset session.searches[arguments.SearchID].couldYou = {}>
		<cfelse>
			<cfset local.searchfilter = getSearchService().new() />
		</cfif>

		<cfreturn local.searchfilter/>
	</cffunction>

	<cffunction name="setAccount" output="false">
		<cfargument name="AcctID">

		<cfset local.stTemp = {}>
		<cfif arguments.AcctID NEQ 0>
			<!--- <cfif ListFindNoCase('qa,beta,prod,local', getCurrentEnvironment())> --->
				<cfset local.Branches = {
					"1P6O" = "P1601409",
					"1N47" = "P1601410",
					"1CO2" = "P1601412",
					"1WO0" = "P1601408",
					"1N32" = "P1601407",
					"17D8" = "P1601485",
					"1WN9" = "P1601411",
					"1N52" = "P1601402",
					"1N63" = "P1601403",
					"1H7M" = "P1601400",
					"1M98" = "P1601405",
					"1N51" = "P1601404",
					"149I" = "P1601401",
					"2N0D" = "P1601413",
					"1H7N" = "P1601399",
					"2B2C" = "P1601396",
					"176T" = "P1601397",
					"1AM2" = "P1601398",
					"2B7B" = "P1642776",
					"155O" = "P1647862",
					"2F6K" = "P1936040",
					"2F9E" = "P2300146",
					"2C9N" = "P1951364",
					"2G1P" = "P2666166",
					"2G68" = "P2721003",
					"2G9P" = "P2768970",
					"2G1A" = "P2596168",
					"2GD0" = "P2812614",
					"2H1B" = "P2860532",
					"2H9U" = "P3161929",
					"2I3I" = "P3156934"
				}>


			<cfquery name="local.qAccount" datasource="#getBookingDSN()#">
				SELECT Acct_ID
				, Account_Name
				, Delivery_AON
				, (SELECT Account_Logo
						FROM Corporate_Production.dbo.Accounts
						WHERE Acct_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.AcctID#" />) AS Logo
				<!--- , Logo --->
				, PCC_Booking
				, PNR_AddAccount
				, BTA_Move
				, Gov_Rates
				, PrePaid_Rates
				, Air_PTC
				, Air_PF
				, Hotel_RateCodes
				, Account_Policies
				, Account_Approval
				, Account_AllowRequests
				, RMUs
				, RMU_Agent
				, RMU_NonAgent
				, CBA_AllDepts
				, Error_Contact
				, Error_Email
				, ConfirmationMessage_NotRequired
				, ConfirmationMessage_Required
				, QueueToCompleat
				, CompleatUse
				, searchModeDefault
				, carInPolicyDefault
				, (SELECT SecurityCode
						FROM Corporate_Production.dbo.Accounts
						WHERE Acct_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.AcctID#" />) AS SecurityCode
				, (SELECT Air_Card
						FROM Corporate_Production.dbo.Accounts
						WHERE Acct_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.AcctID#" />) AS Air_Card
				,	(SELECT Hotel_Card
						FROM Corporate_Production.dbo.Accounts
						WHERE Acct_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.AcctID#" />) AS Hotel_Card
				FROM Accounts
				WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfloop list="#qAccount.ColumnList#" index="local.sCol">
				<cfset local.stTemp[local.sCol] = local.qAccount[local.sCol]>
			</cfloop>

			<cfquery name="local.extendedInfo" datasource="#getCorporateProductionDSN()#">
				SELECT CouldYou,Account_Brand
				FROM Accounts
				WHERE Accounts.Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
					AND Accounts.Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfset local.stTemp.CouldYou = local.extendedInfo.CouldYou>
			<cfset local.stTemp.AccountBrand = local.extendedInfo.Account_Brand>
			<cfset local.stTemp.sBranch = local.Branches[local.qAccount.PCC_Booking]>
			<cfset local.stTemp.Air_PF = ListToArray(local.stTemp.Air_PF, '~')>

			<cfquery name="local.qOutOfPolicy" datasource="#getCorporateProductionDSN()#">
				SELECT Vendor_ID, Type
				FROM OutofPolicy_Vendors
				WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfset local.stTemp.aNonPolicyAir = []>
			<cfset local.stTemp.aNonPolicyCar = []>
			<cfset local.stTemp.aNonPolicyHotel = []>

			<cfloop query="local.qOutOfPolicy">
				<cfset local.sType = 'aNonPolicy'&(local.qOutOfPolicy.Type EQ 'A' ? 'Air' : (local.qOutOfPolicy.Type EQ 'C' ? 'Car' : 'Hotel'))>
				<cfset ArrayAppend(local.stTemp[local.sType], local.qOutOfPolicy.Vendor_ID)>
			</cfloop>

			<cfquery name="local.qLogo" datasource="#getCorporateProductionDSN()#">
				SELECT account_logo
				FROM accounts
				WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<!--- get logo from corporate_production accounts table --->
			<cfset local.stTemp.account_logo = local.qLogo.account_logo>

			<cfquery name="local.qPreferred" datasource="#getCorporateProductionDSN()#">
				SELECT Acct_ID, Vendor_ID, Type
				FROM Preferred_Vendors
				WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfset local.stTemp.aPreferredAir = []>
			<cfset local.stTemp.aPreferredCar = []>
			<cfset local.stTemp.aPreferredHotel = []>

			<cfloop query="qPreferred">
				<cfset local.sType = 'aPreferred'&(local.qPreferred.Type EQ 'A' ? 'Air' : (local.qPreferred.Type EQ 'C' ? 'Car' : 'Hotel'))>
				<cfset ArrayAppend(local.stTemp[local.sType], local.qPreferred.Vendor_ID)>
			</cfloop>

			<cfquery name="local.qPreferredHotelProperties" datasource="#getCorporateProductionDSN()#">
				SELECT Acct_ID, Property_ID
				FROM Accounts_PropertyIDs
				WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfset local.stTemp.aPreferredHotelProperties = []>

			<cfloop query="qPreferredHotelProperties">
				<cfset local.sType = 'aPreferredHotelProperties'>
				<cfset ArrayAppend(local.stTemp[local.sType], local.qPreferredHotelProperties.Property_ID)>
			</cfloop>

			<cfquery name="local.qAirITNumbers" datasource="#getCorporateProductionDSN()#">
				SELECT Carrier, IT_Number
				FROM Airline_ITNumbers
				WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfset local.stTemp.AirITNumbers = arrayNew(1) />

			<cfif qAirITNumbers.recordCount >
				<cfloop query="local.qAirITNumbers">
					<cfset local.airITNumber = structNew() />
					<cfset local.airITNumber.carrier = local.qAirITNumbers.Carrier />
					<cfset local.airITNumber.ITNumber = local.qAirITNumbers.IT_Number />
					<cfset arrayAppend( local.stTemp.AirITNumbers, duplicate( local.airITNumber ) ) />
				</cfloop>
			</cfif>

			<cfquery name="local.locations" datasource="#getCorporateProductionDSN()#" cachedwithin="#createTimeSpan( 0, 12, 0, 0)#">
				SELECT Office_ID, Office_Name
				FROM Account_Offices
				WHERE Acct_ID = <cfqueryparam value="#arguments.acctId#" cfsqltype="cf_sql_integer">
				AND Status = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
				ORDER BY Office_Name
			</cfquery>

			<cfset local.stTemp.Offices = arrayNew(1) />

			<cfif locations.recordCount >

				<cfloop query="local.locations">
					<cfset local.location = structNew() />
					<cfset local.location.name = local.locations.Office_Name />
					<cfset local.location.id = local.locations.Office_ID />
					<cfset arrayAppend( local.stTemp.Offices, duplicate( local.location ) ) />
				</cfloop>
			</cfif>
			<cfset local.stTemp.loadTime = now() />
			<cfset application.Accounts[arguments.AcctID] = local.stTemp>
		</cfif>

		<cfreturn local.stTemp/>
	</cffunction>

	<cffunction name="setPolicy" output="false">
		<cfargument name="policyID">

		<cfset local.stTemp = {}>
		<cfif arguments.policyID NEQ 0>
			<!---Lazy loading, adds policies to the application scope as needed.--->
			<cfset local.qPolicy = PolicyService.loadQuery(arguments.policyID)>
			<cfset local.stTemp = {}>
			<cfloop list="#qPolicy.ColumnList#" index="local.sCol">
				<cfset local.stTemp[local.sCol] = local.qPolicy[local.sCol]>
			</cfloop>

			<!---Get Preferred Car Sizes--->
			<cfset local.qPreferredCarSizes = PolicyService.getCarPreferredCarSizes(arguments.policyID)>
			<cfset local.stTemp.aCarSizes = []>
			<cfloop query="qPreferredCarSizes">
				<cfset ArrayAppend(local.stTemp.aCarSizes, local.qPreferredCarSizes.Car_Size)>
			</cfloop>

			<!--- Get Car Payments --->
			<cfset local.qCDNumbers = PaymentService.getCarPayments(acctID=local.qPolicy.Acct_ID,returnType='query',userID=0,vendor='')>
			<cfset local.stTemp.CDNumbers = {}>
			<cfloop query="qCDNumbers">
				<cfset local.stTemp.CDNumbers[local.qCDNumbers.Value_ID][local.qCDNumbers.Vendor_Code].CD = local.qCDNumbers.CD_Number>
				<cfset local.stTemp.CDNumbers[local.qCDNumbers.Value_ID][local.qCDNumbers.Vendor_Code].DB = local.qCDNumbers.DB_Number>
				<cfset local.stTemp.CDNumbers[local.qCDNumbers.Value_ID][local.qCDNumbers.Vendor_Code].DBType = local.qCDNumbers.DB_Type>
			</cfloop>



			<cfset application.Policies[arguments.policyID] = local.stTemp>
		</cfif>

		<cfreturn local.stTemp/>
	</cffunction>

	<cffunction name="setAirVendors" output="false" returntype="void">

		<cfquery name="local.qAirVendors" datasource="#getBookingDSN()#">
			SELECT VendorCode, ShortName
			FROM RAIR
			WHERE VendorCode NOT LIKE '%/%'
		</cfquery>

		<cfset local.stTemp = {}>

		<cfloop query="local.qAirVendors">
			<cfset local.stTemp[local.qAirVendors.VendorCode].Name = local.qAirVendors.ShortName>
			<cfset local.stTemp[local.qAirVendors.VendorCode].Bag1 = 0>
			<cfset local.stTemp[local.qAirVendors.VendorCode].Bag2 = 0>
		</cfloop>

		<cfquery name="local.qBagFees" datasource="Corporate_Production">
			SELECT ShortCode, OnlineDomBag1, OnlineDomBag2
			FROM OnlineCheckIn_Links, Suppliers
			WHERE OnlineCheckIn_Links.AccountID = Suppliers.AccountID
				AND (OnlineDomBag1 IS NOT NULL AND OnlineDomBag1 <> 0)
				AND	(OnlineDomBag2 IS NOT NULL AND OnlineDomBag2 <> 0)
		</cfquery>

		<cfloop query="local.qBagFees">
			<cfset local.stTemp[local.qBagFees.ShortCode].Bag1 = local.qBagFees.OnlineDomBag1>
			<cfset local.stTemp[local.qBagFees.ShortCode].Bag2 = local.qBagFees.OnlineDomBag2>
		</cfloop>

		<cfset application.stAirVendors = local.stTemp>

		<cfreturn />
	</cffunction>

	<cffunction name="setCarVendors" output="false" returntype="void">

		<cfquery name="local.qCarVendors" datasource="#getBookingDSN()#">
		SELECT VendorCode, VendorName
		FROM RCAR
		GROUP BY VendorCode, VendorName
		</cfquery>

		<cfset local.stTemp = {}>

		<cfloop query="local.qCarVendors">
			<cfset local.stTemp[local.qCarVendors.VendorCode] = local.qCarVendors.VendorName>
		</cfloop>

		<cfset application.stCarVendors = local.stTemp>

		<cfreturn />
	</cffunction>

	<cffunction name="setHotelVendors" output="false" returntype="void">

		<cfquery name="local.qHotelChains" datasource="#getBookingDSN()#">
		SELECT VendorCode, VendorName
		FROM rhtl
		GROUP BY VendorCode, VendorName
		ORDER BY VendorCode, VendorName
		</cfquery>
		<cfset local.stTemp = {} />
		<cfloop query="local.qHotelChains">
			<cfset local.stTemp[local.qHotelChains.VendorCode] = local.qHotelChains.VendorName>
		</cfloop>

		<cfset application.stHotelVendors = local.stTemp>

		<cfreturn />
	</cffunction>

	<cffunction name="setEquipment" output="false" returntype="void">

		<cfquery name="local.qEquipment" datasource="#getBookingDSN()#">
		SELECT EquipmentCode, ShortName
		FROM RAEQ
		</cfquery>
		<cfset local.stTemp = {}>
		<cfloop query="local.qEquipment">
			<cfset local.stTemp[EquipmentCode] = local.qEquipment.ShortName>
		</cfloop>

		<cfset application.stEquipment = local.stTemp>

		<cfreturn />
	</cffunction>

	<cffunction name="setAirports" output="false" returntype="void">

		<cfquery name="local.qAirports" datasource="#getBookingDSN()#">
			SELECT Location_Code AS code
				, Location_Name AS city
				, Airport_Name AS airport
				, country_code as countryCode
				, region_code as stateCode
			FROM lu_Geography
			WHERE Location_Type = 125
				AND Location_Code NOT IN (	SELECT AirportCode
											FROM RAPT
											WHERE AirportType IN (4,5,6,7,8,9) )
											<!---	4 = Heliport, no club, scheduled service,
													5 = Bus station,
													6 = Train station,
													7 = Unknown - not explained in Travelports documentation
													8 = Heliport, not scheduled,
													9 = Secondary, not scheduled
											--->
			ORDER BY code
		</cfquery>

		<cfset local.stTemp = {}>
		<cfset local.domesticList = "US,VI,CA,MX,PR">

		<cfloop query="local.qAirports">
			<cfset local.domestic = "false">
			<cfif listFindNoCase(local.domesticList, local.qAirports.countryCode)>
				<cfset local.domestic = "true">
			</cfif>
			<cfset local.stTemp[local.qAirports.code].city = local.qAirports.city>
			<cfset local.stTemp[local.qAirports.code].airport = local.qAirports.airport>
			<cfset local.stTemp[local.qAirports.code].domestic = local.domestic>
			<cfset local.stTemp[local.qAirports.code].stateCode = local.qAirports.stateCode>
			<cfset local.stTemp[local.qAirports.code].countryCode = local.qAirports.countryCode>
		</cfloop>

		<cfset application.stAirports = local.stTemp>

		<cfreturn />
	</cffunction>

	<cffunction name="setKTPrograms" output="false" returntype="void">

		<cfquery name="local.qKTPrograms" datasource="#getCorporateProductionDSN()#" cachedwithin="#createTimespan(1,0,0,0)#">
			SELECT ProgramID, ProgramName, ProgramLink
			FROM KT_Programs
			ORDER BY ProgramID
		</cfquery>

		<cfset local.stTemp = {} />

		<cfloop query="local.qKTPrograms">
			<cfset local.stTemp[local.qKTPrograms.ProgramID].programName = local.qKTPrograms.ProgramName />
			<cfset local.stTemp[local.qKTPrograms.ProgramID].programLink = local.qKTPrograms.ProgramLink />
			<cfset local.stTemp[local.qKTPrograms.ProgramID].airports = "" />
			<cfset local.stTemp[local.qKTPrograms.ProgramID].airlines = "" />

			<cfquery name="local.qKTAirports" datasource="#getCorporateProductionDSN()#" cachedwithin="#createTimespan(1,0,0,0)#">
				SELECT AirportCode
				FROM KT_Airports
				WHERE ProgramID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qKTPrograms.ProgramID#" />
				ORDER BY AirportCode
			</cfquery>

			<cfif qKTAirports.recordCount>
				<cfset local.stTemp[local.qKTPrograms.ProgramID].airports = valueList(qKTAirports.AirportCode) />
			</cfif>

			<cfquery name="local.qKTAirlines" datasource="#getCorporateProductionDSN()#" cachedwithin="#createTimespan(1,0,0,0)#">
				SELECT CarrierCode
				FROM KT_Airlines
				WHERE ProgramID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qKTPrograms.ProgramID#" />
				ORDER BY CarrierCode
			</cfquery>

			<cfif qKTAirlines.recordCount>
				<cfset local.stTemp[local.qKTPrograms.ProgramID].airlines = valueList(qKTAirlines.CarrierCode) />
			</cfif>
		</cfloop>

		<cfset application.stKTPrograms = local.stTemp />

		<cfreturn />
	</cffunction>

	<cffunction name="setCityCodes" output="false" returntype="void">

		<cfquery name="local.qCityCodes" datasource="#getBookingDSN()#">
			SELECT Location_Code
			FROM lu_Geography
			WHERE City_Code = <cfqueryparam value="1" cfsqltype="cf_sql_bit" />
			ORDER BY Location_Code
		</cfquery>

		<cfset application.sCityCodes = valueList(qCityCodes.Location_Code) />

		<cfreturn />
	</cffunction>

	<cffunction name="setAmenities" output="false" returntype="void">

		<cfquery name="local.qAmenities" datasource="#getBookingDSN()#">
		SELECT code, Amenity
		FROM RAMENITIES
		</cfquery>

		<cfset local.stTemp = {}>

		<cfloop query="qAmenities">
			<cfset local.stTemp[local.qAmenities.code] = local.qAmenities.Amenity>
		</cfloop>

		<cfset application.stAmenities = local.stTemp>

		<cfreturn />

	</cffunction>

	<cffunction name="setStates" output="false" returntype="void">
		<cfquery name="local.qStates" datasource="#getBookingDSN()#">
			SELECT code, State
			FROM RSTATES
		</cfquery>

		<cfset local.stTemp = {}>

		<cfloop query="local.qStates">
			<cfset local.stTemp[local.qStates.code] = local.qStates.State>
		</cfloop>

		<cfset application.stStates = local.stTemp>

		<cfreturn />
	</cffunction>

	<cffunction name="setBlackListedCarrierPairing" output="false" hint="I query the lu_CarrierInterline table and return a list of blacklisted carriers. These carriers cannot be booked together on the same ticket.">

		<!--- THis list occasionally changes so we are caching it here and not putting it into the application scope --->
		<cfquery name="local.blackListedCarrierPairing" datasource="#getBookingDSN()#" cachedwithin="#createTimeSpan(0,12,0,0)#">
			SELECT Carrier1
			, Carrier2
			FROM lu_CarrierInterline
			UNION
			SELECT Carrier2 AS Carrier1
			, Carrier1 AS Carrier2
			FROM lu_CarrierInterline
		</cfquery>

		<!--- Populate the array row by row --->
		<cfloop query="local.blackListedCarrierPairing">
			<cfset local.temp[local.blackListedCarrierPairing.CurrentRow][1]=local.blackListedCarrierPairing.carrier1>
			<cfset local.temp[local.blackListedCarrierPairing.CurrentRow][2]=local.blackListedCarrierPairing.carrier2>
		</cfloop>

		<cfset application.blacklistedCarrierPairing = local.temp>

		<cfreturn />
	</cffunction>

	<cffunction name="setBlackListedCarrier" output="false">

		<cfquery name="local.blackListedCarrierPairing" datasource="#getBookingDSN()#" cachedwithin="#createTimeSpan(0,12,0,0)#">
			SELECT Carrier1
				, Carrier2
			FROM lu_CarrierInterline
			UNION
			SELECT Carrier2 AS Carrier1
				, Carrier1 AS Carrier2
			FROM lu_CarrierInterline
			ORDER BY Carrier1
		</cfquery>

		<cfset local.temp = {}>
		<cfoutput query="local.blackListedCarrierPairing" group="carrier1">
			<cfoutput>
				<cfset local.temp[local.blackListedCarrierPairing.carrier1][local.blackListedCarrierPairing.carrier2] = ''>
			</cfoutput>
		</cfoutput>

		<cfset application.blacklistedCarriers = local.temp>

		<cfreturn />
	</cffunction>

	<cffunction name="authorizeRequest" output="false">
		<cfif NOT findNoCase( ".cfc", cgi.script_name )>
			<cfif NOT structKeyExists( session, "isAuthorized" ) OR session.isAuthorized NEQ TRUE>

				<cfset session.isAuthorized = false />

				<cfif structKeyExists( request.context, "userId" ) AND structKeyExists( request.context, "acctId" ) AND structKeyExists( request.context, "date" ) AND structKeyExists( request.context, "token" )>
					<cfset session.isAuthorized = application.fw.factory.getBean( "AuthorizationService" ).checkCredentials( request.context.userId, request.context.acctId, request.context.date, request.context.token )>

					<cfif session.isAuthorized>
						<cfcookie domain="#cgi.http_host#" secure="yes" name="userId" value="#request.context.userId#" />
						<cfcookie domain="#cgi.http_host#" secure="yes" name="acctId" value="#request.context.acctId#" />
						<cfcookie domain="#cgi.http_host#" secure="yes" name="date" value="#request.context.date#" />
						<cfcookie domain="#cgi.http_host#" secure="yes" name="token" value="#request.context.token#" />

						<cfset var apiURL = application.fw.factory.getBean('EnvironmentService').getShortsAPIURL() />
						<cfset apiURL = replace( replace( apiURL, "http://", "" ), "https://", "") />

						<cfif apiURL NEQ cgi.http_host>
							<cfcookie domain="#apiURL#" secure="yes" name="userId" value="#request.context.userId#" />
							<cfcookie domain="#apiURL#" secure="yes" name="acctId" value="#request.context.acctId#" />
							<cfcookie domain="#apiURL#" secure="yes" name="date" value="#request.context.date#" />
							<cfcookie domain="#apiURL#" secure="yes" name="token" value="#request.context.token#" />
						</cfif>
						<cfset session.cookieDate = request.context.date />
						<cfset session.cookieToken = request.context.token />
					</cfif>

				</cfif>
			<cfelse>
				<cfset var apiURL = application.fw.factory.getBean('EnvironmentService').getShortsAPIURL() />
				<cfset apiURL = replace( replace( apiURL, "http://", "" ), "https://", "") />
				<cfif structKeyExists(request.context, 'date')>
					<cfset session.cookieDate = request.context.date>
					<cfcookie domain="#cgi.http_host#" secure="yes" name="date" value="#request.context.date#" />
					<cfif apiURL NEQ cgi.http_host>
						<cfcookie domain="#apiURL#" secure="yes" name="date" value="#request.context.date#" />
					</cfif>
				</cfif>
				<cfif structKeyExists(request.context, 'token')>
					<cfset session.cookieToken = request.context.token>
					<cfcookie domain="#cgi.http_host#" secure="yes" name="token" value="#request.context.token#" />
					<cfif apiURL NEQ cgi.http_host>
						<cfcookie domain="#apiURL#" secure="yes" name="token" value="#request.context.token#" />
					</cfif>
				</cfif>
			</cfif>

			<cfif NOT session.isAuthorized>
				<cfif structKeyExists(cookie,"loginOrigin") AND cookie.loginOrigin EQ "STO">
					<cfif structKeyExists(cookie,"acctId") AND cookie.acctId EQ 532>
						<cflocation url="#application.fw.factory.getBean('EnvironmentService').getSTOURL()#/?action=dycom.login" addtoken="false">
					<cfelse>
						<cflocation url="#application.fw.factory.getBean('EnvironmentService').getSTOURL()#/?action=main.login" addtoken="false">
					</cfif>
				<cfelse>
					<cflocation url="#application.fw.factory.getBean('EnvironmentService').getPortalURL()#" addtoken="false">
				</cfif>
			</cfif>

		</cfif>
	</cffunction>
</cfcomponent>
