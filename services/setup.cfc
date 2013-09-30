<cfcomponent output="false" accessors="true">

	<cfproperty name="AssetURL"/>
	<cfproperty name="bookDSN"/>
	<cfproperty name="bookingDSN"/>
	<cfproperty name="corporateProductionDSN"/>
	<cfproperty name="portalURL"/>
	<cfproperty name="searchService" />
	<cfproperty name="useLinkedDatabases" />
	<cfproperty name="currentEnvironment" />

	<cffunction name="init" output="false">
		<cfargument name="AssetURL" type="string" requred="true" />
		<cfargument name="bookDSN" type="string" requred="true" />
		<cfargument name="bookingDSN" type="string" requred="true" />
		<cfargument name="corporateProductionDSN" type="string" requred="true" />
		<cfargument name="portalURL" type="string" requred="true" />
		<cfargument name="searchService" />
		<cfargument name="useLinkedDatabases" type="boolean" requred="true" />
		<cfargument name="currentEnvironment" type="string" requred="true" />

		<cfset setAssetURL( arguments.AssetURL ) />
		<cfset setBookDSN( arguments.bookDSN ) />
		<cfset setBookingDSN( arguments.bookingDSN ) />
		<cfset setCorporateProductionDSN( arguments.CorporateProductionDSN ) />
		<cfset setPortalURL( arguments.portalURL ) />
		<cfset setSearchService( arguments.SearchService ) />
		<cfset setUseLinkedDatabases( arguments.useLinkedDatabases ) />
		<cfset setCurrentEnvironment( arguments.currentEnvironment ) />

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

	<cffunction name="setAPIAuth" output="false" returntype="void">
		<cfset application.sAPIAuth = ToBase64('Universal API/UAPI6148916507-02cbc4d4:Qq7?b6*X5B')>
		<cfreturn />
	</cffunction>

	<cffunction name="setFilter" output="false">
		<cfargument name="SearchID" required="true">
		<cfargument name="Append" 	required="false" default="0">
		<cfargument name="requery" required="false" default="false">

		<!---
			TODO: The manual query below is redundant and should be removed and this method refactored to use the local.searchFilter object
			Further, the local.searchFilter object should be renamed to just local.Search
		--->
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


			<cfif getsearch.Air>
				<cfswitch expression="#getsearch.Air_Type#">
					<!---
					airHeading - page header
					heading - used in breadcrumb
					multi-city uses legHeader array - see below
					--->

					<!--- Round trip tab --->
					<cfcase value="RT">
						<cfif DateFormat(getsearch.Depart_DateTime) NEQ DateFormat(getsearch.Arrival_DateTime)>
							<cfset searchfilter.setAirHeading("#application.stAirports[getsearch.Depart_City].city# (#getsearch.Depart_City#) to #application.stAirports[getsearch.Arrival_City].city# (#getsearch.Arrival_City#) :: #DateFormat(getsearch.Depart_DateTime, 'ddd mmm d')# - #DateFormat(getsearch.Arrival_DateTime, 'ddd mmm d')#")>
							<cfset searchfilter.setHeading("#getsearch.Depart_City# to #getsearch.Arrival_City# :: #DateFormat(getsearch.Depart_DateTime, 'm/d')# - #DateFormat(getsearch.Arrival_DateTime, 'm/d')#")>
						<cfelse>
							<cfset searchfilter.setAirHeading("#application.stAirports[getsearch.Depart_City].city# (#getsearch.Depart_City#) to #application.stAirports[getsearch.Arrival_City].city# (#getsearch.Arrival_City#) :: #DateFormat(getsearch.Depart_DateTime, 'ddd mmm d')#")>
							<cfset searchfilter.setHeading("#getsearch.Depart_City# to #getsearch.Arrival_City# :: #DateFormat(getsearch.Depart_DateTime, 'm/d')#")>
						</cfif>
						<cfset searchfilter.addLeg(getsearch.Depart_City&' - '&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d'))>
						<cfset searchfilter.addLeg(getsearch.Arrival_City&' - '&getsearch.Depart_City&' on '&DateFormat(getsearch.Arrival_DateTime, 'ddd, m/d'))>
					</cfcase>

					<!--- One way --->
					<cfcase value="OW">
						<cfset searchfilter.setAirHeading("#application.stAirports[getsearch.Depart_City].city# (#getsearch.Depart_City#) to #application.stAirports[getsearch.Arrival_City].city# (#getsearch.Arrival_City#) :: #DateFormat(getsearch.Depart_DateTime, 'ddd mmm d')#")>
						<cfset searchfilter.setHeading("#getsearch.Depart_City# to #getsearch.Arrival_City# :: #DateFormat(getsearch.Depart_DateTime, 'm/d')#")>
						<cfset searchfilter.addLeg(getsearch.Depart_City&' - '&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d'))>
					</cfcase>

					<!--- Multi-city --->
					<!--- TODO: this logic for making breadcrumbs / title could be broken out into it's own function --->
					<cfcase value="MD" >
						<cfset var local.breadCrumb = "">

						<!--- FYI legs are also added in com/shortstravel/search/searchManager.load() --->

						<cfloop query="getsearchlegs">
							<cfif Len(local.breadCrumb)>
								<cfif ListLast(local.breadCrumb, '-') NEQ depart_city AND  depart_city NEQ arrival_city>
									<cfset local.breadCrumb = "#local.breadCrumb#-#depart_city#-#arrival_city#">
								<cfelse>
									<cfset  local.breadCrumb = "#local.breadCrumb#-#arrival_city#">
								</cfif>
							<cfelse>
								<cfset local.breadCrumb = "#depart_city#-#arrival_city#">
							</cfif>
							<cfset searchfilter.addLeg(getSearchLegs.Depart_City&' - '&getSearchLegs.Arrival_City&' on '&DateFormat(getSearchLegs.Depart_DateTime, 'ddd, m/d'))>
							<cfset searchfilter.addLegHeader("#application.stAirports[getSearchLegs.Depart_City].city# (#getSearchLegs.Depart_City#) to #application.stAirports[getSearchLegs.Arrival_City].city# (#getSearchLegs.Arrival_City#) :: #DateFormat(getSearchLegs.Depart_DateTime, 'ddd mmm d')#")>
						</cfloop>
						<!--- populate headings for display --->
						<cfset searchfilter.setAirHeading("Multi-city Destinations")>
						<cfset searchfilter.setHeading("#local.breadCrumb# :: #DateFormat(getSearchLegs.Depart_DateTime[1], 'm/d')#-#DateFormat(getSearchLegs.Depart_DateTime[getSearchLegs.recordCount], 'm/d')#")>
					</cfcase>
				</cfswitch>

			<cfelseif NOT getsearch.Air AND Len(Trim(getsearch.Arrival_City))>
				<cfset searchfilter.setDestination(application.stAirports[getsearch.Arrival_City].city)>
			</cfif>

			<!--- Set carHeading. --->
			<cfif structKeyExists(getsearch, 'CarPickup_Airport') AND Len(Trim(getsearch.CarPickup_Airport))>
				<cfif structKeyExists(getsearch, 'CarDropoff_Airport') AND Len(Trim(getsearch.CarDropoff_Airport)) AND (getsearch.CarDropoff_Airport NEQ getsearch.CarPickup_Airport)>
					<cfset searchfilter.setCarHeading(getCarPickupAirportData.Airport_Name&' ('&getsearch.CarPickup_Airport&') <small>:: '&DateFormat(getsearch.CarPickup_DateTime, 'ddd mmm d')&'</small> - ' &getCarDropoffAirportData.Airport_Name&' ('&getsearch.CarDropoff_Airport&') <small>:: ' &DateFormat(getsearch.CarDropoff_DateTime, 'ddd mmm d')&'</small>') />
				<cfelse>
					<cfset searchfilter.setCarHeading(getCarPickupAirportData.Airport_Name&' ('&getsearch.CarPickup_Airport&') <small>:: '&DateFormat(getsearch.CarPickup_DateTime, 'ddd mmm d')&' - '&DateFormat(getsearch.CarDropoff_DateTime, 'ddd mmm d')&'</small>') />
				</cfif>
			</cfif>

			<!--- Set searchFilters into the session as session.filters! =================================== --->
			<cfset session.Filters[arguments.SearchID] = searchfilter>
			<!--- ================================================================================================ --->

			<!---Set session variables--->
			<cfset session.UserID = getSearch.User_ID>
			<cfset session.AcctID = getSearch.Acct_ID>
			<cfset session.PolicyID = getSearch.Policy_ID>
			<!--- If coming from any of the change search forms, don't wipe out other (air, hotel, or car) data --->
			<cfif NOT arguments.requery OR NOT structKeyExists(session.searches[arguments.SearchID], "stAvailDetails")>
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

		<cfreturn searchfilter/>
	</cffunction>

	<cffunction name="setAccount" output="false">
		<cfargument name="AcctID">

		<cfset local.stTemp = {}>
		<cfif arguments.AcctID NEQ 0>
			<cfif ListFindNoCase('qa,beta,prod', getCurrentEnvironment())>
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
					"1AM2" = "P1601398"
				}>
			<cfelse>
				<cfset local.Branches = {
					"149I" = "P7003154",
					"176T" = "P7003151",
					"17D8" = "P7003159",
					"1AM2" = "P7003153",
					"1CO2" = "P7003175",
					"1H7M" = "P7003150",
					"1H7N" = "P7003185",
					"1M98" = "P7003155",
					"1N32" = "P7003173",
					"1N47" = "P7003172",
					"1N51" = "P7003156",
					"1N52" = "P7003157",
					"1N63" = "P7003158",
					"1P6O" = "P7003160",
					"1WN9" = "P7003174",
					"1WO0" = "P7003182",
					"2B2C" = "P7003152",
					"2N0D" = "P7003176"
				}>
			</cfif>

			<cfquery name="local.qAccount" datasource="book">
				SELECT Acct_ID, Account_Name, Delivery_AON, Logo, PCC_Booking, PNR_AddAccount, BTA_Move, Gov_Rates,
					Air_PTC, Air_PF, Hotel_RateCodes, Account_Policies, Account_Approval, Account_AllowRequests, RMUs,
					RMU_Agent, RMU_NonAgent, CBA_AllDepts, Error_Contact, Error_Email
				FROM Accounts
				WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfquery name="local.qCouldYou" datasource="#getCorporateProductionDSN()#">
				SELECT CouldYou
				FROM Accounts
				WHERE Accounts.Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
					AND Accounts.Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfloop list="#qAccount.ColumnList#" index="local.sCol">
				<cfset stTemp[sCol] = qAccount[sCol]>
			</cfloop>
			<cfset stTemp.CouldYou = qCouldYou.CouldYou>

			<cfset stTemp.sBranch = Branches[qAccount.PCC_Booking]>
			<cfset stTemp.Air_PF = ListToArray(stTemp.Air_PF, '~')>

			<cfquery name="local.qOutOfPolicy" datasource="#getCorporateProductionDSN()#">
				SELECT Vendor_ID, Type
				FROM OutofPolicy_Vendors
				WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfset stTemp.aNonPolicyAir = []>
			<cfset stTemp.aNonPolicyCar = []>
			<cfset stTemp.aNonPolicyHotel = []>

			<cfloop query="qOutOfPolicy">
				<cfset local.sType = 'aNonPolicy'&(qOutOfPolicy.Type EQ 'A' ? 'Air' : (qOutOfPolicy.Type EQ 'C' ? 'Car' : 'Hotel'))>
				<cfset ArrayAppend(stTemp[sType], qOutOfPolicy.Vendor_ID)>
			</cfloop>

			<cfquery name="local.qPreferred" datasource="#getCorporateProductionDSN()#">
				SELECT Acct_ID, Vendor_ID, Type
				FROM Preferred_Vendors
				WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfset stTemp.aPreferredAir = []>
			<cfset stTemp.aPreferredCar = []>
			<cfset stTemp.aPreferredHotel = []>

			<cfloop query="qPreferred">
				<cfset local.sType = 'aPreferred'&(qPreferred.Type EQ 'A' ? 'Air' : (qPreferred.Type EQ 'C' ? 'Car' : 'Hotel'))>
				<cfset ArrayAppend(stTemp[sType], qPreferred.Vendor_ID)>
			</cfloop>

			<cfquery name="local.locations" datasource="#getCorporateProductionDSN()#" cachedwithin="#createTimeSpan( 0, 12, 0, 0)#">
				SELECT Office_ID, Office_Name
				FROM Account_Offices
				WHERE Acct_ID = <cfqueryparam value="#arguments.acctId#" cfsqltype="cf_sql_integer">
				AND Status = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
				ORDER BY Office_Name
			</cfquery>

			<cfset stTemp.Offices = arrayNew(1) />

			<cfif locations.recordCount >

				<cfloop query="locations">
					<cfset local.location = structNew() />
					<cfset location.name = locations.Office_Name />
					<cfset location.id = locations.Office_ID />
					<cfset arrayAppend( stTemp.Offices, duplicate( location ) ) />
				</cfloop>
			</cfif>

			<cfset application.Accounts[arguments.AcctID] = stTemp>
		</cfif>

		<cfreturn stTemp/>
	</cffunction>

	<cffunction name="setPolicy" output="false">
		<cfargument name="PolicyID">

		<cfset local.stTemp = {}>
		<cfif arguments.PolicyID NEQ 0>
			<!---Lazy loading, adds policies to the application scope as needed.--->
			<cfquery name="local.qPolicy" datasource="#getCorporateProductionDSN()#">
			SELECT Policy_ID, Acct_ID, Policy_Include, Policy_Approval, Policy_Window, Policy_AirReasonCode, Policy_AirLostSavings,
			Policy_AirFirstClass, Policy_AirBusinessClass, Policy_AirLowRule, Policy_AirLowDisp, Policy_AirLowPad,
			Policy_AirMaxRule, Policy_AirMaxDisp, Policy_AirMaxTotal, Policy_AirPrefRule, Policy_AirPrefDisp, Policy_AirAdvRule,
			Policy_AirAdvDisp, Policy_AirAdv, Policy_AirRefRule, Policy_AirRefDisp, Policy_AirNonRefRule, Policy_AirNonRefDisp,
			Policy_FindIt, Policy_FindItDays, Policy_FindItDiff, Policy_FindItFee, Policy_CarReasonCode, Policy_CarMaxRule, Policy_CarMaxDisp,
			Policy_CarMaxRate, Policy_CarPrefRule, Policy_CarPrefDisp, Policy_CarTypeRule, Policy_CarTypeDisp, Policy_CarOnlyRates,
			Policy_HotelReasonCode, Policy_HotelMaxRule, Policy_HotelMaxDisp, Policy_HotelMaxRate, Policy_HotelPrefRule, Policy_HotelPrefDisp,
			Policy_HotelNotBooking, Policy_AirFee, Policy_AirIntFee, Policy_NonAirFee, Policy_SpecialRequestFee, Policy_AgentAirFee,
			Policy_AgentAirIntFee, Policy_AgentNonAirFee, Policy_ComplexFee, BookIt_MonthFee, BookIt_TransFee, Policy_AllowRequests,
			Policy_AirApproval, Policy_HotelApproval, Policy_CarApproval
			FROM Account_Policies
			WHERE Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			AND Policy_ID = <cfqueryparam value="#arguments.PolicyID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfset local.stTemp = {}>
			<cfloop list="#qPolicy.ColumnList#" index="local.sCol">
				<cfset stTemp[sCol] = qPolicy[sCol]>
			</cfloop>

			<cfquery name="local.qPreferredCarSizes" datasource="#getCorporateProductionDSN()#">
				SELECT Car_Size
					, Policy_ID
				FROM Policy_CarSizes
				WHERE Policy_ID = <cfqueryparam value="#arguments.PolicyID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfset stTemp.aCarSizes = []>
			<cfloop query="qPreferredCarSizes">
				<cfset ArrayAppend(stTemp.aCarSizes, qPreferredCarSizes.Car_Size)>
			</cfloop>

			<cfquery name="local.qCDNumbers" datasource="#getCorporateProductionDSN()#">
			SELECT IsNull(Value_ID, '0') AS Value_ID, Vendor_Code, CD_Number, DB_Number, DB_Type
			FROM CD_Numbers
			WHERE Acct_ID = <cfqueryparam value="#qPolicy.Acct_ID#" cfsqltype="cf_sql_numeric" />
			</cfquery>
			<cfset stTemp.CDNumbers = {}>
			<cfloop query="qCDNumbers">
				<cfset stTemp.CDNumbers[qCDNumbers.Value_ID][qCDNumbers.Vendor_Code].CD = qCDNumbers.CD_Number>
				<cfset stTemp.CDNumbers[qCDNumbers.Value_ID][qCDNumbers.Vendor_Code].DB = qCDNumbers.DB_Number>
				<cfset stTemp.CDNumbers[qCDNumbers.Value_ID][qCDNumbers.Vendor_Code].DBType = qCDNumbers.DB_Type>
			</cfloop>

			<cfset application.Policies[arguments.PolicyID] = stTemp>
		</cfif>

		<cfreturn stTemp/>
	</cffunction>

	<cffunction name="setAirVendors" output="false" returntype="void">

		<cfquery name="local.qAirVendors" datasource="#getBookingDSN()#">
			SELECT VendorCode, ShortName
			FROM RAIR
			WHERE VendorCode NOT LIKE '%/%'
		</cfquery>

		<cfset local.stTemp = {}>

		<cfloop query="qAirVendors">
			<cfset stTemp[VendorCode].Name = ShortName>
			<cfset stTemp[VendorCode].Bag1 = 0>
			<cfset stTemp[VendorCode].Bag2 = 0>
		</cfloop>

		<cfquery name="local.qBagFees" datasource="Corporate_Production">
			SELECT ShortCode, OnlineDomBag1, OnlineDomBag2
			FROM OnlineCheckIn_Links, Suppliers
			WHERE OnlineCheckIn_Links.AccountID = Suppliers.AccountID
				AND (OnlineDomBag1 IS NOT NULL AND OnlineDomBag1 <> 0)
				AND	(OnlineDomBag2 IS NOT NULL AND OnlineDomBag2 <> 0)
		</cfquery>

		<cfloop query="qBagFees">
			<cfset stTemp[ShortCode].Bag1 = OnlineDomBag1>
			<cfset stTemp[ShortCode].Bag2 = OnlineDomBag2>
		</cfloop>

		<cfset application.stAirVendors = stTemp>

		<cfreturn />
	</cffunction>

	<cffunction name="setCarVendors" output="false" returntype="void">

		<cfquery name="local.qCarVendors" datasource="#getBookingDSN()#">
		SELECT VendorCode, VendorName
		FROM RCAR
		GROUP BY VendorCode, VendorName
		</cfquery>
		<cfset local.stTemp = {}>
		<cfloop query="qCarVendors">
			<cfset stTemp[VendorCode] = VendorName>
		</cfloop>

		<cfset application.stCarVendors = stTemp>

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
		<cfloop query="qHotelChains">
			<cfset stTemp[VendorCode] = qHotelChains.VendorName>
		</cfloop>

		<cfset application.stHotelVendors = stTemp>

		<cfreturn />
	</cffunction>

	<cffunction name="setEquipment" output="false" returntype="void">

		<cfquery name="local.qEquipment" datasource="#getBookingDSN()#">
		SELECT EquipmentCode, ShortName
		FROM RAEQ
		</cfquery>
		<cfset local.stTemp = {}>
		<cfloop query="qEquipment">
			<cfset stTemp[EquipmentCode] = ShortName>
		</cfloop>

		<cfset application.stEquipment = stTemp>

		<cfreturn />
	</cffunction>

	<cffunction name="setAirports" output="false" returntype="void">

		<cfquery name="local.qAirports" datasource="#getBookingDSN()#">
			SELECT Location_Code AS code
				, Location_Name AS city
				, Airport_Name AS airport
			FROM lu_Geography
			WHERE Location_Type = 125
			ORDER BY code
		</cfquery>

		<cfset local.stTemp = {}>

		<cfloop query="qAirports">
			<cfset stTemp[code].city = city>
			<cfset stTemp[code].airport = airport>
		</cfloop>

		<cfset application.stAirports = stTemp>

		<cfreturn />
	</cffunction>

	<cffunction name="setAmenities" output="false" returntype="void">

		<cfquery name="local.qAmenities" datasource="#getBookingDSN()#">
		SELECT code, Amenity
		FROM RAMENITIES
		</cfquery>
		<cfset local.stTemp = {}>
		<cfloop query="qAmenities">
			<cfset stTemp[qAmenities.code] = qAmenities.Amenity>
		</cfloop>
		<cfset application.stAmenities = stTemp>
		<cfreturn />

	</cffunction>

	<cffunction name="setStates" output="false" returntype="void">
		<cfquery name="local.qStates" datasource="#getBookingDSN()#">
			SELECT code, State
			FROM RSTATES
		</cfquery>
		<cfset local.stTemp = {}>
		<cfloop query="qStates">
			<cfset stTemp[qStates.code] = qStates.State>
		</cfloop>
		<cfset application.stStates = stTemp>
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
			<cfset local.temp[CurrentRow][1]=carrier1>
			<cfset local.temp[CurrentRow][2]=carrier2>
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
		<cfoutput query="blackListedCarrierPairing" group="carrier1">
			<cfoutput>
				<cfset temp[carrier1][carrier2] = ''>
			</cfoutput>
		</cfoutput>

		<cfset application.blacklistedCarriers = temp>

		<cfreturn />
	</cffunction>

</cfcomponent>