$(document).ready(function(){
	
	var searchID = $("#searchID").val();
	var acctID = $( "#acctID" ).val();
	var valueID = $( "#valueID" ).val();
	var travelerNumber = $("#travelerNumber").val();
	var airSelected = $( "#airSelected" ).val();
	var hotelSelected = $( "#hotelSelected" ).val();
	var chainCode = $( "#chainCode" ).val();
	var vehicleSelected = $( "#vehicleSelected" ).val();
	var vendor = $( "#vendor" ).val();
	var arrangerID = $( "#arrangerID" ).val();

	getTraveler();

	function loadTraveler(traveler, loadMethod) {
		console.log(traveler);
		$( "#userID" ).val( traveler.userId );
		$( "#firstName" ).val( traveler.firstName );
		$( "#middleName" ).val( traveler.middleName );
		$( "#lastName" ).val( traveler.lastName );
		if ($( "#userID" ).val() != 0) {
			$( "#firstName" ).prop('disabled', true);
			$( "#lastName" ).prop('disabled', true);
			$( "#firstName2" ).val( traveler.firstName );
			$( "#lastName2" ).val( traveler.lastName );
		}
		else {
			$( "#firstName" ).prop('disabled', false);
			$( "#lastName" ).prop('disabled', false);
			$( "#firstName2" ).val( '' );
			$( "#lastName2" ).val( '' );
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
			for( var i=0, l=traveler.loyaltyProgram.length; i<l; i++ ) {
				if (traveler.loyaltyProgram[i] !== null) {
					// if (traveler.loyaltyProgram[i].shortCode == vendor) {
					// 	$( "#carFF" ).val( traveler.loyaltyProgram[i].acctNum );
					// }
				}
			}
		}

		if (hotelSelected == 'true') {
			if (loadMethod == 'change') {
				$( "#hotelFF" ).val( '' );
				for( var i=0, l=traveler.loyaltyProgram.length; i<l; i++ ) {
					if (traveler.loyaltyProgram[i] !== null) {
						if (traveler.loyaltyProgram[i].shortCode == chainCode) {
							$( "#hotelFF" ).val( traveler.loyaltyProgram[i].acctNum );
						}
					}
				}
			}
			else {
				$( "#hotelFF" ).val( traveler.bookingDetail.hotelFF );
			}
		}

		if (vehicleSelected == 'true') {
			if (loadMethod == 'change') {
				$( "#carFF" ).val( '' );
				for( var i=0, l=traveler.loyaltyProgram.length; i<l; i++ ) {
					if (traveler.loyaltyProgram[i] !== null) {
						if (traveler.loyaltyProgram[i].shortCode == vendor) {
							$( "#carFF" ).val( traveler.loyaltyProgram[i].acctNum );
						}
					}
				}
			}
			else {
				$( "#carFF" ).val( traveler.bookingDetail.carFF );
			}
		}

		$.ajax({type:"POST",
			url: 'RemoteProxy.cfc?method=loadOrgUnit',
			data: 	{
						  userID : traveler.userId
						, acctID : acctID
						, valueID : valueID
					},
			dataType: 'json',
			success:function(orgunits) {
				var orgunits = $.parseJSON(orgunits)
				$( "#orgUnits" ).html('');
				for( var i=0, l=orgunits.length; i<l; i++ ) {
					$( "#orgUnits" ).append( createForm(orgunits[i]) );
				}
			}
		});

		if (vehicleSelected == 'true') {
			$.ajax({type:"POST",
				url: 'RemoteProxy.cfc?method=getCarPayments',
				data: 	{
							  acctID : acctID
							, userID : traveler.userId
							, valueID : valueID
							, vendor : vendor
						},
				dataType: 'json',
				success:function(payments) {
					$( "#carFOPID" ).html('')
					$( "#carFOPID" ).append('<option value=""></option>')
					for( var i=0, l=payments.length; i<l; i++ ) {
						if (payments[i].directBillNumber != '' || payments[i].corporateDiscountNumber != '') {
							if (payments[i].directBillNumber != '') {
								$( "#carFOPID" ).append('<option value="DB_' + payments[i].directBillNumber + '">' + payments[i].fopDescription + '</option>')
							}
							if (payments[i].corporateDiscountNumber != '') {
								$( "#carFOPID" ).append('<option value="DB_' + payments[i].corporateDiscountNumber + '">Present your credit card at the pick-up counter</option>')
							}
						}
						else {
							$( "#carFOPID" ).append('<option value="0">Present your credit card at the pick-up counter</option>')
						}
					}
				}
			});
		}

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
				 	div += '<option value="' + orgunit.ouValues[i].valueID + '"'
				 	if (orgunit.valueID == orgunit.ouValues[i].valueID) {
				 		div += 'selected';
				 	}
				 	div += '>' + orgunit.ouValues[i].valueDisplay + '</option>';
				 }
			div += '</select>';
		}
		div += '</div>';
		div += '</div>';

		return div;
	}

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
				getPayments(traveler.userId, 'initial');
			}
		});
	}

	$( "#userID" ).on('change', function() {
		$.ajax({type:"POST",
			url: 'RemoteProxy.cfc?method=loadFullUser',
			data: 	{
						  acctID : acctID
						, userID : $( "#userID" ).val()
					},
			dataType: 'json',
			success:function(traveler) {
				loadTraveler(traveler, 'change');
				getPayments(traveler.userId, 'initial');
			}
		});
	});

	function getPayments(userID, loadMethod) {
		$.ajax({type:"POST",
			url: 'RemoteProxy.cfc?method=getUserPayments',
			data: 	{
						  userID : userID
						, arrangerID : arrangerID
						, acctID : acctID
						, valueID : valueID
					},
			dataType: 'json',
			success:function(payments, loadMethod) {
				loadPayments(payments, 'air', loadMethod);
			}
		});
	}

	function loadPayments(payments, typeOfService, loadMethod) {
		$( "#" + typeOfService + "FOPID" ).html('')
		$( "#" + typeOfService + "FOPID" ).append('<option value=""></option>')
		var manualEntry = 1;
		for( var i=0, l=payments.length; i<l; i++ ) {
			if (payments[i][typeOfService + 'Use'] == true) {
				if (payments[i].exclusive == 1) {
					manualEntry = 0;
				}
			}
		}
		if (manualEntry == 1) {
			$( "#" + typeOfService + "FOPID" ).append('<option value="0">MANUAL ENTRY</option>')
		}
		var personalCardOnFile = 0
		for( var i=0, l=payments.length; i<l; i++ ) {
			if (payments[i][typeOfService + 'Use'] == true) {
				if (payments[i].fopDescription == '') {
					payments[i].fopDescription = traveler.firstName + ' ' + traveler.lastName;
				}
				var selected = '';
				if (payments[i].btaID != '') {
					$( "#" + typeOfService + "FOPID" ).append('<option value="bta_' + payments[i].btaID + '">' + payments[i].fopDescription + ' ending in ' + payments[i].acctNum + '</option>')
				}
				else if (payments[i].fopID != '') {
					if (payments[i].userID == traveler.userId) {
						personalCardOnFile = 1
					}
					$( "#" + typeOfService + "FOPID" ).append('<option value="fop_' + payments[i].fopID + '">' + payments[i].fopDescription + ' ending in ' + payments[i].acctNum + '</option>')
				}
			}
		}
		if (traveler.userId != 0 && traveler.userId != arrangerID && manualEntry == 1 && personalCardOnFile == 0) {
			$( "#" + typeOfService + "SaveCardDiv" ).show();
		}
		else {
			$( "#" + typeOfService + "SaveCardDiv" ).hide();
		}
		if (loadMethod == 'initial') {
			$( "#" + typeOfService + "FOPID" ).val( traveler.bookingDetail[typeOfService + 'FOPID'] );
			$( "#" + typeOfService + "Manual" ).show();
			$( "#" + typeOfService + "CCNumber" ).val( traveler.bookingDetail[typeOfService + 'CCNumber'] );
			$( "#" + typeOfService + "CCMonth" ).val( traveler.bookingDetail[typeOfService + 'CCMonth'] );
			$( "#" + typeOfService + "CCYear" ).val( traveler.bookingDetail[typeOfService + 'CCYear'] );
			$( "#" + typeOfService + "BillingName" ).val( traveler.bookingDetail[typeOfService + 'BillingName '] );
			if (typeOfService == 'air') {
				$( "#" + typeOfService + "BillingAddress" ).val( traveler.bookingDetail[typeOfService + 'BillingAddress'] );
				$( "#" + typeOfService + "BillingCity" ).val( traveler.bookingDetail[typeOfService + 'BillingCity'] );
				$( "#" + typeOfService + "BillingState" ).val( traveler.bookingDetail[typeOfService + 'BillingState'] );
				$( "#" + typeOfService + "BillingZip" ).val( traveler.bookingDetail[typeOfService + 'BillingZip'] );
			}
			$( "#" + typeOfService + "SaveCard" ).val( traveler.bookingDetail[typeOfService + 'SaveCard'] );
			$( "#" + typeOfService + "SaveName" ).val( traveler.bookingDetail[typeOfService + 'SaveName'] );
		}
	}

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

	//NASCAR custom code for conitional logic for sort1/second org unit displayed/department number
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

});