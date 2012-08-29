<cfoutput>
	#NumberFormat(rc.nTimer)# ms
</cfoutput>
<cfset aAllCabins = ["Y","C","F"]>
<cfset aMyCabins = ListToArray(Replace(LCase(StructKeyList(session.searches[rc.nSearchID].Pricing)), 'f', 'F'))>
<cfset temp = ArraySort(aMyCabins, "text", "desc")>
<cfset aRef = ["0","1"]>
<cfoutput>
	<div id="leg-selector-1" class="roundtrip">
		<div class="grouptab tab-0 first selected">
			<a href="#buildURL('air.availability?Search_ID=#rc.nSearchID#')#">LAS-LAX</a>
		</div>
		<div class="grouptab tab-1 last previous-selected">
			<a href="#buildURL('air.availability?Search_ID=#rc.nSearchID#')#">LAX-LAS</a>
		</div>
	</div>
	<br>
</cfoutput>
<div id="filterbar">
	<div id="sortbar">
		<div class="filterheader">Sorts</h2>
		<input type="radio" id="price" name="sort" /><label for="price">Price</label>
		<input type="radio" id="duration" name="sort" checked="checked" /><label for="duration">Duration</label>
		<input type="radio" id="departure" name="sort" /><label for="departure">Departure</label>
		<input type="radio" id="arrival" name="sort" /><label for="arrival">Arrival</label>
	</div>
	<div class="filterheader">Filters</h2>
	<input type="checkbox" id="Policy" value="1" onChange="filterAir();"> <label for="Policy">In Policy</label>
	<input type="checkbox" id="MultiCarrier" name="MultiCarrier" value="0" onChange="filterAir();" checked="checked"> <label for="MultiCarrier">Single Carrier</label>
	<input type="checkbox" id="NonStops" name="NonStops" value="1" onChange="filterAir();"> <label for="NonStops">Non Stops</label>
	<input type="checkbox" id="Airlines"> <label for="Airlines">Airlines</label>
</div>
<br clear="both">
<cfoutput>
	<cfloop array="#session.searches[rc.Search_ID].stSortFare#" index="sTrip">
		<cfset stTrip = session.searches[rc.Search_ID].stTrips[sTrip]>
		<div id="#sTrip#" class="badge">
			<table width="100%">
			<tr>
				<td width="50px">
					<img class="carrierimg" src="https://www.shortstravelonline.com/book/assets/img/airlines/#(ListLen(stTrip.Carriers) EQ 1 ? stTrip.Carriers : 'Mult')#.png">
				</td>
				<td class="fares" align="right">
					<cfloop array="#aMyCabins#" index="sCabin">
						<cfloop array="#aRef#" index="sRef">
							<cfif StructKeyExists(stTrip, sCabin)
							AND StructKeyExists(stTrip[sCabin], sRef)>
								#(sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First'))#
								#(sRef EQ 0 ? 'Nonrefundable' : 'Refundable')#
								<input type="submit" name="trigger" class="button" value="$#NumberFormat(stTrip[sCabin][sRef].Total)#">
							</cfif>
						</cfloop>
					</cfloop>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<table width="100%">
					<cfloop collection="#stTrip.Groups#" item="nGroup">
						<cfset stGroup = stTrip.Groups[nGroup]>
						<tr>
							<td>
								<strong>#stGroup.Origin#</strong>
							</td>
							<td>
								<strong>#TimeFormat(stGroup.DepartureTime, 'h:mm t')#</strong>
							</td>
							<td>
								-->
							</td>
							<td>
								<strong>#stGroup.Destination#</strong>
							</td>
							<td>
								<strong>#TimeFormat(stGroup.ArrivalTime, 'h:mm t')#</strong>
							</td>
						</tr>
						<tr>
							<td></td>
							<td colspan="2">
								#Replace(stGroup.Flights, ',', '<br>', 'ALL')#
							</td>
							<td colspan="2">
								<span class="fade">#stGroup.TravelTime#</span>
							</td>
						</tr>
					</cfloop>
					</table>
					<cfloop array="#aAllCabins#" index="sCabin">
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
					</cfloop>
					<a href="##" onClick="toggleDiv('#sTrip#details');return false;">Details</a>
				</td>
			</tr>
			<!---
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
						<cfif StructKeyExists(stTrip.Segments, sSegment+1) AND stTrip.Segments[sSegment].Group EQ stTrip.Segments[sSegment+1].Group>
							<tr>
								<td colspan="10" class="layover">
									Layover in
									(#stTrip.Segments[sSegment].Destination#)
									#application.stAirports[stTrip.Segments[sSegment].Destination]#
									for 
									<cfset nLayover = DateDiff('n', stTrip.Segments[sSegment].ArrivalTime, stTrip.Segments[sSegment+1].DepartureTime)>
									#int(nLayover/60)#h #nLayover%60#m
									</td>
							</tr>
						</cfif>
						<cfif StructKeyExists(stTrip.Segments, sSegment+1) AND stTrip.Segments[sSegment].Group NEQ stTrip.Segments[sSegment+1].Group>
							<tr>
								<td colspan="10" class="destination">&nbsp;</td>
							</tr>
						</cfif>
					</cfloop>
					</table>
				</div>--->
			</table>
		</div>
	</cfloop>
	<script type="application/javascript">
	var flightresults = [<cfset nCount = 0><cfloop array="#session.searches[rc.Search_ID].stSortFare#" index="sTrip"><cfset nCount++>[#session.searches[rc.Search_ID].stTrips[sTrip].sJavascript#]<cfif ArrayLen(session.searches[rc.Search_ID].stSortFare) NEQ nCount>,</cfif></cfloop>];
	$(document).ready(function() {
		$( "##sortbar" ).buttonset();
		$( "##Policy" ).button();
		$( "##MultiCarrier" ).button();
		$( "##NonStops" ).button();
		$( "##Airlines" ).dialog({
			autoOpen: false,
			minHeight:200,
			maxHeight:400
		});
		filterAir();
	});
	</script>
</cfoutput>