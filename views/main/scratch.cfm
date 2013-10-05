<cfdump var="#session.searches['282635'].stTrips#"/>


<cfabort>

<cfsavecontent variable="nonstop">{"0":{"ARRIVALTIME":"October, 25 2013 07:15:00 -0400","ORIGIN":"CID","SEGMENTS":{"19T":{"ORIGIN":"CID","ARRIVALTIME":"October, 25 2013 07:15:00 -0400","ARRIVALGMT":"October, 25 2013 17:15:00 -0400","CABIN":"Economy","FLIGHTNUMBER":"3623","EQUIPMENT":"CR7","DEPARTURETIME":"October, 25 2013 06:12:00 -0400","CLASS":"W","DESTINATION":"ORD","DEPARTUREGMT":"October, 25 2013 11:12:00 -0400","CARRIER":"UA","CHANGEOFPLANE":false,"TRAVELTIME":"63","FLIGHTTIME":"63","GROUP":"0"}},"STOPS":0,"DEPARTURETIME":"October, 25 2013 06:12:00 -0400","DESTINATION":"ORD","TRAVELTIME":"1h 3m"},"1":{"ARRIVALTIME":"October, 26 2013 10:54:00 -0400","ORIGIN":"ORD","SEGMENTS":{"28T":{"ORIGIN":"ORD","ARRIVALTIME":"October, 26 2013 10:54:00 -0400","ARRIVALGMT":"October, 26 2013 20:54:00 -0400","CABIN":"Economy","FLIGHTNUMBER":"3834","EQUIPMENT":"ERJ","DEPARTURETIME":"October, 26 2013 09:55:00 -0400","CLASS":"W","DESTINATION":"CID","DEPARTUREGMT":"October, 26 2013 14:55:00 -0400","CARRIER":"UA","CHANGEOFPLANE":false,"TRAVELTIME":"59","FLIGHTTIME":"59","GROUP":"1"}},"STOPS":0,"DEPARTURETIME":"October, 26 2013 09:55:00 -0400","DESTINATION":"CID","TRAVELTIME":"0h 59m"}}</cfsavecontent>
<cfsavecontent variable="onestop">{"0":{"ARRIVALTIME":"October, 25 2013 16:09:00 -0400","ORIGIN":"CID","SEGMENTS":{"32T":{"ORIGIN":"CID","ARRIVALTIME":"October, 25 2013 05:59:00 -0400","ARRIVALGMT":"October, 25 2013 15:59:00 -0400","CABIN":"Economy","FLIGHTNUMBER":"6064","EQUIPMENT":"ER4","DEPARTURETIME":"October, 25 2013 05:00:00 -0400","CLASS":"W","DESTINATION":"ORD","DEPARTUREGMT":"October, 25 2013 10:00:00 -0400","CARRIER":"UA","CHANGEOFPLANE":false,"TRAVELTIME":"609","FLIGHTTIME":"59","GROUP":"0"},"3T":{"ORIGIN":"ORD","ARRIVALTIME":"October, 25 2013 16:09:00 -0400","ARRIVALGMT":"October, 26 2013 02:09:00 -0400","CABIN":"Economy","FLIGHTNUMBER":"1133","EQUIPMENT":"738","DEPARTURETIME":"October, 25 2013 13:11:00 -0400","CLASS":"L","DESTINATION":"RDU","DEPARTUREGMT":"October, 25 2013 18:11:00 -0400","CARRIER":"UA","CHANGEOFPLANE":false,"TRAVELTIME":"537","FLIGHTTIME":"118","GROUP":"0"}},"STOPS":1,"DEPARTURETIME":"October, 25 2013 05:00:00 -0400","DESTINATION":"RDU","TRAVELTIME":"10h 9m"},"1":{"ARRIVALTIME":"October, 26 2013 19:05:00 -0400","ORIGIN":"RDU","SEGMENTS":{"43T":{"ORIGIN":"RDU","ARRIVALTIME":"October, 26 2013 08:11:00 -0400","ARRIVALGMT":"October, 26 2013 18:11:00 -0400","CABIN":"Economy","FLIGHTNUMBER":"751","EQUIPMENT":"319","DEPARTURETIME":"October, 26 2013 07:00:00 -0400","CLASS":"L","DESTINATION":"ORD","DEPARTUREGMT":"October, 26 2013 11:00:00 -0400","CARRIER":"UA","CHANGEOFPLANE":false,"TRAVELTIME":"785","FLIGHTTIME":"131","GROUP":"1"},"7T":{"ORIGIN":"ORD","ARRIVALTIME":"October, 26 2013 19:05:00 -0400","ARRIVALGMT":"October, 27 2013 05:05:00 -0400","CABIN":"Economy","FLIGHTNUMBER":"4323","EQUIPMENT":"ERJ","DEPARTURETIME":"October, 26 2013 18:08:00 -0400","CLASS":"T","DESTINATION":"CID","DEPARTUREGMT":"October, 26 2013 23:08:00 -0400","CARRIER":"UA","CHANGEOFPLANE":false,"TRAVELTIME":"595","FLIGHTTIME":"57","GROUP":"1"}},"STOPS":1,"DEPARTURETIME":"October, 26 2013 07:00:00 -0400","DESTINATION":"CID","TRAVELTIME":"13h 5m"}}</cfsavecontent>

<cfset layover = dateDiff( "n", 'October, 25 2013 05:59:00 -0400', 'October, 25 2013 13:11:00 -0400' ) />
<cfset totalTripTime = 59 + 118 + layover />
<cfoutput>#totalTripTime#</cfoutput>

<cfset nonStopData = deserializeJSON(nonstop) />
<cfset oneStopData = deserializeJSON(onestop) />
<cfdump var="#nonStopData#"/>
<cfdump var="#oneStopData#"/>

<cfabort>

<cfset var tmpArray = [] />
<cfloop collection="#oneStopData['0'].segments#" item="local.segmentId">
	<cfset oneStopData['0'].segments[ segmentId ].segmentId = segmentId />
	<cfset arrayAppend( tmpArray, oneStopData['0'].segments[ segmentID ] ) />
</cfloop>
<cfdump var="#ArrayOfStructSort( tmpArray, "textnocase", "DESC", "DepartureTime")#"/>

<cfset totalTripTime = 0 />
<cfloop from="1" to="#arrayLen( tmpArray )#" index="i" >
	<cfoutput>#totalTripTime#<br></cfoutput>
	<cfset totalTripTime = totalTripTime + tmpArray[ i ].FlightTime />
	<cfoutput>#totalTripTime#<br></cfoutput>
	<cfif i NEQ arrayLen( tmpArray )>
		<cfset var layover = abs( dateDiff( "n", tmpArray[ i+1 ].DepartureTime, tmpArray[ i ].ArrivalTime ) ) />
		<cfset totalTripTime = totalTripTime + layover />
		<cfoutput>#totalTripTime#<br></cfoutput>
	</cfif>
	<br><Br>
</cfloop>

<cfdump var="#totalTripTime#"/>






<cffunction name="ArrayOfStructSort" returntype="array" access="private">
	<cfargument name="base" type="array" required="yes" />
	<cfargument name="sortType" type="string" required="no" default="text" />
	<cfargument name="sortOrder" type="string" required="no" default="ASC" />
	<cfargument name="pathToSubElement" type="string" required="no" default="" />

	<cfset var tmpStruct = StructNew()>
	<cfset var returnVal = ArrayNew(1)>
	<cfset var i = 0>
	<cfset var keys = "">

	<cfloop from="1" to="#ArrayLen(base)#" index="i">
		<cfset tmpStruct[i] = base[i]>
	</cfloop>

	<cfset keys = StructSort(tmpStruct, sortType, sortOrder, pathToSubElement)>

	<cfloop from="1" to="#ArrayLen(keys)#" index="i">
		<cfset returnVal[i] = tmpStruct[keys[i]]>
	</cfloop>

	<cfreturn returnVal>
</cffunction>

<cfabort>
<cfdump var="#serializeJSON( session.searches[rc.SearchID].stTrips[ '-1166883937'].groups )#" />


<cfdump var="#session.searches[rc.SearchID].stTrips#" />
