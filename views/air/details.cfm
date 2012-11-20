<cfset aRef = ["0","1"]>
<cfset aMyCabins = ListToArray(Replace(LCase(StructKeyList(session.searches[rc.nSearchID].FareDetails.stPricing)), 'f', 'F'))>
<cfif rc.action EQ 'air.lowfare'>
	<cfset stTrip = session.searches[rc.Search_ID].stTrips[rc.nTripID]>
<cfelse>
	<cfset stTrip = session.searches[rc.Search_ID].stAvailTrips[rc.nGroup][rc.nTripID]>
</cfif>
<cfoutput>
	<div class="roundall" style="padding:10px;background-color:##FFFFFF; display:table;font-size:11px;font-family: verdana;width:#280*2#px">
		<table>
		<tr>
			<cfloop collection="#stTrip.Groups#" item="nGroup" >
				<cfset stGroup = stTrip.Groups[nGroup]>
				<td>
					<div class="roundall" style="padding:10px;margin:10px;display:table-cell;float:left;color:black;width:250px;background-color:##BED3FC;">
						<div style="display:table;padding:10px;">
							<div style="display:table-row">
								<div style="table-cell;float:left;">
									<strong>#application.stAirports[stGroup.Origin]# (#stGroup.Origin#)</strong><br><br>
									<strong>#application.stAirports[stGroup.Destination]# (#stGroup.Destination#)</strong><br><br>
								</div>
							</div>
							<div style="display:table-row">
								<div style="table-cell;float:left; width:30%;">
									Departs
								</div>
								<div style="table-cell;float:left;">
									#DateFormat(stGroup.DepartureTime, 'ddd, mmm d,')#
									#TimeFormat(stGroup.DepartureTime, 'h:mm tt')#
								</div>
							</div>
							<div style="display:table-row">
								<div style="table-cell; float:left; width:30%;">
									Arrives
								</div>
								<div style="table-cell;float:left;">
									#DateFormat(stGroup.ArrivalTime, 'ddd, mmm d,')#
									#TimeFormat(stGroup.ArrivalTime, 'h:mm tt')#
								</div>
							</div>
							<div style="display:table-row">
								<div style="table-cell;float:left; width:30%;">
									Duration
								</div>
								<div style="table-cell;float:left;">
									#stGroup.TravelTime#
								</div><br><br>
							</div>
						</div>
						<div style="display:table-cell;float:left;color:black;width:100%;">
							<cfset cnt = 0>
							<cfloop collection="#stTrip.Segments#" item="nSegment" >
								<cfif stTrip.Segments[nSegment].Group EQ nGroup>
									<div class="roundall" style="width:90%;padding:10px;border:1px solid ##CFDAFA;background-color:##FFFFFF;">
										</p>
											<strong>
												#application.stAirVendors[stTrip.Segments[nSegment].Carrier].Name#
												###stTrip.Segments[nSegment].FlightNumber#
											</strong>
										</p>
										<p>
											#stTrip.Segments[nSegment].Origin# - 
											#DateFormat(stTrip.Segments[nSegment].DepartureTime, 'mmm d,')# at
											#TimeFormat(stTrip.Segments[nSegment].DepartureTime, 'h:mm tt')#
										</p>
										<cfif stTrip.Segments[nSegment].ChangeOfPlane>
											<p>
													Plane Change
											</p>						
										</cfif>
										<cfif stTrip.Segments[nSegment].FlightTime NEQ ''>
											<p class="fade">
												&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
												Flight Time 
												#int(stTrip.Segments[nSegment].FlightTime/60)#h #stTrip.Segments[nSegment].FlightTime%60#m
											</p>						
										</cfif>
										<p>
											#stTrip.Segments[nSegment].Destination# - 
											#DateFormat(stTrip.Segments[nSegment].ArrivalTime, 'mmm d,')# at
											#TimeFormat(stTrip.Segments[nSegment].ArrivalTime, 'h:mm tt')#
										</p>
										<cfif stTrip.Segments[nSegment].Equipment NEQ ''>
											<p class="fade">
												&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
												on #application.stEquipment[stTrip.Segments[nSegment].Equipment]#
											</p>
										</cfif>
									</div>
									<cfif structKeyExists(stTrip.Segments, nSegment+1)
									AND stTrip.Segments[nSegment+1].Group EQ nGroup>
										<div class="roundall" style="width:90%;padding:10px;margin-right:10px;margin-top:5px;margin-bottom:5px;border:1px solid ##eeeeee;background-color:##eeeeee">
											<cfset minites = DateDiff('n', stTrip.Segments[nSegment].ArrivalTime, stTrip.Segments[nSegment+1].DepartureTime)>
											Layover:
											#int(minites/60)#h #minites%60#m
											in #stTrip.Segments[nSegment].Destination#
										</div>
									</cfif>
								</cfif>
							</cfloop>
							</td>
						</div>
					</div>
				</td>
			</cfloop>
		</tr>
		</table>
	</div>
</cfoutput>
