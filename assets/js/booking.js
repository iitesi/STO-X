function toggleDiv(div) {
	$( "#" + div ).toggle( 'fade' );
}
function filterAir() {
																			//console.log('start');
	var classofservice = $( "input:radio[name=Class]:checked" ).val();
	if (classofservice == undefined) {
		classofservice = 'Y'
	}
	var fares = $( "input:radio[name=Fares]:checked" ).val();
	if (fares == undefined) {
		fares = 0
	}
	var nonstops = $( "input:checkbox[name=NonStops]:checked" ).val();
	var policy = $( "input:checkbox[name=Policy]:checked" ).val();
	var singlecarrier = $( "input:checkbox[name=SingleCarrier]:checked" ).val();
	/*
	 * 	0	Token				-23445611128
	 * 	1	Policy				1/0
	 * 	2 	Multiple Carriers	1/0
	 * 	3 	Carriers			"DL","AA","UA"
	 * 	4	Refundable			1/0
	 * 	5	Preferred			1/0
	 * 	6	Cabin Class			Y, C, F
	 * 	7	Stops				0/1/2
	 */
	 																		//console.log('ran');
	for (loopcnt = 0; loopcnt <= (flightresults.length-1); loopcnt++) {
		var flight = flightresults[loopcnt];
																			//console.log(flight)
																			//console.log(nonstops)
		if ((classofservice != flight[6])
		|| (fares != flight[4])
		|| (nonstops == 'on' && flight[7] != 0)
		|| (policy == 'on' && flight[1] != 1)
		|| (singlecarrier == 'on' && flight[2] != 0)) {
			$( '#' + flight[0] ).hide( 'fade' );
																			//console.log('hide - '+flight[0]);
		}
		else {
			carriercount = 0;
			for (var i = 0; i < flight[3].length; i++) {
				if ($( "#Carrier" + flight[3][i] ).is(':checked') == true) {
					carriercount++;
				}
			}
			if (carriercount == 0) {
				$( '#' + flight[0] ).hide( 'fade' );
			}
			else {
				$( '#' + flight[0] ).show( 'fade' );
			}
		}
	}
	return false;
}

function sortAir (sort) {
	var sortlist = eval( 'sort' + sort );
	for (var t = 0; t < sortlist.length; t++) {
		$( "#aircontent" ).append( $( "#" + sortlist[t] ) );
	}
	return false;
}

function airPrice(search_id, trip_id, cabin, refundable) {
	$.ajax({type:"POST",
		url:"services/airprice.cfc?method=doAirPrice",
		data:"nSearchID="+search_id+"&nTrip="+trip_id+"&sCabin="+cabin+"&bRefundable="+refundable,
		async: true,
		dataType: 'json',
		timeOut: 5000,
		success:function(data) {	
			$( "#" + trip_id + cabin + refundable ).html(data);
			console.log(data);
		},
		error:function(test, tes, te) {
			console.log(test);
			console.log(tes);
			console.log(te);
		}
	});
	return false;
}

function hotelPrice(search_id, hotel, chain) {
	$.ajax({type:"POST",
		url:"services/hotelprice.cfc?method=doHotelPrice",
		data:"nSearchID="+search_id+"&nHotelCode="+hotel+"&sHotelChain="+chain,
		async: true,
		dataType: 'json',
		timeOut: 5000,
		success:function(data) {
			var Rate = data[0] != 'Sold Out' ? '$'+data[0] : data[0];
			var Address = data[1];
			var Policy = data[2];
			var Policies = data[3];
			var PreferredVendor = data[4];
			//var PolicyImage = Policy = 0 ? '<img src="assets/img/policy0.png">' : '';
			//console.log(Policies);
			$("#checkrates"+hotel).html(Rate);
			if (Rate != 'Sold Out') {
				$("#checkrates"+hotel).append('<input type="submit" class="button'+Policy+'policy" name="trigger" value="See Rooms">');//+Policy+Policies+PreferredVendor
			}
			else {
				$("#checkrates"+hotel).html(Rate);//+Policy+Policies+PreferredVendor
			}
			$("#address"+hotel).html(Address);
			$("#"+hotel).attr('data-policy',Policy);
			$("#"+hotel).attr('data-minrate',data[0]);//Send in the rate without the $
		},
		error:function(test, tes, te) {
			console.log('broken');
			console.log(test);
			console.log(tes);
			console.log(te);
		}
	});
	return false;
}

function hotelPhotos(property_id, photos) {
	$.ajax({
		//var serverurl = 'http://localhost:8888/booking'
		url:"https://www.shortstravel.com/bookrate.cfc?method=photos",
		data:"Property_ID="+property_id+"&Photos="+photos,
		dataType: 'jsonp',
		crossDomain: true,
		beforeSend:function () {
			$( "#details" + property_id ).removeClass('refbuttonactive');
			$( "#rates" + property_id ).removeClass('refbuttonactive');
			$( "#amenities" + property_id ).removeClass('refbuttonactive');
			$( "#photos" + property_id ).addClass('refbuttonactive');
			$( "#area" + property_id ).removeClass('refbuttonactive');
			$( "#seerooms" + property_id ).show();
			$( "#hiderooms" + property_id ).hide();
			if (photos == '') {
				$("#hotelrooms" + property_id).html('<div style="border-top:1px dashed gray;"></div><div style="width:100%;margin:0 auto; text-align:center;"><br><br><img src="http://localhost:8888/booking/assets/img/ajax-loader.gif"><br>Gathering the most up to date information...</div>').show();
			}
			else {
				$("#hotelrooms" + property_id).html('<div style="border-top:1px dashed gray;"></div><div style="width:100%;margin:0 auto; text-align:center;"><br><br><img src="http://localhost:8888/booking/assets/img/ajax-loader.gif"><br>loading...</div>').show();
			}
		},
		success:function(details) {
			var firstimg = '';
			var table = '<div style="border-top:1px dashed gray;"></div><div class="listtable">';
				table += '<div class="listrow"><strong>PHOTO GALLERY</strong><a href="#" onClick="hideDetails(' + property_id + ');return false;" style="float:right;">close details</a><br><br></div>';
				table += '<div class="listrow">';
			var count = 0;
			$.each(details, function(key, val) {
				count++;
				if (firstimg == '') {
					table += '<div class="listcell" style="width:300px;">';
					firstimg = val;
				}
				table += '<a href="#" onClick="setImage(' + count + ', ' + property_id + ');return false;"><img id="img' + property_id + count + '" src="' + val + '" border="0" width="75" height="50" style="padding:5px;" /></a>';
			});			
			if (firstimg != '') {
				table += '</div>';
				table += '<div class="listcell" style="width:400px;overflow:hidden;max-height:300px;height:300px;">';
				table += '<img src="' + firstimg + '" id="mainImage' + property_id + '">';
				table += '</div>';
			}
			else {
				table += 'no images available at this time';
			}
			table += '</div>';
			$( "#hotelrooms" + property_id).html(table).show();
		},
		error:function(test, tes, te) { 
			//console.log(te);
		}
	});
	return false;
}

function showRates(search_id, property_id) {
	$.ajax({type:"POST",
		url:"services/hotelrooms.cfc?method=getRooms",
		data:"nSearchID="+search_id+"&nHotelCode="+property_id,
		async: true,
		dataType: 'json',
		success:function(rates) {
			// 0 - PROPERTYID 1- COUNT 2 - ROOMDESCRIPTION 3- RATE 4 - CURRENCYCODE 5 - NEGOTIATEDRATECODE 6 - POLICY
			var table='<div class="listtable">';
			$.each(rates.DATA, function(key, val) {
				table+='<table>';
				table+='<tr><td width="20%">$'+val[3];
				table+=val[4] != 'USD' ? val[2] : '';//add the currency code if it's not USD
				table+=' per night</td>';
				table+='<td width="65%">'+val[2]+'</td>';
				//table+=val[5];// rate code
				/* Government rates
				if (val[5].indexOf(hotel_ratecodes) <= 0) {
					table += '</div>';
				}
				else {
					table += '<img src="../img/corprate.gif"></div>';
				}					
				*/
				table+='<td width="15%"><a href="##" onClick="submitHotel('+property_id+','+val[0]+');return false" class="button">Reserve</a>';
				if (val[6] == false) {
					table+='<br /><font color="#C7151A">Out of Policy</font>';
				}
				table+='</td>';
				table+='</tr>';
			});
			table+='</table>';
			$("#hotelrooms"+property_id).html(table);
		},
		error:function(test, tes, te) { 
			console.log(test);
			console.log(tes);
			console.log(te);
		}
	});
	return false;
}

function displayHotelInfo(e) {
	if (e.targetType == "pushpin") {
		var pix = map.tryLocationToPixel(e.target.getLocation(), Microsoft.Maps.PixelReference.control);
		var infoboxTitle = document.getElementById('infoboxTitle');
		infoboxTitle.innerHTML = e.target.title;
		var infoboxDescription = document.getElementById('infoboxDescription');
		infoboxDescription.innerHTML = e.target.description;
		var infobox2 = document.getElementById('infoBox');
		infobox2.style.top = (pix.y - 60) + "px";
		infobox2.style.left = (pix.x + 5) + "px";
		infobox2.style.visibility = "visible";
		document.getElementById('mapDiv').appendChild(infobox2);
	}
	return false;
}
function closeInfoBox() {
	var infobox2 = document.getElementById('infoBox');
	infobox2.style.visibility = "hidden";
	return false;
}
function changeLatLongCenter(e) {
	if (e.targetType == "map") {
		var zoom = map.getZoom();
		var infoboxvisibility = document.getElementById('infoBox').style.visibility;
		closeInfoBox();
		if (zoom >= 12 && infoboxvisibility == 'hidden') {
			$("#dialog").dialog({	
				buttons: { "Yes": function() { 
									var point = new Microsoft.Maps.Point(e.getX(), e.getY());
									var loc = e.target.tryPixelToLocation(point);
									$( "#latlong" ).val(loc['latitude']+','+loc['longitude']);
									$( "#changelatlong" ).submit();
									$(this).dialog("close");
								},
							'No': function() {
									$(this).dialog("close"); 
								}
						}
			});
		}
	}
	return false;
}
$(document).ready(function() {
	$("#overlay").jqm({
		modal: true,
		ajax: "@href",
		overlayClass: "overlayBackground",
		trigger: "a.overlayTrigger",
		closeClass: "overlayClose",
		target: "#overlayContent",
		overlay:75
	});
});