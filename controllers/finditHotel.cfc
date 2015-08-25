<cfcomponent extends="abstract">

	<cfset variables.bookingDSN = "booking" />

	<!--- Change DSN to DB1 if we are testing Jeff's VB apps
				otherwise we'll use Zeus
	<cfif cgi.local_host IS 'RailoQA'>
		<cfset variables.bookingDSN = "findit">
	</cfif> --->

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfquery name="local.getTrip" datasource="#variables.bookingDSN#">
			SELECT ResultsJSON
			FROM FindItOptions_Hotel
			WHERE SearchID = <cfqueryparam value="#rc.searchID#" cfsqltype="cf_sql_numeric" />
				AND PropertyID = <cfqueryparam value="#rc.propertyID#" cfsqltype="cf_sql_varchar" />
		</cfquery>

		<cfif getTrip.recordCount AND isJSON(local.getTrip.ResultsJSON)>
			<cfset local.trip = deserializeJSON(local.getTrip.ResultsJSON) />

		<cfdump var="#trip#" abort>

			<cfset local.room = trip.rooms[1] />

			<cfset fw.getBeanFactory().getBean('Hotel').select( searchID = rc.searchID
																, propertyID = rc.propertyID
																, ratePlanType = room.ratePlanType
																, ppnBundle = room.ppnBundle
																, totalForStay = room.totalForStay
																, isInPolicy = room.isInPolicy
																, outOfPolicyMessage = room.outOfPolicyMessage
																, findIt = 1) />
		<cfelse>
			<cfset rc.message.addError("The hotel room from FindIt is no longer available.") />
			<cfset variables.fw.redirect("hotel.search?searchID=#rc.searchID#") />
		</cfif>

	</cffunction>

</cfcomponent>