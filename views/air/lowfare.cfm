<cfoutput>
	#NumberFormat(rc.nTimer)# ms
</cfoutput>
<cfset aAllCabins = ["Y","C","F"]>
<cfset aCabins = ["Y"]>
<cfset aRef = ["0","1"]>
<div class="filter">
	Policy<br>
	<input type="checkbox" id="Policy" value="1" onChange="filterAir();return false;" checked="checked"> <label for="Policy">In Policy</label><br>
	<br>
	Carrier Types<br>
	<input type="radio" id="MultiCarrier" name="MultiCarrier" value="0" onChange="filterAir();return false;" checked="checked"> Single Carrier<br>
	<input type="radio" id="MultiCarrier" name="MultiCarrier" value="1" onChange="filterAir();return false;"> All Itineraries<br>
	<br>
	Stops<br>
	<input type="checkbox" id="Stops0" name="Stops0" value="0" onChange="filterAir();return false;" checked="checked"> <label for="Stops0">Nonstop</label><br>
	<input type="checkbox" id="Stops1" name="Stops1" value="1" onChange="filterAir();return false;" checked="checked"> <label for="Stops1">1 Stop</label><br>
	<input type="checkbox" id="Stops2" name="Stops2" value="2" onChange="filterAir();return false;" checked="checked"> <label for="Stops2">2+ Stops</label><br>
	<br>
	<!---Carriers<br>
	<cfoutput query="rc.carriers">
		<input type="checkbox" id="Carrier#Carrier#" value="#Carrier#" onChange="filterAir();return false;" checked="checked"> <label for="Carrier#Carrier#">#CarrierName#</label><br>
	</cfoutput>
	<br>--->
	Preferred<br>
	<input type="checkbox" id="Preferred" value="1" onChange="filterAir();return false;"> <label for="Preferred">Preferred Airlines</label><br>
	<br>
	Display Options<br>
	<input type="checkbox" id="Details" value="1" onChange="showDetails();return false;"> <label for="Details">Expand All Details</label><br>
	<br>
	<br>
	<br>
	<br>
	<h3>Find More Fares</h3>
	<table width="100%" id="findmore">
	<tr>
		<td></td>
		<td align="center">Non Ref</td>
		<td align="center">Refundable</td>
	</tr>
	<cfoutput>
		<cfloop array="#aAllCabins#" index="sCabin">
			<tr>
				<td>#(sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First'))#</td>
				<td align="center">
					<cfif StructKeyExists(session.searches[rc.nSearchID].Pricing, sCabin)
					AND StructKeyExists(session.searches[rc.nSearchID].Pricing[sCabin], 0)>
						<img src="assets/img/checkmark.gif">
					<cfelse>
						<a href="#buildURL('air.lowfare&Search_ID=#rc.nSearchID#&bRefundable=0&sCabins=#sCabin#')#" onClick="toggleDiv('waiting');">Find</a>
					</cfif>
				</td>
				<td align="center">
					<cfif StructKeyExists(session.searches[rc.nSearchID].Pricing, sCabin)
					AND StructKeyExists(session.searches[rc.nSearchID].Pricing[sCabin], 1)>
						<img src="assets/img/checkmark.gif">
					<cfelse>
						<a href="#buildURL('air.lowfare&Search_ID=#rc.nSearchID#&bRefundable=1&sCabins=#sCabin#')#" onClick="toggleDiv('waiting');">Find</a>
					</cfif>
				</td>
			</tr>
		</cfloop>
	</cfoutput>
	</table>
</div>
<cfoutput>
	<cfloop array="#session.searches[rc.Search_ID].stSortFare#" index="sTrip">
		<cfset stTrip = session.searches[rc.Search_ID].stTrips[sTrip]>
		<div id="#sTrip#" class="list">
			<table width="100%">
			<tr>
				<td width="50px">
					<!---<cfif rc.results[token].Preferred EQ 1>
						Pref Carrier<br>
					</cfif>--->
					<img class="carrierimg" src="https://www.shortstravelonline.com/book/assets/img/airlines/#(ListLen(stTrip.Carriers) EQ 1 ? stTrip.Carriers : 'Mult')#.png">
				</td>
				<td>
					<table width="100%">
					<cfloop collection="#stTrip.Segments#" item="sSegment">
						<cfif StructKeyExists(stTrip.Segments[sSegment], 'Start')>
							<cfset Origin = stTrip.Segments[sSegment].Origin>
							<cfset DepartureTime = stTrip.Segments[sSegment].DepartureTime>
						</cfif>
						<cfif StructKeyExists(stTrip.Segments[sSegment], 'Dest')>
							<tr>
								<td>
									#Replace(stTrip.Segments[sSegment].Flights, ',', ', ', 'ALL')#
								</td>
								<td>
									<strong>#Origin#</strong>
								</td>
								<td>
									<strong>#TimeFormat(DepartureTime, 'h:mm t')#</strong>
								</td>
								<td>
									-->
								</td>
								<td>
									<strong>#stTrip.Segments[sSegment].Destination#</strong>
								</td>
								<td>
									<strong>#TimeFormat(stTrip.Segments[sSegment].ArrivalTime, 'h:mm t')#</strong>
								</td>
								<td>
									<span class="fade">#int(stTrip.Segments[sSegment].TravelTime/60)#h 
									#stTrip.Segments[sSegment].TravelTime%60#m</span>
								</td>
							</tr>
						</cfif>
					</cfloop>
					</table>
					<a href="##" onClick="toggleDiv('#sTrip#details');return false;">Details</a>
				</td>
				<cfloop array="#aCabins#" index="sCabin">
					<td class="fares" width="200">
						<h2 class="classofservice">
							#(sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First'))#<br>
						</h2>
						<cfloop array="#aRef#" index="sRef">
							<cfif StructKeyExists(stTrip, sCabin)
							AND StructKeyExists(stTrip[sCabin], sRef)>
								<h1 class="policy1">
									$#NumberFormat(stTrip[sCabin][sRef].Total)#
								</h1>
								#(sRef EQ 0 ? 'Nonrefundable' : 'Refundable')#
								<input type="submit" name="trigger" class="button" value="Reserve">
							</cfif>
						</cfloop>
					</td>
				</cfloop>
			</tr>
			<tr>
				<td colspan="5">
				<div id="#sTrip#details" style="display:none">
					<br><br>
					<table width="100%" class="details">
					<cfloop collection="#stTrip.Segments#" item="sSegment">
						<tr bgcolor="##E8F8FF">
							<td>
								#stTrip.Segments[sSegment].Carrier##stTrip.Segments[sSegment].FlightNumber#<br>
								#application.stAirVendors[stTrip.Segments[sSegment].Carrier]#
							</td>
							<td>
								<strong>#stTrip.Segments[sSegment].Origin#</strong><br>
								#application.stAirports[stTrip.Segments[sSegment].Origin]#
							</td>
							<td>
								<strong>#TimeFormat(stTrip.Segments[sSegment].DepartureTime, 'h:mm t')#</strong>
							</td>
							<td>
								-->
							</td>
							<td>
								<strong>#stTrip.Segments[sSegment].Destination#</strong><br>
								#application.stAirports[stTrip.Segments[sSegment].Destination]#
							</td>
							<td>
								<strong>#TimeFormat(stTrip.Segments[sSegment].ArrivalTime, 'h:mm t')#</strong>
							</td>
							<td>
								<span class="fade">#int(stTrip.Segments[sSegment].FlightTime/60)#h 
								#stTrip.Segments[sSegment].FlightTime%60#m</span>
							</td>
							<td>
								#(StructKeyExists(application.stEquipment, stTrip.Segments[sSegment].Equipment) ? application.stEquipment[stTrip.Segments[sSegment].Equipment] : '')#
							</td>
							<td>
								#(stTrip.Segments[sSegment].ChangeOfPlane EQ 1 ? 'Plane Change' : '')#
							</td>
							<cfset tempArrival = stTrip.Segments[sSegment].ArrivalTime>
						</tr>
						<cfif StructKeyExists(stTrip.Segments[sSegment], 'Layover')>
							<tr>
								<td colspan="10" class="layover">
									Layover in
									(#stTrip.Segments[sSegment].Destination#)
									#application.stAirports[stTrip.Segments[sSegment].Destination]#
									for 
									#stTrip.Segments[sSegment].Layover#
									</td>
							</tr>
						</cfif>
						<cfif StructKeyExists(stTrip.Segments[sSegment], 'Dest')>
							<tr>
								<td colspan="10" class="destination">&nbsp;</td>
							</tr>
						</cfif>
					</cfloop>
					</table>
				</div>
				</td>
			</tr>
			</table>
		</div>
	</cfloop>
</cfoutput>
<!---<script type="application/javascript">
var flightresults = [<cfoutput query="rc.sortingfare">[#rc.results[token].js#]<cfif CurrentRow NEQ RecordCount>,</cfif></cfoutput>];
$(document).ready(function() {
	filterAir();
});
</script>--->