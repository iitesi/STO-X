$(document).ready(function(){

//------------------------------------------------------------------------------
// MODAL
//------------------------------------------------------------------------------

	// hide modal window if user hits the back button
	$(window).on("unload", function() {
	  	$('#myModal').modal('hide');
	});

	// open search widget in modal / iframe
	// url is defined in search button / link
	$('.searchModalButton').click(function(){
		var frameSrc = $(this).attr('data-framesrc');
		$('#searchModal').on('show', function () {
			$('iframe').attr("src",frameSrc);
		});
		$('#searchModal').modal({show:true})
	});

	$('.airModal').on('click', function() {
		$('#myModalBody').text( $(this).attr('data-modal') );
		$('#myModal').modal('show');
	});

	$('.breadcrumbModal').on('click', function() {
		$('#popupModal').modal();
		$('#popupModalHeader').html( '<i class="icon-spinner icon-spin"></i> One moment ...' );
		$('#popupModalBody').html( 'We are retrieving your previous search results...' );
	});

	$('#popupModal').on('hidden', function() {
		$(this).removeData('modal');
		$('#popupModalBody').html( 'One moment, we are retrieving your flight details...' );
	});

//------------------------------------------------------------------------------
// FILTER
// 9:46 AM Wednesday, December 04, 2013 - Jim Priest - jpriest@shortstravel.com
// This should all be redone in Angular.js :)
//------------------------------------------------------------------------------

	$('#filterbarloading').hide();
	$('.airfilterbar').show();

	$('#usermessage').on('click', function() {
		$(this).slideUp();
	});

	$('.closefilterwell').on('click', function() {
		$('#filterwell').slideUp();
	});

	$('.closesliderwell').on('click', function() {
		$('#sliderwell').slideUp();
		$("#timebtn").parent().toggleClass('active');
		// $("#flightbtn").parent().toggleClass('active');
	});

	$('.removefilters').on('click', function() {

		// reset time sliders and filtered and hidden badges
		$(".takeoff-range0").slider("values", [0, 1440]);
		$(".takeoff-range1").slider("values", [0, 1440]);
		$(".landing-range0").slider("values", [0, 1440]);
		$(".landing-range1").slider("values", [0, 1440]);

		$('div[id^="flight"]').removeClass('hiddend0 hiddend1 hiddena0 hiddena1');
		$('div[id^="flight"]').removeClass('dfiltered0 dfiltered1 afiltered0 afiltered1');


		// reset checkboxes
		$('.filterselection input[type=checkbox]').prop('checked',false);
		// reset button states
		$('.filterby, #singlecarrierbtn, #inpolicybtn').parent().removeClass('active');
		$('[id^=nonstopbtn]').parents().removeClass('active');
		$( "#stopdropdown" ).html( 'Stops <b class="caret"></b>' );
		$( "#stopdropdown" ).attr( "data-value", '' );
		// reset button filters back to 0
		$('#SingleCarrier, #InPolicy, #NonStops').val('0')
		// hide filter well
		$('.filterselection').hide();
		$('.filtertimeselection').hide();
		// $('.filterflightselection').hide();
		$('.spinner').show();

		// reset sorting and filters
		sortAir( sortbyprice );
		resetAirDelay.run();
		return false;
	});

	// display airline/class/fare filter well
	$('.filterby').on('click', function() {
		$(".filterselection").slideToggle().css({"position": "absolute", "z-index": 99});
	});

	// display time slider filter well
	$('.filterbytime').on('click', function() {
		$(".filtertimeselection").slideToggle().css({"position": "relative", "z-index": 98});
		$("#timebtn").parent().toggleClass('active');
		// if the other filter is open let's close it
		if( $('.filterselection').is(':visible') ){
			$(".filterselection").slideUp('fast');
		}
	});

	// display flight number slider filter well
	/* $('.filterbyflight').on('click', function() {
		$(".filterflightselection").slideToggle().css({"position": "relative", "z-index": 98});
		$("#flightbtn").parent().toggleClass('active');
		// if the other filter is open let's close it
		if( $('.filterselection').is(':visible') ){
			$(".filterselection").slideUp('fast');
		}
	}); */

	// non-stop dropdown menu
	$('[id^=nonstopbtn]').on('click', function(e) {
			var selectedOption = $(this).attr( 'data-title' );
			var stops = $(this).attr( 'data-stops' );
			var menuRoot = $( this ).parents( "li.dropdown" );

			// set number of stops into hidden field so we can grab it
			$('#NonStops').val( stops );

			// Change dropdown title based on selection
			$( "a.dropdown-toggle", menuRoot ).html( selectedOption  + ' <b class="caret"></b>' );
			$( "a.dropdown-toggle", menuRoot ).attr( "data-value", selectedOption );

			// remove any active class then reset it below
			$('[id^=nonstopbtn]').parents().removeClass('active');

			// set active button
			if ($(this).is('[id^=nonstopbtn]')) {
				$(this).parent('li').parents('li').eq(0).addClass('active');
				$(this).parent().addClass('active');
			} else {
				$(this).parent().addClass('active');
			}

			// run filter
			$('.spinner').show();
			filterAirDelay.run();
			e.preventDefault();
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
		$('.spinner').show();
		filterAirDelay.run();
		return false;
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
		$('.spinner').show();
		filterAirDelay.run();
		return false;
	});

	// Airlines (set of checkboxEs - default = all checked)
	$('input[name="carrier"]').on('change', function() {
		var fields = $('#airlines').find('input[name="carrier"]:checked');
		if (!fields.length){
			$("#airlinebtn").parent().removeClass('active');
		} else {
			$("#airlinebtn").parent().addClass('active');
		}
		$('.spinner').show();
		filterAirDelay.run();
		return false;
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
		$('.spinner').show();
		filterAirDelay.run();
		return false;
	});

	// check for active state when page loads
	var fields = $('#class').find('input[name^="Class"]:checked');
	if (fields.length) {
		$("#classbtn").parent().addClass('active');
	}

	// Fares (set of checkboxes - default = all checked)
	$('input[name^="Fare"]').on('change', function() {
		var fields = $('#fares').find('input[name^="Fare"]:checked');
		if (!fields.length){
			$("#farebtn").parent().removeClass('active');
		} else {
			$("#farebtn").parent().addClass('active');
		}
		$('.spinner').show();
		filterAirDelay.run();
		return false;
	});

	// check for active state when page loads
	var fields = $('#fares').find('input[name^="Fare"]:checked');
	if (fields.length) {
		$("#farebtn").parent().addClass('active');
	}

//------------------------------------------------------------------------------
// SORTING
//------------------------------------------------------------------------------
	$('[id^=sortby]').on('click', function(e) {
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
		e.preventDefault();
	});

	//------------------------------------------------------------------------------
	// on initial page load, run the filterAir()
	// over the initial values of the filter bar
	//------------------------------------------------------------------------------
	filterAir();

}); // end of $(document).ready(function()

// -----------------------------------------------------------------------------
// MISC FUNCTIONS
// -----------------------------------------------------------------------------

// This throttles requests to filterAir() so if the person quickly clicks several
// filters we don't fire filterAir() multiple times.
// http://javascriptweblog.wordpress.com/2010/07/19/a-javascript-function-guard/

// 8:48 AM Friday, May 09, 2014 - Jim Priest - priest@thecrumb.com
// look at replacing this with underscore.js
// http://underscorejs.org/#throttle

var filterAirDelay = new FunctionGuard(filterAir);
var sliderAirDelay = new FunctionGuard(filterAir, 500, null, 'slider');

var resetAirDelay = new FunctionGuard(filterAir, 500, null, 'true');

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

	// This is a functions that scrolls to #id
function scrollToId(id) {
  $('html,body').animate({scrollTop: $("#"+id).offset().top},'fast');
}