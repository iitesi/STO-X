$(document).ready(function(){

	 $('.filterselection').hide();

	// show filter box
	$('.filterby').click(function(){
		$(".filterselection").slideToggle();
	});

// toggle active button state if filter is active

	// Single Carrier (on/off)
	$('#SingleCarrier').change(function(){
		if($(this).is(':checked')){
			$("#singlecarrierbtn").parent().addClass('active');
			// Example of using icon
			// $("#singlecarrierbtn").html('<i class="icon-check"></i> Single Carrier');
		} else {
			$("#singlecarrierbtn").parent().removeClass('active');
			// $("#singlecarrierbtn").text('Single Carrier');
		}
	});

	// check for active state when page loads
	if ($('#SingleCarrier').attr('checked')) {
		$("#singlecarrierbtn").parent().addClass('active');
	}

	// In Policy (on/off)
	$('#InPolicy').change(function(){
		if($(this).is(':checked')){
			$("#inpolicybtn").parent().addClass('active');
		} else {
			$("#inpolicybtn").parent().removeClass('active');
		}
	});

	// check for active state when page loads
	if ($('#InPolicy').attr('checked')) {
		$("#inpolicybtn").parent().addClass('active');
	}

	// NonStops (on/off)
	$('#NonStops').change(function(){
		if($(this).is(':checked')){
			$("#nonstopbtn").parent().addClass('active');
		} else {
			$("#nonstopbtn").parent().removeClass('active');
		}
	});

	// check for active state when page loads
	if ($('#NonStops').attr('checked')) {
		$("#nonstopbtn").parent().addClass('active');
		$("#nonstopbtn").html('<i class="icon-check"></i> In Policy');
	}

// TODO:  need to add call to sort and filterAir() (see old filter.cfm at bottom of page)
// 4:59 PM Monday, June 10, 2013 - Jim Priest - jpriest@shortstravel.com

});


