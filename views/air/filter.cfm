<cfparam name="rc.filter" default="">
<ul id="filter">
	<table>
	<tr>
		<td>
			<div>
				<div id="radiosort">
					<div class="filterheader">Sort By</div>
					<cfif rc.action NEQ 'air.availability'>
<!---
PRICE
--->
						<input type="radio" id="fare" name="sort" <cfif rc.action NEQ 'air.lowfare'>checked="checked"</cfif> /><label for="fare">Price</label>
<!---
PRICE + BAGS
--->
						<input type="radio" id="bag" name="sort" /><label for="bag">Price + Bag Fees</label>
					</cfif>
<!---
DURATION
--->
					<input type="radio" id="duration" name="sort" <cfif rc.action NEQ 'air.availability'>checked="checked"</cfif> /><label for="duration">Duration</label>
<!---
DEPARTURE
--->
					<input type="radio" id="depart" name="sort" /><label for="depart">Departure</label>
<!---
ARRIVAL
--->
					<input type="radio" id="arrival" name="sort" /><label for="arrival">Arrival</label>
				</div>
			</div>
		</td>
		<td>
			<div class="filterheader">Filter By</h2>
		</td>
		<td>
<!---
AIRLINES
--->
			<li>
				<input type="checkbox" id="Airlines" name="Airlines"> <label for="Airlines">Airlines</label>
				<ul>
					<cfoutput>
						<cfif rc.action NEQ 'air.availability'>
							<cfset aCarriers = session.searches[rc.SearchID].stLowFareDetails.aCarriers>
						<cfelse>
							<cfset aCarriers = session.searches[rc.SearchID].stAvailDetails.stCarriers[rc.Group]>
						</cfif>
						<cfloop array="#aCarriers#" index="Carrier" >
							<li><span><input id="Carrier#Carrier#" type="checkbox" value="#Carrier#" checked> <label for="Carrier#Carrier#">#application.stAirVendors[Carrier].Name#</label></span></li>
						</cfloop>
					</cfoutput>
				</ul>
			</li>

			<cfif rc.action NEQ 'air.availability'>
<!---
CLASSES
--->
				<li>
					<input type="checkbox" id="Classes" name="Classes"> <label for="Classes">Class</label>
					<cfoutput>
						<ul>
							<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "Y")
							OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'YX')>
                                <li><input type="checkbox" id="ClassY" name="ClassY" value="Y" <cfif NOT structKeyExists(rc, 'sCabins') OR rc.sCabins EQ 'Y'>checked</cfif>><label for="ClassY">Economy (#session.searches[rc.SearchID].stLowFareDetails.stResults.Y# results)</label></li>
							</cfif>
							<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "C")>
                                <li><input type="checkbox" id="ClassC" name="ClassC" value="C" <cfif NOT structKeyExists(rc, 'sCabins') OR rc.sCabins EQ 'C'>checked</cfif>><label for="ClassC">Business (#session.searches[rc.SearchID].stLowFareDetails.stResults.C# results)</label></li>
							<cfelseif StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'CX')>
                                <li><input type="checkbox" id="ClassC" name="ClassC" value="C" disabled><label for="ClassC">Business (no results)</label></li>
							</cfif>
							<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'CX')>
								<cfoutput>
                                    <li><a href="?action=air.lowfare&SearchID=#rc.SearchID#&sCabins=C">Find Business Class Fares</a></li>
								</cfoutput>
							</cfif>
							<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "F")>
                                <li><input type="checkbox" id="ClassF" name="ClassF" value="F" <cfif NOT structKeyExists(rc, 'sCabins') OR rc.sCabins EQ 'F'>checked</cfif>><label for="ClassF">First (#session.searches[rc.SearchID].stLowFareDetails.stResults.F# results)</label></li>
							<cfelseif StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'FX')>
                                <li><input type="checkbox" id="ClassF" name="ClassF" value="F" disabled><label for="ClassF">First (no results)</label></li>
							</cfif>
							<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'FX')>
								<cfoutput>
                                    <li><a href="?action=air.lowfare&SearchID=#rc.SearchID#&sCabins=F">Find First Class Fares</a></li>
								</cfoutput>
							</cfif>
						</ul>
					</cfoutput>
				</li>
<!---
FARES
--->
				<li>
					<input type="checkbox" id="Fares" name="Fares"> <label for="Fares">Fares</label>
					<cfoutput>
						<ul>
							<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "0")
							OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'X0')>
                                <li><input type="checkbox" id="Fare0" name="Fare0" value="0" <cfif NOT structKeyExists(rc, 'bRef') OR rc.bRef EQ 0>checked</cfif>><label for="Fare0">Non Refundable (#session.searches[rc.SearchID].stLowFareDetails.stResults[0]# results)</label></li>
							</cfif>
							<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "1")
							OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'X1')>
                                <li><input type="checkbox" id="Fare1" name="Fare1" value="1" <cfif NOT structKeyExists(rc, 'bRef') OR rc.bRef EQ 0>checked</cfif>><label for="Fare1">Refundable (#session.searches[rc.SearchID].stLowFareDetails.stResults[1]# results)</label></li>
							</cfif>
							<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'X1')>
								<cfoutput>
                                    <li><a href="?action=air.lowfare&SearchID=#rc.SearchID#&bRefundable=1">Find Refundable Fares</a></li>
								</cfoutput>
							</cfif>
						</ul>
					</cfoutput>
				</li>

			</cfif>
<!---
NON STOPS
--->
			<input type="checkbox" id="NonStops" name="NonStops"> <label for="NonStops">Non Stops</label>
<!---
POLICY
--->
			<input type="checkbox" id="Policy" name="Policy"> <label for="Policy">In Policy</label>
<!---
SINGLE CARRIERS
--->
			<input type="checkbox" id="SingleCarrier" name="SingleCarrier" checked> <label for="SingleCarrier">Single Carrier</label>
		</td>
	</tr>
	</table>
</ul>
<script type="application/javascript">
$(document).ready(function() {
	$( "#radiosort" )
		.buttonset()
		.change(function(event) {
			sortAir($( "input:radio[name=sort]:checked" ).attr('id'));
		});
	$( ".radiobuttons" ).buttonset();
	$( "#NonStops" ).button()
		.click(function() {
			filterAir();
		});
	$( ":checkbox" ).click(function() {
		filterAir();
	});
	$( ":radio" ).click(function() {
		filterAir();
	});
	$( "#Policy" ).button()
		.change(function() {
			filterAir();
		});
	$( "#Classes" ).button();
	$( "#Fares" ).button();
	$( "#Airlines" ).button();
	$( "#SingleCarrier" ).button()
		.change(function() {
			filterAir();
		});
	
});
</script>