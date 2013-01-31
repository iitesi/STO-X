<cfcomponent output="false">
		
<!--- 
getUser
--->
	<cffunction name="getUser" output="false">
		<cfargument name="UserID" required="true">
		
		<cfquery name="local.qUser" datasource="Corporate_Production">
		SELECT First_Name, Last_Name, Email
		FROM Users
		WHERE User_ID = <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_integer" >
		</cfquery>
		
		<cfreturn qUser />
	</cffunction>

</cfcomponent>