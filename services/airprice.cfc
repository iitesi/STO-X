<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="UAPIFactory">
	<cfproperty name="uAPISchemas">
	<cfproperty name="KrakenService">
	<cfproperty name="Storage">

	<cffunction name="init" output="false" hint="Init method.">
		<cfargument name="UAPIFactory">
		<cfargument name="uAPISchemas">
		<cfargument name="KrakenService">
		<cfargument name="Storage">

		<cfset setUAPIFactory(arguments.UAPIFactory)>
		<cfset setUAPISchemas(arguments.uAPISchemas)>
		<cfset setKrakenService(arguments.KrakenService)>
		<cfset setStorage(arguments.Storage)>

		<cfreturn this>
	</cffunction>

	<cffunction name="doAirPrice" output="false">
		<cfargument name="Policy" required="true">
		<cfargument name="Filter" required="false" default="X">
		<cfargument name="SearchID" default="">
		<cfargument name="Selected" default="">

		<cfset local.requestBody = getKrakenService().getAirPriceRequest( 	Filter = arguments.Filter,
																			Selected = arguments.Selected )>

		<cfset local.response = getStorage().getStorage(	searchID = arguments.searchID,
															request = local.requestBody )>

		<cfif structIsEmpty(local.response)>
			<cfset local.response = getKrakenService().AirPrice(	body = local.requestBody,
																	SearchID = arguments.SearchID )>

			<cfset getStorage().storeAir(	searchID = arguments.searchID,
											request = local.requestBody,
											storage = local.response )>
		</cfif>

		<cfreturn local.response>
 	</cffunction>
</cfcomponent>
