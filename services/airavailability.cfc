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
		<cfargument name="Filter"	required="true">
		<cfargument name="Account"  required="true">
		<cfargument name="Policy"   required="true">
		<cfargument name="Group"	required="false">

		<cfset local.stThreads = {}>
		<cfset local.sThreadName = ''>
		<cfset local.sPriority = ''>

		<!--- Create a thread for every leg.  Give priority to the group specifically selected. --->
		<cfloop collection="#arguments.Filter.getLegs()#" item="local.nLeg">
			<cfif arguments.Group EQ nLeg>
				<cfset local.sPriority = 'HIGH'>
			<cfelse>
				<cfset local.sPriority = 'LOW'>
			</cfif>
			<cfset sThreadName = doAvailability(arguments.Filter, nLeg-1, arguments.Account, arguments.Policy, sPriority)>

			<cfif sPriority EQ 'HIGH' AND sThreadName NEQ ''>
				<cfset stThreads[sThreadName] = ''>
			</cfif>
		</cfloop>

		<!--- Join only if threads where thrown out. --->
		<cfif NOT StructIsEmpty(stThreads)
			AND sPriority EQ 'HIGH'>
			<cfthread action="join" name="#structKeyList(stThreads)#" />
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="doAvailability" output="false">
		<cfargument name="Filter" required="true">
		<cfargument name="Group" required="true">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="sPriority" required="false"	default="HIGH">
		<cfargument name="stGroups" required="false" default="#structNew()#">

		<cfset local.sThreadName = "">

		<!--- Don't go back to the getUAPI if we already got the data. --->
		<cfif NOT StructKeyExists(arguments.stGroups, arguments.Group)>
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
					<!--- <cfset attributes.sResponse = getUAPI().callUAPI('AirService', attributes.sMessage, arguments.Filter.getSearchID(), arguments.Filter.getAcctID(), arguments.Filter.getUserID())> --->


				<!--- use to spoof a GOOD request --->
				<cfsavecontent variable="attributes.sResponse">
					<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/"><SOAP:Body><air:AvailabilitySearchRsp xmlns:air="http://www.travelport.com/schema/air_v22_0" xmlns:common_v19_0="http://www.travelport.com/schema/common_v19_0"  TransactionId="554FDB4C0A07611407B77CA0A6C80A11" ResponseTime="1768" DistanceUnits="MI"><common_v19_0:NextResultReference>H4sIAAAAAAAAAJ1UvU8UQRR/t9zJhxACKDEYRaMRC929O5Hjq+FLgi4f4dACpBhuh2Vwb3eZHWAxxkQbbWxojCZWRBITazUxodXSGAujsTDY+gdQGHwz3AErKtEtZnfe+73fvI/f7PPvkAg41M2SBaLPC+boXZyTJZMFIrzz/tijN+RJCcQGIB6wmzT0ASC2GMe1AoPO57y8bqeDRSZyM7ptBTqxiC8oD3T05D1X7wsFJzkx5t2grnn3cyPbrFnVoGwCDhLOx1ieynMEpCZMDDCKVAZS5T2LOsYWjSGRWZ/m2DTLEcE8twMZLOrvMLTtw3DJoSGbcuheJlMyBYK5aiug1pStMBzi2kZWcObaCEnY3Jv3BdTtcg64gtqUo7c873GqapyD25Aw4YDHmc2Ku0qfewvMorwHMyrYEmIbHvrzvNCBSDNV/sVG7s376Ylr79YeZh5oAGosgCxt+7D8uQsfXk+2H723Pllki+F4W/6PK131bTprNH/SIGZCdUAJz80oHfSSpUCA/vdBZaP4jpCD/m+deXG/e0X7YVoaxMehngUjnE5TTi0JHPJEP1tALUKVr8wFu4BT0bQK2cgLYfQSoarESVcGhZPkXk6vGqcv8HsUFYEsZ/fXsUJ2YJOxwycjlRUKUpeweCZsPTENEuNQaaG1WMI4VDN3gThMFTDuuRQBIlJj2axnEckk4IjpcduQe0NiIjWJQvwQ2aopIRUgBVCPMbqM0SVkO6dXnaE1O/FlQ2qFQ2MUNEUCqnfjUkRvbm58HZ7UVzTQLkMpG2SOwwK8dKxnhnuu53j2koCGX9Lb8XWoZLquv4zLhjVFD8spmD6QHd4JOJ0V81PP3tZMz2VGmkqknIM9SRZzk1Ur/KoRe3wr3bCu8IvlUNonckb/4FgY+jL8zL4KVFPtXD430nOl/aMGJdhWFLLD8M+ySyoVDh4csURlqIyYsHzX4tjVx2FV/0ATyE3D75yTy2sFp1wP4X+qpGvMxNfxC8lUMp1saUsmL2Za2zKpdDKZzDSnW1szLS3NKcSN9l71/fAn/iFJ2AUGAAA=</common_v19_0:NextResultReference><air:FlightDetailsList><air:FlightDetails Key="0T" Origin="RDU" Destination="PHL" DepartureTime="2013-09-27T07:00:00.000-04:00" ArrivalTime="2013-09-27T08:19:00.000-04:00" FlightTime="79" TravelTime="244" Equipment="CRJ" OriginTerminal="2" DestinationTerminal="D"/><air:FlightDetails Key="1T" Origin="PHL" Destination="ATL" DepartureTime="2013-09-27T09:00:00.000-04:00" ArrivalTime="2013-09-27T11:04:00.000-04:00" FlightTime="124" TravelTime="244" Equipment="M88" OnTimePerformance="80" OriginTerminal="E" DestinationTerminal="S"/><air:FlightDetails Key="2T" Origin="RDU" Destination="CMH" DepartureTime="2013-09-27T07:15:00.000-04:00" ArrivalTime="2013-09-27T08:37:00.000-04:00" FlightTime="82" TravelTime="244" Equipment="ERJ" OnTimePerformance="70" OriginTerminal="2"/><air:FlightDetails Key="3T" Origin="CMH" Destination="ATL" DepartureTime="2013-09-27T09:45:00.000-04:00" ArrivalTime="2013-09-27T11:19:00.000-04:00" FlightTime="94" TravelTime="244" Equipment="M88" OnTimePerformance="90" DestinationTerminal="S"/><air:FlightDetails Key="4T" Origin="RDU" Destination="MEM" DepartureTime="2013-09-27T07:00:00.000-04:00" ArrivalTime="2013-09-27T08:02:00.000-05:00" FlightTime="122" TravelTime="274" Equipment="CRJ" OnTimePerformance="90" OriginTerminal="2"/><air:FlightDetails Key="5T" Origin="MEM" Destination="ATL" DepartureTime="2013-09-27T09:13:00.000-05:00" ArrivalTime="2013-09-27T11:34:00.000-04:00" FlightTime="81" TravelTime="274" Equipment="D95" OnTimePerformance="80" DestinationTerminal="S"/><air:FlightDetails Key="6T" Origin="RDU" Destination="MCO" DepartureTime="2013-09-27T07:40:00.000-04:00" ArrivalTime="2013-09-27T09:25:00.000-04:00" FlightTime="105" TravelTime="253" Equipment="CR7" OnTimePerformance="90" OriginTerminal="2"/><air:FlightDetails Key="7T" Origin="MCO" Destination="ATL" DepartureTime="2013-09-27T10:30:00.000-04:00" ArrivalTime="2013-09-27T11:53:00.000-04:00" FlightTime="83" TravelTime="253" Equipment="757" OnTimePerformance="90" DestinationTerminal="S"/><air:FlightDetails Key="8T" Origin="RDU" Destination="BWI" DepartureTime="2013-09-27T06:40:00.000-04:00" ArrivalTime="2013-09-27T07:55:00.000-04:00" FlightTime="75" TravelTime="319" Equipment="CRJ" OnTimePerformance="90" OriginTerminal="2"/><air:FlightDetails Key="9T" Origin="BWI" Destination="ATL" DepartureTime="2013-09-27T10:05:00.000-04:00" ArrivalTime="2013-09-27T11:59:00.000-04:00" FlightTime="114" TravelTime="319" Equipment="M88" OnTimePerformance="80" DestinationTerminal="S"/><air:FlightDetails Key="10T" Origin="RDU" Destination="DTW" DepartureTime="2013-09-27T06:00:00.000-04:00" ArrivalTime="2013-09-27T07:50:00.000-04:00" FlightTime="110" TravelTime="364" Equipment="CR9" OnTimePerformance="90" OriginTerminal="2" DestinationTerminal="EM"/><air:FlightDetails Key="11T" Origin="DTW" Destination="ATL" DepartureTime="2013-09-27T10:05:00.000-04:00" ArrivalTime="2013-09-27T12:04:00.000-04:00" FlightTime="119" TravelTime="364" Equipment="M90" OnTimePerformance="90" OriginTerminal="EM" DestinationTerminal="S"/><air:FlightDetails Key="12T" Origin="RDU" Destination="PHL" DepartureTime="2013-09-27T07:00:00.000-04:00" ArrivalTime="2013-09-27T08:25:00.000-04:00" FlightTime="85" TravelTime="309" Equipment="E90" OnTimePerformance="90" OriginTerminal="2" DestinationTerminal="B"/><air:FlightDetails Key="13T" Origin="PHL" Destination="ATL" DepartureTime="2013-09-27T09:50:00.000-04:00" ArrivalTime="2013-09-27T12:09:00.000-04:00" FlightTime="139" TravelTime="309" Equipment="E75" OnTimePerformance="80" OriginTerminal="C" DestinationTerminal="N"/><air:FlightDetails Key="14T" Origin="RDU" Destination="PHL" DepartureTime="2013-09-27T05:15:00.000-04:00" ArrivalTime="2013-09-27T06:28:00.000-04:00" FlightTime="73" TravelTime="414" Equipment="E90" OnTimePerformance="90" OriginTerminal="2" DestinationTerminal="B"/><air:FlightDetails Key="15T" Origin="PHL" Destination="ATL" DepartureTime="2013-09-27T09:50:00.000-04:00" ArrivalTime="2013-09-27T12:09:00.000-04:00" FlightTime="139" TravelTime="414" Equipment="E75" OnTimePerformance="80" OriginTerminal="C" DestinationTerminal="N"/></air:FlightDetailsList><air:AirSegmentList><air:AirSegment Key="16T" Group="0" Carrier="DL" FlightNumber="3980" Origin="RDU" Destination="PHL" DepartureTime="2013-09-27T07:00:00.000-04:00" ArrivalTime="2013-09-27T08:19:00.000-04:00" FlightTime="79" TravelTime="244" ETicketability="Yes" Equipment="CRJ" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K9|L9|U9|T9|X5"/></air:AirAvailInfo><air:FlightDetailsRef Key="0T"/></air:AirSegment><air:AirSegment Key="17T" Group="0" Carrier="DL" FlightNumber="805" Origin="PHL" Destination="ATL" DepartureTime="2013-09-27T09:00:00.000-04:00" ArrivalTime="2013-09-27T11:04:00.000-04:00" FlightTime="124" TravelTime="244" ETicketability="Yes" Equipment="M88" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F9|P9|A9|G9"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K9|L9|U9|T9|X5"/></air:AirAvailInfo><air:FlightDetailsRef Key="1T"/></air:AirSegment><air:AirSegment Key="18T" Group="0" Carrier="DL" FlightNumber="6376" Origin="RDU" Destination="CMH" DepartureTime="2013-09-27T07:15:00.000-04:00" ArrivalTime="2013-09-27T08:37:00.000-04:00" FlightTime="82" TravelTime="244" ETicketability="Yes" Equipment="ERJ" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K9|L9|U9|T9|X9|V7|E7"/></air:AirAvailInfo><air:FlightDetailsRef Key="2T"/></air:AirSegment><air:AirSegment Key="19T" Group="0" Carrier="DL" FlightNumber="1416" Origin="CMH" Destination="ATL" DepartureTime="2013-09-27T09:45:00.000-04:00" ArrivalTime="2013-09-27T11:19:00.000-04:00" FlightTime="94" TravelTime="244" ETicketability="Yes" Equipment="M88" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F9|P9|A1"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K9|L9|U9|T9|X9|V7|E7"/></air:AirAvailInfo><air:FlightDetailsRef Key="3T"/></air:AirSegment><air:AirSegment Key="20T" Group="0" Carrier="DL" FlightNumber="3607" Origin="RDU" Destination="MEM" DepartureTime="2013-09-27T07:00:00.000-04:00" ArrivalTime="2013-09-27T08:02:00.000-05:00" FlightTime="122" TravelTime="274" ETicketability="Yes" Equipment="CRJ" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K6"/></air:AirAvailInfo><air:FlightDetailsRef Key="4T"/></air:AirSegment><air:AirSegment Key="21T" Group="0" Carrier="DL" FlightNumber="387" Origin="MEM" Destination="ATL" DepartureTime="2013-09-27T09:13:00.000-05:00" ArrivalTime="2013-09-27T11:34:00.000-04:00" FlightTime="81" TravelTime="274" ETicketability="Yes" Equipment="D95" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F9|P9|A9|G9"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K6"/></air:AirAvailInfo><air:FlightDetailsRef Key="5T"/></air:AirSegment><air:AirSegment Key="22T" Group="0" Carrier="DL" FlightNumber="6285" Origin="RDU" Destination="MCO" DepartureTime="2013-09-27T07:40:00.000-04:00" ArrivalTime="2013-09-27T09:25:00.000-04:00" FlightTime="105" TravelTime="253" ETicketability="Yes" Equipment="CR7" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F7|P7|A5|G1"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K5"/></air:AirAvailInfo><air:FlightDetailsRef Key="6T"/></air:AirSegment><air:AirSegment Key="23T" Group="0" Carrier="DL" FlightNumber="2118" Origin="MCO" Destination="ATL" DepartureTime="2013-09-27T10:30:00.000-04:00" ArrivalTime="2013-09-27T11:53:00.000-04:00" FlightTime="83" TravelTime="253" ETicketability="Yes" Equipment="757" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F9|P9|A9|G6"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K5"/></air:AirAvailInfo><air:FlightDetailsRef Key="7T"/></air:AirSegment><air:AirSegment Key="24T" Group="0" Carrier="DL" FlightNumber="3796" Origin="RDU" Destination="BWI" DepartureTime="2013-09-27T06:40:00.000-04:00" ArrivalTime="2013-09-27T07:55:00.000-04:00" FlightTime="75" TravelTime="319" ETicketability="Yes" Equipment="CRJ" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K9|L9|U4|T4"/></air:AirAvailInfo><air:FlightDetailsRef Key="8T"/></air:AirSegment><air:AirSegment Key="25T" Group="0" Carrier="DL" FlightNumber="1925" Origin="BWI" Destination="ATL" DepartureTime="2013-09-27T10:05:00.000-04:00" ArrivalTime="2013-09-27T11:59:00.000-04:00" FlightTime="114" TravelTime="319" ETicketability="Yes" Equipment="M88" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F3|P3|A1"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q9|K9|L9|U4|T4"/></air:AirAvailInfo><air:FlightDetailsRef Key="9T"/></air:AirSegment><air:AirSegment Key="26T" Group="0" Carrier="DL" FlightNumber="4969" Origin="RDU" Destination="DTW" DepartureTime="2013-09-27T06:00:00.000-04:00" ArrivalTime="2013-09-27T07:50:00.000-04:00" FlightTime="110" TravelTime="364" ETicketability="Yes" Equipment="CR9" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F8|P7|A6|G5"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q8|K6|L3|U3|T2"/></air:AirAvailInfo><air:FlightDetailsRef Key="10T"/></air:AirSegment><air:AirSegment Key="27T" Group="0" Carrier="DL" FlightNumber="1175" Origin="DTW" Destination="ATL" DepartureTime="2013-09-27T10:05:00.000-04:00" ArrivalTime="2013-09-27T12:04:00.000-04:00" FlightTime="119" TravelTime="364" ETicketability="Yes" Equipment="M90" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F7|P7|A4|G3"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|S9|H9|Q8|K6|L3|U3|T2"/></air:AirAvailInfo><air:FlightDetailsRef Key="11T"/></air:AirSegment><air:AirSegment Key="28T" Group="0" Carrier="US" FlightNumber="2018" Origin="RDU" Destination="PHL" DepartureTime="2013-09-27T07:00:00.000-04:00" ArrivalTime="2013-09-27T08:25:00.000-04:00" FlightTime="85" TravelTime="309" ETicketability="Yes" Equipment="E90" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F6|A6|P6"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|H9|Q9|N9|V7|W1"/></air:AirAvailInfo><air:FlightDetailsRef Key="12T"/></air:AirSegment><air:AirSegment Key="29T" Group="0" Carrier="US" FlightNumber="3315" Origin="PHL" Destination="ATL" DepartureTime="2013-09-27T09:50:00.000-04:00" ArrivalTime="2013-09-27T12:09:00.000-04:00" FlightTime="139" TravelTime="309" ETicketability="Yes" Equipment="E75" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F6|A6|P6"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|H9|Q9|N9|V7|W1"/></air:AirAvailInfo><air:FlightDetailsRef Key="13T"/></air:AirSegment><air:AirSegment Key="30T" Group="0" Carrier="US" FlightNumber="1724" Origin="RDU" Destination="PHL" DepartureTime="2013-09-27T05:15:00.000-04:00" ArrivalTime="2013-09-27T06:28:00.000-04:00" FlightTime="73" TravelTime="414" ETicketability="Yes" Equipment="E90" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F6|A6|P6"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|H9|Q9|N9|V9|W9|L9|S2"/></air:AirAvailInfo><air:FlightDetailsRef Key="14T"/></air:AirSegment><air:AirSegment Key="31T" Group="0" Carrier="US" FlightNumber="3315" Origin="PHL" Destination="ATL" DepartureTime="2013-09-27T09:50:00.000-04:00" ArrivalTime="2013-09-27T12:09:00.000-04:00" FlightTime="139" TravelTime="414" ETicketability="Yes" Equipment="E75" ChangeOfPlane="false" ParticipantLevel="Secure Sell" LinkAvailability="true" PolledAvailabilityOption="Polled avail used" OptionalServicesIndicator="false" AvailabilitySource="Seamless"><air:AirAvailInfo ProviderCode="1V"><air:BookingCodeInfo CabinClass="First" BookingCounts="F6|A6|P6"/><air:BookingCodeInfo CabinClass="Economy" BookingCounts="Y9|B9|M9|H9|Q9|N9|V9|W9|L9|S2"/></air:AirAvailInfo><air:FlightDetailsRef Key="15T"/></air:AirSegment></air:AirSegmentList><air:AirItinerarySolution Key="32T"><air:AirSegmentRef Key="16T"/><air:AirSegmentRef Key="17T"/><air:AirSegmentRef Key="18T"/><air:AirSegmentRef Key="19T"/><air:AirSegmentRef Key="20T"/><air:AirSegmentRef Key="21T"/><air:AirSegmentRef Key="22T"/><air:AirSegmentRef Key="23T"/><air:AirSegmentRef Key="24T"/><air:AirSegmentRef Key="25T"/><air:AirSegmentRef Key="26T"/><air:AirSegmentRef Key="27T"/><air:AirSegmentRef Key="28T"/><air:AirSegmentRef Key="29T"/><air:AirSegmentRef Key="30T"/><air:AirSegmentRef Key="31T"/><air:Connection SegmentIndex="0"/><air:Connection SegmentIndex="2"/><air:Connection SegmentIndex="4"/><air:Connection SegmentIndex="6"/><air:Connection SegmentIndex="8"/><air:Connection SegmentIndex="10"/><air:Connection SegmentIndex="12"/><air:Connection SegmentIndex="14"/></air:AirItinerarySolution></air:AvailabilitySearchRsp></SOAP:Body></SOAP:Envelope>
				</cfsavecontent>


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
					<cfset attributes.stAvailTrips = parseConnections(attributes.aResponse, attributes.stSegments, attributes.stSegmentKeys, attributes.stSegmentKeyLookUp)>
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
				<cfif arguments.Filter.getAirType() IS "MD">
					<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortDepartPreferred[arguments.Group] = session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortDepart[arguments.Group] />
					<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortArrivalPreferred[arguments.Group] = session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortArrival[arguments.Group] />
				<cfelse>
					<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortDepartPreferred[arguments.Group] = sortByPreferredTime("aSortDepart", arguments.Filter.getSearchID(), arguments.Group, arguments.Filter) />
					<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortArrivalPreferred[arguments.Group] = sortByPreferredTime("aSortArrival", arguments.Filter.getSearchID(), arguments.Group, arguments.Filter) />
				</cfif>

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
						<air:AvailabilitySearchReq TargetBranch="#arguments.Account.sBranch#"
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
										<air:SearchArvTime PreferredTime="#DateFormat(arguments.filter.getArrivalDateTime(), 'yyyy-mm-dd')#" />
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
							<cfelseif arguments.Group NEQ 0 AND arguments.Filter.getAirType() EQ 'MD'>
								<cfset local.cnt = 0>
								<cfloop query="local.qSearchLegs">
									<cfset cnt++>
									<cfif arguments.Group EQ cnt>
										<air:SearchAirLeg>
											<air:SearchOrigin>
												<cfif arguments.filter.getAirFromCityCode() EQ 1>
													<com:City Code="#depart_city#" />
												<cfelse>
													<com:Airport Code="#depart_city#" />
												</cfif>
											</air:SearchOrigin>
											<air:SearchDestination>
												<cfif arguments.filter.getAirToCityCode() EQ 1>
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
			<cfif stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<!--- Build up the distinct segment string. --->
					<cfset sIndex = ''>
					<cfloop array="#aSegmentKeys#" index="local.sCol">
						<cfset sIndex &= stAirSegment.XMLAttributes[sCol]>
					</cfloop>
					<!--- Create a look up structure for the primary key. --->
					<cfset stSegmentKeys[stAirSegment.XMLAttributes.Key] = {
						HashIndex	: 	getUAPI().HashNumeric(sIndex),
						Index		: 	sIndex
					}>
				</cfloop>
			</cfif>
		</cfloop>

		<cfreturn stSegmentKeys />
	</cffunction>

	<cffunction name="addSegmentRefs" output="false">
		<cfargument name="stResponse">
		<cfargument name="stSegmentKeys">

		<cfset local.sAPIKey = ''>
		<cfset local.cnt = 0>
		<cfloop array="#arguments.stResponse#" index="local.stAirItinerarySolution">
			<cfif stAirItinerarySolution.XMLName EQ 'air:AirItinerarySolution'>
				<cfloop array="#stAirItinerarySolution.XMLChildren#" index="local.stAirSegmentRef">
					<cfif stAirSegmentRef.XMLName EQ 'air:AirSegmentRef'>
						<cfset sAPIKey = stAirSegmentRef.XMLAttributes.Key>
						<cfset arguments.stSegmentKeys[sAPIKey].nLocation = cnt>
						<cfset cnt++>
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
			<cfset stSegmentKeyLookUp[stSegmentKeys[sKey].nLocation] = sKey>
		</cfloop>

		<cfreturn stSegmentKeyLookUp />
	</cffunction>

	<cffunction name="parseSegments" output="false">
		<cfargument name="stResponse"		required="true">
		<cfargument name="stSegmentKeys"	required="true">

		<cfset local.stSegments = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<cfif stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<cfset local.dArrivalGMT = stAirSegment.XMLAttributes.ArrivalTime>
					<cfset local.dArrivalTime = GetToken(dArrivalGMT, 1, '.')>
					<cfset local.dArrivalOffset = GetToken(GetToken(dArrivalGMT, 2, '-'), 1, ':')>
					<cfset local.dDepartGMT = stAirSegment.XMLAttributes.DepartureTime>
					<cfset local.dDepartTime = GetToken(dDepartGMT, 1, '.')>
					<cfset local.dDepartOffset = GetToken(GetToken(dDepartGMT, 2, '-'), 1, ':')>
					<cfset stSegments[arguments.stSegmentKeys[stAirSegment.XMLAttributes.Key].HashIndex] = {
						Arrival				: dArrivalGMT,
						ArrivalTime			: ParseDateTime(dArrivalTime),
						ArrivalGMT			: ParseDateTime(DateAdd('h', dArrivalOffset, dArrivalTime)),
						Carrier 			: stAirSegment.XMLAttributes.Carrier,
						ChangeOfPlane		: stAirSegment.XMLAttributes.ChangeOfPlane EQ 'true',
						Departure			: dDepartGMT,
						DepartureTime		: ParseDateTime(dDepartTime),
						DepartureGMT		: ParseDateTime(DateAdd('h', dDepartOffset, dDepartTime)),
						Destination			: stAirSegment.XMLAttributes.Destination,
						Equipment			: stAirSegment.XMLAttributes.Equipment,
						FlightNumber		: stAirSegment.XMLAttributes.FlightNumber,
						FlightTime			: stAirSegment.XMLAttributes.FlightTime,
						Group				: stAirSegment.XMLAttributes.Group,
						Origin				: stAirSegment.XMLAttributes.Origin,
						TravelTime			: stAirSegment.XMLAttributes.TravelTime
					}>
				</cfloop>
			</cfif>
		</cfloop>

		<cfreturn stSegments />
	</cffunction>

	<cffunction name="parseConnections" output="false">
		<cfargument name="stResponse">
		<cfargument name="stSegments">
		<cfargument name="stSegmentKeys">
		<cfargument name="stSegmentKeyLookUp">

		<!--- Create a structure to hold FIRST connection points --->
		<cfset local.stSegmentIndex = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirItinerarySolution">
			<cfif stAirItinerarySolution.XMLName EQ 'air:AirItinerarySolution'>
				<cfloop array="#stAirItinerarySolution.XMLChildren#" index="local.stConnection">
					<cfif stConnection.XMLName EQ 'air:Connection'>
						<cfset stSegmentIndex[stConnection.XMLAttributes.SegmentIndex] = StructNew('linked')>
						<cfset stSegmentIndex[stConnection.XMLAttributes.SegmentIndex][1] = stSegments[stSegmentKeys[stSegmentKeyLookUp[stConnection.XMLAttributes.SegmentIndex]].HashIndex]>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		<!--- Add to that structure the missing connection points --->
		<cfset local.stTrips = {}>
		<cfset local.nCount = 0>
		<cfset local.nSegNum = 1>
		<cfset local.nMaxCount = ArrayLen(StructKeyArray(stSegmentKeys))>
		<cfloop collection="#stSegmentIndex#" item="local.nIndex">
			<cfset nCount = nIndex>
			<cfset nSegNum = 1>
			<cfloop condition="NOT StructKeyExists(stSegmentIndex, nCount+1) AND nCount LT nMaxCount AND StructKeyExists(stSegmentKeyLookUp, nCount+1)">
				<cfset nSegNum++>
				<cfset stSegmentIndex[nIndex][nSegNum] = stSegments[stSegmentKeys[stSegmentKeyLookUp[nCount+1]].HashIndex]>
				<cfset nCount++>
			</cfloop>
		</cfloop>
		<!--- Create an appropriate trip key --->
		<cfset local.stTrips = {}>
		<cfset local.sIndex = ''>
		<cfset local.aCarriers = {}>
		<cfset local.nHashNumeric = ''>
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<cfloop collection="#stSegmentIndex#" item="local.nIndex">
			<cfloop collection="#stSegmentIndex[nIndex]#" item="local.sSegment">
				<cfset sIndex = ''>
				<cfloop array="#aSegmentKeys#" index="local.stSegment">
					<cfset sIndex &= stSegmentIndex[nIndex][sSegment][stSegment]>
				</cfloop>
			</cfloop>
			<cfset nHashNumeric = getUAPI().hashNumeric(sIndex)>
			<cfset stTrips[nHashNumeric].Segments = stSegmentIndex[nIndex]>
			<cfset stTrips[nHashNumeric].Class = 'X'>
			<cfset stTrips[nHashNumeric].Ref = 'X'>
		</cfloop>

		<cfreturn stTrips />
	</cffunction>

	<cffunction name="sortByPreferredTime" output="false" hint="I take the depart/arrival sorts and weight the legs closest to requested departure or arrival time.">
		<cfargument name="StructToSort" required="true" />
		<cfargument name="SearchID" required="true" />
		<cfargument name="Group" required="true" />
		<cfargument name="Filter" required="true" />

		<cfset local.aSortArray = "session.searches[" & arguments.SearchID & "].stAvailDetails." & arguments.StructToSort & "[" & arguments.Group & "]" />

		<!--- TODO: Get MD working. --->
		<!--- <cfif arguments.Filter.getAirType() IS "MD">
			<cfset local.nGroup = arguments.Group + 1 />
			<cfloop collection="#arguments.Filter.getLegs()[1]#" item="local.nLeg">
				<cfif nLeg EQ nGroup>
					<cfset local.preferredDepartTime = nLeg.Depart_DateTime />
					<cfset local.preferredDepartTimeType = nLeg.Depart_TimeType />
				</cfif>
			</cfloop>
		<cfelse> --->
			<cfset local.nGroup = arguments.Group />
			<cfset local.preferredDepartTime = arguments.Filter.getDepartDateTime() />
			<cfset local.preferredDepartTimeType = arguments.Filter.getDepartTimeType() />
		<!--- </cfif> --->

		<cfif arguments.Filter.getAirType() IS "RT">
			<cfset local.preferredArrivalTime = arguments.Filter.getArrivalDateTime() />
			<cfset local.preferredArrivalTimeType = arguments.Filter.getArrivalTimeType() />
		<cfelse>
			<cfset local.preferredArrivalTime = "" />
			<cfset local.preferredArrivalTimeType = "" />
		</cfif>

		<cfset local.aPreferredSort = [] />
		<cfset local.sortQuery = QueryNew("nTripKey, departDiff, arrivalDiff", "varchar, numeric, numeric") />
		<cfset local.newRow = QueryAddRow(sortQuery, arrayLen(Evaluate(aSortArray))) />
		<cfset local.queryCounter = 1 />

		<cfloop array="#evaluate(aSortArray)#" index="local.nTripKey">
			<cfset local.stTrip = session.searches[arguments.SearchID].stAvailTrips[nGroup][nTripKey] />

			<cfif arguments.Filter.getDepartTimeType() IS 'A'>
				<cfset departDateDiff = abs(dateDiff("n", preferredDepartTime, stTrip.arrival)) />
			<cfelse>
				<cfset departDateDiff = abs(dateDiff("n", preferredDepartTime, stTrip.depart)) />
			</cfif>
			<cfif arguments.Filter.getAirType() IS "RT">
				<cfif arguments.Filter.getArrivalTimeType() IS 'A'>
					<cfset arrivalDateDiff = abs(dateDiff("n", preferredArrivalTime, stTrip.arrival)) />
				<cfelse>
					<cfset arrivalDateDiff = abs(dateDiff("n", preferredArrivalTime, stTrip.depart)) />
				</cfif>
			<cfelse>
				<cfset arrivalDateDiff = 0 />
			</cfif>

			<cfset temp = querySetCell(sortQuery, "nTripKey", nTripKey, queryCounter) />
			<cfset temp = querySetCell(sortQuery, "departDiff", departDateDiff, queryCounter) />
			<cfset temp = querySetCell(sortQuery, "arrivalDiff", arrivalDateDiff, queryCounter) />
			<cfset queryCounter++ />
		</cfloop>

		<cfquery name="local.preferredSort" dbtype="query">
			SELECT nTripKey, departDiff, arrivalDiff
			FROM sortQuery
			<cfif (arguments.Filter.getAirType() IS "RT") AND (nGroup EQ 1)>
				ORDER BY arrivalDiff
			<cfelse>
				ORDER BY departDiff
			</cfif>
		</cfquery>

		<cfif preferredSort.recordCount>
			<cfset aPreferredSort = listToArray(valueList(preferredSort.nTripKey)) />
		</cfif>

		<cfreturn aPreferredSort />
	</cffunction>

</cfcomponent>