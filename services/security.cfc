<cfcomponent output="false">

	<cffunction name="close" output="false">
		<cfargument name="SearchID">

		<cfset local.temp = StructDelete(session.searches, arguments.SearchID)>
		<cfset local.nNewSearchID = "">

		<cfloop collection="#session.searches#" item="local.SearchID">
			<cfset local.nNewSearchID = local.SearchID>
			<cfbreak>
		</cfloop>

		<cfreturn local.nNewSearchID/>
	</cffunction>

</cfcomponent>