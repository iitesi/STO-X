<cfcomponent output="false">

<!---
getOUs
--->
	<cffunction name="getOUs" output="false">
		<cfargument name="Value_ID"		default="#session.searches[url.Search_ID].nValueID#">
		<cfargument name="Acct_ID" 		default="#session.Acct_ID#">
		
		<cfquery name="local.qOUs" datasource="Corporate_Production" cachedwithin="#createTime(24,0,0)#">
		SELECT OUs.OU_ID, OU_Name, OU_Capture, OU_Position, OU_Default, OU_Required, OU_Freeform, OU_Pattern, OU_Max, OU_Min, OU_Values.Value_ID, OU_Type, OU_STO, Value_Display, Value_Report
		FROM OUs LEFT OUTER JOIN OU_Values ON OUs.OU_ID = OU_Values.OU_ID
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		AND OUs.Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		AND (MainOU_ID IS NULL OR MainValue_ID IN (<cfqueryparam value="#arguments.Value_ID#" cfsqltype="cf_sql_integer">))
		AND OUs.OU_ID NOT IN (<cfqueryparam value="347,348,349" cfsqltype="cf_sql_integer" list="true">)<!--- Custom code for the State of Texas execption codes --->
		<cfif arguments.Acct_ID NEQ 348>
			AND OU_Capture IN (<cfqueryparam value="R,P" cfsqltype="cf_sql_varchar" list="true">)
			AND OU_Type IN (<cfqueryparam value="SORT,UDID" cfsqltype="cf_sql_varchar" list="true">)
		<cfelse>
			AND OUs.OU_ID IN (<cfqueryparam value="399,400,401,402,403" cfsqltype="cf_sql_integer" list="true">)
		</cfif>
		ORDER BY OU_Order, OUs.OU_ID, Value_Display
		</cfquery>
		
		<cfreturn qOUs>
	</cffunction>

<!---
saveSummary
--->
	<cffunction name="saveSummary" output="false">

		
		<cfset local.stItinerary = session.searches[arguments.nSearchID].stItinerary>
		<cfset local.stTraveler = StructCopy(session.searches[arguments.nSearchID].stTravelers[arguments.nTraveler])>

		<!--- Personal Information --->
		<cfset stTraveler.First_Name = (arguments.First_Name NEQ '' ? arguments.First_Name : 'error')>
		<cfif (arguments.NoMiddleName EQ 0 AND arguments.Middle_Name EQ '')
		OR (arguments.NoMiddleName EQ 1 AND arguments.Middle_Name NEQ '')>
			<cfset stTraveler.Middle_Name = 'error'>
		<cfelse>
			<cfset stTraveler.Middle_Name = arguments.Middle_Name>
		</cfif>
		<cfset stTraveler.NoMiddleName = arguments.NoMiddleName>
		<cfset stTraveler.Last_Name = (arguments.Last_Name NEQ '' ? arguments.Last_Name : 'error')>
		<cfset stTraveler.Phone_Number = (arguments.Phone_Number NEQ '' ? arguments.Phone_Number : 'error')>
		<cfset stTraveler.Wireless_Phone = (arguments.Wireless_Phone NEQ '' ? arguments.Wireless_Phone : 'error')>
		<cfset stTraveler.Email = (IsValid('Email', arguments.Email) ? arguments.Email : 'error')>
		<cfset arguments.CCEmail = Replace(arguments.CCEmail, ' ', '', 'ALL')>
		<cfset arguments.CCEmail = Replace(arguments.CCEmail, ',', ';', 'ALL')>
		<cfset local.sTempEmails = ''>
		<cfset local.sTempError = 0>
		<cfloop list="#arguments.CCEmail#" delimiters=";" index="local.sEmail">
			<cfif IsValid('Email', sEmail)>
				<cfset sTempEmails = ListAppend(sTempEmails, sEmail, ';')>
			<cfelse>
				<cfset sTempError = 1>
			</cfif>
		</cfloop>
		<cfset stTraveler.CCEmail = (NOT sTempError ? sTempEmails : 'error')>
		<cfset local.dBirthday = arguments.Month&'/'&arguments.Day&'/'&(arguments.Year EQ '****' AND IsDate(stTraveler.Birthday) ? Year(stTraveler.Birthday) : arguments.Year)>
		<cfset stTraveler.Birthdate = (IsDate(dBirthday) ? CreateODBCDate(dBirthday) : 'error')>
		<cfset stTraveler.Gender = (arguments.Gender NEQ '' ? arguments.Gender : 'error')>

		<!--- Org Units --->

		<!--- Air Payment --->
		
		<!--- Car Payment --->

		<!--- Hotel Payment --->

		<!--- Air Options --->
		<cfset stTraveler.Window_Aisle = arguments.Seats>
		<cfloop array="#stItinerary.Air.Carriers#" index="nCarrierKey" item="sCarrier">
			<cfset stTraveler.Air_FF[sCarrier] = arguments['Air_FF#sCarrier#']>
		</cfloop>
		<cfset stTraveler.Car_FF[stItinerary.Air.CarVendor] = arguments.Car_FF>
		
		<!--- Car Options --->

		<!--- Hotel Options --->


<cfdump var="#stTraveler#">
<cfdump var="#arguments#">	
		
		<cfabort>

		<cfreturn qAllTravelers />
	</cffunction>

<!---
getAllTravelers
--->
	<cffunction name="getAllTravelers" output="false">
		<cfargument name="User_ID" 		default="#session.User_ID#">
		<cfargument name="Acct_ID" 		default="#session.Acct_ID#">
		
		<cfstoredproc procedure="sp_travelers" datasource="Corporate_Production">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#arguments.Acct_ID#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#arguments.User_ID#">
			<cfprocresult name="local.qAllTravelers"> 
		</cfstoredproc> 

		<cfreturn qAllTravelers />
	</cffunction>

<!---
determinFees
--->
	<cffunction name="determinFees" access="remote" output="false">
		<cfargument name="Acct_ID" 		default="#session.Acct_ID#">
		<cfargument name="User_ID" 		default="#session.User_ID#">
		<cfargument name="stItinerary" 	default="#session.searches[url.Search_ID].stItinerary#">
		<cfargument name="sAirType"		default="#session.searches[url.Search_ID].sAirType#">
		
		<cfset local.stFees = {}>
		<cfset local.bAir = false>
		<cfset local.sFeeType = ''>
		<!--- Determine if an agent is booking for the traveler --->
		<cfquery name="local.qAgentSine" datasource="Corporate_Production">
		SELECT AccountID
		FROM Payroll_Users
		WHERE User_ID = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfif StructKeyExists(arguments.stItinerary, 'Air')>
			<cfset local.bAir = true>
			<cfif qAgentSine.AccountID EQ ''>
				<cfset sFeeType = 'ODOM'>
			<cfelse>
				<cfset sFeeType = 'DOM'>
			</cfif>
			<cfset local.stCities = {}>
			<cfset local.nSegments = 0>
			<cfloop collection="#arguments.stItinerary.Air.Groups#" item="local.nGroup">
				<cfloop collection="#arguments.stItinerary.Air.Groups[nGroup].Segments#" item="local.sSegment">
					<cfset stCities[arguments.stItinerary.Air.Groups[nGroup].Segments[sSegment].Origin] = ''>
					<cfset stCities[arguments.stItinerary.Air.Groups[nGroup].Segments[sSegment].Destination] = ''>
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
				OR arguments.sAirType EQ 'MD'
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
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		AND Fee_Type = <cfqueryparam value="ORQST" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfquery name="local.qSpecificFee" datasource="Corporate_Production">
		SELECT IsNull(Fee_Amount, 0) AS Fee_Amount
		FROM Account_Fees
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		AND Fee_Type = <cfqueryparam value="#sFeeType#" cfsqltype="cf_sql_varchar">
		</cfquery>
<!--- TO DO : Traveler Count --->
		<cfset stFees.nRequestFee = qRequest.Fee_Amount>
		<cfset stFees.nSpecificFee = qSpecificFee.Fee_Amount>
		<cfset stFees.bComplex = (sFeeType NEQ 'OINTLRD' AND sFeeType NEQ 'INTLRD' ? false : true)>
		<cfset stFees.sAgent = qAgentSine.AccountID>
<!--- TO DO : Special requests --->
		<!--- <cfif bAir AND qAgentSine.AccountID EQ '' AND getAllTravelers.Special_Requests NEQ ''>
			<cfset Fee = RequestFee + Fee>
		</cfif> --->
		
		<cfreturn stFees />
	</cffunction>

<!---
getOutOfPolicy
--->
	<cffunction name="getOutOfPolicy" output="false">
		<cfargument name="Acct_ID" default="#session.Acct_ID#">
		
		<cfquery name="local.qOutOfPolicy" datasource="Corporate_Production" cachedwithin="#CreateTimeSpan(30,0,0,0)#">
		SELECT FareSavingsCode, Description
		FROM FareSavingsCode
		WHERE STO = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		AND FareSavingsCodeID NOT IN (35)
		<cfif arguments.Acct_ID NEQ 348>
			AND Acct_ID IS NULL
		<cfelse>
			AND Acct_ID = <cfqueryparam value="348" cfsqltype="cf_sql_integer">
		</cfif>
		ORDER BY FareSavingsCode
		</cfquery>
		
		<cfreturn qOutOfPolicy>
	</cffunction>

<!---
getTXExceptionCodes
--->
	<cffunction name="getTXExceptionCodes" output="false">
		
		<cfquery name="local.qTXExceptionCodes" datasource="Corporate_Production" cachedwithin="#CreateTimeSpan(30,0,0,0)#">
		SELECT *
		FROM FareSavingsCode
		WHERE Acct_ID = <cfqueryparam value="235" cfsqltype="cf_sql_integer">
		AND STO = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		ORDER BY FareSavingsCode
		</cfquery>
		
		<cfreturn qTXExceptionCodes>
	</cffunction>
	
<!--- 
getFOPs
--->
	<cffunction name="getFOPs" output="false">
		<cfargument name="nUserID">
		<cfargument name="nValueID">
		<cfargument name="Acct_ID" 		default="#session.Acct_ID#">
		
		<cfquery name="local.qFOPs" datasource="Corporate_Production">
		<!--- Profile credit cards --->
		SELECT FOP_ID, 0 AS BTA_ID, 'Profile' AS CC_UseType, FOP_Code, Acct_Num, Expire_Date, CASE WHEN Air_Use = 1 THEN 'O' ELSE 'N' END AS Air_Use, CASE WHEN Hotel_Use = 1 THEN 'O' ELSE 'N' END AS Hotel_Use, CASE WHEN BookIt_Use = 1 THEN 'O' ELSE 'N' END AS BookIt_Use, Billing_Name, Billing_Address, Billing_City, Billing_State, Billing_Zip
		FROM Form_Of_Payment, Users
		WHERE Form_Of_Payment.User_ID = <cfqueryparam value="#arguments.nUserID#" cfsqltype="cf_sql_integer">
		AND Form_Of_Payment.User_ID = Users.User_ID
		UNION
		<!--- Account wide credit card --->
		SELECT 0 AS FOP_ID, BTA_ID, 'BTA' AS CC_UseType, FOP_Code, Acct_Num, Expire_Date, BTA_Air AS Air_Use, BTA_Hotel AS Hotel_Use, BTA_BookIt AS BookIt_Use, Billing_Name, Billing_Address, Billing_City, Billing_State, Billing_Zip
		FROM BTAs
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		AND Allow_Rules = <cfqueryparam value="0" cfsqltype="cf_sql_integer">
		UNION
		<!--- Department specific credit card by guest traveler --->
		SELECT 0 AS FOP_ID, BTAs.BTA_ID, 'OU' AS CC_UseType, FOP_Code, Acct_Num, Expire_Date, OU_Air AS Air_Use, OU_Hotel AS Hotel_Use, OU_BookIt AS BookIt_Use, Billing_Name, Billing_Address, Billing_City, Billing_State, Billing_Zip
		FROM BTAs, OU_BTAs, OU_Values
		WHERE OU_BTAs.Value_ID = <cfqueryparam value="#arguments.nValueID#" cfsqltype="cf_sql_integer">
		AND BTAs.BTA_ID = OU_BTAs.BTA_ID
		AND OU_BTAs.Value_ID = OU_Values.Value_ID
		AND OU_Values.Active = 1
		<cfif arguments.Acct_ID EQ 254>
			UNION
			SELECT 0 AS FOP_ID, 0 AS BTA_ID, 'GHOST' AS CC_UseType, '' AS FOP_Code, '' AS Acct_Num, '' AS Expire_Date, 'GHOST' AS CCType, 'O' AS Air_Use, 'N' AS Hotel_Use, 'N' AS BookIt_Use, '' AS Billing_Name, '' AS Billing_Address, '' AS Billing_City, '' AS Billing_State, '' AS Billing_Zip
			FROM OU_Values
			WHERE Value_ID = <cfqueryparam value="#arguments.nValueID#" cfsqltype="cf_sql_integer">
			AND Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		</cfif>
		</cfquery>
		<cfset local.stFOPs = StructNew()>
		<cfset local.aUses = []>
		<cfset local.bAirCard = 0>
		<cfset local.bHotelCard = 0>
		<cfset local.bBookitCard = 0>
		<cfset local.bAirPerCard = 0>
		<cfset local.bHotelPerCard = 0>
		<cfset local.bBookitPerCard = 0>
		<cfset local.nCount = 0>
		<!--- 
		Air/car/hotel status key:
			N = Cannot be used
			R = Travelers are REQUIRED to use this card
			E = Travelers may use this card EXCEPT when a personal card is in their profile
			O = Travelers may use this card OR their personal card in their profile
		--->
		<!--- Set general strings as well as exclusive defaults --->
		<cfloop query="qFOPs">
			<cfset aUses = []>
			<cfif Air_Use EQ 'R'>
				<cfset ArrayAppend(aUses, 'A')>
				<cfset bAirCard = 1>
			</cfif>
			<cfif Hotel_Use EQ 'R'>
				<cfset ArrayAppend(aUses, 'H')>
				<cfset bHotelCard = 1>
			</cfif>
			<cfif BookIt_Use EQ 'R'>
				<cfset ArrayAppend(aUses, 'B')>
				<cfset bBookitCard = 1>
			</cfif>
			<cfif NOT ArrayIsEmpty(aUses)>
				<cfset nCount++ />
				<cfset stFOPs[nCount].FOP_ID = FOP_ID>
				<cfset stFOPs[nCount].BTA_ID = BTA_ID>
				<cfset stFOPs[nCount].CC_UseType = CC_UseType>
				<cfset stFOPs[nCount].aUses = aUses>
				<cfset stFOPs[nCount].CC_Number = 0>
				<cfset stFOPs[nCount].Billing_Name = Billing_Name>
				<cfset stFOPs[nCount].Billing_Address = Billing_Address>
				<cfset stFOPs[nCount].Billing_City = Billing_City>
				<cfset stFOPs[nCount].Billing_State = Billing_State>
				<cfset stFOPs[nCount].Billing_Zip = Billing_Zip>
				<cfset stFOPs[nCount].CC_Exclude = 1>
			</cfif>
		</cfloop>
		<!--- If no exclusive defaults set, check for personal level uses --->
		<cfif NOT bAirCard OR NOT bHotelCard OR NOT bBookitCard>
			<cfloop query="qFOPs">
				<cfif CC_UseType EQ 'Per'>
					<cfset aUses = []>
					<cfif Air_Use NEQ 'N' AND NOT bAirCard>
						<cfset ArrayAppend(aUses, 'A')>
						<cfset bAirPerCard = 1>
					</cfif>
					<cfif Hotel_Use NEQ 'N' AND NOT bHotelCard>
						<cfset ArrayAppend(aUses, 'H')>
						<cfset bHotelPerCard = 1>
					</cfif>
					<cfif BookIt_Use NEQ 'N' AND NOT bBookitCard>
						<cfset ArrayAppend(aUses, 'B')>
						<cfset bBookitPerCard = 1>
					</cfif>
					<cfif NOT ArrayIsEmpty(aUses)>
						<cfset Card_Name = CCName&' - Ending in '&Right(CCNum, 4)>
						<cfset nCount++ />
						<cfset stFOPs[nCount].FOP_ID = FOP_ID>
						<cfset stFOPs[nCount].BTA_ID = BTA_ID>
						<cfset stFOPs[nCount].CC_UseType = CC_UseType>
						<cfset stFOPs[nCount].aUses = aUses>
						<cfset stFOPs[nCount].CC_Number = 0>
						<cfset stFOPs[nCount].Billing_Name = Billing_Name>
						<cfset stFOPs[nCount].Billing_Address = Billing_Address>
						<cfset stFOPs[nCount].Billing_City = Billing_City>
						<cfset stFOPs[nCount].Billing_State = Billing_State>
						<cfset stFOPs[nCount].Billing_Zip = Billing_Zip>
						<cfset stFOPs[nCount].CC_Exclude = 0>
					</cfif>
				</cfif>
			</cfloop>
			<!--- If no personal defaults set, check for not exclusive cards --->
			<cfloop query="qFOPs">
				<cfif CC_UseType NEQ 'Per'>
					<cfset aUses = []>
					<cfif bAirCard EQ 0
					AND ((Air_Use EQ 'E' AND bAirPerCard EQ 0)
						OR (Air_Use NEQ 'E' AND Air_Use NEQ 'N'))>
						<cfset ArrayAppend(aUses, 'A')>
					</cfif>
					<cfif bHotelCard EQ 0
					AND ((Hotel_Use EQ 'E' AND bHotelPerCard EQ 0)
						OR (Hotel_Use NEQ 'E' AND Hotel_Use NEQ 'N'))>
						<cfset ArrayAppend(aUses, 'H')>
					</cfif>
					<cfif bBookitCard EQ 0
					AND ((BookIt_Use EQ 'E' AND bBookitPerCard EQ 0)
						OR (BookIt_Use NEQ 'E' AND BookIt_Use NEQ 'N'))>
						<cfset ArrayAppend(aUses, 'B')>
					</cfif>
					<cfif NOT ArrayIsEmpty(aUses)>
						<cfset nCount++ />
						<cfset stFOPs[nCount].FOP_ID = FOP_ID>
						<cfset stFOPs[nCount].BTA_ID = BTA_ID>
						<cfset stFOPs[nCount].CC_UseType = CC_UseType>
						<cfset stFOPs[nCount].aUses = aUses>
						<cfset stFOPs[nCount].CC_Number = 0>
						<cfset stFOPs[nCount].Billing_Name = Billing_Name>
						<cfset stFOPs[nCount].Billing_Address = Billing_Address>
						<cfset stFOPs[nCount].Billing_City = Billing_City>
						<cfset stFOPs[nCount].Billing_State = Billing_State>
						<cfset stFOPs[nCount].Billing_Zip = Billing_Zip>
						<cfset stFOPs[nCount].CC_Exclude = 0>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn stFOPs />
	</cffunction>
		
<!--- 
encryption
--->
	<cffunction name="encryption" output="false">
		<cfargument name="sString"		default="">
		<cfargument name="sMethod" 		default="Decrypt">

		<cfset local.sString = ''>
		<cfset local.sSecretKey = 'sqIYCnx+1JgtIED5RMrr1w=='>

		<cfif arguments.sString NEQ ''>
			<cfif arguments.sMethod EQ 'Decrypt'>
				<cfset local.oCLS = CreateObject('COM', 'aes.clsDecrypt', 'InProc')>
				<cfset sString = oCLS.Decrypt(sSecretKey, arguments.sString, 256)>
			<cfelse>
				<cfset local.oCLS = CreateObject('COM', 'aes.clsEncrypt', 'InProc')>
				<cfset sString = oCLS.Encrypt(sSecretKey, arguments.sString, 256)>
			</cfif>
			<cfscript>
			ReleaseComObject(oCLS);
			</cfscript>
			<cfset sString = Trim(sString)>
		</cfif>
		
		<cfreturn sString />
	</cffunction>

</cfcomponent>