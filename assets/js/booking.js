function toggleDiv(div) {
	$( '#' + div ).toggle( 'fade' );
}
function filterAir() {
	var multicarrier = $( "#MultiCarrier:checked" ).val();
	var policy = $( "#Policy:checked" ).val();
	var preferred = $( "#Preferred:checked" ).val();
	/*
	 * 	0	Token				DL0211DL1123UA221
	 * 	1	Policy				1/0
	 * 	2 	Multiple Carriers	1/0
	 * 	3 	Carriers			"DL","AA","UA"
	 * 	4	Refundable			1/0
	 * 	5	Total Price			000.00
	 * 	6	Travel Time			000
	 * 	7	Preferred			1/0
	 * 	8	Cabin Class			Economy, Business, First
	 * 	9	Stops				0/1/2
	 */
	for (loopcnt = 0; loopcnt <= (flightresults.length-1); loopcnt++) {
		var flight = flightresults[loopcnt];
		console.log($( '#Stops' + flight[9] + ':checked').val());
		if ((multicarrier == 0 && flight[2] == 1) ||
		(policy == 1 && flight[1] == 0) ||
		(preferred == 1 && flight[7] == 0) ||
		($( '#Stops' + flight[9] + ':checked').val() != 1)) {
			$( '#' + flight[0] ).hide( 'fade' );
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
function showDetails() {
	var details = $( "#Details:checked" ).val();
	for (loopcnt = 0; loopcnt <= (flightresults.length-1); loopcnt++) {
		var flight = flightresults[loopcnt];
		if (details == 1) {
			$( '#' + flight[0] + 'details' ).show( 'fade' );
		}
		else {
			$( '#' + flight[0] + 'details' ).hide( 'fade' );
		}
	}
	return false;
}
function filterairold() {
	var policy = $( "#Policy:checked" ).val();
	var itineraries = $( "input[name=Itineraries]:checked" ).val();
	var travpref = $( "#travpref:checked" ).val();
	var acctpref = $( "#acctpref:checked" ).val();
	var reffare = $( "#reffare:checked" ).val();
	if (reffare != 1) {
		 if ($( "#reffare" ).val() != 'schedule') {
		 	reffare = 0;
		 }
		 else {
		 	reffare = 1;
		 }
	}
	var nonreffare = $( "#nonreffare:checked" ).val();
	if (nonreffare != 1) {
		 if ($( "#nonreffare" ).val() != 'schedule') {
		 	nonreffare = 0;
		 }
		 else {
		 	nonreffare = 1;
		 }
	}
	var MinOutDep = $( "#MinOutDep" ).val();
	var MaxOutDep = parseInt($( "#MaxOutDep" ).val())+.59;
	var MinOutArr = $( "#MinOutArr" ).val();
	var MaxOutArr = parseInt($( "#MaxOutArr" ).val())+.59;
	var MinRetDep = $( "#MinRetDep" ).val();
	var MaxRetDep = parseInt($( "#MaxRetDep" ).val())+.59;
	var MinRetArr = $( "#MinRetArr" ).val();
	var MaxRetArr = parseInt($( "#MaxRetArr" ).val())+.59;
	var showntokens = '';
	var carriercount = 0;
	var flightnumcount = 0;
	matchcriteriacount = 0;
	//0 Air_ID, 1 Policy, 2 Carriers, 3 Carrier, 4 Flights, 5 Outbound_Depart, 6 Outbound_Arrival,
	//7 Return_Depart, 8 Return_Arrival, 9 Refundable, 10 Status, 11 Stops, 12 Count of carriers
	//12 Total fare, 13 Trip Type, 14 Token, 15 Traveler Preferred, 16 Account Preferred, 17 Class
	//18 Selected, 19 Private Fare, 20 PTC
	for (loopcnt = 0; loopcnt <= (flightresults.length-1); loopcnt++) {
		var flight = flightresults[loopcnt];
		//console.log(flight)
		var visible = $( "#air" + flight[14] ).is(":visible");
		//(PF == 1 && flight[19] == 0) ||
		//(PTC == 1 && flight[20] == 0) ||
		if ((flight[18] == 0) &&
		((policy == 1 && flight[1] == 0) ||
		(travpref == 1 && flight[15] == 0) ||
		(acctpref == 1 && flight[16] == 0) ||
		(itineraries == 0 && flight[2] == 1) ||
		(reffare == 0 && flight[9] == 1) ||
		(nonreffare == 0 && flight[9] == 0) ||
		((MinOutDep > flight[5]) == true) ||
		((MaxOutDep < flight[5]) == true) ||
		((MinOutArr > flight[6]) == true) ||
		((MaxOutArr < flight[6]) == true) ||
		((MinRetDep > flight[7]) == true) ||
		((MaxRetDep < flight[7]) == true) ||
		((MinRetArr > flight[8]) == true) ||
		((MaxRetArr < flight[8]) == true) ||
		($("#Stops" + flight[11]).is(':checked') == false))) {
			flight[10] = 'hide';
		}
		else {
			flight[10] = 'show';
			carriercount = 0;
			for (var i = 0; i < flight[3].length; i++) {
				if ($("#Carriers" + flight[3][i]).is(':checked') == true) {
					carriercount++;
				}
			}
			if (carriercount == 0) {
				flight[10] = 'hide';
			}
		}
		//console.log(matchcriteriacount + ' between ' + start_from + ' to ' + end_on + ' = ' + (matchcriteriacount >= start_from && matchcriteriacount < end_on) + ' - currnet showing ' + visible);
		if (flight[10] == 'hide' && visible == true) {
			//$("#air" + flight[14]).removeClass('show').addClass('hide');
			$("#air" + flight[14]).hide();
		}
		if (flight[10] == 'show') {
			showntokens = showntokens+','+flight[14];
		}
	}
	var sort = $( "#sorttype" ).val();
	var order = $( "#air" + sort + "sort" ).val();
	order = order.split(',');
	for (var t = 0; t < order.length; t++) {
		if (showntokens.indexOf(order[t]) > 0) {
			matchcriteriacount++;
			if (matchcriteriacount >= start_from && matchcriteriacount <= end_on) {
				$("#air" + order[t]).show();
			}
			else  {
				$("#air" + order[t]).hide();
			}
		}
	}
	$("#aircount").html(matchcriteriacount + ' itineraries displaying');
	airpgs(matchcriteriacount);
	if (matchcriteriacount == 0) {
		$( "#noairresults" ).show();
	}
	else {
		$( "#noairresults" ).hide();
	}
	if (itineraries == 1 && matchcriteriacount != 0) {
		$( "#multicarriermessage" ).fadeIn('slow');
	}
	else {
		$( "#multicarriermessage" ).hide();
	}
	return false;
}