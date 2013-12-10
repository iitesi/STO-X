// ===============================================
// Air Time Sliders
// ===============================================
// Dependencies
// 	* jQuery UI Sliders : http://jqueryui.com/
// 	* Moment.js for handling times : http://momentjs.com/
// ===============================================

// TODO
// ===============================================
// see code in badge.cfm to populate the data-attributes for each badge with the min/max times for that badge
// that logic needs to be moved 'up' earlier in process (airParse) so we can grab min/max times here in JS
// grab the  min/max times from badge range so we can set in slider below
// this would be dynamically populated
// var mintime = 330;
// var maxtime = 1173;


// Useful Resources for Sliders
// ===============================================
// plugins
// http://isotope.metafizzy.co/docs/filtering.html
// http://tinysort.sjeiti.com/
// http://stackoverflow.com/questions/2558893/jquery-select-elements-with-value-between-x-and-y

// ding ding
// http://stackoverflow.com/questions/8880336/how-to-select-an-li-with-jquery-using-multiple-data-attributes-and-multiple-logi
// http://stackoverflow.com/questions/15912599/javascript-select-elements-with-data-value-in-range-of-x-and-y


//	http://www.jquery4u.com/data-manipulation/jquery-filter-objects-data-attribute/
// 	https://github.com/layervault/jquery.data.filter/blob/master/src/jquery.data.filter.js

// 	http://stanford.wikia.com/wiki/Kayak.com_Time_Slider
// 	http://stackoverflow.com/questions/4764844/how-do-i-show-hide-elements-using-jquery-when-there-are-two-intersecting-princip
// 	http://jsfiddle.net/danieltulp/gz5gN/42/
// 	http://jsfiddle.net/bZmJ8/11/
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
	var mintime = 0;
	var maxtime = 1440
	var steptime = 60;

	var takeoff0 = new Array();

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
			doShowHideBadges();
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
			doShowHideBadges();
		}
	}); // slider-range1
});


// div id="flight732914299"
// class="pull-left"
// data-departuretime1="1340"
// data-departuretime0="865"
// data-arrivaltime0="980"
// data-arrivaltime1="10"


	function doShowHideBadges(){
    //hide all initially then loop through each
    $('div[id^="flight"]').hide().each(function(e){

        //show items for first slider
        // var sliderValue1 = $('.slider-range0').slider("option", "values");
        // if($(this).data('departuretime0') >= sliderValue1[0] && $(this).data('departuretime0') <= sliderValue1[1]){
        //     $(this).show();
        // }

        // show items for second slider
        var sliderValue2 = $('.slider-range1').slider("option", "values");
         if($(this).data('arrivaltime0') >= sliderValue2[0] && $(this).data('arrivaltime0') <= sliderValue2[1]){
             $(this).show();
         }

        //other sliders
    });
	}
