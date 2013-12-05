// ===============================================
// Air Time Sliders
// ===============================================
// Dependencies
// 	* jQuery UI Sliders : http://jqueryui.com/
// 	* Moment.js for handling times : http://momentjs.com/
// ===============================================
// Useful Resources for Sliders
//
// http://stanford.wikia.com/wiki/Kayak.com_Time_Slider
// http://stackoverflow.com/questions/4764844/how-do-i-show-hide-elements-using-jquery-when-there-are-two-intersecting-princip
//
// 	http://jsfiddle.net/jrweinb/MQ6VT/
// 	http://stackoverflow.com/questions/18095439/jquery-ui-slider-using-time-as-range-not-timeline-js-fixed-width
// 	http://marcneuwirth.com/blog/2010/02/21/using-a-jquery-ui-slider-to-select-a-time-range/
// 	http://marcneuwirth.com/blog/2011/05/22/revisiting-the-jquery-ui-time-slider/
// 	http://stackoverflow.com/questions/1425913/show-hide-div-based-on-value-of-jquery-ui-slider
// 	http://stackoverflow.com/questions/10213678/jquery-ui-slider-ajax-result
// 	http://ghusse.github.io/jQRangeSlider/documentation.html#zoomMethods
// 	http://momentjs.com/docs/
// 	using data-attributes - give each badge a data-takeoff data-landing attribute to use for filtering
// 	http://stackoverflow.com/questions/15582349/modify-this-function-to-show-hide-by-data-attributes-instead-of-by-class
// 	MAX	1395168300		1055
// 	MIN	1394202000   	660

$(document).ready(function () {
	// see code in badge.cfm to populate the data-attributes for each badge with the min/max times for that badge
	// that logic needs to be moved 'up' earlier in process (airParse) so we can grab min/max times here in JS
	// grab the  min/max times from badge range so we can set in slider below
	// this would be dynamically populated
	// var mintime = 330;
	// var maxtime = 1173;

	var mintime = 0;
	var maxtime = 1440
	var steptime = 60;

	// for roundtrip we need 8 times
	var slidertime = new Array();
		slidertime[0] = moment().startOf('day').minutes(maxtime).format('h:mma');
		slidertime[1] = moment().startOf('day').minutes(mintime).format('h:mma');
		slidertime[2] = moment().startOf('day').minutes(maxtime).format('h:mma');
		slidertime[3] = moment().startOf('day').minutes(mintime).format('h:mma');
		slidertime[4] = moment().startOf('day').minutes(maxtime).format('h:mma');
		slidertime[5] = moment().startOf('day').minutes(mintime).format('h:mma');
		slidertime[6] = moment().startOf('day').minutes(maxtime).format('h:mma');
		slidertime[7] = moment().startOf('day').minutes(mintime).format('h:mma');

	$('.slider-time0').text( slidertime[0] );
	$('.slider-time1').text( slidertime[1] );
	$('.slider-time2').text( slidertime[2] );
	$('.slider-time3').text( slidertime[3] );
	$('.slider-time4').text( slidertime[4] );
	$('.slider-time5').text( slidertime[5] );
	$('.slider-time6').text( slidertime[6] );
	$('.slider-time7').text( slidertime[7] );

	$(".slider-range0").slider({
		range: true,
		min: mintime,
		max: maxtime,
		step: steptime,
		values: [mintime, maxtime],

		slide: function (e, ui) {
					var time0 = moment().startOf('day').add('m', ui.values[0]).format('h:mma');
					var time1 = moment().startOf('day').add('m', ui.values[1]).format('h:mma');
					$('.slider-time0').html(time0);
					$('.slider-time1').html(time1);

				// show or hide badges based on attr for each badge
				// being mindful it may already be hidden by another filter
				//
				// add class 'filtered' and check that along with time to see if it should be hidden?


				$('div[id^="flight"]').each(function(e){
					if( $(this).data('departuretime0') >= ui.values[0] && $(this).data('departuretime0') <= ui.values[1]){
						$(this).show();
					} else {
						$(this).hide()
					}
				});
		}
	}); // slider-range0

	$(".slider-range1").slider({
		range: true,
		min: mintime,
		max: maxtime,
		step: steptime,
		values: [mintime, maxtime],

		slide: function (e, ui) {
					var time2 = moment().startOf('day').add('m', ui.values[0]).format('h:mma');
					var time3 = moment().startOf('day').add('m', ui.values[1]).format('h:mma');
					$('.slider-time2').html(time2);
					$('.slider-time3').html(time3);

				// show or hide badges based on attr for each badge
				$('div[id^="flight"]').each(function(e){
					if($(this).data('arrivaltime0') >= ui.values[0] && $(this).data('arrivaltime0') <= ui.values[1]){
						$(this).show();
					} else {
						$(this).hide()
					}
				});
		}
	}); // slider-range1




});
