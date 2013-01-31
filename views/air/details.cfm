<cfset aRef = ["0","1"]>
<cfset aMyCabins = ListToArray(Replace(LCase(StructKeyList(session.searches[rc.SearchID].stLowFareDetails.stPricing)), 'f', 'F'))>
<cfif rc.nGroup EQ ''>
	<cfset stTrip = session.searches[rc.SearchID].stTrips[rc.nTripID]>
<cfelse>
	<cfset stTrip = session.searches[rc.SearchID].stAvailTrips[rc.nGroup][rc.nTripID]>
</cfif>
<cfoutput>
	<div class="roundall" style="padding:10px;background-color:##FFFFFF; display:table;font-size:11px;width:#300*2#px">
		<table>
		<tr>
			<cfloop collection="#stTrip.Groups#" item="nGroup" >
				<cfset stGroup = stTrip.Groups[nGroup]>
				<td valign="top">
					<div class="roundall" style="padding:10px;margin:10px;display:table-cell;float:left;color:black;width:290px;background-color:##BED3FC;">
						<table>
							<tr>
								<td colspan="2">
									<strong>#application.stAirports[stGroup.Origin]# (#stGroup.Origin#)</strong><br><br>
									<strong>#application.stAirports[stGroup.Destination]# (#stGroup.Destination#)</strong><br><br>
								</td>
							</tr>
							<tr>
								<td width="40%">
									Departs
								</td>
								<td>
									#DateFormat(stGroup.DepartureTime, 'ddd, mmm d,')#
									#TimeFormat(stGroup.DepartureTime, 'h:mm tt')#
								</td>
							</tr>
							<tr>
								<td>
									Arrives
								</td>
								<td>
									#DateFormat(stGroup.ArrivalTime, 'ddd, mmm d,')#
									#TimeFormat(stGroup.ArrivalTime, 'h:mm tt')#
								</td>
							</tr>
							<tr>
								<td>
									Duration
								</td>
								<td>
									#stGroup.TravelTime#
								</td>
							</tr>
						</table><br><br>
						<div style="display:table-cell;float:left;color:black;width:100%;">
							<cfset nCnt = 0>
							<cfset aKeys = structKeyArray(stGroup.Segments)>
							<cfloop collection="#stGroup.Segments#" item="nSegment" >
								<cfset nCnt++>
								<cfset stSegment = stGroup.Segments[nSegment]>
								<div class="roundall" style="width:90%;padding:10px;border:1px solid ##CFDAFA;background-color:##FFFFFF;">
									</p>
										<strong>
											#application.stAirVendors[stSegment.Carrier].Name#
											###stSegment.FlightNumber#
										</strong>
									</p>
									<p>
										<span title="#application.stAirports[stSegment.Origin]#">#stSegment.Origin#</a> - 
										#DateFormat(stSegment.DepartureTime, 'mmm d,')# at
										#TimeFormat(stSegment.DepartureTime, 'h:mm tt')#
									</p>
									<cfif stSegment.ChangeOfPlane>
										<p>
											Plane Change
										</p>						
									</cfif>
									<cfif stSegment.FlightTime NEQ ''>
										<p class="fade">
											&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
											Flight Time 
											#int(stSegment.FlightTime/60)#h #stSegment.FlightTime%60#m
										</p>						
									</cfif>
									<p>
										<span title="#application.stAirports[stSegment.Destination]#">#stSegment.Destination#</a> - 
										#DateFormat(stSegment.ArrivalTime, 'mmm d,')# at
										#TimeFormat(stSegment.ArrivalTime, 'h:mm tt')#
									</p>
									<cfif stSegment.Equipment NEQ ''
									AND StructKeyExists(application.stEquipment, stSegment.Equipment)>
										<p class="fade">
											&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
											on #application.stEquipment[stSegment.Equipment]#
										</p>
									</cfif>
								</div>
								<cfif nCnt LT ArrayLen(aKeys)
								AND stGroup.Segments[aKeys[nCnt+1]].Group EQ nGroup>
									<div class="roundall" style="width:90%;padding:10px;margin-right:10px;margin-top:5px;margin-bottom:5px;border:1px solid ##eeeeee;background-color:##eeeeee">
										<cfset minites = DateDiff('n', stSegment.ArrivalTime, stGroup.Segments[aKeys[nCnt+1]].DepartureTime)>
										Layover:
										#int(minites/60)#h #minites%60#m
										in 
										<span title="#application.stAirports[stSegment.Destination]#">#stSegment.Destination#</span>
									</div>
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
