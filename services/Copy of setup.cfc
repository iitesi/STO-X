<cfcomponent output="false">
	
	<cffunction name="setServerURL" output="false" returntype="string">
		
		<cfreturn IIF( cgi.https EQ 'on', DE("https"), DE("http") )&'://'&cgi.Server_Name&'/'&GetToken(this.mappings["booking"], ListLen(this.mappings["booking"], '\'), '\')/>
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
		<cfif cgi.SERVER_NAME EQ 'www.shortstravelonline.com'>
			<cfset sPortalURL = 'https://www.shortstravel.com'>
		<cfelseif cgi.SERVER_NAME EQ 'www.shortstravel.com'>
			<cfset sPortalURL = 'https://www.shortstravel.com'>
		<cfelseif cgi.SERVER_NAME EQ 'www.b-hives.com'>
			<cfset sPortalURL = 'https://www.b-hive.travel'>
		<cfelseif cgi.SERVER_NAME EQ 'localhost'>
			<cfset sPortalURL = 'http://localhost'>
		<cfelseif cgi.SERVER_NAME EQ 'localhost:8888'>
			<cfset sPortalURL = 'http://localhost:8888'>
		<cfelseif cgi.SERVER_NAME EQ 'hermes.shortstravel.com'>
			<cfset sPortalURL = 'https://hermes.shortstravel.com'>
		</cfif>
		
		<cfset application.sPortalURL = sPortalURL>
		
		<cfreturn />
	</cffunction>
	
	<cffunction name="setAPIAuth" output="false" returntype="void">
		
		<cfset application.sAPIAuth = ToBase64('Universal API/uAPI6148916507-02cbc4d4:Qq7?b6*X5B')>
		
		<cfreturn />
	</cffunction>
	
	<cffunction name="setAccounts" output="false" returntype="void">
		
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
			<cfloop list="#qAccounts.ColumnList#" index="local.sCol">
				<cfset stTemp[Acct_ID][sCol] = qAccounts[sCol]>
			</cfloop> 
		</cfloop>
		
		<cfset application.sAccounts = stTemp>
		
		<cfreturn />
	</cffunction>
	
	<cffunction name="setPolicies" output="false" returntype="void">
		
		<cfquery name="local.qPolicies" datasource="book">
		SELECT Policy_ID, Acct_ID, Policy_Include, Policy_Approval, Policy_Window, Policy_AirReasonCode, Policy_AirLostSavings, 
		Policy_AirFirstClass, Policy_AirBusinessClass, Policy_ApprovalText, Policy_AirLowRule, Policy_AirLowDisp, Policy_AirLowPad, 
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
			<cfloop list="#qPolicies.ColumnList#" index="local.sCol">
				<cfset stTemp[Policy_ID][sCol] = qPolicies[sCol]>
			</cfloop> 
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