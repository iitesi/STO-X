<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc" />

		<cfset rc.Sell = session.searches[SearchId].Sell>

		<cfreturn />
	</cffunction>

</cfcomponent>