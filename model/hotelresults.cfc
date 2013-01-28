<cfcomponent accessors="true">

	<cfproperty name="Hotels">

	<cffunction name="init" output="false">

		<cfset setHotels({})>

		<cfreturn this>
	</cffunction>

</cfcomponent>