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
	// grab the  min/max times from badge range so we can set in slider below
	// this would be dynamically populated
	var mintime = 330;
	var maxtime = 1173;

	var slidertime1 = moment().startOf('day').seconds(mintime*60).format('h:mma');
	var slidertime2 = moment().startOf('day').seconds(maxtime*60).format('h:mma');

	$('.slider-time').text( slidertime1 );
	$('.slider-time2').text( slidertime2 );

	$(".slider-range").slider({
		range: true,
		min: mintime,
		max: maxtime,
		step: 10,
		values: [mintime, maxtime],

		slide: function (e, ui) {
					var hours1 = Math.floor(ui.values[0] / 60);
					var minutes1 = ui.values[0] - (hours1 * 60);
					if (hours1.length == 1) hours1 = '0' + hours1;
					if (minutes1.length == 1) minutes1 = '0' + minutes1;
					if (minutes1 == 0) minutes1 = '00';
					if (hours1 >= 12) {
							if (hours1 == 12) {
									hours1 = hours1;
									minutes1 = minutes1 + " PM";
							} else {
									hours1 = hours1 - 12;
									minutes1 = minutes1 + " PM";
							}
					} else {
							hours1 = hours1;
							minutes1 = minutes1 + " AM";
					}
					if (hours1 == 0) {
							hours1 = 12;
							minutes1 = minutes1;
					}


				// set min time
				$('.slider-time').html(hours1 + ':' + minutes1);

					var hours2 = Math.floor(ui.values[1] / 60);
					var minutes2 = ui.values[1] - (hours2 * 60);

					if (hours2.length == 1) hours2 = '0' + hours2;
					if (minutes2.length == 1) minutes2 = '0' + minutes2;
					if (minutes2 == 0) minutes2 = '00';
					if (hours2 >= 12) {
							if (hours2 == 12) {
									hours2 = hours2;
									minutes2 = minutes2 + " PM";
							} else if (hours2 == 24) {
									hours2 = 11;
									minutes2 = "59 PM";
							} else {
									hours2 = hours2 - 12;
									minutes2 = minutes2 + " PM";
							}
					} else {
							hours2 = hours2;
							minutes2 = minutes2 + " AM";
					}

				// set the max time
				$('.slider-time2').html(hours2 + ':' + minutes2);



				// show or hide badges based on attr for each badge
				$('div[id^="flight"]').each(function(e){
					console.log( $(this).attr('takeofftime0' ) );
					console.log('Time: ' + ui.values[0] + ' to ' +  ui.values[1]);
					console.log( '-----------------' );
					if($(this).attr('takeofftime0') >= ui.values[0] && $(this).attr('takeofftime0') <= ui.values[1]){
						$(this).show();
					} else {
						$(this).hide()
					}
				});
		}
	});
});
