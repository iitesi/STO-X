<cfif rc.nGroup EQ ''>
	<cfset stSegments = session.searches[rc.Search_ID].stTrips[rc.nTripID].Segments>
<cfelse>
	<cfset stSegments = session.searches[rc.Search_ID].stAvailTrips[rc.nGroup][rc.nTripID].Segments>
</cfif>
<cfoutput>
	<div>
		<ul class="tabs">
			<cfloop collection="#stSegments#" item="nSeg">
				<li><a <cfif rc.nSegment EQ nSeg>class="active"</cfif> onClick="$('.tabcontent').html('Checking #stSegments[nSeg].Carrier##stSegments[nSeg].FlightNumber# seat availablity...');$('##overlayContent').load('#buildURL('air.seatmap?Search_ID=#rc.nSearchID#&bSuppress=1&nTripID=#rc.nTripID#&nSegment=#nSeg##(rc.nGroup NEQ '' ? "&nGroup=#rc.nGroup#" : "")#')#')">#stSegments[nSeg].Carrier##stSegments[nSeg].FlightNumber#</a></li>
			</cfloop>
		</ul>
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
			<div class="tabcontent">
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
					<td class="paddingright">Unknown</td>
					<td class="seat NoSeat"></td>
					<td class="paddingright">No Seat</td>
				</tr>
				</table>
			</div>
		<cfelse>
			<div class="tabcontent">#rc.stSeats.Error#</div>
		</cfif>
	</div>
</cfoutput>