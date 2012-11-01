<div id="filterbar">
	<div>
		<div class="filterheader">Filter By</div>
		<button id="btnHotelChain">Hotel Chain</button>
		<button id="btnHotelAmenities">Amenities</button>
		<button class="radiobuttons">
			<input type="radio" id="Policy" name="Policy" value="0" onclick="filterhotel();"><label for="Policy">In Policy</label>
		</button>
	</div>
</div>
<cfoutput>
	<cfset arraysort(session.searches[rc.nSearchID].stHotelChains,'text') />
	<div id="HotelDialog" class="popup">
		<div class="popup-hotel">
			<div class="region">
				<cfloop array="#session.searches[rc.nSearchID].stHotelChains#" index="Chain">
					<div class="checkbox">
						<input id="Chain#Chain#" type="checkbox" name="HotelChain#Chain#" value="#Chain#" checked="checked" onclick="filterChain();">
						<label for="Chain#Chain#">#StructKeyExists(application.stHotelVendors,Chain) ? application.stHotelVendors[Chain] : 'No Chain found'#</label>
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
						<input id="#Amenity#" type="checkbox" name="HotelAmenity#Amenity#" value="#Amenity#" onclick="filterAmenity();">
						<label for="#Amenity#">#application.stAmenities[Amenity]#</label><!--- #StructKeyExists(application.stAmenities,Amenity) ? application.stAmenities[Amenity] : 'No Amenity found'# --->
					</div>
				</cfloop>
			</div>
		</div>
	</div>
</cfoutput>

<script type="application/javascript">
<!---SELECT Property_ID, Signature_Image, Lat, Long, 0 AS HECL, 0 AS HAFA, 0 AS PARK, 0 AS BRFT, 0 AS FRTR, 0 AS HSPI, 0 AS SPAA, 0 AS POOL, 0 AS MEFA, 0 AS COBU, 0 AS FPRK, 0 AS RTNT, 0 AS COBR--->
function filterhotel() {
	// pages & sortng
	//var start_from = $( "#current_page" ).val() * 20;
	//var end_on = start_from + 20;
	//var matchcriteriacount = 0;

	//filter

	<cfoutput>
		<cfloop list="#StructKeyList(application.stAmenities)#" index="amenity">
			var #amenity# = $("###amenity#:checked").val();
		</cfloop>
		var hotelresults = #serializeJSON(session.HotelInformationQuery,true)#;
		console.log(hotelresults);
		var orderedpropertyids = "#ArrayToList(session.searches[rc.Search_ID]['stSortHotels'])#";
		orderedpropertyids = orderedpropertyids.split(',');	
	</cfoutput>
	<!---
		var amenities = '#StructKeyList(application.stAmenities)#';
		amenities = amenities.split(',');
		console.log(amenities);
		for (var i = 0; i < amenities.length; i++) {
			var amenity = amenities[i];
			amenity = $("#" + amenity + ":checked").val();
			console.log(amenity);
		}
	--->

	//totals
	var propertyid = '';
	var property = '';
	var propertyname = '';
	for (var t = 1; t < orderedpropertyids.length; t++) {
		propertyid = orderedpropertyids[t];

		propertyname = property[2];

		if ((internet == true && property[3] == 0) ||
		(business == true && property[4] == 0) ||
		(meeting == true && property[5] == 0) ||
		(transportation == true && property[6] == 0) ||
		(breakfast == true && property[7] == 0) ||
		(restaurant == true && property[8] == 0) ||
		(roomservice == true && property[9] == 0) ||
		(soldout == undefined && property[13] == 1) ||
		($( "#Vendors" + property[15] + ":checked" ).val() == undefined) ||
		(hotelname != '' && propertyname.indexOf(hotelname) < 0) ||
		(travpref == 1 && property[21] == 0) ||
		(acctpref == 1 && property[22] == 0)) {
			$( "#hotellist" + propertyid ).hide();
			pins[propertyid].setOptions({visible: false});
			//console.log('hide '+propertyid)
		}
		else {
			matchcriteriacount++;
			if (matchcriteriacount >= start_from && matchcriteriacount < end_on) {
				$( "#hotellist" + propertyid ).show();
				$( "#number" + propertyid ).html('<strong>' + matchcriteriacount + ' - </strong>');
				pins[propertyid].setOptions({visible:true, text:'' + matchcriteriacount + '', zIndex:1000});
				loadImage(property[10], propertyid);
				if (property[11] == 0) {
					getHotelRates(propertyid, property[15], property[16], hcm);
				}
			}
			else {
				$( "#hotellist" + propertyid ).hide();
				pins[propertyid].setOptions({visible: false});
			}
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
<!---
function filterHotel() {
	var Policy = $('input:radio[name=Policy]:checked').val()
	if (Policy == 0) {			
		$('[data-policy="0"]').toggle(); 
	}
};

function filterChain() {
	$('input[name^="HotelChain"][checked]').each(function() {
		var SingleChain = this.value;
		var SingleChainResponse = this.checked;
		if (SingleChainResponse == true) {
			$('[data-chain='+SingleChain+']').show(); 
		}
		else {
			$('[data-chain='+SingleChain+']').hide();     			
		}
	});
};


function filterAmenity() {
	$('input[name^="HotelAmenity"]').each(function() {
		var SingleAmenity = this.value;
		var SingleAmenityResponse = this.checked;
		console.log(SingleAmenity);
		console.log(SingleAmenityResponse);
		if (SingleAmenityResponse == true) {
			$('[data-amenities~='+SingleAmenity+']').show();
		}
		else {
			$('[data-amenities~='+SingleAmenity+']').hide();  
			console.log('hide');   			
		}
	});
};
--->