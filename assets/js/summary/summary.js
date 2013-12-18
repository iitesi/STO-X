$(document).ready(function(){

	var searchID = $("#searchID").val();
	var acctID = $( "#acctID" ).val();
	var valueID = $( "#valueID" ).val();
	var travelerNumber = $("#travelerNumber").val();
	var airSelected = $( "#airSelected" ).val();
	var carriers = $( "#carriers" ).val();
		carriers = $.parseJSON(carriers);
	var hotelSelected = $( "#hotelSelected" ).val();
	var chainCode = $( "#chainCode" ).val();
	var vehicleSelected = $( "#vehicleSelected" ).val();
	var vendor = $( "#vendor" ).val();
	var arrangerID = $( "#arrangerID" ).val();
	var arrangerAdmin = $( "#arrangerAdmin" ).val();
	var arrangerSTMEmployee = $( "#arrangerSTMEmployee" ).val();
	var errors = $( "#errors" ).val();
	var airFee = parseFloat( $( "#airFee" ).val() );
	var auxFee = parseFloat( $( "#auxFee" ).val() );
	var requestFee = parseFloat( $( "#requestFee" ).val() );

	$( "#createProfileDiv" ).hide();
	$( "#usernameDiv" ).hide();
	getTraveler();

	// Get traveler from session and populate the form
	function getTraveler() {
		$.ajax({type:"POST",
			url: '/booking/RemoteProxy.cfc?method=getSearchTraveler',
			data:	{
						  travelerNumber : travelerNumber
						, searchID : searchID
					},
			dataType: 'json',
			success:function(traveler) {
				loadTraveler(traveler, 'initial');
				$( "#orgUnits" ).html('');
				for( var i=0, l=traveler.orgUnit.length; i<l; i++ ) {
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
	}

	// On change find the other traveler's data
	$( "#userID" ).on('change', function() {
		$( "#airSpinner" ).show();
		$( "#hotelSpinner" ).show();
		$( "#carSpinner" ).show();
		$.ajax({type:"POST",
			url: 'RemoteProxy.cfc?method=loadFullUser',
			data: 	{
						  acctID : acctID
						, userID : $( "#userID" ).val()
						, valueID : valueID
						, arrangerID : arrangerID
					},
			dataType: 'json',
			success:function(traveler) {
				loadTraveler(traveler, 'change');
				$( "#orgUnits" ).html('');
				for( var i=0, l=traveler.orgUnit.length; i<l; i++ ) {
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

	$("#createProfileDiv").on("click", function () { 
		var $checkbox = $(this).find(':checkbox');
		if ($checkbox.prop('checked')) {
			$("#usernameDiv").show();
		}
		else {
			$("#usernameDiv").hide();
		}
	});

	function loadTraveler(traveler, loadMethod) {
		$( "#createProfileDiv" ).hide();
		$( "#usernameDiv" ).hide();
		$( "#userID" ).val( traveler.userId );
		if ($( "#userID" ).val() == null) {
			$( "#userID" ).val(0);
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
		if (traveler.bookingDetail.createProfile == 1) {
			$( "#createProfileDiv" ).show();
			$( "#createProfile" ).attr( 'checked', true );
			$( "#usernameDiv" ).show();
			$( "#username" ).val( traveler.bookingDetail.username );
			$( "#username_disabled" ).val( traveler.bookingDetail.username );
			$( "#password" ).val( traveler.bookingDetail.password );
			$( "#passwordConfirm" ).val( traveler.bookingDetail.password );
		}
		$( "#lastName" ).val( traveler.lastName );
		if ($( "#userID" ).val() != 0) {
			$( "#firstName" ).prop('disabled', true);
			$( "#lastName" ).prop('disabled', true);
			if (traveler.middleName != undefined && traveler.middleName.length >= 2) {
				$( "#fullNameDiv" ).hide();
			}
			else {
				$( "#fullNameDiv" ).show();
			}
			$( "#firstName2" ).val( traveler.firstName );
			$( "#lastName2" ).val( traveler.lastName );
			if (traveler.stoDefaultUser == 1) {
				$( "#userIDDiv" ).hide();
				$( "#firstName" ).prop('disabled', false);
				$( "#lastName" ).prop('disabled', false);
				$( "#saveProfileDiv" ).hide();
				$( "#createProfileDiv" ).hide();
				$( "#firstName2" ).val( '' );
				$( "#lastName2" ).val( '' );
			}
		}
		else {
			$( "#fullNameDiv" ).show();
			$( "#firstName" ).prop('disabled', false);
			$( "#lastName" ).prop('disabled', false);
			$( "#firstName2" ).val( '' );
			$( "#lastName2" ).val( '' );
			$( "#saveProfileDiv" ).hide();
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

		// If a FindIt guest
		if (traveler.firstName == undefined && traveler.stoDefaultUser == 0) {
			$( "#userID" ).val( 0 );
			// $( "#userIDDiv" ).hide();
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

			$( "#hotelFF" ).val( '' );
			for( var i=0, l=traveler.loyaltyProgram.length; i<l; i++ ) {
				if (traveler.loyaltyProgram[i] !== null) {
					if (traveler.loyaltyProgram[i].shortCode == chainCode && traveler.loyaltyProgram[i].custType == 'H') {
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
		recalculateTotal();

	}

	function createForm(orgunit) {
		if (orgunit.OUUpdate != 0 || orgunit.valueID == '' || orgunit.valueReport == '') {
			var inputName = orgunit.OUType + orgunit.OUPosition;
			var div = '<div class="control-group'
			if ($.inArray(inputName, errors.split(",")) >= 0) {
				div += ' error';
			}
			div += '">';
			div += '<label class="control-label" for="' + inputName + '">' + orgunit.OUName;
			if (orgunit.OURequired == 1) {
				div += ' *</label>';
			} 
			else {
				div += '&nbsp;&nbsp;</label>';
			}
			div += '<div class="controls">';
			if (orgunit.OUFreeform == 1) {
				div += '<input type="text" name="' + inputName + '" id="' + inputName + '" maxlength="' + orgunit.OUMax + '" value="' + orgunit.valueReport + '">';
			}
			else {
				div += '<select name="' + inputName + '" id="' + inputName + '"';
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
			div += '</div>';
			div += '</div>';
			$( "#orgUnits" ).append( div );
			if (orgunit.OUFreeform == 1) {
				$( "#" + inputName ).val( orgunit.valueReport );
			}
			else {
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
				if (traveler.payment[i].btaID != '') {
					$( "#" + typeOfService + "FOPID" ).append('<option value="bta_' + traveler.payment[i].btaID + '">' + traveler.payment[i].fopDescription + endingIn + '</option>')
				}
				else if (traveler.payment[i].fopID != '') {
					if (traveler.payment[i].userID == traveler.userId) {
						personalCardOnFile = 1
					}
					$( "#" + typeOfService + "FOPID" ).append('<option value="fop_' + traveler.payment[i].fopID + '">' + traveler.payment[i].fopDescription + endingIn + '</option>')
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
		if (traveler.bookingDetail.newAirCC == 1) {
			$( "#newAirCC" ).attr( 'checked', true );
			showNewCard = 1;
		}
		if (traveler.bookingDetail.newHotelCC == 1) {
			$( "#newHotelCC" ).attr( 'checked', true );
			showNewCard = 1;
		}
		if ($( "#" + typeOfService + "FOPID" ).val() == 0 || showNewCard == 1) {
			$( "#" + typeOfService + "FOPIDDiv" ).hide();
			if ($( "#" + typeOfService + "FOPID" ).val() == 0) {
				$( "#" + typeOfService + "NewCard" ).hide();
			}			
			$( "#" + typeOfService + "Manual" ).show();
			$( "#" + typeOfService + "CCNumber" ).val( traveler.bookingDetail[typeOfService + 'CCNumber'] );
			$( "#" + typeOfService + "CCMonth" ).val( traveler.bookingDetail[typeOfService + 'CCMonth'] );
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
				if (airNeeded == 'false' || $(" #airFOPID").val() != 0) {
					$( "#copyAirCCDiv" ).hide();
				}
				else {
					$( "#copyAirCCDiv" ).show();
					if (traveler.bookingDetail.copyAirCC == 1) {
						$( "#copyAirCC" ).attr( 'checked', true );
					}
					else {
						$( "#copyAirCC" ).attr( 'checked', false );

					}
				}
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
		$( "#carFOPID" ).val( traveler.bookingDetail.carFOPID );
	}

	$(".newCard").on("click", "input[type=checkbox]", function() {
		var airCard = $("#newAirCC");
		var hotelCard = $("#newHotelCC");
		var showAirNewCard = (airCard.attr("checked") == "checked");

		if (this.name == 'newAirCC') {
			if (this.checked) {
				$("#airFOPIDDiv").hide();
				$("#airManual").show();
				$("#copyAirCCDiv").show();
			}
			else {
				$("#airFOPIDDiv").show();
				$("#airManual").hide();
				$("#copyAirCCDiv").hide();
			}
		}
		else if (this.name == 'newHotelCC') {
			if (this.checked) {
				$("#hotelFOPIDDiv").hide();
				$("#hotelManual").show();
				if (showAirNewCard) {
					$("#copyAirCCDiv").show();
				}
			}
			else {
				$("#hotelFOPIDDiv").show();
				$("#hotelManual").hide();
				$("#copyAirCCDiv").hide();
			}
		}
	});

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
		if (fee == 0) {
			$( "#bookingFeeRow" ).hide();
		}
		else {
			$( "#bookingFeeRow" ).show();
		}
		total += fee;
		$( "#totalCol" ).html( '<strong>$' + total.toFixed(2) + '</strong>' )
	}

	$( "#specialRequests" ).focusout(function() {
		recalculateTotal();
	})

	$( "#airFOPID" ).change(function() {
		if ($( "#airFOPID" ).val() == 0) {
			$( "#airManual" ).show()
		}
		else {
			$( "#airManual" ).hide()
		}
	})

	$( "#hotelFOPID" ).change(function() {
		if ($( "#hotelFOPID" ).val() == 0) {
			$( "#hotelManual" ).show()
		}
		else {
			$( "#hotelManual" ).hide()
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

	$( "#copyAirCC" ).click(function() {
		$( "#hotelCCNumber" ).val( $( "#airCCNumber" ).val() );
		$( "#hotelCCMonth" ).val( $( "#airCCMonth" ).val() );
		$( "#hotelCCYear" ).val( $( "#airCCYear" ).val() );
		$( "#hotelBillingName" ).val( $( "#airBillingName" ).val() );
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
					var originalValue = $("#sort1").val();
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
					var originalValue = $("#sort2").val();
					$( "#sort2" ).html('');
					$( "#sort2" ).append('<option value="0"></option>');
					for( var i=0, l=values.length; i<l; i++ ) {
						$( "#sort2" ).append('<option value="' + values[i].valueID + '">' + values[i].valueDisplay + '</option>');
					}
					$( "#sort2" ).val( originalValue );
					$( "#sort2" ).trigger("change");
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
					var originalValue = $("#sort3").val();
					$( "#sort3" ).html('');
					$( "#sort3" ).append('<option value="0"></option>');
					for( var i=0, l=values.length; i<l; i++ ) {
						$( "#sort3" ).append('<option value="' + values[i].valueID + '">' + values[i].valueDisplay + '</option>');
					}
					$( "#sort3" ).val( originalValue );
					$( "#sort3" ).trigger("change");
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
					var originalValue = $("#sort4").val();
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
	$("#" + seatArray[0] + " a").attr('href', oldLink + "&seat=" + seatArray[1]);
	// scroll to flight info
 	scrollTo('airDiv');
 }

$( "#purchaseButton" ).on("click", function (e) {
	$( "#travelerButton" ).attr('disabled', 'disabled');
	$( "#purchaseButton" ).val("Purchasing Reservation...");
	$( "#purchaseButton" ).attr('disabled', 'disabled');
	$( "#triggerButton" ).val("CONFIRM PURCHASE");
	$( "#triggerButton" ).removeAttr('disabled');
	$( "#purchaseForm" ).submit();
});
