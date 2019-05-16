$(document).ready(function(){

	var searchID = $("#searchID").val();
	var acctID = $( "#acctID" ).val();
	var valueID = $( "#valueID" ).val();
	var travelerNumber = $("#travelerNumber").val();
	var airSelected = $( "#airSelected" ).val();
	var platingcarrier = $( "#platingcarrier" ).val();
	var carriers = $( "#carriers" ).val();
	if (carriers != '') {
		carriers = $.parseJSON(carriers);
	}
	var hotelSelected = $( "#hotelSelected" ).val();

	if ($('#airSelected').val() == 'false' && $('#requireHotelCarFee').val() == 1){
		var serviceFeesSelected = 'true';
	}
	else {
		var serviceFeesSelected = 'false';
	}	
	var chainCode = $( "#chainCode" ).val();
	var masterChainCode = $( "#masterChainCode" ).val();
	var vehicleSelected = $( "#vehicleSelected" ).val();
	var vendor = $( "#vendor" ).val();
	var arrangerID = $( "#arrangerID" ).val();
	var arrangerAdmin = $( "#arrangerAdmin" ).val();
	var arrangerSTMEmployee = $( "#arrangerSTMEmployee" ).val();
	var unusedtickets = $( "#unusedtickets" ).val();
	var errors = $( "#errors" ).val();
	var airFee = parseFloat( $( "#airFee" ).val() );
	var auxFee = parseFloat( $( "#auxFee" ).val() );
	var airAgentFee = parseFloat( $( "#airAgentFee" ).val() );
	var airAgentFee = parseFloat( $( "#airAgentFee" ).val() );
	var requestFee = parseFloat( $( "#requestFee" ).val() );
	var findit = $("#findit").val();
	var externalTMC = $("#externalTMC").val();
	var finditOA = 0;
	if (findit == 1 && externalTMC == 1) {
		var finditOA = 1;
	}
	var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

	$( "#createProfileDiv" ).hide();
	$( "#usernameDiv" ).hide();
	$( "#hotelWhereStayingDiv" ).hide();
	getTraveler();

	// Get traveler from session and populate the form
	function getTraveler() {

		var userID = $( "#userID" ).val();
		var isGuest = (userID == 0);

		$.ajax({type:"POST",
			url: '/booking/RemoteProxy.cfc?method=getSearchTraveler',
			data:	{
						  travelerNumber : travelerNumber
						, searchID : searchID
					},
			dataType: 'json',
			success:function(traveler) {

				//console.log('getTraveler()...response');
				//console.log(traveler);

				loadTraveler(traveler, 'initial');
				$( "#orgUnits" ).html('');
				for( var i=0, l=traveler.orgUnit.length; i<l; i++ ) {
					if (isGuest && traveler.orgUnit[i].OUID == 925) { // Employee ID
						traveler.orgUnit[i].valueReport = traveler.orgUnit[i].OUDefault;
					}
					createForm(traveler.orgUnit[i]);
				}
				if (acctID == 348) {
					$( "#custom" ).trigger('change');
					for( var i=0, l=traveler.orgUnit.length; i<l; i++ ) {
						$( "#" + traveler.orgUnit[i].OUType + traveler.orgUnit[i].OUPosition ).val( traveler.orgUnit[i].valueID );
					}
				}
				if (airSelected == 'true') {
					loadPayments(traveler, 'air');
					showUnusedTickets(traveler.unusedTicket, traveler.bookingDetail.unusedTickets);
					$( "#airSpinner" ).hide();
				}
				if (serviceFeesSelected == 'true') {
					loadPayments(traveler, 'serviceFee');
					$( "#serviceFeeSpinner" ).hide();
				}
				if (hotelSelected == 'true') {
					loadPayments(traveler, 'hotel');
					$( "#hotelSpinner" ).hide();
				}
				if (vehicleSelected == 'true') {
					loadCarPayments(traveler);
					$( "#carSpinner" ).hide();
				}
			}
		});
	}

	// On change find the other traveler's data
	$( "#userID" ).on('change', function() {

		var userID = $( "#userID" ).val();
		var isGuest = (userID == 0);
		
		//console.log('userID onChange()...');
		//console.log(userID);

		$( "#airSpinner" ).show();
		$( "#hotelSpinner" ).show();
		$( "#carSpinner" ).show();
		$( "#serviceFeeSpinner" ).show();
		$.ajax({type:"POST",
			url: 'RemoteProxy.cfc?method=loadFullUser',
			data: 	{
						  acctID : acctID
						, userID : userID
						, arrangerID : arrangerID
						, vendor : $( "#vendor" ).val()
					},
			dataType: 'json',
			success:function(traveler) {

				//console.log('userID onChange()...response');
				//console.log(traveler);

				loadTraveler(traveler, 'change');
				$( "#orgUnits" ).html('');
				for( var i=0, l=traveler.orgUnit.length; i<l; i++ ) {
					if (isGuest && traveler.orgUnit[i].OUID == 925) { // Employee ID
						traveler.orgUnit[i].valueReport = traveler.orgUnit[i].OUDefault;
					}
					createForm(traveler.orgUnit[i]);
				}
				if (acctID == 348) {
					$( "#custom" ).trigger('change');
					for( var i=0, l=traveler.orgUnit.length; i<l; i++ ) {
						$( "#" + traveler.orgUnit[i].OUType + traveler.orgUnit[i].OUPosition ).val( traveler.orgUnit[i].valueID );
					}
				}
				if (airSelected == 'true') {
					loadPayments(traveler, 'air');
					showUnusedTickets(traveler.unusedTicket, traveler.bookingDetail.unusedTickets);
					$( "#airSpinner" ).hide();
				}
				if (hotelSelected == 'true') {
					loadPayments(traveler, 'hotel');
					$( "#hotelSpinner" ).hide();
				}
				if (vehicleSelected == 'true') {
					loadCarPayments(traveler);
					$( "#carSpinner" ).hide();
				}
				if (serviceFeesSelected == 'true') {
					loadPayments(traveler, 'serviceFee');
					$( "#serviceFeeSpinner" ).hide();
				}
			}
		});
	});

	function showUnusedTickets(unusedTickets, selectedUnusedTickets) {
		var unusedticketsHTML = '';
		var displayUnusedTickets = 0;

		for( var i=0, l=unusedTickets.length; i<l; i++ ) {
			if ( platingcarrier == unusedTickets[i].carrier ) {
				displayUnusedTickets = 1;
			}
		}

		$( "#unusedtickeverbiage" ).hide();

		if (displayUnusedTickets == 1) {
			unusedticketsHTML += 'You have unused ticket credits on this airline.<br>';
			unusedticketsHTML += '<small>Check below if you would like a Travel Consultant to review the airline\'s re-use rules to determine if your credit can be applied to this ticket.';
			if (airAgentFee != 0){
				unusedticketsHTML += 'A $'+airAgentFee.toFixed(2)+' Travel Consultant booking fee will apply.</small>';
			}
			unusedticketsHTML += '</small>';
			unusedticketsHTML += '<table class="rwd-table rwd-table-left" width="100%"><tr><th></th><th><small>Airline</small></th><th><small>Credit Value</small></th><th><small>Expires</small></th><th><small>Original Ticket Issued To</small></th></tr>';

			for( var i=0, l=unusedTickets.length; i<l; i++ ) {
				if ( platingcarrier == unusedTickets[i].carrier ) {
					var checked = '';
					if (selectedUnusedTickets.indexOf(unusedTickets[i].id) >= 0) {
						var checked = 'checked';
					}
					var d = new Date(unusedTickets[i].expirationDate);
					unusedticketsHTML += '<tr class="details">'
					unusedticketsHTML += '<td data-th="Use this Credit"><input type="radio" name="unusedtickets" class="unusedtickets" id="unusedticketsID" value="'+unusedTickets[i].id+'" '+checked+'></td>'
					unusedticketsHTML += '<td data-th="Airline"><small>'+unusedTickets[i].carrierName+'</small></td>'
					unusedticketsHTML += '<td data-th="Credit Value"><small>$'+unusedTickets[i].airfare.toFixed(2)+'</small></td>'
					unusedticketsHTML += '<td data-th="Expires"><small>'+(d.getUTCMonth()+1)+'/'+d.getDate()+'/'+d.getFullYear()+'</small></td>'
					unusedticketsHTML += '<td data-th="Original Ticket Issued to"><small>'+unusedTickets[i].lastName+'/'+unusedTickets[i].firstName+'</small></td>'
					unusedticketsHTML += '</tr>'
				}
			}
			unusedticketsHTML += '<tr class="details">'
			unusedticketsHTML += '<td class="no-label"><input type="radio" name="unusedtickets" class="unusedtickets" id="unusedticketsID" value="" checked><small class="visible-xs-inline"> No, I do not want to apply unused ticket credits to this purchase</small></td>'
			unusedticketsHTML += '<td class="no-label hidden-xs" colspan="4" style="font-weight:normal"><small>No, I do not want to apply unused ticket credits to this purchase.</small></td>'
			unusedticketsHTML += '</tr>'
			unusedticketsHTML += '</table>';

			$( "#unusedTicketsDiv" ).removeClass('hide');
			$( "#unusedTicketsDiv" ).html( unusedticketsHTML );
		}
		else {
			$( "#unusedTicketsDiv" ).addClass('hide');
			$( "#unusedTicketsDiv" ).html( '<input type="radio" name="unusedtickets" class="unusedtickets" id="unusedticketsID" value="" checked>' );
		}
	}
	// On change find the other traveler number's data
	/* $( "#travelNumberType" ).on('change', function() {
		$.ajax({
			type: "POST",
			url: "RemoteProxy.cfc?method=getUserTravelerNumber",
			data: 	{
						userID: $( "#userID" ).val()
						, travelNumberType: $( "#travelNumberType" ).val()
					},
			dataType: "text",
			success:function(travelerNumber) {
				$( "#travelNumber" ).val(travelerNumber);
			}
		});
	}); */

	$("#createProfileDiv").on("click", function () {
		var $checkbox = $(this).find(':checkbox');
		if ($checkbox.prop('checked')) {
			$("#usernameDiv").show();
		}
		else {
			$("#usernameDiv").hide();
		}
	});

	$("#hotelNotBooked").on("change", function() {
		var hotelReason = $("#hotelNotBooked").val();
		if (hotelReason == 'H' || hotelReason == 'I' || hotelReason == 'J') {
			$("#hotelWhereStayingDiv").show();
		}
		else {
			$("#hotelWhereStayingDiv").hide();
		}
	});

	function loadTraveler(traveler, loadMethod) {
		$( "#createProfileDiv" ).hide();
		$( "#usernameDiv" ).hide();
		$( "#userID" ).val( traveler.userId );
		if ($( "#userID" ).val() == null) {
			$( "#userID" ).val(0);
		}
		if (findit == 1) {
			$( "#nameChange" ).hide();
		}
		$( "#firstName" ).val( traveler.firstName );
		$( "#middleName" ).val( traveler.middleName );
		if (traveler.noMiddleName == 1) {
			$( "#noMiddleName" ).attr( 'checked', true );
		}
		else {
			$( "#noMiddleName" ).attr( 'checked', false );

		}
		if (traveler.bookingDetail.saveProfile == 1) {
			$( "#saveProfile" ).attr( 'checked', true );
		}
		else {
			$( "#saveProfile" ).attr( 'checked', false );
		}
		if (traveler.bookingDetail.createProfile == 1 && $("#userID") == 0) {
			$( "#createProfileDiv" ).show();
			$( "#createProfile" ).attr( 'checked', true );
			$( "#usernameDiv" ).show();
			$( "#username" ).val( traveler.bookingDetail.username );
			$( "#username_disabled" ).val( traveler.bookingDetail.username );
			$( "#password" ).val( traveler.bookingDetail.password );
			$( "#passwordConfirm" ).val( traveler.bookingDetail.password );
		}
		$( "#lastName" ).val( traveler.lastName );
		$( "#suffix" ).val( traveler.suffix );
		if ($( "#userID" ).val() != 0) {
			if (finditOA) {
				$( "#userIDDiv" ).hide();
				$( "#saveProfileDiv" ).hide();
			}
			else {
				// $( "#firstName" ).prop('disabled', true);
				$( "#lastName" ).prop('disabled', true);
				if (traveler.middleName != undefined && traveler.middleName.length >= 2) {
					$( "#fullNameDiv" ).hide();
				}
				else {
					$( "#fullNameDiv" ).show();
				}
			}
			if (traveler.stoDefaultUser == 1) {
				$( "#userIDDiv" ).hide();
				$( "#firstName" ).prop('disabled', false);
				$( "#lastName" ).prop('disabled', false);
				$( "#saveProfileDiv" ).hide();
				$( "#createProfileDiv" ).hide();
			}
		}
		else {
			$( "#fullNameDiv" ).show();
			$( "#firstName" ).prop('disabled', false);
			$( "#lastName" ).prop('disabled', false);
			$( "#saveProfileDiv" ).hide();
		}
		/* If the first name contains a space and the middle name is blank, show nameCheckDiv */
		if (traveler.firstName != undefined && traveler.firstName.indexOf(' ') >= 0 && (traveler.middleName == undefined || traveler.middleName == '')) {
			$( "#nameCheckDiv" ).show();
		}
		$( "#phoneNumber" ).val( traveler.phoneNumber );
		$( "#wirelessPhone" ).val( traveler.wirelessPhone );
		$( "#email" ).val( traveler.email );
		$( "#ccEmails" ).val( traveler.ccEmails );
		var birthdate = new Date( traveler.birthdate );
		$( "#month" ).val( birthdate.getUTCMonth()+1 );
		$( "#day" ).val( birthdate.getUTCDate() );
		$( "#year" ).val( birthdate.getYear()+1900 );
		$( "#gender" ).val( traveler.gender );
		$( "#redress" ).val( traveler.redress );
		$( "#travelNumber" ).val( traveler.travelNumber );
		// $( "#travelNumberType" ).val( traveler.travelNumberType );

		// If an unregistered FindIt guest
		if (findit == 1 && $("#userID").val() == 0) {
			$( "#userIDDiv" ).hide();
			$( "#saveProfileDiv" ).hide();

			$.ajax({type: "POST",
				url: "RemoteProxy.cfc?method=loadFindItGuest",
				data: "searchID="+searchID,
				dataType: "json",
				success:function(data) {
					if (data['DATA'].length) {
						$( "#createProfileDiv" ).show();
						if (traveler.bookingDetail.createProfile == 1) {
							$( "#createProfile" ).attr( 'checked', true );
							$( "#usernameDiv" ).show();
							$( "#password" ).val( traveler.bookingDetail.password );
							$( "#passwordConfirm" ).val( traveler.bookingDetail.password );
						}
						else {
							$( "#createProfile" ).attr( 'checked', false );
						}

						guestEmail = data['DATA'][0][4];
						$("#email").val(guestEmail);
						$("#username").val(guestEmail);
						$("#username_disabled").val(guestEmail);
					}
				}
			});
		}

		if (airSelected == 'true') {
			if (traveler.bookingDetail.airNeeded == '' || traveler.bookingDetail.airNeeded == 1)  {
				$( "#airNeeded" ).attr( 'checked', true );
				$( "#airDiv" ).show();
				$( "#airTotalRow" ).show();
			}
			else {
				$( "#airNeeded" ).attr( 'checked', false );
				$( "#airDiv" ).hide();
				$( "#airTotalRow" ).hide();
				$( "#airPayment" ).hide()
			}
			$( "#airReasonCode" ).val( traveler.bookingDetail.airReasonCode );
			$( "#lostSavings" ).val( traveler.bookingDetail.lostSavings );
			$( "#udid113" ).val( traveler.bookingDetail.udid113 );
			$( "#specialNeeds" ).val( traveler.specialNeeds );
			$( "#specialRequests" ).val( traveler.bookingDetail.specialRequests );
			$( "#windowAisle" ).val( traveler.windowAisle );
			$( "#hotelNotBooked" ).val( traveler.bookingDetail.hotelNotBooked );

			for( var c=0, cl=carriers.length; c<cl; c++ ) {
				$( "#airFF" + carriers[c] ).val( '' );
				for( var i=0, l=traveler.loyaltyProgram.length; i<l; i++ ) {
					if (traveler.loyaltyProgram[i] !== null) {
						if (traveler.loyaltyProgram[i].shortCode == carriers[c] && traveler.loyaltyProgram[i].custType == 'A') {
							$( "#airFF" + carriers[c] ).val( traveler.loyaltyProgram[i].acctNum );
						}
					}
				}
			}
			var seatFieldNames = $( "#seatFieldNames" ).val();
				seatFieldNames = seatFieldNames.split(',');
			for( var c=0, cl=seatFieldNames.length; c<cl; c++ ) {
				if (traveler.bookingDetail.seats[seatFieldNames[c]] !== undefined) {
					$( "#" + seatFieldNames[c] + "_display" ).html( traveler.bookingDetail.seats[seatFieldNames[c]] );
					$( "#" + seatFieldNames[c] ).val( traveler.bookingDetail.seats[seatFieldNames[c]] );
				}
			}
		}
		else {
			$( "#airNeeded" ).attr( 'checked', false );
		}

		if (hotelSelected == 'true') {
			if (traveler.bookingDetail.hotelNeeded == '' || traveler.bookingDetail.hotelNeeded == 1)  {
				$( "#hotelNeeded" ).attr( 'checked', true );
				$( "#hotelDiv" ).show();
				$( "#hotelTotalRow" ).show();
			}
			else {
				$( "#hotelNeeded" ).attr( 'checked', false );
				$( "#hotelDiv" ).hide();
				$( "#hotelTotalRow" ).hide();
				$( "#hotelPayment" ).hide()
			}
			$( "#hotelReasonCode" ).val( traveler.bookingDetail.hotelReasonCode );
			$( "#udid112" ).val( traveler.bookingDetail.udid112 );
			$( "#hotelSpecialRequests" ).val( traveler.bookingDetail.hotelSpecialRequests );
			$( "#hotelFF" ).val( '' );
			for( var i=0, l=traveler.loyaltyProgram.length; i<l; i++ ) {
				if (traveler.loyaltyProgram[i] !== null) {
					// Use the master chain loyalty number first
					if (traveler.loyaltyProgram[i].shortCode == masterChainCode && traveler.loyaltyProgram[i].custType == 'H') {
						$( "#hotelFF" ).val( traveler.loyaltyProgram[i].acctNum );
					}
					else if ($( "#hotelFF" ).val() == '' && traveler.loyaltyProgram[i].shortCode == chainCode && traveler.loyaltyProgram[i].custType == 'H') {
						$( "#hotelFF" ).val( traveler.loyaltyProgram[i].acctNum );
					}
				}
			}
		}
		else {
			$( "#hotelNeeded" ).attr( 'checked', false );
		}

		if (vehicleSelected == 'true') {
			if (traveler.bookingDetail.carNeeded == '' || traveler.bookingDetail.carNeeded == 1)  {
				$( "#carNeeded" ).attr( 'checked', true );
				$( "#carDiv" ).show();
				$( "#carTotalRow" ).show();
			}
			else {
				$( "#carNeeded" ).attr( 'checked', false );
				$( "#carDiv" ).hide();
				$( "#carTotalRow" ).hide();
				$( "#carPayment" ).hide()
			}

			$( "#carReasonCode" ).val( traveler.bookingDetail.carReasonCode );
			$( "#udid111" ).val( traveler.bookingDetail.udid111 );

			$( "#carFF" ).val( '' );
			for( var i=0, l=traveler.loyaltyProgram.length; i<l; i++ ) {
				if (traveler.loyaltyProgram[i] !== null) {
					if (traveler.loyaltyProgram[i].shortCode == vendor && traveler.loyaltyProgram[i].custType == 'C') {
						$( "#carFF" ).val( traveler.loyaltyProgram[i].acctNum );
					}
				}
			}
		}
		else {
			$( "#carNeeded" ).attr( 'checked', false );
		}

		if (acctID == 348 && (airSelected == 'true' || vehicleSelected == 'true')) {
			$( "#hotelNotBooked" ).val( traveler.bookingDetail.hotelNotBooked );
			if ($( "#hotelNotBooked" ).val() != '' && $( "#hotelNotBooked" ).val() != 'K' ) {
				$( "#hotelWhereStayingDiv" ).show();
				$( "#hotelWhereStaying" ).val( traveler.bookingDetail.hotelWhereStaying );
			}
		}
		recalculateTotal();

	}

	function createForm(orgunit) {
		if (orgunit.OUDisplay == 1) {
			var userID =  $( "#userID" ).val(); 
			var inputName = orgunit.OUType + orgunit.OUPosition;

			// special case for C1: things that are "visble", which really means added to the form
			// and also non-updateable, shall be hidden from view altogether
			var hideVisibleAndNotEditable = (orgunit.acctID == 581 && orgunit.OUUpdate != '1');
			if (hideVisibleAndNotEditable) {
				var hidden = ' hidden';
			} else {
				var hidden = '';
			}

			var div = '<div class="form-group'+hidden;
			if ($.inArray(inputName, errors.split(",")) >= 0) {
				div += ' error';
			}
			div += '">';

			if (orgunit.OUSTOVerbiage != '') {
				div += '<p>' + orgunit.OUSTOVerbiage + '</p>'
			}

			div += '<label class="control-label col-sm-4 col-xs-12" for="' + inputName + '">' + orgunit.OUName;
			if (orgunit.OURequired == 1  || (orgunit.OURequiredGuestOnly ==1 && userID == 0) || (orgunit.OURequiredProfileOnly ==1 && userID != 0)) {
				div += ' *</label>';
			}
			else {
				div += '&nbsp;&nbsp;</label>';
			}
			div += '<div class="controls col-sm-8 col-xs-12">';
			if ((orgunit.OUFreeform == 1 && orgunit.OUUpdate == '1') || (orgunit.OUFreeform == 1 && orgunit.OUUpdate != '1' && orgunit.valueReport == '')){
				div += '<input class="form-control" type="text" name="' + inputName + '" id="' + inputName + '" maxlength="' + orgunit.OUMax + '" value="' + orgunit.valueReport + '">';
			}
			else if(orgunit.OUFreeform == 1 && orgunit.OUUpdate != '1'){
				div += '<span>'+orgunit.valueReport+'</span>';
				div += '<input type="hidden" name="' + inputName + '" id="' + inputName + '" value="' + orgunit.valueReport + '">';
			}
			else if((orgunit.OUFreeform == 0 && orgunit.OUUpdate == '1') || (orgunit.OUFreeform == 0 && orgunit.OUUpdate != '1' && orgunit.valueID == '')) {
				div += '<select class="form-control" name="' + inputName + '" id="' + inputName + '"';
				div += '>';
				div += '<option value="-1"></option>';
					if (orgunit.ouValues.length) {
						for( var i=0, l=orgunit.ouValues.length; i<l; i++ ) {
							div += '<option value="' + orgunit.ouValues[i].valueID + '">' + orgunit.ouValues[i].valueDisplay + '</option>';
						}
					}
					else {
						div += '<option value="' + orgunit.valueID + '">' + orgunit.valueDisplay + '</option>';
					}
				div += '</select>';
			}
			else if(orgunit.OUFreeform == 0 && orgunit.OUUpdate != '1') {
				div += '<span>'+orgunit.valueDisplay+'</span>';
				div += '<input type="hidden" name="' + inputName + '" id="' + inputName + '" value="' + orgunit.valueID + '">';
			}
			div += '</div>';
			div += '</div>';
			$( "#orgUnits" ).append( div );
			if ((orgunit.OUFreeform == 1 && orgunit.OUUpdate == '1') || (orgunit.OUFreeform == 1 && orgunit.OUUpdate != '1' && orgunit.valueReport == '')) {
				$( "#" + inputName ).val( orgunit.valueReport );
			}
			else if ((orgunit.OUFreeform == 0 && orgunit.OUUpdate == '1') || (orgunit.OUFreeform == 0 && orgunit.OUUpdate != '1' && orgunit.valueID == '')) {
				$( "#" + inputName ).val( orgunit.valueID );
				if(inputName == 'custom' && acctID != 1 && arrangerAdmin != 1 && arrangerSTMEmployee != 1 && orgunit.valueID != '' && orgunit.valueID != 0 && orgunit.valueID != -1){
					$( "#" + inputName ).attr( "disabled", true );
				}
			}
		}
	 

	return false;
	}

	function loadPayments(traveler, typeOfService) {
		var payments = traveler.payment
		$( "#" + typeOfService + "FOPID" ).html('')
		$( "#" + typeOfService + "FOPIDDiv" ).show();
		var manualEntry = 1;
		for( var i=0, l=traveler.payment.length; i<l; i++ ) {
			if (traveler.payment[i][typeOfService + 'Use'] == true) {
				if (traveler.payment[i].exclusive == 1) {
					manualEntry = 0;
				}
			}
		}
		var personalCardOnFile = 0
		for( var i=0, l=traveler.payment.length; i<l; i++ ) {
			if (traveler.payment[i][typeOfService + 'Use'] == true) {
				if (traveler.payment[i].fopDescription == '') {
					traveler.payment[i].fopDescription = traveler.firstName + ' ' + traveler.lastName;
				}
				var selected = '';
				var endingIn = '';
				if (traveler.payment[i].acctNum4 != '') {
					endingIn = ' ending in ' + traveler.payment[i].acctNum4;
				}
				if (traveler.payment[i].btaID !== '') {
					$( "#" + typeOfService + "FOPID" ).append('<option value="bta_' + traveler.payment[i].pciID + '">' + traveler.payment[i].fopDescription + endingIn + '</option>')
					if (acctID != 255) {
						if (traveler.payment[i].btaAirUse == 'R') {
							$( "#addAirCC" ).hide();
						}
						if (traveler.payment[i].btaHotelUse == 'R') {
							$( "#addHotelCC" ).hide();
						}
						if (traveler.payment[i].btaServiceFeeUse == 'R') {
							$( "#addServiceFeeCC" ).hide();
						}
					}
				}
				else if (traveler.payment[i].fopID !== '') {
					if (traveler.payment[i].userID == traveler.userId) {
						personalCardOnFile = 1
					}
					var todaysDate = new Date();
					var expirationDate = new Date(traveler.payment[i].expireDate);
					if (expirationDate < todaysDate) {
						$( "#" + typeOfService + "FOPID" ).append('<option class="red" value="fop_' + traveler.payment[i].pciID + '">*EXPIRED!* - ' + traveler.payment[i].fopDescription + endingIn + '</option>')
					}
					else {
						$( "#" + typeOfService + "FOPID" ).append('<option value="fop_' + traveler.payment[i].pciID + '">' + traveler.payment[i].fopDescription + endingIn + '</option>')
					}
				}
			}
		}
		/* if (manualEntry == 1) {
			$( "#" + typeOfService + "FOPID" ).append('<option value="0">Enter a new card</option>')
		} */
		$( "#" + typeOfService + "FOPID" ).val( traveler.bookingDetail[typeOfService + 'FOPID'] );
		if ($( "#" + typeOfService + "FOPID" ).val() === null) {
			$( "#" + typeOfService + "FOPID" ).append('<option value="0"></option>')
		}
		var showNewCard = 0;
		var capitalizedTypeOfService = typeOfService.charAt(0).toUpperCase() + typeOfService.substring(1);
		var newCC = "new" + capitalizedTypeOfService + "CC";
		var newCCID = "new" + capitalizedTypeOfService + "CCID";
		$( "#new" + capitalizedTypeOfService + "CC" ).val( traveler.bookingDetail[newCC] );
		$( "#new" + capitalizedTypeOfService + "CCID" ).val( traveler.bookingDetail[newCCID] );
		if ($( "#new" + capitalizedTypeOfService + "CC" ).val() == 1) {
			showNewCard = 1;
			$( "#add" + capitalizedTypeOfService + "CC" ).hide();
			$( "#remove" + capitalizedTypeOfService + "CC" ).show();
		}
		if ($( "#" + typeOfService + "FOPID" ).val() == 0 || showNewCard == 1) {
			$( "#" + typeOfService + "FOPIDDiv" ).hide();
			if ($( "#" + typeOfService + "FOPID" ).val() == 0) {
				// $( "#" + typeOfService + "NewCard" ).hide();
			}
			if (showNewCard == 0) {
				$( "#" + typeOfService + "Manual" ).hide();
			}
			else {
				$( "#" + typeOfService + "Manual" ).show();
			}
			$( "#" + typeOfService + "CCName" ).val( traveler.bookingDetail[typeOfService + 'CCName'] );
			$( "#" + typeOfService + "CCType" ).val( traveler.bookingDetail[typeOfService + 'CCType'] );
			$( "#" + typeOfService + "CCNumber" ).val( traveler.bookingDetail[typeOfService + 'CCNumber'] );
			$( "#" + typeOfService + "CCNumberRight4" ).val( traveler.bookingDetail[typeOfService + 'CCNumberRight4'] );
			$( "#" + typeOfService + "CCExpiration" ).val( traveler.bookingDetail[typeOfService + 'CCExpiration'] );
			$( "#" + typeOfService + "CCMonth" ).val( traveler.bookingDetail[typeOfService + 'CCMonth'] );
			var displayMonth = $( "#" + typeOfService + "CCMonth" ).val() - 1;
			$( "#" + typeOfService + "CCMonthDisplay" ).val( monthNames[displayMonth] );
			$( "#" + typeOfService + "CCYear" ).val( traveler.bookingDetail[typeOfService + 'CCYear'] );
			$( "#" + typeOfService + "CCCVV" ).val( traveler.bookingDetail[typeOfService + 'CCCVV'] );
			$( "#" + typeOfService + "BillingName" ).val( traveler.bookingDetail[typeOfService + 'BillingName'] );
			if (typeOfService == 'air') {
				$( "#" + typeOfService + "BillingAddress" ).val( traveler.bookingDetail[typeOfService + 'BillingAddress'] );
				$( "#" + typeOfService + "BillingCity" ).val( traveler.bookingDetail[typeOfService + 'BillingCity'] );
				$( "#" + typeOfService + "BillingState" ).val( traveler.bookingDetail[typeOfService + 'BillingState'] );
				$( "#" + typeOfService + "BillingZip" ).val( traveler.bookingDetail[typeOfService + 'BillingZip'] );
			}
			else {
				if (traveler.bookingDetail.airNeeded == 1 && $( "#newAirCC" ).val() == 1 && $( "#newHotelCC" ).val() != 1) {
					$( "#hotelManual" ).show();
					$( "#copyAirCCDiv" ).show();
					if (traveler.bookingDetail.copyAirCC == 1 && traveler.bookingDetail.hotelFOPID == 0) {
						$( "#copyAirCC" ).attr( 'checked', true );
					}
					else {
						$( "#copyAirCC" ).attr( 'checked', false );
					}
				}
				else {
					$( "#copyAirCCDiv" ).hide();
				}
			}
		}
		else if (typeOfService == 'hotel' && airSelected && traveler.bookingDetail['newAirCCID'] != 0 && $( "#newHotelCCID" ).val() == 0) {
			$( "#hotelManual" ).show();
			$( "#copyAirCCDiv" ).show();
			if (traveler.bookingDetail.copyAirCC == 1 && traveler.bookingDetail.hotelFOPID == 0) {
				$( "#copyAirCC" ).attr( 'checked', true );
			}
			else {
				$( "#copyAirCC" ).attr( 'checked', false );
			}
		}
		else {
			$( "#" + typeOfService + "Manual" ).hide();
		}
	}

	function loadCarPayments(traveler) {
		$( "#carFOPID" ).html('')
		//$( "#carFOPID" ).append('<option value=""></option>')
		var optionShow = false;
		for( var i=0, l=traveler.payment.length; i<l; i++ ) {
			if (traveler.payment[i].directBillNumber != '' || traveler.payment[i].corporateDiscountNumber != '') {
				if (traveler.payment[i].carUse == true) {
					if (traveler.payment[i].directBillNumber != '') {
						$( "#carFOPID" ).append('<option value="DB_' + traveler.payment[i].directBillNumber + '">' + traveler.payment[i].fopDescription + '</option>')
						optionShow = true;
					}
					if (traveler.payment[i].corporateDiscountNumber != '') {
						$( "#carFOPID" ).append('<option value="CD_' + traveler.payment[i].corporateDiscountNumber + '">Present your credit card at the pick-up counter</option>')
						optionShow = true;
					}
				}
			}
		}
		if (optionShow == false) {
			$( "#carFOPID" ).append('<option value="0">Present your credit card at the pick-up counter</option>')
		}
		
		if (traveler.bookingDetail.carFOPID.length) {
			$( "#carFOPID" ).val( traveler.bookingDetail.carFOPID );
		}
	}

	function recalculateTotal() {
		var total = 0;
		var fee = 0;
		if (hotelSelected && $( "#hotelNeeded" ).attr( 'checked' ) ) {
			total += parseFloat( $( "#hotelTotal" ).val() )
			fee = auxFee;
		}
		if (vehicleSelected && $( "#carNeeded" ).attr( 'checked' ) ) {
			total += parseFloat( $( "#carTotal" ).val() )
			fee = auxFee;
		}
		if ( airSelected && $( "#airNeeded" ).attr( 'checked' ) ) {
			total += parseFloat( $( "#airTotal" ).val() )
			fee = airFee;
		}
		if ( $( "#specialRequests" ).val() != '' && $( "#specialRequests" ).val() != undefined) {
			fee = requestFee;
		}

		$( "#unusedtickeverbiage" ).hide();
		if ($( "input[name=unusedtickets]:checked" ).val() != undefined && $( "input[name=unusedtickets]:checked" ).val() != 0) {
			$( "#unusedtickeverbiage" ).show();
			fee = airAgentFee;
		}

		if (fee == 0) {
			$( "#bookingFeeRow" ).hide();
		}
		else {
			$( "#bookingFeeRow" ).show();
			$( "#bookingFeeCol" ).html('$'+fee.toFixed(2))
		}
		total += fee;
		$( "#bookingFee" ).val( fee );
		$( "#totalCol" ).html( '<strong>$' + total.toFixed(2) + '</strong>' )
	}

	$("#unusedTicketsDiv").on("click", function () {
		recalculateTotal();
	});

	$( "#specialRequests" ).focusout(function() {
		recalculateTotal();
	})

	$( "#unusedtickets" ).click(function() {
		recalculateTotal();
	})

	$( "#airFOPID" ).change(function() {
		if ($( "#airFOPID" ).val() == 0) {
			$( "#airManual" ).show();
		}
		else {
			$( "#airManual" ).hide();
		}
	})

	$( "#hotelFOPID" ).change(function() {
		if ($( "#hotelFOPID" ).val() == 0) {
			$( "#hotelManual" ).show();
		}
		else {
			$( "#hotelManual" ).hide();
		}
	})

	$( "#airNeeded" ).click(function() {
		if ($( "#airNeeded" ).attr('checked')) {
			$( "#airDiv" ).show()
			$( "#airTotalRow" ).show();
			$( "#airPayment" ).show()
			recalculateTotal();
		}
		else {
			$( "#airDiv" ).hide()
			$( "#airTotalRow" ).hide();
			$( "#airPayment" ).hide()
			recalculateTotal();
		}
	})

	$( "#hotelNeeded" ).click(function() {
		if ($( "#hotelNeeded" ).attr('checked')) {
			$( "#hotelDiv" ).show()
			$( "#hotelTotalRow" ).show();
			$( "#hotelPayment" ).show()
			recalculateTotal();
		}
		else {
			$( "#hotelDiv" ).hide()
			$( "#hotelTotalRow" ).hide();
			$( "#hotelPayment" ).hide()
			recalculateTotal();
		}
	})

	$( "#carNeeded" ).click(function() {
		if ($( "#carNeeded" ).attr('checked')) {
			$( "#carDiv" ).show()
			$( "#carTotalRow" ).show();
			$( "#carPayment" ).show()
			recalculateTotal();
		}
		else {
			$( "#carDiv" ).hide('slow')
			$( "#carTotalRow" ).hide();
			$( "#carPayment" ).hide()
			recalculateTotal();
		}
	})

	$( "#copyAirCC" ).on("click", function () {
		if ($(this).prop('checked')) {
			$( "#newHotelCC" ).val( $( "#newAirCC" ).val() );
			$( "#newHotelCCID" ).val( $( "#newAirCCID" ).val() );
			$( "#hotelFOPID" ).val( $( "#airFOPID" ).val() );
			$( "#hotelCCName" ).val( $( "#airCCName" ).val() );
			$( "#hotelCCType" ).val( $( "#airCCType" ).val() );
			$( "#hotelCCNumber" ).val( $( "#airCCNumber" ).val() );
			$( "#hotelCCNumberRight4" ).val( $( "#airCCNumberRight4" ).val() );
			$( "#hotelCCExpiration" ).val( $( "#airCCExpiration" ).val() );
			$( "#hotelCCMonth" ).val( $( "#airCCMonth" ).val() );
			$( "#hotelCCMonthDisplay" ).val( $( "#airCCMonthDisplay" ).val() );
			$( "#hotelCCYear" ).val( $( "#airCCYear" ).val() );
			$( "#hotelBillingName" ).val( $( "#airBillingName" ).val() );
			var hotelCCMonthYear = $( "#airCCMonthDisplay" ).val() + ' ' + $( "#airCCYear" ).val();
			$( "#copyAirCCNumber" ).html( $( "#airCCNumber" ).val() );
			$( "#copyAirCCMonthYear" ).html( hotelCCMonthYear );
			$( "#copyAirBillingName" ).html( $( "#airBillingName" ).val() );
		}
		else {
			$( "#newHotelCC" ).val( 0 );
			$( "#newHotelCCID" ).val( 0 );
			$( "#hotelFOPID" ).val( 0 );
			$( "#hotelCCName" ).val( '' );
			$( "#hotelCCType" ).val( '' );
			$( "#hotelCCNumber" ).val( '' );
			$( "#hotelCCNumberRight4" ).val( '' );
			$( "#hotelCCExpiration" ).val( '' );
			$( "#hotelCCMonth" ).val( '' );
			$( "#hotelCCMonthDisplay" ).val( '' );
			$( "#hotelCCYear" ).val( '' );
			$( "#hotelBillingName" ).val( '' );
			$( "#copyAirCCNumber" ).html( '' );
			$( "#copyAirCCMonthYear" ).html( '' );
			$( "#copyAirBillingName" ).html( '' );
		}
	})

	//NASCAR custom code for conditional logic for sort1/second org unit displayed/department number
	if (acctID == 348) {

		$( "#orgUnits" ).on('change', '#custom', function() {
			var custom = $( "#custom" ).val();
			$.ajax({type:"POST",
				url: 'RemoteProxy.cfc?method=getOrgUnitValues',
				data: 	{
							  ouID : 400
							, conditionalSort1 : custom
						},
				dataType: 'json',
				success:function(values) {
					var originalValue = $( "#sort1" ).val();
					$( "#sort1" ).html('');
					$( "#sort1" ).append('<option value="0"></option>');
					for( var i=0, l=values.length; i<l; i++ ) {
						$( "#sort1" ).append('<option value="' + values[i].valueID + '">' + values[i].valueDisplay + '</option>');
					}
					$( "#sort1" ).val( originalValue );
					$( "#sort1" ).trigger( "change" );
				}
			});

			$.ajax({type:"POST",
				url: 'RemoteProxy.cfc?method=updateTravelerCompany',
				data: 	{
							  userID : $("#userID").val()
							, acctID : acctID
							, arrangerID : arrangerID
							, searchID : searchID
							, travelerNumber : travelerNumber
							, valueID : custom
							, vendor : vendor
						},
				dataType: 'json',
				success:function(traveler) {
					$( "#airSpinner" ).show();
					$( "#hotelSpinner" ).show();
					$( "#carSpinner" ).show();

					if (airSelected == 'true') {
						loadPayments(traveler, 'air');
						$( "#airSpinner" ).hide();
					}
					if (hotelSelected == 'true') {
						loadPayments(traveler, 'hotel');
						$( "#hotelSpinner" ).hide();
					}
					if (vehicleSelected == 'true') {
						loadCarPayments(traveler);
						$( "#carSpinner" ).hide();
					}
				}
			});
		});

		$( "#orgUnits" ).on('change', '#sort1', function() {
			var custom = $( "#custom" ).val();
			var sort1 = $( "#sort1" ).val();
			$.ajax({type:"POST",
				url: 'RemoteProxy.cfc?method=getOrgUnitValues',
				data: 	{
							  ouID : 401
							, conditionalSort1 : custom
							, conditionalSort2 : sort1
						},
				dataType: 'json',
				success:function(values) {
					var originalValue = $( "#sort2" ).val();
					$( "#sort2" ).html('');
					$( "#sort2" ).append('<option value="0"></option>');
					for( var i=0, l=values.length; i<l; i++ ) {
						$( "#sort2" ).append('<option value="' + values[i].valueID + '">' + values[i].valueDisplay + '</option>');
					}
					$( "#sort2" ).val( originalValue );
					$( "#sort2" ).trigger( "change" );
				}
			});
		});

		$( "#orgUnits" ).on('change', '#sort2', function() {
			var custom = $( "#custom" ).val();
			var sort1 = $( "#sort1" ).val();
			var sort2 = $( "#sort2" ).val();
			$.ajax({type:"POST",
				url: 'RemoteProxy.cfc?method=getOrgUnitValues',
				data: 	{
							  ouID : 402
							, conditionalSort1 : custom
							, conditionalSort2 : sort1
							, conditionalSort3 : sort2
						},
				dataType: 'json',
				success:function(values) {
					var originalValue = $( "#sort3" ).val();
					$( "#sort3" ).html('');
					$( "#sort3" ).append('<option value="0"></option>');
					for( var i=0, l=values.length; i<l; i++ ) {
						$( "#sort3" ).append('<option value="' + values[i].valueID + '">' + values[i].valueDisplay + '</option>');
					}
					$( "#sort3" ).val( originalValue );
					$( "#sort3" ).trigger( "change" );
				}
			});
		});

		$( "#orgUnits" ).on('change', '#sort3', function() {
			var custom = $( "#custom" ).val();
			var sort1 = $( "#sort1" ).val();
			var sort2 = $( "#sort2" ).val();
			var sort3 = $( "#sort3" ).val();
			$.ajax({type:"POST",
				url: 'RemoteProxy.cfc?method=getOrgUnitValues',
				data: 	{
							  ouID : 403
							, conditionalSort1 : custom
							, conditionalSort2 : sort1
							, conditionalSort3 : sort2
							, conditionalSort4 : sort3
						},
				dataType: 'json',
				success:function(values) {
					var originalValue = $( "#sort4" ).val();
					$( "#sort4" ).html('');
					$( "#sort4" ).append('<option value="0"></option>');
					for( var i=0, l=values.length; i<l; i++ ) {
						$( "#sort4" ).append('<option value="' + values[i].valueID + '">' + values[i].valueDisplay + '</option>');
					}
					$( "#sort4" ).val( originalValue );
				}
			});
		});
	}
}); // end of jQuery document ready


	// This is a functions that scrolls to #id
function scrollTo(id) {
  $('html,body').animate({scrollTop: $("#"+id).offset().top},'fast');
}

function GetValueFromChild(selectedSegmentSeat) {
 	// tear down modal so we can select another one from seat link
	$('#popupModal').on('hidden', function() {
		$(this).removeData('modal');
	});
	var seatArray = selectedSegmentSeat.split('|');
	// write seat to hidden field
	$("#segment_" + seatArray[0]).val( seatArray[1] );
	// write seat to summary page
 	$("#" + seatArray[0] + " span").text( seatArray[1] );
 	// append seat to url so we can show it selected if they open seatmap again
	var oldLink = $("#" + seatArray[0] + " a").attr( 'href' );
	if(oldLink.indexOf('seat=') > -1) {
		var reExp = new RegExp("[\\?&]" + 'seat' + "=([^&#]*)");
		var dlimeter = reExp.exec(oldLink);
		dlimeter = dlimeter[0].charAt(0);
		var newUrl = oldLink.replace(reExp, dlimeter + 'seat' + "=" + seatArray[1]);
		$("#" + seatArray[0] + " a").attr('href', newUrl);

	} else {
		$("#" + seatArray[0] + " a").attr('href', oldLink + "&seat=" + seatArray[1]);
	}
	// scroll to flight info
 	scrollTo('airDiv');
 }

function formValidated(){
	if ($("#pricelineAgreeTerms").length)
		if(!$("#pricelineAgreeTerms").prop("checked")){
			alert("You must first read and agree to all terms.");
			$("#pricelineAgreeTerms").focus();
			$("#agreeToTermsError").show();
			return false;
		}

	return true;
}

$('#popupModal').on('hidden.bs.modal', function () {
    $(this).removeData('bs.modal');
		$('#popupModal').html($('#defaultPopupContent').html());
});

$( "#purchaseButton" ).on("click", function (e) {
	if(formValidated()){
		$( "#travelerButton" ).attr('disabled', 'disabled');
		$( "#purchaseButton" ).val("Purchasing Reservation...");
		$( "#purchaseButton" ).attr('disabled', 'disabled');
		$( "#triggerButton" ).val("CONFIRM PURCHASE");
		$( "#triggerButton" ).removeAttr('disabled');
		$( "#purchaseForm" ).submit();
	}
	else
		e.preventDefault();
});

/* $("input[type=submit]").click(function() {
	var buttonValue = $(this).attr("value");
	if (buttonValue == 'CONFIRM PURCHASE') {
		if(formValidated()){
			setPurchaseButtons();
			return;
		}
		else
			e.preventDefault();
	}
	else {
		$("#triggerButton").val(buttonValue);
		return;
	}
});

function setPurchaseButtons(){
	$( "#travelerButton" ).attr('disabled', 'disabled');
	$( "#purchaseButton" ).val("Purchasing Reservation...");
	$( "#purchaseButton" ).attr('disabled', 'disabled');
	$( "#triggerButton" ).val("CONFIRM PURCHASE");
	$( "#triggerButton" ).removeAttr('disabled');
} */

$(".displayPaymentModal").click(function() {
	var formData = $("#purchaseForm").serialize();
	$.ajax({
		type: "POST",
		url: "/booking/services/summary.cfc",
		data: {
			method: "setSummaryFormVariables",
			formData: formData,
		}
	});
	var paymentType = $(this).attr("data-paymentType");
	var oldSrc = $("#displayFrameAddress").html();
	oldSrc = oldSrc.replace(/&amp;/g, "&");
	var newSrc = oldSrc + "&paymentType=" + paymentType;
	$("#addIframe").attr("src", newSrc);
	$("#displayPaymentWindow").modal('show');
});

$(".removePaymentModal").click(function() {
	var formData = $("#purchaseForm").serialize();
	$.ajax({
		type: "POST",
		url: "/booking/services/summary.cfc",
		data: {
			method: "setSummaryFormVariables",
			formData: formData,
		}
	});
	var paymentType = $(this).attr("data-paymentType");
	var newFOPID = $(this).attr("data-id");
	var oldSrc = $("#removeFrameAddress").html();
	oldSrc = oldSrc.replace(/&amp;/g, "&");
	var newSrc = oldSrc + "&paymentType=" + paymentType;
	newSrc = newSrc + "&fopID=" + newFOPID;
	$("#removeIframe").attr("src", newSrc);
	$("#removePaymentWindow").modal('show');
});
