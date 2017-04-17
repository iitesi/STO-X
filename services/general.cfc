<cfcomponent output="false">

	<cffunction name="init" output="false">
		<cfreturn this>
	</cffunction>

	<cffunction name="getUser" output="false" hint="I get the user.">
		<cfargument name="userID" type="numeric" required="true">

		<cfquery name="local.qUser" datasource="Corporate_Production">
			SELECT First_Name
			, Last_Name
			, Email
			, Phone_Number
			FROM Users
			LEFT OUTER JOIN Biz_Contact_Info ON Users.User_ID = Biz_Contact_Info.User_ID
			WHERE Users.User_ID = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer" >
		</cfquery>

		<cfreturn qUser />
	</cffunction>

	<cffunction name="getTrip" output="false" hint="">
		<cfargument name="SearchID" type="numeric" required="true">
		<cfargument name="PropertyID" type="numeric" required="true">
		<cfquery name="local.getTrip" datasource="booking">
			SELECT TOP 1 ResultsJSON
			FROM FindItOptions_Hotel
			WHERE SearchID = <cfqueryparam value="#arguments.searchID#" cfsqltype="cf_sql_numeric" />
				AND PropertyID = <cfqueryparam value="#arguments.propertyID#" cfsqltype="cf_sql_varchar" />
			ORDER BY ID DESC
		</cfquery>
		<cfreturn getTrip />
	</cffunction>
</cfcomponent>