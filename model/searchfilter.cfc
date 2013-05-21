<cfcomponent accessors="true">

	<cfproperty name="AcctID">
	<cfproperty name="Air">
	<cfproperty name="AirHeading">
	<cfproperty name="Airlines">
	<cfproperty name="AirType">
	<cfproperty name="Arrival_City">
	<cfproperty name="ArrivalCity">
	<cfproperty name="ArrivalDate">
	<cfproperty name="ArrivalType">
	<cfproperty name="BookingFor">
	<cfproperty name="Car">
	<cfproperty name="CarHeading">
	<cfproperty name="CheckIn_Date">
	<cfproperty name="CheckOut_Date">
	<cfproperty name="COS">
	<cfproperty name="DepartCity">
	<cfproperty name="DepartDate">
	<cfproperty name="DepartType">
	<cfproperty name="Destination">
	<cfproperty name="Heading">
	<cfproperty name="Hotel">
	<cfproperty name="Hotel_Address">
	<cfproperty name="Hotel_Airport">
	<cfproperty name="Hotel_City">
	<cfproperty name="Hotel_Country">
	<cfproperty name="Hotel_Landmark">
	<cfproperty name="Hotel_Radius">
	<cfproperty name="Hotel_Search">
	<cfproperty name="Hotel_State">
	<cfproperty name="Hotel_Zip">
	<cfproperty name="HotelHeading">
	<cfproperty name="International">
	<cfproperty name="Legs">
	<cfproperty name="Office_ID">
	<cfproperty name="PolicyID">
	<cfproperty name="ProfileID">
	<cfproperty name="SearchID">
	<cfproperty name="UserID">
	<cfproperty name="Username">
	<cfproperty name="ValueID">

	<cffunction name="init" output="false">
		<cfset setLegs([])>
		<cfreturn this>
	</cffunction>

	<cffunction name="addLeg" output="false">
		<cfargument name="objLeg">
		<cfset arrayAppend(Legs, arguments.objLeg)>
	</cffunction>

</cfcomponent>