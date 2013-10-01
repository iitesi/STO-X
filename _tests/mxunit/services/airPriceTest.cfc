<cfcomponent extends="mxunit.framework.TestCase"  name="airPriceTest.cfc" output="false" hint="">
   
	<cffunction name="Setup">
		<!---Set up a mock object to represent the UserService--->
     	<cfset variables.UAPIMock = mock() />
     	<cfset variables.AirParseMock = mock() />
     	<cfset variables.AirAdapterMock = mock() />

     	<cfset variables.UAPISchemas = structNew() />
     	<cfset variables.UAPISchemas.air = "http://www.travelport.com/schema/air_v22_0" />
		<cfset variables.UAPISchemas.common = "http://www.travelport.com/schema/common_v19_0" />
		<cfset variables.UAPISchemas.hotel = "http://www.travelport.com/schema/hotel_v21_0" />
		<cfset variables.UAPISchemas.terminal = "http://www.travelport.com/schema/terminal_v8_0" />
		<cfset variables.UAPISchemas.universal = "http://www.travelport.com/schema/universal_v20_0" />
		<cfset variables.UAPISchemas.vehicle = "http://www.travelport.com/schema/vehicle_v21_0" />


     	<!--- Create the component to be tested --->
        <cfset variables.AirPrice = createObject('component','booking.services.airprice').init( variables.UAPIMock, variables.UAPISchemas, variables.airadaptermock, variables.airadaptermock ) />
	</cffunction>

	<cffunction name="testgetTripKey" >
		<cfset var args = structNew() />
		<cfset args.foo = "123" />
		<cfset args.foo2 = "ntrip" />
		<cfset args.nTrip = "XYZ12345" />
		<cfset args.who = "Benny" />

		<cfset assertEquals( 'ntrip', variables.AirPrice.getTripKey( args ), "The method did not return the correct value from the given parameters"  ) />
	</cffunction>
</cfcomponent>
