<cfcomponent output="false">

	<cffunction name="setServerURL" output="false" returntype="void">
		
		<cfset application.sServerURL = (cgi.https EQ 'on' ? 'https' : 'http')&'://'&cgi.Server_Name&'/booking'>
		
		<cfreturn />
	</cffunction>
	
	<cffunction name="setServerURL" output="false" returntype="void">
		
		<cfset local.sServerURL = ''>
		<cfif cgi.https EQ 'on'>
			<cfset sServerURL = 'https://'&cgi.Server_Name&'/booking'>
		<cfelse>
			<cfset sServerURL = 'http://'&cgi.Server_Name&'/booking'>
		</cfif>
		<cfset application.sServerURL = sServerURL>
		
		<cfreturn />
	</cffunction>
	
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
	
	<cffunction name="setAPIAuth" output="false" returntype="void">
		
		<cfset application.sAPIAuth = ToBase64('Universal API/uAPI6148916507-02cbc4d4:Qq7?b6*X5B')>
		
		<cfreturn />
	</cffunction>
	
	<cffunction name="setAccounts" output="false" returntype="void">
		
		<cfset local.stBranches = {
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
		
		<cfquery name="local.qAccounts" datasource="book">
		SELECT Acct_ID, Account_Name, Delivery_AON, Logo, PCC_Booking, PNR_AddAccount, BTA_Move, Gov_Rates, Air_PassengerCodes,
		Air_PrivateFares, Air_PTC, Air_PF, Hotel_RateCodes, Account_Policies, Account_Approval, Account_AllowRequests, RMUs,
		RMU_Agent, RMU_NonAgent, CBA_AllDepts, Error_Contact, Error_Email
		FROM Accounts
		WHERE Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer" >
		</cfquery>
		<cfset local.stTemp = {}>
		<cfloop query="qAccounts">
			<cfset stTemp[Acct_ID] = {}>
			<cfset stTemp[Acct_ID].aPreferredAir = ArrayNew()> 
			<cfset stTemp[Acct_ID].aPreferredCar = ArrayNew()> 
			<cfset stTemp[Acct_ID].aPreferredHotel = ArrayNew()> 
			<cfset stTemp[Acct_ID].aNonPolicyAir = ArrayNew()> 
			<cfset stTemp[Acct_ID].aNonPolicyCar = ArrayNew()> 
			<cfset stTemp[Acct_ID].aNonPolicyHotel = ArrayNew()> 
			<cfloop list="#qAccounts.ColumnList#" index="local.sCol">
				<cfset stTemp[Acct_ID][sCol] = qAccounts[sCol]>
			</cfloop>
			<cfset stTemp[Acct_ID].sBranch = stBranches[PCC_Booking]> 
			<cfset stTemp[Acct_ID].Air_PF = ListToArray(stTemp[Acct_ID].Air_PF, '~')> 
		</cfloop>
		
		<cfquery name="local.qOutOfPolicy" datasource="book">
		SELECT Vendor_ID, Acct_ID, Type
		FROM OutofPolicy_Vendors
		</cfquery>
		<cfloop query="qOutOfPolicy">
			<cfif StructKeyExists(stTemp, Acct_ID)>
				<cfset local.sType = 'aNonPolicy'&(Type EQ 'A' ? 'Air' : (Type EQ 'C' ? 'Car' : 'Hotel'))>
				<cfset ArrayAppend(stTemp[Acct_ID][sType], qOutOfPolicy.Vendor_ID)>
			</cfif>
		</cfloop>
		
		<cfquery name="local.qPreferred" datasource="book">
		SELECT Acct_ID, Vendor_ID, Type
		FROM Preferred_Vendors
		</cfquery>
		<cfloop query="qPreferred">
			<cfif StructKeyExists(stTemp, Acct_ID)>
				<cfset local.sType = 'aPreferred'&(Type EQ 'A' ? 'Air' : (Type EQ 'C' ? 'Car' : 'Hotel'))>
				<cfset ArrayAppend(stTemp[Acct_ID][sType], qPreferred.Vendor_ID)>
			</cfif>
		</cfloop>
		
		<cfset application.stAccounts = stTemp>
		
		<cfreturn />
	</cffunction>
	
	<cffunction name="setPolicies" output="false" returntype="void">
		
		<cfquery name="local.qPolicies" datasource="book">
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
		WHERE Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer" >
		</cfquery>
		<cfset local.stTemp = {}>
		<cfloop query="qPolicies">
			<cfset stTemp[Policy_ID] = {}>
			<cfset stTemp[Policy_ID].aCarSizes = ArrayNew()>
			<cfloop list="#qPolicies.ColumnList#" index="local.sCol">
				<cfset stTemp[Policy_ID][sCol] = qPolicies[sCol]>
			</cfloop> 
		</cfloop>
		
		<cfquery name="local.qPreferredCarSizes" datasource="book">
		SELECT Car_Size, Policy_ID
		FROM Policy_CarSizes
		</cfquery>
		<cfloop query="qPreferredCarSizes">
			<cfif StructKeyExists(stTemp, Policy_ID)>
				<cfset ArrayAppend(stTemp[Policy_ID].aCarSizes, qPreferredCarSizes.Car_Size)>
			</cfif>
		</cfloop>
		
		<cfset application.stPolicies = stTemp>
		
		<cfreturn />
	</cffunction>
		
	<cffunction name="setAirVendors" output="false" returntype="void">
		
		<cfquery name="local.qAirVendors">
		SELECT VendorCode, ShortName
		FROM RAIR
		WHERE VendorCode NOT LIKE '%/%'
		</cfquery>
		<cfset local.stTemp = {}>
		<cfloop query="qAirVendors">
			<cfset stTemp[VendorCode] = ShortName>
		</cfloop>
		
		<cfset application.stAirVendors = stTemp>
		
		<cfreturn />
	</cffunction>
	
	<cffunction name="setCarVendors" output="false" returntype="void">
		
		<cfquery name="local.qCarVendors">
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
	
	<cffunction name="setEquipment" output="false" returntype="void">
		
		<cfquery name="local.qEquipment">
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
		
		<cfquery name="local.qAirports">
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
			
</cfcomponent>