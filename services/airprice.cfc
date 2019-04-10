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
		<cfargument name="Pricing" default="">
		<cfargument name="CabinClass" default="">

		<cfset local.requestBody = getKrakenService().getAirPriceRequest( 	Filter = arguments.Filter,
																			Selected = arguments.Selected,
																			CabinClass = arguments.CabinClass )>

		<cfset local.response = getStorage().getStorage(	searchID = arguments.searchID,
															request = local.requestBody )>

		<cfif structIsEmpty(local.response)>
			<cfset local.response = getKrakenService().AirPrice(	body = local.requestBody,
																	SearchID = arguments.SearchID )>

			<cfset getStorage().storeAir(	searchID = arguments.searchID,
											request = local.requestBody,
											storage = local.response )>
		</cfif>

		<cfset var Pricing = parseAirPrice(	response = local.response,
											Pricing = arguments.Pricing )>

		<cfreturn local.Pricing>
 	</cffunction>

	<cffunction name="parseAirPrice" output="false">
		<cfargument name="response" default="">
		<cfargument name="Pricing" default="">

		<cfset var Pricing = arguments.Pricing>
		<cfif structKeyExists(arguments.response, 'AirPriceResponse')
			AND structKeyExists(arguments.response.AirPriceResponse, 'AirPriceResultField')>
			<cfloop collection="#arguments.response.AirPriceResponse.AirPriceResultField#" index="local.priceIndex" item="local.AirPriceResultField">
				<cfif structKeyExists(AirPriceResultField, 'AirPricingSolutionField')>
					<cfloop collection="#AirPriceResultField.AirPricingSolutionField#" index="local.solution" item="local.AirPricingSolutionField">
						<cfif structKeyExists(AirPricingSolutionField, 'AirPricingInfoField')>
							<cfloop collection="#AirPricingSolutionField.AirPricingInfoField#" index="local.pricingField" item="local.airPricingInfoField">
								<cfif structKeyExists(airPricingInfoField, 'TotalPriceField')>
									<cfset var Solution = {}>
									<cfset Solution.TotalFare = airPricingInfoField.TotalPriceField>
									<cfset Solution.Refundable = airPricingInfoField.RefundableFieldSpecified>
									<cfset Solution.PlatingCarrier = airPricingInfoField.PlatingCarrierField>
									<cfset Solution.BookingInfo = []>
									<cfset var BookingInfo = {}>
									<cfloop collection="#airPricingInfoField.BookingInfoField#" index="local.bookingFieldIndex" item="local.bookingField">
										<cfset BookingInfo.BookingCode = bookingField.BookingCodeField>
										<cfset BookingInfo.CabinClass = bookingField.CabinClassField>
										<cfset arrayAppend(Solution.BookingInfo, BookingInfo)>
									</cfloop>
									<cfset arrayAppend(Pricing, Solution)>
								</cfif>
							</cfloop>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn Pricing>
 	</cffunction>
</cfcomponent>
