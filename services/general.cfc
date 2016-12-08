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

</cfcomponent>