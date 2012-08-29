function toggleDiv(div) {
	$( '#' + div ).toggle( 'fade' );
}
function filterAir() {
	var multicarrier = $( "#MultiCarrier:checked" ).val();
	var policy = $( "#Policy:checked" ).val();
	var preferred = $( "#Preferred:checked" ).val();
	var nonstops = $( "#NonStops:checked" ).val();
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
//console.log('multicarrier ' + multicarrier);
//console.log('policy ' + policy);
//console.log('preferred ' + preferred);
//console.log('NonStops ' + $( '#NonStops:checked').val());
	for (loopcnt = 0; loopcnt <= (flightresults.length-1); loopcnt++) {
		var flight = flightresults[loopcnt];
		if ((multicarrier == 0 && flight[2] == 1) ||
		(policy == 1 && flight[1] == 0) ||
		(preferred == 1 && flight[7] == 0) ||
		(nonstops == 1 && flight[9] != 0)) {
			$( '#' + flight[0] ).hide( 'fade' );
//console.log('hide');
		}
		else {
			carriercount = 0;
//console.log('show');
			$( '#' + flight[0] ).show( 'fade' );
			//for (var i = 0; i < flight[3].length; i++) {
			//	if ($( "#Carrier" + flight[3][i] ).is(':checked') == true) {
			//		carriercount++;
			//	}
			//}
			//if (carriercount == 0) {
			//	$( '#' + flight[0] ).hide( 'fade' );
			//}
			//else {
			//	$( '#' + flight[0] ).show( 'fade' );
			//}
		}
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