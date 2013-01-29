<br /><br />
<div id="filterbar">
	<div>
		<div class="filterheader">Filter By</div>
		<button id="btnHotelChain">Hotel Chain</button>
		<button id="btnHotelAmenities">Amenities</button>
		<input type="checkbox" id="Policy" name="Policy"> <label for="Policy">In Policy</label>
	</div>
</div>
<cfoutput>
	<cfset arraysort(session.searches[rc.nSearchID].stHotelChains,'text') />
	<div id="HotelDialog" class="popup">
		<div class="popup-hotel">
			<div class="region">
				<cfloop array="#session.searches[rc.nSearchID].stHotelChains#" index="Chain">
					<div class="checkbox">
						<input id="HotelChain#Chain#" type="checkbox" name="HotelChain#Chain#" value="#Chain#" checked="checked" onclick="filterhotel();">
						<label for="HotelChain#Chain#">#StructKeyExists(application.stHotelVendors,Chain) ? application.stHotelVendors[Chain] : 'No Chain found'#</label>
					</div>
				</cfloop>
			</div>
		</div>
	</div>
	<div id="AmenityDialog" class="popup">
		<div class="popup-hotel">
			<div class="region">
				<cfloop array="#session.searches[rc.nSearchID].stAmenities#" index="Amenity">
					<div class="checkbox">
						<input id="#Amenity#" type="checkbox" name="HotelAmenity#Amenity#" value="#Amenity#" onclick="filterhotel();">
						<label for="#Amenity#">#application.stAmenities[Amenity]#</label>
					</div>
				</cfloop>
			</div>
		</div>
	</div>
</cfoutput>

<script type="application/javascript">
function filterhotel() {
	// pages & sortng
	var start_from = $( "#current_page" ).val() * 20;
	var end_on = start_from + 20;
	var matchcriteriacount = 0;

	<cfoutput>
		var hotelresults = #serializeJSON(session.searches[rc.Search_ID].HotelInformationQuery,true)#;
		var orderedpropertyids = "#ArrayToList(session.searches[rc.Search_ID]['stSortHotels'])#";
	</cfoutput>	
	orderedpropertyids = orderedpropertyids.split(',');
	
	for (var t = 0; t < orderedpropertyids.length; t++) {
		// start the loop with 5 because property_id, signature_image, lat, long, chain_code, policy are 0-5
		for (var i = 5; i < hotelresults.COLUMNS.length; i++) {
			var ColumnName = hotelresults.COLUMNS[i];
			var propertymatch = 1;
			if ($("#" + ColumnName + ":checked").val() != undefined) {
				if (hotelresults.DATA[ColumnName][t] == 0) {// if the value is checked and it's not active for this property mark propertymatch as 0
					propertymatch = 0;
					break;
				}
			}
		}

		// check chain code match
		var chaincode = hotelresults.DATA['CHAIN_CODE'][t];
		if (propertymatch == 1) {
			if ($("#HotelChain" + chaincode + ":checked").val() == undefined) {
				propertymatch = 0;
			}
		}

		// check Policy
		var Policy = $( "input:checkbox[name=Policy]:checked" ).val();
		var PolicyValue = hotelresults.DATA['POLICY'][t];
		if (propertymatch == 1 && Policy == 'on' && PolicyValue != '1') {		
				propertymatch = 0;
		}

		var propertyid = hotelresults.DATA['PROPERTY_ID'][t];
		if (propertymatch == 1) {
			$("#" + propertyid ).show('fade');
				//pins[propertyid].setOptions({visible: true});
				matchcriteriacount++;
				if (matchcriteriacount >= start_from && matchcriteriacount < end_on) {
					$("#"+propertyid ).show('fade');
					$("#number"+propertyid).html(matchcriteriacount);
					//pins[propertyid].setOptions({visible:true, text:'' + matchcriteriacount + '', zIndex:1000});
					//loadImage(property[10], propertyid);
					//if (property[11] == 0) {
						//getHotelRates(propertyid, property[15], property[16], hcm);
					//}
				}
				else {
					$("#" + propertyid ).hide('fade');
					//pins[propertyid].setOptions({visible: false});
				}
		}
		else {
			$("#" + propertyid ).hide('fade');
			//pins[propertyid].setOptions({visible: false});		
		}
	}
	

	writePages(matchcriteriacount);
	if (matchcriteriacount != totalproperties) {
		$( "#hotelcount" ).html(matchcriteriacount + ' of ' + totalproperties + ' total properties');
	}
	else {
		$( "#hotelcount" ).html(totalproperties +' total properties');
	}	
	
	return false;
}

function sortHotel(sort) {
	$( "#current_page" ).val(0);
	$( "#sorttype" ).val(sort);
	var order = $( "#hotellist" + sort + "sort" ).val();
	order = order.split(',');
	for (var t = 0; t < order.length; t++) {
		$( "#hotelresults" ).append( $( "#hotellist" + order[t] ) );
	}
	filterhotel();
}	

$(document).ready(function() {

		$( "#Policy" )
			.button()
			.change(function() {
				filterhotel();
			});

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
			closeOnEscape: true
		});
	$( "#btnHotelAmenities" )
		.button({
			icons: {secondary: "ui-icon-triangle-1-s"}
		})
		.click(function() {
			$( "#AmenityDialog" ).dialog( "open" );
		return false;
	});
	$( "#AmenityDialog" ).dialog({
			autoOpen: false,
			show: "fade",
			hide: "fade",
			width: 525,
			title:	'Select your preferred amenities',
			position: [100,120],
			modal: true,
			closeOnEscape: true
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