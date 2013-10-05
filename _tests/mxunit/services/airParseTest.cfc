<cfcomponent extends="mxunit.framework.TestCase"  name="airPriceTest.cfc" output="false" hint="">
   
	<cffunction name="Setup">
		<!---Set up a mock object to represent the UserService--->
     	<cfset variables.UAPIMock = mock() />

     	<!--- Create the component to be tested --->
        <cfset variables.AirParse = createObject('component','booking.services.airparse').init( variables.UAPIMock ) />
	</cffunction>

	<cffunction name="testCalculateTripTime" >
		<cfset var data = nonStopSegmentData() />
		<cfset assertEquals( 63, variables.AirParse.calculateTripTime( data[ '0' ].segments ), "The method did not return the correct trip time for an outbound non-stop segment"  ) />
		<cfset assertEquals( 59, variables.AirParse.calculateTripTime( data[ '1' ].segments ), "The method did not return the correct trip time for an inbound non-stop segment"  ) />

		<cfset data = oneStopSegmentData() />
		<cfset assertEquals( 609, variables.AirParse.calculateTripTime( data[ '0' ].segments ), "The method did not return the correct trip time for an outbound one-stop segment"  ) />
		<cfset assertEquals( 785, variables.AirParse.calculateTripTime( data[ '1' ].segments ), "The method did not return the correct trip time for an inbound one-stop segment"  ) />
	</cffunction>



	<cffunction name="nonStopSegmentData" access="private" output="false" returntype="struct" hint="">
		<cfsavecontent variable="local.data">{"0":{"ARRIVALTIME":"October, 25 2013 07:15:00 -0400","ORIGIN":"CID","SEGMENTS":{"19T":{"ORIGIN":"CID","ARRIVALTIME":"October, 25 2013 07:15:00 -0400","ARRIVALGMT":"October, 25 2013 17:15:00 -0400","CABIN":"Economy","FLIGHTNUMBER":"3623","EQUIPMENT":"CR7","DEPARTURETIME":"October, 25 2013 06:12:00 -0400","CLASS":"W","DESTINATION":"ORD","DEPARTUREGMT":"October, 25 2013 11:12:00 -0400","CARRIER":"UA","CHANGEOFPLANE":false,"TRAVELTIME":"63","FLIGHTTIME":"63","GROUP":"0"}},"STOPS":0,"DEPARTURETIME":"October, 25 2013 06:12:00 -0400","DESTINATION":"ORD","TRAVELTIME":"1h 3m"},"1":{"ARRIVALTIME":"October, 26 2013 10:54:00 -0400","ORIGIN":"ORD","SEGMENTS":{"28T":{"ORIGIN":"ORD","ARRIVALTIME":"October, 26 2013 10:54:00 -0400","ARRIVALGMT":"October, 26 2013 20:54:00 -0400","CABIN":"Economy","FLIGHTNUMBER":"3834","EQUIPMENT":"ERJ","DEPARTURETIME":"October, 26 2013 09:55:00 -0400","CLASS":"W","DESTINATION":"CID","DEPARTUREGMT":"October, 26 2013 14:55:00 -0400","CARRIER":"UA","CHANGEOFPLANE":false,"TRAVELTIME":"59","FLIGHTTIME":"59","GROUP":"1"}},"STOPS":0,"DEPARTURETIME":"October, 26 2013 09:55:00 -0400","DESTINATION":"CID","TRAVELTIME":"0h 59m"}}</cfsavecontent>

		<cfreturn deserializeJSON( local.data ) />
	</cffunction>

	<cffunction name="oneStopSegmentData" access="private" output="false" returntype="struct" hint="">
		<cfsavecontent variable="local.data">{"0":{"ARRIVALTIME":"October, 25 2013 16:09:00 -0400","ORIGIN":"CID","SEGMENTS":{"32T":{"ORIGIN":"CID","ARRIVALTIME":"October, 25 2013 05:59:00 -0400","ARRIVALGMT":"October, 25 2013 15:59:00 -0400","CABIN":"Economy","FLIGHTNUMBER":"6064","EQUIPMENT":"ER4","DEPARTURETIME":"October, 25 2013 05:00:00 -0400","CLASS":"W","DESTINATION":"ORD","DEPARTUREGMT":"October, 25 2013 10:00:00 -0400","CARRIER":"UA","CHANGEOFPLANE":false,"TRAVELTIME":"609","FLIGHTTIME":"59","GROUP":"0"},"3T":{"ORIGIN":"ORD","ARRIVALTIME":"October, 25 2013 16:09:00 -0400","ARRIVALGMT":"October, 26 2013 02:09:00 -0400","CABIN":"Economy","FLIGHTNUMBER":"1133","EQUIPMENT":"738","DEPARTURETIME":"October, 25 2013 13:11:00 -0400","CLASS":"L","DESTINATION":"RDU","DEPARTUREGMT":"October, 25 2013 18:11:00 -0400","CARRIER":"UA","CHANGEOFPLANE":false,"TRAVELTIME":"537","FLIGHTTIME":"118","GROUP":"0"}},"STOPS":1,"DEPARTURETIME":"October, 25 2013 05:00:00 -0400","DESTINATION":"RDU","TRAVELTIME":"10h 9m"},"1":{"ARRIVALTIME":"October, 26 2013 19:05:00 -0400","ORIGIN":"RDU","SEGMENTS":{"43T":{"ORIGIN":"RDU","ARRIVALTIME":"October, 26 2013 08:11:00 -0400","ARRIVALGMT":"October, 26 2013 18:11:00 -0400","CABIN":"Economy","FLIGHTNUMBER":"751","EQUIPMENT":"319","DEPARTURETIME":"October, 26 2013 07:00:00 -0400","CLASS":"L","DESTINATION":"ORD","DEPARTUREGMT":"October, 26 2013 11:00:00 -0400","CARRIER":"UA","CHANGEOFPLANE":false,"TRAVELTIME":"785","FLIGHTTIME":"131","GROUP":"1"},"7T":{"ORIGIN":"ORD","ARRIVALTIME":"October, 26 2013 19:05:00 -0400","ARRIVALGMT":"October, 27 2013 05:05:00 -0400","CABIN":"Economy","FLIGHTNUMBER":"4323","EQUIPMENT":"ERJ","DEPARTURETIME":"October, 26 2013 18:08:00 -0400","CLASS":"T","DESTINATION":"CID","DEPARTUREGMT":"October, 26 2013 23:08:00 -0400","CARRIER":"UA","CHANGEOFPLANE":false,"TRAVELTIME":"595","FLIGHTTIME":"57","GROUP":"1"}},"STOPS":1,"DEPARTURETIME":"October, 26 2013 07:00:00 -0400","DESTINATION":"CID","TRAVELTIME":"13h 5m"}}</cfsavecontent>

		<cfreturn deserializeJSON( local.data ) />
	</cffunction>
</cfcomponent>
