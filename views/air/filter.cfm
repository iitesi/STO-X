<ul id="nav">
	<div>
		<div class="radiosort">
			<div class="filterheader">Sort By</h2>
			<cfif rc.action NEQ 'air.availability'>

				<!--- Price --->
				<input type="radio" id="fare" name="sort" /><label for="fare">Price</label>

				<!--- Price + Bag Fees --->
				<input type="radio" id="bag" name="sort" /><label for="bag">Price + Bag Fees</label>
			</cfif>

			<!--- Duration --->
			<input type="radio" id="duration" name="sort" checked="checked" /><label for="duration">Duration</label>

			<!--- Departure --->
			<input type="radio" id="depart" name="sort" /><label for="depart">Departure</label>

			<!--- Arrival --->
			<input type="radio" id="arrival" name="sort" /><label for="arrival">Arrival</label>
		</div>
	</div>

	<div class="filterheader">Filter By</h2>

		<cfif structKeyExists(session.searches[rc.nSearchID].FareDetails, "stCarriers")>
			<!--- Airlines --->
			<li>
				<a href="#" class="main">Airlines</a>
				<ul>
					<cfoutput>
						<cfloop array="#session.searches[rc.nSearchID].FareDetails.stCarriers#" index="Carrier" >
							<li><span><input id="Carrier#Carrier#" type="checkbox" value="#Carrier#" checked> <label for="Carrier#Carrier#">#application.stAirVendors[Carrier].Name#</label></span></li>
						</cfloop>
					</cfoutput>
				</ul>
			</li>
		</cfif>

	<cfif rc.action NEQ 'air.availability'>
		<cfloop collection="#session.searches[rc.nSearchID].stTrips#" item="sTrip">
			<cfloop array="#aCabins#" index="sCabin">
				<cfloop array="#aRef#" index="bRef">
					<cfif StructKeyExists(session.searches[rc.Search_ID].stTrips[sTrip], sCabin)
					AND StructKeyExists(session.searches[rc.Search_ID].stTrips[sTrip][sCabin], bRef)>
						<cfset session.searches[rc.Search_ID].FareDetails[sCabin] = 1>
						<cfset session.searches[rc.Search_ID].FareDetails[bRef] = 1>
					</cfif>
				</cfloop>
			</cfloop>
		</cfloop>
		<!--- Class --->
		<li>
			<a href="#" class="main">Class</a>
			<ul>
				<li>
					<cfif structKeyExists(session.searches[rc.Search_ID].FareDetails.stResults, "Y")
					OR StructKeyExists(session.searches[rc.nSearchID].FareDetails.stPricing, 'YX')>
						<input type="checkbox" id="ClassY" name="ClassY" value="Y" <cfif NOT structKeyExists(rc, 'sCabins') OR rc.sCabins EQ 'Y'>checked</cfif>><label for="ClassY">Economy</label>
					</cfif>
					<!--- <cfif NOT StructKeyExists(session.searches[rc.nSearchID].FareDetails.stPricing, 'YX')>
						<cfoutput>
							<a href="#buildURL('air.lowfare?Search_ID=#rc.nSearchID#&sCabins=Y')#">Find Economy Class Fares</a>
						</cfoutput>
					</cfif> --->
				</li>
				<li>
					<cfif structKeyExists(session.searches[rc.Search_ID].FareDetails.stResults, "C")>
						<input type="checkbox" id="ClassC" name="ClassC" value="C" <cfif structKeyExists(rc, 'sCabins') AND rc.sCabins EQ 'C'>checked</cfif>><label for="ClassC">Business</label>
					<cfelseif StructKeyExists(session.searches[rc.nSearchID].FareDetails.stPricing, 'CX')>
						<input type="checkbox" id="ClassC" name="ClassC" value="C" disabled><label for="ClassC">Business (no results)</label>
					</cfif>
					<cfif NOT StructKeyExists(session.searches[rc.nSearchID].FareDetails.stPricing, 'CX')>
						<cfoutput>
							<a href="#buildURL('air.lowfare?Search_ID=#rc.nSearchID#&sCabins=C')#">Find Business Class Fares</a>
						</cfoutput>
					</cfif>
				</li>
				<li>
					<cfif structKeyExists(session.searches[rc.Search_ID].FareDetails.stResults, "F")>
						<input type="checkbox" id="ClassF" name="ClassF" value="F" <cfif structKeyExists(rc, 'sCabins') AND rc.sCabins EQ 'F'>checked</cfif>><label for="ClassF">First</label>
					<cfelseif StructKeyExists(session.searches[rc.nSearchID].FareDetails.stPricing, 'FX')>
						<input type="checkbox" id="ClassF" name="ClassF" value="F" disabled><label for="ClassF">First (no results)</label>
					</cfif>
					<cfif NOT StructKeyExists(session.searches[rc.nSearchID].FareDetails.stPricing, 'FX')>
						<cfoutput>
							<a href="#buildURL('air.lowfare?Search_ID=#rc.nSearchID#&sCabins=F')#">Find First Class Fares</a>
						</cfoutput>
					</cfif>
				</li>
			</ul>
		</li>

		<!--- Fares --->
		<li>
			<a href="#" class="main">Fares</a>
			<ul>
				<li>
					<cfif structKeyExists(session.searches[rc.Search_ID].FareDetails.stResults, "0")
					OR StructKeyExists(session.searches[rc.nSearchID].FareDetails.stPricing, 'X0')>
						<input type="checkbox" id="Fare0" name="Fare0" value="0" <cfif NOT structKeyExists(rc, 'bRef') OR rc.bRef EQ 0>checked</cfif>><label for="Fare0">Non Refundable</label>
					</cfif>
					<!--- <cfif NOT StructKeyExists(session.searches[rc.nSearchID].FareDetails.stPricing, 'X0')>
						<cfoutput>
							<a href="#buildURL('air.lowfare?Search_ID=#rc.nSearchID#&bRefundable=0')#">Find Non Refundable Fares</a>
						</cfoutput>
					</cfif> --->
				</li>
				<li>
					<cfif structKeyExists(session.searches[rc.Search_ID].FareDetails.stResults, "1")
					OR StructKeyExists(session.searches[rc.nSearchID].FareDetails.stPricing, 'X1')>
						<input type="checkbox" id="Fare1" name="Fare1" value="1" <cfif structKeyExists(rc, 'bRef') AND rc.bRef EQ 0>checked</cfif>><label for="Fare1">Refundable</label>
					</cfif>
					<cfif NOT StructKeyExists(session.searches[rc.nSearchID].FareDetails.stPricing, 'X1')>
						<cfoutput>
							<a href="#buildURL('air.lowfare?Search_ID=#rc.nSearchID#&bRefundable=1')#">Find Refundable Fares</a>
						</cfoutput>
					</cfif>
				</li>
			</ul>
		</li>


	</cfif>
	
	<!--- Non stops --->
	<input type="checkbox" id="NonStops" name="NonStops"> <label for="NonStops">Non Stops</label>
	
	<!--- Policy --->
	<input type="checkbox" id="Policy" name="Policy"> <label for="Policy">In Policy</label>

	<!--- Single Carrier Flights --->
	<input type="checkbox" id="SingleCarrier" name="SingleCarrier" checked> <label for="SingleCarrier">Single Carrier</label>
</ul>
<script type="application/javascript">
	$(document).ready(function() {
		$( ".radiobuttons" ).buttonset();
		$( ".radiosort" )
			.buttonset()
			.change(function(event) {
				sortAir($( "input:radio[name=sort]:checked" ).attr('id'));
			});
		$( "#NonStops" )
			.button()
			.click(function() {
				filterAir();
			});
		$( ":checkbox" ).click(function() {
			filterAir();
		});
		$( ":radio" ).click(function() {
			filterAir();
		});
		$( "#Policy" )
			.button()
			.change(function() {
				filterAir();
			});
		$( "#SingleCarrier" )
			.button()
			.change(function() {
				filterAir();
			});
		
	});
	</script>
<style>
#nav{
	margin-bottom:10px;
	float:left;
	width:100%;
	position:relative;
	z-index:5;
	font-family: Verdana;
	font-size: 11px;
}
#nav .main {
	color:#FFFFFF;
	background:#0090D2;
}
#nav ul{
	list-style:none;
	position:absolute;
	left:-9999px; /* Hide off-screen when not needed (this is more accessible than display:none;) */
	width: 200px;
}
#nav ul li{
	padding:5px; /* Introducing a padding between the li and the a give the illusion spaced items */
	float:none;

	background-color: #FFF;
	font-size: 11px;
	padding: 5px;
	float:left;
	position: relative;
	width: 245px;
	box-shadow: 0 1px 3px rgba(0, 53, 229, 0.4);
	color: #211922;
}
#nav li{
	float:left;
	margin-right:10px;
	position:relative;
}
#nav a{
	display:block;
	padding:5px 15px 5px 15px;
	text-decoration:none;
}
#nav li:hover ul{ /* Display the dropdown on hover */
	left:0; /* Bring back on-screen when needed */
}
</style>