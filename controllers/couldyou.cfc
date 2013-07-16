<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<!---TODO: Replace this with logic to get the start/end date based on services selected--->
		<cfset rc.startDate = arguments.rc.Filter.getCheckInDate() />
		<cfset rc.endDate = arguments.rc.Filter.getCheckOutDate() />

		<cfreturn />
	</cffunction>

</cfcomponent>