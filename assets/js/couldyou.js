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
		preStart.setDate( preStart.getDate() - 7);
		preStart.setHours( 0,0,0,0 );
		if( preStart.getTime() < new Date().getTime() ){
			preStart = new Date();
			preStart.setHours( 0,0,0,0 );
			preStart.setDate( preStart.getDate() + 1 );
		}
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

		var preTripOffsetDays = Math.floor( ( preStart.getTime() - originalDepart.getTime())/(1000*60*60*24) );

		for( var i=preTripOffsetDays; i<=7; i++ ){
			var d = new Date( shortstravel.couldyou.dates.originalDepart );
			d.setHours( 0,0,0,0 );
			d.setDate( d.getDate() + i );
			shortstravel.couldyou.data[ dateFormat( d, 'mm-dd-yyyy' ) ] = {};
			shortstravel.couldyou.data[ dateFormat( d, 'mm-dd-yyyy' ) ].dataLoaded = false;
		}

	},

	getCouldYouForDate: function( searchId, requestedDate ){
		shortstravel.couldyou.data[ requestedDate ].departureDate = new Date( requestedDate );
		shortstravel.couldyou.data[ requestedDate ].departureDate.setHours( 0,0,0,0 );
		shortstravel.couldyou.data[ requestedDate ].arrivalDate = new Date( requestedDate );
		shortstravel.couldyou.data[ requestedDate ].arrivalDate.setHours( 0,0,0,0 );
		shortstravel.couldyou.data[ requestedDate ].arrivalDate.setDate( shortstravel.couldyou.data[ requestedDate ].arrivalDate.getDate() + shortstravel.couldyou.dates.tripLength);

		if( shortstravel.couldyou.data[ requestedDate ].departureDate.getTime() == shortstravel.couldyou.dates.originalDepart.getTime() ){
			shortstravel.couldyou.data[ requestedDate ].air = {};
			if( typeof shortstravel.itinerary.AIR == 'object' ){
				shortstravel.couldyou.data[ requestedDate ].air[ "1" ] = shortstravel.itinerary.AIR;
			} else {
				shortstravel.couldyou.data[ requestedDate ].air[ "1" ] = "";
			}
			if( typeof shortstravel.itinerary.HOTEL == 'object' ){
				shortstravel.couldyou.data[ requestedDate ].hotel = shortstravel.itinerary.HOTEL;
			} else {
				shortstravel.couldyou.data[ requestedDate ].hotel = "";
			}

			if( typeof shortstravel.itinerary.VEHICLE == 'object' ){
				shortstravel.couldyou.data[ requestedDate ].vehicle = shortstravel.itinerary.VEHICLE;
			} else {
				shortstravel.couldyou.data[ requestedDate ].vehicle = "";
			}
			shortstravel.couldyou.data[ requestedDate ].dataLoaded = true;
			shortstravel.couldyou.data[ requestedDate ].total = shortstravel.couldyou.calculateDailyTotal( requestedDate );
			shortstravel.couldyou.data[ requestedDate ].message = shortstravel.couldyou.formatCurrency( shortstravel.couldyou.data[requestedDate].total );

		} else {

			$.getJSON( '/booking/RemoteProxy.cfc?method=couldYou&searchID=' + searchId + '&requestedDate=' + requestedDate, function( data ){
				shortstravel.couldyou.data[ requestedDate ].air = data.AIR;
				shortstravel.couldyou.data[ requestedDate ].hotel = data.HOTEL;
				shortstravel.couldyou.data[ requestedDate ].vehicle = data.CAR;
				shortstravel.couldyou.data[ requestedDate ].dataLoaded = true;
				shortstravel.couldyou.data[ requestedDate ].total = shortstravel.couldyou.calculateDailyTotal( requestedDate );

				if( shortstravel.couldyou.data[ requestedDate ].air == "" || shortstravel.couldyou.data[ requestedDate ].hotel == "" || shortstravel.couldyou.data[ requestedDate ].vehicle == "" ){
					var missingServices = [];
					if( shortstravel.couldyou.data[ requestedDate ].air == "" ){
						missingServices.push( 'flight' );
					}
					if( shortstravel.couldyou.data[ requestedDate ].hotel == "" ){
						missingServices.push( 'hotel' );
					}
					if( shortstravel.couldyou.data[ requestedDate ].vehicle == "" ){
						missingServices.push( 'car' );
					}
					shortstravel.couldyou.data[ requestedDate ].message = missingServices.toString() + ' not available';
					shortstravel.couldyou.data[ requestedDate ].message = shortstravel.couldyou.data[ requestedDate ].message.replace( ",", ", ");

				} else {
					shortstravel.couldyou.data[ requestedDate ].message = shortstravel.couldyou.formatCurrency( shortstravel.couldyou.data[requestedDate].total );
				}

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
		}
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


		return Math.round(total * 100 ) / 100;
	},

	updateCalendar: function(){

		for( var prop in shortstravel.couldyou.data ){
			//convert our date string to the format used by the class system in fullcalendar
			var d = new Date( prop );
			d.setHours( 0,0,0,0 );

			var className = dateFormat( d, 'yyyy-mm-dd' );
			var dateCell = $('td[data-date="' + className + '"]' );


			if( ( shortstravel.search.air == 1 && shortstravel.couldyou.data[ prop ].air == "" ) ||
				( shortstravel.search.hotel == 1 && shortstravel.couldyou.data[ prop ].hotel == "" ) ||
				( shortstravel.search.car == 1 && shortstravel.couldyou.data[ prop ].vehicle == "" ) ){
				var ev = {
					title: shortstravel.couldyou.data[ prop ].message.toString(),
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

				if( Math.round( dailyTotal ) >= Math.round( selectedDayTotal ) && d.getTime() != shortstravel.couldyou.dates.originalDepart.getTime() ){
					var ev = {
						title: shortstravel.couldyou.data[ prop ].message.toString(),
						allDay: true,
						start: d,
						color: '#fcefef',
						textColor: "#000"

					}
					$('#calendar1').fullCalendar( 'renderEvent', ev, true );
					dateCell.removeClass('ui-widget-content' ).addClass('fc-higherPrice');
				} else if( Math.round( dailyTotal ) < Math.round( selectedDayTotal ) && d.getTime() != shortstravel.couldyou.dates.originalDepart.getTime() ){
					var ev = {
						title: shortstravel.couldyou.data[ prop ].message.toString(),
						allDay: true,
						start: d,
						color: '#e2effc',
						textColor: "#000"

					}
					$('#calendar1').fullCalendar( 'renderEvent', ev, true );
					dateCell.removeClass('ui-widget-content' ).addClass('fc-lowerPrice');

				} else {
					var ev = {
						title: shortstravel.couldyou.data[ prop ].message.toString(),
						allDay: true,
						start: d,
						color: '#fff',
						textColor: "#000"

					}
					$('#calendar1').fullCalendar( 'renderEvent', ev, true );
				}

				if( d.getTime() == shortstravel.couldyou.dates.originalDepart.getTime() ){
					$('td[data-date="' + dateFormat( d, 'yyyy-mm-dd' ) + '"]' ).addClass( 'selected' );
				}

			}

		}
	},

	buildAlternativesTable: function(){
		var numCheaperDates = 0;

		for( var prop in shortstravel.couldyou.data ){
			if( ( shortstravel.search.air == 1 && shortstravel.couldyou.data[ prop ].air == "" ) ||
				( shortstravel.search.hotel == 1 && shortstravel.couldyou.data[ prop ].hotel == "" ) ||
				( shortstravel.search.car == 1 && shortstravel.couldyou.data[ prop ].vehicle == "" ) ){

				var row = '<tr id="' + prop + '" class="fc-notAvailable">';
				row += '<td>' + shortstravel.couldyou.data[ prop ].message + '</td>'
				row += '<td>&nbsp;-&nbsp;</td>';

			} else {
				var row = '<tr id="' + prop + '" ';
				if ( shortstravel.couldyou.data[ prop ].departureDate.getTime() == shortstravel.couldyou.dates.originalDepart.getTime() ){
					row += ' class="fc-originalDate selected">'
				} else if( Math.round( shortstravel.couldyou.data[ prop ].total ) >= Math.round( shortstravel.itinerary.total )){
					row += ' class="fc-higherPrice">'
				} else if( Math.round( shortstravel.couldyou.data[ prop ].total ) < Math.round( shortstravel.itinerary.total ) ){
					numCheaperDates++;
					row += ' class="fc-lowerPrice">'
				} else {
					row += '>'
				}
				row += '<td>' + shortstravel.couldyou.data[ prop ].message +'</td>';
				row += '<td>' + shortstravel.couldyou.formatCurrency( Math.round( shortstravel.itinerary.total - shortstravel.couldyou.data[prop].total ) ) + '</td>';
			}

			row += '<td>' + dateFormat( shortstravel.couldyou.data[prop].departureDate, "ddd, mmm dd" ) + '</td>';
			row += '<td>' + dateFormat( shortstravel.couldyou.data[prop].arrivalDate, "ddd, mmm dd" ) + '</td>';
			row += '</tr>'

			$("#alternativesTable tbody" ).append( row );
		}

		$( '#numCheaperDates' ).html( numCheaperDates + ' cheaper dates found' );

		$("#alternativesTable tr" ).on( "click", function(){
			if( !$( this ).hasClass( 'fc-notAvailable' ) ){
				var d = new Date( $( this ).attr( 'id' ) );
				d.setHours( 0,0,0,0 );
				shortstravel.couldyou.changeDate( d );
			};
		})
	},

	changeDate: function( newDate ){
		var prop = dateFormat( newDate, 'mm-dd-yyyy' );
		if( !( newDate.getTime() < shortstravel.couldyou.dates.preStart.getTime()  || newDate.getTime() > shortstravel.couldyou.dates.postEnd.getTime() )
			&& shortstravel.couldyou.data[ prop ].message.indexOf( 'not available' ) == -1 )
		{
			$('#tripStartDate' ).html( dateFormat( shortstravel.couldyou.data[ prop ].departureDate, "ddd, mmm dd" ) );
			$('#tripEndDate' ).html( dateFormat( shortstravel.couldyou.data[ prop ].arrivalDate, "ddd, mmm dd" ) );

			$('#tripTotal' ).html( shortstravel.couldyou.formatCurrency( shortstravel.couldyou.data[ prop ].total, 2 ));

			if( shortstravel.search.air == 1 ){
				var airTotal = 0;
				var airTaxes = 0;
				var airBaseRate = 0;

				for( var tripId in shortstravel.couldyou.data[ prop ].air ){
					airBaseRate += parseFloat( shortstravel.couldyou.data[ prop ].air[tripId].BASE );
					airTaxes += parseFloat( shortstravel.couldyou.data[ prop ].air[tripId].TAXES );
					airTotal += parseFloat( shortstravel.couldyou.data[ prop ].air[tripId].TOTAL );
				}

				$('#airBaseRate' ).html( shortstravel.couldyou.formatCurrency( airBaseRate, 2 ) );
				$('#airTaxes' ).html( shortstravel.couldyou.formatCurrency( airTaxes, 2 ) );
				$('#airTotal' ).html( shortstravel.couldyou.formatCurrency( airTotal, 2 ) );
			}

			if( shortstravel.search.hotel == 1 ){
				if( shortstravel.couldyou.data[prop].hotel.Rooms[0].totalForStay > 0 ){
					$('#hotelTaxes' ).html( 'Including taxes' );
					$('#hotelTotal' ).html( shortstravel.couldyou.formatCurrency( shortstravel.couldyou.data[prop].hotel.Rooms[0].totalForStay, 2 ) );
				} else {
					$('#hotelTaxes' ).html( 'Quoted at checkin' );
					$('#hotelTotal' ).html( shortstravel.couldyou.formatCurrency( shortstravel.couldyou.data[prop].hotel.Rooms[0].baseRate, 2 ) );
				}
			}

			if( shortstravel.search.car == 1 ){
				$('#carTotal' ).html( shortstravel.couldyou.formatCurrency( shortstravel.couldyou.data[prop].vehicle.estimatedTotalAmount, 2 ) );
			}

			$('.selected' ).removeClass('selected');
			$('#' + dateFormat( newDate, 'mm-dd-yyyy' ) ).addClass( 'selected' );
			$('td[data-date="' + dateFormat( newDate, 'yyyy-mm-dd' ) + '"]' ).addClass( 'selected' );

		}
	},

	formatCurrency: function( cost, places ){
		if( typeof places != "number" ){
			places = 0;
		}
		var roundedCost = ( Math.round( cost * (Math.pow(10,places)) ) / (Math.pow(10,places)) ).toFixed(2);

		if( typeof shortstravel.itinerary.AIR == 'object' ){
			return '$ ' + roundedCost;
		} else {

			if( shortstravel.itinerary.VEHICLE.currency == 'USD' ){
				return '$ ' + roundedCost;
			} else {
				return roundedCost + shortstravel.itinerary.VEHICLE.currency;
			}
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
			shortstravel.couldyou.changeDate( date );
		}
    })

	$('#calendar1').fullCalendar( "gotoDate", shortstravel.couldyou.dates.preStart );
	$('.ui-state-highlight' ).removeClass( 'ui-state-highlight' );

	if( $("#calendar1").fullCalendar('getView').visEnd < shortstravel.couldyou.dates.postEnd ){

		$('#calendar2').fullCalendar({
			theme: true,
			header: {
				left: '',
				center: 'title',
				right: ''
			},

			dayClick: function( date, allDay, jsEvent, view ) {
				shortstravel.couldyou.changeDate( date );
			}
		})

		$('#calendar2').fullCalendar( "gotoDate", shortstravel.couldyou.dates.postEnd );
		$('.ui-state-highlight' ).removeClass( 'ui-state-highlight' );
	}

	for( var prop in shortstravel.couldyou.data ){
		shortstravel.couldyou.getCouldYouForDate( shortstravel.search.searchID, prop );
	}

})