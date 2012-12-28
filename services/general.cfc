<cfcomponent output="false">
		
<!--- 
getUser
--->
	<cffunction name="getUser" output="false">
		<cfargument name="nUserID" required="true">
		
		<cfquery name="local.qUser" datasource="Corporate_Production">
		SELECT First_Name, Last_Name, Email
		FROM Users
		WHERE User_ID = <cfqueryparam value="#arguments.nUserID#" cfsqltype="cf_sql_integer" >
		</cfquery>
		
		<cfreturn qUser />
	</cffunction>

</cfcomponent>