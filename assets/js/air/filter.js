$(document).ready(function(){

//------------------------------------------------------------------------------
// FILTER
//------------------------------------------------------------------------------
	// hide filter bar and message div by default
	$('.filterselection, #filtermsg').hide();

	$('#filtermsg .close').on('click', function() {
		$(this).parent().hide();
	});

	$('.closefilterwell').on('click', function() {
		$('.filterselection').slideUp();
	});

	$('#removefilters').on('click', function() {
		// reset checkboxes
		$('.filterselection input[type=checkbox]').prop('checked',false);
		// reset button states
		$('.filterby, #singlecarrierbtn, #nonstopbtn, #inpolicybtn').parent().removeClass('active');

		// reset sorting and filters
		sortAir( sortbyprice );

		// TODO: hack to show all flights by default
		// 9:59 AM Thursday, June 20, 2013 - Jim Priest - jpriest@shortstravel.com
		$('[id^="flight"]').show();

	});

	$('.filterby').on('click', function() {
		$(".filterselection").slideToggle().css({"position": "absolute", "z-index": 1});
		scrollTo("filtermsg");
	});

// toggle active button state if filter is active
	// Single Carrier (on/off)
	$('#singlecarrierbtn').on('click', function() {
		if( $('#SingleCarrier').val() == 0 ){
	 		$('#SingleCarrier').val('1')
	 		$("#singlecarrierbtn").parent().addClass('active');
		} else {
	 		$('#SingleCarrier').val('0')
	 		$("#singlecarrierbtn").parent().removeClass('active');
		}
		filterAirDelay.run();
	});

	// In Policy (on/off)
	$('#inpolicybtn').on('click', function() {
		if( $('#InPolicy').val() == 0 ){
	 		$('#InPolicy').val('1')
	 		$("#inpolicybtn").parent().addClass('active');
		} else {
	 		$('#InPolicy').val('0')
	 		$("#inpolicybtn").parent().removeClass('active');
		}
		filterAirDelay.run();
	});

	// NonStops (on/off)
	$('#nonstopbtn').on('click', function() {
		if( $('#NonStops').val() == 0 ){
	 		$('#NonStops').val('1')
	 		$("#nonstopbtn").parent().addClass('active');
		} else {
	 		$('#NonStops').val('0')
	 		$("#nonstopbtn").parent().removeClass('active');
		}
		filterAirDelay.run();
	});

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

// -----------------------------------------------------------------------------
// MISC FUNCTIONS
// -----------------------------------------------------------------------------

// This is a functions that scrolls to #id
function scrollTo(id)
{
  $('html,body').animate({scrollTop: $("#"+id).offset().top},'fast');
}

// This throttles requests to filter() so if the person quickly clicks several
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