// ===============================================
// Air Time Sliders
// ===============================================
// Dependencies
// 	* jQuery UI Sliders : http://jqueryui.com/
// 	* Moment.js for handling times : http://momentjs.com/
// ===============================================
// Useful Resources for Sliders
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
	var maxtime = 1439;
	var steptime = 60;

	var slidertime1 = moment().startOf('day').seconds(mintime*60).format('h:mma');
	var slidertime2 = moment().startOf('day').seconds(maxtime*60).format('h:mma');

	$('.slider-time').text( slidertime1 );
	$('.slider-time2').text( slidertime2 );

	$(".slider-range").slider({
		range: true,
		min: mintime,
		max: maxtime,
		step: steptime,
		values: [mintime, maxtime],

		slide: function (e, ui) {
					var time1 = moment().startOf('day').add('m', ui.values[0]).format('h:mma');
					$('.slider-time').html(time1);

					var time2 = moment().startOf('day').add('m', ui.values[1]).format('h:mma');
					$('.slider-time2').html(time2);





				// show or hide badges based on attr for each badge
				$('div[id^="flight"]').each(function(e){
					// console.log( $(this).data('departuretime0') );
					// console.log('Time: ' + ui.values[0] + ' to ' +  ui.values[1]);
					// console.log( '-----------------' );
					if($(this).data('departuretime0') >= ui.values[0] && $(this).data('departuretime0') <= ui.values[1]){
						$(this).show();
					} else {
						$(this).hide()
					}
				});
		}
	});
});
