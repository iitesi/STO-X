<cfcomponent output="true">

	<cfset variables.fw = "">
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="fw">
		<cfset variables.fw = arguments.fw>
		<cfreturn this>
	</cffunction>

<!--- session : security --->
	<cffunction name="security" access="public" output="true">
		
		<cfset variables.fw.service('session.search', 'search')>
		<cfset variables.fw.service('session.user', 'user')>
		<cfset variables.fw.service('session.account', 'account')>
		<cfset variables.fw.service('session.tabs', 'tabs')>
		
		<cfreturn />
	</cffunction>

</cfcomponent>