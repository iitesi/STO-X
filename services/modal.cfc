<cfcomponent output="false">

<!--- init --->
	<cffunction name="init" output="false">
		<cfreturn this />
	</cffunction>

<!--- getHeader --->
	<cffunction name="getHeader" output="false">
		<cfargument name="headerText" required="true" />
		
		<cfset local.headerText = arguments.headerText />
		
		<cfreturn headerText />
	</cffunction>

</cfcomponent>