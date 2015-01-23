<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="UAPIFactory">
	<cfproperty name="uAPISchemas">

	<cffunction name="init" output="false" hint="Init method.">
		<cfargument name="UAPIFactory">
		<cfargument name="uAPISchemas">

		<cfset setUAPIFactory(arguments.UAPIFactory)>
		<cfset setUAPISchemas(arguments.uAPISchemas)>

		<cfreturn this>
	</cffunction>

<!--- doAirPrice --->
	<cffunction name="doSeatMap" output="false">
		<cfargument name="searchID" required="true">
		<cfargument name="nTripID" required="true">
		<cfargument name="nSegment"	required="false" default="">
		<cfargument name="group" required="false" default="">
		<cfargument name="sClass" required="false" default="Y">
		<cfargument name="stAccount" required="false" default="#application.Accounts[session.AcctID]#">

		<cfset local.sMessage = prepareSoapHeader(arguments.stAccount, arguments.searchID, arguments.nTripID, arguments.nSegment, arguments.sClass, arguments.Group)>
		<cfset local.sResponse = getUAPI().callUAPI('AirService', local.sMessage, arguments.searchID)>
		<cfset local.stResponse = getUAPI().formatUAPIRsp(local.sResponse)>
		<cfset local.stSeats = parseSeats(local.stResponse)>

		<cfreturn local.stSeats />
	</cffunction>

<!--- prepareSOAPHeader --->
	<cffunction name="prepareSOAPHeader" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="SearchID" 	required="true">
		<cfargument name="nTripID" 		required="true">
		<cfargument name="nSegment" 	required="false"	default="">
		<cfargument name="sClass" 		required="false"	default="Y">
		<cfargument name="Group" 		required="false"	default="">

		<cfset local.stSegment = {} />
		<cfif arguments.Group EQ ''>
			<cfif arguments.nSegment EQ ''>
				<cfloop collection="#session.searches[arguments.SearchID].stTrips[arguments.nTripID].Groups[0].Segments#" index="local.nSegment">
					<cfset local.stSegment = session.searches[arguments.SearchID].stTrips[arguments.nTripID].Groups[0].Segments[local.nSegment]>
					<cfbreak>
				</cfloop>
			<cfelse>
				<cfloop collection="#session.searches[arguments.SearchID].stTrips[arguments.nTripID].Groups#" index="local.Group">
					<cfloop collection="#session.searches[arguments.SearchID].stTrips[arguments.nTripID].Groups[Group].Segments#" index="local.nSegment">
						<cfif arguments.nSegment EQ local.nSegment>
							<cfset local.stSegment = session.searches[arguments.SearchID].stTrips[arguments.nTripID].Groups[Group].Segments[local.nSegment]>
							<cfbreak>
						</cfif>
					</cfloop>
				</cfloop>
			</cfif>
		<cfelse>
			<cfif arguments.nSegment EQ ''>
				<cfloop collection="#session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTripID].Groups[0].Segments#" index="local.nSegment">
					<cfset local.stSegment = session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTripID].Groups[0].Segments[local.nSegment]>
					<cfbreak>
				</cfloop>
			<cfelse>
				<cfloop collection="#session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTripID].Groups#" index="local.Group">
					<cfloop collection="#session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTripID].Groups[Group].Segments#" index="local.nSegment">
						<cfif arguments.nSegment EQ local.nSegment>
							<cfset local.stSegment = session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTripID].Groups[Group].Segments[local.nSegment]>
							<cfbreak>
						</cfif>
					</cfloop>
				</cfloop>
			</cfif>
		</cfif>

		<cfif isStruct(local.stSegment) AND structKeyExists(local.stSegment, "Carrier")>
			<cfsavecontent variable="local.sMessage">
				<cfoutput>
					<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
						<soapenv:Body>
							<air:SeatMapReq
								TargetBranch="#arguments.stAccount.sBranch#"
								xmlns:air="http://www.travelport.com/schema/air_v22_0"
								xmlns:com="http://www.travelport.com/schema/common_v19_0">
								<!--- TODO: Don't understand why the below isn't working. Try to fix at a later date. --->
								<!--- xmlns:air="#getUAPISchemas().air#"
								xmlns:com="#getUAPISchemas().common#"> --->
								<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
								<air:AirSegment
									Key="#arguments.nSegment#T"
									Carrier="#local.stSegment.Carrier#"
									FlightNumber="#local.stSegment.FlightNumber#"
									Origin="#local.stSegment.Origin#"
									Destination="#local.stSegment.Destination#"
									DepartureTime="#DateFormat(local.stSegment.DepartureTime, 'yyyy-mm-dd')#T#TimeFormat(local.stSegment.DepartureTime, 'HH:mm')#:00"
									ProviderCode="1V"
									Group="#local.stSegment.Group#">
								</air:AirSegment>
								<air:BookingCode Code="#arguments.sClass#" />
							</air:SeatMapReq>
						</soapenv:Body>
					</soapenv:Envelope>
				</cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfset local.sMessage="" />
		</cfif>

		<cfreturn local.sMessage />
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
							<cfif structKeyExists(local.stFacility.XMLAttributes, "Availability")>
								<cfset local.stSeats[local.nRow][local.sColumn].Avail = local.stFacility.XMLAttributes.Availability>
							<cfelse>
								<cfset local.stSeats[local.nRow][local.sColumn].Avail = "NoSeat">
							</cfif>
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
								<cfelseif local.stCharacteristic.XMLAttributes.Value EQ 'Preferential'>
									<cfset local.stSeats[local.nRow][local.sColumn].Avail = 'Preferential'>
								<cfelseif local.stCharacteristic.XMLAttributes.Value EQ 'RestrictedGeneral'>
									<cfset local.stSeats[local.nRow][local.sColumn].Avail = 'RBDRestriction'>
								<!--- <cfelseif local.stCharacteristic.XMLAttributes.Value EQ 'ExitRow'>
									<cfset local.stSeats[local.nRow][local.sColumn][local.stCharacteristic.XMLAttributes.Value] = 1> --->
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