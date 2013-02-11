<cfcomponent>

<!---
init
--->
	<cfset variables.fw = ''>
	<cffunction name="init" output="false">
		<cfargument name="fw">

		<cfset variables.fw = arguments.fw>

		<cfreturn this>
	</cffunction>

<!---
default
--->
	<cffunction name="default" output="false">
		<cfargument name="rc">
		
	  <cfset fw.getBeanFactory().getBean('couldyou').doCouldYou(argumentcollection=arguments.rc)>

		<cfreturn />
	</cffunction>

</cfcomponent>