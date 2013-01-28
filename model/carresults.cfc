<cfcomponent accessors="true">

	<cfproperty name="Cars">

	<cffunction name="init" output="false">

		<cfset setCars({})>

		<cfreturn this>
	</cffunction>

</cfcomponent>