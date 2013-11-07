<cfcomponent hint="Helpers for air.">

	<!--- init --->
	<cffunction name="init" access="public" output="false">
		<cfreturn this />
	</cffunction>

	<cffunction name="getTripDays" returntype="String" access="public" output="false" hint="I calculate the number of days in a trip. Used in badges to display +1 Day, etc. on badges, trip details, summary, etc.">
		<cfargument name="departureTime" required="yes" />
		<cfargument name="arrivalTime" required="yes" />
		<cfset local.tripLength = "">
		<cfif dateDiff("d", arguments.DepartureTime, arguments.ArrivalTime) GT 0>
			<cfset day = "day">
			<cfif dateDiff("d", arguments.DepartureTime, arguments.ArrivalTime) GT 1>
				<cfset day = "days">
			</cfif>
			<cfset local.tripLength = "&nbsp; <span class='tripLength'>+#dateDiff('d', arguments.DepartureTime, arguments.ArrivalTime)# #day#</span>">
		</cfif>
		<cfreturn local.tripLength />
	</cffunction>
</cfcomponent>