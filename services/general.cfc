<cfcomponent output="false">

<!---
init
--->
	<cffunction name="init" output="false">

		<cfreturn this>
	</cffunction>
		
<!--- 
getUser
--->
	<cffunction name="getUser" output="false">
		<cfargument name="UserID" required="true">
		
		<cfquery name="local.qUser" datasource="Corporate_Production">
		SELECT First_Name, Last_Name, Email, Phone_Number
		FROM Users
		LEFT OUTER JOIN Biz_Contact_Info ON Users.User_ID = Biz_Contact_Info.User_ID
		WHERE Users.User_ID = <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_integer" >
		</cfquery>
		
		<cfreturn qUser />
	</cffunction>

</cfcomponent>