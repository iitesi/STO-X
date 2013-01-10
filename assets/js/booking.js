function toggleDiv(div) {
	$( "#" + div ).toggle( 'fade' );
}
/*
	Submits the air.availability form.
*/
function submitAvailability (nTripKey) {
	$("#nTrip").val(nTripKey);
	$("#availabilityForm").submit();
}
/*
	Submits the air.lowfare form.
*/
function submitLowFare (nTripKey) {
	$("#nTrip").val(nTripKey);
	$("#lowfareForm").submit();
}
/*
	Submits the car.availability form.
*/
function submitCarAvailability (sCategory, sVendor) {
	$("#sCategory").val(sCategory);
	$("#sVendor").val(sVendor);
	$("#carAvailabilityForm").submit();
}
/*
	Shows and hides the manual payment form
*/
function showManualCreditCard(type) {
	var option = $( "#" + type + "FOP_ID" ).val();
	if (option == 'Manual') {
		$( "#" + type + "Manual" ).show();
	}
	else {
		$( "#" + type + "Manual" ).hide();
	}
}
function filterAir() {
																			//console.log('start');
	var classy = $( "#ClassY:checked" ).val();
	var classc = $( "#ClassC:checked" ).val();
	var classf = $( "#ClassF:checked" ).val();
	var fare0 = $( "#Fare0:checked" ).val();
	var fare1 = $( "#Fare1:checked" ).val();
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
	 																		//console.log('---------------------------------------------------------------------');
	 																		//console.log('nonstops - '+nonstops);
	 																		//console.log('policy - '+policy);
	 																		//console.log('singlecarrier - '+singlecarrier);
	 																		//console.log('ran');
	 																		//console.log(flightresults);
	for (loopcnt = 0; loopcnt <= (flightresults.length-1); loopcnt++) {
		var flight = flightresults[loopcnt];
																			//console.log(flight)
																			//console.log(classy)
		if ((flight[6] == 'Y' && classy == undefined)
		|| (flight[6] == 'C' && classc == undefined)
		|| (flight[6] == 'F' && classf == undefined)
		|| (flight[4] == 0 && fare0 == undefined)
		|| (flight[4] == 1 && fare1 == undefined)
		|| (nonstops == 'on' && flight[7] != 0)
		|| (policy == 'on' && flight[1] != 1)
		|| (singlecarrier == 'on' && flight[2] != 0)) {
			$( '#' + flight[0] ).hide( 'fade' );
	 																		//console.log('---------------------------------------------------------------------');
																			//console.log('hide - '+flight[0]);
																			//console.log('hide - classofservice Y - '+(flight[6] == 'Y' && classy == undefined));
																			//console.log('hide - fares - '+(fares != flight[4]));
																			//console.log('hide - nonstops - '+(nonstops == 'on' && flight[7] != 0));
																			//console.log('hide - policy - '+(policy == 'on' && flight[1] != 1));
																			//console.log('hide - classofservice - '+(classofservice != flight[6]));
																			//console.log('hide - singlecarrier - '+(singlecarrier == 'on' && flight[2] != 0));
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
	 																		//console.log('---------------------------------------------------------------------');
																			//console.log('show - '+flight[0]);
																			//console.log('show - classofservice - '+(classofservice != flight[6]));
																			//console.log('show - fares - '+(fares != flight[4]));
																			//console.log('show - nonstops - '+(nonstops == 'on' && flight[7] != 0));
																			//console.log('show - policy - '+(policy == 'on' && flight[1] != 1));
																			//console.log('show - classofservice - '+(classofservice != flight[6]));
																			//console.log('show - singlecarrier - '+(singlecarrier == 'on' && flight[2] != 0));
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

/*
------------------
HOTEL SECTION
------------------
*/

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
			var sURL = 'Search_ID='+search_id+'&PropertyID='+hotel+'&RoomRatePlanType=&HotelChain='+chain;
			$("#checkrates"+hotel).html(Rate + '<a href="?action=hotel.popup&sDetails=Rooms&'+sURL+'" class="overlayTrigger"><button type="button" class="textButton">See Rooms</button></a>');
			// if it's Sold Out overwrite existing html with the Sold Out message
			if (Rate == 'Sold Out') {
				$("#checkrates"+hotel).html(Rate);
				$("#DetailLinks"+hotel).html('');
			}
			$("#address"+hotel).html(Address);
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

/*Submits the hotel.search form.*/
function submitHotel (sHotel) {
	$("#sHotel").val(sHotel);
	$("#hotelForm").submit();
}

/*
--------------------------------------------------------------------------------------------------------------------
CAR SECTION
--------------------------------------------------------------------------------------------------------------------
*/
function filterCar() {
	var policy = $( "input:checkbox[name=Policy]:checked" ).val();
	var nCount = 0;

	for (loopcnt = 0; loopcnt <= (carresults.length-1); loopcnt++) {
		var car = carresults[loopcnt];
																							//console.log(car)
		if (($( "#btnCategory" + car[1] ).is(':checked') == false)
		|| ($( "#btnVendor" + car[2] ).is(':checked') == false)
		|| (policy == 'on' && car[3] != 1)) {
			$( "#" + car[0] ).hide();
		}
		else {
			$( "#" + car[0] ).show();
			nCount++;
		}
	}
	for (loopcnt = 0; loopcnt <= (carcategories.length-1); loopcnt++) {
		var category = carcategories[loopcnt];
																							//console.log(category);
		if (($( "#btnCategory" + category[0] ).is(':checked') == false)
		|| (policy == 'on' && category[1] != 1)) {
			$( '#row' + category ).hide();
		}
		else {
			$( '#row' + category ).show();
		}
	}
	for (loopcnt = 0; loopcnt <= (carvendors.length-1); loopcnt++) {
		var vendor = carvendors[loopcnt];
																							//console.log(category);
		if (($( "#btnVendor" + vendor[0] ).is(':checked') == false)
		|| (policy == 'on' && vendor[1] != 1)) {
			$( '#vendor' + vendor[0] ).hide();
		}
		else {
			$( '#vendor' + vendor[0] ).show();
		}
	}

	return nCount;
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

/* CouldYou */

/* This creates the Total and updates the ID in the DOM if a struct was returned. It's the same for all 3 callbacks. */
function getTotal(data,startdate) {
	if (data['NTOTALPRICE'] != undefined) {
		var Total = data['DAY'] + '<br />';
		Total+= $.isNumeric(data['NTOTALPRICE']) ? '$' : '';
		Total+=data['NTOTALPRICE'];
		$("#Air"+startdate).attr('style','background-color:#' + data['SCOLOR'] + ';');
		$("#Air"+startdate).html(Total);
	}
	return false;
}

function logError(test,tes,te) {
	console.log(test);
	console.log(tes);
	console.log(te);	
}

function couldYouAir(search_id,trip,cabin,refundable,adddays,startdate,viewDay,currenttotal) {
	$.ajax({type:"POST",
		url:"services/couldyou.cfc?method=doAirPriceCouldYou",
		data:"nSearchID="+search_id+"&nTrip="+trip+"&sCabin="+cabin+"&bRefundable="+refundable+"&nTripDay="+adddays+"&nStartDate="+startdate+"&nTotal="+currenttotal,
		async: true,
		dataType: 'json',
		timeOut: 5000,
		success:function(data) {
			getTotal(data,startdate)
		},
		error:function(test, tes, te) {
			logError(test,tes,te)
		}
	});
	return false;
}

function couldYouHotel(search_id,hotelcode,hotelchain,viewDay,nights,startdate,currenttotal) {
	$.ajax({type:"POST",
		url:"services/couldyou.cfc?method=doHotelPriceCouldYou",
		data:"nSearchID="+search_id+"&nHotelCode="+hotelcode+"&sHotelChain="+hotelchain+"&nTripDay="+viewDay+"&nNights="+nights+"&nTotal="+currenttotal,
		async: true,
		dataType: 'json',
		timeOut: 5000,
		success:function(data) {
			getTotal(data,startdate)
		},
		error:function(test, tes, te) {
			logError(test,tes,te)
		}
	});
	return false;
}

function couldYouCar(search_id,carchain,cartype,viewDay,startdate,currenttotal) {
	$.ajax({type:"POST",
		url:"services/couldyou.cfc?method=doCarPriceCouldYou&Search_ID="+search_id,
		data:"nSearchID="+search_id+"&sCarChain="+carchain+"&sCarType="+cartype+"&nTripDay="+viewDay+"&nTotal="+currenttotal,
		async: true,
		dataType: 'json',
		timeOut: 5000,
		success:function(data) {
			getTotal(data,startdate)
		},
		error:function(test, tes, te) {
			logError(test,tes,te)
		}
	});
	return false;
}