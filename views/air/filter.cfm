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
				<a href="#">Airlines</a>
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
		
		<!--- Class --->
		<li>
			<a href="#">Class</a>
			<ul>
				<li><input type="radio" id="ClassY" name="Class" value="Y"><label for="ClassY">Economy</label></li>
				<li><input type="radio" id="ClassC" name="Class" value="C"><label for="ClassC">Business</label></li>
				<li><input type="radio" id="ClassF" name="Class" value="F"><label for="ClassF">First</label></li>
			</ul>
		</li>

		<!--- Fares --->
		<li>
			<a href="#">Fares</a>
			<ul>
				<li><input type="radio" id="Fares0" name="Fares" value="0"><label for="Fares0">Non Refundable</label></li>
				<li><input type="radio" id="Fares1" name="Fares" value="1"><label for="Fares1">Refundable</label></li>
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
		filterAir();
		
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
#nav li{
	float:left;
	margin-right:10px;
	position:relative;
}
#nav a{
	display:block;
	padding:5px 15px 5px 15px;
	color:#FFFFFF;
	background:#0090D2;
	text-decoration:none;
}
#nav ul{
	background:#0090D2;
	background:rgba(255,255,255,0); /* But! Let's make the background fully transparent where we can, we don't actually want to see it if we can help it... */
	list-style:none;
	position:absolute;
	left:-9999px; /* Hide off-screen when not needed (this is more accessible than display:none;) */
	width: 200px;
}
#nav ul li{
	background:#0090D2;
	padding:5px; /* Introducing a padding between the li and the a give the illusion spaced items */
	float:none;
	color:#FFF;
}
#nav li:hover ul{ /* Display the dropdown on hover */
	left:0; /* Bring back on-screen when needed */
}
</style>