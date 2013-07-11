<cfcomponent output="false" accessors="true">

	<cfproperty name="UAPI">

<!--- doAirPrice --->
	<cffunction name="doSeatMap" output="false">
		<cfargument name="searchID" required="true">
		<cfargument name="nTripID" required="true">
		<cfargument name="nSegment"	required="false" default="">
		<cfargument name="group" required="false" default="">
		<cfargument name="sCabin" required="false" default="Y">
		<cfargument name="stAccount" required="false" default="#application.Accounts[session.AcctID]#">

		<cfset local.sMessage = prepareSoapHeader(arguments.stAccount, arguments.searchID, arguments.nTripID, arguments.nSegment, 'Y', arguments.Group)>
		<cfset local.sResponse = UAPI.callUAPI('AirService', local.sMessage, arguments.searchID)>
		<cfset local.stResponse = UAPI.formatUAPIRsp(local.sResponse)>
		<cfset local.stSeats = parseSeats(local.stResponse)>

		<cfreturn local.stSeats />
	</cffunction>

<!--- prepareSOAPHeader --->
	<cffunction name="prepareSOAPHeader" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="SearchID" 	required="true">
		<cfargument name="nTripID" 		required="true">
		<cfargument name="nSegment" 	required="false"	default="">
		<cfargument name="sCabin" 		required="false"	default="Y"><!--- Options (one item) - Y, C, F --->
		<cfargument name="Group" 		required="false"	default="">

		<cfif arguments.Group EQ ''>
			<cfif arguments.nSegment EQ ''>
				<cfloop collection="#session.searches[arguments.SearchID].stTrips[arguments.nTripID].Groups[0].Segments#" index="local.nSegment">
					<cfset local.stSegment = session.searches[arguments.SearchID].stTrips[arguments.nTripID].Groups[0].Segments[nSegment]>
					<cfbreak>
				</cfloop>
			<cfelse>
				<cfloop collection="#session.searches[arguments.SearchID].stTrips[arguments.nTripID].Groups#" index="local.Group">
					<cfloop collection="#session.searches[arguments.SearchID].stTrips[arguments.nTripID].Groups[Group].Segments#" index="local.nSegment">
						<cfif arguments.nSegment EQ nSegment>
							<cfset local.stSegment = session.searches[arguments.SearchID].stTrips[arguments.nTripID].Groups[Group].Segments[nSegment]>
							<cfbreak>
						</cfif>
					</cfloop>
				</cfloop>
			</cfif>
		<cfelse>
			<cfif arguments.nSegment EQ ''>
				<cfloop collection="#session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTripID].Groups[0].Segments#" index="local.nSegment">
					<cfset local.stSegment = session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTripID].Groups[0].Segments[nSegment]>
					<cfbreak>
				</cfloop>
			<cfelse>
				<cfloop collection="#session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTripID].Groups#" index="local.Group">
					<cfloop collection="#session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTripID].Groups[Group].Segments#" index="local.nSegment">
						<cfif arguments.nSegment EQ nSegment>
							<cfset local.stSegment = session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTripID].Groups[Group].Segments[nSegment]>
							<cfbreak>
						</cfif>
					</cfloop>
				</cfloop>
			</cfif>
		</cfif>

		<cfsavecontent variable="local.sMessage">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
				<soapenv:Header/>
					<soapenv:Body>
						<air:SeatMapReq TargetBranch="#arguments.stAccount.sBranch#" xmlns:air="http://www.travelport.com/schema/air_v18_0" xmlns:com="http://www.travelport.com/schema/common_v15_0">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
								<air:AirSegment
									Key="#nSegment#T"
									Carrier="#stSegment.Carrier#"
									FlightNumber="#stSegment.FlightNumber#"
									Origin="#stSegment.Origin#"
									Destination="#stSegment.Destination#"
									DepartureTime="#DateFormat(stSegment.DepartureTime, 'yyyy-mm-dd')#T#TimeFormat(stSegment.DepartureTime, 'HH:mm')#:00"
									ProviderCode="1V"
									Group="#stSegment.Group#">
								</air:AirSegment>
							<air:BookingCode Code="Y" />
						</air:SeatMapReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>

		<cfreturn sMessage/>
	</cffunction>

	<cffunction name="parseSeats" access="private" output="false" hint="I parse seats from uAPI data.">
		<cfargument name="stResponse"	required="true">

		<cfset local.stSeats = {}>
		<cfset local.nRow = ''>
		<cfset local.sColumn = ''>

		<cfloop array="#arguments.stResponse#" index="local.stRow">
			<cfif local.stRow.XMLName EQ 'air:Row'>
				<cfloop array="#local.stRow.XMLChildren#" index="local.stFacility">

					<cfif local.stFacility.XMLName EQ 'air:Facility'>
						<!---
						Seat Types: Seat, Aisle, Open, Unknown
						--->
						<cfif local.stFacility.XMLAttributes.Type EQ 'Seat'>
							<cfset local.nRow = GetToken(local.stFacility.XMLAttributes.SeatCode, 1, '-')>
							<cfset local.sColumn = GetToken(local.stFacility.XMLAttributes.SeatCode, 2, '-')>
							<!---
							Seat Availabilities: 	Available, Occupied, Reserved, AdvancedBoardingPass, InterlineCheckin, Codeshare,
							Protected, PartnerAirline, AdvSeatSelection, Blocked, Extra, RBDRestriction, Group,	NoSeat
							--->
							<cfset local.stSeats['Columns'][local.sColumn] = ''>
							<cfset local.stSeats[local.nRow][local.sColumn].Avail = local.stFacility.XMLAttributes.Availability>
							<cfloop array="#stFacility.XMLChildren#" index="local.stCharacteristic">
								<!---
								Seat Characteristics
								ExitRow, Wing, Left, Right, Forward, Rear, UpperDeck, LowerDeck, DesignatedRBD, ExtraLegRoom,
								BufferRow, RowDoesNotExist, SeatRestrictionsApply, MovieScreen, Aisle, PaidGeneralSeat,
								RearGalley, NearToiletBulkhead, Window, RestrictedRecline, PreferentialRestrictedGeneral,
								LegRest, NoSeat, Middle, RBDSpecific, Bassinet, Blocked, Handicapped, BufferZone,
								ElectronicConnection
								--->
								<cfif local.stCharacteristic.XMLAttributes.Value EQ 'ExitRow'>
									<cfset local.stSeats['ExitRow'][local.nRow] = 1>
								<cfelseif local.stCharacteristic.XMLAttributes.Value EQ 'ExitRow'>
									<cfset local.stSeats[local.nRow][local.sColumn][local.stCharacteristic.XMLAttributes.Value] = 1>
								</cfif>
							</cfloop>
						<cfelseif local.stFacility.XMLAttributes.Type EQ 'Aisle'>
							<cfset local.stSeats['Aisle'][local.sColumn] = 1>
						</cfif>
					</cfif>
				</cfloop>
			<cfelseif local.stRow.XMLName EQ 'FaultString'>
				<cfset local.stSeats.Error = local.stRow.XMLText>
			</cfif>
		</cfloop>

		<cfreturn local.stSeats />
	</cffunction>

</cfcomponent>