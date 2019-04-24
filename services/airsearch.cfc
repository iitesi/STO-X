<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="KrakenService">
	<cfproperty name="Storage">
	<cfproperty name="LowFare">

	<cffunction name="init" output="false" hint="Init method.">
		<cfargument name="KrakenService">
		<cfargument name="Storage">
		<cfargument name="LowFare">

		<cfset setKrakenService(arguments.KrakenService)>
		<cfset setStorage(arguments.Storage)>
		<cfset setLowFare(arguments.LowFare)>

		<cfreturn this>
	</cffunction>

	<cffunction name="doAirSearch" output="false">
		<cfargument name="Filter">
		<cfargument name="SearchID">

		<cfset var requestBody = getLowFare().getFlightSearchRequest(Policy = arguments.Policy,
																	Filter = arguments.Filter)>

		<cfset var response = getStorage().getStorage(searchID = arguments.searchID,
													request = requestBody )>

		<cfif structIsEmpty(response)>

			<cfset response = getKrakenService().AirSearch(body = requestBody,
															SearchID = arguments.SearchID)>

			<cfset getStorage().storeAir(searchID = arguments.searchID,
										request = requestBody,
										storage = response )>
		</cfif>

		<cfreturn response>
 	</cffunction>
 	
</cfcomponent>