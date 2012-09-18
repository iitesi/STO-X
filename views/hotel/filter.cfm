<div id="filterbar">
	<div>
		<div class="filterheader">Filter By</h2>
		<button id="btnHotelChains">Chains</button>
	</div>
</div>

<cfoutput>
	<div id="HotelChains" class="popup">
		<div class="popup-airlines">
			<div class="region">
				<cfloop array="#session.searches[rc.nSearchID].stHotelChains#" index="Chain" >
					<div class="checkbox">
						<input id="Chain#Chain#" type="checkbox" value="#Chain#" checked>
						<label for="Chain#Chain#">#application.stHotelVendors[Chain]#</label>
					</div>
				</cfloop>
			</div>
		</div>
	</div>
</cfoutput>

<script type="application/javascript">
	$(document).ready(function() {
		$( ".radiobuttons" ).buttonset();
		$( ".radiosort" )
			.buttonset()
			.change(function(event) {
				sortAir($( "input:radio[name=sort]:checked" ).attr('id'));
			});
		$( "#btnHotelChains" )
			.button({
				icons: {secondary: "ui-icon-triangle-1-s"}
			})
			.click(function() {
				$( "#HotelChains" ).dialog( "open" );
			return false;
		});
		$( "#HotelChains" ).dialog({
				autoOpen: false,
				show: "fade",
				hide: "fade",
				width: 525,
				title: 'Select your preferred hotel chains',
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
		
	});
	</script>