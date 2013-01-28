<cfcomponent accessors="true">

	<cfproperty name="SearchID">
	<cfproperty name="Air">
	<cfproperty name="Car">
	<cfproperty name="Hotel">
	<cfproperty name="AirType">
	<cfproperty name="DepartCity">
	<cfproperty name="DepartDate">
	<cfproperty name="DepartType">
	<cfproperty name="ArrivalCity">
	<cfproperty name="ArrivalDate">
	<cfproperty name="ArrivalType">
	<cfproperty name="Airlines">
	<cfproperty name="International">
	<cfproperty name="COS">
	<cfproperty name="BookingFor">
	<cfproperty name="Destination">
	<cfproperty name="Heading">
	<cfproperty name="ProfileID">
	<cfproperty name="PolicyID">
	<cfproperty name="ValueID">
	<cfproperty name="Legs">
	<cfproperty name="UserID">
	<cfproperty name="AcctID">
	<cfproperty name="Username">

	<cffunction name="init" output="false">

		<cfset setLegs([])>

		<cfreturn this>
	</cffunction>

	<cffunction name="addLeg" output="false">
		<cfargument name="objLeg">

		<cfset arrayAppend(Legs, arguments.objLeg)>

	</cffunction>

</cfcomponent>