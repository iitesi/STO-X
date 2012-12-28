<cfcomponent output="false">

<!---
getUser
--->
	<cffunction name="getUser" access="remote" output="false">
		<cfargument name="nSearchID"	default="#url.Search_ID#">
		<cfargument name="Acct_ID" 		default="#session.Acct_ID#">
		<cfargument name="User_ID" 		default="#session.searches[url.Search_ID].nProfileID#">
		<cfargument name="nTraveler" 	default="1">

		<cfset local.stTravelers = session.searches[arguments.nSearchID].stTravelers>
		<!--- <cfset local.stTravelers = {}> --->

		<cfif IsNumeric(arguments.User_ID)
		AND (NOT StructKeyExists(stTravelers, arguments.nTraveler)
			OR stTravelers[arguments.nTraveler].User_ID NEQ arguments.User_ID)>
			<!--- Preload general information --->
			<cfquery name="local.qUser" datasource="Corporate_Production">
			SELECT Users.First_Name, Users.Middle_Name, Users.NoMiddleName, Users.Last_Name, Personal_Contact_Info.Birthdate, Users.Email, Users.Gender, Biz_Contact_Info.Phone_Number, Personal_Contact_Info.Wireless_Phone, CASE WHEN Airline_Prefs.Window_Aisle = 1 THEN 'W' ELSE 'A' END AS Window_Aisle
			FROM Users, Users_Accounts
			LEFT OUTER JOIN Personal_Contact_Info ON Users_Accounts.User_ID = Personal_Contact_Info.User_ID
			LEFT OUTER JOIN Biz_Contact_Info ON Users_Accounts.User_ID = Biz_Contact_Info.User_ID
			LEFT OUTER JOIN Airline_Prefs ON Users_Accounts.User_ID = Airline_Prefs.User_ID
			WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
			AND Users.User_ID = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_integer">
			AND Status = <cfqueryparam value="A" cfsqltype="cf_sql_varchar">
			AND Users.User_ID = Users_Accounts.User_ID
			AND Primary_Acct = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfset stTravelers[arguments.nTraveler].User_ID = arguments.User_ID>
			<cfloop list="#qUser.columnList#" index="local.sColumn">
				<cfset stTravelers[arguments.nTraveler][sColumn] = qUser[sColumn]>
			</cfloop>

			<!--- Setup all frequent account numbers --->
			<cfquery name="local.qFFAccounts" datasource="Corporate_Production">
			SELECT ShortCode, CustType, Name, Acct_Num
			FROM MP_Accts, Suppliers
			WHERE User_ID = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_integer">
			AND MP_Accts.Supplier = Suppliers.AccountID
			ORDER BY CustType, Name
			</cfquery>
			<cfloop query="qFFAccounts">
				<cfset stTravelers[arguments.nTraveler].stFFAccounts[CustType][ShortCode] = qFFAccounts.Acct_Num>
			</cfloop>

			<!--- Add carbon copy email addresses --->
			<cfquery name="local.qCCEmails" datasource="Corporate_Production">
			SELECT DISTINCT CCEmail_Address
			FROM VI_CcEmail
			WHERE User_ID = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfset stTravelers[arguments.nTraveler].CCEmail = ValueList(qCCEmails.CCEmail_Address, ';')>

			<!--- Get their Value_ID --->
			<cfquery name="local.qSTOOU" datasource="Corporate_Production">
			SELECT OU_Users.Value_ID
			FROM OU_Users, OUs
			WHERE User_ID = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_integer">
			AND OUs.Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
			AND OU_Users.OU_ID = OUs.OU_ID
			AND OU_Users.Value_ID IS NOT NULL
			AND OU_Users.Value_ID <> <cfqueryparam value="" cfsqltype="cf_sql_varchar">
			AND OUs.OU_STO = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfset stTravelers[arguments.nTraveler].Value_ID = qSTOOU.Value_ID>

			<!--- Populate the org units --->
			<!--- OU_Users.Value_Report is if the OU is a freeform. OU_Values.Value_Report is if the OU is a dropdown --->
			<cfquery name="local.qOUs" datasource="Corporate_Production">
			SELECT OU_Users.OU_ID, OU_Name, OU_Values.Value_ID, Value_Display, OU_Values.Value_Report, CASE WHEN OU_Users.Value_ID IS NOT NULL THEN OU_Values.Value_Report ELSE OU_Users.Value_Report END AS Display_Value
			FROM OUs, OU_Users LEFT OUTER JOIN OU_Values ON OU_Users.Value_ID = OU_Values.Value_ID
			WHERE OUs.OU_ID = OU_Users.OU_ID
			AND OUs.Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			AND OUs.Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
			AND User_ID = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_integer">
			AND (MainOU_ID IS NULL
				<cfif stTravelers[arguments.nTraveler].Value_ID NEQ ''>
					OR MainValue_ID IN (<cfqueryparam value="#stTravelers[arguments.nTraveler].Value_ID#" cfsqltype="cf_sql_integer">)
				</cfif>)
			AND OUs.OU_ID NOT IN (<cfqueryparam value="347,348,349" cfsqltype="cf_sql_integer" list="true">)<!--- Custom code for the State of Texas execption codes --->
			<cfif arguments.Acct_ID NEQ 348>
				AND OU_Capture IN (<cfqueryparam value="R,P" cfsqltype="cf_sql_varchar" list="true">)
				AND OU_Type IN (<cfqueryparam value="SORT,UDID" cfsqltype="cf_sql_varchar" list="true">)
			<cfelse>
				AND OUs.OU_ID IN (<cfqueryparam value="399,400,401,402,403" cfsqltype="cf_sql_integer" list="true">)
			</cfif>
			ORDER BY OU_Order
			</cfquery>
			<cfset stTravelers[arguments.nTraveler].stOUs = StructNew('linked')>
			<cfloop query="qOUs">
				<cfset stTravelers[arguments.nTraveler].stOUs[OU_ID].OU_Name = OU_Name>
				<cfset stTravelers[arguments.nTraveler].stOUs[OU_ID].Value_ID = Value_ID>
				<cfset stTravelers[arguments.nTraveler].stOUs[OU_ID].Value_Display = Value_Display>
				<cfset stTravelers[arguments.nTraveler].stOUs[OU_ID].Value_Report = Value_Report>
			</cfloop>

			<cfset stTravelers[arguments.nTraveler].stFOPs = getFOPs(arguments.User_ID, qSTOOU.Value_ID)>

			<!--- Mark appropriate type --->
			<cfset stTravelers[arguments.nTraveler].Type = (arguments.User_ID NEQ 0 ? 'Profiled' : 'Guest')>
			
		</cfif>
		
		<cfset session.searches[arguments.nSearchID].stTravelers = stTravelers>

		<cfreturn >
	</cffunction>

<!---
saveTraveler
--->
	<cffunction name="saveTraveler" output="false" access="remote" returnformat="plain">
		<cfargument name="nSearchID">
		<cfargument name="nTraveler">
		<cfargument name="nUserID">
		<cfargument name="First_Name">
		<cfargument name="Middle_Name">
		<cfargument name="Last_Name">
		<cfargument name="Phone_Number">
		<cfargument name="Wireless_Phone">
		<cfargument name="Email">
		<cfargument name="CCEmail">
		<cfargument name="Month">
		<cfargument name="Day">
		<cfargument name="Year">
		<cfargument name="Gender">
		
		<!--- Set local scope --->
		<cfset local.stTravelers = session.searches[arguments.nSearchID].stTravelers>
		
		<!--- Add data to the local scope --->
		<cfset stTravelers[arguments.nTraveler].First_Name = (arguments.First_Name NEQ '' ? arguments.First_Name : stTravelers[arguments.nTraveler].First_Name)>
		<cfset stTravelers[arguments.nTraveler].Middle_Name = (arguments.Middle_Name NEQ '' ? arguments.Middle_Name : stTravelers[arguments.nTraveler].Middle_Name)>
		<cfset stTravelers[arguments.nTraveler].Last_Name = (arguments.Last_Name NEQ '' ? arguments.Last_Name : stTravelers[arguments.nTraveler].Last_Name)>
		<cfset stTravelers[arguments.nTraveler].Phone_Number = arguments.Phone_Number>
		<cfset stTravelers[arguments.nTraveler].Wireless_Phone = arguments.Wireless_Phone>
		<cfset stTravelers[arguments.nTraveler].Email = arguments.Email>
		<cfset stTravelers[arguments.nTraveler].CCEmail = arguments.CCEmail>
		<!--- <cfset stTravelers[arguments.nTraveler].Birthdate = CreateDate(arguments.Year, arguments.Month, arguments.Day)> --->
		<cfset stTravelers[arguments.nTraveler].Gender = arguments.Gender>

		<!--- Move local scope to the session scope --->
		<cfset session.searches[arguments.nSearchID].stTravelers = stTravelers>
		
		<!--- Put together the display HTML for the summary --->
		<cfset local.sSummary = showTravelerSummary(arguments.nSearchID, arguments.nTraveler)>

		<cfreturn sSummary>
	</cffunction>

<!---
showTravelerSummary
--->
	<cffunction name="showTravelerSummary" output="false" access="remote" returnformat="plain">
		<cfargument name="nSearchID">
		<cfargument name="nTraveler">
		
		<cfset local.stTraveler = (StructKeyExists(session.searches[arguments.nSearchID].stTravelers, arguments.nTraveler) ? session.searches[arguments.nSearchID].stTravelers[arguments.nTraveler] : {})>
		
		<cfsavecontent variable="local.sSummary">
			<cfoutput>
				<cfif NOT StructIsEmpty(stTraveler)>
					<table width="400">
					<tr>
						<td colspan="2"><h2>#stTraveler.Last_Name#/#stTraveler.First_Name# #stTraveler.Middle_Name#</h2>
						<a href="##" onClick="showForm(#arguments.nTraveler#);" style="float:right">edit</a></td>
					</tr>
					<tr>
						<td>Business</td>
						<td>#stTraveler.Phone_Number#</td>
					</tr>
					<tr>
						<td>Wireless</td>
						<td>#stTraveler.Wireless_Phone#</td>
					</tr>
					<tr>
						<td>Email</td>
						<td>#stTraveler.Email#</td>
					</tr>
					<tr>
						<td>CC Email</td>
						<td>#Replace(stTraveler.CCEmail, ',', ' ', 'ALL')#</td>
					</tr>
					<tr>
						<td>DOB</td>
						<td>#DateFormat(stTraveler.Birthdate, 'mmmm d, yyyy')#</td>
					</tr>
					<tr>
						<td>Gender</td>
						<td>#(stTraveler.Gender EQ 'F' ? 'Female' : 'Male')#</td>
					</tr>
					<cfloop collection="#stTraveler.stOUs#" index="nOU_ID">
						<tr>
							<td>#stTraveler.stOUs[nOU_ID].OU_Name#</td>
							<td>#stTraveler.stOUs[nOU_ID].Value_Display#</td>
						</tr>
					</cfloop>
					</table>
				<cfelse>
					<a href="##" onClick="showForm(#arguments.nTraveler#);" style="float:right">+ Add Traveler</a>
				</cfif>
			</cfoutput>
		</cfsavecontent>

		<cfreturn serializeJSON(sSummary)>
	</cffunction>

<!---
setTravelerForm
--->
	<cffunction name="setTravelerForm" output="false" access="remote" returnformat="plain">
		<cfargument name="nSearchID">
		<cfargument name="nTraveler">
		
		<cfif structKeyExists(session.searches[arguments.nSearchID].stTravelers, arguments.nTraveler)>
			<cfset local.stTraveler = session.searches[arguments.nSearchID].stTravelers[arguments.nTraveler]>
			<cfset local.qOUs = getOUs(stTraveler.Value_ID)>
		<cfelse>
			<cfset local.stTraveler.Type = 'NEW'>
			<cfset local.stTraveler.User_ID = ''>
			<cfset local.qOUs = getOUs(session.searches[arguments.nSearchID].nValueID)>
		</cfif>
		<cfsavecontent variable="local.sForm">
			<cfoutput>
				<table width="400">
				<cfset local.qAllTravelers = getAllTravelers()>
				<tr>
					<td colspan="2">
						<select name="User_ID" id="User_ID" onChange="changeTraveler(#arguments.nTraveler#);">
						<option value="">SELECT A TRAVELER</option>
						<option value="0">GUEST TRAVELER</option>
						<cfloop query="qAllTravelers">
							<option value="#qAllTravelers.User_ID#" <cfif stTraveler.User_ID EQ qAllTravelers.User_ID>selected</cfif>>#qAllTravelers.Last_Name#/#qAllTravelers.First_Name# #qAllTravelers.Middle_Name#</option>
						</cfloop>
						</select>
					</td>
				</tr>
				<cfif stTraveler.Type EQ 'Profile'>
					<tr>
						<td>
							<label for="First_Name#arguments.nTraveler#">First Name</label>
						</td>
						<td>
							<input type="text" name="First_Name#arguments.nTraveler#" id="First_Name#arguments.nTraveler#" value="#stTraveler.First_Name#">
						</td>
					</tr>
					<tr>
						<td>
							<label for="Middle_Name#arguments.nTraveler#">Middle Name</label>
						</td>
						<td>
							<input type="text" name="Middle_Name#arguments.nTraveler#" id="Middle_Name#arguments.nTraveler#" value="#stTraveler.Middle_Name#">
						</td>
					</tr>
					<tr>
						<td>
							<label for="Last_Name#arguments.nTraveler#">Last Name</label>
						</td>
						<td>
							<input type="text" name="Last_Name#arguments.nTraveler#" id="Last_Name#arguments.nTraveler#" value="#stTraveler.Last_Name#">
						</td>
					</tr>
				<cfelse>
					<input type="hidden" name="First_Name#arguments.nTraveler#" id="First_Name#arguments.nTraveler#" value="#stTraveler.First_Name#">
					<input type="hidden" name="Middle_Name#arguments.nTraveler#" id="Middle_Name#arguments.nTraveler#" value="#stTraveler.Middle_Name#">
					<input type="hidden" name="Last_Name#arguments.nTraveler#" id="Last_Name#arguments.nTraveler#" value="#stTraveler.Last_Name#">
				</cfif>
				<tr>
					<td>
						<label for="Phone_Number#arguments.nTraveler#">Business Phone</label>
					</td>
					<td>
						<input type="text" name="Phone_Number#arguments.nTraveler#" id="Phone_Number#arguments.nTraveler#" value="#stTraveler.Phone_Number#">
					</td>
				</tr>
				<tr>
					<td>
						<label for="Wireless_Phone#arguments.nTraveler#">Wireless Phone</label>
					</td>
					<td>
						<input type="text" name="Wireless_Phone#arguments.nTraveler#" id="Wireless_Phone#arguments.nTraveler#" value="#stTraveler.Wireless_Phone#">
					</td>
				</tr>
				<tr>
					<td>
						<label for="Email#arguments.nTraveler#">Email</label>
					</td>
					<td>
						<input type="text" name="Email#arguments.nTraveler#" id="Email#arguments.nTraveler#" value="#stTraveler.Email#">
					</td>
				</tr>
				<tr>
					<td>
						<label for="CCEmail#arguments.nTraveler#">CC Emails</label>
					</td>
					<td>
						<input type="text" name="CCEmail#arguments.nTraveler#" id="CCEmail#arguments.nTraveler#" value="#stTraveler.CCEmail#">
					</td>
				</tr>
				<tr>
					<td>
						<label for="Month#nTraveler#">Birthday</label>
					</td>
					<td>
						<select name="Month#arguments.nTraveler#" id="Month#arguments.nTraveler#">
						<option value=""></option>
						<cfloop from="1" to="12" index="i">
							<option value="#i#" <cfif IsDate(stTraveler.Birthdate) AND Month(stTraveler.Birthdate) EQ i>selected</cfif>>#MonthAsString(i)#</option>
						</cfloop>
						</select>
						<select name="Day#nTraveler#">
						<option value=""></option>
						<cfloop from="1" to="31" index="i">
							<option value="#i#" <cfif IsDate(stTraveler.Birthdate) AND Day(stTraveler.Birthdate) EQ i>selected</cfif>>#i#</option>
						</cfloop>
						</select>
						<select name="Year#nTraveler#">
						<option value=""></option>
						<cfloop from="#Year(Now())-100#" to="#Year(Now())#" index="i">
							<option value="#i#" <cfif IsDate(stTraveler.Birthdate) AND Year(stTraveler.Birthdate) EQ i>selected</cfif>>#i#</option>
						</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<label for="Gender#arguments.nTraveler#">Gender</label>
					</td>
					<td>
						<select name="Gender#arguments.nTraveler#" id="Gender#arguments.nTraveler#">
						<option value="M" <cfif stTraveler.Gender EQ 'M'>selected</cfif>>Male</option>
						<option value="F" <cfif stTraveler.Gender EQ 'F'>selected</cfif>>Female</option>
						</select>
					</td>
				</tr>
				<cfoutput query="qOUs" group="OU_ID">
					<tr>
						<td>
							<label for="OU_ID#qOUs.OU_ID##arguments.nTraveler#">#qOUs.OU_Name#</label>
						</td>
						<td>
							<select name="OU_ID#qOUs.OU_ID##arguments.nTraveler#" id="OU_ID#qOUs.OU_ID##arguments.nTraveler#">
							<option value=""></option>
							<cfoutput>
								<option value="#qOUs.Value_Report#" <cfif StructKeyExists(stTraveler.stOUs, qOUs.OU_ID) AND stTraveler.stOUs[qOUs.OU_ID].Value_ID EQ qOUs.Value_ID>selected</cfif>>#qOUs.Value_Display#</option>
							</cfoutput>
							</select>
						</td>
					</tr>
				</cfoutput>
				<tr>
					<td colspan="2">
						<input type="submit" value="Save" onClick="saveTraveler(#nTraveler#);">
					</td>
				</tr>
				</table>
			</cfoutput>
		</cfsavecontent>

		<cfreturn serializeJSON(sForm)>
	</cffunction>

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