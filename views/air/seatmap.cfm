




<!---     <div class="tabbable tabs-left"> <!-- Only required for left/right tabs -->
    <ul class="nav nav-tabs">
    <li class="active"><a href="#tab1" data-toggle="tab">Section 1</a></li>
    <li><a href="#tab2" data-toggle="tab">Section 2</a></li>
    </ul>
    <div class="tab-content">
    <div class="tab-pane active" id="tab1">
    <p>I'm in Section 1.</p>
    </div>
    <div class="tab-pane" id="tab2">
    <p>Howdy, I'm in Section 2.</p>
    </div>
    </div>
    </div> --->



<cfsetting showdebugoutput="false">
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
		<ul class="tabs">
			<table>
			<tr height="30">
				<cfset sURL = 'SearchID=#rc.SearchID#&nTripID=#rc.nTripID#&Group=#rc.Group#'>
				<cfloop collection="#stGroups#" index="GroupKey" item="stGroup">
					<cfloop collection="#stGroup.Segments#" index="sSegKey" item="stSegment">
						<td>
							<li>
								<a class="<cfif rc.nSegment EQ sSegKey>active</cfif>" onClick="$('##seats').html('One moment please...');$('##seatcontent').load('?action=air.seatmap&#sURL#&nSegment=#sSegKey#&bSelection=1');" >
									X #stSegment.Carrier# #stSegment.FlightNumber# (#stSegment.Origin# to #stSegment.Destination#)
								</a>
							</li>
						</td>
					</cfloop>
				</cfloop>
			</tr>
			<cfset sCurrentSeat = ''>
			<cfset sNextSegKey = ''>
			<cfset bFound = 0>
			<cfset nSegmentCount = 0>
			<cfif rc.bSelection>
				<tr>
					<cfloop collection="#stGroups#" index="GroupKey" item="stGroup">
						<cfloop collection="#stGroup.Segments#" index="sSegKey" item="stSegment">
							<cfset nSegmentCount++>
							<td>
								Seat: <!--- <input type="text" id="Seat#stSegment.Carrier##stSegment.FlightNumber##stSegment.Origin##stSegment.Destination#_popup" size="4" maxlength="5" value="#session.searches[rc.SearchID].stTravelers[1].stSeats['#stSegment.Carrier##stSegment.FlightNumber##stSegment.Origin##stSegment.Destination#']#" disabled> --->
							</td>
							<cfif bFound EQ 1>
								<cfset bFound = 0>
								<cfset sNextSegKey = sSegKey>
							</cfif>
							<cfif rc.nSegment EQ sSegKey>
								<cfset bFound = 1>
								<cfset stSegments = stSegment>
								<!--- <cfset sCurrentSeat = session.searches[rc.SearchID].stTravelers[1].stSeats['#stSegment.Carrier##stSegment.FlightNumber##stSegment.Origin##stSegment.Destination#']> --->
							</cfif>
						</cfloop>
					</cfloop>
				</tr>
				<cfif sNextSegKey NEQ ''>
					<tr>
						<td colspan="#nSegmentCount#" align="right">
							<br><br>
							<a onClick="$('##seats').html('One moment please...');$('##seatcontent').load('?action=air.seatmap&#sURL#&nSegment=#sNextSegKey#&bSelection=1');">
								Next Segment >>
							</a>
						</td>
					</tr>
				</cfif>
			</cfif>
			</table>
		</ul>
		<div id="seats">
			<strong>
				<img class="carrierimg" src="assets/img/airlines/#stSegment.Carrier#.png" style="float:left;padding-right:20px;">
				#application.stAirVendors[stSegment.Carrier].Name# Flt ###stSegment.FlightNumber# <br>
				#application.stAirports[stSegment.Origin]# (#stSegment.Origin#) to #application.stAirports[stSegment.Destination]# (#stSegment.Destination#) <br>
				#DateFormat(stSegment.DepartureTime, 'ddd, mmm d')# - #TimeFormat(stSegment.DepartureTime, 'h:mm tt')# to #TimeFormat(stSegment.ArrivalTime, 'h:mm tt')#
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
									<td class="seat #rc.stSeats[nRow][sColumn].Avail#<cfif sCurrentSeat EQ nRow&sColumn> currentseat</cfif>" title="#sDesc#" id="#nRow##sColumn#">
										<cfif rc.bSelection
										AND rc.stSeats[nRow][sColumn].Avail EQ 'Available'>
											<a href="##" onClick="selectSeats('#stSegments.Carrier#', #stSegments.FlightNumber#, '#nRow##sColumn#', '#stSegments.Origin#', '#stSegments.Destination#');return false;" style="text-decoration:none;">&nbsp;&nbsp;&nbsp;&nbsp;</a>
										</cfif>
									</td>
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
				<div id="seatcontent">#rc.stSeats.Error#</div>
			</cfif>
		</div>
	</div>
</cfoutput>