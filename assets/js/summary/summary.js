$(document).ready(function(){

	var searchID = $("#searchID").val();
	var acctID = $( "#acctID" ).val();
	var valueID = $( "#valueID" ).val();
	var travelerNumber = $("#travelerNumber").val();
	var airSelected = $( "#airSelected" ).val();
	var carriers = $( "#carriers" ).val();
		carriers = $.parseJSON(carriers)
	var hotelSelected = $( "#hotelSelected" ).val();
	var chainCode = $( "#chainCode" ).val();
	var vehicleSelected = $( "#vehicleSelected" ).val();
	var vendor = $( "#vendor" ).val();
	var arrangerID = $( "#arrangerID" ).val();
	var airFee = parseFloat( $( "#airFee" ).val() );
	var auxFee = parseFloat( $( "#auxFee" ).val() );
	var requestFee = parseFloat( $( "#requestFee" ).val() );

	getTraveler();

	// Get traveler from session and populate the form
	function getTraveler() {
		$.ajax({type:"POST",
			url: 'services/summary.cfc?method=travelerJSON',
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

	function loadTraveler(traveler, loadMethod) {
		console.log(traveler);
		$( "#userID" ).val( traveler.userId );
		$( "#firstName" ).val( traveler.firstName );
		$( "#middleName" ).val( traveler.middleName );
		if (traveler.noMiddleName == 1) {
			$( "#noMiddleName" ).attr( 'checked', true );
		}
		else {
			$( "#noMiddleName" ).attr( 'checked', false );

		}
		if (traveler.bookingDetail.saveProfile == 'true') {
			$( "#saveProfile" ).attr( 'checked', true );
		}
		else {
			$( "#saveProfile" ).attr( 'checked', false );

		}
		$( "#lastName" ).val( traveler.lastName );
		if ($( "#userID" ).val() != 0) {
			if (traveler.middleName.length >= 2) {
				$( "#fullNameDiv" ).hide();
			}
			else {
				$( "#fullNameDiv" ).show();
			}
			$( "#firstName" ).prop('disabled', true);
			$( "#lastName" ).prop('disabled', true);
			$( "#firstName2" ).val( traveler.firstName );
			$( "#lastName2" ).val( traveler.lastName );
			$( "#saveProfileDiv" ).show();
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
		$( "#day" ).val( birthdate.getDate() );
		$( "#year" ).val( birthdate.getYear()+1900 );
		$( "#gender" ).val( traveler.gender );

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
			}
			$( "#airReasonCode" ).val( traveler.bookingDetail.airReasonCode );
			$( "#lostSavings" ).val( traveler.bookingDetail.lostSavings );
			$( "#udid113" ).val( traveler.bookingDetail.udid113 );
			$( "#specialNeeds" ).val( traveler.specialNeeds );
			$( "#specialRequests" ).val( traveler.bookingDetail.specialRequests );

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
			}
			$( "#hotelReasonCode" ).val( traveler.bookingDetail.hotelReasonCode );
			$( "#udid112" ).val( traveler.bookingDetail.udid112 );

			if (loadMethod == 'change') {
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
				$( "#hotelFF" ).val( traveler.bookingDetail.hotelFF );
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
			}

			$( "#carReasonCode" ).val( traveler.bookingDetail.carReasonCode );
			$( "#udid111" ).val( traveler.bookingDetail.udid111 );

			if (loadMethod == 'change') {
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
				$( "#carFF" ).val( traveler.bookingDetail.carFF );
			}
		}
		else {
			$( "#carNeeded" ).attr( 'checked', false );
		}
		recalculateTotal();

	}

	function createForm(orgunit) {

		var inputName = orgunit.OUType + orgunit.OUPosition;
		var div = '<div class="control-group">';
		div += '<label class="control-label" for="' + inputName + '">' + orgunit.OUName + '</label>';
		div += '<div class="controls">';
		if (orgunit.OUFreeform == 1) {
			div += '<input type="text" name="' + inputName + '" id="' + inputName + '" maxlength="' + orgunit.OUMax + '" value="' + orgunit.valueReport + '">';
		}
		else {
			div += '<select name="' + inputName + '" id="' + inputName + '"';
			div += '>';
			div += '<option value="0"></option>';
				for( var i=0, l=orgunit.ouValues.length; i<l; i++ ) {
					div += '<option value="' + orgunit.ouValues[i].valueID + '">' + orgunit.ouValues[i].valueDisplay + '</option>';
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
		}

		return false;
	}

	function loadPayments(traveler, typeOfService) {
		var payments = traveler.payment
		$( "#" + typeOfService + "FOPID" ).html('')
		//$( "#" + typeOfService + "FOPID" ).append('<option value=""></option>')
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
				if (traveler.payment[i].btaID != '') {
					$( "#" + typeOfService + "FOPID" ).append('<option value="bta_' + traveler.payment[i].btaID + '">' + traveler.payment[i].fopDescription + ' ending in ' + payments[i].acctNum + '</option>')
				}
				else if (traveler.payment[i].fopID != '') {
					if (traveler.payment[i].userID == traveler.userId) {
						personalCardOnFile = 1
					}
					$( "#" + typeOfService + "FOPID" ).append('<option value="fop_' + traveler.payment[i].fopID + '">' + traveler.payment[i].fopDescription + ' ending in ' + payments[i].acctNum + '</option>')
				}
			}
		}
		if (manualEntry == 1) {
			$( "#" + typeOfService + "FOPID" ).append('<option value="0">MANUAL ENTRY</option>')
		}
		if (traveler.userId != 0 && traveler.userId != arrangerID && manualEntry == 1 && personalCardOnFile == 0) {
			$( "#" + typeOfService + "SaveCardDiv" ).show();
		}
		else {
			$( "#" + typeOfService + "SaveCardDiv" ).hide();
		}
		$( "#" + typeOfService + "FOPID" ).val( traveler.bookingDetail[typeOfService + 'FOPID'] );
		if ($( "#" + typeOfService + "FOPID" ).val() == 0) {
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
		}
		else {
			$( "#" + typeOfService + "Manual" ).hide();
		}
		if (traveler.bookingDetail[typeOfService + 'SaveCard'] === 0) {
			$( "#" + typeOfService + "SaveCard" ).attr( 'checked', false );
		}
		else {
			$( "#" + typeOfService + "SaveCard" ).attr( 'checked', true );

		}
		$( "#" + typeOfService + "SaveName" ).val( traveler.bookingDetail[typeOfService + 'SaveName'] );
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
						$( "#carFOPID" ).append('<option value="DB_' + traveler.payment[i].corporateDiscountNumber + '">Present your credit card at the pick-up counter</option>')
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
		if ( $( "#specialRequests" ).val() != '') {
			fee = requestFee;
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

	$( "#airSaveCard" ).click(function() {
		if ($( "#airSaveCard" ).attr('checked')) {
			$( "#airSaveNameDiv" ).show()
		}
		else {
			$( "#airSaveNameDiv" ).hide()
		}
	})

	$( "#hotelSaveCard" ).click(function() {
		if ($( "#hotelSaveCard" ).attr('checked')) {
			$( "#hotelSaveNameDiv" ).show()
		}
		else {
			$( "#hotelSaveNameDiv" ).hide()
		}
	})

	$( "#airNeeded" ).click(function() {
		if ($( "#airNeeded" ).attr('checked')) {
			$( "#airDiv" ).show()
			$( "#airTotalRow" ).show();
			recalculateTotal();
		}
		else {
			$( "#airDiv" ).hide()
			$( "#airTotalRow" ).hide();
			recalculateTotal();
		}
	})

	$( "#hotelNeeded" ).click(function() {
		if ($( "#hotelNeeded" ).attr('checked')) {
			$( "#hotelDiv" ).show()
			$( "#hotelTotalRow" ).show();
			recalculateTotal();
		}
		else {
			$( "#hotelDiv" ).hide()
			$( "#hotelTotalRow" ).hide();
			recalculateTotal();
		}
	})

	$( "#carNeeded" ).click(function() {
		if ($( "#carNeeded" ).attr('checked')) {
			$( "#carDiv" ).show()
			$( "#carTotalRow" ).show();
			recalculateTotal();
		}
		else {
			$( "#carDiv" ).hide('slow')
			$( "#carTotalRow" ).hide();
			recalculateTotal();
		}
	})

	//NASCAR custom code for conitional logic for sort1/second org unit displayed/department number
	if (acctID == 348) {

		$( "#orgUnits" ).on('change', '#custom', function() {
			var custom = $( "#custom" ).val()
			$.ajax({type:"POST",
				url: 'RemoteProxy.cfc?method=getOrgUnitValues',
				data: 	{
							  ouID : 400
							, conditionalSort1 : custom
						},
				dataType: 'json',
				success:function(values) {
					var values = $.parseJSON(values)
					$( "#sort1" ).html('')
					$( "#sort1" ).append('<option value="0"></option>')
					for( var i=0, l=values.length; i<l; i++ ) {
						$( "#sort1" ).append('<option value="' + values[i].valueID + '">' + values[i].valueDisplay + '</option>')
					}
					$( "#sort1" ).trigger( "change" );
				}
			});
		});

		$( "#orgUnits" ).on('change', '#sort1', function() {
			var custom = $( "#custom" ).val()
			var sort1 = $( "#sort1" ).val()
			$.ajax({type:"POST",
				url: 'RemoteProxy.cfc?method=getOrgUnitValues',
				data: 	{
							  ouID : 401
							, conditionalSort1 : custom
							, conditionalSort2 : sort1
						},
				dataType: 'json',
				success:function(values) {
					var values = $.parseJSON(values)
					$( "#sort2" ).html('')
					$( "#sort2" ).append('<option value="0"></option>')
					for( var i=0, l=values.length; i<l; i++ ) {
						$( "#sort2" ).append('<option value="' + values[i].valueID + '">' + values[i].valueDisplay + '</option>')
					}
					$( "#sort2" ).trigger("change");
				}
			});
		});

		$( "#orgUnits" ).on('change', '#sort2', function() {
			var custom = $( "#custom" ).val()
			var sort1 = $( "#sort1" ).val()
			var sort2 = $( "#sort2" ).val()
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
					var values = $.parseJSON(values)
					$( "#sort3" ).html('')
					$( "#sort3" ).append('<option value="0"></option>')
					for( var i=0, l=values.length; i<l; i++ ) {
						$( "#sort3" ).append('<option value="' + values[i].valueID + '">' + values[i].valueDisplay + '</option>')
					}
					$( "#sort3" ).trigger("change");
				}
			});
		});

		$( "#orgUnits" ).on('change', '#sort3', function() {
			var custom = $( "#custom" ).val()
			var sort1 = $( "#sort1" ).val()
			var sort2 = $( "#sort2" ).val()
			var sort3 = $( "#sort3" ).val()
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
					var values = $.parseJSON(values)
					$( "#sort4" ).html('')
					$( "#sort4" ).append('<option value="0"></option>')
					for( var i=0, l=values.length; i<l; i++ ) {
						$( "#sort4" ).append('<option value="' + values[i].valueID + '">' + values[i].valueDisplay + '</option>')
					}
				}
			});
		});
	}

});