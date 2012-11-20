<div id="filterbar">
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
	<div>
		<div class="filterheader">Filter By</h2>
		
		<!--- Airlines --->
		<button id="btnAirlines">Airlines</button>
		<cfif structKeyExists(session.searches[rc.nSearchID], "stCarriers")>
			<div id="AirlinesDialog" class="popup">
				<div class="popup-airlines">
					<div class="region">
						<cfloop array="#session.searches[rc.nSearchID].stCarriers#" index="Carrier" >
							<div class="checkbox">
								<input id="Carrier#Carrier#" type="checkbox" value="#Carrier#" checked>
								<label for="Carrier#Carrier#">#application.stAirVendors[Carrier].Name#</label>
							</div>
						</cfloop>
					</div>
				</div>
			</div>
		</cfif>
		<cfif rc.action NEQ 'air.availability'>
			
			<!--- Class --->
			<button id="btnClass">Class</button>
			<div id="ClassDialog" class="popup">
				<div class="radiobuttons">
					<input type="radio" id="ClassY" name="Class" value="Y"><label for="ClassY">Economy</label>
					<input type="radio" id="ClassC" name="Class" value="C"><label for="ClassC">Business</label>
					<input type="radio" id="ClassF" name="Class" value="F"><label for="ClassF">First</label>
				</div>
			</div>
			
			<!--- Fares --->
			<button id="btnFares">Fares</button>
			<div id="FaresDialog" class="popup">
				<div class="radiobuttons">
					<input type="radio" id="Fares0" name="Fares" value="0"><label for="Fares0">Non Refundable</label>
					<input type="radio" id="Fares1" name="Fares" value="1"><label for="Fares1">Refundable</label>
				</div>
			</div>
		</cfif>
		
		<!--- Non stops --->
		<input type="checkbox" id="NonStops" name="NonStops"> <label for="NonStops">Non Stops</label>
		
		<!--- Policy --->
		<input type="checkbox" id="Policy" name="Policy"> <label for="Policy">In Policy</label>

		<!--- Single Carrier Flights --->
		<input type="checkbox" id="SingleCarrier" name="SingleCarrier" checked> <label for="SingleCarrier">Single Carrier</label>
	</div>
</div>
<script type="application/javascript">
	$(document).ready(function() {
		$( ".radiobuttons" ).buttonset();
		$( ".radiosort" )
			.buttonset()
			.change(function(event) {
				sortAir($( "input:radio[name=sort]:checked" ).attr('id'));
			});
		$( "#btnAirlines" )
			.button({
				icons: {secondary: "ui-icon-triangle-1-s"}
			})
			.click(function() {
				$( "#AirlinesDialog" ).dialog( "open" );
			return false;
		});
		$( "#AirlinesDialog" ).dialog({
				autoOpen: false,
				show: "fade",
				hide: "fade",
				width: 525,
				title:	'Select your preferred airlines',
				position: [100,120],
				modal: true,
				closeOnEscape: true,
				buttons: {
					"Search": function(){
						filterAir();
						$( this ).dialog( "close" );
						return false;
					},
					"Cancel": function(){
						$( this ).dialog( "close" );
						return false;
					}
				}
			});
		$( "#btnClass" )
			.button({
				icons: {secondary: "ui-icon-triangle-1-s"}
			})
			.click(function() {
				$( "#ClassDialog" ).dialog( "open" );
			return false;
		});
		$( "#ClassDialog" ).dialog({
				autoOpen: false,
				show: "fade",
				hide: "fade",
				width: 290,
				title:	'Select your preferred class of service',
				position: [100,120],
				modal: true,
				closeOnEscape: true,
				buttons: {
					"Search": function(){
						filterAir();
						$( this ).dialog( "close" );
						return false;
					},
					"Cancel": function(){
						$( this ).dialog( "close" );
						return false;
					}
				}
			});
		$( "#btnFares" )
			.button({
				icons: {secondary: "ui-icon-triangle-1-s"}
			})
			.click(function() {
				$( "#FaresDialog" ).dialog( "open" );
			return false;
		});
		$( "#FaresDialog" ).dialog({
				autoOpen: false,
				show: "fade",
				hide: "fade",
				width: 290,
				title:	'Select your preferred fare type',
				position: [100,120],
				modal: true,
				closeOnEscape: true,
				buttons: {
					"Search": function(){
						filterAir();
						$( this ).dialog( "close" );
						return false;
					},
					"Cancel": function(){
						$( this ).dialog( "close" );
						return false;
					}
				}
			});
		$( "#NonStops" )
			.button()
			.click(function() {
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
		$( "#Time" ).button();
		filterAir();
		
	});
	</script>