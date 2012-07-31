<cfcomponent output="false">

<!--- session : search --->
	<cffunction name="search" access="remote" output="false" returntype="void">
		<cfargument name="Search_ID" required="true" type="numeric" > 
		<cfargument name="Append" required="false" type="numeric" default="0" > 
		
		<cfset var getsearch = ''>
		<cfset var done = 0>
		<cfset var num = 0>
		<cfset var keylist = ''>
			
		<cfquery name="getsearch" datasource="book">
		SELECT TOP 1 Search_ID, Air, Car, Hotel, Policy_ID, Profile_ID, Value_ID
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_integer">
		ORDER BY Search_ID DESC
		</cfquery>
		
		<cfif arguments.Append EQ 0>
			<cfset num = 1>
		<cfelse>
			<cfset keylist = StructKeyArray(session.searches)>
			<cfset ArraySort(keylist, 'text')>
			<cfloop list="#ArraytoList(keylist)#" index="num">			
				<cfif session.searches[num]['Search_ID'] EQ arguments.Search_ID>
					<cfset done = 1>
				</cfif>
			</cfloop>
			<cfif done EQ 0>
				<cfset num++>
			</cfif>
		</cfif>
		
		<cflock timeout="30" scope="session" type="exclusive">
			<cfset session.searches[num] = StructNew()>
			<cfset session.searches[num]['Search_ID'] = arguments.Search_ID>
			<cfset session.searches[num]['Air'] = getsearch.Air>
			<cfset session.searches[num]['Car'] = getsearch.Car>
			<cfset session.searches[num]['Hotel'] = getsearch.Hotel>
			<cfset session.Policy_ID = getsearch.Policy_ID>
			<cfset session.Profile_ID = getsearch.Profile_ID>
			<cfset session.Value_ID = getsearch.Value_ID>
		</cflock>
		
		<cfreturn />
	</cffunction>
	
<!--- session : user --->
	<cffunction name="user" access="remote" output="false" returntype="void">
		<cfargument name="Search_ID" required="false" default=""> 
		
		<cfset var getuser = ''>
		
		<cfquery name="getuser" datasource="book">
		SELECT TOP 1 User_ID, Username
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cflock timeout="30" scope="session" type="exclusive">
			<cfset session.User_ID = getuser.User_ID>
			<cfset session.Username = getuser.Username>
		</cflock>
		
		<cfreturn />
	</cffunction>

<!--- session : account --->
	<cffunction name="account" access="remote" output="false" returntype="void">
		<cfargument name="Search_ID" required="false" default=""> 
		
		<cfset var getAccountID = ''>
		<cfset var tempaccount = StructNew()>
		<cfset var getaccount = ''>
		<cfset var col = ''>
		
		<cfquery name="getAccountID" datasource="book">
		SELECT Acct_ID
		FROM Searches 
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfquery name="getaccount" datasource="Corporate_Production">
		SELECT TOP 1 Accounts.Acct_ID, Accounts.Account_Name, Acct_Logo AS Logo_Image, Account_Brand
		FROM Accounts
		WHERE Accounts.Acct_ID = <cfqueryparam value="#getAccountID.Acct_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfquery name="getpcc" datasource="book">
		SELECT TOP 1 PCC_Booking
		FROM Accounts
		WHERE Accounts.Acct_ID = <cfqueryparam value="#getAccountID.Acct_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfloop list="#getaccount.columnlist#" index="col">
			<cfset session.account.Acct_ID = getaccount.Acct_ID>
			<cfset session.account.Account_Name = getaccount.Account_Name>
			<cfset session.account.Logo_Image = getaccount.Logo_Image>
			<cfset session.account.Account_Brand = getaccount.Account_Brand>
			<cfset session.account.PCC_Booking = getpcc.PCC_Booking>
		</cfloop>

		<cfreturn />
	</cffunction>

<!--- session : tabs --->
	<cffunction name="tabs" access="remote" output="false" returntype="void">
		
		<cfset var num = 0>
		<cfloop list="#StructKeyList(session.searches)#" index="num">
			<cfif NOT StructKeyExists(session.searches[num], 'tab')>
				<cfset session.searches[num].tab = 'Cedar Rapids - 1/1 to 1/5'>
			</cfif>
		</cfloop>

		<cfreturn />
	</cffunction>
	
</cfcomponent>