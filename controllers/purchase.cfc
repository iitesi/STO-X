<cfcomponent>

	<cfset variables.fw = "">
	<cffunction name="init" output="false" returntype="any">
		<cfargument name="fw">
		<cfset variables.fw = arguments.fw>
		<cfreturn this>
	</cffunction>
	
<!---
default
--->
	<cffunction name="default" output="false">
		<cfargument name="rc">
		
		<cfset variables.fw.service('aircreate.doAirCreate', 'void')>

		<cfreturn />
	</cffunction>
	
</cfcomponent>