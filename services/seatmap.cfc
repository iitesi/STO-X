<cfcomponent output="false">
	
<!--- doAirPrice --->
	<cffunction name="doSeatMap" output="false">
		<cfargument name="SearchID" 	required="true">
		<cfargument name="nTripID"	 	required="true">
		<cfargument name="nSegment"		required="false"	default="">
		<cfargument name="Group"		required="false"    default="">
		<cfargument name="sCabin" 		required="false"	default="Y">
		<cfargument name="stAccount"	required="false" 	default="#application.Accounts[session.AcctID]#">
		
		<cfset local.sMessage = prepareSoapHeader(arguments.stAccount, arguments.SearchID, arguments.nTripID, arguments.nSegment, 'Y', arguments.Group)>
		<cfset local.sResponse = application.objUAPI.callUAPI('AirService', sMessage, SearchID)>
		<cfset stResponse = application.objUAPI.formatUAPIRsp(sResponse)>
		<cfset local.stSeats = parseSeats(stResponse)>
		
		<cfreturn stSeats>
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
							<com:BillingPointOfSaleInfo OriginApplication="uAPI" />
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
	
<!---
parseSeats
--->
	<cffunction name="parseSeats" returntype="struct" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stSeats = {}>
		<cfset local.nRow = ''>
		<cfset local.sColumn = ''>

		<cfloop array="#arguments.stResponse#" index="local.stRow">
			<cfif stRow.XMLName EQ 'air:Row'>
				<cfloop array="#stRow.XMLChildren#" index="local.stFacility">

					<cfif stFacility.XMLName EQ 'air:Facility'>
						<!---
						Seat Types
						Seat, Aisle, Open, Unknown
						--->
						<cfif stFacility.XMLAttributes.Type EQ 'Seat'>
							<cfset nRow = GetToken(stFacility.XMLAttributes.SeatCode, 1, '-')>
							<cfset sColumn = GetToken(stFacility.XMLAttributes.SeatCode, 2, '-')>
							<!---
							Seat Availabilities
							Available, Occupied, Reserved, AdvancedBoardingPass, InterlineCheckin, Codeshare, 
							Protected, PartnerAirline, AdvSeatSelection, Blocked, Extra, RBDRestriction, Group, 
							NoSeat
							--->
							<cfset stSeats['Columns'][sColumn] = ''>
							<cfset stSeats[nRow][sColumn].Avail = stFacility.XMLAttributes.Availability>
							<cfloop array="#stFacility.XMLChildren#" index="local.stCharacteristic">
								<!--- 
								Seat Characteristics
								ExitRow, Wing, Left, Right, Forward, Rear, UpperDeck, LowerDeck, DesignatedRBD, ExtraLegRoom, 
								BufferRow, RowDoesNotExist, SeatRestrictionsApply, MovieScreen, Aisle, PaidGeneralSeat, 
								RearGalley, NearToiletBulkhead, Window, RestrictedRecline, PreferentialRestrictedGeneral, 
								LegRest, NoSeat, Middle, RBDSpecific, Bassinet, Blocked, Handicapped, BufferZone,
								ElectronicConnection
								--->
								<cfif stCharacteristic.XMLAttributes.Value EQ 'ExitRow'>
									<cfset stSeats['ExitRow'][nRow] = 1>
								<cfelseif stCharacteristic.XMLAttributes.Value EQ 'ExitRow'>
									<cfset stSeats[nRow][sColumn][stCharacteristic.XMLAttributes.Value] = 1>
								</cfif>
							</cfloop>
						<cfelseif stFacility.XMLAttributes.Type EQ 'Aisle'>
							<cfset stSeats['Aisle'][sColumn] = 1>
						</cfif>
					</cfif>
				</cfloop>
			<cfelseif stRow.XMLName EQ 'FaultString'>
				<cfset stSeats.Error = stRow.XMLText>
			</cfif>
		</cfloop>
		
		<cfreturn  stSeats/>
	</cffunction>	
	
</cfcomponent>