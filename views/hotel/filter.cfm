<div id="filterbar">
	<div>
		<div class="filterheader">Filter By</div>
		<button id="btnHotelChain">Hotel Chain</button>
		<button class="radiobuttons">
			<input type="radio" id="Policy" name="Policy" value="0" onclick="filterHotel();"><label for="Policy">In Policy</label>
		</button>
	</div>
</div>
<cfoutput>
	<cfset arraysort(session.searches[rc.nSearchID].stHotelChains,'text') />
	<div id="HotelDialog" class="popup">
		<div class="popup-hotel">
			<div class="region">
				<cfloop array="#session.searches[rc.nSearchID].stHotelChains#" index="Chain">
					<!--- #Chain# --->
					<div class="checkbox">
						<input id="Chain#Chain#" type="checkbox" name="HotelChain#Chain#" value="#Chain#" checked="checked" onclick="filterChain();">
						<label for="Chain#Chain#">#StructKeyExists(application.stHotelVendors,Chain) ? application.stHotelVendors[Chain] : 'No Chain found'#</label>
					</div>
				</cfloop>
			</div>
		</div>
	</div>
</cfoutput>


<script type="application/javascript">
function filterHotel() {
	var Policy = $('input:radio[name=Policy]:checked').val()
	if (Policy == 0) {			
		$('[data-policy="0"]').toggle(); 
	}
};


function filterChain() {
	$('input[name^="HotelChain"][checked]').each(
		function() {
  		var SingleChain = this.value;
  		var SingleChainResponse = this.checked;
  		if (SingleChainResponse == true) {
				$('[data-chain='+SingleChain+']').show(); 
  		}
  		else {
				$('[data-chain='+SingleChain+']').hide();     			
  		}
		}
	);
};

$(document).ready(function() {


	$( ".radiobuttons" ).buttonset();
	$( ".radiosort" )
		.buttonset()
		.change(function(event) {
			sortAir($( "input:radio[name=sort]:checked" ).attr('id'));
		});
	$( "#btnHotelChain" )
		.button({
			icons: {secondary: "ui-icon-triangle-1-s"}
		})
		.click(function() {
			$( "#HotelDialog" ).dialog( "open" );
		return false;
	});
	$( "#HotelDialog" ).dialog({
			autoOpen: false,
			show: "fade",
			hide: "fade",
			width: 525,
			title:	'Select your preferred hotel chains',
			position: [100,120],
			modal: true,
			closeOnEscape: true,
			buttons: {
				/*
				"Search": function(){
					//filterChain();
					$( this ).dialog( "close" );
					return false;
				},*/
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
	
});
</script>