<!---<cfoutput>
	#NumberFormat(rc.nTimer)# ms
</cfoutput>--->
<cfset aAllCabins = ["Y","C","F"]>
<cfset aMyCabins = ListToArray(Replace(LCase(StructKeyList(session.searches[rc.nSearchID].Pricing)), 'f', 'F'))>
<cfset temp = ArraySort(aMyCabins, "text", "desc")>
<cfset aRef = ["0","1"]>
<cfset aRef = ["0"]>
<!---<cfoutput>
	#View('air/filter')#<br>
	#View('air/legs')#
</cfoutput>--->
<br clear="both">
<cfoutput>
	<div class="badgeblank">
		<table width="100%" border="1">
		<tr>
			<td class="fade" width="200px">
			</td>
			<td>
				<div class="grouptab first">
					<a href="#buildURL('air.availability?Search_ID=#rc.nSearchID#')#">
						<div class="number">1</div>
						LAS-LAX
					</a>
				</div><br><br>
			</td>
			<td>
				<div class="grouptab first">
					<a href="#buildURL('air.availability?Search_ID=#rc.nSearchID#')#">
						<div class="number">2</div>
						LAS-LAX
					</a>
				</div><br><br>
			</td>
			<td class="fade">
			</td>
		</tr>
		<tr>
			<td class="fade" width="200px" valign="baseline">
				Carrier <img src="assets/img/down.png">
			</td>
			<td>
				<table width="250px">
				<tr>
					<td width="30%">
					</td>
					<td class="fade" width="30%">
						Depart <img src="assets/img/down.png">
					</td>
					<td width="10%">
					</td>
					<td class="fade" width="30%">
						Arrive <img src="assets/img/down.png">
					</td>
				</tr>
				</table>
			</td>
			<td>
				<table width="250px">
				<tr>
					<td width="30%">
					</td>
					<td class="fade" width="30%">
						Depart <img src="assets/img/down.png">
					</td>
					<td width="10%">
					</td>
					<td class="fade" width="30%">
						Arrive <img src="assets/img/down.png">
					</td>
				</tr>
				</table>
			</td>
			<td class="fade">
				Price <img src="assets/img/down.png">
			</td>
		</tr>
		</table>
	</div>
	<cfloop array="#session.searches[rc.Search_ID].stSortFare#" index="sTrip">
		<cfset stTrip = session.searches[rc.Search_ID].stTrips[sTrip]>
		<div id="#sTrip#" class="badge">
			<table width="100%">
			<tr>
				<td width="200px">
					<img class="carrierimg" src="https://www.shortstravelonline.com/book/assets/img/airlines/#(ListLen(stTrip.Carriers) EQ 1 ? stTrip.Carriers : 'Mult')#.png" style="padding-left:20px;">
				</td>
				<cfloop collection="#stTrip.Groups#" item="nGroup" >
					<td>
						<cfset stGroup = stTrip.Groups[nGroup]>
						<table width="250px">
						<tr>
							<td width="30%">
							</td>
							<td class="fade" width="30%">
								<strong>#stGroup.Origin#</strong>
							</td>
							<td width="10%">
							</td>
							<td class="fade right" width="30%">
								<strong>#stGroup.Destination#</strong>
							</td>
						</tr>
						<tr>
							<td class="bold large">
								<strong>#DateFormat(stGroup.DepartureTime, 'ddd')#</strong>
							</td>
							<td class="bold large">
								<strong>#TimeFormat(stGroup.DepartureTime, 'h:mmt')#</strong>
							</td>
							<td class="bold large center">
								-
							</td>
							<td class="bold large right">
								<strong>#TimeFormat(stGroup.ArrivalTime, 'h:mmt')#</strong>
							</td>
						</tr>
						<tr>
							<td class="fade" valign="top">Economy</td>
							<td class="fade" valign="top" colspan="2">
								#Replace(stGroup.Flights, ',', '<br>', 'ALL')#
							</td>
							<td class="right fade" valign="top">
								<span class="fade">#stGroup.TravelTime#</span>
							</td>
						</tr>
						</table>
						<!---<cfloop array="#aAllCabins#" index="sCabin">
							<cfloop array="#aRef#" index="sRef">
								<div id="#sTrip##sCabin##sRef#" class="left">
									<cfif StructKeyExists(stTrip, sCabin)
									AND StructKeyExists(stTrip[sCabin], sRef)>
										#sCabin##sRef# - $#NumberFormat(stTrip[sCabin][sRef].Total)#
									<cfelse>
										<a href="##" onClick="airPrice(#rc.nSearchID#,#sTrip#,'#sCabin#',#sRef#);return false;">#sCabin##sRef#</a>
									</cfif>
								</div>
							</cfloop>
						</cfloop>--->
						<!---<a href="##" onClick="toggleDiv('#sTrip#details');return false;">Details</a>--->
					</td>
				</cfloop>
				<td class="fares" align="right">
					<cfloop array="#aMyCabins#" index="sCabin">
						<cfloop array="#aRef#" index="sRef">
							<cfif StructKeyExists(stTrip, sCabin)
							AND StructKeyExists(stTrip[sCabin], sRef)>
								#(sCabin EQ 'Y' ? 'ECONOMY' : (sCabin EQ 'C' ? 'BUSINESS' : 'FIRST'))# CLASS
								<input type="submit" name="trigger" class="button" value="$#NumberFormat(stTrip[sCabin][sRef].Total)#">
								#(sRef EQ 0 ? 'NON' : '')# REFUNDABLE
							</cfif>
						</cfloop>
					</cfloop>
				</td>
			</tr>
			<tr height="100%">
				<td valign="bottom" colspan="10">Flight Details | Seats | Bags | Email | CouldYou?</td>
			</tr>
			</table>
		</div>
	</cfloop>
	<script type="application/javascript">
	var flightresults = [<cfset nCount = 0><cfloop array="#session.searches[rc.Search_ID].stSortFare#" index="sTrip"><cfset nCount++>[#session.searches[rc.Search_ID].stTrips[sTrip].sJavascript#]<cfif ArrayLen(session.searches[rc.Search_ID].stSortFare) NEQ nCount>,</cfif></cfloop>];
	$(document).ready(function() {
		$( "##Airlines" ).button();
		$( "##Class" ).button();
		$( "##Fares" ).button();
		$( "##NonStops" ).button();
		$( "##Policy" ).button();
		$( "##Time" ).button();
		$( "##Airlines" ).dialog({
			autoOpen: false,
			minHeight:200,
			maxHeight:400
		});
		filterAir();
	});
	</script>
</cfoutput>