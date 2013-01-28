<cfcomponent accessors="true">

	<cfproperty name="arrivalTime">
	<cfproperty name="cabin">
	<cfproperty name="carrier">
	<cfproperty name="changeOfPlane">
	<cfproperty name="class">
	<cfproperty name="departureTime">
	<cfproperty name="destination">
	<cfproperty name="equipment">
	<cfproperty name="flightNumber">
	<cfproperty name="group">
	<cfproperty name="origin">
	<cfproperty name="travelTime">

	<cffunction name="init" output="false">

		<cfreturn this>
	</cffunction>

	<cffunction name="populate" output="false">
		<cfargument name="Data">

		<cfloop collection="#arguments.Data#" item="local.Key">
			<cfset variables[Key] = arguments.Data[Key]>
		</cfloop>

	</cffunction>

</cfcomponent>