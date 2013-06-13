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
/*
	Select seats from the summary page
*/
function selectSeats(sCarrier, nFlightNumber, sSeat, sOrigin, Destination) {

    var SearchID = $( "#SearchID" ).val();
    var nTraveler = $( "#nTraveler" ).val();
    var oldSeat = $( "#Seat" + sCarrier + nFlightNumber + sOrigin + Destination).val();

    $( "#" + oldSeat ).removeClass('currentseat');
    $( "#" + sSeat ).addClass('currentseat');

    $( "#Seat" + sCarrier + nFlightNumber + sOrigin + Destination + "_view").val(sSeat);
    $( "#Seat" + sCarrier + nFlightNumber + sOrigin + Destination + "_popup").val(sSeat);
    $( "#Seat" + sCarrier + nFlightNumber + sOrigin + Destination ).val(sSeat);

    $.ajax({
        type: 'POST',
        url: 'services/traveler.cfc',
        data: {
            method: 'setSeat',
            SearchID: SearchID,
            nTraveler: nTraveler,
            sCarrier: sCarrier,
            nFlightNumber: nFlightNumber,
            sOrigin: sOrigin,
            Destination: Destination,
            sSeat: sSeat
        },
        dataType: 'json'
    });

    return false;
}
function getUnusedTickets(userid, acctid) {

    $.ajax({type:"POST",
        url: 'services/reports.cfc?method=showUnusedTickets',
        data:"UserID="+userid+"&AcctID="+acctid,
        dataType: 'json',
        success:function(data) {
            $("#unusedtickets").html(data);
        },
        error:function(test, tes, te) {
            console.log('error');
        }
    });

    return false;
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

function AirPrice(searchid, trip_id, cabin, refundable) {
	$.ajax({type:"POST",
		url:"services/AirPrice.cfc?method=doAirPrice",
		data:"SearchID="+searchid+"&nTrip="+trip_id+"&sCabin="+cabin+"&bRefundable="+refundable,
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

function hotelPrice(searchid, hotel, chain) {
	$.ajax({type:"POST",
		url:"services/hotelprice.cfc?method=doHotelPrice",
		data:"SearchID="+searchid+"&nHotelCode="+hotel+"&sHotelChain="+chain,
		async: true,
		dataType: 'json',
		timeOut: 5000,
		success:function(data) {
			var Rate = data[0] != 'Sold Out' ? '$'+data[0] : data[0];
			var Address = data[1];
			var divdata = '<div id="seerooms'+hotel+'" class="button-wrapper"><a onClick="showRates('+searchid+',\''+hotel+'\');return false;" class="button"><span>See Rooms</span></a></div>';
			divdata+='<div id="hiderooms'+hotel+'" class="button-wrapper hide"><a onClick="hideRates(\''+hotel+'\');return false;" class="button"><span>Hide Rooms</span></a></div>';
			$("#checkrates2"+hotel).html(Rate + divdata);
			// if it's Sold Out overwrite existing html with the Sold Out message
			if (Rate == 'Sold Out') {
				$("#checkrates2"+hotel).html(Rate);
				$("#DetailLinks"+hotel).html('');
				var ArrayOrder = jQuery.inArray(hotel,orderedpropertyids);
				//console.log(orderedpropertyids);
				//console.log(ArrayOrder);
				//console.log(hotel);
				//console.log(hotelresults['DATA']['SOLDOUT'][ArrayOrder]);
				hotelresults['DATA']['SOLDOUT'][ArrayOrder] = 1;
				//console.log(hotelresults['DATA']['SOLDOUT'][ArrayOrder]);
			}
			$("#address"+hotel).html(Address);
		},
		error:function(test,tes,te) {
			logError(test,tes,te)
		}
	});
	return false;
}

/* this shows when loading hotel details, rooms, amenities or photos */
function hotelLoading(property_id) {
	//$("#details"+property_id).removeClass('refbuttonactive');
	//$("#rates"+property_id).addClass('refbuttonactive');
	//$("#amenities"+property_id).removeClass('refbuttonactive');
	//$("#photos"+property_id).removeClass('refbuttonactive');
	//$("#area"+property_id).removeClass('refbuttonactive');
	$("#seerooms"+property_id).hide();
	$("#hiderooms"+property_id).show();
	$("#checkrates"+property_id).html('<div style="border-top:1px dashed gray;"></div><div style="width:100%;margin:0 auto; text-align:center;"><br><br>Gathering the most up to date information...<br><img src="assets/img/ajax-loader.gif"></div>').show();
}

function showRates(searchid,property_id) {
	$.ajax({
		url:"services/hotelrooms.cfc?method=getRooms",
		data:"SearchID="+searchid+"&nHotelCode="+property_id,
		dataType: 'json',
		beforeSend:function () {
			hotelLoading(property_id)
		},
		success:function(rates) {
			//"0 - PROPERTYID, 1 - COUNT, 2 - ROOMDESCRIPTION, 3 - RATE, 4 - CURRENCYCODE, 5 - ROOMRATECATEGORY, 6 - ROOMRATEPLANTYPE, 7 - POLICY, 8 - GOVERNMENTRATE"
			var table = '<table width="100%">';
			$.each(rates.DATA, function(key, val) {
				table+='<tr style="padding:5px;width:80px;border-top:1px dashed gray;"><td>';
				table+='$ '+val[3];
				if (val[4] != 'USD' && val[4] != null) {
					table+=val[4];
				}
				table+=' per night&nbsp;</td>';
				table+='<td>'+val[2]+'</td>';
				var GovernmentRate = val[8];
				var PolicyFlag = val[7] == true ? 1 : 0;
				table+='<td><input type="submit" id="ChosenHotel" name="HotelSubmission" class="button'+PolicyFlag+'policy" value="Reserve" onclick="submitHotel(\''+property_id+'\',\''+val[2]+'\');">';
				if (GovernmentRate) {
					table+='<img src="assets/img/GovRate.gif">';
				}
				if (val[7] == false) {
					if (GovernmentRate) {
						table+='<br>';
					}
					table+='<font color="#C7151A">Out of Policy</font>';
				}
				table+='</td></tr>';
			});
			table+='<tr><td></td></tr></table>';
			$( "#checkrates" + property_id).html(table).show();
		},
		error:function(test,tes,te) {
			logError(test,tes,te)
		}
	});
	return false;
}

function showDetails(searchid,property_id,hotel_chain,rate_type) {
	$.ajax({
		url:"services/hoteldetails.cfc?method=doHotelDetails",
		data:"SearchID="+searchid+"&nHotelCode="+property_id+"&sHotelChain="+hotel_chain+"&sRatePlanType="+rate_type,
		dataType: 'json',
		beforeSend:function () {
			hotelLoading(property_id)
		},
		success:function(details) {
			var table = '<br /><table width="100%"><tr><td class="bold">HOTEL DETAILS<a href="#" onClick="hideRates('+property_id+');return false;" style="float:right;">close details</a><br /><br /></td></tr>';
			$.each(details.DATA, function(key, val) {
				var data = details.DATA;
				var DetailsShown = false;
				var CheckInTime = data[0][1];
				if (CheckInTime != undefined && CheckInTime != '') {
					table+='<tr><td><strong>Check In Time:</strong> '+CheckInTime+'<br /><br /></td></tr>';
					DetailsShown = true;
				}
				var CheckOutTime = data[0][2];
				if (CheckOutTime != undefined && CheckOutTime != '') {
					table+='<tr><td><strong>Check Out Time:</strong> '+CheckOutTime+'<br /><br /></td></tr>';
					DetailsShown = true;
				}
				var Details = data[0][0];
				if (Details != undefined && Details != '') {
					table+='<tr><td><strong>Details:</strong> '+Details+'</td></tr>';
					DetailsShown = true;
				}

				if (DetailsShown == false) {
					table+='<tr><td><em>There are no details for this hotel.</em></td></tr>';
				}

			});
			table+='</table>';
			$("#checkrates"+property_id).html(table).show();
		},
		error:function(test,tes,te) {
			logError(test,tes,te)
		}
	});
	return false;
}

function showAmenities(searchid,property_id) {
	$.ajax({
		url:"services/hotelrooms.cfc?method=getAmenities",
		data:"SearchID="+searchid+"&nHotelCode="+property_id,
		dataType: 'json',
		beforeSend:function () {
			hotelLoading(property_id)
		},
		success:function(details) {
			var table = '<br /><table width="100%"><tr><td class="bold">HOTEL AMENITIES<a href="#" onClick="hideRates('+property_id+');return false;" style="float:right;">close details</a><br /><br /></td></tr>';
			var count = 0;
			$.each(details, function(val) {
				count++;
				if (count % 3 == 1) {
					table+='<tr>';
				}
				table+='<td width="33%">'+details[val]+'</td>';
				if (count % 3 == 0) {
					table+='</tr>';
				}
			});
			table+='</table>';
			$( "#checkrates" + property_id).html(table).show();
		},
		error:function(test,tes,te) {
			logError(test,tes,te)
		}
	});
	return false;
}

function showPhotos(searchid,property_id,hotel_chain) {
	$.ajax({
		url:"services/hotelphotos.cfc?method=doHotelPhotoGallery",
		data:"SearchID="+searchid+"&nHotelCode="+property_id+"&sHotelChain="+hotel_chain,
		dataType: 'json',
		beforeSend:function () {
			hotelLoading(property_id)
		},
		success:function(details) {
			var firstimg = '';
			var table = '<br /><table width="500px"><tr><td class="bold" colspan="2">HOTEL PHOTOS';
			table+='<a href="#" onClick="hideRates('+property_id+');return false;" style="float:right;">close details</a><br /><br /></td></tr><tr><td><table>';
			var count = 0;
			$.each(details, function(key, val) {
				count++;
				if (firstimg == '') {
					firstimg = val;
				}
				if (count % 3 == 1) {
					table+='<tr>';
				}
				table+='<td><a href="#" onClick="setImage(' + count + ', ' + property_id + ');return false;">';
				table+='<img id="img' + property_id + count + '" src="' + val + '" border="0" width="75" height="50" style="padding:2px;" /></a></td>';
				if (count % 3 == 0) {
					table+='</tr>';
				}
			});
			table+='</table>';
			table+='<td><table><tr><td>';
			if (firstimg != '') {
				table+='<div class="listcell" style="width:300px;overflow:hidden;max-height:300px;height:300px;">';
				table+='<img width="300px" src="' + firstimg + '" id="mainImage' + property_id + '">';
			}
			else {
				table+='no images available at this time';
			}
			table+='</td></tr></table></td></tr></table>';
			$( "#checkrates" + property_id).html(table).show();
		},
		error:function(test,tes,te) {
			logError(test,tes,te)
		}
	});
	return false;
}

$(document).ready(function() {

 // bootstrap tooltips
 //  add  " rel='tooltip' " to element and it will use that elements title text as toolip
	$(function () {
		$("[rel='tooltip']").tooltip();
	});

  $("#SoldOut")
  .button()
  .change(function() {
  	filterhotel();
  });

  $("#Policy")
  .button()
  .change(function() {
  	filterhotel();
  });

  $(".radiobuttons").buttonset();
  $("#HotelChains").button();
	$("#HotelAmenities").button();

});

function loadImage(image, property_id) {
  $( "#hotelimage" + property_id ).html('');
  var img = new Image();
  $(img).load(function () {
    $(img).hide();
    $( "#hotelimage" + property_id ).html(img);
    $(img).fadeIn('slow');
  }).attr('src', image)
  .attr('style','max-width: 125px;');
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

function setImage(count, property_id) {
	var mImage = $('#mainImage'+property_id)[0]
	mImage.src = $( "#img" + property_id + count ).attr("src");
	return false;
}

function hideRates(property_id) {
	$("#hiderooms"+property_id).hide();
	$("#seerooms"+property_id).show();
	$("#checkrates"+property_id).hide();
	return false;
}

function submitForm(formname, submitbutton, newbuttontext){
	if (submitbutton != '') {
		$("#" + submitbutton).html('<a class="button" onclick="return false;"><span>' + newbuttontext + '</span></a>');
	}
	$( "#" + formname ).submit();
	return false;
}

function stohotel() {
	if ($("#Hotel_Search").val() === "Airport") {
		$("#filterhotelairport").show('fast');
		$("#filterhotellandmark").hide();
		$("#filterhoteladdress").hide();
		$("#filterhoteloffice").hide();
	}
	else if ($("#Hotel_Search").val() === "City") {
		$("#filterhotelairport").hide();
		$("#filterhotellandmark").show('fast');
		$("#filterhoteladdress").hide();
		$("#filterhoteloffice").hide();
	}
	else if ($("#Hotel_Search").val() === "Address") {
		$("#filterhotelairport").hide();
		$("#filterhotellandmark").hide();
		$("#filterhoteladdress").show('fast');
		$("#filterhoteloffice").hide();
	}
	else if ($("#Hotel_Search").val() === "Office") {
		$("#filterhotelairport").hide();
		$("#filterhotellandmark").hide();
		$("#filterhoteladdress").hide();
		$("#filterhoteloffice").show('fast');
	}
}

/*Submits the hotel.search form.*/
function submitHotel (sHotel,sRoomDescription) {
	$("#sHotel").val(sHotel);
	$("#sRoomDescription").val(sRoomDescription);
	$("#hotelForm").submit();
}

//PAGES
function writePages(number_of_items) {

	//calculate the number of pages that are needed
	var number_of_pages = Math.ceil(number_of_items/20);
	//set current page
	var current_page = $('#current_page').val();
	//reset current page if they are on a page that isn't available
	if (current_page > number_of_pages - 1) {
		current_page = 0;
		$('#current_page').val(0);
	}
	//define variable
	var navigation_html = '';
	//create html for the previous link
	if (current_page != 0) {
		navigation_html+='<a class=prev_page href="javascript:previous();"><< Previous Page</a> ';
	}
	//create html for the numbered links
	if (number_of_pages > 1) {
		var current_link = 0;
		while(number_of_pages > current_link){
			navigation_html+='<a class=page_link href="javascript:go_to_page('+current_link+')" longdesc="'+current_link+'">'+(current_link+1)+'</a> ';
			current_link++;
		}
	}
	//create html for the next link
	if (($('#current_page').val() != number_of_pages-1) && (number_of_pages > 0)) {
 	   navigation_html+='<a class=next_page href="javascript:next();">Next Page >></a>';
	}
	//write the html to the navigation div
  $('#page_navigation').html(navigation_html);
  $('#page_navigation2').html(navigation_html);
  //add active_page class to the active page link
  $('#page_navigation .page_link').eq(current_page).addClass('active_page');
  $('#page_navigation2 .page_link').eq(current_page).addClass('active_page');
	return false;
}

function previous() {
	new_page = parseInt($('#current_page').val()) - 1;
	$('#current_page').val(new_page);
	filterhotel();
}

function next() {
	new_page = parseInt($('#current_page').val()) + 1;
	$('#current_page').val(new_page);
	filterhotel();
}

function go_to_page(new_page) {
	$('#current_page').val(new_page);
	filterhotel();
}

/*
--------------------------------------------------------------------------------------------------------------------
CAR SECTION
--------------------------------------------------------------------------------------------------------------------
*/
function filterCar(howFilter) {
	if (howFilter == 'clearAll') {
		$(":checkbox").prop('checked', true);
		$("#btnPolicy").parent().addClass('active');
	}

	var policy = $("#btnPolicy").parent().hasClass('active');
	var nCount = 0;

	for (loopcnt = 0; loopcnt <= (carresults.length-1); loopcnt++) {
		var car = carresults[loopcnt];
																							//console.log(car)
		if (($( "#fltrCategory" + car[1] ).is(':checked') == false)
		|| ($( "#fltrVendor" + car[2] ).is(':checked') == false)
		|| (policy == true && car[3] != 1)) {
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
		if (($( "#fltrCategory" + category[0] ).is(':checked') == false)
		|| (policy == true && category[1] != 1)) {
			$( '#row' + category ).hide();
		}
		else {
			$( '#row' + category ).show();
		}
	}
	for (loopcnt = 0; loopcnt <= (carvendors.length-1); loopcnt++) {
		var vendor = carvendors[loopcnt];
																							//console.log(vendor);
		if (($( "#fltrVendor" + vendor[0] ).is(':checked') == false)
		|| (policy == true && vendor[1] != 1)) {
			$( '#vendor' + vendor[0] ).hide();
		}
		else {
			$( '#vendor' + vendor[0] ).show();
		}
	}

	return nCount;
}
/* $(document).ready(function() {
	$("#overlay").jqm({
		modal: true,
		ajax: "@href",
		overlayClass: "overlayBackground",
		trigger: "a.overlayTrigger",
		closeClass: "overlayClose",
		target: "#overlayContent",
		overlay:75
	});

}); */

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

function couldYouAir(searchid,trip,cabin,refundable,adddays,startdate,viewDay,currenttotal) {
    console.log('air')
	$.ajax({type:"POST",
		url:"services/couldyou.cfc?method=doAirPriceCouldYou",
		data:"SearchID="+searchid+"&nTrip="+trip+"&sCabin="+cabin+"&bRefundable="+refundable+"&nTripDay="+adddays+"&nStartDate="+startdate+"&nTotal="+currenttotal,
		async: true,
		dataType: 'json',
		timeOut: 5000,
		success:function(data) {
			getTotal(data,startdate)
		},
		error:function(test,tes,te) {
			logError(test,tes,te)
		}
	});
	return false;
}

function couldYouHotel(searchid,hotelcode,hotelchain,viewDay,nights,startdate,currenttotal) {
	$.ajax({type:"POST",
		url:"services/couldyou.cfc?method=doHotelPriceCouldYou",
		data:"SearchID="+searchid+"&nHotelCode="+hotelcode+"&sHotelChain="+hotelchain+"&nTripDay="+viewDay+"&nNights="+nights+"&nTotal="+currenttotal,
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

function couldYouCar(searchid,carchain,cartype,viewDay,startdate,currenttotal) {
	$.ajax({type:"POST",
		url:"services/couldyou.cfc?method=doCarPriceCouldYou&SearchID="+searchid,
		data:"SearchID="+searchid+"&sCarChain="+carchain+"&sCarType="+cartype+"&nTripDay="+viewDay+"&nTotal="+currenttotal,
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


function setOtherFields(nTraveler, overrideEverything) {
    var SearchID = $( "#SearchID" ).val();
    $.ajax({
        type: 'POST',
        url: 'services/traveler.cfc',
        data: {
            method: 'getTraveler',
            nTraveler: nTraveler,
            SearchID: SearchID
        },
        dataType: 'json',
        success: function(traveler) {
            //set global variables
            var sCarriers = $( "#sCarriers" ).val().split(',');
            var sCarVendor = $( "#sCarVendor" ).val();
            //set variables if defined
            var stAirFFs = new Object();
            if (typeof traveler['STFFACCOUNTS'] != 'undefined'
                && typeof traveler['STFFACCOUNTS']['A'] != 'undefined') {
                stAirFFs = traveler['STFFACCOUNTS']['A'];
            }
            var stCarFFs = new Object();
            if (typeof traveler['STFFACCOUNTS'] != 'undefined'
                && typeof traveler['STFFACCOUNTS']['C'] != 'undefined') {
                stCarFFs = traveler['STFFACCOUNTS']['C'];
            }
            var stHotelFFs = new Object();
            if (typeof traveler['STFFACCOUNTS'] != 'undefined'
                && typeof traveler['STFFACCOUNTS']['H'] != 'undefined') {
                stHotelFFs = traveler['STFFACCOUNTS']['H'];
            }
            var stFOPs = new Object();
            if (typeof traveler['STFOPS'] != 'undefined') {
                stFOPs = traveler['STFOPS'];
            }
            var sSeat = '';
            if (typeof traveler['WINDOW_AISLE'] != 'undefined') {
                sSeat = traveler['WINDOW_AISLE'];
            }
            //logic to update form fields
            for (var i = 0; i < stFOPs.length; i++) {
                console.log(stFOPs[i]);

            }
            if (($( "#Air_FF" + sCarriers[i] ).val() == '')
            || overrideEverything == true) {
	            for (var i = 0; i < sCarriers.length; i++) {
	                if (typeof stAirFFs[sCarriers[i]] != 'undefined') {
	                    $( "#Air_FF" + sCarriers[i] ).val(stAirFFs[sCarriers[i]]);
	                }
	                else {
	                    $( "#Air_FF" + sCarriers[i] ).val('');
	                }
	            }
            }
            if (typeof stCarFFs[sCarVendor] != 'undefined') {
                $( "#Car_FF" ).val(stCarFFs[sCarVendor]);
            }
            else {
                $( "#Car_FF" ).val('');
            }
            $( "#Seats" ).val(sSeat);
        }
    });
}

function getAuthorizedTravelers(userID, acctID) {
	$.ajax({
		type: 'POST',
		url: 'RemoteProxy.cfc',
		data: {	method: 'getAuthorizedTravelers',
				userID: userID,
				acctID: acctID
			  },
		dataType: 'json',
		success: function(Travelers) {
			$.each(Travelers, function(index,Traveler) {
				$( "#userID" ).append( '<option value="' + Traveler.userId + '"'+ 'selected>' + Traveler.lastName + ', ' + Traveler.firstName + '</option>')
			});
		}
	});
	return false
}

function getUser(userID) {
	$.ajax({
		type: 'POST',
		url: 'RemoteProxy.cfc',
		data: {	method: 'getUser',
				userID: userID
			  },
		dataType: 'json',
		success: function(User) {
			$( "#firstName" ).val( User.firstName );
			$( "#middleName" ).val( User.middleName );
			$( "#noMiddleName" ).val( User.noMiddleName );
			$( "#lastName" ).val( User.lastName );
			$( "#phoneNumber" ).val( User.phoneNumber );
			$( "#wirelessPhone" ).val( User.wirelessPhone );
			$( "#email" ).val( User.email );
			$( "#gender" ).val( User.gender );
			//var birthday = new Date();
			//var birthday = User.birthdate;
			//$( "#birthdayMonth" ).val( birthday.getDate() );
		}
	});
	return false
}

function getUserCCEmails(userID) {
	$.ajax({
		type: 'POST',
		url: 'RemoteProxy.cfc',
		data: {	method: 'getUserCCEmails',
				userID: userID,
				returnType: 'string'
			  },
		dataType: 'json',
		success: function(ccEmails) {
			$( "#ccEmails" ).val( ccEmails );
		}
	});
	return false
}

function changeTraveler(nTraveler) {
	var userID = $( "#User_ID" ).val();

	setTravelerForm(nTraveler, 1, userID);
}
function setTravelerForm(nTraveler, bCollapse, nDefaultUser) {
	var searchID = $( "#SearchID" ).val();

	$( "#travelerForm" ).html('<table width="500" height="300"><tr><td valign="top">Gathering profile data...</td></tr></table>');
	$( "#paymentForm" ).html('<table width="500"><tr><td valign="top"></td></tr></table>');

	$.ajax({
		type: 'POST',
		url: 'RemoteProxy.cfc',
		data: {
			method: 'getUser',
			userID: nDefaultUser
		},
		dataType: 'json',
		success: function(data) {
			console.log(data);
			writeTravelerForm(data);
			$( "#travelerForm" ).html(data);
			//setPaymentForm(nTraveler);
			//setOtherFields(1, 0);
		}
	});
}
function setPaymentForm(nTraveler) {
	var searchID = $( "#SearchID" ).val();
	var air = $( "#Air" ).val();
	var car = $( "#Car" ).val();
	var hotel = $( "#Hotel" ).val();

	$.ajax({
		type: 'POST',
		url: 'services/payment.cfc',
		data: {
			method: 'payments',
			nTraveler: nTraveler,
			searchID: searchID,
			air: air,
			car: car,
			hotel: hotel
		},
		dataType: 'json',
		success: function(data) {
			$( "#paymentForm" ).html(data);
		}
	});
}