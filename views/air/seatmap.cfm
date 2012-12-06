
<cfoutput>
	<div id="seatcontent">
		<cfif rc.nGroup EQ ''>
			<cfif NOT StructKeyExists(rc, 'nSegment')>
				<cfloop collection="#session.searches[rc.nSearchID].stTrips[rc.nTripID].Groups[0].Segments#" index="local.nSegment">
					<cfset rc.nSegment = nSegment>
					<cfbreak>
				</cfloop>
			</cfif>
			<cfset stGroups = session.searches[rc.nSearchID].stTrips[rc.nTripID].Groups>
		<cfelse>
			<cfif NOT StructKeyExists(rc, 'nSegment')>
				<cfloop collection="#session.searches[rc.nSearchID].stAvailTrips[rc.nGroup][rc.nTripID].Groups[0].Segments#" index="local.nSegment">
					<cfset rc.nSegment = nSegment>
					<cfbreak>
				</cfloop>
			</cfif>
			<cfset stGroups = session.searches[rc.nSearchID].stAvailTrips[rc.nGroup][rc.nTripID].Groups>
		</cfif>
		<ul class="tabs">
			<cfset sURL = 'Search_ID=#rc.nSearchID#&nTripID=#rc.nTripID#&nGroup=#rc.nGroup#'>
			<cfloop collection="#stGroups#" item="nGroup">
				<cfloop collection="#stGroups[nGroup].Segments#" item="nSegment">
					<li><a <cfif rc.nSegment EQ nSegment>class="active"</cfif> onClick="$('##seats').html('One moment please...');$('##seatcontent').load('?action=air.seatmap&#sURL#&nSegment=#nSegment#');">#stGroups[nGroup].Segments[nSegment].Carrier##stGroups[nGroup].Segments[nSegment].FlightNumber# (#stGroups[nGroup].Segments[nSegment].Origin# to #stGroups[nGroup].Segments[nSegment].Destination#)</a></li>
					<cfif rc.nSegment EQ nSegment>
						<cfset stSegments = stGroups[nGroup].Segments[nSegment]>
					</cfif>
				</cfloop>
			</cfloop>
		</ul>
		<br><br>
		<div id="seats">
			<strong>
				<img class="carrierimg" src="assets/img/airlines/#stSegments.Carrier#.png" style="float:left;padding-right:20px;">
				#application.stAirVendors[stSegments.Carrier].Name# Flt ###stSegments.FlightNumber# <br>
				#application.stAirports[stSegments.Origin]# (#stSegments.Origin#) to #application.stAirports[stSegments.Destination]# (#stSegments.Destination#) <br>
				#DateFormat(stSegments.DepartureTime, 'ddd, mmm d')# - #TimeFormat(stSegments.DepartureTime, 'h:mm tt')# to #TimeFormat(stSegments.ArrivalTime, 'h:mm tt')#
			</strong>
			<br><br>
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
				<table class="popUpTable">
				<!---
				Display wing
				--->
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
				<!---
				Display seats
				--->
				<tr>
					<cfloop array="#aRows#" index="nRow">
						<td>
							<table width="25">
							<cfloop array="#aColumns#" index="sColumn">
								<cfif structKeyExists(stAisles, sColumn)>
									<tr>
										<td>#nRow#</td>
									</tr>
								</cfif>
								<cfset sDesc = rc.stSeats[nRow][sColumn].AVAIL>
								<cfset sDesc = ListAppend(sDesc, structKeyList(rc.stSeats[nRow][sColumn]))>
								<cfset sDesc = ListDeleteAt(sDesc, ListFind(sDesc, 'AVAIL'))>
								<cfset sDesc = Replace(sDesc, ',', ', ')>
								<cfset sDesc = (sDesc EQ '' ? nRow&sColumn : nRow&sColumn&': '&sDesc)>
								<tr>
									<td class="seat #rc.stSeats[nRow][sColumn].Avail#" title="#sDesc#"></td>
								</tr>
							</cfloop>
							</table>
						</td>
					</cfloop>
				</tr>
				<!---
				Display wing
				--->
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
				<!---
				Display legend
				--->
				<br><br>
				<table class="popUpTable">
				<tr>
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
				<div id="seatcontent">#rc.stSeats.Error#</div>
			</cfif>
		</div>
	</div>
</cfoutput>