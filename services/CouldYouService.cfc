<cfcomponent output="false" accessors="true">

	<cfproperty name="CouldYouManager"/>

	<cffunction name="init" access="public" output="false" returntype="any" hint="">
		<cfargument name="CouldYouManager" type="any" required="true" />

		<cfset setCouldYouManager( arguments.CouldYouManager ) />

		<cfreturn this>
	</cffunction>

	<cffunction name="logOriginalTrip" access="public" output="false" returntype="any" hint="">
		<cfargument name="trip" type="struct" required="true" hint="I am the structure of originally selected air, hotel and vehicle options for a search" />

		<cfset var args = structNew() />
		<cfset args.isOriginal = true />

		<cfset getCouldYouManager().logTrip( argumentCollection = args ) />
	</cffunction>

	<cffunction name="logAlternateTrip" access="public" output="false" returntype="any" hint="">
		<cfargument name="trip" type="struct" required="true" hint="Structure with air, hotel and vehicle data retrieved during a CouldYou search" />

		<cfset var args = structNew() />
		<cfset args.isOriginal = false />



		<cfset getCouldYouManager().logTrip( argumentCollection = args ) />

	</cffunction>


</cfcomponent>