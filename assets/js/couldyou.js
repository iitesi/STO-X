var shortstravel = {};
shortstravel.couldyou = {

	data: {},

	dates: {},

	setupDates: function( searchDepartDate ){
		shortstravel.couldyou.dates.maxSavings = [];
		var originalDepart = new Date( shortstravel.search.departDateTime );
		originalDepart.setHours( 0,0,0,0 );
		var originalReturn = new Date( shortstravel.search.arrivalDateTime );
		originalReturn.setHours( 0,0,0,0 );
		var tripLength = Math.floor( (originalReturn.getTime() - originalDepart.getTime())/(1000*60*60*24) );

		shortstravel.couldyou.dates.tripLength = tripLength;
		shortstravel.couldyou.dates.originalDepart = originalDepart;

		var preStart = new Date( shortstravel.couldyou.dates.originalDepart );
		//TODO: Add logic here to make sure 7 days prior isn't before the current date
		preStart.setDate( preStart.getDate() - 7);
		preStart.setHours( 0,0,0,0 );
		shortstravel.couldyou.dates.preStart = preStart;

		var preEnd = new Date( shortstravel.couldyou.dates.originalDepart );
		preEnd.setDate( preEnd.getDate() - 1);
		preStart.setHours( 0,0,0,0 );
		shortstravel.couldyou.dates.preEnd = preEnd;

		var postStart = new Date( shortstravel.couldyou.dates.originalDepart );
		postStart.setDate( postStart.getDate() + 1);
		postStart.setHours( 0,0,0,0 );
		shortstravel.couldyou.dates.postStart = postStart;

		var postEnd = new Date( shortstravel.couldyou.dates.originalDepart );
		postEnd.setDate( postStart.getDate() + 6);
		postEnd.setHours( 0,0,0,0 );
		shortstravel.couldyou.dates.postEnd = postEnd;

		for( var i=-7; i<=7; i++ ){
			if( i != 0 ){
				var d = new Date( shortstravel.couldyou.dates.originalDepart );
				d.setDate( d.getDate() + i );
				shortstravel.couldyou.data[ dateFormat( d, 'mm-dd-yyyy' ) ] = {};
				shortstravel.couldyou.data[ dateFormat( d, 'mm-dd-yyyy' ) ].dataLoaded = false;
			}
		}

	},

	getCouldYouForDate: function( searchId, requestedDate ){
		$.getJSON( '/booking/RemoteProxyMock.cfc?method=couldYou&searchID=' + searchId + '&requestedDate=' + requestedDate, function( data ){
			shortstravel.couldyou.data[ requestedDate ].air = data.AIR;
			shortstravel.couldyou.data[ requestedDate ].hotel = data.HOTEL;
			shortstravel.couldyou.data[ requestedDate ].vehicle = data.CAR;
			shortstravel.couldyou.data[ requestedDate ].dataLoaded = true;
			shortstravel.couldyou.data[ requestedDate ].total = shortstravel.couldyou.calculateDailyTotal( requestedDate );
			shortstravel.couldyou.data[ requestedDate ].departureDate = new Date( requestedDate );
			shortstravel.couldyou.data[ requestedDate ].departureDate.setHours( 0,0,0,0 );
			shortstravel.couldyou.data[ requestedDate ].arrivalDate = new Date( requestedDate );
			shortstravel.couldyou.data[ requestedDate ].arrivalDate.setHours( 0,0,0,0 );
			shortstravel.couldyou.data[ requestedDate ].arrivalDate.setDate( shortstravel.couldyou.data[ requestedDate ].arrivalDate.getDate() + shortstravel.couldyou.dates.tripLength);

			//check to see if all calls have completed
			var completed = true;
			for( var prop in shortstravel.couldyou.data ){
				if( !shortstravel.couldyou.data[ prop ].dataLoaded ){
					completed = false;
					break;
				}
			}

			if( completed ){
				shortstravel.couldyou.updateCalendar();
				shortstravel.couldyou.buildAlternativesTable();
				$('#myModal').modal( 'hide' );
			}
		})

	},

	calculateDailyTotal: function( selectedDate ){

		var total = 0;

		//Get air total
		if( shortstravel.search.air == 1 && shortstravel.couldyou.data[ selectedDate ].air != "" ){
			for( tripId in shortstravel.couldyou.data[ selectedDate ].air ){
				var airTotal = shortstravel.couldyou.data[ selectedDate ].air[ tripId ].TOTAL;
				if( typeof airTotal != 'number' ){
					airTotal = parseFloat( airTotal );
				}
				total = total + airTotal;
			}
		}

		//Get hotel total
		if( shortstravel.search.hotel == 1 && shortstravel.couldyou.data[ selectedDate ].hotel != "" ){
			var hotelTotal = shortstravel.couldyou.data[ selectedDate ].hotel.Rooms[ 0 ].totalForStay;
			total = total + hotelTotal;
		}

		//Get vehicle total
		if( shortstravel.search.car == 1 && shortstravel.couldyou.data[ selectedDate ].air != "" ){
			var vehicleTotal = shortstravel.couldyou.data[ selectedDate ].vehicle.estimatedTotalAmount;
			if( typeof vehicleTotal != 'number' ){
				vehicleTotal = parseFloat( vehicleTotal );
			}
			total = total + vehicleTotal;
		}


		return Math.round(total);
	},

	updateCalendar: function(){

		for( var prop in shortstravel.couldyou.data ){
			//convert our date string to the format used by the class system in fullcalendar
			var d = new Date( prop );
			var className = dateFormat( d, 'yyyy-mm-dd' );
			var dateCell = $('td[data-date="' + className + '"]' );

			if( shortstravel.couldyou.data[ prop ].air == "" || shortstravel.couldyou.data[ prop ].hotel == "" || shortstravel.couldyou.data[ prop ].vehicle == "" ){
				var ev = {
					title: 'Not available',
					allDay: true,
					start: d,
					color: '#efefef',
					textColor: "#000"

				}
				$('#calendar1').fullCalendar( 'renderEvent', ev, true );
				dateCell.removeClass('ui-widget-content' ).addClass('fc-notAvailable');
			} else {
				var selectedDayTotal = shortstravel.itinerary.total;
				var dailyTotal = shortstravel.couldyou.data[ prop ].total;

				if( dailyTotal >= selectedDayTotal ){
					var ev = {
						title: '$' + dailyTotal,
						allDay: true,
						start: d,
						color: '#fcefef',
						textColor: "#000"

					}
					$('#calendar1').fullCalendar( 'renderEvent', ev, true );
					dateCell.removeClass('ui-widget-content' ).addClass('fc-higherPrice');
				} else {
					var ev = {
						title: '$' + dailyTotal,
						allDay: true,
						start: d,
						color: '#e2effc',
						textColor: "#000"

					}
					$('#calendar1').fullCalendar( 'renderEvent', ev, true );
					dateCell.removeClass('ui-widget-content' ).addClass('fc-lowerPrice');

				}

			}

		}
	},

	buildAlternativesTable: function(){

		for( var prop in shortstravel.couldyou.data ){

			if( shortstravel.couldyou.data[ prop ].air == "" || shortstravel.couldyou.data[ prop ].hotel == "" || shortstravel.couldyou.data[ prop ].vehicle == "" ){
				var row = '<tr class="fc-notAvailable">';
				var missingServices = [];
				if( shortstravel.couldyou.data[ prop ].air == "" ){
					missingServices.push( 'flight' );
				}
				if( shortstravel.couldyou.data[ prop ].hotel == "" ){
					missingServices.push( 'hotel' );
				}
				if( shortstravel.couldyou.data[ prop ].vehicle == "" ){
					missingServices.push( 'car' );
				}
				row += '<td>' + missingServices.toString() + ' not available</td>'
				row += '<td>&nbsp;-&nbsp;</td>';

			} else {
				var row = '<tr';
				if( shortstravel.couldyou.data[ prop ].total >= shortstravel.itinerary.total ){
					row += ' class="fc-higherPrice">'
				} else if( shortstravel.couldyou.data[ prop ].total < shortstravel.itinerary.total ){
					row += ' class="fc-lowerPrice">'
				} else {
					row += '>'
				}
				row += '<td>' + shortstravel.couldyou.data[prop].total +'</td>';
				row += '<td>' + Math.round( shortstravel.couldyou.data[prop].total - shortstravel.itinerary.total ) + '</td>';
			}

			row += '<td>' + dateFormat( shortstravel.couldyou.data[prop].departureDate, "ddd, mmm dd" ) + '</td>';
			row += '<td>' + dateFormat( shortstravel.couldyou.data[prop].arrivalDate, "ddd, mmm dd" ) + '</td>';
			row += '</tr>'

			$("#alternativesTable tbody" ).append( row );
		}

	}

};

$(document).ready(function(){
	$('#myModal').modal();
	shortstravel.couldyou.setupDates();

	$('#calendar1').fullCalendar({
        theme: true,
        header: {
        	left: '',
        	center: 'title',
        	right: ''
        },

        dayClick: function( date, allDay, jsEvent, view ) {

        	if( !( date.getTime() == shortstravel.couldyou.dates.originalDepart.getTime() || date.getTime() < shortstravel.couldyou.dates.preStart.getTime()  || date.getTime() > shortstravel.couldyou.dates.postEnd.getTime() ) ){

			}
		}
    })

	$('#calendar1').fullCalendar( "gotoDate", shortstravel.couldyou.dates.originalDepart );
	$('.ui-state-highlight' ).removeClass( 'ui-state-highlight' );

	for( var i=-7; i<8; i++ ){
		if( i != 0 ){
			var d = new Date( shortstravel.couldyou.dates.originalDepart );
			d.setDate( d.getDate() + i );
			shortstravel.couldyou.getCouldYouForDate( shortstravel.search.searchID, dateFormat( d, 'mm-dd-yyyy' ) );
		}
	}

})