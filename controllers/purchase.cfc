<cfcomponent output="false">

	<cfset variables.fw = "">
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="fw">

		<cfset variables.fw = arguments.fw>
		<cfset variables.bf = fw.getBeanFactory()>

		<cfreturn this>
	</cffunction>

<!---
default
--->
	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfset rc.stAir = session.searches[arguments.rc.SearchID].stItinerary.Air>
		<cfset variables.bf.getBean("AirCreate").doAirCreate(argumentcollection=arguments.rc)>

		<cfreturn />
	</cffunction>
	
</cfcomponent>