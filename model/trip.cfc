<cfcomponent accessors="true">

	<cfproperty name="arrival">
	<cfproperty name="base">
	<cfproperty name="carriers">
	<cfproperty name="class">
	<cfproperty name="depart">
	<cfproperty name="duration">
	<cfproperty name="groups">
	<cfproperty name="ptc">
	<cfproperty name="ref">
	<cfproperty name="segments">
	<cfproperty name="stops">
	<cfproperty name="taxes">
	<cfproperty name="total">
	<cfproperty name="totalbag">

	<cffunction name="init" output="false">

		<cfset setGroups({})>

		<cfreturn this>
	</cffunction>

	<cffunction name="addGroup" output="false">
		<cfargument name="sGroupKey">
		<cfargument name="objGroup">

		<cfset groups[arguments.sGroupKey] = arguments.objGroup>

	</cffunction>

</cfcomponent>