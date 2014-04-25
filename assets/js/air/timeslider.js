// ===============================================
// Air Time Sliders
// ===============================================
// Dependencies
// 	* jQuery UI - Sliders : http://jqueryui.com/
// 	* Moment.js - For handling times : http://momentjs.com/
//  * Underscore.js - For just making things easier : http://underscorejs.org/
// ===============================================

$(document).ready(function () {
	var mintime = 0;
	var maxtime = 1440;
	var steptime = 30;
	var baseRange = [0,1440];
	var departRange = [0,1440];
	var arriveRange = [0,1440];

	// display slider times  (min max)
	$('.takeoff-time0').text(showTime(mintime));
	$('.takeoff-time1').text(showTime(maxtime));
	$('.takeoff-time2').text(showTime(mintime));
	$('.takeoff-time3').text(showTime(maxtime));

	$('.landing-time0').text(showTime(mintime));
	$('.landing-time1').text(showTime(maxtime));
	$('.landing-time2').text(showTime(mintime));
	$('.landing-time3').text(showTime(maxtime));

	// takeoff sliders
	$(".takeoff-range0").slider({
		range: true,
		min: mintime,
		max: maxtime,
		step: steptime,
		values: departRange,
		slide: _.throttle( function (e, ui) {
			$('.takeoff-time0').html(showTime(ui.values[0])); //  +' ('+ ui.values[0]+')'
			$('.takeoff-time1').html(showTime(ui.values[1])); //  +' ('+ ui.values[1]+')'
			filterBlocks(ui.values, null, 'd0');
		}, 200)
	});

	$(".takeoff-range1").slider({
		range: true,
		min: mintime,
		max: maxtime,
		step: steptime,
		values: departRange,
		slide: _.throttle( function (e, ui) {
			$('.takeoff-time2').html(showTime(ui.values[0]));
			$('.takeoff-time3').html(showTime(ui.values[1]));
			filterBlocks(ui.values, null, 'd1');
		}, 200)
	});

// landing slider2
	$(".landing-range0").slider({
		range: true,
		min: mintime,
		max: maxtime,
		step: steptime,
		values: arriveRange,
		slide: _.throttle( function (e, ui) {
			$('.landing-time0').html(showTime(ui.values[0]));
			$('.landing-time1').html(showTime(ui.values[1]));
			filterBlocks(null, ui.values, 'a0');
		}, 200)
	});

	$(".landing-range1").slider({
		range: true,
		min: mintime,
		max: maxtime,
		step: steptime,
		values: arriveRange,
		slide: _.throttle( function (e, ui) {
			$('.landing-time2').html(showTime(ui.values[0]));
			$('.landing-time3').html(showTime(ui.values[1]));
			filterBlocks(null, ui.values, 'a1');
		}, 200)

	}); // slider

	function filterBlocks(departRange, arriveRange, id) {
		departRange0 = $('.takeoff-range0').slider('values');
		departRange1 = $('.takeoff-range1').slider('values');
		arriveRange0 = $('.landing-range0').slider('values');
		arriveRange1 = $('.landing-range1').slider('values');

  	$('div[id^="flight"]').each(function(){
			var departTime0 = $(this).data('departuretime0');
			var departTime1 = $(this).data('departuretime1');
			var arriveTime0 = $(this).data('arrivaltime0');
			var arriveTime1 = $(this).data('arrivaltime1');

			// filter departures
			if ( id == 'd0' ) {
				$(this).removeClass('dfiltered0');
				if( departTime0.isBetween(departRange[0],departRange[1]) && !$(this).hasAnyClass('hiddend1','hiddena0','hiddena1') ){
						$(this).addClass('hiddend0').addClass('dfiltered0');
				} else if ($(this).hasAnyClass('dfiltered1')) {
					$(this).removeClass('hiddend0');
				}	else {
				 	$(this).removeClass('hiddend0').addClass('dfiltered0');
				}
			}

			if ( id == 'd1' ) {
				$(this).removeClass('dfiltered1');
				if( departTime1.isBetween(departRange[0],departRange[1]) && !$(this).hasAnyClass('hiddend0','hiddena0','hiddena1') ){
					$(this).addClass('hiddend1').addClass('dfiltered1');
				} else if ($(this).hasAnyClass('dfiltered0')) {
					$(this).removeClass('hiddend1');
				}	else {
				 	$(this).removeClass('hiddend1').addClass('dfiltered1');
				}
			}

			// filter landings
			if ( id == 'a0' ) {
				$(this).removeClass('afiltered0');
				if( arriveTime0.isBetween(arriveRange[0],arriveRange[1]) && !$(this).hasAnyClass('hiddena1','hiddend0','hiddend1') ){
						$(this).addClass('hiddena0').addClass('afiltered0');
				} else if ($(this).hasAnyClass('afilterea1')) {
					$(this).removeClass('hiddena0');
				}	else {
				 	$(this).removeClass('hiddena0').addClass('afiltered0');
				}
			}

			if ( id == 'a1' ) {
				$(this).removeClass('afiltered1');
				if( arriveTime1.isBetween(arriveRange[0],arriveRange[1]) && !$(this).hasAnyClass('hiddena0','hiddend0','hiddend1') ){
					$(this).addClass('hiddena1').addClass('afiltered1');
				} else if ($(this).hasAnyClass('afilterea0')) {
					$(this).removeClass('hiddena1');
				}	else {
				 	$(this).removeClass('hiddena1').addClass('afiltered1');
				}
			}

			// last check - if the sliders have moved back to default values - 'reset'
			if ( id == 'd0' && _.isEqual(baseRange, departRange)) {
				$(this).removeClass('hiddend0').removeClass('dfiltered0');
			}

			if ( id == 'd1' && _.isEqual(baseRange, departRange)) {
				$(this).removeClass('hiddend1').removeClass('dfiltered1');
			}

			if ( id == 'a0' && _.isEqual(baseRange, arriveRange)) {
				$(this).removeClass('hiddena0').removeClass('afilterea0');
			}

			if ( id == 'a1' && _.isEqual(baseRange, arriveRange)) {
				$(this).removeClass('hiddena1').removeClass('afilterea1');
			}
		});

		var flightCount = $('div[id^="flight"]:visible').length;
		// show flight count
 		$('#flightCount').text(flightCount);

	}

	// function to see if number is between two values
	Number.prototype.isBetween = function(first,last){
		return !(first < last ? this >= first && this <= last : this >= last && this <= first);
	}

	// use moment.js library to easily display friendly times
	function showTime(mins) {
		return moment().startOf('day').add('m', mins).format('h:mma');
	}

	// update to hasClass() to allow multiple classes
	$.fn.hasAnyClass = function() {
		for (var i = 0; i < arguments.length; i++) {
			if (this.hasClass(arguments[i])) {
				return true;
			}
		}
		return false;
	}

});