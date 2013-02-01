<cfcomponent output="false">
	
<!--- close --->
	<cffunction name="close" output="false">
		<cfargument name="SearchID">
		
		<cfset local.temp = StructDelete(session.searches, arguments.SearchID)>
		<cfset local.nNewSearchID = ''>
		<cfloop collection="#session.searches#" item="local.SearchID">
			<cfset nNewSearchID = SearchID>
			<cfbreak>
		</cfloop>
		
		<cfreturn nNewSearchID/>
	</cffunction>
	
</cfcomponent>