<cfcomponent output="false">

<!---
setServerURL
--->
	<cffunction name="setServerURL" output="false" returntype="void">
		
		<cfset application.sServerURL = (cgi.https EQ 'on' ? 'https' : 'http')&'://'&cgi.Server_Name&'/booking'>
		
		<cfreturn />
	</cffunction>
	
<!---
setPortalURL
--->
	<cffunction name="setPortalURL" output="false" returntype="void">
		
		<cfset local.sPortalURL = ''>
		<cfset local.bDebug = 0>

		<cfif cgi.SERVER_NAME EQ 'www.shortstravelonline.com'>
			<cfset sPortalURL = 'https://www.shortstravel.com'>
			<cfset bDebug = 0>
		<cfelseif cgi.SERVER_NAME EQ 'www.shortstravel.com'>
			<cfset sPortalURL = 'https://www.shortstravel.com'>
			<cfset bDebug = 0>
		<cfelseif cgi.SERVER_NAME EQ 'www.b-hives.com'>
			<cfset sPortalURL = 'https://www.b-hive.travel'>
			<cfset bDebug = 0>
		<cfelseif cgi.SERVER_NAME EQ 'localhost'>
			<cfset sPortalURL = 'http://localhost'>
			<cfset bDebug = 1>
		<cfelseif cgi.SERVER_NAME EQ 'localhost:8888'>
			<cfset sPortalURL = 'http://localhost:8888'>
			<cfset bDebug = 1>
		<cfelseif cgi.SERVER_NAME EQ 'hermes.shortstravel.com'>
			<cfset sPortalURL = 'https://hermes.shortstravel.com'>
			<cfset bDebug = 0>
		</cfif>
		
		<cfset application.sPortalURL = sPortalURL>
		<cfset application.bDebug = bDebug>
		
		<cfreturn />
	</cffunction>
	
<!---
setAPIAuth - REMOVE LATER
--->
	<cffunction name="setAPIAuth" output="false" returntype="void">
		
		<cfset application.sAPIAuth = ToBase64('Universal API/uAPI6148916507-02cbc4d4:Qq7?b6*X5B')>
		
		<cfreturn />
	</cffunction>

<!---
setSearch
--->
	<cffunction name="setSearch" output="false">
		<cfargument name="SearchID" required="true">
		<cfargument name="Append" 	required="false" default="0" >

		<cfif arguments.SearchID NEQ 0>
			<cfset local.searchfilter = createObject("component", "booking.model.searchfilter").init()>

			<cfquery name="local.getsearch">
			SELECT TOP 1 Acct_ID, Search_ID, Air, Car, Hotel, Policy_ID, Profile_ID, Value_ID, User_ID, Username,
			Air_Type, Depart_City, Depart_DateTime, Arrival_City, Arrival_DateTime, Airlines, International, Depart_TimeType,
			Arrival_TimeType, ClassOfService
			FROM Searches
			WHERE Search_ID = <cfqueryparam value="#arguments.SearchID#" cfsqltype="cf_sql_integer">
			ORDER BY Search_ID DESC
			</cfquery>
			<cfif getsearch.Air_Type EQ 'MD'>
				<cfquery name="local.getsearchlegs">
				SELECT Depart_City, Arrival_City, Depart_DateTime, Depart_TimeType
				FROM Searches_Legs
				WHERE Search_ID = <cfqueryparam value="#arguments.SearchID#" cfsqltype="cf_sql_numeric" />
				</cfquery>
			</cfif>

			<cfset searchfilter.setSearchID(getsearch.Search_ID)>
			<cfset searchfilter.setAir(getsearch.Air EQ 1 ? true : false)>
			<cfset searchfilter.setCar(getsearch.Car EQ 1 ? true : false)>
			<cfset searchfilter.setHotel(getsearch.Hotel EQ 1 ? true : false)>
			<cfset searchfilter.setAirType(getsearch.Air_Type)>
			<cfset searchfilter.setDepartCity(getsearch.Depart_City)>
			<cfset searchfilter.setDepartDate(getsearch.Depart_DateTime)>
			<cfset searchfilter.setDepartType(getsearch.Depart_TimeType)>
			<cfset searchfilter.setArrivalCity(getsearch.Arrival_City)>
			<cfset searchfilter.setArrivalDate(getsearch.Arrival_DateTime)>
			<cfset searchfilter.setArrivalType(getsearch.Arrival_TimeType)>
			<cfset searchfilter.setAirlines(getsearch.Airlines)>
			<cfset searchfilter.setInternational(getsearch.International EQ 1 ? true : false)>
			<cfset searchfilter.setCOS(getsearch.ClassOfService)>
			<cfset searchfilter.setProfileID(getsearch.Profile_ID)>
			<cfset searchfilter.setPolicyID(getsearch.Policy_ID)>
			<cfset searchfilter.setValueID(getsearch.Value_ID)>
			<cfset searchfilter.setUserID(getsearch.User_ID)>
			<cfset searchfilter.setAcctID(getsearch.Acct_ID)>
			<cfset searchfilter.setUsername(getsearch.Username)>

			<cfif getsearch.Profile_ID EQ getsearch.User_ID>
				<cfset searchfilter.setBookingFor('')><!--- Booking for themselves --->
			<cfelseif getsearch.Profile_ID EQ 0>
				<cfset searchfilter.setBookingFor('Guest Traveler')><!--- Guest traveler --->
			<cfelse>
				<cfquery name="local.getuser" datasource="Corporate_Production">
				SELECT First_Name, Last_Name
				FROM Users
				WHERE User_ID = <cfqueryparam value="#getsearch.Profile_ID#" cfsqltype="cf_sql_integer" >
				</cfquery>
				<cfset searchfilter.setBookingFor(getuser.First_Name&' '&getuser.Last_Name)><!--- Booking for someone else --->
			</cfif>

			<!--- Round trip tab --->
			<cfif getsearch.Air AND getsearch.Air_Type EQ 'RT'>
				<cfif DateFormat(getsearch.Depart_DateTime) NEQ DateFormat(getsearch.Arrival_DateTime)>
					<cfset searchfilter.setHeading(getsearch.Depart_City&'-'&getsearch.Arrival_City&' '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')&' to '&DateFormat(getsearch.Arrival_DateTime, 'm/d'))>
					<cfelse>
					<cfset searchfilter.setHeading(getsearch.Depart_City&'-'&getsearch.Arrival_City&' '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d'))>
				</cfif>
				<cfset searchfilter.setDestination(application.stAirports[getsearch.Arrival_City])>
				<cfset searchfilter.addLeg(getsearch.Depart_City&' - '&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d'))>
				<cfset searchfilter.addLeg(getsearch.Arrival_City&' - '&getsearch.Depart_City&' on '&DateFormat(getsearch.Arrival_DateTime, 'ddd, m/d'))>
			<!--- One way trip tab --->
			<cfelseif getsearch.Air AND getsearch.Air_Type EQ 'OW'>
				<cfset searchfilter.setHeading(getsearch.Depart_City&'-'&getsearch.Arrival_City&' '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d'))>
				<cfset searchfilter.setDestination(application.stAirports[getsearch.Arrival_City])>
				<cfset searchfilter.addLeg(getsearch.Depart_City&' - '&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d'))>
			<!--- Multi destination trip tab --->
			<cfelseif getsearch.Air AND getsearch.Air_Type EQ 'MD'>
				<!---<cfset searchfilter.setDestination('')>
				<cfset searchfilter.setHeading(getsearch.Depart_City&'-'&getsearch.Arrival_City&' '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d'))>
				<cfset tab.Heading = getsearch.Depart_City&'-'&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')&' '>--->
				<!---<cfset tab.Legs[0] = getsearch.Depart_City&' to '&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')>
				<cfloop query="getsearchlegs">
					<cfset tab.Heading = tab.Heading&getsearchlegs.Depart_City&'-'&getsearchlegs.Arrival_City&' on '&DateFormat(getsearchlegs.Depart_DateTime, 'ddd, m/d')&' '>
					<cfset tab.Legs[getsearchlegs.CurrentRow] = getsearchlegs.Depart_City&' to '&getsearchlegs.Arrival_City&' on '&DateFormat(getsearchlegs.Depart_DateTime, 'ddd, m/d')>
				</cfloop>--->
			<cfelseif NOT getsearch.Air>
				<cfset searchfilter.setDestination(application.stAirports[getsearch.Arrival_City])>
			</cfif>

			<!---Set filter--->
			<cfset session.Filters[arguments.SearchID] = searchfilter>
			<!---Set session variables--->
			<cfset session.UserID = getSearch.User_ID>
			<cfset session.AcctID = getSearch.Acct_ID>
			<cfset session.PolicyID = getSearch.Policy_ID>
			<!---Default the search session struct--->
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
			<cfset session.searches[arguments.SearchID].stItinerary = {}>
			<cfset session.searches[arguments.SearchID].stSelected = StructNew("linked")>
			<cfset session.searches[arguments.SearchID].stSelected[0] = {}>
			<cfset session.searches[arguments.SearchID].stSelected[1] = {}>
			<cfset session.searches[arguments.SearchID].stSelected[2] = {}>
			<cfset session.searches[arguments.SearchID].stSelected[3] = {}>
		</cfif>

		<cfreturn searchfilter/>
	</cffunction>

<!---
setAccount
--->
	<cffunction name="setAccount" output="false">
		<cfargument name="AcctID">

		<cfset local.stTemp = {}>
		<cfif arguments.AcctID NEQ 0>
			<!---Lazy loading, adds account to the application scope as needed.--->
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

			<cfquery name="local.qAccount">
			SELECT Accounts.Acct_ID, Accounts.Account_Name, Delivery_AON, Logo, PCC_Booking, PNR_AddAccount, BTA_Move, Gov_Rates,
			Air_PTC, Air_PF, Hotel_RateCodes, Account_Policies, Account_Approval, Account_AllowRequests, RMUs,
			RMU_Agent, RMU_NonAgent, CBA_AllDepts, Error_Contact, Error_Email, CouldYou
			FROM Accounts, Zeus.Corporate_Production.dbo.Accounts CPAccounts<!--- CouldYou is in the Corporate_Production accounts table --->
			WHERE Accounts.Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			AND Accounts.Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
			AND Accounts.Acct_ID = CPAccounts.Acct_ID
			</cfquery>

			<cfloop list="#qAccount.ColumnList#" index="local.sCol">
				<cfset stTemp[sCol] = qAccount[sCol]>
			</cfloop>
			<cfset stTemp.sBranch = Branches[qAccount.PCC_Booking]>
			<cfset stTemp.Air_PF = ListToArray(stTemp.Air_PF, '~')>

			<cfquery name="local.qOutOfPolicy" datasource="book">
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

			<cfquery name="local.qPreferred" datasource="book">
			SELECT Acct_ID, Vendor_ID, Type
			FROM Preferred_Vendors
			WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfset stTemp.aPreferredAir = []>
			<cfset stTemp.aPreferredCar = []>
			<cfset stTemp.aPreferredHotel = []>
			<cfloop query="qPreferred">
				<cfif StructKeyExists(stTemp, Acct_ID)>
					<cfset local.sType = 'aPreferred'&(qPreferred.Type EQ 'A' ? 'Air' : (qPreferred.Type EQ 'C' ? 'Car' : 'Hotel'))>
					<cfset ArrayAppend(stTemp[sType], qPreferred.Vendor_ID)>
				</cfif>
			</cfloop>

			<cfset application.Accounts[arguments.AcctID] = stTemp>
		</cfif>

		<cfreturn stTemp/>
	</cffunction>

<!---
setPolicy
--->
	<cffunction name="setPolicy" output="false">
		<cfargument name="PolicyID">

		<cfset local.stTemp = {}>
		<cfif arguments.PolicyID NEQ 0>
			<!---Lazy loading, adds policies to the application scope as needed.--->
			<cfquery name="local.qPolicy" datasource="book">
			SELECT Policy_ID, Acct_ID, Policy_Include, Policy_Approval, Policy_Window, Policy_AirReasonCode, Policy_AirLostSavings,
			Policy_AirFirstClass, Policy_AirBusinessClass, Policy_AirLowRule, Policy_AirLowDisp, Policy_AirLowPad,
			Policy_AirMaxRule, Policy_AirMaxDisp, Policy_AirMaxTotal, Policy_AirPrefRule, Policy_AirPrefDisp, Policy_AirAdvRule,
			Policy_AirAdvDisp, Policy_AirAdv, Policy_AirRefRule, Policy_AirRefDisp, Policy_AirNonRefRule, Policy_AirNonRefDisp,
			Policy_FindIt, Policy_FindItDays, Policy_FindItDiff, Policy_FindItFee, Policy_CarReasonCode, Policy_CarMaxRule, Policy_CarMaxDisp,
			Policy_CarMaxRate, Policy_CarPrefRule, Policy_CarPrefDisp, Policy_CarTypeRule, Policy_CarTypeDisp, Policy_CarOnlyRates,
			Policy_HotelReasonCode, Policy_HotelMaxRule, Policy_HotelMaxDisp, Policy_HotelMaxRate, Policy_HotelPrefRule, Policy_HotelPrefDisp,
			Policy_HotelNotBooking, Policy_AirFee, Policy_AirIntFee, Policy_NonAirFee, Policy_SpecialRequestFee, Policy_AgentAirFee,
			Policy_AgentAirIntFee, Policy_AgentNonAirFee, Policy_ComplexFee, BookIt_MonthFee, BookIt_TransFee, Policy_AllowRequests
			FROM Account_Policies
			WHERE Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			AND Policy_ID = <cfqueryparam value="#arguments.PolicyID#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfset local.stTemp = {}>
			<cfloop list="#qPolicy.ColumnList#" index="local.sCol">
				<cfset stTemp[sCol] = qPolicy[sCol]>
			</cfloop>

			<cfquery name="local.qPreferredCarSizes" datasource="book">
			SELECT Car_Size, Policy_ID
			FROM Policy_CarCategories
			WHERE Policy_ID = <cfqueryparam value="#arguments.PolicyID#" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfset stTemp.aCarSizes = []>
			<cfloop query="qPreferredCarSizes">
				<cfset ArrayAppend(stTemp.aCarSizes, qPreferredCarSizes.Car_Size)>
			</cfloop>

			<cfquery name="local.qCDNumbers">
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
		
<!---
setAirVendors
--->
	<cffunction name="setAirVendors" output="false" returntype="void">
		
		<cfquery name="local.qAirVendors" datasource="booking">
		SELECT VendorCode, ShortName
		FROM RAIR
		WHERE VendorCode NOT LIKE '%/%'
		</cfquery>
		<cfset local.stTemp = {}>
		<cfloop query="qAirVendors">
			<cfset stTemp[VendorCode].Name = ShortName>
			<cfset stTemp[VendorCode].Bag1 = 0>
		</cfloop>
		<cfquery name="local.qBagFees" datasource="Corporate_Production">
		SELECT ShortCode, OnlineDomBag1
		FROM OnlineCheckIn_Links, Suppliers
		WHERE OnlineDomBag1 IS NOT NULL
		AND OnlineDomBag1 <> 0
		AND OnlineCheckIn_Links.AccountID = Suppliers.AccountID
		</cfquery>
		<cfloop query="qBagFees">
			<cfset stTemp[ShortCode].Bag1 = OnlineDomBag1>
		</cfloop>
		<cfset application.stAirVendors = stTemp>
		
		<cfreturn />
	</cffunction>
	
<!---
setCarVendors
--->
	<cffunction name="setCarVendors" output="false" returntype="void">
		
		<cfquery name="local.qCarVendors" datasource="booking">
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
	
<!---
setHotelVendors
--->
	<cffunction name="setHotelVendors" output="false" returntype="void">
		
		<cfquery name="local.qHotelChains" datasource="booking">
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
	
<!---
setEquipment
--->
	<cffunction name="setEquipment" output="false" returntype="void">
		
		<cfquery name="local.qEquipment" datasource="booking">
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
	
<!---
setAirports
--->
	<cffunction name="setAirports" output="false" returntype="void">
		
		<cfquery name="local.qAirports" datasource="booking">
		SELECT AirportCode, AirportName
		FROM RAPT
		</cfquery>
		<cfset local.stTemp = {}>
		<cfloop query="qAirports">
			<cfset stTemp[AirportCode] = AirportName>
		</cfloop>
		
		<cfset application.stAirports = stTemp>
		
		<cfreturn />
	</cffunction>
		
<!---
setAmenities
--->
	<cffunction name="setAmenities" output="false" returntype="void">
		
		<cfquery name="local.qAmenities" datasource="booking">
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
			
</cfcomponent>