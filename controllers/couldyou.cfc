<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfset rc.startDate = arguments.rc.Filter.getCheckInDate() />
		<cfset rc.endDate = arguments.rc.Filter.getCheckOutDate() />

		<cfreturn />
	</cffunction>

</cfcomponent>