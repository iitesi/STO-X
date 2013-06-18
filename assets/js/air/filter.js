$(document).ready(function(){

//------------------------------------------------------------------------------
// FILTER
//------------------------------------------------------------------------------
	// hide filter bar and message div by default
	$('.filterselection, #filtermsg').hide();

	$('#filtermsg .close').on('click', function() {
		$(this).parent().hide();
	});

	$('#removefilters').on('click', function() {
		// reset checkboxes
		$('.filterselection input[type=checkbox]').prop('checked',false);
		// show filters
		$('.filterselection').show();
		// reset button states
		$('.filterby li').removeClass('active');
		// write friendly message
		$('#filtermsg').removeClass('alert-error').addClass('alert-success').show();
		$('#filtermsg span').text('Filters successfully reset!');
		// scroll to filter bar
		scrollTo("filtermsg");

		// reset sorting and filters
		sortAir( sortbyprice );
		$('[id^="flight"]').show();

	});

	$('.filterby').on('click', function() {
		$(".filterselection").slideToggle();
		scrollTo("filtermsg");
	});

// toggle active button state if filter is active
	// Single Carrier (on/off)
	$('#SingleCarrier').on('change', function() {
		if($(this).is(':checked')){
			$("#singlecarrierbtn").parent().addClass('active');
		} else {
			$("#singlecarrierbtn").parent().removeClass('active');
		}
		filterAirDelay.run();
	});

	// check for active state when page loads
	if ($('#SingleCarrier').attr('checked')) {
		$("#singlecarrierbtn").parent().addClass('active');
	}

	// In Policy (on/off)
	$('#InPolicy').on('change', function() {
		if($(this).is(':checked')){
			$("#inpolicybtn").parent().addClass('active');
		} else {
			$("#inpolicybtn").parent().removeClass('active');
		}
		filterAirDelay.run();
	});

	// check for active state when page loads
	if ($('#InPolicy').attr('checked')) {
		$("#inpolicybtn").parent().addClass('active');
	}

	// NonStops (on/off)
	$('#NonStops').on('change', function() {
		if($(this).is(':checked')){
			$("#nonstopbtn").parent().addClass('active');
		} else {
			$("#nonstopbtn").parent().removeClass('active');
		}
		filterAirDelay.run();
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
		filterAirDelay.run();
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
		filterAirDelay.run();
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
		filterAirDelay.run();
	});

	// check for active state when page loads
	var fields = $('#fares').find('input[name^="Fare"]:checked');
	if (fields.length) {
		$("#farebtn").parent().addClass('active');
	}

//------------------------------------------------------------------------------
// SORTING
//------------------------------------------------------------------------------
	$('[id^=sortby]').on('click', function() {
			// sort flights
			sortAir( $(this).attr("id") );

			// remove all active states
			$('[id^=sortby]').parents().removeClass('active');

			// set active button
			if ($(this).is('[id^=sortbyprice]')) {
				$(this).parent('li').parents('li').eq(0).addClass('active');
				$(this).parent().addClass('active');
			} else {
				$(this).parent().addClass('active');
			}
	});


}); // $(document).ready(function(){


<<<<<<< Updated upstream
=======
//------------------------------------------------------------------------------
// SORTING
//------------------------------------------------------------------------------
	$('[id^=sortby]').on('click', function() {

			// sort flights
			sortAir( $(this).attr("id") );

			// remove all active states
			$('[id^=sortby]').parents().removeClass('active');

			// set active button
			if ($(this).is('[id^=sortbyprice]')) {
				$(this).parent('li').parents('li').eq(0).addClass('active');
				$(this).parent().addClass('active');
			} else {
				$(this).parent().addClass('active');
			}
	});

>>>>>>> Stashed changes

// -----------------------------------------------------------------------------
// MISC FUNCTIONS
// -----------------------------------------------------------------------------

// This is a functions that scrolls to #id
function scrollTo(id)
{
  $('html,body').animate({scrollTop: $("#"+id).offset().top},'fast');
}

// This throttles requests to filter() so if the person quicly clicks several
// filters we don't fire filterAir() multiple times.
// http://javascriptweblog.wordpress.com/2010/07/19/a-javascript-function-guard/

var filterAirDelay = new FunctionGuard(filterAir);

function FunctionGuard(fn, quietTime, context /*,fixed args*/) {
    this.fn = fn;
    this.quietTime = quietTime || 1000;   // adjust this time (ms) to wait, or pass it in as an argument when calling
    this.context = context || null;
    this.fixedArgs = (arguments.length > 3) ? Array.prototype.slice.call(arguments, 3) : [];
}

FunctionGuard.prototype.run = function(/*dynamic args*/) {
    this.cancel(); //clear timer
    var fn = this.fn, context = this.context, args = this.mergeArgs(arguments);
    var invoke = function() {
        fn.apply(context,args);
    }
    this.timer = setTimeout(invoke,this.quietTime); //reset timer
}

FunctionGuard.prototype.mergeArgs = function(dynamicArgs) {
    return this.fixedArgs.concat(Array.prototype.slice.call(dynamicArgs,0));
}

FunctionGuard.prototype.cancel = function(){
    this.timer && clearTimeout(this.timer);
}