<cfcomponent output="false">

	<cffunction name="init" output="false">
		<cfreturn this>
	</cffunction>

	<cffunction name="setServerURL" output="false" returntype="void">

		<cfset application.sServerURL = (cgi.https EQ 'on' ? 'https' : 'http')&'://'&cgi.Server_Name&'/booking'>
		<cfreturn />

	</cffunction>

	<cffunction name="setPortalURL" output="false" returntype="void">

		<cfset local.sPortalURL = ''>
		<cfset local.bDebug = 0>

		<cfif cgi.SERVER_NAME EQ 'www.shortstravelonline.com'>
			<cfset sPortalURL = 'https://www.shortstravel.com'>
		<cfelseif cgi.SERVER_NAME EQ 'www.shortstravel.com'>
			<cfset sPortalURL = 'https://www.shortstravel.com'>
		<cfelseif cgi.SERVER_NAME EQ 'www.b-hives.com'>
			<cfset sPortalURL = 'https://www.b-hive.travel'>
		<cfelseif cgi.SERVER_NAME EQ 'localhost'>
			<cfset sPortalURL = 'http://localhost'>
			<cfset bDebug = 1>
		<cfelseif cgi.SERVER_NAME EQ 'localhost:8888'>
			<cfset sPortalURL = 'http://localhost:8888'>
			<cfset bDebug = 1>
		<cfelseif cgi.SERVER_NAME EQ 'hermes.shortstravel.com'>
			<cfset sPortalURL = 'https://hermes.shortstravel.com'>
		</cfif>

		<cfset application.sPortalURL = sPortalURL>
		<cfset application.bDebug = bDebug>

		<cfreturn />
	</cffunction>

	<cffunction name="setAPIAuth" output="false" returntype="void">

		<cfset application.sAPIAuth = ToBase64('Universal API/UAPI6148916507-02cbc4d4:Qq7?b6*X5B')>
		<cfreturn />

	</cffunction>

	<cffunction name="setFilter" output="false">
		<cfargument name="SearchID" required="true">
		<cfargument name="Append" 	required="false" default="0" >

		<cfset local.searchfilter = createObject("component", "booking.model.searchfilter").init()>
		<cfif arguments.SearchID NEQ 0>

			<cfquery name="local.getsearch">
			SELECT TOP 1 Acct_ID, Search_ID, Air, Car, CarPickup_Airport, CarPickup_DateTime, CarDropoff_DateTime, Hotel, Policy_ID,
			Profile_ID, Value_ID, User_ID, Username, Air_Type, Depart_City, Depart_DateTime, Arrival_City, Arrival_DateTime, Airlines,
			International, Depart_TimeType, Arrival_TimeType, ClassOfService, CheckIn_Date, Arrival_City, CheckOut_Date, Hotel_Search,
			Hotel_Airport, Hotel_Landmark, Hotel_Address, Hotel_City, Hotel_State, Hotel_Zip, Hotel_Country, Office_ID, Hotel_Radius
			, air_heading
			, car_heading
			, hotel_heading
			FROM Searches
			WHERE Search_ID = <cfqueryparam value="#arguments.SearchID#" cfsqltype="cf_sql_integer">
			ORDER BY Search_ID DESC
			</cfquery>



			<cfif getsearch.Air_Type EQ 'MD'>
				<cfquery name="local.getsearchlegs">
					SELECT Depart_City
						, Arrival_City
						, Depart_DateTime
						, Depart_TimeType
					FROM Searches_Legs
					WHERE Search_ID = <cfqueryparam value="#arguments.SearchID#" cfsqltype="cf_sql_numeric" />
					ORDER BY Depart_DateTime
				</cfquery>
			</cfif>

			<!--- populate search filter from query above --->
			<cfset searchfilter.setAcctID(getsearch.Acct_ID)>
			<cfset searchfilter.setAir(getsearch.Air EQ 1 ? true : false)>
			<cfset searchfilter.setAirHeading(getsearch.air_heading)>
			<cfset searchfilter.setAirlines(getsearch.Airlines)>
			<cfset searchfilter.setAirType(getsearch.Air_Type)>
			<cfset searchfilter.setArrivalCity(getsearch.Arrival_City)>
			<cfset searchfilter.setArrivalDate(getsearch.Arrival_DateTime)>
			<cfset searchfilter.setArrivalType(getsearch.Arrival_TimeType)>
			<cfset searchfilter.setCar(getsearch.Car EQ 1 ? true : false)>
			<cfset searchfilter.setCarHeading(getsearch.Car_Heading)>
			<cfset searchfilter.setCarPickupAirport(getsearch.CarPickup_Airport)>
			<cfset searchfilter.setCarPickupDateTime(getsearch.CarPickup_DateTime)>
			<cfset searchfilter.setCarDropoffDateTime(getsearch.CarDropoff_DateTime)>
			<cfset searchfilter.setCheckIn_Date(getsearch.CheckIn_Date)>
			<cfset searchfilter.setCheckOut_Date(getsearch.CheckOut_Date)>
			<cfset searchfilter.setCOS(getsearch.ClassOfService)>
			<cfset searchfilter.setDepartCity(getsearch.Depart_City)>
			<cfset searchfilter.setDepartDate(getsearch.Depart_DateTime)>
			<cfset searchfilter.setDepartType(getsearch.Depart_TimeType)>
			<cfset searchfilter.setHotel(getsearch.Hotel EQ 1 ? true : false)>
			<cfset searchfilter.setHotel_Address(getsearch.Hotel_Address)>
			<cfset searchfilter.setHotel_Airport(getsearch.Hotel_Airport)>
			<cfset searchfilter.setHotel_City(getsearch.Hotel_City)>
			<cfset searchfilter.setHotel_Country(getsearch.Hotel_Country)>
			<cfset searchfilter.setHotel_Landmark(getsearch.Hotel_Landmark)>
			<cfset searchfilter.setHotel_Radius(getsearch.Hotel_Radius)>
			<cfset searchfilter.setHotel_Search(getsearch.Hotel_Search)>
			<cfset searchfilter.setHotel_State(getsearch.Hotel_State)>
			<cfset searchfilter.setHotel_Zip(getsearch.Hotel_Zip)>
			<cfset searchfilter.setHotelHeading(getsearch.Hotel_Heading)>
			<cfset searchfilter.setInternational(getsearch.International EQ 1 ? true : false)>
			<cfset searchfilter.setOffice_ID(getsearch.Office_ID)>
			<cfset searchfilter.setPolicyID(getsearch.Policy_ID)>
			<cfset searchfilter.setProfileID(getsearch.Profile_ID)>
			<cfset searchfilter.setSearchID(getsearch.Search_ID)>
			<cfset searchfilter.setUserID(getsearch.User_ID)>
			<cfset searchfilter.setUsername(getsearch.Username)>
			<cfset searchfilter.setValueID(getsearch.Value_ID)>

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

			<cfquery name="local.getAirportData" datasource="book">
				SELECT Airport_Name, Airport_City, Airport_State
				FROM lu_FullAirports
				WHERE Airport_Code =
					<cfif getsearch.Car>
						<cfqueryparam value="#getsearch.CarPickup_Airport#" cfsqltype="cf_sql_varchar" />
					<cfelse>
						<cfqueryparam value="#getsearch.Arrival_City#" cfsqltype="cf_sql_varchar" />
					</cfif>
			</cfquery>

			<cfif getsearch.Air>
				<cfswitch expression="#getsearch.Air_Type#">
					<!---
					airHeading - page header
					heading - used in breadcrumb
					--->

					<!--- Round trip tab --->
					<cfcase value="RT">
						<cfif DateFormat(getsearch.Depart_DateTime) NEQ DateFormat(getsearch.Arrival_DateTime)>
							<cfset searchfilter.setAirHeading("#application.stAirports[getsearch.Depart_City]# (#getsearch.Depart_City#) to #application.stAirports[getsearch.Arrival_City]# (#getsearch.Arrival_City#) :: #DateFormat(getsearch.Depart_DateTime, 'ddd mmm d')# - #DateFormat(getsearch.Arrival_DateTime, 'ddd mmm d')#")>
							<cfset searchfilter.setHeading("#getsearch.Depart_City# to #getsearch.Arrival_City# :: #DateFormat(getsearch.Depart_DateTime, 'm/d')# - #DateFormat(getsearch.Arrival_DateTime, 'm/d')#")>
						<cfelse>
							<cfset searchfilter.setAirHeading("#application.stAirports[getsearch.Depart_City]# (#getsearch.Depart_City#) to #application.stAirports[getsearch.Arrival_City]# (#getsearch.Arrival_City#) ::: #DateFormat(getsearch.Depart_DateTime, 'ddd mmm d')#")>
							<cfset searchfilter.setHeading("#getsearch.Depart_City# to #getsearch.Arrival_City# :: #DateFormat(getsearch.Depart_DateTime, 'm/d')#")>
						</cfif>
						<cfset searchfilter.addLeg(getsearch.Depart_City&' - '&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d'))>
						<cfset searchfilter.addLeg(getsearch.Arrival_City&' - '&getsearch.Depart_City&' on '&DateFormat(getsearch.Arrival_DateTime, 'ddd, m/d'))>
					</cfcase>

					<!--- One way --->
					<cfcase value="OW">
						<cfset searchfilter.setAirHeading("#application.stAirports[getsearch.Depart_City]# (#getsearch.Depart_City#) to #application.stAirports[getsearch.Arrival_City]# (#getsearch.Arrival_City#) ::: #DateFormat(getsearch.Depart_DateTime, 'ddd mmm d')#")>
						<cfset searchfilter.setHeading("#getsearch.Depart_City# to #getsearch.Arrival_City# :: #DateFormat(getsearch.Depart_DateTime, 'm/d')#")>
						<cfset searchfilter.addLeg(getsearch.Depart_City&' - '&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d'))>
					</cfcase>

					<!--- Multi-city --->

					<!---
					* Raleigh Durham (RDU) to Miami (MIA) to Atlanta (ATL) :::  Tue Jun 4 – Thurs Jun 6
					* Outbound city – first destination – second destination (the logic would be to take either the next origin or destination city, and not repeat the same city already listed).  And, show first depart and last return date.
					* Set a limit of 3 and  add “…” if there are more:

					Depart_City	Arrival_City	Depart_DateTime	Depart_TimeType
					RDU	MIA	2013-06-05 00:00:00.000	D
					MIA	ATL	2013-06-07 00:00:00.000	D
					ATL	RDU	2013-06-09 00:00:00.000	D

Multi-City
Raleigh Durham (RDU) to Miami (MIA) to Atlanta (ATL) ::: Tue Jun 4 – Thurs Jun 6
Outbound city – first destination – second destination (the logic would be to take either the next origin or destination city, and not repeat the same city already listed). And, show first depart and last return date.
Set a limit of 3 and add “…” if there are more:
Raleigh Durham (RDU) to Miami (MIA) to Atlanta (ATL) … ::: Tue Jun 4 – Thurs Jun 6
					--->

					<cfcase value="MD" >
						<cfset local.tempAirheading = "Air Heading">
						<cfset local.tempHeading = "Breadcrumb">

						<cfloop query="getsearchlegs">
							<cfset searchfilter.addLeg(getSearchLegs.Depart_City&' - '&getSearchLegs.Arrival_City&' on '&DateFormat(getSearchLegs.Depart_DateTime, 'ddd, m/d'))>
						</cfloop>
<!---
Legs
Array
1
string	RDU - ATL on Mon, 6/10
2
string	ATL - MIA on Wed, 6/12
3
string	MIA - RDU on Fri, 6/14 --->


						<cfset searchfilter.setAirHeading(tempAirheading)>
						<cfset searchfilter.setHeading(tempHeading)>


					</cfcase>
				</cfswitch>
			<cfelseif NOT getsearch.Air AND Len(Trim(getsearch.Arrival_City))>
				<cfset searchfilter.setDestination(application.stAirports[getsearch.Arrival_City])>
			</cfif>


			<!--- Set carHeading. --->
			<cfif structKeyExists(getsearch, 'CarPickup_Airport') AND Len(Trim(getsearch.CarPickup_Airport))>
				<cfset searchfilter.setCarHeading(getAirportData.Airport_Name&' ('&getsearch.CarPickup_Airport&'), '&getAirportData.Airport_City&', '&getAirportData.Airport_State&' :: '&DateFormat(getsearch.CarPickup_DateTime, 'ddd mmm d')&' - '&DateFormat(getsearch.CarDropoff_DateTime, 'ddd mmm d'))>
			</cfif>


			<!--- Set session.filters! ---------------------------------------------------->
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
			FROM Accounts, Corporate_Production.dbo.Accounts CPAccounts<!--- CouldYou is in the Corporate_Production accounts table --->
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

	<cffunction name="setAirports" output="false" returntype="void">

		<cfquery name="local.qAirports" datasource="book">
			SELECT location_code AS AirportCode
			, Location_Name AS AirportName
			FROM lu_Geography
			WHERE Location_Type = 125
			ORDER BY AIRPORTCODE
		</cfquery>

		<cfset local.stTemp = {}>

		<cfloop query="qAirports">
			<cfset stTemp[AirportCode] = AirportName>
		</cfloop>

		<cfset application.stAirports = stTemp>

		<cfreturn />
	</cffunction>

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

	<cffunction name="setStates" output="false" returntype="void">

		<cfquery name="local.qStates" datasource="booking">
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

</cfcomponent>