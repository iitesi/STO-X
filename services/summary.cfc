<cfcomponent output="false">
	
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
			SELECT Users.User_ID, Users.First_Name, Users.Middle_Name, Users.NoMiddleName, Users.Last_Name,
			Personal_Contact_Info.Birthdate, Users.Email, Users.Gender, Biz_Contact_Info.Phone_Number,
			Personal_Contact_Info.Wireless_Phone, CASE WHEN Airline_Prefs.Window_Aisle = 1 THEN 'W' ELSE 'A' END AS Window_Aisle
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
			WHERE User_ID = <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfset stTravelers[arguments.nTraveler].CCEmail = ValueList(qCCEmails.CCEmail_Address, ';')>
			<!--- Populate the org units --->
			<!--- <cfquery name="local.qOUs" datasource="Corporate_Production">
			<!--- OU_Users.Value_Report is if the OU is a freeform. OU_Values.Value_Report is if the OU is a dropdown --->
			SELECT OUs.OU_ID, OU_Name, OU_Capture, OU_Position, OU_Default, OU_Required,
			OU_Freeform, OU_Pattern, OU_Max, OU_Min, OU_Users.Value_Report AS Freeform,
			OU_Values.Value_Report AS Dropdown, OU_Values.Value_ID, OU_Type, OU_STO
			FROM OUs LEFT OUTER JOIN OU_Users ON OUs.OU_ID = OU_Users.OU_ID
												AND OU_Users.User_ID = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_integer">
			LEFT OUTER JOIN OU_Values ON OU_Users.Value_ID = OU_Values.Value_ID
			WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
			AND OUs.Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			AND (MainOU_ID IS NULL
				OR MainValue_ID IN (#session.Value_ID#))
			AND OUs.OU_ID NOT IN (347,348,349)<!--- Custom code for the State of Texas execption codes --->
			<cfif session.account.Acct_ID NEQ 348>
				AND OU_Capture IN ('R','P')
				AND OU_Type IN ('SORT','UDID')
			<cfelse>
				AND OUs.OU_ID IN (399,400,401,402,403)
			</cfif>
			ORDER BY OU_Order
			</cfquery> --->
			<cfset stTravelers[arguments.nTraveler].Type = (arguments.User_ID NEQ 0 ? 'Profiled' : 'Guest')>
			
		</cfif>
		
		<cfset session.searches[arguments.nSearchID].stTravelers = stTravelers>

		<cfreturn >
	</cffunction>
	
	<cffunction name="saveTraveler" output="false" access="remote" returnformat="plain">
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
		
		<cfset local.stTravelers = session.searches[arguments.nSearchID].stTravelers>
		<cfif arguments.First_Name NEQ ''>
			<cfset stTravelers[arguments.nTraveler].First_Name = arguments.First_Name>
		</cfif>
		<cfif arguments.Middle_Name NEQ ''>
			<cfset stTravelers[arguments.nTraveler].Middle_Name = arguments.Middle_Name>
		</cfif>
		<cfif arguments.Last_Name NEQ ''>
			<cfset stTravelers[arguments.nTraveler].Last_Name = arguments.Last_Name>
		</cfif>
		<cfset stTravelers[arguments.nTraveler].Phone_Number = arguments.Phone_Number>
		<cfset stTravelers[arguments.nTraveler].Wireless_Phone = arguments.Wireless_Phone>
		<cfset stTravelers[arguments.nTraveler].Email = arguments.Email>
		<cfset stTravelers[arguments.nTraveler].CCEmail = arguments.CCEmail>
		<!--- <cfset stTravelers[arguments.nTraveler].Birthdate = CreateDate(arguments.Year, arguments.Month, arguments.Day)> --->
		<cfset stTravelers[arguments.nTraveler].Gender = arguments.Gender>
		<cfset session.searches[arguments.nSearchID].stTravelers = stTravelers>
		
		<cfsavecontent variable="local.sSummary">
			<cfset local.stTraveler = stTravelers[arguments.nTraveler]>
			<cfoutput>
				<h3>#stTraveler.Last_Name#/#stTraveler.First_Name# #stTraveler.Middle_Name#</h3> (#arguments.nTraveler#)<br>
				<a href="##" onClick="showForm(#arguments.nTraveler#);" style="float:right">edit</a>
				#stTraveler.Phone_Number#<br>
				#stTraveler.Wireless_Phone#<br>
				#stTraveler.Email#<br>
				#stTraveler.CCEmail#<br>
				#DateFormat(stTraveler.Birthdate, 'mmmm d, yyyy')#<br>
				#(stTraveler.Gender EQ 'F' ? 'Female' : 'Male')#
			</cfoutput>
		</cfsavecontent>

		<cfreturn serializeJSON(sSummary)>
	</cffunction>

	<cffunction name="setTravelerForm" output="false" access="remote" returnformat="plain">
		<cfargument name="nSearchID">
		<cfargument name="nTraveler">
		
		<cfif structKeyExists(session.searches[arguments.nSearchID].stTravelers, arguments.nTraveler)>
			<cfset local.stTraveler = session.searches[arguments.nSearchID].stTravelers[arguments.nTraveler]>
		<cfelse>
			<cfset local.stTraveler.Type = 'NEW'>
		</cfif>
		<cfsavecontent variable="local.sForm">
			<cfoutput>
				<table>
				<cfif stTraveler.Type EQ 'NEW'>
					<cfset local.qAllTravelers = getAllTravelers(#session.searches[arguments.nSearchID].nProfileID#)>
					<tr>
						<td>
							<select name="User_ID#arguments.nTraveler#" id="User_ID#arguments.nTraveler#" onChange="addTraveler(#arguments.nTraveler#);">
							<option value="">SELECT A TRAVELER</option>
							<option value="0">GUEST TRAVELER</option>
							<cfloop query="qAllTravelers">
								<option value="#qAllTravelers.User_ID#">#qAllTravelers.Last_Name#/#qAllTravelers.First_Name# #qAllTravelers.Middle_Name#</option>
							</cfloop>
							</select>
						</td>
					</tr>
				<cfelseif stTraveler.Type NEQ 'New'>
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
						<tr>
							<td colspan="2">
								<h2>#stTraveler.Last_Name#/#stTraveler.First_Name# #stTraveler.Middle_Name#</h2>
							</td>
						</tr>
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
							<label for="Wireless_Phone#arguments.nTraveler#">Cell Phone</label>
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
					<tr>
						<td colspan="2">
							<input type="submit" value="Save" onClick="saveTraveler(#nTraveler#);">
						</td>
					</tr>
				</cfif>
				</table>
			</cfoutput>
		</cfsavecontent>

		<cfreturn serializeJSON(sForm)>
	</cffunction>
	
	<cffunction name="getOUs" output="false">
		<cfargument name="Acct_ID" 		default="#session.Acct_ID#">
		<cfargument name="User_ID" 		default="#session.searches[url.Search_ID].nProfileID#">
		
		<cfquery name="local.qOUs" datasource="Corporate_Production">
		<!--- OU_Users.Value_Report is if the OU is a freeform. OU_Values.Value_Report is if the OU is a dropdown --->
		SELECT OUs.OU_ID, OU_Name, OU_Capture, OU_Position, OU_Default, OU_Required,
		OU_Freeform, OU_Pattern, OU_Max, OU_Min, OU_Users.Value_Report AS Freeform,
		OU_Values.Value_Report AS Dropdown, OU_Values.Value_ID, OU_Type, OU_STO
		FROM OUs LEFT OUTER JOIN OU_Users ON OUs.OU_ID = OU_Users.OU_ID
											AND OU_Users.User_ID = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_integer">
		LEFT OUTER JOIN OU_Values ON OU_Users.Value_ID = OU_Values.Value_ID
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		AND OUs.Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		AND (MainOU_ID IS NULL
			OR MainValue_ID IN (#session.Value_ID#))
		AND OUs.OU_ID NOT IN (347,348,349)<!--- Custom code for the State of Texas execption codes --->
		<cfif session.account.Acct_ID NEQ 348>
			AND OU_Capture IN ('R','P')
			AND OU_Type IN ('SORT','UDID')
		<cfelse>
			AND OUs.OU_ID IN (399,400,401,402,403)
		</cfif>
		ORDER BY OU_Order
		</cfquery>
		
		<cfreturn qOUs>
	</cffunction>

	<cffunction name="getAllTravelers" output="false">
		<cfargument name="User_ID" 		default="#session.searches[url.Search_ID].nProfileID#">
		<cfargument name="Acct_ID" 		default="#session.Acct_ID#">
		
		<cfstoredproc procedure="sp_travelers" datasource="Corporate_Production">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#arguments.Acct_ID#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#arguments.User_ID#">
			<cfprocresult name="local.qAllTravelers"> 
		</cfstoredproc> 

		<cfreturn qAllTravelers />
	</cffunction>

</cfcomponent>