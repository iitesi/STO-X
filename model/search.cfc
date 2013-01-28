<cfcomponent accessors="true">

	<cfproperty name="filter">
	<cfproperty name="fareTrips">
	<cfproperty name="scheduleTrips">

	<cffunction name="init" output="false">

		<cfset setFareTrips({})>
		<cfset setScheduleTrips({})>

		<cfreturn this>
	</cffunction>

	<cffunction name="addTrips" output="false">
		<cfargument name="sTripType">
		<cfargument name="sTripKey">
		<cfargument name="objTrip">

		<cfset variables[arguments.sTripType][arguments.sTripKey] = arguments.objTrip>

	</cffunction>

</cfcomponent>