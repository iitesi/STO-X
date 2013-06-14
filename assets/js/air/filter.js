$(document).ready(function(){

	// run filter on page load
	filterAir();

//------------------------------------------------------------------------------
// SORTING
//------------------------------------------------------------------------------

// TODO:  need to add call to sortAir()???
// 4:59 PM Monday, June 10, 2013 - Jim Priest - jpriest@shortstravel.com



// sortbyprice
// sortbyprice1bag
// sortbyprice2bag
// sortbyduration
// sortbydeparture
// sortbyarrival


	$('[id^=sortby]').on('click', function() {
		console.log('Sorting!');
	});



// <script type="application/javascript">
// $(document).ready(function() {
// 	$( "#radiosort" ).change(function(event) {
// 		sortAir($( "input:radio[name=sort]:checked" ).attr('id'));
// 	});
// });
// </script>


//------------------------------------------------------------------------------
// FILTER
//------------------------------------------------------------------------------
	$('.filterselection').hide();

	// show filter box
	$('.filterby').click(function(){
		$(".filterselection").slideToggle();
		scrollTo("filtermsg");
	});

// toggle active button state if filter is active

	// Single Carrier (on/off)
	$('#SingleCarrier').on('change', function() {
		filterAir();
		console.log('Single carrier clicked....');
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
	$('#InPolicy').on('change', function() {
		filterAir();
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
	$('#NonStops').on('change', function() {
		filterAir();
		if($(this).is(':checked')){
			$("#nonstopbtn").parent().addClass('active');
		} else {
			$("#nonstopbtn").parent().removeClass('active');
		}
	});

	// check for active state when page loads
	if ($('#NonStops').attr('checked')) {
		$("#nonstopbtn").parent().addClass('active');
	}

	// Airlines (set of checkboxs - default = all checked)
	$('input[name="carrier"]').on('change', function() {
		var fields = $('#airlines').find('input[name="carrier"]:checked');
		if (!fields.length){
			$("#airlinebtn").parent().removeClass('active');
		} else {
			$("#airlinebtn").parent().addClass('active');
		}
	});

	// check for active state when page loads
	var fields = $('#airlines').find('input[name="carrier"]:checked');
	if (fields.length) {
		$("#airlinebtn").parent().addClass('active');
	}

	// Class (set of checkboxs - default = economy checked)
	$('input[name^="Class"]').on('change', function() {
		var fields = $('#class').find('input[name^="Class"]:checked');
		if (!fields.length){
			$("#classbtn").parent().removeClass('active');
		} else {
			$("#classbtn").parent().addClass('active');
		}
	});

	// check for active state when page loads
	var fields = $('#class').find('input[name^="Class"]:checked');
	if (fields.length) {
		$("#classbtn").parent().addClass('active');
	}

	// Fares (set of checkboxs - default = all checked)
	$('input[name^="Fare"]').on('change', function() {
		var fields = $('#fares').find('input[name^="Fare"]:checked');
		if (!fields.length){
			$("#farebtn").parent().removeClass('active');
		} else {
			$("#farebtn").parent().addClass('active');
		}
	});

	// check for active state when page loads
	var fields = $('#fares').find('input[name^="Fare"]:checked');
	if (fields.length) {
		$("#farebtn").parent().addClass('active');
	}

// TODO: STM-688 and STM-687
// * Need to add code to 'reset' all checkboxes back to default states
// * Need to show/hide the Find more ... links if results are found for fare / class filters
// 7:50 PM Thursday, June 13, 2013 - Jim Priest - jpriest@shortstravel.com

}); // $(document).ready(function(){


// -----------------------------------------------------------------------------
// MISC FUNCTIONS
// -----------------------------------------------------------------------------

// This is a functions that scrolls to #id
function scrollTo(id)
{
  $('html,body').animate({scrollTop: $("#"+id).offset().top},'fast');
}

