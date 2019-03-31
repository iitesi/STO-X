$(document).ready(function(){
	$('.filterselection .filtergroup').hide();
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
		console.log(frameSrc);
		$('#searchModal').on('show.bs.modal', function () {
			$('iframe').attr("src",frameSrc);
		});
		$('#searchModal').modal('show')
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

	$('#popupModal').on('hidden.bs.modal', function() {
		$(this).removeData('modal');
		$('#popupModalBody').html( '<i class="fa fa-spinner fa-spin"></i> One moment, we are retrieving your flight details...' );
	});

	$('#popupModal').on('show.bs.modal', function (event) {
	   var button = $(event.relatedTarget) // Button that triggered the modal
	   var url = button.data('url') // Extract info from data-* attributes
	   $('#popupModalBody').load(url);
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
		$('#airlines, #class, #fares').hide();
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
		$('#SingleCarrier, #InPolicy').val('0');
		$('#NonStops').val('');
		// hide filter well
		$('.filterselection').hide();
		$('.filterselection .filtergroup').hide();
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
		$(".filterselection").slideToggle({
			complete: function() {
				if(!$('.filterselection').is(':visible')) {
					$('#airlines, #class, #fares').hide();
				};
			}
		}); //.css({"position": "absolute", "z-index": 99});
	});

	$('#airlinebtn').on('click', function(){
		$('#airlines').show();
	});

	$('#classbtn').on('click', function(){
		$('#class').show();
	});

	$('#farebtn').on('click', function(){
		$('#fares').show();
	});

	// display time slider filter well
	$('.filterbytime').on('click', function() {
		$(".filtertimeselection").slideToggle(); //.css({"position": "relative", "z-index": 98});
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
	
	// Flightnumber filter
	$('#flightnumberbtn').on('click', function() {
		$('.spinner').show();
		filterAirByFlightNumber($('#flightnumber').val());
		$('.spinner').hide();
	})
	
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
	/*
	$('.grid-view,.list-view').removeClass('hidden');

	var view = Cookies.get('sto-view-pref')

	if(!view || view == 'grid') {
		// Default to grid-view
		$('.showGridView').addClass('active');
		$('.list-view').hide();
	} else {
		$('.showListView').addClass('active');
		$('.grid-view').hide();
	}

	$('.viewToggle button').click(function(ev){
		$('.viewToggle button').toggleClass('active');
		$('.grid-view,.list-view').toggle();
		var viewSelected = $(ev.target).data('view');
		if(!viewSelected) viewSelected =  $(ev.target).parents('[data-view]').data('view')
		Cookies.set('sto-view-pref', viewSelected);

	});
	*/

}); // end of $(document).ready(function()

// -----------------------------------------------------------------------------
// MISC FUNCTIONS
// -----------------------------------------------------------------------------

// This throttles requests to filterAir()  so if the person quickly clicks several
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

function filterAir(reset) {

	var loopcnt = 0;
	var classy = $("#ClassY:checked").val();
	var classc = $("#ClassC:checked").val();
	var classf = $("#ClassF:checked").val();
	var fare0 = $("#Fare0:checked").val();
	var fare1 = $("#Fare1:checked").val();
	var nonstops = $("#NonStops").val();
	var inpolicy = $("#InPolicy").val();
	var singlecarrier = $("#SingleCarrier").val();
	var showCount = 0;
	var showFlight = false;

	// see if any airlines are checked in filter
	var airfields = $('input[name=carrier]:checked').map(function () { return this.value; }).toArray();

	// reset all filters - reset=true is passed from air/filter.js  resetAirDelay() and is used to clear filters
	if(reset == 'true'){

		// set count to all, and show all badges
		showCount = flightresults.length;
		$('[class^="flight"]').show();
		
		$('#flightnumber').val('');
		$('span.flightNumberFilter').hide();

	} else {

		for (loopcnt = 0; loopcnt <= (flightresults.length-1); loopcnt++) {
			
			var flight = flightresults[loopcnt];
			showFlight = true;

			// loop through and only check each subsequent filter if the previous
			// filter didn't already hide it ( showflight=true )

			// check in-policy, single carrier
			if(showFlight == true){
				if( (flight[1] == 0 && inpolicy == 1 ) || (flight[2] == 1 && singlecarrier == 1 ) ){
					showFlight = false;
				}
			}

			// non-stops - show all by default (nonstops will be empty)
			if(showFlight == true){
				if( nonstops.length > 0 && flight[7] != nonstops ){
					showFlight = false;
				}
			}

			// check refundable / non-refundable and not both checked at once which would imply you want to see everything
			if(showFlight == true){
				if(
					(
						(fare0 == 0 && flight[4] == 1)
						|| (fare1 == 1 && flight[4] == 0)
					)
					// if all are selected show all
					&& !( fare0 == 0 && fare1 == 1)
				){
					showFlight = false;
				}
			}

			// check class Y = Economy, C = Business, F = First
			if(showFlight == true){

				if ( // single selection made
					( classy == 'Y' && classc != 'C' && classf != 'F' )
					|| ( classc == 'C' && classy != 'Y' && classf != 'F' )
					|| ( classf == 'F' && classy != 'Y' && classc != 'C' )
				){
					 if (
						 ( classy == 'Y' && flight[6] == 'C' || classy == 'Y' && flight[6] == 'F')
						 || ( classc == 'C' && flight[6] == 'Y' || classc == 'C' && flight[6] == 'F' )
						 || ( classf == 'F' && flight[6] == 'Y' || classf == 'F' && flight[6] == 'C' )
				 			// if all are selected show all
					 		&& !( classf == 'F' && classc == 'C' && classf == 'F' )
					 	) {
					 		showFlight = false;
					 	} // inside if

				} else if ( // two selections made

					( classy == 'Y' && classc == 'C' && classf != 'F' )
					|| ( classy == 'Y' && classf == 'F' && classc != 'C' )
					|| ( classc == 'C' && classf == 'F' && classy != 'Y' )
				){
					 if (
							( classy == 'Y' && classc == 'C' && classf != 'F' && flight[6] == 'F' )
							|| 	( classf == 'F' && classc == 'C' && classy != 'Y' && flight[6] == 'Y' )
							|| 	( classy == 'Y' && classf == 'F' && classc != 'C' && flight[6] == 'C' )
				 			// if all are selected show all
					 		&& !( classf == 'F' && classc == 'C' && classf == 'F' )
					 	) {
					 		showFlight = false;
					 	} // inside if
				} // two selections made
			} // showflight = true

			// check carriers
			if(showFlight == true){
					// check first to see if ANY airlines are checked
					if (airfields.length) {

						var show = 0;
						$.each( airfields, function( intValue, currentElement ) {

							// loop over and see if airline is in trip
							if( jQuery.inArray( currentElement , flight[3]) >= 0 ) {
								show = 1;
								// as soon as we've found 1 match we can dump out of the loop and we'll show this trip
								return false;
							}

						}); // end each()

						// if nothing matches - we'll hide the trip
						if (show == 0){
							showFlight = false;
						}
					} // airfields.length
			} // showflight = true

			// show or hide flight
			if(showFlight == true){
				showCount++;
				$( '.flight' + flight[0] ).show();
			} else {
				$( '.flight' + flight[0] ).hide();
			}

		} // end of for loop flightresults
	} // reset == 'true'

	// show/hide no flights found message
	if(showCount == 0){
		$('.noFlightsFound').show();
	} else {
		$('.noFlightsFound').hide();
	}

	// show flight count
 	$('#flightCount').text(showCount);
 	
 	if (parseInt($('#flightCount').text()) > parseInt($('#flightCount2').text())) {
 		$('#flightCount2').text(showCount);
 	}
 	
	$('.spinner').hide();
	
	return false;
}

function filterAirByFlightNumber(flightNumber) {
	
	flightNumber = flightNumber.replace(/^\D+/g,'');
	
	if (flightNumber.length > 0) {
		
		$("div[class^=flight]").each(function() {
			
			var flightDiv = $(this);
			var showFlight = false;
			
			$('span.flightNumberFilter',this).each(function() {
				if ($(this).text() == flightNumber) {
					showFlight = true;
				}
			});
			
			if (showFlight) {
				
				flightDiv.show();
				
			} else {
				
				flightDiv.hide();
			}
		});
		
		$('#flightCount').text($('div[class^=flight]:visible').length);
	}
}

function sortAir(sort) {
	var sortlist = eval( sort );
	if(sortlist){
		for (var t = 0; t < sortlist.length; t++) {
			$( "#aircontent .grid-view" ).append( $( ".grid-view .flight" + sortlist[t] ) );
			$( "#aircontent .list-view" ).append( $( ".list-view .flight" + sortlist[t] ) );
		}
	}
	return false;
}
