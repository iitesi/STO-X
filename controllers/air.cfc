<cfcomponent>

	<cfset variables.fw = "">
<!--- init --->
	<cffunction name="init" access="public" output="true" returntype="any">
		<cfargument name="fw">
		<cfset variables.fw = arguments.fw>
		<cfreturn this>
	</cffunction>

<!--- air : default --->
	<cffunction name="default" access="public" output="true">
		
		<cfset variables.fw.service('policy.policyair', 'policyair')>
		<cfset variables.fw.service('airfare.LowFareSearchReq', 'message')>
		<cfset variables.fw.service('uapi.call', 'MasterXML')>
		<cfset variables.fw.service('airfare.parse', 'airsegments')>
		
		<cfreturn />
	</cffunction>

</cfcomponent>