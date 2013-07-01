<cfcomponent extends="abstract">

<!---
default
--->
	<cffunction name="default" output="false">
		<cfargument name="rc">

	  <cfset fw.getBeanFactory().getBean('couldyou').doCouldYou(argumentcollection=arguments.rc)>

		<cfreturn />
	</cffunction>

</cfcomponent>