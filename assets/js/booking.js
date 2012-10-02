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
																			//console.log('hide');
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
			//"RATE_ID","RATE_CODE","RATE_DESC","AVERAGE_RATE","TOTAL_COST","RATE_HIC","CURRENCY","RATEORDER","RATE_ORDER","ROOM_POLICY","POLICY"
			var table = '<div class="listtable">';
			$.each(rates.DATA, function(key, val) {
				table+='<div class="listrow">';
				if (val[2] == 'USD') {
					table += '<div class="listcell" style="padding:5px;width:100px;border-top:1px dashed gray;"><span class="cost1">$'+val[1]+'</span> per night</div>';
				}
				else {//non USD
					table += '<div class="listcell" style="padding:5px;width:100px;border-top:1px dashed gray;"><span class="cost1">'+val[1]+' '+val[2]+'</span> per night</div>';
				}					
				//table += '<div class="listcell" style="padding:5px;width:500px;border-top:1px dashed gray;">'+val[4];// rate code
				/* Government rates
				if (val[5].indexOf(hotel_ratecodes) <= 0) {
					table += '</div>';
				}
				else {
					table += '<img src="../img/corprate.gif"></div>';
				}					
				*/
				table += '<div class="listcell" style="padding:5px;width:80px;border-top:1px dashed gray;"><div class="button-wrapper" id="button'+property_id+'"><a href="##" onClick="submitHotel('+property_id+','+val[0]+');return false" class="button"><span>Reserve</span></a></div>';
				/*
				if (val[9] == 0 || val[10] == 0) {
					table += '<font color="#C7151A">Out of Policy</font>';
				}
				*/
				table += '</div></div>';
			});
			table += '</div>';
			$("#hotelrooms"+property_id).html(table);
			console.log(property_id);
			//$("#hotelrooms"+property_id).html(table);
			//$("#checkrates"+hotel).html('this works');
		},
		error:function(test, tes, te) { 
			console.log(test);
			console.log(tes);
			console.log(te);
		}
	});
	return false;
}