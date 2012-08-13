<!---<div class="filter">
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
	Carriers<br>
	<cfoutput query="rc.carriers">
		<input type="checkbox" id="Carrier#Carrier#" value="#Carrier#" onChange="filterAir();return false;" checked="checked"> <label for="Carrier#Carrier#">#CarrierName#</label><br>
	</cfoutput>
	<br>
	Preferred<br>
	<input type="checkbox" id="Preferred" value="1" onChange="filterAir();return false;"> <label for="Preferred">Preferred Airlines</label><br>
	<br>
	Display Options<br>
	<input type="checkbox" id="Details" value="1" onChange="showDetails();return false;"> <label for="Details">Expand All Details</label><br>
</div>
<cfoutput>
	<cfloop query="rc.sortingfare">
		<div id="#token#" class="list">
			<table width="100%">
			<tr>
				<td width="50px">
					<cfif rc.results[token].Preferred EQ 1>
						Pref Carrier<br>
					</cfif>
					<img class="carrierimg" src="https://www.shortstravelonline.com/book/assets/img/airlines/#(rc.results[token].MultiCarrier EQ 0 ? rc.results[token].Group[0].Carriers : 'Mult')#.png">
				</td>
				<td width="300px">
					<table width="100%">
					<cfset variables.GroupArray = StructKeyArray(rc.results[token].Group)>
					<cfset temp = ArraySort(variables.GroupArray, 'numeric', 'asc')>
					<cfloop array="#variables.GroupArray#" index="local.group">
						<tr>
							<td>
								#Replace(rc.results[token].Group[group].Carriers, ',', ', ', 'ALL')#
							</td>
							<td>
								<strong>#rc.results[token].Group[group].Origin#</strong>
							</td>
							<td>
								<strong>#TimeFormat(rc.results[token].Group[group].DepartureTime, 'h:mm t')#</strong>
							</td>
							<td>
								-->
							</td>
							<td>
								<strong>#rc.results[token].Group[group].Destination#</strong>
							</td>
							<td>
								<strong>#TimeFormat(rc.results[token].Group[group].ArrivalTime, 'h:mm t')#</strong>
							</td>
							<td>
								<span class="fade">#int(rc.results[token].Group[group].TravelTime/60)#h 
								#rc.results[token].Group[group].TravelTime%60#m</span>
							</td>
						</tr>
					</cfloop>
					</table>
					<a href="##" onClick="toggleDiv('#token#details');return false;">Details</a>
				</td>
				<td class="fares">
					<h2 class="classofservice">
						Economy<br>
					</h2>
					<cfif StructKeyExists(rc.results[token].Fares, 0)
					AND StructKeyExists(rc.results[token].Fares[0], 'Economy')>
						<h1 class="policy#rc.results[token].Fares[0].Economy.Policy#">
							#(rc.results[token].Fares[0].Economy.Currency EQ 'USD' ? '$'&NumberFormat(rc.results[token].Fares[0].Economy.TotalPrice) : NumberFormat(rc.results[token].Fares[0].Economy.TotalPrice)&' '&rc.results[token].Fares[0].Economy.Currency)#
						</h1>
						Nonrefundable
						<input type="submit" name="trigger" class="button" value="Reserve">
					</cfif>
					<cfif StructKeyExists(rc.results[token].Fares, 1)
					AND StructKeyExists(rc.results[token].Fares[1], 'Economy')>
						<h1 class="policy#rc.results[token].Fares[1].Economy.Policy#">
							#(rc.results[token].Fares[1].Economy.Currency EQ 'USD' ? '$'&NumberFormat(rc.results[token].Fares[1].Economy.TotalPrice) : NumberFormat(rc.results[token].Fares[0].Economy.TotalPrice)&' '&rc.results[token].Fares[1].Economy.Currency)#
						</h1>
						Refundable
						<input type="submit" name="trigger" class="button" value="Reserve">
					</cfif>
				</td>
				<td class="fares">
					<h2 class="classofservice">
						Business<br>
					</h2>
					<cfif StructKeyExists(rc.results[token].Fares, 0)
					AND StructKeyExists(rc.results[token].Fares[0], 'Business')>
						<h1 class="policy#rc.results[token].Fares[0].Business.Policy#">
							#(rc.results[token].Fares[0].Business.Currency EQ 'USD' ? '$'&NumberFormat(rc.results[token].Fares[0].Business.TotalPrice) : NumberFormat(rc.results[token].Fares[0].Business.TotalPrice)&' '&rc.results[token].Fares[0].Business.Currency)#
						</h1>
						Nonrefundable
						<input type="submit" name="trigger" class="button" value="Reserve">
					</cfif>
					<cfif StructKeyExists(rc.results[token].Fares, 1)
					AND StructKeyExists(rc.results[token].Fares[1], 'Business')>
						<h1 class="policy#rc.results[token].Fares[1].Business.Policy#">
							#(rc.results[token].Fares[1].Business.Currency EQ 'USD' ? '$'&NumberFormat(rc.results[token].Fares[1].Business.TotalPrice) : NumberFormat(rc.results[token].Fares[1].Business.TotalPrice)&' '&rc.results[token].Fares[1].Business.Currency)#
						</h1>
						Refundable
						<input type="submit" name="trigger" class="button" value="Reserve">
					</cfif>
				</td>
				<td class="fares">
					<h2 class="classofservice">
						First<br>
					</h2>
					<cfif StructKeyExists(rc.results[token].Fares, 0)
					AND StructKeyExists(rc.results[token].Fares[0], 'First')>
						<h1 class="policy#rc.results[token].Fares[0].First.Policy#">
							#(rc.results[token].Fares[0].First.Currency EQ 'USD' ? '$'&NumberFormat(rc.results[token].Fares[0].First.TotalPrice) : NumberFormat(rc.results[token].Fares[0].First.TotalPrice)&' '&rc.results[token].Fares[0].First.Currency)#
						</h1>
						Nonrefundable
						<input type="submit" name="trigger" class="button" value="Reserve">
					</cfif>
					<cfif StructKeyExists(rc.results[token].Fares, 1)
					AND StructKeyExists(rc.results[token].Fares[1], 'First')>
						<h1 class="policy#rc.results[token].Fares[1].First.Policy#">
							#(rc.results[token].Fares[1].First.Currency EQ 'USD' ? '$'&NumberFormat(rc.results[token].Fares[1].First.TotalPrice) : NumberFormat(rc.results[token].Fares[1].First.TotalPrice)&' '&rc.results[token].Fares[1].First.Currency)#
						</h1>
						Refundable
						<input type="submit" name="trigger" class="button" value="Reserve">
					</cfif>
				</td>
			</tr>
			<tr>
				<td colspan="5">
				<div id="#token#details" style="display:none">
					<br><br>
					<table width="100%" class="details">
					<cfset variables.SegmentArray = StructKeyArray(rc.results[token].Segments)>
					<cfset temp = ArraySort(variables.SegmentArray, 'numeric', 'asc')>
					<cfset tempGroup = -1>
					<cfloop array="#variables.SegmentArray#" index="local.group">
						<cfif tempGroup NEQ -1 AND tempGroup EQ rc.results[token].Segments[group].Group>
							<tr>
								<td colspan="10" class="layover">
									Layover in
									(#rc.results[token].Segments[group-1].Destination#)
									#rc.results[token].Segments[group-1].DestinationAirport#
									for 
									<cfset layover = DateDiff('n', rc.results[token].Segments[group-1].ArrivalTime, rc.results[token].Segments[group].DepartureTime)>
									#int(layover/60)#h 
									#layover%60#m
									</td>
							</tr>
						</cfif>
						<cfif tempGroup NEQ -1 AND tempGroup NEQ rc.results[token].Segments[group].Group>
							<tr>
								<td colspan="10" class="destination">&nbsp;</td>
							</tr>
						</cfif>
						<cfif tempGroup NEQ rc.results[token].Segments[group].Group>
							<cfset tempGroup = rc.results[token].Segments[group].Group>
						</cfif>
						<tr bgcolor="##E8F8FF">
							<td>
								#rc.results[token].Segments[group].Carrier##rc.results[token].Segments[group].FlightNumber#<br>
								#rc.results[token].Segments[group].CarrierName#
							</td>
							<td>
								<strong>#rc.results[token].Segments[group].Origin#</strong><br>
								#rc.results[token].Segments[group].OriginAirport#
							</td>
							<td>
								<strong>#TimeFormat(rc.results[token].Segments[group].DepartureTime, 'h:mm t')#</strong>
							</td>
							<td>
								-->
							</td>
							<td>
								<strong>#rc.results[token].Segments[group].Destination#</strong><br>
								#rc.results[token].Segments[group].DestinationAirport#
							</td>
							<td>
								<strong>#TimeFormat(rc.results[token].Segments[group].ArrivalTime, 'h:mm t')#</strong>
							</td>
							<td>
								<span class="fade">#int(rc.results[token].Segments[group].FlightTime/60)#h 
								#rc.results[token].Segments[group].FlightTime%60#m</span>
							</td>
							<td>
								#rc.results[token].Segments[group].EquipmentName#
							</td>
							<td>
								#(rc.results[token].Segments[group].ChangeOfPlane EQ 1 ? 'Plane Change' : '')#
							</td>
							<td>
								#rc.results[token].Segments[group].CabinClass#
							</td>
						</tr>
					</cfloop>
					</table>
				</div>
				</td>
			</tr>
			</table>
		</div>
	</cfloop>
</cfoutput>
<script type="application/javascript">
var flightresults = [<cfoutput query="rc.sortingfare">[#rc.results[token].js#]<cfif CurrentRow NEQ RecordCount>,</cfif></cfoutput>];
$(document).ready(function() {
	filterAir();
});
</script>--->