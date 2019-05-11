<cfsilent>
	<cfparam name="rc.bSelection" default="0">
	<cfparam name="rc.Summary" default="false">
	<cfparam name="rc.seat" default="">

	<cfset sCurrentSeat = rc.seat>
	<cfset sNextSegKey = ''>
	<cfset bFound = 0>
	<cfset nSegmentCount = 0>
	<cfset breadCount = 0>
	<cfset nTotalCount = 0>
</cfsilent> 
<cftry>
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
				<cfloop collection="#session.searches[rc.SearchID].stAvailTrips[rc.Group][rc.nTripID].Groups[rc.Group].Segments#" index="local.nSegment">
					<cfset rc.nSegment = nSegment>
					<cfbreak>
				</cfloop>
			</cfif>
			<cfset stGroups = session.searches[rc.SearchID].stAvailTrips[rc.Group][rc.nTripID].Groups>
		</cfif> 
		<!--- get the current segment --->
		<cfset rc.nSegment = replace(rc.nSegment, " ", "+", "ALL") /> 
		<cfset currentSegment = structFindKey(stGroups,rc.nSegment)[1].value> 
		<!--- get how many segments there are in this trip --->
		<cfset segmentCount = 0>
		<cfloop collection="#stGroups#" index="GroupKey" item="stGroup">
			<cfloop collection="#stGroup.Segments#" index="sSegKey" item="stSegment">
				<cfset segmentCount++>
			</cfloop>
		</cfloop>

	<!--- hide breadcrumb bar for summary modal --->
	<cfif rc.action NEQ "air.summarypopup">
		<ul class="nav nav-pills nav-stacked">
			<cfset sURL = 'SearchID=#rc.SearchID#&nTripID=#rc.nTripID#&Group=#rc.Group#'>
			<cfloop collection="#stGroups#" index="GroupKey" item="stGroup">
				<cfloop collection="#stGroup.Segments#" index="sSegKey" item="stSegment">
					<cfset breadCount++>
						<cfset sClass = (structKeyExists(stSegment, "Class") ? stSegment.Class : 'Y') />
						<li class="<cfif rc.nSegment EQ sSegKey>active</cfif>">
							<a class="pointer" title="View seats for this flight..." onClick="$('##seats').html('<i class=&quot;icon-spinner icon-spin&quot;></i> One moment while we fetch seat information...');$('##seatcontent').load('?action=air.seatmap&#sURL#&nSegment=#sSegKey#&sClass=#sClass#&bSelection=1');" >
								#application.stAirVendors[stSegment.Carrier].Name# #stSegment.FlightNumber# (#stSegment.Origin# to #stSegment.Destination#)
							</a>

						</li>
				</cfloop>
			</cfloop>
		</ul>
	</cfif>

		<div id="seats">
			<!--- show seatmap heading --->
			<img class="popuplogo pull-left" src="assets/img/airlines/#currentSegment.Carrier#_sm.png">
			<div class="media-heading pull-left">
				<h3>#application.stAirVendors[currentSegment.Carrier].Name# #currentSegment.FlightNumber# #application.stAirports[currentSegment.Origin].airport# (#currentSegment.Origin#) to #application.stAirports[currentSegment.Destination].airport# (#currentSegment.Destination#)
				<cfif structKeyExists(rc, "seat") AND Len(rc.seat)>
				:: Selected Seat - #rc.seat#
				</cfif>
			</h3>
				#DateFormat(currentSegment.DepartureTime, 'ddd, mmm d')# - #TimeFormat(currentSegment.DepartureTime, 'h:mm tt')# to #TimeFormat(currentSegment.ArrivalTime, 'h:mm tt')#
			</div>
			<div class="clearfix"></div>

		<!--- show seatmap rc.stSeats is returned from doSeatMap --->
			<cfif isStruct(rc.stSeats) AND NOT structIsEmpty(rc.stSeats) AND NOT StructKeyExists(rc.stSeats, 'Error')>
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
			<table class="popUpTable seatmapTable_desktop hidden-xs">
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

								<cfif NOT structKeyExists(rc.stSeats[nRow], sColumn)>
									<cfset rc.stSeats[nRow][sColumn].AVAIL = "No Seat" />
								</cfif>

								<cfif structKeyExists(rc.stSeats[nRow], sColumn)>
									<cfset sDesc = rc.stSeats[nRow][sColumn].AVAIL>
									<cfset sDesc = ListAppend(sDesc, structKeyList(rc.stSeats[nRow][sColumn]))>
									<cfif ListFind(sDesc, 'AVAIL') GT 0>
									<cfset sDesc = ListDeleteAt(sDesc, ListFind(sDesc, 'AVAIL'))>
									</cfif>
									<cfset sDesc = Replace(sDesc, ',', ', ')>
									<cfset sDesc = (sDesc EQ '' ? nRow&sColumn : nRow&sColumn&': '&sDesc)>
									<tr>
										<td class="seat #rc.stSeats[nRow][sColumn].Avail#<cfif sCurrentSeat EQ nRow&sColumn> currentseat</cfif>" title="#sDesc#" id="#nRow##sColumn#">
											<!--- Per STM-2013: Removed the clickable action from air results only; can still click from summary page. --->
											<cfif rc.action EQ 'air.summarypopup'>
												<cfif rc.stSeats[nRow][sColumn].Avail EQ 'Available'>
													<a href="##" style="display: block;" class="availableSeat" id="#rc.nTotalCount#|#nRow##sColumn#" title="Seat #nRow##sColumn#">&nbsp;</a>
												<cfelseif rc.stSeats[nRow][sColumn].Avail EQ 'Preferential'>
													<a href="##" style="display: block;" class="preferredSeat" id="#rc.nTotalCount#|#nRow##sColumn#" title="Seat #nRow##sColumn#">&nbsp;</a>
												</cfif>
											</cfif>
										</td>
									</tr>
								</cfif>
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

			<!-- mobile seatmap -->
			<table class="popUpTable seatmapTable_mobile visible-xs">


			<!---	Display seats	--->

					<cfloop array="#aRows#" index="nRow">
						<tr>
						<!-- Left wing -->
						<td>
							<table width="15">
							<tr>
								<cfif NOT structKeyExists(stExitRows, nRow)>
									<td>&nbsp;</td>
								<cfelse>
									<td class="wingmiddle">&nbsp;</td>
								</cfif>
							</tr>
							</table>
						</td>
						<!-- End Left Wing -->

							<!-- <table width="25"> -->
							<cfloop array="#aColumns#" index="sColumn">
								<cfif structKeyExists(stAisles, sColumn)>
									<td>
										<table width="25">
											<tr>
												<td align="center">#nRow#</td>
											</tr>
										</table>
									</td>
								</cfif>

								<cfif NOT structKeyExists(rc.stSeats[nRow], sColumn)>
									<cfset rc.stSeats[nRow][sColumn].AVAIL = "No Seat" />
								</cfif>

								<cfif structKeyExists(rc.stSeats[nRow], sColumn)>
									<cfset sDesc = rc.stSeats[nRow][sColumn].AVAIL>
									<cfset sDesc = ListAppend(sDesc, structKeyList(rc.stSeats[nRow][sColumn]))>
									<cfif ListFind(sDesc, 'AVAIL') GT 0>
										<cfset sDesc = ListDeleteAt(sDesc, ListFind(sDesc, 'AVAIL'))>
									</cfif>
									<cfset sDesc = Replace(sDesc, ',', ', ')>
									<cfset sDesc = (sDesc EQ '' ? nRow&sColumn : nRow&sColumn&': '&sDesc)>
									<td>
										<table width="25">
											<tr>
												<td class="seat #rc.stSeats[nRow][sColumn].Avail#<cfif sCurrentSeat EQ nRow&sColumn> currentseat</cfif>" title="#sDesc#" id="#nRow##sColumn#">
													<!--- Per STM-2013: Removed the clickable action from air results only; can still click from summary page. --->
													<cfif rc.action EQ 'air.summarypopup'>
														<cfif rc.stSeats[nRow][sColumn].Avail EQ 'Available'>
															<a href="##" style="display: block;" class="availableSeat" id="#rc.nTotalCount#|#nRow##sColumn#" title="Seat #nRow##sColumn#">&nbsp;</a>
														<cfelseif rc.stSeats[nRow][sColumn].Avail EQ 'Preferential'>
															<a href="##" style="display: block;" class="preferredSeat" id="#rc.nTotalCount#|#nRow##sColumn#" title="Seat #nRow##sColumn#">&nbsp;</a>
														</cfif>
													</cfif>
												</td>
											</tr>
										</table>
									</td>
								</cfif>
							</cfloop>
							<!--</table>-->

						<!-- Right Wing -->
						<td>
							<table width="15">
							<tr>
								<cfif NOT structKeyExists(stExitRows, nRow)>
									<td>&nbsp;</td>
								<cfelse>
									<td class="wingmiddle">&nbsp;</td>
								</cfif>
							</tr>
							</table>
						</td>
						<!-- End Right wing -->

						</tr>
					</cfloop>



			</table>
			<!-- end mobile setmap -->

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

				<table id="confirmPreferredTable" class="hide">
					<tr>
						<td>
							<br />
							<h3>You have selected a preferred seat. Please make sure your frequent flyer status qualifies you for this preferred seat.</h3>
							<h3 class="red bold">If you do not qualify for a preferred seat with this specific airline and you choose a preferred seat, you will not be able to book this flight.</h3>
							<input type="hidden" id="preferredSeatID" value="">
							<input type="button" id="confirmSeat" class="btn btn-primary" value="CONTINUE WITH PREFERRED SEAT">
						</td>
					</tr>
				</table>
			<cfelseif isStruct(rc.stSeats) AND structKeyExists(rc.stSeats, "Error")>
				<div id="seatcontent"><p>#rc.stSeats.Error#</p></div>
			<cfelse>
				<div id="seatcontent"><p>No seat map is available for this flight.</p></div>
			</cfif>
		</div>
	</div>

	<script>
		$(document).ready(function() {
			$('.availableSeat').on('click', function() {
				var seatSelected =  $(this).attr('id');
				window.parent.GetValueFromChild( seatSelected );
				$('##popupModal').modal('hide');
				$(this).removeData('modal');
			});

			$('.preferredSeat').on('click', function() {
				var preferredSeatSelected =  $(this).attr('id');
				$('##confirmPreferredTable').removeClass('hide');
				$('##preferredSeatID').val(preferredSeatSelected);
			});

			$('##confirmSeat').on('click', function() {
				var seatSelected =  $('##preferredSeatID').val();
				window.parent.GetValueFromChild( seatSelected ); 
				$('##popupModal').modal('hide');
				$(this).removeData('modal');
			});
		});
	</script>

</cfoutput>
	<cfcatch type="any">
		<cfif rc.action eq "air.popup">
			<strong>Seat Map not available at this time. Please select seats on the upcoming summary page.</strong>
		<cfelse>
			<cfoutput>
			 	<cfsavecontent variable="catchvar">
			 		Message: #cfcatch.Message# 
			 		Raw_Trace: #cfcatch.TagContext[1].Raw_Trace#
			 	</cfsavecontent>
			 </cfoutput> 
			<cfthrow message="#catchvar#">
		</cfif>
	</cfcatch>
</cftry>