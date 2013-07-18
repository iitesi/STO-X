<cfsilent>
	<cfparam name="rc.bSelection" default="0">
	<cfset sCurrentSeat = ''>
	<cfset sNextSegKey = ''>
	<cfset bFound = 0>
	<cfset nSegmentCount = 0>
	<cfset breadCount = 0>
</cfsilent>

<cfoutput>
	<div id="seatcontent">
		<cfif rc.Group EQ ''>
			<cfif NOT StructKeyExists(rc, 'nSegment')>
				<cfloop collection="#session.searches[rc.SearchID].stTrips[rc.nTripID].Groups[0].Segments#" index="local.nSegment">
					<cfset rc.nSegment = nSegment>
					<cfbreak>
				</cfloop>
			</cfif>
			<cfset stGroups = session.searches[rc.SearchID].stTrips[rc.nTripID].Groups>
		<cfelse>
			<cfif NOT StructKeyExists(rc, 'nSegment')>
				<cfloop collection="#session.searches[rc.SearchID].stAvailTrips[rc.Group][rc.nTripID].Groups[0].Segments#" index="local.nSegment">
					<cfset rc.nSegment = nSegment>
					<cfbreak>
				</cfloop>
			</cfif>
			<cfset stGroups = session.searches[rc.SearchID].stAvailTrips[rc.Group][rc.nTripID].Groups>
		</cfif>

		<!--- get the current segment --->
		<cfset currentSegment = structFindKey(stGroups,rc.nSegment)[1].value>

		<!--- get how many segments there are in this trip --->
		<cfset segmentCount = 0>
		<cfloop collection="#stGroups#" index="GroupKey" item="stGroup">
			<cfloop collection="#stGroup.Segments#" index="sSegKey" item="stSegment">
				<cfset segmentCount++>
			</cfloop>
		</cfloop>

		<ul class="breadcrumb">
			<cfset sURL = 'SearchID=#rc.SearchID#&nTripID=#rc.nTripID#&Group=#rc.Group#'>
			<cfloop collection="#stGroups#" index="GroupKey" item="stGroup">
				<cfloop collection="#stGroup.Segments#" index="sSegKey" item="stSegment">
					<cfset breadCount++>
						<li class="<cfif rc.nSegment EQ sSegKey>active</cfif>">
							<span title="View seats for this flight..." onClick="$('##seats').html('<i class=&quot;icon-spinner icon-spin&quot;></i> One moment while we fetch seat information...');$('##seatcontent').load('?action=air.seatmap&#sURL#&nSegment=#sSegKey#&bSelection=1');" >
								#application.stAirVendors[stSegment.Carrier].Name# #stSegment.FlightNumber# (#stSegment.Origin# to #stSegment.Destination#)
							</span>
							<cfif segmentCount NEQ breadCount>
								<span class="divider">/</span>
							</cfif>
						</li>
				</cfloop>
			</cfloop>
		</ul>

		<div id="seats">
			<!--- show seatmap heading --->
			<img class="popuplogo pull-left" src="assets/img/airlines/#currentSegment.Carrier#.png">
			<div class="media-heading pull-left">
				<h3>#application.stAirVendors[currentSegment.Carrier].Name# #currentSegment.FlightNumber# #application.stAirports[currentSegment.Origin]# (#currentSegment.Origin#) to #application.stAirports[currentSegment.Destination]# (#currentSegment.Destination#)</h3>
				#DateFormat(currentSegment.DepartureTime, 'ddd, mmm d')# - #TimeFormat(currentSegment.DepartureTime, 'h:mm tt')# to #TimeFormat(currentSegment.ArrivalTime, 'h:mm tt')#
			</div>
			<div class="clearfix"></div>
			<br>

		<!--- show seatmap rc.stSeats is returned from doSeatMap --->
			<cfif NOT StructKeyExists(rc.stSeats, 'Error')>
				<cfif StructKeyExists(rc.stSeats, 'ExitRow')>
					<cfset stExitRows = rc.stSeats.ExitRow>
					<cfset structDelete(rc.stSeats, "ExitRow")>
				<cfelse>
					<cfset stExitRows = {}>
				</cfif>
				<cfset stAisles = rc.stSeats.Aisle>
				<cfset structDelete(rc.stSeats, "Aisle")>
				<cfset aColumns = structKeyArray(rc.stSeats.Columns)>
				<cfset ArraySort(aColumns, 'text', 'desc')>
				<cfset structDelete(rc.stSeats, "Columns")>
				<cfset aRows = structKeyArray(rc.stSeats)>
				<cfset ArraySort(aRows, "numeric")>

		<!--- Display wing	--->
			<table class="popUpTable">
				<tr>
					<cfset start = 0>
					<cfloop array="#aRows#" index="nRow">
						<td>
							<table width="25">
							<tr>
								<cfif NOT structKeyExists(stExitRows, nRow)>
									<td>&nbsp;</td>
								<cfelse>
									<td class="wingmiddle">&nbsp;</td>
								</cfif>
							</tr>
							</table>
						</td>
					</cfloop>
				</tr>

			<!---	Display seats	--->
				<tr>
					<cfloop array="#aRows#" index="nRow">
						<td>
							<table width="25">
							<cfloop array="#aColumns#" index="sColumn">
								<cfif structKeyExists(stAisles, sColumn)>
									<tr>
										<td align="center">#nRow#</td>
									</tr>
								</cfif>
								<cfset sDesc = rc.stSeats[nRow][sColumn].AVAIL>
								<cfset sDesc = ListAppend(sDesc, structKeyList(rc.stSeats[nRow][sColumn]))>
								<cfset sDesc = ListDeleteAt(sDesc, ListFind(sDesc, 'AVAIL'))>
								<cfset sDesc = Replace(sDesc, ',', ', ')>
								<cfset sDesc = (sDesc EQ '' ? nRow&sColumn : nRow&sColumn&': '&sDesc)>
								<tr>
									<td class="seat #rc.stSeats[nRow][sColumn].Avail#<cfif sCurrentSeat EQ nRow&sColumn> currentseat</cfif>" title="#sDesc#" id="#nRow##sColumn#">
										&nbsp;
									</td>
								</tr>
							</cfloop>
							</table>
						</td>
					</cfloop>
				</tr>

				<!--- Display wing --->
				<tr>
					<cfloop array="#aRows#" index="nRow">
						<td>
							<table width="25">
							<tr>
								<cfif NOT structKeyExists(stExitRows, nRow)>
									<td>&nbsp;</td>
								<cfelse>
									<td class="wingmiddle">&nbsp;</td>
								</cfif>
							</tr>
							</table>
						</td>
					</cfloop>
				</tr>
			</table>


		<!--- Display legend	--->
				<br>
				<table class="popUpTable">
				<tr>
					<td class="seat currentseat"></td>
					<td class="paddingright">Seat Selected</td>
					<td class="seat Available"></td>
					<td class="paddingright">Available</td>
					<td class="seat Preferential"></td>
					<td class="paddingright">Preferred</td>
					<td class="seat Occupied"></td>
					<td class="paddingright">Occupied</td>
					<td class="seat Unknown"></td>
					<td class="paddingright">Unknown</td>
					<td class="seat NoSeat"></td>
					<td class="paddingright">No Seat</td>
				</tr>
				</table>
			<cfelse>
				<div id="seatcontent"><p>#rc.stSeats.Error#</p></div>
			</cfif>
		</div>
	</div>
</cfoutput>