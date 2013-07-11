<cfcomponent output="false">

	<cffunction name="init" returntype="any" access="public" output="false" hint="I initialize this component">

		<cfreturn this />
	</cffunction>

	<cffunction name="travelerJSON" returntype="any" returnformat="plain" access="remote" output="false">
		<cfargument name="searchID" required="true" type="numeric">
		<cfargument name="travelerNumber" required="true" type="numeric">

		<cfreturn  serializeJSON(session.searches[arguments.searchID].travelers[arguments.travelerNumber])/>
	</cffunction>

	<cffunction name="getOutOfPolicy" output="false">
		<cfargument name="acctID" required="true" type="numeric">
		
		<cfquery name="local.qOutOfPolicy" datasource="Corporate_Production" cachedwithin="#CreateTimeSpan(30,0,0,0)#">
			SELECT FareSavingsCode
				, Description
			FROM FareSavingsCode
			WHERE STO = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
				AND FareSavingsCodeID NOT IN (35)
				<cfif arguments.acctID NEQ 348>
					AND Acct_ID IS NULL
				<cfelse>
					AND Acct_ID = <cfqueryparam value="348" cfsqltype="cf_sql_integer">
				</cfif>
			ORDER BY FareSavingsCode
		</cfquery>
		
		<cfreturn qOutOfPolicy>
	</cffunction>

	<cffunction name="getStates" output="false">
		
		<cfquery name="local.qStates" datasource="book" cachedwithin="#CreateTimeSpan(30,0,0,0)#">
			SELECT State_Code
				, State_Name
			FROM LU_States
			WHERE State_Country = 'United States'
			ORDER BY State_Code
		</cfquery>
		
		<cfreturn qStates>
	</cffunction>

	<cffunction name="getTXExceptionCodes" output="false">
		
		<cfquery name="local.qTXExceptionCodes" datasource="Corporate_Production" cachedwithin="#CreateTimeSpan(30,0,0,0)#">
			SELECT FareSavingsCode
				, Description
			FROM FareSavingsCode
			WHERE Acct_ID = <cfqueryparam value="235" cfsqltype="cf_sql_integer">
				AND STO = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			ORDER BY FareSavingsCode
		</cfquery>
		
		<cfreturn qTXExceptionCodes>
	</cffunction>

<!--- <!---
saveSummary
--->
	<cffunction name="saveSummary" output="false">
		<cfargument name="qAllOUs">
		<cfargument name="NoMiddleName" default="0">
		<cfargument name="AirFOP_ID" default="">
		<cfargument name="CarFOP_ID" default="">
		<cfargument name="HotelFOP_ID" default="">
		<cfargument name="Traveler">

		<cfloop collection="#arguments#" item="local.field">
			<cfset local[field] = arguments[field]>
		</cfloop>

		<cfset local.stItinerary = session.searches[SearchID].stItinerary>
		<cfset local.stTraveler = session.searches[SearchID].stTravelers[nTraveler]>
		<cfset stTraveler.Errors = {}>

		<!--- Personal Information --->
		<cfif First_Name EQ ''>
			<cfset stTraveler.First_Name = ''>
			<cfset stTraveler.Errors.First_Name = ''>
		<cfelse>
			<cfset stTraveler.First_Name = First_Name>
		</cfif>
		<cfif (NoMiddleName EQ 0 AND Middle_Name EQ '')
		OR (NoMiddleName EQ 1 AND Middle_Name NEQ '')>
			<cfset stTraveler.Middle_Name = ''>
			<cfset stTraveler.Errors.Middle_Name = ''>
		<cfelse>
			<cfset stTraveler.Middle_Name = Middle_Name>
		</cfif>
		<cfset stTraveler.NoMiddleName = NoMiddleName>
		<cfif Last_Name EQ ''>
			<cfset stTraveler.Last_Name = ''>
			<cfset stTraveler.Errors.Last_Name = ''>
		<cfelse>
			<cfset stTraveler.Last_Name = Last_Name>
		</cfif>
		<cfif Phone_Number EQ ''>
			<cfset stTraveler.Phone_Number = ''>
			<cfset stTraveler.Errors.Phone_Number = ''>
		<cfelse>
			<cfset stTraveler.Phone_Number = Phone_Number>
		</cfif>
		<cfif Wireless_Phone EQ ''>
			<cfset stTraveler.Wireless_Phone = ''>
			<cfset stTraveler.Errors.Wireless_Phone = ''>
		<cfelse>
			<cfset stTraveler.Wireless_Phone = Wireless_Phone>
		</cfif>
		<cfif NOT IsValid('Email', Email)>
			<cfset stTraveler.Email = ''>
			<cfset stTraveler.Errors.Email = ''>
		<cfelse>
			<cfset stTraveler.Email = Email>
		</cfif>
		<cfset local.sTempEmails = ''>
		<cfset local.sTempError = 0>
		<cfloop list="#Replace(Replace(CCEmail, ',', ';', 'ALL'), ' ', '', 'ALL')#" delimiters=";" index="local.sEmail">
			<cfif IsValid('Email', sEmail)>
				<cfset sTempEmails = ListAppend(sTempEmails, sEmail, ';')>
			<cfelse>
				<cfset sTempError = 1>
			</cfif>
		</cfloop>
		<cfif sTempError>
			<cfset stTraveler.CCEmail = ''>
			<cfset stTraveler.Errors.CCEmail = ''>
		<cfelse>
			<cfset stTraveler.CCEmail = sTempEmails>
		</cfif>
		<cfset local.Birthdate = Month&'/'&Day&'/'&(Year EQ '****' AND IsDate(stTraveler.Birthdate) ? Year(stTraveler.Birthdate) : Year)>
		<cfif NOT IsDate(Birthdate)>
			<cfset stTraveler.Birthdate = ''>
			<cfset stTraveler.Errors.Birthdate = ''>
		<cfelse>
			<cfset stTraveler.Birthdate = CreateODBCDate(Birthdate)>
		</cfif>
		<cfif Gender EQ ''>
			<cfset stTraveler.Gender = ''>
			<cfset stTraveler.Errors.Gender = ''>
		<cfelse>
			<cfset stTraveler.Gender = Gender>
		</cfif>
		<cfset local.qAllOUs = getAllOUs(stTraveler.Value_ID, session.AcctID)>
		<!--- Org Units --->
		<cfloop query="qAllOUs" group="OU_ID">
			<cfset local.field = qAllOUs.OU_Type&qAllOUs.OU_Position>
			<cfset local.value = local[field]>
			<cfif (qAllOUs.OU_Capture EQ 'R'
				OR (qAllOUs.OU_Capture EQ 'P' AND stTraveler.User_ID EQ 0))>
				<cfif qAllOUs.OU_Required EQ 1 AND Len(Trim(value)) LTE 0>
					<cfset stTraveler.Errors[field] = ''>
				<cfelseif qAllOUs.OU_Freeform EQ 1 AND Len(Trim(value)) GT 0 AND qAllOUs.OU_Pattern NEQ ''>
					<cfloop from="1" to="#Len(qAllOUs.OU_Pattern)#" index="local.character">
						<cfset local.patternCharacter = Mid(qAllOUs.OU_Pattern, character, 1)>
						<cfset local.stringCharacter = Mid(value, character, 1)>
						<cfif (IsNumeric(patternCharacter) AND NOT IsNumeric(stringCharacter))
						OR (patternCharacter EQ 'A' AND REFind("[A-Za-z]", stringCharacter, 1) NEQ 1)
						OR (patternCharacter EQ 'x' AND REFind("[^A-Za-z|^0-9]", stringCharacter, 1) EQ 1)
						OR (REFind("[^A-Za-z|^0-9]", patternCharacter, 1) EQ 1 AND patternCharacter NEQ stringCharacter)>
							<cfset stTraveler.Errors[field] = ''>
							<cfbreak>
						</cfif>
					</cfloop>
				<cfelseif (qAllOUs.OU_Required EQ 1 AND qAllOUs.OU_Freeform EQ 1 AND Len(Trim(value)) GT qAllOUs.OU_Max)
				OR (qAllOUs.OU_Required EQ 1 AND qAllOUs.OU_Freeform EQ 1 AND Len(Trim(value)) LT qAllOUs.OU_Min)>
					<cfset stTraveler.Errors[field] = ''>
				</cfif>
			</cfif>
			<cfif NOT structKeyExists(stTraveler.Errors, field)>
				<cfset stTraveler.OUs[field].Value_ID = ''>
				<cfset stTraveler.OUs[field].Value_Display = ''>
				<cfset stTraveler.OUs[field].Value_Report = value>
			</cfif>
		</cfloop>

		<!--- Air Payment --->
		<cfset stTraveler.AirFOP.Errors = {}>
		<cfif IsNumeric(AirFOP_ID)>
			<cfset stTraveler.AirFOP = stTraveler.listFOPs[AirFOP_ID]>
			<cfset stTraveler.AirFOP.AirFOP_ID = AirFOP_ID>
		<cfelseif AirFOP_ID EQ 'Manual'>
			<cfset stTraveler.AirFOP.AirFOP_ID = 'Manual'>
			<cfset stTraveler.AirFOP.FOP_ID = ''>
			<cfset stTraveler.AirFOP.BTA_ID = ''>
			<cfset stTraveler.AirFOP.CC_UseType = 'Manual'>
			<cfset stTraveler.AirFOP.aUses = ['A']>
			<cfif AirCC_Code EQ ''>
				<cfset stTraveler.AirFOP.CC_Code = ''>
				<cfset stTraveler.AirFOP.Errors.AirCC_Code = ''>
			<cfelse>
				<cfset stTraveler.AirFOP.CC_Code = AirCC_Code>
			</cfif>
			<cfif Len(AirCC_Number) LT 15>
				<cfset stTraveler.AirFOP.CC_Number = ''>
				<cfset stTraveler.AirFOP.Errors.AirCC_Number = ''>
			<cfelse>
				<cfset stTraveler.AirFOP.CC_Number = AirCC_Number>
			</cfif>
			<cfif AirCC_Month EQ '' OR AirCC_Year EQ 0>
				<cfset stTraveler.AirFOP.CC_Expiration = ''>
				<cfset stTraveler.AirFOP.Errors.AirCC_Month = ''>
			<cfelse>
				<cfset stTraveler.AirFOP.CC_Expiration = AirCC_Month&'/'&AirCC_Year>
			</cfif>
			<cfif AirBilling_Name EQ ''>
				<cfset stTraveler.AirFOP.Billing_Name = ''>
				<cfset stTraveler.AirFOP.Errors.AirBilling_Name = ''>
			<cfelse>
				<cfset stTraveler.AirFOP.Billing_Name = AirBilling_Name>
			</cfif>
			<cfif AirBilling_Address EQ ''>
				<cfset stTraveler.AirFOP.Billing_Address = ''>
				<cfset stTraveler.AirFOP.Errors.AirBilling_Address = ''>
			<cfelse>
				<cfset stTraveler.AirFOP.Billing_Address = AirBilling_Address>
			</cfif>
			<cfif AirBilling_City EQ ''>
				<cfset stTraveler.AirFOP.Billing_City = ''>
				<cfset stTraveler.AirFOP.Errors.AirBilling_City = ''>
			<cfelse>
				<cfset stTraveler.AirFOP.Billing_City = AirBilling_City>
			</cfif>
			<cfif AirBilling_State EQ ''>
				<cfset stTraveler.AirFOP.Billing_State = ''>
				<cfset stTraveler.AirFOP.Errors.AirBilling_State = ''>
			<cfelse>
				<cfset stTraveler.AirFOP.Billing_State = AirBilling_State>
			</cfif>
			<cfif AirBilling_Zip EQ ''>
				<cfset stTraveler.AirFOP.Billing_Zip = ''>
				<cfset stTraveler.AirFOP.Errors.AirBilling_Zip = ''>
			<cfelse>
				<cfset stTraveler.AirFOP.Billing_Zip = AirBilling_Zip>
			</cfif>
			<cfif AirBilling_CVV EQ ''>
				<cfset stTraveler.AirFOP.Billing_CVV = ''>
				<cfset stTraveler.AirFOP.Errors.AirBilling_CVV = ''>
			<cfelse>
				<cfset stTraveler.AirFOP.Billing_CVV = AirBilling_CVV>
			</cfif>
		</cfif>

		<!--- Car Payment --->

		<!--- Hotel Payment --->

		Air Options
		<cfset stTraveler.Window_Aisle = Seats>
		<cfloop array="#stItinerary.Air.Carriers#" index="nCarrierKey" item="sCarrier">
			<cfset stTraveler.Air_FF[sCarrier] = local['Air_FF#sCarrier#']>
		</cfloop>
		<cfset stTraveler.Service_Requests = Service_Requests>
		<cfset stTraveler.Special_Requests = Special_Requests>
		<cfif structKeyExists(local, 'Air_ReasonCode')>
			<cfif Air_ReasonCode EQ ''>
				<cfset stTraveler.Air_ReasonCode = ''>
				<cfset stTraveler.Errors.Air_ReasonCode = ''>
			<cfelse>
				<cfset stTraveler.Air_ReasonCode = Air_ReasonCode>
			</cfif>
		</cfif>
		<cfif structKeyExists(local, 'LostSavings')>
			<cfif LostSavings EQ ''>
				<cfset stTraveler.LostSavings = ''>
				<cfset stTraveler.Errors.LostSavings = ''>
			<cfelse>
				<cfset stTraveler.LostSavings = LostSavings>
			</cfif>
		</cfif>
		<cfloop array="#stItinerary.Air.Carriers#" item="sCarrier">
			<cfset stTraveler['Air_FF#sCarrier#'] = local['Air_FF#sCarrier#']>
		</cfloop>
		<!---<cfset stTraveler.Car_FF[stItinerary.Air.CarVendor] = Car_FF>--->
		
		<!--- Car Options --->

		<!--- Hotel Options --->
		
		<cfset session.searches[SearchID].stTravelers[nTraveler] = stTraveler>

		<cfreturn />
	</cffunction>

<!---
getOUs
--->
	<cffunction name="getAllOUs" output="false">
		<cfargument name="valueID">
		<cfargument name="acctID">
		
		<cfquery name="local.qAllOUs" datasource="Corporate_Production" cachedwithin="#createTime(24,0,0)#">
		SELECT OUs.OU_ID, OU_Name, OU_Capture, OU_Position, OU_Default, OU_Required, OU_Freeform, OU_Pattern, OU_Max, OU_Min, OU_Values.Value_ID, OU_Type, OU_STO, Value_Display, Value_Report
		FROM OUs LEFT OUTER JOIN OU_Values ON OUs.OU_ID = OU_Values.OU_ID
		WHERE Acct_ID = <cfqueryparam value="#arguments.acctID#" cfsqltype="cf_sql_integer">
		AND OUs.Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		AND (MainOU_ID IS NULL OR MainValue_ID IN (<cfqueryparam value="#arguments.valueID#" cfsqltype="cf_sql_integer">))
		AND OUs.OU_ID NOT IN (<cfqueryparam value="347,348,349" cfsqltype="cf_sql_integer" list="true">)<!--- Custom code for the State of Texas execption codes --->
		<cfif arguments.acctID NEQ 348>
			AND OU_Capture IN (<cfqueryparam value="R,P" cfsqltype="cf_sql_varchar" list="true">)
			AND OU_Type IN (<cfqueryparam value="SORT,UDID" cfsqltype="cf_sql_varchar" list="true">)
		<cfelse>
			AND OUs.OU_ID IN (<cfqueryparam value="399,400,401,402,403" cfsqltype="cf_sql_integer" list="true">)
		</cfif>
		ORDER BY OU_Order, OUs.OU_ID, Value_Display
		</cfquery>
		
		<cfreturn qAllOUs>
	</cffunction>

<!---
determineFees
--->
	<cffunction name="determineFees" access="remote" output="false">
		<cfargument name="AcctID" 		default="#session.AcctID#">
		<cfargument name="UserID" 		default="#session.UserID#">
		<cfargument name="stItinerary">
		<cfargument name="Fitler">
		
		<cfset local.stFees = {}>
		<cfset local.Air = false>
		<cfset local.sFeeType = ''>
		<!--- Determine if an agent is booking for the traveler --->
		<cfquery name="local.qAgentSine" datasource="Corporate_Production">
		SELECT AccountID
		FROM Payroll_Users
		WHERE User_ID = <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfif StructKeyExists(arguments.stItinerary, 'Air')>
			<cfset local.Air = true>
			<cfif qAgentSine.AccountID EQ ''>
				<cfset sFeeType = 'ODOM'>
			<cfelse>
				<cfset sFeeType = 'DOM'>
			</cfif>
			<cfset local.stCities = {}>
			<cfset local.nSegments = 0>
			<cfloop collection="#arguments.stItinerary.Air.Groups#" item="local.Group">
				<cfloop collection="#arguments.stItinerary.Air.Groups[Group].Segments#" item="local.sSegment">
					<cfset stCities[arguments.stItinerary.Air.Groups[Group].Segments[sSegment].Origin] = ''>
					<cfset stCities[arguments.stItinerary.Air.Groups[Group].Segments[sSegment].Destination] = ''>
					<cfset nSegments++>
				</cfloop>
			</cfloop>
			<cfquery name="local.qSearch">
			SELECT Country_Code
			FROM lu_Geography
			WHERE Location_Code IN (<cfqueryparam value="#StructKeyList(stCities)#" cfsqltype="cf_sql_varchar">)
			AND Location_Type = <cfqueryparam value="125" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfloop query="qSearch">
				<cfif qSearch.Country_Code NEQ 'US'>
					<cfif qAgentSine.AccountID EQ ''>
						<cfset sFeeType = 'OINTL'>
					<cfelse>
						<cfset sFeeType = 'INTL'>
					</cfif>
				</cfif>
			</cfloop>
			<cfif (sFeeType EQ 'OINTL' OR sFeeType EQ 'INTL')
			AND (ArrayLen(arguments.stItinerary.Air.Carriers) GT 1
				OR arguments.Filter.getAirType() EQ 'MD'
				OR nSegments GT 6)>
					<cfif qAgentSine.AccountID EQ ''>
						<cfset sFeeType = 'OINTLRD'>
					<cfelse>
						<cfset sFeeType = 'INTLRD'>
					</cfif>
			</cfif>
		<cfelse>
			<cfif qAgentSine.AccountID EQ ''>
				<cfset sFeeType = 'OAUX'>
			<cfelse>
				<cfset sFeeType = 'MAUX'>
			</cfif>
		</cfif>
		<cfquery name="local.qRequest" datasource="Corporate_Production">
		SELECT IsNull(Fee_Amount, 0) AS Fee_Amount
		FROM Account_Fees
		WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
		AND Fee_Type = <cfqueryparam value="ORQST" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfquery name="local.qSpecificFee" datasource="Corporate_Production">
		SELECT IsNull(Fee_Amount, 0) AS Fee_Amount
		FROM Account_Fees
		WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
		AND Fee_Type = <cfqueryparam value="#sFeeType#" cfsqltype="cf_sql_varchar">
		</cfquery>
<!--- TO DO : Traveler Count --->
		<cfset stFees.nRequestFee = qRequest.Fee_Amount>
		<cfset stFees.nSpecificFee = qSpecificFee.Fee_Amount>
		<cfset stFees.bComplex = (sFeeType NEQ 'OINTLRD' AND sFeeType NEQ 'INTLRD' ? false : true)>
		<cfset stFees.sAgent = qAgentSine.AccountID>
<!--- TO DO : Special requests --->
		<!--- <cfif Air AND qAgentSine.AccountID EQ '' AND getAllTravelers.Special_Requests NEQ ''>
			<cfset Fee = RequestFee + Fee>
		</cfif> --->
		
		<cfreturn stFees />
	</cffunction>

<!---
getTXExceptionCodes
--->
 --->
</cfcomponent>