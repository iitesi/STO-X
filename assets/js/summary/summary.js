$(document).ready(function(){
	
	var searchID = $("#searchID").val();
	var acctID = $( "#acctID" ).val();
	var valueID = $( "#valueID" ).val();
	var vendor = $( "#vendor" ).val();
	var travelerNumber = $("#travelerNumber").val();
	var airSelected = $( "#airSelected" ).val();
	var hotelSelected = $( "#hotelSelected" ).val();
	var vehicleSelected = $( "#vehicleSelected" ).val();

	getTraveler();

	function loadTraveler(traveler) {
		//console.log(traveler);
		$( "#userID" ).val( traveler.userId );
		$( "#firstName" ).val( traveler.firstName );
		$( "#middleName" ).val( traveler.middleName );
		$( "#lastName" ).val( traveler.lastName );
		if ($( "#userID" ).val() != 0) {
			$( "#firstName" ).prop('disabled', true);
			$( "#lastName" ).prop('disabled', true);
		}
		else {
			$( "#firstName" ).prop('disabled', false);
			$( "#lastName" ).prop('disabled', false);
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

		if (airSelected == 'true' || hotelSelected == 'true') {
			$.ajax({type:"POST",
				url: 'RemoteProxy.cfc?method=getUserPayments',
				data: 	{
							  userID : traveler.userId
							, acctID : acctID
							, valueID : valueID
						},
				dataType: 'json',
				success:function(payments) {
					if (airSelected == 'true') {
						$( "#airFOPID" ).html('')
						$( "#airFOPID" ).append('<option value=""></option>')
						$( "#airFOPID" ).append('<option value="0">MANUAL ENTRY</option>')
						for( var i=0, l=payments.length; i<l; i++ ) {
							if (payments[i].airUse == true) {
								if (payments[i].fopDescription == '') {
									payments[i].fopDescription = traveler.firstName + ' ' + traveler.lastName;
								}
								if (payments[i].btaID != '') {
									$( "#airFOPID" ).append('<option value="bta_' + payments[i].btaID + '">' + payments[i].fopDescription + ' ending in ' + payments[i].acctNum + '</option>')
								}
								else if (payments[i].fopID != '') {
									$( "#airFOPID" ).append('<option value="fop_' + payments[i].fopID + '">' + payments[i].fopDescription + ' ending in ' + payments[i].acctNum + '</option>')
								}
							}
						}
					}
					if (hotelSelected == 'true') {
						$( "#hotelFOPID" ).html('')
						$( "#hotelFOPID" ).append('<option value=""></option>')
						$( "#hotelFOPID" ).append('<option value="0">MANUAL ENTRY</option>')
						for( var i=0, l=payments.length; i<l; i++ ) {
							if (payments[i].airUse == true) {
								if (payments[i].fopDescription == '') {
									payments[i].fopDescription = traveler.firstName + ' ' + traveler.lastName;
								}
								if (payments[i].btaID != '') {
									$( "#hotelFOPID" ).append('<option value="bta_' + payments[i].btaID + '">' + payments[i].fopDescription + ' ending in ' + payments[i].acctNum + '</option>')
								}
								else if (payments[i].fopID != '') {
									$( "#hotelFOPID" ).append('<option value="fop_' + payments[i].fopID + '">' + payments[i].fopDescription + ' ending in ' + payments[i].acctNum + '</option>')
								}
							}
						}
					}
				}
			});
		}

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
								$( "#carFOPID" ).append('<option value="DB_' + payments[i].corporateDiscountNumber + '">INDIVIDUAL PAY AT COUNTER</option>')
							}
						}
						else {
							$( "#carFOPID" ).append('<option value="0">PRESENT CARD AT COUNTER</option>')
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
				loadTraveler(traveler);
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
				loadTraveler(traveler);
			}
		});
	});

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

});