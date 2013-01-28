<cfcomponent accessors="true">

	<cfproperty name="arrivalTime">
	<cfproperty name="departureTime">
	<cfproperty name="destination">
	<cfproperty name="origin">
	<cfproperty name="stops">
	<cfproperty name="travelTime">
	<cfproperty name="segments">

	<cffunction name="init" output="false">

		<cfset setSegments({})>

		<cfreturn this>
	</cffunction>

	<cffunction name="addSegment" output="false">
		<cfargument name="sSegKey">
		<cfargument name="objSegment">

		<cfset segments[arguments.sSegKey] = arguments.objSegment>

	</cffunction>

	<cffunction name="populate" output="false">
		<cfargument name="Data">

		<cfloop collection="#arguments.Data#" item="local.Key">
			<cfset variables[Key] = arguments.Data[Key]>
		</cfloop>

	</cffunction>

</cfcomponent>