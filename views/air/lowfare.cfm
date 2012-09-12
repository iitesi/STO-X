<!---<cfoutput>
	#NumberFormat(rc.nTimer)# ms
</cfoutput>--->
<cfset aAllCabins = ["Y","C","F"]>
<cfset aMyCabins = ListToArray(Replace(LCase(StructKeyList(session.searches[rc.nSearchID].Pricing)), 'f', 'F'))>
<cfset temp = ArraySort(aMyCabins, "text", "desc")>
<cfset aRef = ["0","1"]>
<cfset aRef = ["0"]>
<cfoutput>
	#View('air/legs')#
	#View('air/filter')#
</cfoutput>
<br clear="both">
<cfoutput>
	<div id="aircontent">
		<cfloop array="#session.searches[rc.Search_ID].stSortFare#" index="sTrip">
			<cfset stTrip = session.searches[rc.Search_ID].stTrips[sTrip]>
			<div id="#sTrip#" class="badge" style="min-height:300px;">
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
						<cfloop array="#aMyCabins#" index="sCabin">
							<cfloop array="#aRef#" index="sRef">
								<cfif StructKeyExists(stTrip, sCabin)
								AND StructKeyExists(stTrip[sCabin], sRef)>
									#(sCabin EQ 'Y' ? 'ECONOMY' : (sCabin EQ 'C' ? 'BUSINESS' : 'FIRST'))# CLASS
									<input type="submit" name="trigger" class="button#stTrip[sCabin][sRef].Policy#policy" value="$#NumberFormat(stTrip[sCabin][sRef].Total)#">
									<span class="fade">#(sRef EQ 0 ? 'NO REFUNDS' : 'REFUNDABLE')#</span> 
								</cfif>
							</cfloop>
						</cfloop>
					</td>
				</tr>
				<cfloop collection="#stTrip.Groups#" item="nGroup" >
					<tr>
						<td colspan="2" align="center">
							<br>
							<cfset stGroup = stTrip.Groups[nGroup]>
							<table width="90%">
							<tr>
								<td width="25%">
								</td>
								<td class="fade medium" width="30%">
									<strong>#stGroup.Origin#</strong>
								</td>
								<td width="20%">
								</td>
								<td class="fade right medium" width="25%">
									<strong>#stGroup.Destination#</strong>
								</td>
							</tr>
							<tr>
								<td class="bold medium">
									<strong>#DateFormat(stGroup.DepartureTime, 'ddd')#</strong>
								</td>
								<td class="bold medium">
									<strong>#TimeFormat(stGroup.DepartureTime, 'h:mmt')#</strong>
								</td>
								<td class="bold large center">
									-
								</td>
								<td class="bold right medium">
									<strong>#TimeFormat(stGroup.ArrivalTime, 'h:mmt')#</strong>
								</td>
							</tr>
							<cfset cnt = 0>
							<cfloop collection="#stTrip.Segments#" item="nSegment" >
								<cfif stTrip.Segments[nSegment].Group EQ nGroup>
									<tr>
										<td class="fade" valign="top">
											#stTrip.Segments[nSegment].Carrier##stTrip.Segments[nSegment].FlightNumber#
										</td>
										<td class="fade" valign="top">
											Economy
										</td>
										<td class="right fade" valign="top">
											<cfif StructKeyExists(stTrip.Segments, nSegment+1)
											AND stTrip.Segments[nSegment+1].Group EQ nGroup>
												to #stTrip.Segments[nSegment].Destination#
											</cfif>
										</td>
										<td class="right fade" valign="top">
											<cfset cnt++>
											<cfif cnt EQ 1>
												#stGroup.TravelTime#
											</cfif>
										</td>
									</tr>
								</cfif>
							</cfloop>
							</table>
						</td>
					</tr>
				</cfloop>
				</table>
				<br><br>
				Flight Details | Seats | Bags | Email | CouldYou?
			</div>
		</cfloop>
	</div>
	<!---<cfdump eval=session.searches[rc.Search_ID].stTrips>--->
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
	</script>
</cfoutput>