<cfcomponent output="false">

<!---
init
--->
	<cffunction name="init" output="false">

		<cfreturn this>
	</cffunction>

<!--- 
traveler
--->
	<cffunction name="traveler" output="false" access="remote" returnformat="plain">
		<cfargument name="searchID">
		<cfargument name="userID">
		<cfargument name="nTraveler">
		<cfargument name="bCollapse">

		<cfset local.Traveler = session.searches[arguments.searchID].stTravelers[arguments.nTraveler]>
		<cfset local.acctID = session.AcctID>

		<cfif NOT structKeyExists(Traveler, 'User_ID')
		OR Traveler.User_ID NEQ arguments.userID>
			<cfset Traveler = {}>
			<!--- Preload general information --->
			<cfset Traveler = getGeneralInfo(arguments.userID, acctID)>
			<!--- Setup all frequent account numbers --->
			<cfset Traveler.listFFAccounts = getFFAccounts(arguments.userID)>
			<!--- Add carbon copy email addresses --->
			<cfset Traveler.CCEmail = getCCEmails(arguments.userID)>
			<!--- Get their Value_ID --->
			<cfset Traveler.Value_ID = getValueID(arguments.userID, acctID)><!--- session.searches[SearchID].ValueID --->
			<!--- Get FOPs --->
			<cfset Traveler.listFOPs = getAllFOPs(arguments.userID, Traveler.Value_ID, acctID)>
			<!--- Populate all possible OUs --->
			<cfset Traveler.OUs = getOUs(arguments.userID, Traveler.Value_ID, acctID)>
			<!--- Mark appropriate type --->
			<cfset Traveler.Type = (arguments.userID NEQ 0 ? 'Profiled' : 'Guest')>
			<!---Add profile BAR--->
			<cfset Traveler.BAR = getBAR(acctID, arguments.userID, Traveler.Value_ID, 0)><!---todo account.CBA_AllDepts--->
			<!---Add profile PAR--->
			<cfset Traveler.PAR = getPAR(arguments.userID)>
			<!--- Save the data in the profile --->
			<cfset session.searches[SearchID].stTravelers[nTraveler] = Traveler>
			<cfset session.OrigTraveler[nTraveler] = structCopy(session.searches[SearchID].stTravelers[nTraveler])>
		</cfif>

		<cfset local.qAllOUs = getAllOUs(Traveler.Value_ID, acctID)>
		<cfset local.qAllTravelers = getAllTravelers(session.userID, acctID)>
		<cfset local.sForm = setTravelerForm(Traveler, qAllOUs, qAllTravelers, bCollapse)>

		<cfreturn sForm/>
	</cffunction>

<!---
getTraveler
--->
	<cffunction name="getTraveler" output="false" access="remote" returnformat="plain">
		<cfargument name="searchID">
		<cfargument name="nTraveler">

		<cfset local.stTraveler = {}>
		<cfif StructKeyExists(session.searches[arguments.searchID].stTravelers, arguments.nTraveler)>
			<cfset stTraveler = session.searches[arguments.searchID].stTravelers[arguments.nTraveler]>
		</cfif>

		<cfreturn UCase(serializeJSON(stTraveler))>
	</cffunction>

<!--- 
getUser
--->
	<cffunction name="getGeneralInfo" output="false">
		<cfargument name="userID">
		<cfargument name="acctID">

		<cfset local.Traveler.User_ID = arguments.userID>

		<cfquery name="local.qUser" datasource="Corporate_Production">
		SELECT Users.First_Name, Users.Middle_Name, CASE WHEN Users.NoMiddleName = '' THEN 0 ELSE Users.NoMiddleName END AS NoMiddleName, Users.Last_Name, Personal_Contact_Info.Birthdate, Users.Email, Users.Gender, Biz_Contact_Info.Phone_Number,
		Personal_Contact_Info.Wireless_Phone, CASE WHEN Airline_Prefs.Window_Aisle = 1 THEN 'Window' ELSE 'Aisle' END AS Window_Aisle
		FROM Users, Users_Accounts
		LEFT OUTER JOIN Personal_Contact_Info ON Users_Accounts.User_ID = Personal_Contact_Info.User_ID
		LEFT OUTER JOIN Biz_Contact_Info ON Users_Accounts.User_ID = Biz_Contact_Info.User_ID
		LEFT OUTER JOIN Airline_Prefs ON Users_Accounts.User_ID = Airline_Prefs.User_ID
		WHERE Acct_ID = <cfqueryparam value="#arguments.acctID#" cfsqltype="cf_sql_integer">
		AND Users.User_ID = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer">
		AND Status = <cfqueryparam value="A" cfsqltype="cf_sql_varchar">
		AND Users.User_ID = Users_Accounts.User_ID
		AND Primary_Acct = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfloop list="#qUser.columnList#" index="local.sColumn">
			<cfset Traveler[sColumn] = qUser[sColumn]>
		</cfloop>
		<cfif Traveler.NoMiddleName EQ ''>
			<cfset Traveler.NoMiddleName = 0>
		</cfif>
		<cfset Traveler.BirthdateYear = (isDate(Traveler.Birthdate) ? Year(Traveler.Birthdate) : '')>
		<cfset Traveler.Errors = {}>
		<cfset Traveler.Seats = {}>
		<cfset Traveler.AirFOP.AirFOP_ID = ''>
		<cfset Traveler.AirFOP.Errors = {}>
		<cfset Traveler.Special_Requests = ''>
		<cfset Traveler.Service_Requests = ''>
		<cfset Traveler.Air_ReasonCode = ''>
		<cfset Traveler.LostSavings = ''>

		<cfreturn Traveler />
	</cffunction>


<!--- 
getCCEmails
--->
	<cffunction name="getCCEmails" output="false">
		<cfargument name="userID">

		<cfquery name="local.qCCEmails" datasource="Corporate_Production">
		SELECT DISTINCT CCEmail_Address
		FROM VI_CcEmail
		WHERE User_ID = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfreturn ValueList(qCCEmails.CCEmail_Address, ';') />
	</cffunction>

<!--- 
getValueID
--->
	<cffunction name="getValueID" output="false">
		<cfargument name="userID">
		<cfargument name="acctID">

		<cfquery name="local.qSTOOU" datasource="Corporate_Production">
		SELECT OU_Users.Value_ID
		FROM OU_Users, OUs
		WHERE User_ID = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer">
		AND OUs.Acct_ID = <cfqueryparam value="#arguments.acctID#" cfsqltype="cf_sql_integer">
		AND OU_Users.OU_ID = OUs.OU_ID
		AND OU_Users.Value_ID IS NOT NULL
		AND OU_Users.Value_ID <> <cfqueryparam value="" cfsqltype="cf_sql_varchar">
		AND OUs.OU_STO = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfreturn qSTOOU.Value_ID />
	</cffunction>
	
<!--- 
getOUs
--->
	<cffunction name="getOUs" output="false">
		<cfargument name="userID">
		<cfargument name="valueID">
		<cfargument name="acctID">

		<!--- OU_Users.Value_Report is if the OU is a freeform. OU_Values.Value_Report is if the OU is a dropdown --->
		<cfquery name="local.qAllOUs" datasource="Corporate_Production">
		SELECT OU_Users.OU_ID, OU_Name, OU_Type, OU_Position, OU_Values.Value_ID, Value_Display, OU_Values.Value_Report, CASE WHEN OU_Users.Value_ID IS NOT NULL THEN OU_Values.Value_Report ELSE OU_Users.Value_Report END AS Display_Value
		FROM OUs, OU_Users LEFT OUTER JOIN OU_Values ON OU_Users.Value_ID = OU_Values.Value_ID
		WHERE OUs.OU_ID = OU_Users.OU_ID
		AND OUs.Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		AND OUs.Acct_ID = <cfqueryparam value="#arguments.acctID#" cfsqltype="cf_sql_integer">
		AND User_ID = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer">
		AND (MainOU_ID IS NULL
			<cfif ValueID NEQ ''>
				OR MainValue_ID IN (<cfqueryparam value="#arguments.valueID#" cfsqltype="cf_sql_integer">)
			</cfif>)
		AND OUs.OU_ID NOT IN (<cfqueryparam value="347,348,349" cfsqltype="cf_sql_integer" list="true">)<!--- Custom code for the State of Texas execption codes --->
		<cfif AcctID NEQ 348>
			AND OU_Capture IN (<cfqueryparam value="R,P" cfsqltype="cf_sql_varchar" list="true">)
			AND OU_Type IN (<cfqueryparam value="SORT,UDID" cfsqltype="cf_sql_varchar" list="true">)
		<cfelse>
			AND OUs.OU_ID IN (<cfqueryparam value="399,400,401,402,403" cfsqltype="cf_sql_integer" list="true">)
		</cfif>
		ORDER BY OU_Order
		</cfquery>

		<cfset local.OUs = StructNew('linked')>
		<cfloop query="qAllOUs">
			<cfset OUs[qAllOUs.OU_Type&qAllOUs.OU_Position].OU_Name = OU_Name>
			<cfset OUs[qAllOUs.OU_Type&qAllOUs.OU_Position].Value_ID = Value_ID>
			<cfset OUs[qAllOUs.OU_Type&qAllOUs.OU_Position].Value_Display = Value_Display>
			<cfset OUs[qAllOUs.OU_Type&qAllOUs.OU_Position].Value_Report = Value_Report>
		</cfloop>

		<cfreturn OUs />
	</cffunction>

<!--- 
getAllFOPs
--->
	<cffunction name="getAllFOPs" output="false">
		<cfargument name="userID">
		<cfargument name="valueID">
		<cfargument name="acctID">
		
		<cfquery name="local.qFOPs" datasource="Corporate_Production">
		<!--- Profile credit cards --->
		SELECT FOP_ID, 0 AS BTA_ID, 'Profile' AS CC_UseType, FOP_Code, Acct_Num, Expire_Date, CASE WHEN Air_Use = 1 THEN 'O' ELSE 'N' END AS Air_Use, CASE WHEN Hotel_Use = 1 THEN 'O' ELSE 'N' END AS Hotel_Use, CASE WHEN BookIt_Use = 1 THEN 'O' ELSE 'N' END AS BookIt_Use,
		Billing_Name, Billing_Address, Billing_City, Billing_State, Billing_Zip
		FROM Form_Of_Payment, Users
		WHERE Form_Of_Payment.User_ID = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer">
		AND Form_Of_Payment.User_ID = Users.User_ID
		UNION
		<!--- Account wide credit card --->
		SELECT 0 AS FOP_ID, BTA_ID, 'BTA' AS CC_UseType, FOP_Code, Acct_Num, Expire_Date, BTA_Air AS Air_Use, BTA_Hotel AS Hotel_Use, BTA_BookIt AS BookIt_Use,
		Billing_Name, Billing_Address, Billing_City, Billing_State, Billing_Zip
		FROM BTAs
		WHERE Acct_ID = <cfqueryparam value="#arguments.acctID#" cfsqltype="cf_sql_integer">
		AND Allow_Rules = <cfqueryparam value="0" cfsqltype="cf_sql_integer">
		UNION
		<!--- Department specific credit card by guest traveler --->
		SELECT 0 AS FOP_ID, BTAs.BTA_ID, 'OU' AS CC_UseType, FOP_Code, Acct_Num, Expire_Date, OU_Air AS Air_Use, OU_Hotel AS Hotel_Use, OU_BookIt AS BookIt_Use,
		Billing_Name, Billing_Address, Billing_City, Billing_State, Billing_Zip
		FROM BTAs, OU_BTAs, OU_Values
		WHERE OU_BTAs.Value_ID = <cfqueryparam value="#arguments.valueID#" cfsqltype="cf_sql_integer">
		AND BTAs.BTA_ID = OU_BTAs.BTA_ID
		AND OU_BTAs.Value_ID = OU_Values.Value_ID
		AND OU_Values.Active = 1
		<cfif arguments.acctID EQ 254>
			UNION
			SELECT 0 AS FOP_ID, 0 AS BTA_ID, 'GHOST' AS CC_UseType, '' AS FOP_Code, '' AS Acct_Num, '' AS Expire_Date, 'GHOST' AS CCType, 'O' AS Air_Use, 'N' AS Hotel_Use, 'N' AS BookIt_Use,
			'' AS Billing_Name, '' AS Billing_Address, '' AS Billing_City, '' AS Billing_State, '' AS Billing_Zip
			FROM OU_Values
			WHERE Value_ID = <cfqueryparam value="#arguments.valueID#" cfsqltype="cf_sql_integer">
			AND Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		</cfif>
		ORDER BY FOP_ID, BTA_ID
		</cfquery>

		<cfset local.FOPs = StructNew()>
		<cfset local.Uses = []>
		<cfset local.airCard = 0>
		<cfset local.hotelCard = 0>
		<cfset local.bookitCard = 0>
		<cfset local.airPerCard = 0>
		<cfset local.hotelPerCard = 0>
		<cfset local.bookitPerCard = 0>
		<cfset local.count = 0>
		<!--- 
		Air/car/hotel status key:
			N = Cannot be used
			R = Travelers are REQUIRED to use this card
			E = Travelers may use this card EXCEPT when a personal card is in their profile
			O = Travelers may use this card OR their personal card in their profile
		--->
		<!--- Set general strings as well as exclusive defaults --->
		<cfloop query="qFOPs">
			<cfset Uses = []>
			<cfif qFOPs.Air_Use EQ 'R'>
				<cfset arrayAppend(Uses, 'A')>
				<cfset airCard = 1>
			</cfif>
			<cfif qFOPs.Hotel_Use EQ 'R'>
				<cfset arrayAppend(Uses, 'H')>
				<cfset hotelCard = 1>
			</cfif>
			<cfif qFOPs.BookIt_Use EQ 'R'>
				<cfset arrayAppend(Uses, 'B')>
				<cfset bookitCard = 1>
			</cfif>
			<cfif NOT arrayIsEmpty(Uses)>
				<cfset count++ />
				<cfset FOPs[count].FOP_ID = qFOPs.FOP_ID>
				<cfset FOPs[count].BTA_ID = qFOPs.BTA_ID>
				<cfset FOPs[count].CC_UseType = qFOPs.CC_UseType>
				<cfset FOPs[count].Uses = qFOPs.Uses>
				<cfset FOPs[count].CC_Number = 0>
				<cfset FOPs[count].Billing_Name = qFOPs.Billing_Name>
				<cfset FOPs[count].Billing_Address = qFOPs.Billing_Address>
				<cfset FOPs[count].Billing_City = qFOPs.Billing_City>
				<cfset FOPs[count].Billing_State = qFOPs.Billing_State>
				<cfset FOPs[count].Billing_Zip = qFOPs.Billing_Zip>
				<cfset FOPs[count].CC_Exclude = 1>
			</cfif>
		</cfloop>
		<!--- If no exclusive defaults set, check for personal level uses --->
		<cfif NOT airCard OR NOT hotelCard OR NOT bookitCard>
			<cfloop query="qFOPs">
				<cfif qFOPs.CC_UseType EQ 'Per'>
					<cfset Uses = []>
					<cfif qFOPs.Air_Use NEQ 'N' AND NOT airCard>
						<cfset arrayAppend(Uses, 'A')>
						<cfset airPerCard = 1>
					</cfif>
					<cfif qFOPs.Hotel_Use NEQ 'N' AND NOT hotelCard>
						<cfset arrayAppend(Uses, 'H')>
						<cfset hotelPerCard = 1>
					</cfif>
					<cfif qFOPs.BookIt_Use NEQ 'N' AND NOT bookitCard>
						<cfset arrayAppend(Uses, 'B')>
						<cfset bookitPerCard = 1>
					</cfif>
					<cfif NOT arrayIsEmpty(Uses)>
						<cfset Card_Name = CCName&' - Ending in '&Right(CCNum, 4)>
						<cfset count++ />
						<cfset FOPs[count].FOP_ID = qFOPs.FOP_ID>
						<cfset FOPs[count].BTA_ID = qFOPs.BTA_ID>
						<cfset FOPs[count].CC_UseType = qFOPs.CC_UseType>
						<cfset FOPs[count].Uses = Uses>
						<cfset FOPs[count].CC_Number = 0>
						<cfset FOPs[count].Billing_Name = qFOPs.Billing_Name>
						<cfset FOPs[count].Billing_Address = qFOPs.Billing_Address>
						<cfset FOPs[count].Billing_City = qFOPs.Billing_City>
						<cfset FOPs[count].Billing_State = qFOPs.Billing_State>
						<cfset FOPs[count].Billing_Zip = qFOPs.Billing_Zip>
						<cfset FOPs[count].CC_Exclude = 0>
					</cfif>
				</cfif>
			</cfloop>
			<!--- If no personal defaults set, check for not exclusive cards --->
			<cfloop query="qFOPs">
				<cfif qFOPs.CC_UseType NEQ 'Per'>
					<cfset Uses = []>
					<cfif airCard EQ 0
					AND ((qFOPs.Air_Use EQ 'E' AND airPerCard EQ 0)
						OR (qFOPs.Air_Use NEQ 'E' AND qFOPs.Air_Use NEQ 'N'))>
						<cfset ArrayAppend(Uses, 'A')>
					</cfif>
					<cfif hotelCard EQ 0
					AND ((qFOPs.Hotel_Use EQ 'E' AND hotelPerCard EQ 0)
						OR (qFOPs.Hotel_Use NEQ 'E' AND qFOPs.Hotel_Use NEQ 'N'))>
						<cfset ArrayAppend(Uses, 'H')>
					</cfif>
					<cfif bookitCard EQ 0
					AND ((qFOPs.BookIt_Use EQ 'E' AND bookitPerCard EQ 0)
						OR (qFOPs.BookIt_Use NEQ 'E' AND qFOPs.BookIt_Use NEQ 'N'))>
						<cfset ArrayAppend(Uses, 'B')>
					</cfif>
					<cfif NOT ArrayIsEmpty(Uses)>
						<cfset count++ />
						<cfset FOPs[count].FOP_ID = qFOPs.FOP_ID>
						<cfset FOPs[count].BTA_ID = qFOPs.BTA_ID>
						<cfset FOPs[count].CC_UseType = qFOPs.CC_UseType>
						<cfset FOPs[count].Uses = Uses>
						<cfset FOPs[count].CC_Number = 0>
						<cfset FOPs[count].Billing_Name = qFOPs.Billing_Name>
						<cfset FOPs[count].Billing_Address = qFOPs.Billing_Address>
						<cfset FOPs[count].Billing_City = qFOPs.Billing_City>
						<cfset FOPs[count].Billing_State = qFOPs.Billing_State>
						<cfset FOPs[count].Billing_Zip = qFOPs.Billing_Zip>
						<cfset FOPs[count].CC_Exclude = 0>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn FOPs />
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
	
</cfcomponent>