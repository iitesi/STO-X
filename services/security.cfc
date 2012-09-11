<cfcomponent output="false">
	
<!--- session : search --->
	<cffunction name="search" access="remote" output="false" returntype="void">
		<cfargument name="Search_ID" 	required="true"> 
		<cfargument name="Append" 		required="false" default="0" > 
		
		<cfset local.done = 0>
		<cfif StructKeyExists(session, 'searches')
		AND IsStruct(session.searches)
		AND StructKeyExists(session.searches, arguments.Search_ID)
		AND StructKeyExists(session.searches[arguments.Search_ID], 'Policy_ID')>
			<cfset done = 1>
		</cfif>
		
		<cfif done EQ 0>
			<cfif NOT StructKeyExists(session, 'searches') OR NOT IsStruct(session.searches)>
				<cfset session.searches = StructNew()>
			</cfif>
			
			<cfquery name="local.getsearch" datasource="book">
			SELECT TOP 1 Acct_ID, Search_ID, Air, Car, Hotel, Policy_ID, Profile_ID, Value_ID, User_ID, Username,
			Air_Type, Depart_City, Depart_DateTime, Arrival_City, Arrival_DateTime
			FROM Searches
			WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_integer">
			ORDER BY Search_ID DESC
			</cfquery>
			
			<cfif getsearch.Air_Type EQ 'MD'>
				<cfquery name="local.getsearchlegs" datasource="book">
				SELECT Depart_City, Arrival_City, Depart_DateTime, Depart_TimeType
				FROM Searches_Legs
				WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
				</cfquery>
			</cfif>
			
			<cfif getsearch.Profile_ID EQ getsearch.User_ID>
				<cfset tab.bookingfor = ''>
			<cfelseif getsearch.Profile_ID EQ 0>
				<cfset tab.bookingfor = 'Guest Traveler'>
			<cfelse>
				<cfquery name="local.getuser" datasource="Corporate_Production">
				SELECT First_Name, Last_Name
				FROM Users
				WHERE User_ID = <cfqueryparam value="#getsearch.Profile_ID#" cfsqltype="cf_sql_integer" >
				</cfquery>
				<cfset tab.bookingfor = getuser.First_Name&' '&getuser.Last_Name>
			</cfif>
			
			<cfset local.tab['Search_ID'] = arguments.Search_ID>
			<cfset tab.Air = getsearch.Air>
			<cfset tab.Pricing = {}>
			<cfset tab.Car = getsearch.Car>
			<cfset tab.Hotel = getsearch.Hotel>
			<cfset tab.Policy_ID = getsearch.Policy_ID>
			<cfset tab.Profile_ID = getsearch.Profile_ID>
			<cfset tab.Value_ID = getsearch.Value_ID>
			<cfset tab.Depart_DateTime = getsearch.Depart_DateTime>
			<cfset tab.stSegments = {}>
			<cfset tab.stTrips = {}>
			<cfif getsearch.Air AND getsearch.Air_Type EQ 'RT'>
				<cfif DateFormat(getsearch.Depart_DateTime) NEQ DateFormat(getsearch.Arrival_DateTime)>
					<cfset tab.Heading = getsearch.Depart_City&'-'&getsearch.Arrival_City&' from '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')&' to '&DateFormat(getsearch.Arrival_DateTime, 'm/d')>
				<cfelse>
					<cfset tab.Heading = getsearch.Depart_City&'-'&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')>
				</cfif>
			<cfelseif getsearch.Air AND getsearch.Air_Type EQ 'OW'>
				<cfset tab.Heading = getsearch.Depart_City&'-'&getsearch.Arrival_City&' from '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')>
			<cfelseif getsearch.Air AND getsearch.Air_Type EQ 'MD'>
				<cfset tab.Heading = ''>
				<cfloop query="getsearchlegs">
					<cfset tab.Heading = tab['Heading']&getsearchlegs.Depart_City&'-'&getsearchlegs.Arrival_City&' on '&DateFormat(getsearchlegs.Depart_DateTime, 'ddd, m/d')&' '>
				</cfloop>
			<cfelseif NOT getsearch.Air AND getsearch.Car>
				<cfset tab.Heading = ''>
				<cfset tab.Heading = getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')>
			</cfif>
			
			<cflock timeout="30" scope="session" type="exclusive">
				<cfset session.searches[arguments.Search_ID] = tab>
				<cfset session.User_ID = getsearch.User_ID>
				<cfset session.Username = getsearch.Username>
				<cfset session.Acct_ID = getsearch.Acct_ID>
			</cflock>
		</cfif>
		
		<cfreturn />
	</cffunction>
	
<!--- close --->
	<cffunction name="close" output="false">
		<cfargument name="nSearchID"> 
		
		<cfset local.temp = StructDelete(session.searches, arguments.nSearchID)>
		<cfset local.nNewSearchID = ''>
		<cfloop collection="#session.searches#" item="local.nSearchID">
			<cfset nNewSearchID = nSearchID>
			<cfbreak>
		</cfloop>
		
		<cfreturn nNewSearchID/>
	</cffunction>
	
</cfcomponent>