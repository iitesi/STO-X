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

		<cfif NOT structKeyExists(local.traveler, 'User_ID')
		OR local.traveler.User_ID NEQ arguments.userID>
			<cfset local.traveler = {}>
			<!--- Preload general information --->
			<cfset local.Traveler = getGeneralInfo(arguments.userID, acctID)>
			<!--- Setup all frequent account numbers --->
			<cfset local.Traveler.listFFAccounts = getFFAccounts(arguments.userID)>
			<!--- Add carbon copy email addresses --->
			<cfset local.Traveler.CCEmail = getCCEmails(arguments.userID)>
			<!--- Get their Value_ID --->
			<cfset local.Traveler.Value_ID = getValueID(arguments.userID, acctID)><!--- session.searches[SearchID].ValueID --->
			<!--- Get FOPs --->
			<cfset local.Traveler.listFOPs = getAllFOPs(arguments.userID, local.Traveler.Value_ID, acctID)>
			<!--- Populate all possible OUs --->
			<cfset local.Traveler.OUs = getOUs(arguments.userID, local.Traveler.Value_ID, acctID)>
			<!--- Mark appropriate type --->
			<cfset local.Traveler.Type = (arguments.userID NEQ 0 ? 'Profiled' : 'Guest')>
			<!---Add profile BAR--->
			<cfset local.Traveler.BAR = getBAR(acctID, arguments.userID, local.Traveler.Value_ID, 0)><!---todo account.CBA_AllDepts--->
			<!---Add profile PAR--->
			<cfset local.Traveler.PAR = getPAR(arguments.userID)>
			<!--- Save the data in the profile --->
			<cfset session.searches[SearchID].stTravelers[arguments.nTraveler] = local.Traveler>
			<cfset session.OrigTraveler[arguments.nTraveler] = structCopy(session.searches[SearchID].stTravelers[arguments.nTraveler])>
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
			<cfset local.stTraveler = session.searches[arguments.searchID].stTravelers[arguments.nTraveler]>
		</cfif>

		<cfreturn UCase(serializeJSON(local.stTraveler))>
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

		<cfloop list="#local.qUser.columnList#" index="local.sColumn">
			<cfset local.traveler[local.sColumn] = local.qUser[local.sColumn]>
		</cfloop>
		<cfif local.traveler.NoMiddleName EQ ''>
			<cfset local.traveler.NoMiddleName = 0>
		</cfif>
		<cfset local.traveler.BirthdateYear = (isDate(local.traveler.Birthdate) ? Year(local.traveler.Birthdate) : '')>
		<cfset local.traveler.Errors = {}>
		<cfset local.traveler.Seats = {}>
		<cfset local.traveler.AirFOP.AirFOP_ID = ''>
		<cfset local.traveler.AirFOP.Errors = {}>
		<cfset local.traveler.Special_Requests = ''>
		<cfset local.traveler.Service_Requests = ''>
		<cfset local.traveler.Air_ReasonCode = ''>
		<cfset local.traveler.LostSavings = ''>

		<cfreturn local.traveler />
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
		<cfloop query="local.qAllOUs">
			<cfset local.OUs[local.qAllOUs.OU_Type&local.qAllOUs.OU_Position].OU_Name = OU_Name>
			<cfset local.OUs[local.qAllOUs.OU_Type&local.qAllOUs.OU_Position].Value_ID = Value_ID>
			<cfset local.OUs[local.qAllOUs.OU_Type&local.qAllOUs.OU_Position].Value_Display = Value_Display>
			<cfset local.OUs[local.qAllOUs.OU_Type&local.qAllOUs.OU_Position].Value_Report = Value_Report>
		</cfloop>

		<cfreturn local.OUs />
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
		<cfloop query="local.qFOPs">
			<cfset local.Uses = []>
			<cfif local.qFOPs.Air_Use EQ 'R'>
				<cfset arrayAppend(local.Uses, 'A')>
				<cfset local.airCard = 1>
			</cfif>
			<cfif local.qFOPs.Hotel_Use EQ 'R'>
				<cfset arrayAppend(local.Uses, 'H')>
				<cfset local.hotelCard = 1>
			</cfif>
			<cfif local.qFOPs.BookIt_Use EQ 'R'>
				<cfset arrayAppend(local.Uses, 'B')>
				<cfset local.bookitCard = 1>
			</cfif>
			<cfif NOT arrayIsEmpty(local.Uses)>
				<cfset local.count++ />
				<cfset local.FOPs[local.count].FOP_ID = local.qFOPs.FOP_ID>
				<cfset local.FOPs[local.count].BTA_ID = local.qFOPs.BTA_ID>
				<cfset local.FOPs[local.count].CC_UseType = local.qFOPs.CC_UseType>
				<cfset local.FOPs[local.count].Uses = local.qFOPs.Uses>
				<cfset local.FOPs[local.count].CC_Number = 0>
				<cfset local.FOPs[local.count].Billing_Name = local.qFOPs.Billing_Name>
				<cfset local.FOPs[local.count].Billing_Address = local.qFOPs.Billing_Address>
				<cfset local.FOPs[local.count].Billing_City = local.qFOPs.Billing_City>
				<cfset local.FOPs[local.count].Billing_State = local.qFOPs.Billing_State>
				<cfset local.FOPs[local.count].Billing_Zip = local.qFOPs.Billing_Zip>
				<cfset local.FOPs[local.count].CC_Exclude = 1>
			</cfif>
		</cfloop>
		<!--- If no exclusive defaults set, check for personal level uses --->
		<cfif NOT local.airCard OR NOT local.hotelCard OR NOT local.bookitCard>
			<cfloop query="local.qFOPs">
				<cfif local.qFOPs.CC_UseType EQ 'Per'>
					<cfset local.Uses = []>
					<cfif local.qFOPs.Air_Use NEQ 'N' AND NOT local.airCard>
						<cfset arrayAppend(local.Uses, 'A')>
						<cfset local.airPerCard = 1>
					</cfif>
					<cfif local.qFOPs.Hotel_Use NEQ 'N' AND NOT local.hotelCard>
						<cfset arrayAppend(local.Uses, 'H')>
						<cfset local.hotelPerCard = 1>
					</cfif>
					<cfif local.qFOPs.BookIt_Use NEQ 'N' AND NOT local.bookitCard>
						<cfset arrayAppend(local.Uses, 'B')>
						<cfset local.bookitPerCard = 1>
					</cfif>
					<cfif NOT arrayIsEmpty(local.Uses)>
						<cfset local.Card_Name = local.CCName&' - Ending in '&Right(local.CCNum, 4)>
						<cfset local.count++ />
						<cfset local.FOPs[count].FOP_ID = local.qFOPs.FOP_ID>
						<cfset local.FOPs[count].BTA_ID = local.qFOPs.BTA_ID>
						<cfset local.FOPs[count].CC_UseType = local.qFOPs.CC_UseType>
						<cfset local.FOPs[count].Uses = local.Uses>
						<cfset local.FOPs[count].CC_Number = 0>
						<cfset local.FOPs[count].Billing_Name = local.qFOPs.Billing_Name>
						<cfset local.FOPs[count].Billing_Address = local.qFOPs.Billing_Address>
						<cfset local.FOPs[count].Billing_City = local.qFOPs.Billing_City>
						<cfset local.FOPs[count].Billing_State = local.qFOPs.Billing_State>
						<cfset local.FOPs[count].Billing_Zip = local.qFOPs.Billing_Zip>
						<cfset local.FOPs[count].CC_Exclude = 0>
					</cfif>
				</cfif>
			</cfloop>
			<!--- If no personal defaults set, check for not exclusive cards --->
			<cfloop query="local.qFOPs">
				<cfif local.qFOPs.CC_UseType NEQ 'Per'>
					<cfset local.Uses = []>
					<cfif local.airCard EQ 0
					AND ((local.qFOPs.Air_Use EQ 'E' AND local.airPerCard EQ 0)
						OR (local.qFOPs.Air_Use NEQ 'E' AND local.qFOPs.Air_Use NEQ 'N'))>
						<cfset ArrayAppend(local.Uses, 'A')>
					</cfif>
					<cfif local.hotelCard EQ 0
					AND ((local.qFOPs.Hotel_Use EQ 'E' AND local.hotelPerCard EQ 0)
						OR (local.qFOPs.Hotel_Use NEQ 'E' AND local.qFOPs.Hotel_Use NEQ 'N'))>
						<cfset ArrayAppend(local.Uses, 'H')>
					</cfif>
					<cfif local.bookitCard EQ 0
					AND ((local.qFOPs.BookIt_Use EQ 'E' AND local.bookitPerCard EQ 0)
						OR (local.qFOPs.BookIt_Use NEQ 'E' AND local.qFOPs.BookIt_Use NEQ 'N'))>
						<cfset ArrayAppend(local.Uses, 'B')>
					</cfif>
					<cfif NOT ArrayIsEmpty(local.Uses)>
						<cfset local.count++ />
						<cfset local.FOPs[local.count].FOP_ID = local.qFOPs.FOP_ID>
						<cfset local.FOPs[local.count].BTA_ID = local.qFOPs.BTA_ID>
						<cfset local.FOPs[local.count].CC_UseType = local.qFOPs.CC_UseType>
						<cfset local.FOPs[local.count].Uses = local.Uses>
						<cfset local.FOPs[local.count].CC_Number = 0>
						<cfset local.FOPs[local.count].Billing_Name = local.qFOPs.Billing_Name>
						<cfset local.FOPs[local.count].Billing_Address = local.qFOPs.Billing_Address>
						<cfset local.FOPs[local.count].Billing_City = local.qFOPs.Billing_City>
						<cfset local.FOPs[local.count].Billing_State = local.qFOPs.Billing_State>
						<cfset local.FOPs[local.count].Billing_Zip = local.qFOPs.Billing_Zip>
						<cfset local.FOPs[local.count].CC_Exclude = 0>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn local.FOPs />
	</cffunction>

<!---
getOUs
--->
	<cffunction name="getAllOUs" output="false">
		<cfargument name="valueID">
		<cfargument name="acctID">

		<cfquery name="local.qAllOUs" datasource="Corporate_Production" cachedwithin="#createTime(0,24,0,0)#">
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

		<cfreturn local.qAllOUs>
	</cffunction>

<!---
setTravelerForm
<!--- --->
	<cffunction name="setTravelerForm" output="false" access="remote" returnformat="plain">
		<cfargument name="Traveler">
		<cfargument name="qAllOUs">
		<cfargument name="qAllTravelers">
		<cfargument name="bCollapse">

		<cfset local.bFormShown = false>
		<cfset local.bCollapse = arguments.bCollapse>
		<cfif Traveler.User_ID EQ 0>
			<cfset local.bCollapse = false>
		</cfif>
		<cfsavecontent variable="local.sForm">
			<cfoutput>
				<table width="500" height="290">
				<tr height="23">
					<td colspan="2" class="underline-heading"> <h2>Traveler</h2></td>
				</tr>
				<tr height="23">
					<td>
						<label for="User_ID">Change Traveler</label>
					</td>
					<td>
						<select name="User_ID" id="User_ID" onChange="changeTraveler(#nTraveler#);">
						<option value="">SELECT A TRAVELER</option>
						<option value="0" <cfif Traveler.User_ID EQ 0>selected</cfif>>GUEST TRAVELER</option>
						<cfloop query="arguments.qAllTravelers">
							<option value="#arguments.qAllTravelers.User_ID#" <cfif Traveler.User_ID EQ arguments.qAllTravelers.User_ID>selected</cfif>>#arguments.qAllTravelers.Last_Name#/#arguments.qAllTravelers.First_Name# #arguments.qAllTravelers.Middle_Name#</option>
						</cfloop>
						</select>
					</td>
				</tr>
				<cfset local.bNameFilledOutProperly = false>
				<cfif Traveler.Type EQ 'Profiled'
				AND Traveler.First_Name NEQ ''
				AND Traveler.Last_Name NEQ ''
				AND (Traveler.Middle_Name NEQ '' OR Traveler.NoMiddleName)>
					<cfset local.bNameFilledOutProperly = true>
				</cfif>
				<cfif NOT local.bNameFilledOutProperly>
					<tr height="23">
						<td>
							<label for="First_Name" class="#(structKeyExists(Traveler.Errors, 'First_Name') ? 'error' : '')#">First Name</label>
						</td>
						<td>
							<cfif (bCollapse AND Traveler.First_Name NEQ '') OR Traveler.Type EQ 'Profiled'>
								#Traveler.First_Name#
								<input type="hidden" name="First_Name" id="First_Name" value="#Traveler.First_Name#">
							<cfelse>
								<input type="text" name="First_Name" id="First_Name" value="#Traveler.First_Name#">
								<cfset local.bFormShown = true>
							</cfif>
						</td>
					</tr>
					<tr height="23">
						<td>
							<label for="Middle_Name" class="#(structKeyExists(Traveler.Errors, 'Middle_Name') ? 'error' : '')#">Middle Name</label>
						</td>
						<td>
							<cfif (bCollapse AND (Traveler.Middle_Name NEQ '' OR Traveler.NoMiddleName))
							OR (Traveler.Type EQ 'Profiled' AND (Traveler.Middle_Name NEQ '' OR Traveler.NoMiddleName))>
								#Traveler.Middle_Name# <cfif Traveler.NoMiddleName><em>No middle name</em></cfif>
								<input type="hidden" name="Middle_Name" id="Middle_Name" value="#Traveler.Middle_Name#">
							<cfelse>
								<input type="text" name="Middle_Name" id="Middle_Name" value="#Traveler.Middle_Name#">
								<input type="checkbox" name="NoMiddleName" value="1" <cfif Traveler.NoMiddleName>checked</cfif>>
								No middle name
								<cfset local.bFormShown = true>
							</cfif>
						</td>
					</tr>
					<tr height="23">
						<td>
							<label for="Last_Name" class="#(structKeyExists(Traveler.Errors, 'Last_Name') ? 'error' : '')#">Last Name</label>
						</td>
						<td>
							<cfif (bCollapse AND Traveler.Last_Name NEQ '') OR Traveler.Type EQ 'Profiled'>
								#Traveler.Last_Name#
								<input type="hidden" name="Last_Name" id="Last_Name" value="#Traveler.Last_Name#">
							<cfelse>
								<input type="text" name="Last_Name" id="Last_Name" value="#Traveler.Last_Name#">
								<cfset local.bFormShown = true>
							</cfif>
						</td>
					</tr>
				<cfelse>
					<input type="hidden" name="First_Name" value="#Traveler.First_Name#">
					<input type="hidden" name="Middle_Name" value="#Traveler.Middle_Name#">
					<input type="hidden" name="NoMiddleName" value="#Traveler.NoMiddleName#">
					<input type="hidden" name="Last_Name" value="#Traveler.Last_Name#">
				</cfif>
				<tr height="23">
					<td>
						<label for="Phone_Number" class="#(structKeyExists(Traveler.Errors, 'Phone_Number') ? 'error' : '')#">Business Phone</label>
					</td>
					<td>
						<cfif bCollapse AND Traveler.Phone_Number NEQ ''>
							#Traveler.Phone_Number#
							<input type="hidden" name="Phone_Number" id="Phone_Number" value="#Traveler.Phone_Number#">
						<cfelse>
							<input type="text" name="Phone_Number" id="Phone_Number" value="#Traveler.Phone_Number#">
							<cfset local.bFormShown = true>
						</cfif>
					</td>
				</tr>
				<tr height="23">
					<td>
						<label for="Wireless_Phone" class="#(structKeyExists(Traveler.Errors, 'Wireless_Phone') ? 'error' : '')#">Wireless Phone</label>
					</td>
					<td>
						<cfif bCollapse AND Traveler.Wireless_Phone NEQ ''>
							#Traveler.Wireless_Phone#
							<input type="hidden" name="Wireless_Phone" id="Wireless_Phone" value="#Traveler.Wireless_Phone#">
						<cfelse>
							<input type="text" name="Wireless_Phone" id="Wireless_Phone" value="#Traveler.Wireless_Phone#">
							<cfset local.bFormShown = true>
						</cfif>
					</td>
				</tr>
				<tr height="23">
					<td>
						<label for="Email" class="#(structKeyExists(Traveler.Errors, 'Email') ? 'error' : '')#">Email</label>
					</td>
					<td>
						<cfif bCollapse AND Traveler.Email NEQ ''>
							#Traveler.Email#
							<input type="hidden" name="Email" id="Email" value="#Traveler.Email#">
						<cfelse>
							<input type="text" name="Email" id="Email" value="#Traveler.Email#" size="50">
							<cfset local.bFormShown = true>
						</cfif>
					</td>
				</tr>
				<tr height="23">
					<td>
						<label for="CCEmail" class="#(structKeyExists(Traveler.Errors, 'CCEmail') ? 'error' : '')#">CC Emails</label>
					</td>
					<td>
						<cfif bCollapse AND Traveler.CCEmail NEQ ''>
							#Traveler.CCEmail#
							<input type="hidden" name="CCEmail" id="CCEmail" value="#Traveler.CCEmail#">
						<cfelse>
							<input type="text" name="CCEmail" id="CCEmail" value="#Traveler.CCEmail#" size="50">
							<cfset local.bFormShown = true>
						</cfif>
					</td>
				</tr>
				<tr height="23">
					<td>
						<label for="Month" class="#(structKeyExists(Traveler.Errors, 'Birthday') ? 'error' : '')#">Birthday</label>
					</td>
					<td>
						<cfif bCollapse AND IsDate(Traveler.Birthdate)>
							#DateFormat(Traveler.Birthdate, 'm/d/****')#
							<input type="hidden" name="Month" id="Month" value="#Month(Traveler.Birthdate)#">
							<input type="hidden" name="Day" id="Month" value="#Day(Traveler.Birthdate)#">
							<input type="hidden" name="Year" id="Year" value="#Year(Traveler.Birthdate)#">
						<cfelse>
							<select name="Month" id="Month">
							<option value=""></option>
							<cfloop from="1" to="12" index="local.i">
								<option value="#local.i#" <cfif IsDate(Traveler.Birthdate) AND Month(Traveler.Birthdate) EQ local.i>selected</cfif>>#MonthAsString(local.i)#</option>
							</cfloop>
							</select>
							<select name="Day">
							<option value=""></option>
							<cfloop from="1" to="31" index="local.i">
								<option value="#local.i#" <cfif IsDate(Traveler.Birthdate) AND Day(Traveler.Birthdate) EQ local.i>selected</cfif>>#local.i#</option>
							</cfloop>
							</select>
							<select name="Year">
							<option value=""></option>
							<cfif IsDate(Traveler.Birthdate) AND Traveler.User_ID NEQ 0>
								<option value="****" selected>****</option>
							</cfif>
							<cfloop from="#Year(Now())#" to="#Year(Now())-100#" step="-1" index="local.i">
								<option value="#local.i#" <cfif IsDate(Traveler.Birthdate) AND Traveler.User_ID EQ 0 AND Year(Traveler.Birthdate) EQ i>selected</cfif>>#local.i#</option>
							</cfloop>
							</select>
							<cfset local.bFormShown = true>
						</cfif>
					</td>
				</tr>
				<tr height="23">
					<td>
						<label for="Gender" class="#(structKeyExists(Traveler.Errors, 'Gender') ? 'error' : '')#">Gender</label>
					</td>
					<td>
						<cfif bCollapse AND Traveler.Gender NEQ ''>
							#(Traveler.Gender EQ 'F' ? 'Female' : 'Male')#
							<input type="hidden" name="Gender" id="Gender" value="#Traveler.Gender#">
						<cfelse>
							<select name="Gender" id="Gender">
							<option value=""></option>
							<option value="M" <cfif Traveler.Gender EQ 'M'>selected</cfif>>Male</option>
							<option value="F" <cfif Traveler.Gender EQ 'F'>selected</cfif>>Female</option>
							</select>
							<cfset local.bFormShown = true>
						</cfif>
					</td>
				</tr>
				<!--- <cfdump var="#Traveler.OUs#"> --->
				<cfoutput query="qAllOUs" group="OU_ID">
					<tr height="23">
						<td>
							<label for="#qAllOUs.OU_Type##qAllOUs.OU_Position#" class="#(structKeyExists(Traveler.Errors, qAllOUs.OU_Type&qAllOUs.OU_Position) ? 'error' : '')#">#qAllOUs.OU_Name#</label><!--- Sort1 OR UDID55 --->
						</td>
						<td>
							<cfif bCollapse AND StructKeyExists(Traveler.OUs, qAllOUs.OU_ID) AND Traveler.OUs[qAllOUs.OU_ID].Value_ID NEQ ''>
								#Traveler.OUs[qAllOUs.OU_ID].Value_Display#
								<input type="hidden" name="#qAllOUs.OU_Type##qAllOUs.OU_Position#" id="#qAllOUs.OU_Type##qAllOUs.OU_Position#" value="#Traveler.OUs[qAllOUs.OU_Type&qAllOUs.OU_Position].Value_ID#">
							<cfelse>
								<cfif qAllOUs.OU_Freeform>
									<input type="text" name="#qAllOUs.OU_Type##qAllOUs.OU_Position#" id="#qAllOUs.OU_Type##qAllOUs.OU_Position#" <cfif StructKeyExists(Traveler.OUs, qAllOUs.OU_Type&qAllOUs.OU_Position)>value="#Traveler.OUs[qAllOUs.OU_Type&qAllOUs.OU_Position].Value_ID#"</cfif> size="#(qAllOUs.OU_Max GT 20 ? 20 : qAllOUs.OU_Max+1)#" maxlength="#qAllOUs.OU_Max#">
								<cfelse>
									<select name="#qAllOUs.OU_Type##qAllOUs.OU_Position#" id="#qAllOUs.OU_Type##qAllOUs.OU_Position#">
									<option value=""></option>
									<cfoutput>
										<option value="#qAllOUs.Value_Report#" <cfif StructKeyExists(Traveler.OUs, qAllOUs.OU_Type&qAllOUs.OU_Position) AND Traveler.OUs[qAllOUs.OU_Type&qAllOUs.OU_Position].Value_Report EQ qAllOUs.Value_Report>selected</cfif>>#qAllOUs.Value_Display#</option>
									</cfoutput>
									</select>
								</cfif>
								<cfset local.bFormShown = true>
							</cfif>
						</td>
					</tr>
					<input type="hidden" name="#qAllOUs.OU_Type##qAllOUs.OU_Position#_Required" value="#qAllOUs.OU_Required#">
				</cfoutput>
				<cfif Traveler.Type EQ 'Profiled' AND bFormShown>
					<tr height="23">
						<td colspan="2" align="right">
							<input type="checkbox" name="bSaveChanges" value="1" checked> Save changes to profile
						</td>
					</tr>
				</cfif>
				<cfif bCollapse AND Traveler.Type EQ 'Profiled'>
					<tr height="23">
						<td colspan="2">
							<a href="##" onClick="setTravelerForm(#nTraveler#, 0);">Edit All Traveler Information</a>
						</td>
					</tr>
				</cfif>
				</table>
				<!--- <cfdump var="#Traveler#"> --->
			</cfoutput>
		</cfsavecontent>

		<cfreturn serializeJSON(sForm)>
	</cffunction>
 --->
</cfcomponent>