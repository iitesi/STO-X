<cfcomponent output="false" accessors="true">

	<cfproperty name="UAPI">
	<cfproperty name="uAPISchemas" />
	<cfproperty name="AirParse">

	<cffunction name="init" output="false">
		<cfargument name="UAPI">
    	<cfargument name="uAPISchemas" type="any" required="true" />
		<cfargument name="AirParse">

		<cfset setUAPI(arguments.UAPI)>
    	<cfset setUAPISchemas( arguments.uAPISchemas ) />
		<cfset setAirParse(arguments.AirParse)>

		<cfreturn this>
	</cffunction>

	<cffunction name="selectLeg" output="false">
		<cfargument name="SearchID">
		<cfargument name="Group">
		<cfargument name="nTrip">

		<cfset session.searches[arguments.SearchID].stSelected[arguments.Group] = session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTrip]>

		<cfreturn />
	</cffunction>

	<cffunction name="threadAvailability" output="false">
		<cfargument name="Filter" required="true">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="Group" required="false">

		<cfset local.stThreads = {}>
		<cfset local.sThreadName = ''>
		<cfset local.sPriority = ''>

		<!--- Create a thread for every leg.  Give priority to the group specifically selected. --->
		<cfloop collection="#arguments.Filter.getLegsForTrip()#" item="local.nLeg" index="local.nLegIndex">
			<cfif arguments.Group EQ local.nLegIndex-1>
				<cfset local.sPriority = 'HIGH'>
			<cfelse>
				<cfset local.sPriority = 'LOW'>
			</cfif>
			<cfset local.sThreadName = doAvailability( Filter = arguments.Filter
												, Group = local.nLegIndex-1
												, Account = arguments.Account
												, Policy = arguments.Policy
												, sPriority = local.sPriority)>

			<cfif local.sPriority EQ 'HIGH' AND local.sThreadName NEQ ''>
				<cfset local.stThreads[local.sThreadName] = ''>
			</cfif>
		</cfloop>
		<!--- Join only if threads where thrown out. --->
		<cfif NOT StructIsEmpty(local.stThreads)
			AND local.sPriority EQ 'HIGH'>
			<cfthread action="join" name="#structKeyList(local.stThreads)#" />
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="doAvailability" output="false">
		<cfargument name="Filter" required="true">
		<cfargument name="Group" required="true">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="sPriority" required="false"	default="HIGH">

		<cfset local.sThreadName = "">

		<!--- Don't go back to the getUAPI if we already got the data. --->
		<cfif NOT structKeyExists(session.searches, arguments.Filter.getSearchID())
			OR NOT structKeyExists(session.searches[arguments.Filter.getSearchID()], 'stAvailDetails')
			OR NOT structKeyExists(session.searches[arguments.Filter.getSearchID()].stAvailDetails, 'stGroups')
			OR NOT structKeyExists(session.searches[arguments.Filter.getSearchID()].stAvailDetails.stGroups, arguments.Group)>

			<cfset local.sThreadName = 'Group'&arguments.Group>
			<cfset local[local.sThreadName] = {}>

			<!--- Note:  To debug: comment out opening and closing cfthread tags and
			dump sMessage or sResponse to see what uAPI is getting and sending back --->

			<cfthread
				action="run"
				name="#local.sThreadName#"
				priority="#arguments.sPriority#"
				Filter="#arguments.Filter#"
				Group="#arguments.Group#"
				Account="#arguments.Account#"
				Policy="#arguments.Policy#">

 				<cfset attributes.sNextRef = 'ROUNDONE'>
				<cfset attributes.nCount = 0>

				<cfloop condition="attributes.sNextRef NEQ ''">
					<cfset attributes.nCount++>
					<!--- Put together the SOAP message. --->
					<cfset attributes.sMessage = prepareSoapHeader(arguments.Filter, arguments.Group, (attributes.sNextRef NEQ 'ROUNDONE' ? attributes.sNextRef : ''), arguments.Account)>
					<!--- Call the getUAPI. --->
					<cfset attributes.sResponse = getUAPI().callUAPI('AirService', attributes.sMessage, arguments.Filter.getSearchID(), arguments.Filter.getAcctID(), arguments.Filter.getUserID())>

<!--- use to spoof a GOOD request
2:15 PM Wednesday, September 25, 2013 - Jim Priest - jpriest@shortstravel.com

	If the uAPI is really slow (esp on r.local) you can uncomment this to spoof a uAPI response.

	* Uncomment the cfsavecontent below
	* Comment out the getUAPI().callUAPI above

	Please be aware you will get the same flight for each request!  But this is useful if you
	just need a result - like when testing  filters for example
--->
<!---
<cfsavecontent variable="attributes.sResponse">
	<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/"><SOAP:Body><air:AvailabilitySearchRsp xmlns:air="http://www.travelport.com/schema/air_v22_0" xmlns:common_v19_0="http://www.travelport.com/schema/common_v19_0"  TransactionId="554FDB4C0A07611407B77CA0A6C80A11" ResponseTime="1768" DistanceUnits="MI"><common_v19_0:NextResultReference>H4sIAAAAAAAAAJ1UvU8UQRR/t9zJhxACKDEYRaMRC929O5Hjq+FLgi4f4dACpBhuh2Vwb3eZHWAxxkQbbWxojCZWRBITazUxodXSGAujsTDY+gdQGHwz3AErKtEtZnfe+73fvI/f7PPvkAg41M2SBaLPC+boXZyTJZMFIrzz/tijN+RJCcQGIB6wmzT0ASC2GMe1AoPO57y8bqeDRSZyM7ptBTqxiC8oD3T05D1X7wsFJzkx5t2grnn3cyPbrFnVoGwCDhLOx1ieynMEpCZMDDCKVAZS5T2LOsYWjSGRWZ/m2DTLEcE8twMZLOrvMLTtw3DJoSGbcuheJlMyBYK5aiug1pStMBzi2kZWcObaCEnY3Jv3BdTtcg64gtqUo7c873GqapyD25Aw4YDHmc2Ku0qfewvMorwHMyrYEmIbHvrzvNCBSDNV/sVG7s376Ylr79YeZh5oAGosgCxt+7D8uQsfXk+2H723Pllki+F4W/6PK131bTprNH/SIGZCdUAJz80oHfSSpUCA/vdBZaP4jpCD/m+deXG/e0X7YVoaxMehngUjnE5TTi0JHPJEP1tALUKVr8wFu4BT0bQK2cgLYfQSoarESVcGhZPkXk6vGqcv8HsUFYEsZ/fXsUJ2YJOxwycjlRUKUpeweCZsPTENEuNQaaG1WMI4VDN3gThMFTDuuRQBIlJj2axnEckk4IjpcduQe0NiIjWJQvwQ2aopIRUgBVCPMbqM0SVkO6dXnaE1O/FlQ2qFQ2MUNEUCqnfjUkRvbm58HZ7UVzTQLkMpG2SOwwK8dKxnhnuu53j2koCGX9Lb8XWoZLquv4zLhjVFD8spmD6QHd4JOJ0V81PP3tZMz2VGmkqknIM9SRZzk1Ur/KoRe3wr3bCu8IvlUNonckb/4FgY+jL8zL4KVFPtXD430nOl/aMGJdhWFLLD8M+ySyoVDh4csURlqIyYsHzX4tjVx2FV/0ATyE3D75yTy2sFp1wP4X+qpGvMxNfxC8lUMp1saUsmL2Za2zKpdDKZzDSnW1szLS3NKcSN9l71/fAn/iFJ2AUGAAA=</common_v19_0:NextResultReference><air:FlightDetailsList><air:FlightDetails Key="0T" Origin="RDU" Destination="PHL" DepartureTime="2013-09-27T07:00:00.000-04:00" ArrivalTime="2013-09-27T08:19:00.000-04:00" FlightTime="79" TravelTime="244" Equipment="CRJ" OriginTerminal="2" DestinationTerminal="D"/><air:FlightDetails Key="1T" Origin="PHL" Destination="ATL" DepartureTime="2013-09-27T09:00:00.000-04:00" ArrivalTime="2013-09-27T11:04:00.000-04:00" FlightTime="124" TravelTime="244" Equipment="M88" OnTimePerformance="80" OriginTerminal="E" DestinationTerminal="S"/><air:FlightDetails Key="2T" Origin="RDU" Destination="CMH" DepartureTime="2013-09-27T07:15:00.000-04:00" ArrivalTime="2013-09-27T08:37:00.000-04:00" FlightTime="82" TravelTime="244" Equipment="ERJ" OnTimePerformance="70" OriginTerminal="2"/><air:FlightDetails Key="3T" Origin="CMH" Destination="ATL" DepartureTime="2013-09-27T09:45:00.000-04:00" ArrivalTime="2013-09-27T11:19:00.000-04:00" FlightTime="94" TravelTime="244" Equipment="M88" OnTimePerformance="90" DestinationTerminal="S"/><air:FlightDetails Key="4T" Origin="RDU" Destination="MEM" DepartureTime="2013-09-27T07:00:00.000-04:00" ArrivalTime="2013-09-27T08:02:00.000-05:00" FlightTime="122" TravelTime="274" Equipment="CRJ" OnTimePerformance="90" OriginTerminal="2"/><air:FlightDetails Key="5T" Origin="MEM" Destination="ATL" DepartureTime="2013-09-27T09:13:00.000-05:00" ArrivalTime="2013-09-27T11:34:00.000-04:00" FlightTime="81" TravelTime="274" Equipment="D95" OnTimePerformance="80" DestinationTerminal="S"/><air:FlightDetails Key="6T" Origin="RDU" Destination="MCO" DepartureTime="2013-09-27T07:40:00.000-04:00" ArrivalTime="2013-09-27T09:25:00.000-04:00" FlightTime="105" TravelTime="253" Equipment="CR7" OnTimePerformance="90" OriginTerminal="2"/><air:FlightDetails Key="7T" Origin="MCO" Destination="ATL" DepartureTime="2013-09-27T10:30:00.000-04:00" ArrivalTime="2013-09-27T11:53:00.000-04:00" FlightTime="83" TravelTime="253" Equipment="757" OnTimePerformance="90" DestinationTerminal="S"/><air:FlightDetails Key="8T" Origin="RDU" Destination="BWI" DepartureTime="2013-09-27T06:40:00.000-04:00" ArrivalTime="2013-09-27T07:55:00.000-04:00" FlightTime="75" TravelTime="319" Equipment="CRJ" OnTimePerformance="90" OriginTerminal="2"/><air:FlightDetails Key="9T" Origin="BWI" Destination="ATL" DepartureTime="2013-09-27T10:05:00.000-04:00" ArrivalTime="2013-09-27T11:59:00.000-04:00" FlightTime="114" TravelTime="319" Equipment="M88" OnTimePerformance="80" DestinationTerminal="S"/><air:FlightDetails Key="10T" Origin="RDU" Destination="DTW" DepartureTime="2013-09-27T06:00:00.000-04:00" ArrivalTime="2013-09-27T07:50:00.000-04:00" FlightTime="110" TravelTime="364" Equipment="CR9" OnTimePerformance="90" OriginTerminal="2" DestinationTerminal="EM"/><air:FlightDetails Key="11T" Origin="DTW" Destination="ATL" DepartureTime="2013-09-27T10:05:00.000-04:00" ArrivalTime="2013-09-27T12:04:00.000-04:00" FlightTime="119" TravelTime="364" Equipment="M90" OnTimePerformance="90" OriginTerminal="EM" DestinationTerminal="S"/><air:FlightDetails Key="12T" Origin="RDU" Destination="PHL" DepartureTime="2013-09-27T07:00:00.000-04:00" ArrivalTime="2013-09-27T08:25:00.000-04:00" FlightTime="85" TravelTime="309" Equipment="E90" OnTimePerformance="90" OriginTerminal="2" DestinationTerminal="B"/><air:FlightDetails Key="13T" Origin="PHL" Destination="ATL" DepartureTime="2013-09-27T09:50:00.000-04:00" ArrivalTime="2013-09-27T12:09:00.000-04:00" FlightTime="139" TravelTime="309" Equipment="E75" OnTimePerformance="80" OriginTerminal="C" DestinationTerminal="N"/><air:FlightDetails Key="14T" Origin="RDU" Destination="PHL" DepartureTime="2013-09-27T05:15:00.000-04:00" ArrivalTime="2013-09-27T06:28:00.000-04:00" FlightTime="73" TravelTime="414" Equipment="E90" OnTimePerformance="90" OriginTerminal="2" DestinationTerminal="B"/><air:FlightDetails Key="15T" Origin="PHL" Destination="ATL" DepartureTime="2013-09-27T09:50:00.000-04:00" ArrivalTime="2013-09-27T12:09:00.000-04:00" FlightTime="139" TravelTime="414" Equipment="E75" OnTimePerformance="80" OriginTerminal="C" DestinationTerminal="N"/></air:FlightDetailsList><air:AirSegmentList><air:AirSegment Key="16T" Group="0" Carrier="DL" FlightNumber="3980" Origin="RDU" Destination="PHL" DepartureTime="2013-09-27T07:00:00.000-04:00" ArrivalTime="2013-09-27T08:19:00.000-04:00" FlightTime="79" TravelTime="244" ETicketability="Yes" Equipment="CRJ" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K9|L9|U9|T9|X5"/></air:AirAvailInfo><air:FlightDetailsRef Key="0T"/></air:AirSegment><air:AirSegment Key="17T" Group="0" Carrier="DL" FlightNumber="805" Origin="PHL" Destination="ATL" DepartureTime="2013-09-27T09:00:00.000-04:00" ArrivalTime="2013-09-27T11:04:00.000-04:00" FlightTime="124" TravelTime="244" ETicketability="Yes" Equipment="M88" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F9|P9|A9|G9"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K9|L9|U9|T9|X5"/></air:AirAvailInfo><air:FlightDetailsRef Key="1T"/></air:AirSegment><air:AirSegment Key="18T" Group="0" Carrier="DL" FlightNumber="6376" Origin="RDU" Destination="CMH" DepartureTime="2013-09-27T07:15:00.000-04:00" ArrivalTime="2013-09-27T08:37:00.000-04:00" FlightTime="82" TravelTime="244" ETicketability="Yes" Equipment="ERJ" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K9|L9|U9|T9|X9|V7|E7"/></air:AirAvailInfo><air:FlightDetailsRef Key="2T"/></air:AirSegment><air:AirSegment Key="19T" Group="0" Carrier="DL" FlightNumber="1416" Origin="CMH" Destination="ATL" DepartureTime="2013-09-27T09:45:00.000-04:00" ArrivalTime="2013-09-27T11:19:00.000-04:00" FlightTime="94" TravelTime="244" ETicketability="Yes" Equipment="M88" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F9|P9|A1"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K9|L9|U9|T9|X9|V7|E7"/></air:AirAvailInfo><air:FlightDetailsRef Key="3T"/></air:AirSegment><air:AirSegment Key="20T" Group="0" Carrier="DL" FlightNumber="3607" Origin="RDU" Destination="MEM" DepartureTime="2013-09-27T07:00:00.000-04:00" ArrivalTime="2013-09-27T08:02:00.000-05:00" FlightTime="122" TravelTime="274" ETicketability="Yes" Equipment="CRJ" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K6"/></air:AirAvailInfo><air:FlightDetailsRef Key="4T"/></air:AirSegment><air:AirSegment Key="21T" Group="0" Carrier="DL" FlightNumber="387" Origin="MEM" Destination="ATL" DepartureTime="2013-09-27T09:13:00.000-05:00" ArrivalTime="2013-09-27T11:34:00.000-04:00" FlightTime="81" TravelTime="274" ETicketability="Yes" Equipment="D95" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F9|P9|A9|G9"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K6"/></air:AirAvailInfo><air:FlightDetailsRef Key="5T"/></air:AirSegment><air:AirSegment Key="22T" Group="0" Carrier="DL" FlightNumber="6285" Origin="RDU" Destination="MCO" DepartureTime="2013-09-27T07:40:00.000-04:00" ArrivalTime="2013-09-27T09:25:00.000-04:00" FlightTime="105" TravelTime="253" ETicketability="Yes" Equipment="CR7" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F7|P7|A5|G1"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K5"/></air:AirAvailInfo><air:FlightDetailsRef Key="6T"/></air:AirSegment><air:AirSegment Key="23T" Group="0" Carrier="DL" FlightNumber="2118" Origin="MCO" Destination="ATL" DepartureTime="2013-09-27T10:30:00.000-04:00" ArrivalTime="2013-09-27T11:53:00.000-04:00" FlightTime="83" TravelTime="253" ETicketability="Yes" Equipment="757" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F9|P9|A9|G6"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K5"/></air:AirAvailInfo><air:FlightDetailsRef Key="7T"/></air:AirSegment><air:AirSegment Key="24T" Group="0" Carrier="DL" FlightNumber="3796" Origin="RDU" Destination="BWI" DepartureTime="2013-09-27T06:40:00.000-04:00" ArrivalTime="2013-09-27T07:55:00.000-04:00" FlightTime="75" TravelTime="319" ETicketability="Yes" Equipment="CRJ" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K9|L9|U4|T4"/></air:AirAvailInfo><air:FlightDetailsRef Key="8T"/></air:AirSegment><air:AirSegment Key="25T" Group="0" Carrier="DL" FlightNumber="1925" Origin="BWI" Destination="ATL" DepartureTime="2013-09-27T10:05:00.000-04:00" ArrivalTime="2013-09-27T11:59:00.000-04:00" FlightTime="114" TravelTime="319" ETicketability="Yes" Equipment="M88" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F3|P3|A1"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K9|L9|U4|T4"/></air:AirAvailInfo><air:FlightDetailsRef Key="9T"/></air:AirSegment><air:AirSegment Key="26T" Group="0" Carrier="DL" FlightNumber="4969" Origin="RDU" Destination="DTW" DepartureTime="2013-09-27T06:00:00.000-04:00" ArrivalTime="2013-09-27T07:50:00.000-04:00" FlightTime="110" TravelTime="364" ETicketability="Yes" Equipment="CR9" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F8|P7|A6|G5"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q8|K6|L3|U3|T2"/></air:AirAvailInfo><air:FlightDetailsRef Key="10T"/></air:AirSegment><air:AirSegment Key="27T" Group="0" Carrier="DL" FlightNumber="1175" Origin="DTW" Destination="ATL" DepartureTime="2013-09-27T10:05:00.000-04:00" ArrivalTime="2013-09-27T12:04:00.000-04:00" FlightTime="119" TravelTime="364" ETicketability="Yes" Equipment="M90" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F7|P7|A4|G3"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q8|K6|L3|U3|T2"/></air:AirAvailInfo><air:FlightDetailsRef Key="11T"/></air:AirSegment><air:AirSegment Key="28T" Group="0" Carrier="US" FlightNumber="2018" Origin="RDU" Destination="PHL" DepartureTime="2013-09-27T07:00:00.000-04:00" ArrivalTime="2013-09-27T08:25:00.000-04:00" FlightTime="85" TravelTime="309" ETicketability="Yes" Equipment="E90" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F6|A6|P6"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|H9|Q9|N9|V7|W1"/></air:AirAvailInfo><air:FlightDetailsRef Key="12T"/></air:AirSegment><air:AirSegment Key="29T" Group="0" Carrier="US" FlightNumber="3315" Origin="PHL" Destination="ATL" DepartureTime="2013-09-27T09:50:00.000-04:00" ArrivalTime="2013-09-27T12:09:00.000-04:00" FlightTime="139" TravelTime="309" ETicketability="Yes" Equipment="E75" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F6|A6|P6"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|H9|Q9|N9|V7|W1"/></air:AirAvailInfo><air:FlightDetailsRef Key="13T"/></air:AirSegment><air:AirSegment Key="30T" Group="0" Carrier="US" FlightNumber="1724" Origin="RDU" Destination="PHL" DepartureTime="2013-09-27T05:15:00.000-04:00" ArrivalTime="2013-09-27T06:28:00.000-04:00" FlightTime="73" TravelTime="414" ETicketability="Yes" Equipment="E90" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F6|A6|P6"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|H9|Q9|N9|V9|W9|L9|S2"/></air:AirAvailInfo><air:FlightDetailsRef Key="14T"/></air:AirSegment><air:AirSegment Key="31T" Group="0" Carrier="US" FlightNumber="3315" Origin="PHL" Destination="ATL" DepartureTime="2013-09-27T09:50:00.000-04:00" ArrivalTime="2013-09-27T12:09:00.000-04:00" FlightTime="139" TravelTime="414" ETicketability="Yes" Equipment="E75" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F6|A6|P6"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|H9|Q9|N9|V9|W9|L9|S2"/></air:AirAvailInfo><air:FlightDetailsRef Key="15T"/></air:AirSegment></air:AirSegmentList><air:AirItinerarySolution Key="32T"><air:AirSegmentRef Key="16T"/><air:AirSegmentRef Key="17T"/><air:AirSegmentRef Key="18T"/><air:AirSegmentRef Key="19T"/><air:AirSegmentRef Key="20T"/><air:AirSegmentRef Key="21T"/><air:AirSegmentRef Key="22T"/><air:AirSegmentRef Key="23T"/><air:AirSegmentRef Key="24T"/><air:AirSegmentRef Key="25T"/><air:AirSegmentRef Key="26T"/><air:AirSegmentRef Key="27T"/><air:AirSegmentRef Key="28T"/><air:AirSegmentRef Key="29T"/><air:AirSegmentRef Key="30T"/><air:AirSegmentRef Key="31T"/><air:Connection SegmentIndex="0"/><air:Connection SegmentIndex="2"/><air:Connection SegmentIndex="4"/><air:Connection SegmentIndex="6"/><air:Connection SegmentIndex="8"/><air:Connection SegmentIndex="10"/><air:Connection SegmentIndex="12"/><air:Connection SegmentIndex="14"/></air:AirItinerarySolution></air:AvailabilitySearchRsp></SOAP:Body></SOAP:Envelope>
</cfsavecontent>
--->
					<!--- Format the getUAPI response. --->
					<cfset attributes.aResponse = getUAPI().formatUAPIRsp(attributes.sResponse)>
					<!--- Create unique segment keys. --->
					<cfset attributes.sNextRef =	getAirParse().parseNextReference(attributes.aResponse)>
					<cfif attributes.nCount GT 3>
						<cfset attributes.sNextRef	= ''>
					</cfif>
					<!--- Create unique segment keys. --->
					<cfset attributes.stSegmentKeys = parseSegmentKeys(attributes.aResponse)>
					<!--- Add in the connection references --->
					<cfset attributes.stSegmentKeys = addSegmentRefs(attributes.aResponse, attributes.stSegmentKeys)>
					<!--- Parse the segments. --->
					<cfset attributes.stSegments = parseSegments(attributes.aResponse, attributes.stSegmentKeys)>
					<!--- Create a look up list opposite of the stSegmentKeys --->
					<cfset attributes.stSegmentKeyLookUp = parseKeyLookUp(attributes.stSegmentKeys)>
					<!--- Parse the trips. --->
					<cfset attributes.stAvailTrips = parseConnections(attributes.aResponse, attributes.stSegments, attributes.stSegmentKeys, attributes.stSegmentKeyLookUp, arguments.filter, arguments.group)>
					<!--- Add group node --->
					<cfset attributes.stAvailTrips	= getAirParse().addGroups(attributes.stAvailTrips, 'Avail')>
					<!--- Mark preferred carriers. --->
					<cfset attributes.stAvailTrips = getAirParse().addPreferred(attributes.stAvailTrips, arguments.Account)>
					<!--- Run policy on all the results --->
					<cfset attributes.stAvailTrips	= getAirParse().checkPolicy(attributes.stAvailTrips, arguments.Filter.getSearchID(), '', 'Avail', arguments.Account, arguments.Policy)>
					<!--- Create javascript structure per trip. --->
					<cfset attributes.stAvailTrips	=	getAirParse().addJavascript(attributes.stAvailTrips, 'Avail')>
					<!--- Merge information into the current session structures. --->
					<cfset session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group] = getAirParse().mergeTrips(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], attributes.stAvailTrips)>
				</cfloop>

				<!--- Add list of available carriers per leg --->
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.stCarriers[arguments.Group] = getAirParse().getCarriers(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group])>
				<!--- Add sorting per leg --->
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortDepart[arguments.Group] = StructSort(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], 'numeric', 'asc', 'Depart')>
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortArrival[arguments.Group] = StructSort(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], 'numeric', 'asc', 'Arrival')>
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortDuration[arguments.Group]	= StructSort(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], 'numeric', 'asc', 'Duration')>

				<!--- Sorting with preferred departure or arrival time taken into account --->
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortDepartPreferred[arguments.Group] = sortByPreferredTime("aSortDepart", arguments.Filter.getSearchID(), arguments.Group, arguments.Filter) />
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortArrivalPreferred[arguments.Group] = sortByPreferredTime("aSortArrival", arguments.Filter.getSearchID(), arguments.Group, arguments.Filter) />

				<!--- Mark this leg as priced --->
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.stGroups[arguments.Group] = 1>
			</cfthread>
		</cfif>

		<cfreturn local.sThreadName>
	</cffunction>

	<cffunction name="prepareSoapHeader" access="private" returntype="string" output="false" hint="I prepare the SOAP header.">
		<cfargument name="Filter" required="true">
		<cfargument name="Group" required="true">
		<cfargument name="sNextRef" required="true">
		<cfargument name="Account" required="true">

		<cfif arguments.Filter.getAirType() EQ 'MD'>
			<!--- grab leg query out of filter --->
			<cfset local.qSearchLegs = arguments.filter.getLegs()[1]>
		</cfif>

		<!--- Code needs to be reworked and put in a better location --->
		<cfset local.targetBranch = arguments.Account.sBranch>
		<cfif arguments.Filter.getAcctID() EQ 254
			OR arguments.Filter.getAcctID() EQ 255>
			<cfset local.targetBranch = 'P1601396'>
		</cfif>

<!---
****************************************************************************
				ANY CHANGES MADE BELOW PROBABLY NEED TO ALSO BE MADE IN
						   lowfare.cfc   prepareSoapHeader()
****************************************************************************
--->

		<cfsavecontent variable="local.message">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<air:AvailabilitySearchReq TargetBranch="#local.targetBranch#"
								xmlns:air="#getUAPISchemas().air#"
								xmlns:com="#getUAPISchemas().common#">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
							<cfif arguments.sNextRef NEQ ''>
								<com:NextResultReference>#arguments.sNextRef#</com:NextResultReference>
							</cfif>
							<cfif arguments.Group EQ 0>
								<air:SearchAirLeg>
									<air:SearchOrigin>
										<cfif arguments.filter.getAirFromCityCode() EQ 1>
											<com:City Code="#arguments.Filter.getDepartCity()#" />
										<cfelse>
											<com:Airport Code="#arguments.Filter.getDepartCity()#" />
										</cfif>
									</air:SearchOrigin>
									<air:SearchDestination>
										<cfif arguments.filter.getAirToCityCode() EQ 1>
											<com:City Code="#arguments.Filter.getArrivalCity()#" />
										<cfelse>
											<com:Airport Code="#arguments.Filter.getArrivalCity()#" />
										</cfif>
									</air:SearchDestination>

									<cfif arguments.filter.getDepartDateTimeActual() EQ "Anytime">
										<air:SearchDepTime PreferredTime="#DateFormat(arguments.filter.getDepartDateTime(), 'yyyy-mm-dd')#" />
									<cfelse>
										<cfif arguments.filter.getDepartTimeType() EQ "A">
											<air:SearchArvTime PreferredTime="#DateFormat(arguments.filter.getDepartDateTime(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTime(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#">
												<com:TimeRange EarliestTime="#DateFormat(arguments.filter.getDepartDateTimeStart(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTimeStart(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" LatestTime="#DateFormat(arguments.filter.getDepartDateTimeEnd(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTimeEnd(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" />
											</air:SearchArvTime>
										<cfelse>
											<air:SearchDepTime PreferredTime="#DateFormat(arguments.filter.getDepartDateTime(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTime(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#">
												<com:TimeRange EarliestTime="#DateFormat(arguments.filter.getDepartDateTimeStart(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTimeStart(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" LatestTime="#DateFormat(arguments.filter.getDepartDateTimeEnd(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getDepartDateTimeEnd(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" />
											</air:SearchDepTime>
										</cfif>
									</cfif>
								</air:SearchAirLeg>
							</cfif>

							<cfif arguments.Group EQ 1 AND arguments.Filter.getAirType() EQ 'RT'>
								<air:SearchAirLeg>
									<air:SearchOrigin>
										<cfif arguments.filter.getAirToCityCode() EQ 1>
											<com:City Code="#arguments.Filter.getArrivalCity()#" />
										<cfelse>
											<com:Airport Code="#arguments.Filter.getArrivalCity()#" />
										</cfif>
									</air:SearchOrigin>
									<air:SearchDestination>
										<cfif arguments.filter.getAirFromCityCode() EQ 1>
											<com:City Code="#arguments.Filter.getDepartCity()#" />
										<cfelse>
											<com:Airport Code="#arguments.Filter.getDepartCity()#" />
										</cfif>
									</air:SearchDestination>
									<cfif arguments.filter.getArrivalDateTimeActual() EQ "Anytime">
										<air:SearchDepTime PreferredTime="#DateFormat(arguments.filter.getArrivalDateTime(), 'yyyy-mm-dd')#" />
									<cfelse>
										<cfif arguments.filter.getDepartTimeType() EQ "A">
											<air:SearchArvTime PreferredTime="#DateFormat(arguments.filter.getArrivalDateTime(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTime(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#">
												<com:TimeRange EarliestTime="#DateFormat(arguments.filter.getArrivalDateTimeStart(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTimeStart(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" LatestTime="#DateFormat(arguments.filter.getArrivalDateTimeEnd(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTimeEnd(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" />
											</air:SearchArvTime>
										<cfelse>
											<air:SearchDepTime PreferredTime="#DateFormat(arguments.filter.getArrivalDateTime(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTime(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#">
												<com:TimeRange EarliestTime="#DateFormat(arguments.filter.getArrivalDateTimeStart(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTimeStart(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" LatestTime="#DateFormat(arguments.filter.getArrivalDateTimeEnd(), 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.filter.getArrivalDateTimeEnd(), 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" />
											</air:SearchDepTime>
										</cfif>
									</cfif>
								</air:SearchAirLeg>

							<!--- for multi-city trips loop over SearchesLegs --->
							<cfelseif arguments.Group NEQ 0
								AND arguments.Filter.getAirType() EQ 'MD'>
								<cfset local.cnt = 0>
								<cfloop query="local.qSearchLegs">
									<cfset cnt++>
									<cfif arguments.Group+1 EQ cnt>
										<air:SearchAirLeg>
											<air:SearchOrigin>
												<cfif airFrom_CityCode EQ 1>
													<com:City Code="#depart_city#" />
												<cfelse>
													<com:Airport Code="#depart_city#" />
												</cfif>
											</air:SearchOrigin>
											<air:SearchDestination>
												<cfif airTo_CityCode EQ 1>
													<com:City Code="#arrival_city#" />
												<cfelse>
													<com:Airport Code="#arrival_city#" />
												</cfif>
											</air:SearchDestination>

											<cfif local.qSearchLegs.Depart_DateTimeActual EQ "Anytime">
												<air:SearchDepTime PreferredTime="#DateFormat(local.qSearchLegs.Depart_DateTime, 'yyyy-mm-dd')#" />
											<cfelse>
												<air:SearchDepTime PreferredTime="#DateFormat(local.qSearchLegs.Depart_DateTime, 'yyyy-mm-dd') & 'T' & TimeFormat(local.qSearchLegs.Depart_DateTime, 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#">
													<com:TimeRange EarliestTime="#DateFormat(local.qSearchLegs.Depart_DateTimeStart, 'yyyy-mm-dd') & 'T' & TimeFormat(local.qSearchLegs.Depart_DateTimeStart, 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" LatestTime="#DateFormat(local.qSearchLegs.Depart_DateTimeEnd, 'yyyy-mm-dd') & 'T' & TimeFormat(local.qSearchLegs.Depart_DateTimeEnd, 'HH:mm:ss.lll') & '-' & TimeFormat(application.gmtOffset, 'HH:mm')#" />
												</air:SearchDepTime>
											</cfif>
										</air:SearchAirLeg>
									</cfif>
								</cfloop>
							</cfif>

<!--- MaxSolutions="1" --->

							<cfif arguments.sNextRef EQ ''>
								<air:AirSearchModifiers
									DistanceType="MI"
									IncludeFlightDetails="false"
									AllowChangeOfAirport="false"
									ProhibitOvernightLayovers="true"
									ProhibitMultiAirportConnection="true"
									PreferNonStop="true">
									<cfif Len(arguments.filter.getAirlines()) EQ 2>
										<air:PermittedCarriers>
											<com:Carrier Code="#arguments.filter.getAirlines()#"/>
										</air:PermittedCarriers>
									<cfelse>
										<air:ProhibitedCarriers>
											<com:Carrier Code="G4"/>
											<com:Carrier Code="NK"/>
											<com:Carrier Code="ZK"/>
										</air:ProhibitedCarriers>
									</cfif>
								</air:AirSearchModifiers>
								<com:SearchPassenger Code="ADT" />
								<!---
								<air:AirPricingModifiers ProhibitNonRefundableFares="#bProhibitNonRefundableFares#" FaresIndicator="PublicAndPrivateFares" ProhibitMinStayFares="false" ProhibitMaxStayFares="false" CurrencyType="USD" ProhibitAdvancePurchaseFares="false" ProhibitRestrictedFares="false" ETicketability="Required" ProhibitNonExchangeableFares="false" ForceSegmentSelect="false">
								</air:AirPricingModifiers>
								--->
								<com:PointOfSale ProviderCode="1V" PseudoCityCode="1M98" />
							</cfif>
						</air:AvailabilitySearchReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>

		<cfreturn message/>
	</cffunction>

	<cffunction name="parseSegmentKeys" output="false">
		<cfargument name="stResponse"	required="true">

		<cfset local.stSegmentKeys = {}>
		<cfset local.sIndex = ''>
		<!--- Create list of fields that make up a distint segment. --->
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber','TravelTime']>
		<!--- Loop through results. --->
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<cfif local.stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<!--- Build up the distinct segment string. --->
					<cfset local.sIndex = ''>
					<cfloop array="#aSegmentKeys#" index="local.sCol">
						<cfset local.sIndex &= local.stAirSegment.XMLAttributes[local.sCol]>
					</cfloop>
					<!--- Create a look up structure for the primary key. --->
					<cfset local.stSegmentKeys[local.stAirSegment.XMLAttributes.Key] = {
						HashIndex	: 	getUAPI().HashNumeric(local.sIndex),
						Index		: 	local.sIndex
					}>
				</cfloop>
			</cfif>
		</cfloop>

		<cfreturn local.stSegmentKeys />
	</cffunction>

	<cffunction name="addSegmentRefs" output="false">
		<cfargument name="stResponse">
		<cfargument name="stSegmentKeys">

		<cfset local.sAPIKey = ''>
		<cfset local.cnt = 0>
		<cfloop array="#arguments.stResponse#" index="local.stAirItinerarySolution">
			<cfif local.stAirItinerarySolution.XMLName EQ 'air:AirItinerarySolution'>
				<cfloop array="#stAirItinerarySolution.XMLChildren#" index="local.stAirSegmentRef">
					<cfif local.stAirSegmentRef.XMLName EQ 'air:AirSegmentRef'>
						<cfset local.sAPIKey = local.stAirSegmentRef.XMLAttributes.Key>
						<cfset arguments.stSegmentKeys[local.sAPIKey].nLocation = local.cnt>
						<cfset local.cnt++>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>

		<cfreturn arguments.stSegmentKeys />
	</cffunction>

	<cffunction name="parseKeyLookup" output="false">
		<cfargument name="stSegmentKeys">

		<cfset local.stSegmentKeyLookUp = {}>
		<cfloop collection="#arguments.stSegmentKeys#" item="local.sKey">
			<cfset local.stSegmentKeyLookUp[arguments.stSegmentKeys[local.sKey].nLocation] = local.sKey>
		</cfloop>

		<cfreturn local.stSegmentKeyLookUp />
	</cffunction>

	<cffunction name="parseSegments" output="false">
		<cfargument name="stResponse"		required="true">
		<cfargument name="stSegmentKeys"	required="true">

		<cfset local.stSegments = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<cfif local.stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#local.stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<cfset local.dArrivalGMT = local.stAirSegment.XMLAttributes.ArrivalTime>
					<cfset local.dArrivalTime = GetToken(local.dArrivalGMT, 1, '.')>
					<cfset local.dArrivalOffset = GetToken(GetToken(local.dArrivalGMT, 2, '-'), 1, ':')>
					<cfset local.dDepartGMT = local.stAirSegment.XMLAttributes.DepartureTime>
					<cfset local.dDepartTime = GetToken(local.dDepartGMT, 1, '.')>
					<cfset local.dDepartOffset = GetToken(GetToken(local.dDepartGMT, 2, '-'), 1, ':')>
					<cfset local.stSegments[arguments.stSegmentKeys[local.stAirSegment.XMLAttributes.Key].HashIndex] = {
						Arrival					: local.dArrivalGMT,
						ArrivalTime			: ParseDateTime(local.dArrivalTime),
						ArrivalGMT			: ParseDateTime(DateAdd('h', local.dArrivalOffset, local.dArrivalTime)),
						Carrier 				: local.stAirSegment.XMLAttributes.Carrier,
						ChangeOfPlane		: local.stAirSegment.XMLAttributes.ChangeOfPlane EQ 'true',
						Departure				: local.dDepartGMT,
						DepartureTime		: ParseDateTime(local.dDepartTime),
						DepartureGMT		: ParseDateTime(DateAdd('h', local.dDepartOffset, local.dDepartTime)),
						Destination			: local.stAirSegment.XMLAttributes.Destination,
						Equipment				: local.stAirSegment.XMLAttributes.Equipment,
						FlightNumber		: local.stAirSegment.XMLAttributes.FlightNumber,
						FlightTime			: local.stAirSegment.XMLAttributes.FlightTime,
						Group						: local.stAirSegment.XMLAttributes.Group,
						Origin					: local.stAirSegment.XMLAttributes.Origin,
						TravelTime			: local.stAirSegment.XMLAttributes.TravelTime
					}>
				</cfloop>
			</cfif>
		</cfloop>

		<cfreturn local.stSegments />
	</cffunction>

	<cffunction name="parseConnections" output="false">
		<cfargument name="stResponse">
		<cfargument name="stSegments">
		<cfargument name="stSegmentKeys">
		<cfargument name="stSegmentKeyLookUp">
		<cfargument name="filter">
		<cfargument name="group">

		<!--- Create a structure to hold FIRST connection points --->
		<cfset local.stSegmentIndex = {}>
		<cfset local.firstSegmentIndex = ''>
		<cfloop array="#arguments.stResponse#" index="local.stAirItinerarySolution">
			<cfif local.stAirItinerarySolution.XMLName EQ 'air:AirItinerarySolution'>
				<cfloop array="#local.stAirItinerarySolution.XMLChildren#" index="local.stConnection">
					<cfif local.stConnection.XMLName EQ 'air:Connection'>
						<cfif local.firstSegmentIndex EQ ''>
							<cfset local.firstSegmentIndex = local.stConnection.XMLAttributes.SegmentIndex>
						</cfif>
						<cfset local.stSegmentIndex[local.stConnection.XMLAttributes.SegmentIndex] = StructNew('linked')>
						<cfset local.stSegmentIndex[local.stConnection.XMLAttributes.SegmentIndex][1] = arguments.stSegments[arguments.stSegmentKeys[arguments.stSegmentKeyLookUp[local.stConnection.XMLAttributes.SegmentIndex]].HashIndex]>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		<cfif local.firstSegmentIndex EQ ''>
			<cfset local.firstSegmentIndex = arrayLen(structKeyArray(arguments.stSegmentKeyLookUp))-1>
		</cfif>

		<!--- Backfill with nonstops --->
		<cfloop from="0" to="#local.firstSegmentIndex-1#" index="local.segmentIndex">
			<cfset local.stSegmentIndex[ local.segmentIndex ] = StructNew('linked')>
			<cfset local.stSegmentIndex[ local.segmentIndex ][1] = arguments.stSegments[ arguments.stSegmentKeys[ arguments.stSegmentKeyLookUp[ segmentIndex ] ].HashIndex ]>
		</cfloop>

		<!--- Add to that structure the missing connection points --->
		<cfset local.stTrips = {}>
		<cfset local.nCount = 0>
		<cfset local.nSegNum = 1>
		<cfset local.nMaxCount = arrayLen(structKeyArray(arguments.stSegmentKeys))>
		<cfloop collection="#local.stSegmentIndex#" item="local.nIndex">
			<cfset local.nCount = local.nIndex>
			<cfset local.nSegNum = 1>
			<cfloop condition="NOT StructKeyExists(local.stSegmentIndex, local.nCount+1) AND local.nCount LT nMaxCount AND StructKeyExists(arguments.stSegmentKeyLookUp, local.nCount+1)">
				<cfset local.nSegNum++>
				<cfset local.stSegmentIndex[local.nIndex][local.nSegNum] = arguments.stSegments[arguments.stSegmentKeys[arguments.stSegmentKeyLookUp[local.nCount+1]].HashIndex]>
				<cfset local.nCount++>
			</cfloop>
		</cfloop>

		<!--- Create an appropriate trip key --->
		<cfset local.stTrips = {}>
		<cfset local.sIndex = ''>
		<cfset local.aCarriers = {}>
		<cfset local.nHashNumeric = ''>
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<cfloop collection="#local.stSegmentIndex#" item="local.nIndex">
			<cfloop collection="#local.stSegmentIndex[local.nIndex]#" item="local.sSegment">
				<cfset local.sIndex = ''>
				<cfloop array="#aSegmentKeys#" index="local.stSegment">
					<cfset local.sIndex &= local.stSegmentIndex[local.nIndex][sSegment][local.stSegment]>
				</cfloop>
			</cfloop>
			<cfset local.nHashNumeric = getUAPI().hashNumeric(local.sIndex)>
			<cfset local.stTrips[nHashNumeric].Segments = local.stSegmentIndex[local.nIndex]>
			<cfset local.stTrips[nHashNumeric].Class = 'X'>
			<cfset local.stTrips[nHashNumeric].Ref = 'X'>
		</cfloop>

		<!--- STM-2254 Hack
		5:31 PM Friday, October 04, 2013 - Jim Priest - jpriest@shortstravel.com
		junk code to remove flights not matching original arrival/departure

		Also see below for methods relating to city codes included in this hack
		--->

			<!--- get selected origin/destination from the filter --->
			<cfset local.original.departure = Left(arguments.filter.getLegsForTrip()[arguments.group+1], 3)>
			<cfset local.original.arrival = Mid(arguments.filter.getLegsForTrip()[arguments.group+1], 7, 3)>

			<!--- now check those first to see if they are a city code, if so get the related airport codes --->
			<cfset local.toCheck.departure = listToArray(local.original.departure)>
			<cfif IsCityCode(local.original.departure)>
				<cfset local.toCheck.departure = getCityCodeAirportCodes(local.original.departure)>
			</cfif>

			<cfset local.toCheck.arrival = listToArray(local.original.arrival)>
			<cfif IsCityCode(local.original.arrival)>
				<cfset local.toCheck.arrival = getCityCodeAirportCodes(local.original.arrival)>
			</cfif>

			<cfset local.badList = "">

			<!--- loop over stTrips and compare chosen origin/destination against the airport codes returned from the uAPI --->
			<cfloop collection="#local.stTrips#" index="local.tripIndex" item="local.tripItem">
				<cfset local.origin = ''>
				<cfset local.destination = ''>
				<cfloop collection="#local.tripItem.segments#" index="local.segmentIndex" item="local.segment">
					<cfif local.origin EQ ''>
						<cfset local.origin = local.segment.origin>
					</cfif>
					<cfset local.destination = local.segment.destination>
				</cfloop>

				<cfif NOT arrayFindNoCase(local.toCheck.arrival, local.destination)
						OR NOT arrayFindNoCase(local.toCheck.departure, local.origin)>
					<cfset local.badList = listAppend(local.badList, local.tripIndex)>
				</cfif>
			</cfloop>

			<!--- delete the trips containing bad origin/destination cities from stTrips --->
			<cfloop list="#local.badList#" index="local.badListIndex" item="local.badListItem">
				<cfset structDelete(local.stTrips, local.badListItem)>
			</cfloop>

		<!--- // end of STM-2254 hack --->

		<cfreturn local.stTrips />
	</cffunction>


	<cffunction name="sortByPreferredTime" output="false" hint="I take the depart/arrival sorts and weight the legs closest to requested departure or arrival time.">
		<cfargument name="StructToSort" required="true" />
		<cfargument name="SearchID" required="true" />
		<cfargument name="Group" required="true" />
		<cfargument name="Filter" required="true" />

		<cfset local.aSortArray = "session.searches[" & arguments.SearchID & "].stAvailDetails." & arguments.StructToSort & "[" & arguments.Group & "]" />

		<!--- TODO: Get MD working. --->
		<!--- Note: legs start with 1, groups start with 0 --->
		<cfif arguments.Filter.getAirType() IS "MD">
			<cfset local.nLeg = arguments.Group + 1 />
			<cfset local.preferredDepartTime = arguments.Filter.getLegs()[1].Depart_DateTime[local.nLeg] />
			<cfset local.preferredDepartTimeType = arguments.Filter.getLegs()[1].Depart_TimeType[local.nLeg] />
		<cfelse>
			<cfset local.preferredDepartTime = arguments.Filter.getDepartDateTime() />
			<cfset local.preferredDepartTimeType = arguments.Filter.getDepartTimeType() />
		</cfif>

		<cfif arguments.Filter.getAirType() IS "RT">
			<cfset local.preferredArrivalTime = arguments.Filter.getArrivalDateTime() />
			<cfset local.preferredArrivalTimeType = arguments.Filter.getArrivalTimeType() />
		<cfelse>
			<cfset local.preferredArrivalTime = "" />
			<cfset local.preferredArrivalTimeType = "" />
		</cfif>

		<cfset local.aPreferredSort = [] />
		<cfset local.sortQuery = QueryNew("nTripKey, departDiff, arrivalDiff", "varchar, numeric, numeric") />
		<cfset local.newRow = QueryAddRow(sortQuery, arrayLen(Evaluate(local.aSortArray))) />
		<cfset local.queryCounter = 1 />

		<cfloop array="#evaluate(local.aSortArray)#" index="local.nTripKey">
			<cfset local.stTrip = session.searches[arguments.SearchID].stAvailTrips[arguments.Group][local.nTripKey] />

			<cfif arguments.Filter.getDepartTimeType() IS 'A'>
				<cfset local.departDateDiff = abs(dateDiff("n", local.preferredDepartTime, local.stTrip.arrival)) />
			<cfelse>
				<cfset local.departDateDiff = abs(dateDiff("n", local.preferredDepartTime, local.stTrip.depart)) />
			</cfif>
			<cfif arguments.Filter.getAirType() IS "RT">
				<cfif arguments.Filter.getArrivalTimeType() IS 'A'>
					<cfset local.arrivalDateDiff = abs(dateDiff("n", local.preferredArrivalTime, local.stTrip.arrival)) />
				<cfelse>
					<cfset local.arrivalDateDiff = abs(dateDiff("n", local.preferredArrivalTime, local.stTrip.depart)) />
				</cfif>
			<cfelse>
				<cfset local.arrivalDateDiff = 0 />
			</cfif>

			<cfset local.temp = querySetCell(local.sortQuery, "nTripKey", local.nTripKey, local.queryCounter) />
			<cfset local.temp = querySetCell(local.sortQuery, "departDiff", local.departDateDiff, local.queryCounter) />
			<cfset local.temp = querySetCell(local.sortQuery, "arrivalDiff", local.arrivalDateDiff, local.queryCounter) />
			<cfset local.queryCounter++ />
		</cfloop>

		<cfquery name="local.preferredSort" dbtype="query">
			SELECT nTripKey, departDiff, arrivalDiff
			FROM sortQuery
			<cfif (arguments.Filter.getAirType() IS "RT") AND (arguments.Group EQ 1)>
				ORDER BY arrivalDiff
			<cfelse>
				ORDER BY departDiff
			</cfif>
		</cfquery>

		<cfif local.preferredSort.recordCount>
			<cfset local.aPreferredSort = listToArray(valueList(local.preferredSort.nTripKey)) />
		</cfif>

		<cfreturn local.aPreferredSort />
	</cffunction>


	<!---
	Throw away code - STM-2254
	4:54 PM Friday, October 04, 2013 - Jim Priest - jpriest@shortstravel.com
	 --->

	<cffunction name="isCityCode" output="false" hint="I take a code and check if it's a city code or a normal airport code.">
		<cfargument name="CityCode" required="true" />
		<cfset local.cityCodeList = "BER,BJS,BUE,BUH,CHI,DTT,LON,MIL,MOW,NYC,OSA,PAR,ROM,SAO,SEL,SPK,STO,TYO,WAS,YEA,YMQ,YTO">
		<cfset local.isCityCode = false>
		<cfif listFindNoCase(local.cityCodeList, arguments.cityCode)>
			<cfset local.isCityCode = true>
		</cfif>
		<cfreturn local.isCityCode>
	</cffunction>

	<cffunction name="getCityCodeAirportCodes" output="false" hint="This is throw away code to check bad flights for city codes and to return a list of associated airport codes that should not be filtered.">
		<cfargument name="CityCodeToCheck" required="true" />

		<!--- build stuct of cityCodes --->
		<cfset local.cityCode = {}>
		<cfset local.cityCodeList = "BER|TXL,SXF,THF;BJS|PEK,NAY;BUE|EZE,AEP;BUH|OTP,BBU;CHI|ORD,MDW;DTT|DTT,DTW,DET;LON|LGW,LHR;MIL|MXP,LIN;MOW|SVO,DME,VKO,PUW,BKA;NYC|JFK,EWR,LGA;OSA|KIX,ITM;PAR|CDG, ORY;ROM|FCO,CIA;SAO|GRU,CGH,VCP;SEL|ICN,GMP;SPK|CTS,OKD;STO|ARN,NYO,BMA,VST;TYO|NRT,HND;WAS|IAD,DCA,BWI;YEA|YEG,YXD;YMQ|YUL,YMY,YMX;YTO|YYZ,YTZ">

		<cfloop list="#local.cityCodeList#" delimiters=";" index="local.cityCodeListIndex" item="local.cityCodeListItem">
			<cfset local.cityCode[ListFirst(local.cityCodeListItem, '|')] = []>
			<cfset local.TempCityList = ListLast(local.cityCodeListItem, '|')>
			<cfloop list="#local.TempCityList#" index="local.tempCityListIndex" item="local.tempCityListItem">
					<cfset local.cityCode[ListFirst(local.cityCodeListItem, '|')][local.tempCityListIndex] = local.tempCityListItem>
			</cfloop>
		</cfloop>

		<cfset local.airportCodes = StructFindKey(local.cityCode, arguments.cityCodeToCheck)>

		<cfreturn local.airportCodes[1].value>
	</cffunction>
 <!--- // end of STM-2254 hack --->
</cfcomponent>