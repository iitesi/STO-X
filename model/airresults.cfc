<cfcomponent accessors="true">

	<cfproperty name="aSortFare">
	<cfproperty name="aSortDept">
	<cfproperty name="Pricing">
	<cfproperty name="Trips">

	<cffunction name="init" output="false">

		<cfset setPricing({})>
		<cfset setTrips({})>

		<cfreturn this>
	</cffunction>

	<cffunction name="addPricing" output="false">
		<cfargument name="sCabin">
		<cfargument name="bRef">

		<cfset Pricing[arguments.sCabin&arguments.bRef] = ''>

	</cffunction>

	<cffunction name="addTrip" output="false">
		<cfargument name="sTripKey">
		<cfargument name="objTrip">

		<cfset Trips[arguments.sTripKey] = arguments.objTrip>

	</cffunction>

</cfcomponent>