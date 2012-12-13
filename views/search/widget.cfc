<cfcomponent>

	<cffunction name="init" output="false" returntype="any">
		<cfreturn this>
	</cffunction>

	<cffunction Name="getSpecificUser" access="remote" returntype="query" output="false">
		<cfargument Name="User_ID" type="numeric" required="yes">
		<cfargument Name="Acct_ID" type="numeric" required="yes">
		
		<cfquery Name="getSpecificUser" datasource="Corporate_Production">
		SELECT Users.First_Name, Users.Last_Name, Users_Accounts.Type_ID, 
		Primary_Acct.Acct_ID AS Primary_Acct, Acct_DirNew, AllowSavedTrips, International
		FROM Users, Users_Accounts, Users_Accounts AS Primary_Acct, Accounts
		WHERE Users_Accounts.Acct_ID = <cfqueryparam value="#Acct_ID#" cfsqltype="cf_sql_integer">
		AND Users.User_ID = <cfqueryparam value="#User_ID#" cfsqltype="cf_sql_integer">
		AND Users.Status = 'A'
		AND Users.User_ID = Users_Accounts.User_ID
		AND Users.User_ID = Primary_Acct.User_ID
		AND Users_Accounts.Acct_ID = Accounts.Acct_ID
		AND Primary_Acct.Primary_Acct = 1
		</cfquery>
		
		<cfreturn getSpecificUser>
	</cffunction>
	
	<cffunction Name="getAllDefaultUsers" output="false">
		
		<cfset var getAllDefaultUsers = ''>
		<cfquery Name="getAllDefaultUsers" datasource="Corporate_Production" cachedwithin="#application.cachedwithin#">
		SELECT User_ID
		FROM Users
		WHERE Last_Name = <cfqueryparam value="STODEFAULTUSER" cfsqltype="cf_sql_varchar">
		AND First_Name = <cfqueryparam value="STODEFAULTUSER" cfsqltype="cf_sql_varchar">
		AND Status = <cfqueryparam value="A" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfset var stAllowedUsers = StructNew()>
		<cfloop query="getAllDefaultUsers">
			<cfset stAllowedUsers[User_ID] = ''>
		</cfloop>
		
		<cfreturn stAllowedUsers>
	</cffunction>
	
	<cffunction Name="getAllFees" access="remote" returntype="string" output="false">
		<cfargument Name="Acct_ID" type="numeric" required="yes">
		
		<cfquery Name="getAllFees" datasource="book" cachedwithin="#application.cachedwithin#">
		SELECT CASE WHEN MAX(Policy_NonAirFee) > 0 THEN '' ELSE 'NoFees' END AS Fee
		FROM Account_Policies
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfreturn getAllFees.Fee>
	</cffunction>
	
	<cffunction Name="getSearchWindows" access="remote" returntype="string" output="false">
		<cfargument Name="Acct_ID" type="numeric" required="yes">
		
		<cfset var Policy_Window = ''> 
		
		<cfquery Name="getSearchWindows" datasource="book" cachedwithin="#application.cachedwithin#">
		SELECT DISTINCT Policy_Window
		FROM Account_Policies
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		AND Policy_Window IS NOT NULL
		</cfquery>
		<cfif getSearchWindows.RecordCount EQ 1>
			<cfset Policy_Window = ' (+/-'&Round(getSearchWindows.Policy_Window/2)&'h)'>
		<cfelse>
			<cfset Policy_Window = ''>
		</cfif>
		
		<cfreturn Policy_Window>
	</cffunction>
	
	<cffunction Name="getSpecificAccount" access="remote" returntype="query" output="false">
		<cfargument Name="Acct_ID" type="numeric" required="yes">
		
		<cfquery Name="getSpecificAccount" datasource="Corporate_Production" cachedwithin="#application.cachedwithin#">
		SELECT IsNull(SearchByPrice, 1) AS SearchByPrice
		FROM Accounts
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfreturn getSpecificAccount />
	</cffunction>
	
	<cffunction Name="getAllStates" access="remote" returntype="query" output="false">
		
		<cfquery Name="getAllStates" datasource="book" cachedwithin="#application.cachedwithin#">
		SELECT State_Code
		FROM lu_States
		WHERE State_Country = <cfqueryparam value="United States" cfsqltype="cf_sql_varchar">
		ORDER BY State_Code
		</cfquery>
		
		<cfreturn getAllStates>
	</cffunction>
	
	<cffunction Name="getAllCountries" access="remote" returntype="query" output="false">
		
		<cfquery Name="getAllCountries" datasource="book" cachedwithin="#application.cachedwithin#">
		SELECT DISTINCT Country_Code, Country_Name
		FROM lu_Countries
		ORDER BY Country_Name
		</cfquery>
		
		<cfreturn getAllCountries>
	</cffunction>
	
	<cffunction Name="getDefaultAirport" access="remote" returntype="string" output="false">
		<cfargument Name="Profile_ID" required="no" type="numeric">
		<cfargument Name="User_ID" required="no" type="numeric">
		
		<cfset var DefaultCode = '000'>
		
		<cfquery Name="getDefaultAirport" datasource="Corporate_Production" cachedwithin="#application.cachedwithin#">
		SELECT TOP 1 Code
		FROM Airport_Prefs
		WHERE User_ID =
			<cfif arguments.Profile_ID NEQ 0>
				<cfqueryparam value="#arguments.Profile_ID#" cfsqltype="cf_sql_integer">
			<cfelse>
				<cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_integer">
			</cfif>
		ORDER BY Order_ID
		</cfquery>
		
		<cfif getDefaultAirport.RecordCount>
			<cfset DefaultCode = getDefaultAirport.Code>
		</cfif>
		
		<cfquery Name="getDefaultAirport" datasource="book" cachedwithin="#application.cachedwithin#">
		SELECT Geography_ID, Location_Display
		FROM lu_Geography
		WHERE Location_Code = <cfqueryparam value="#DefaultCode#" cfsqltype="cf_sql_varchar">
		AND Location_Type = <cfqueryparam value="125" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfreturn getDefaultAirport.Location_Display>
	</cffunction>
	
	<cffunction Name="getAllAirlines" access="remote" returntype="query" output="false">
		
		<cfset var getAllAirlines = ''>
		
		<cfquery Name="getAllAirlines" datasource="book" cachedwithin="#CreateTimeSpan(0,0,0,0)#">
		SELECT Vendor_Code, Vendor_Name
		FROM lu_Vendors
		WHERE Vendor_Type = <cfqueryparam value="A" cfsqltype="cf_sql_varchar">
		AND Vendor_Code IN ('DL','AA','UA','WN','US','CO','AS','F9','FL','B6','LH','AC','BA','XE','AF','KL','SK','VX')
		ORDER BY Vendor_Name
		</cfquery>
		
		<cfreturn getAllAirlines>
	</cffunction>
	
	<cffunction Name="getSpecificLongLat" access="remote" returntype="string" output="false">
		<cfargument Name="Hotel" required="yes" type="numeric">
		<cfargument Name="Hotel_Search" required="yes" type="string">
		<cfargument Name="Hotel_Airport" required="yes" type="string">
		<cfargument Name="Hotel_Landmark" required="yes" type="string">
		<cfargument Name="Hotel_Address" required="yes" type="string">
		<cfargument Name="Hotel_City" required="yes" type="string">
		<cfargument Name="Hotel_State" required="yes" type="string">
		<cfargument Name="Hotel_Zip" required="yes" type="string">
		<cfargument Name="Hotel_Country" required="yes" type="string">
		<cfargument Name="Office_ID" required="yes" type="string">
		
		<cfset var LatLong = '0,0'>
		<cfset var Search_Location = ''>
		
		<cfif arguments.Hotel EQ 1>
			<cfif arguments.Hotel_Search EQ 'Airport'>
				<cfquery name="getSpecificLongLat" datasource="book">
				SELECT Long, Lat, Geography_ID
				FROM lu_Geography
				WHERE Location_Display = <cfqueryparam value="#arguments.Hotel_Airport#" cfsqltype="cf_sql_varchar">
				AND Location_Type = <cfqueryparam value="125" cfsqltype="cf_sql_integer">
				AND Lat <> <cfqueryparam value="0" cfsqltype="cf_sql_integer">
				AND Long <> <cfqueryparam value="0" cfsqltype="cf_sql_integer">
				</cfquery>
				<cfif getSpecificLongLat.RecordCount EQ 1>
					<cfset LatLong = getSpecificLongLat.Lat&','&getSpecificLongLat.Long&','&getSpecificLongLat.Geography_ID>
				<cfelseif Len(arguments.Hotel_Airport) EQ 3>
					<cfquery name="getSpecificLongLat" datasource="book">
					SELECT Long, Lat, Geography_ID
					FROM lu_Geography
					WHERE Location_Code = <cfqueryparam value="#arguments.Hotel_Airport#" cfsqltype="cf_sql_varchar">
					AND Location_Type = <cfqueryparam value="125" cfsqltype="cf_sql_integer">
					AND Lat <> <cfqueryparam value="0" cfsqltype="cf_sql_integer">
					AND Long <> <cfqueryparam value="0" cfsqltype="cf_sql_integer">
					</cfquery>
					<cfif getSpecificLongLat.RecordCount EQ 1>
						<cfset LatLong = getSpecificLongLat.Lat&','&getSpecificLongLat.Long&','&getSpecificLongLat.Geography_ID>
					</cfif>
				</cfif>
			<cfelseif arguments.Hotel_Search EQ 'City'>
				<cfquery name="getSpecificLongLat" datasource="book">
				SELECT Long, Lat, Geography_ID
				FROM lu_Geography
				WHERE Location_Display = <cfqueryparam value="#arguments.Hotel_Landmark#" cfsqltype="cf_sql_varchar">
				AND Location_Type = <cfqueryparam value="126" cfsqltype="cf_sql_integer">
				AND Lat <> <cfqueryparam value="0" cfsqltype="cf_sql_integer">
				AND Long <> <cfqueryparam value="0" cfsqltype="cf_sql_integer">
				</cfquery>
				<cfif getSpecificLongLat.RecordCount EQ 1 AND getSpecificLongLat.Lat NEQ '' AND getSpecificLongLat.Long NEQ ''>
					<cfset LatLong = getSpecificLongLat.Lat&','&getSpecificLongLat.Long&','&getSpecificLongLat.Geography_ID>
				</cfif>
			<cfelseif arguments.Hotel_Search EQ 'Office'>
				<cfquery name="getSpecificLongLat" datasource="book">
				SELECT Office_Long, Office_Lat
				FROM Account_Offices
				WHERE Office_ID = #arguments.Office_ID#
				</cfquery>
				<cfif getSpecificLongLat.RecordCount EQ 1 AND getSpecificLongLat.Office_Lat NEQ '' AND getSpecificLongLat.Office_Long NEQ ''>
					<cfset LatLong = getSpecificLongLat.Office_Lat&','&getSpecificLongLat.Office_Long&',0'>
				</cfif>
			</cfif>
			<cfif LatLong EQ '0,0'>
				<cfif arguments.Hotel_Search EQ 'Airport'>
					<cfset Search_Location = arguments.Hotel_Airport>
				<cfelseif arguments.Hotel_Search EQ 'City'>
					<cfset Search_Location = arguments.Hotel_Landmark>
				<cfelseif arguments.Hotel_Search EQ 'Office'>
					<cfset Search_Location = ''>
				<cfelse>
					<cfset Search_Location = '#Trim(arguments.Hotel_Address)#,#Trim(arguments.Hotel_City)#,#Trim(arguments.Hotel_State)#,#Trim(arguments.Hotel_Zip)#,#Trim(arguments.Hotel_Country)#'>
				</cfif>
				<cfif Search_Location NEQ '' AND Search_Location NEQ ',,,'>
					<cftry>
						<cfhttp method="get" url="https://maps.google.com/maps/geo?q=#Search_Location#&output=xml&oe=utf8\&sensor=false&key=ABQIAAAAIHNFIGiwETbSFcOaab8PnBQ2kGXFZEF_VQF9vr-8nzO_JSz_PxTci5NiCJMEdaUIn3HA4o_YLE757Q" />
						<cfset LatLong = XMLParse(cfhttp.FileContent)>
						<cfset LatLong = LatLong.kml.Response.Placemark.Point.coordinates.XMLText>
						<cfset LatLong = GetToken(LatLong, 2, ',')&','&GetToken(LatLong, 1, ',')&',0'>
					<cfcatch>
					</cfcatch>
					</cftry>
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn LatLong>
	</cffunction>
	
	<cffunction Name="getAllOffices" access="remote" returntype="query" output="false">
		<cfargument Name="Acct_ID" required="yes" type="numeric">
		
		<cfquery Name="getAllOffices" datasource="book" cachedwithin="#application.cachedwithin#">
		SELECT Office_ID, Office_Name
		FROM Account_Offices
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		AND Status = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		ORDER BY Office_Name
		</cfquery>
		
		<cfreturn getAllOffices>
	</cffunction>
	
	<cffunction Name="getSpecificOffice" access="remote" returntype="query" output="false">
		<cfargument Name="Office_ID" required="yes" type="numeric">
		
		<cfquery Name="getSpecificOffice" datasource="book">
		SELECT Office_Name
		FROM Account_Offices
		WHERE Office_ID = <cfqueryparam value="#arguments.Office_ID#" cfsqltype="cf_sql_integer">
		AND Status = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfreturn getSpecificOffice>
	</cffunction>
	
	<cffunction Name="getSpecificGeography" access="remote" returntype="string" output="false">
		<cfargument Name="Location_Code" required="no" default="">
		<cfargument Name="Location_Display" required="no" default="">
		<cfargument Name="Type" required="no" default="125">
		<cfargument Name="International" required="no" default="0">
		
		<cfquery Name="getSpecificGeography" datasource="book" cachedwithin="#application.cachedwithin#">
		SELECT Location_Display AS Location, Country_Code
		FROM lu_Geography
		WHERE Location_Type = <cfqueryparam value="#arguments.Type#" cfsqltype="cf_sql_integer">
		<cfif arguments.Type EQ 125>
			AND Location_Code = <cfqueryparam value="#arguments.Location_Code#" cfsqltype="cf_sql_varchar">
			<cfif arguments.International EQ 0>
				AND Country_Code IN ('US','VI')
			</cfif>
		</cfif>
		<cfif arguments.Location_Display NEQ '' AND Len(arguments.Location_Display) NEQ 3>
			AND Location_Display = '#arguments.Location_Display#'
		</cfif>
		</cfquery>
		
		<cfloop query="getSpecificGeography">
			<cfif Country_Code NEQ 'US' AND Country_Code NEQ 'VI'>
				<cfset form.International = 1>
			</cfif>
		</cfloop>
		
		<cfreturn getSpecificGeography.Location>
	</cffunction>
	
	<cffunction name="getSpecificSTOOU" access="remote" returntype="query" output="no">
		<cfargument name="Acct_ID" type="numeric" required="yes">
		
		<cfquery name="getSpecificSTOOU" datasource="Corporate_Production" cachedwithin="#application.cachedwithin#">
		SELECT OUs.OU_ID, 0 AS Account_Policies, OUs.OU_Name
		FROM OUs
		WHERE Acct_ID = <cfqueryparam value="#Acct_ID#" cfsqltype="cf_sql_integer">
		AND OU_STO = 1
		AND Active = 1
		</cfquery>
		
		<cfif getSpecificSTOOU.RecordCount>
			<cfquery name="getSpecificSTO" datasource="book" cachedwithin="#application.cachedwithin#">
			SELECT Account_Policies
			FROM Accounts Accounts
			WHERE Acct_ID = <cfqueryparam value="#Acct_ID#" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfset QuerySetCell(getSpecificSTOOU, 'Account_Policies', getSpecificSTO.Account_Policies)>
		</cfif>
		
		<cfreturn getSpecificSTOOU>	
	</cffunction>
	
	<cffunction name="determinePolicy" access="remote" returntype="string" output="no">
		<cfargument name="Profile_ID" required="no">
		<cfargument name="Value_ID" required="no">
		<cfargument name="Acct_ID" type="numeric" required="yes">
		
		<cfset var PolicyID = 0>
		<cfset var ValueID = 0>
		<cfset var VIP = 0>
		
		<!--- Profiled traveler --->
		<cfif arguments.Profile_ID NEQ 0>
			
			<cfquery name="getAllOUs" datasource="Corporate_Production">
			SELECT Users.VIP, OUs.OU_ID, OU_Users.Value_ID
			FROM Users, OU_Users, OUs
			WHERE Users.User_ID = <cfqueryparam value="#arguments.Profile_ID#" cfsqltype="cf_sql_integer">
			AND OUs.Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
			AND Users.User_ID = OU_Users.User_ID
			AND OU_Users.OU_ID = OUs.OU_ID
			AND OU_Users.Value_ID IS NOT NULL
			AND OU_Users.Value_ID <> <cfqueryparam value="" cfsqltype="cf_sql_varchar">
			AND OUs.OU_STO = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			</cfquery>
			
			<cfif getAllOUs.RecordCount>
				<cfset ValueID = getAllOUs.Value_ID>
				<cfset VIP = getAllOUs.VIP>
				
				<cfquery name="getAllPolicies" datasource="book">
				SELECT Account_Policies.Policy_ID
				FROM Account_Policies
				WHERE Account_Policies.Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
				AND Account_Policies.Policy_OUID = <cfqueryparam value="#getAllOUs.OU_ID#" cfsqltype="cf_sql_integer">
				AND Account_Policies.Policy_ValueID = <cfqueryparam value="#getAllOUs.Value_ID#" cfsqltype="cf_sql_integer">
				<cfif getAllOUs.VIP EQ 0>
					AND (Account_Policies.Policy_Include = <cfqueryparam value="Non" cfsqltype="cf_sql_varchar">
						OR Account_Policies.Policy_Include = <cfqueryparam value="ALL" cfsqltype="cf_sql_varchar">)
				<cfelse>
					AND (Account_Policies.Policy_Include = <cfqueryparam value="VIP" cfsqltype="cf_sql_varchar">
						OR Account_Policies.Policy_Include = <cfqueryparam value="ALL" cfsqltype="cf_sql_varchar">)
				</cfif>
				ORDER BY Account_Policies.Policy_Include DESC
				</cfquery>
				
				<cfif getAllPolicies.RecordCount>
					<cfset PolicyID = getAllPolicies.Policy_ID>
				</cfif>
			</cfif>
		<!--- Guest traveler --->
		<cfelseif arguments.Value_ID NEQ 0 AND arguments.Value_ID NEQ ''>
			<cfset ValueID = arguments.Value_ID>
			
			<cfquery name="getAllPolicies" datasource="book">
			SELECT Account_Policies.Policy_ID
			FROM Account_Policies
			WHERE Account_Policies.Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
			AND Account_Policies.Policy_ValueID = <cfqueryparam value="#ValueID#" cfsqltype="cf_sql_integer">
			AND (Account_Policies.Policy_Include = <cfqueryparam value="Non" cfsqltype="cf_sql_varchar">
				OR Account_Policies.Policy_Include = <cfqueryparam value="ALL" cfsqltype="cf_sql_varchar">)
			ORDER BY Account_Policies.Policy_Include DESC
			</cfquery>
			
			<cfif getAllPolicies.RecordCount>
				<cfset PolicyID = getAllPolicies.Policy_ID>
			</cfif>
		</cfif>
		
		<!--- If no specific policy based on the profiles department or guest travelers department --->
		<cfif PolicyID EQ 0>
			<cfif arguments.Profile_ID NEQ 0 AND getAllOUs.RecordCount EQ 0>
				
				<cfquery name="getAllOUs" datasource="Corporate_Production">
				SELECT Users.VIP
				FROM Users
				WHERE Users.User_ID = <cfqueryparam value="#arguments.Profile_ID#" cfsqltype="cf_sql_integer">
				</cfquery>
				
				<cfset VIP = getAllOUs.VIP>
			</cfif>
			
			<!--- Get default account policy --->
			<cfquery name="getAllPolicies" datasource="book">
			SELECT Account_Policies.Policy_ID
			FROM Account_Policies
			WHERE Account_Policies.Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
			AND Account_Policies.Policy_OUID IS NULL
			AND Account_Policies.Policy_ValueID IS NULL
			<cfif VIP EQ 0>
				AND (Account_Policies.Policy_Include = <cfqueryparam value="Non" cfsqltype="cf_sql_varchar">
					OR Account_Policies.Policy_Include = <cfqueryparam value="ALL" cfsqltype="cf_sql_varchar">)
			<cfelse>
				AND (Account_Policies.Policy_Include = <cfqueryparam value="VIP" cfsqltype="cf_sql_varchar">
					OR Account_Policies.Policy_Include = <cfqueryparam value="ALL" cfsqltype="cf_sql_varchar">)
			</cfif>
			ORDER BY Account_Policies.Policy_Include DESC
			</cfquery>
			
			<cfif getAllPolicies.RecordCount>
				<cfset PolicyID = getAllPolicies.Policy_ID>
			</cfif>
		</cfif>
		
		<cfreturn PolicyID&'~'&ValueID />
	</cffunction>
	
	<cffunction name="getSpecificPolicy" access="remote" returntype="any" returnformat="plain" output="false">
		<cfargument Name="Acct_ID" type="numeric" required="yes">
		<cfargument Name="Value_ID" required="no" default="0">
		<cfargument Name="Profile_ID" required="no" default="0">
		
		<cfset var policy = ''>
		<cfset var Policy_ID = ''>
		
		<cfif arguments.Value_ID EQ ''>
			<cfset arguments.Value_ID = 0>
		</cfif>
		<cfif arguments.Profile_ID EQ ''>
			<cfset arguments.Profile_ID = 0>
		</cfif>
		
		<cfinvoke component="widget"
			method="determinePolicy"
			Profile_ID="#arguments.Profile_ID#"
			Value_ID="#arguments.Value_ID#"
			Acct_ID="#arguments.Acct_ID#"
			returnvariable="Policy_ID">
		
		<cfquery Name="getSpecificPolicy" datasource="book" cachedwithin="#application.cachedwithin#">
		SELECT Policy_ID, Policy_AirBusinessClass, Policy_AirFirstClass
		FROM Account_Policies
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		<cfif GetToken(Policy_ID, 1, '~') NEQ 0>
			AND Policy_ID = <cfqueryparam value="#GetToken(Policy_ID, 1, '~')#" cfsqltype="cf_sql_integer">
		<cfelse>
			AND Policy_OUID IS NULL
		</cfif>
		</cfquery>
		
		<cfset getSpecificPolicy = serializeJSON(getSpecificPolicy)>
		
		<cfreturn getSpecificPolicy>
	</cffunction>
	
	<cffunction name="getSpecificDepartment" access="remote" returntype="string" output="false">
		<cfargument name="Profile_ID" required="no">
		<cfargument name="Value_ID" required="no">
		
		<cfset var Department = ''>
		
		<cfif arguments.Profile_ID NEQ 0>
			
			<cfquery name="getSpecificDepartment" datasource="Corporate_Production">
			SELECT OU_Values.Value_Display
			FROM OUs, OU_Values, OU_Users
			WHERE OU_Users.User_ID = <cfqueryparam value="#arguments.Profile_ID#" cfsqltype="cf_sql_integer">
			AND OUs.OU_ID = OU_Values.OU_ID
			AND OU_Values.Value_ID = OU_Users.Value_ID
			AND OUs.Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			AND OU_Values.Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			AND OU_STO = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			</cfquery>
			
			<cfset Department = getSpecificDepartment.Value_Display>
		<cfelseif arguments.Value_ID NEQ 0 AND arguments.Value_ID NEQ ''>
			
			<cfquery name="getSpecificDepartment" datasource="Corporate_Production">
			SELECT OU_Values.Value_Display
			FROM OU_Values
			WHERE OU_Values.Value_ID = <cfqueryparam value="#arguments.Value_ID#" cfsqltype="cf_sql_integer">
			AND OU_Values.Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			</cfquery>
			
			<cfset Department = getSpecificDepartment.Value_Display>
		</cfif>
		
		<cfreturn Department />
	</cffunction>
	
	<cffunction name="getAllDepartments" access="remote" returntype="query" output="false">
		<cfargument name="User_ID" type="numeric" required="yes">		
		<cfargument name="OU_ID" type="numeric" required="yes">		
		<cfargument name="Type_ID" type="numeric" required="yes">
		
		<cfquery name="getAllDepartments" datasource="Corporate_Production">
		<cfif arguments.Type_ID EQ 1>
			<!--- their departments --->
			SELECT Value_Display, Value_ID
			FROM OU_Values
			WHERE OU_ID = <cfqueryparam value="#arguments.OU_ID#" cfsqltype="cf_sql_integer">
			AND Active = 1
			AND Value_ID IN (SELECT Value_ID FROM OU_Users WHERE User_ID = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_integer">)
			UNION
			<!--- any departments they are admin over --->
			SELECT Value_Display, Value_ID
			FROM OU_Values
			WHERE OU_ID = <cfqueryparam value="#arguments.OU_ID#" cfsqltype="cf_sql_integer">
			AND Active = 1
			AND Value_ID IN (SELECT Value_ID FROM OU_ValueAdmins WHERE User_ID = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_integer">)
		<cfelse>
			<!--- show all departments --->
			SELECT Value_Display, Value_ID
			FROM OU_Values
			WHERE OU_ID = <cfqueryparam value="#arguments.OU_ID#" cfsqltype="cf_sql_integer">
			AND Active = 1
		</cfif> 
		ORDER BY Value_Display
		</cfquery>
		
		<cfreturn getAllDepartments>
	</cffunction>
	
	<cffunction name="getLastSearch" access="remote" returntype="string" output="false">
		<cfargument name="User_ID" type="numeric" required="no">		
		<cfargument name="Acct_ID" type="numeric" required="yes">		
		<cfargument name="Search_ID" type="numeric" required="no">
			
		<cfquery name="getLastSearch" datasource="book">
		SELECT TOP 1 QueryString
		FROM Users_Searches
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		<cfif StructKeyExists(arguments, 'Search_ID')><!--- if SSO hotel add-on pull by search_id --->
			AND Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_integer">
		<cfelse><!--- if not an SSO hotel add-on pull User_ID and timestamp --->
			AND Timestamp >= #CreateODBCDate(DateAdd('ww', -1, Now()))#
			AND User_ID = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_integer">
			AND QueryString LIKE '%HotelAddOn=0%'
		</cfif>
		ORDER BY Timestamp DESC
		</cfquery>
		
		<cfreturn getLastSearch.QueryString>
	</cffunction>
	
	<cffunction name="getSpecificTrip" access="remote" returntype="string" output="false">
		<cfargument name="Trip_ID" type="numeric" required="yes">		
		<cfargument name="User_ID" type="numeric" required="yes">		
		<cfargument name="Acct_ID" type="numeric" required="yes">
		
		<cfquery name="getSpecificTrip" datasource="book">
		SELECT TOP 1 QueryString
		FROM Users_Searches
		WHERE User_ID = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_integer">
		AND Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		AND Search_ID = <cfqueryparam value="#arguments.Trip_ID#" cfsqltype="cf_sql_integer">
		ORDER BY Timestamp DESC
		</cfquery>
		
		<cfreturn getSpecificTrip.QueryString>
	</cffunction>
	
	<cffunction name="getAllSavedSearches" access="remote" returntype="query" output="false">
		<cfargument name="User_ID" type="numeric" required="yes">		
		<cfargument name="Acct_ID" type="numeric" required="yes">
			
		<cfquery name="getAllSavedSearches" datasource="book">
		SELECT Search_ID AS Trip_ID, Trip_Name
		FROM Users_Searches
		WHERE User_ID = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_integer">
		AND Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		AND SaveTrip = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		AND Active = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		ORDER BY Trip_Name
		</cfquery>
		
		<cfreturn getAllSavedSearches>
	</cffunction>
	
	<cffunction name="getAllTravelers" access="remote" returntype="query" output="false">
		<cfargument name="User_ID" type="numeric" required="yes">		
		<cfargument name="Acct_ID" type="numeric" required="yes">
		
		<cfstoredproc procedure="sp_travelers" datasource="Corporate_Production">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#arguments.Acct_ID#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#arguments.User_ID#">
			<cfprocresult name="getAllTravelers"> 
		</cfstoredproc> 

		<cfreturn getAllTravelers />
	</cffunction>
	
</cfcomponent>