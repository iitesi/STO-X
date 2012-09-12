<cfoutput>
	#View('air/legs')#
	#View('air/filter')#
</cfoutput>
<br clear="both">
<cfoutput>
	<div id="aircontent">
		<cfloop array="#session.searches[rc.Search_ID].stSortSegments#" index="sTripKey">
			<cfset stTrip = session.searches[rc.Search_ID].stAvailTrips[sTripKey]>
			<div id="#sTripKey#" class="badge" style="min-height:230px;">
				<table width="100%">
				<tr>
					<td width="125px" align="center">
						<cfloop collection="#stTrip.Segments#" item="nSegment" >
							<cfif ArrayFind(application.stAccounts[session.Acct_ID].aPreferredAir, stTrip.Segments[nSegment].Carrier)>
								<span class="medium blue bold">PREFERRED</span><br>
								<cfbreak>
							</cfif>
						</cfloop>
						<img class="carrierimg" src="https://www.shortstravelonline.com/book/assets/img/airlines/#(ListLen(stTrip.Carriers) EQ 1 ? stTrip.Carriers : 'Mult')#.png">
						#(ListLen(stTrip.Carriers) EQ 1 ? '<br>'&application.stAirVendors[stTrip.Carriers].Name : '')#
					</td>
					<td class="fares" align="right">
						<input type="submit" name="trigger" class="button1policy" value="Select">
					</td>
				</tr>
				<cfset nMaxSeg = ArrayLen(StructKeyArray(stTrip.Segments))>
				<tr>
					<td colspan="2" align="center">
						<br>
						<table width="90%">
						<tr>
							<td width="25%">
							</td>
							<td class="fade medium" width="30%">
								<strong>#stTrip.Segments[1].Origin#</strong>
							</td>
							<td width="20%">
							</td>
							<td class="fade right medium" width="25%">
								<strong>#stTrip.Segments[nMaxSeg].Destination#</strong>
							</td>
						</tr>
						<tr>
							<td class="bold medium">
								<strong>#DateFormat(stTrip.Segments[1].DepartureTime, 'ddd')#</strong>
							</td>
							<td class="bold medium">
								<strong>#TimeFormat(stTrip.Segments[1].DepartureTime, 'h:mmt')#</strong>
							</td>
							<td class="bold large center">
								-
							</td>
							<td class="bold right medium">
								<strong>#TimeFormat(stTrip.Segments[nMaxSeg].ArrivalTime, 'h:mmt')#</strong>
							</td>
						</tr>
						<cfset cnt = 0>
						<cfloop collection="#stTrip.Segments#" item="nSegment" >
							<tr>
								<td class="fade" valign="top">
									#stTrip.Segments[nSegment].Carrier##stTrip.Segments[nSegment].FlightNumber#
								</td>
								<td class="fade" valign="top">
									Economy
								</td>
								<td class="right fade" valign="top">
									<cfif StructKeyExists(stTrip.Segments, nSegment+1)>
										to #stTrip.Segments[nSegment].Destination#
									</cfif>
								</td>
								<td class="right fade" valign="top">
									<cfset cnt++>
									<cfif cnt EQ 1>
										#int(stTrip.Segments[nSegment].TravelTime/60)#h #stTrip.Segments[nSegment].TravelTime%60#m
									</cfif>
								</td>
							</tr>
						</cfloop>
						</table>
					</td>
				</tr>
				</table>
				<br><br>
				Flight Details | Seats | Bags | Email | CouldYou?
			</div>
		</cfloop>
	</div>
	<!---<cfdump eval=session.searches[rc.Search_ID].stTrips>
	<script type="application/javascript">
	var sortarrival = #SerializeJSON(session.searches[rc.nSearchID].stSortArrival)#;
	var sortdepart = #SerializeJSON(session.searches[rc.nSearchID].stSortDepart)#;
	var sortfare = #SerializeJSON(session.searches[rc.nSearchID].stSortFare)#;
	var sortduration = #SerializeJSON(session.searches[rc.nSearchID].stSortDuration)#;
	var sortbag = #SerializeJSON(session.searches[rc.nSearchID].stSortBag)#;
	var flightresults = [<cfset nCount = 0><cfloop array="#session.searches[rc.Search_ID].stSortFare#" index="sTrip"><cfset nCount++>[#session.searches[rc.Search_ID].stTrips[sTrip].sJavascript#]<cfif ArrayLen(session.searches[rc.Search_ID].stSortFare) NEQ nCount>,</cfif></cfloop>];
	$(document).ready(function() {
		filterAir();
	});
	</script>--->
</cfoutput>