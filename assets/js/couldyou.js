var shortstravel = {};
shortstravel.couldyou = {

	data: {},

	dates: {},

	setupDates: function( Search ){
		var dates = {};

		if( shortstravel.search.air == 1 ){
			var originalDepart = new Date( Search.departDateTime );
			var originalReturn = new Date( Search.arrivalDateTime );
		} else if( shortstravel.search.hotel == 1 ){
			var originalDepart = new Date( Search.checkInDate );
			var originalReturn = new Date( Search.checkOutDate );
		} else if( shortstravel.search.car == 1 ){
			var originalDepart = new Date( Search.carPickupDateTime );
			var originalReturn = new Date( Search.carDropoffDateTime );
		}
		originalDepart.setHours( 0,0,0,0 );
		originalReturn.setHours( 0,0,0,0 );

		var tripLength = Math.floor( (originalReturn.getTime() - originalDepart.getTime())/(1000*60*60*24) );

		dates.tripLength = tripLength;
		dates.originalDepart = originalDepart;
		dates.originalReturn = originalReturn;

		var preStart = new Date( dates.originalDepart );
		preStart.setDate( preStart.getDate() - 7);
		preStart.setHours( 0,0,0,0 );
		if( preStart.getTime() < new Date().getTime() ){
			preStart = new Date();
			preStart.setHours( 0,0,0,0 );
			preStart.setDate( preStart.getDate() + 1 );
		}
		dates.preStart = preStart;

		var preEnd = new Date( dates.originalDepart );
		preEnd.setDate( preEnd.getDate() - 1);
		preStart.setHours( 0,0,0,0 );
		dates.preEnd = preEnd;

		var postStart = new Date( dates.originalDepart );
		postStart.setDate( postStart.getDate() + 1);
		postStart.setHours( 0,0,0,0 );
		dates.postStart = postStart;

		var postEnd = new Date( dates.originalDepart );
		postEnd.setDate( postStart.getDate() + 7);
		postEnd.setHours( 0,0,0,0 );
		dates.postEnd = postEnd;

		return dates;

	},

	initializeDataStore: function( dates ){
		var dataStore = [];
		var preTripOffsetDays = Math.floor( ( dates.preStart.getTime() - dates.originalDepart.getTime())/(1000*60*60*24) );

		for( var i=preTripOffsetDays; i<=7; i++ ){
			var dayData = {};
			var departureDate = new Date( dates.originalDepart );
			departureDate.setHours( 0,0,0,0 );
			departureDate.setDate( departureDate.getDate() + i );

			var returnDate = new Date( departureDate );
			returnDate.setHours( 0,0,0,0 );
			returnDate.setDate( returnDate.getDate() + dates.tripLength );

			dayData.dataLoaded = false;
			dayData.departureDate = departureDate;
			dayData.returnDate = returnDate;
			dayData.offset = i;
			dayData.maxSavings = false;
			dayData.message = '';

			dataStore.push( dayData )
		}

		return dataStore;
	},

	getCouldYouForDate: function( searchId, requestedDate ){

		if( requestedDate.departureDate.getTime() == shortstravel.couldyou.dates.originalDepart.getTime() ){
			requestedDate.air = {};
			if( typeof shortstravel.itinerary.AIR == 'object' ){
				requestedDate.air[ "1" ] = shortstravel.itinerary.AIR;
			} else {
				requestedDate.air[ "1" ] = "";
			}
			if( typeof shortstravel.itinerary.HOTEL == 'object' ){
				requestedDate.hotel = shortstravel.itinerary.HOTEL;
			} else {
				requestedDate.hotel = "";
			}

			if( typeof shortstravel.itinerary.VEHICLE == 'object' ){
				requestedDate.vehicle = shortstravel.itinerary.VEHICLE;
			} else {
				requestedDate.vehicle = "";
			}
			requestedDate.dataLoaded = true;
			requestedDate.total = shortstravel.couldyou.calculateDailyTotal( requestedDate );
			requestedDate.message = shortstravel.couldyou.formatCurrency( requestedDate.total );

		} else {

			$.ajax({
				url: '/booking/RemoteProxy.cfc?method=couldYou&searchID=' + searchId + '&requestedDate=' + requestedDate.departureDate,
				dataType: 'json',
				success: function( data ){
					requestedDate.air = data.AIR;
					requestedDate.hotel = data.HOTEL;
					requestedDate.vehicle = data.CAR;
					requestedDate.dataLoaded = true;
					requestedDate.total = shortstravel.couldyou.calculateDailyTotal( requestedDate );

					if( requestedDate.air == "" || requestedDate.hotel == "" || requestedDate.vehicle == "" ){
						var missingServices = [];
						if( requestedDate.air == "" ){
							missingServices.push( 'flight' );
						}
						if( requestedDate.hotel == "" ){
							missingServices.push( 'hotel' );
						}
						if( requestedDate.vehicle == "" ){
							missingServices.push( 'car' );
						}
						requestedDate.message = missingServices.toString() + ' not available';
						requestedDate.message = requestedDate.message.replace( ",", ", ");

					} else {
						requestedDate.message = shortstravel.couldyou.formatCurrency( requestedDate.total );
					}

				},
				error: function(){
					requestedDate.air = '';
					requestedDate.hotel = '';
					requestedDate.vehicle = '';
					requestedDate.dataLoaded = true;
					requestedDate.total = 0;
					requestedDate.message = 'Itinerary not available';

				},
				complete: function(){
					//check to see if all calls have completed
					var completed = true;
					for( var i=0; i<shortstravel.couldyou.data.length; i++ ){
						var selectedDate = shortstravel.couldyou.data[i];
						if( !selectedDate.dataLoaded ){
							completed = false;
							break;
						}
					}

					if( completed ){
						$('#myModal').modal( 'hide' );
						shortstravel.couldyou.calculateMaxSavingDates();
						shortstravel.couldyou.updateCalendar();
						shortstravel.couldyou.buildAlternativesTable();

					}
				}
			})
		}
	},

	calculateDailyTotal: function( selectedDate ){

		var total = 0;

		//Get air total
		if( shortstravel.search.air == 1 && selectedDate.air != "" ){
			for( tripId in selectedDate.air ){
				var airTotal = selectedDate.air[ tripId ].TOTAL;
				if( typeof airTotal != 'number' ){
					airTotal = parseFloat( airTotal );
				}
				total = total + airTotal;
			}
		}

		//Get hotel total
		if( shortstravel.search.hotel == 1 && selectedDate.hotel != "" && selectedDate.hotel.Rooms.length ){
			var hotelTotal = 0;
			if( selectedDate.hotel.Rooms[ 0 ].totalForStay != 0 ){
				hotelTotal = selectedDate.hotel.Rooms[ 0 ].totalForStay;
			} else {
				var timeDiff = Math.abs(selectedDate.departureDate.getTime() - selectedDate.returnDate.getTime());
				var nights = Math.ceil(timeDiff / (1000 * 3600 * 24));
				hotelTotal = selectedDate.hotel.Rooms[0].dailyRate * nights;
			}
			total = total + hotelTotal;
		}

		//Get vehicle total
		if( shortstravel.search.car == 1 && selectedDate.vehicle != "" ){
			var vehicleTotal = selectedDate.vehicle.estimatedTotalAmount;
			if( typeof vehicleTotal != 'number' ){
				vehicleTotal = parseFloat( vehicleTotal );
			}
			total = total + vehicleTotal;
		}


		return Math.round(total * 100 ) / 100;
	},

	calculateMaxSavingDates: function(){
		var maxSavings = 0;
		for( var i=0; i<shortstravel.couldyou.data.length; i++ ){
			var selectedDate = shortstravel.couldyou.data[i];
			if( selectedDate.message.indexOf( 'not available' ) == -1 ){
				var dailySavings = ( Math.round( shortstravel.itinerary.total ) ) - ( Math.round( selectedDate.total ) );
				if( dailySavings > maxSavings ){
					maxSavings = dailySavings;
				}
			}
		}

		if( maxSavings > 0 ){
			for( var i=0; i<shortstravel.couldyou.data.length; i++ ){
				var selectedDate = shortstravel.couldyou.data[i];
				if( selectedDate.message.indexOf( 'not available' ) == -1 ){
					var dailySavings = ( Math.round( shortstravel.itinerary.total ) ) - ( Math.round( selectedDate.total ) );
					if( dailySavings == maxSavings ){
						selectedDate.maxSavings = true;
					}
				}
			}
		}
	},

	updateCalendar: function(){
		for( var i=0; i<shortstravel.couldyou.data.length; i++ ){
			var selectedDate = shortstravel.couldyou.data[i];
			var dateCell = $('td[data-date="' + dateFormat( selectedDate.departureDate, "yyyy-mm-dd" ) + '"]' );


			if( ( shortstravel.search.air == 1 && selectedDate.air == "" ) ||
				( shortstravel.search.hotel == 1 && selectedDate.hotel == "" ) ||
				( shortstravel.search.car == 1 && selectedDate.vehicle == "" ) ){
				var ev = {
					title: selectedDate.message.toString(),
					allDay: true,
					start: selectedDate.departureDate,
					color: '#efefef',
					textColor: "#000"

				}
				$('#calendar1').fullCalendar( 'renderEvent', $.extend(true, {}, ev), true );
				if( $("#calendar1").fullCalendar('getView').visEnd < shortstravel.couldyou.dates.postEnd ){
					if( selectedDate.departureDate.getTime() >= $("#calendar2").fullCalendar('getView').visStart.getTime() ){
						$('#calendar2').fullCalendar( 'renderEvent', $.extend(true, {}, ev), true );
					}
				}
				dateCell.removeClass('ui-widget-content' ).addClass('fc-notAvailable');
			} else {
				var selectedDayTotal = shortstravel.itinerary.total;
				var dailyTotal = selectedDate.total;

				if( Math.round( dailyTotal ) >= Math.round( selectedDayTotal ) && selectedDate.departureDate.getTime() != shortstravel.couldyou.dates.originalDepart.getTime() ){
					var ev = {
						title: selectedDate.message.toString(),
						allDay: true,
						start: selectedDate.departureDate,
						color: '#fcefef',
						textColor: "#000"

					}
					$('#calendar1').fullCalendar( 'renderEvent', $.extend(true, {}, ev), true );
					if( $("#calendar1").fullCalendar('getView').visEnd < shortstravel.couldyou.dates.postEnd ){
						if( selectedDate.departureDate.getTime() >= $("#calendar2").fullCalendar('getView').visStart.getTime() ){
							$('#calendar2').fullCalendar( 'renderEvent', $.extend(true, {}, ev), true );
						}
					}
					dateCell.removeClass('ui-widget-content' ).addClass('fc-higherPrice fc-selectable');
				} else if( Math.round( dailyTotal ) < Math.round( selectedDayTotal ) && selectedDate.departureDate.getTime() != shortstravel.couldyou.dates.originalDepart.getTime() ){
					if( selectedDate.maxSavings ){
						var eventColor = '#e1efe1';
						var cellClass = 'fc-maxSavings fc-selectable';
					} else {
						var eventColor = '#e2effc';
						var cellClass = 'fc-lowerPrice fc-selectable';
					}


					var ev = {
						title: selectedDate.message.toString(),
						allDay: true,
						start: selectedDate.departureDate,
						color: eventColor,
						textColor: "#000"

					}
					$('#calendar1').fullCalendar( 'renderEvent', $.extend(true, {}, ev), true );

					if( $("#calendar1").fullCalendar('getView').visEnd < shortstravel.couldyou.dates.postEnd ){
						if( selectedDate.returnDate.getTime() >= $("#calendar2").fullCalendar('getView').visStart.getTime() ){
							$('#calendar2').fullCalendar( 'renderEvent', $.extend(true, {}, ev), true );
						}
					}
					dateCell.removeClass('ui-widget-content' ).addClass( cellClass);

				} else {
					var ev = {
						title: selectedDate.message.toString(),
						allDay: true,
						start: selectedDate.departureDate,
						color: '#fff',
						textColor: "#000"

					}
					$('#calendar1').fullCalendar( 'renderEvent', $.extend(true, {}, ev), true );
					if( $("#calendar1").fullCalendar('getView').visEnd < shortstravel.couldyou.dates.postEnd ){
						if( selectedDate.returnDate.getTime() >= $("#calendar2").fullCalendar('getView').visStart.getTime() ){
							$('#calendar2').fullCalendar( 'renderEvent', $.extend(true, {}, ev), true );
						}
					}
				}

				if( selectedDate.departureDate.getTime() == shortstravel.couldyou.dates.originalDepart.getTime() ){
					$('td[data-date="' + dateFormat( selectedDate.departureDate, "yyyy-mm-dd" ) + '"]' ).addClass( 'selected  fc-selectable' );
				}

			}

		}
	},

	buildAlternativesTable: function(){
		var numCheaperDates = 0;

		for( var i=0; i<shortstravel.couldyou.data.length; i++ ){
			var selectedDate = shortstravel.couldyou.data[i];

			if( ( shortstravel.search.air == 1 && selectedDate.air == "" ) ||
				( shortstravel.search.hotel == 1 && selectedDate.hotel == "" ) ||
				( shortstravel.search.car == 1 && selectedDate.vehicle == "" ) ){

				var row = '<tr id="' + dateFormat( selectedDate.departureDate, 'yyyy-mm-dd' ) + '" class="fc-notAvailable">';
				row += '<td>' + selectedDate.message + '</td>'
				row += '<td>&nbsp;-&nbsp;</td>';

			} else {
				var row = '<tr id="' + dateFormat( selectedDate.departureDate, 'yyyy-mm-dd' ) + '" ';
				if ( selectedDate.departureDate.getTime() == shortstravel.couldyou.dates.originalDepart.getTime() ){
					row += ' class="fc-originalDate selected fc-selectable">'
				} else if( Math.round( selectedDate.total ) >= Math.round( shortstravel.itinerary.total )){
					row += ' class="fc-higherPrice fc-selectable">'
				} else if( Math.round( selectedDate.total ) < Math.round( shortstravel.itinerary.total ) ){
					numCheaperDates++;
					if( selectedDate.maxSavings ){
						row += ' class="fc-maxSavings fc-selectable">';
					} else {
						row += ' class="fc-lowerPrice fc-selectable">';
					}
				} else {
					row += '>'
				}
				row += '<td>' + selectedDate.message +'</td>';
				row += '<td>';
				if( selectedDate.message != 'Itinerary not available'){
					row += shortstravel.couldyou.formatCurrency( Math.abs( Math.round( shortstravel.itinerary.total - selectedDate.total ) ) );
				}
				if( Math.round( shortstravel.itinerary.total - selectedDate.total ) > 0 ){
					row += ' savings';
				} else if( Math.round( shortstravel.itinerary.total - selectedDate.total ) < 0 ){
					row += ' more'
				} else if( selectedDate.message == 'Itinerary not available' ){
					row += ' '
				}

				row += '</td>';
			}

			row += '<td>' + dateFormat( selectedDate.departureDate, "ddd, mmm dd" ) + '</td>';
			row += '<td>';
			if( shortstravel.search.airType != 'OW' ){
				row += dateFormat( selectedDate.returnDate, "ddd, mmm dd" )
			}
			row += '</td>';
			row += '</tr>'

			$("#alternativesTable tbody" ).append( row );
		}

		$( '#numCheaperDates' ).html( numCheaperDates + ' cheaper dates found' );

		$("#alternativesTable tr" ).on( "click", function(){
			if( !$( this ).hasClass( 'fc-notAvailable' ) ){
				var dateParts = $( this ).attr( 'id' ).split('-');
				// console.dir( dateParts );
				var d = new Date( dateParts[0], dateParts[1]-1, dateParts[2], 0, 0, 0);
				// console.log( d );
				shortstravel.couldyou.changeDate( d );
			};
		})
	},

	changeDate: function( newDate ){

		for( var i=0; i<shortstravel.couldyou.data.length; i++ ){
			if( shortstravel.couldyou.data[i].departureDate.getTime() == newDate.getTime() ){
				var selectedDate = shortstravel.couldyou.data[i];
				break;
			}
		}

		if( !( newDate.getTime() < shortstravel.couldyou.dates.preStart.getTime()  || newDate.getTime() > shortstravel.couldyou.dates.postEnd.getTime() )
			&& selectedDate.message.indexOf( 'not available' ) == -1 )
		{
			$('.tripStartDate' ).html( dateFormat( selectedDate.departureDate, "ddd, mmm dd" ) );
			if( shortstravel.search.airType != 'OW' ){
				$('.tripEndDate' ).html( dateFormat( selectedDate.returnDate, "ddd, mmm dd" ) );
			}

			$('#tripTotal' ).html( shortstravel.couldyou.formatCurrency( selectedDate.total, 2 ));

			if( shortstravel.search.air == 1 ){
				var airTotal = 0;
				var airTaxes = 0;
				var airBaseRate = 0;

				for( var tripId in selectedDate.air ){
					airBaseRate += parseFloat( selectedDate.air[tripId].BASE );
					airTaxes += parseFloat( selectedDate.air[tripId].TAXES );
					airTotal += parseFloat( selectedDate.air[tripId].TOTAL );
				}

				$('#airBaseRate' ).html( shortstravel.couldyou.formatCurrency( airBaseRate, 2 ) );
				$('#airTaxes' ).html( shortstravel.couldyou.formatCurrency( airTaxes, 2 ) );
				$('#airTotal' ).html( shortstravel.couldyou.formatCurrency( airTotal, 2 ) );
			}

			if( shortstravel.search.hotel == 1 ){

				var hotelTotal = 0;
				if( selectedDate.hotel.Rooms[ 0 ].totalForStay != 0 ){
					hotelTotal = selectedDate.hotel.Rooms[ 0 ].totalForStay;
					$('#hotelBaseRate' ).html('');
				} else {
					var timeDiff = Math.abs(selectedDate.departureDate.getTime() - selectedDate.returnDate.getTime());
					var nights = Math.ceil(timeDiff / (1000 * 3600 * 24));
					hotelTotal = selectedDate.hotel.Rooms[0].dailyRate * nights;
					$('#hotelBaseRate' ).html( shortstravel.couldyou.formatCurrency( selectedDate.hotel.Rooms[0].dailyRate, 2 ) );
				}

				$('#hotelTotal' ).html( shortstravel.couldyou.formatCurrency( hotelTotal, 2 ) );
				if( selectedDate.hotel.Rooms[0].totalForStay > 0 ){
					$('#hotelTaxes' ).html( 'Including taxes' );
				} else {
					$('#hotelTaxes' ).html( 'Quoted at checkin' );
				}

				if( selectedDate.hotel.Rooms[0].ratePlanType != shortstravel.itinerary.HOTEL.Rooms[0].ratePlanType ){
					$( '#alert-text' ).html(
						'<b>WARNING!</b> The room type for this date is different than your original.<br>Original: '
						+ shortstravel.itinerary.HOTEL.Rooms[0].description.toUpperCase()
						+ '<br>Selected: '
						+ selectedDate.hotel.Rooms[0].description.toUpperCase()
					);
					$( '#alert-wrapper' ).removeClass( 'hide' );
				} else {
					$( '#alert-wrapper' ).addClass( 'hide' );
					$( '#alert-text' ).html( '' );
				}
			}

			if( shortstravel.search.car == 1 ){
				$('#carTotal' ).html( shortstravel.couldyou.formatCurrency( selectedDate.vehicle.estimatedTotalAmount, 2 ) );
			}

			$('.selected' ).removeClass('selected');
			$('#' + dateFormat( newDate, 'yyyy-mm-dd' ) ).addClass( 'selected' );
			$('td[data-date="' + dateFormat( newDate, 'yyyy-mm-dd' ) + '"]' ).addClass( 'selected' );
			$("#btnContinuePurchase" ).val( dateFormat( newDate, "mm-dd-yyyy" ) );

		}
	},

	formatCurrency: function( cost, places ){

		if( typeof places != "number" ){
			places = 0;
		}
		var roundedCost = ( Math.round( cost * (Math.pow(10,places)) ) / (Math.pow(10,places)) );
		if( places != 0 ){
			roundedCost = roundedCost.toFixed( places );
		}

		if( typeof shortstravel.itinerary.AIR == 'object' ){
			return '$ ' + roundedCost;
		} else {
			if( typeof shortstravel.itinerary.HOTEL != 'undefined' ){
				if( shortstravel.itinerary.HOTEL.Rooms[0].totalForStayCurrency == 'USD' || shortstravel.itinerary.HOTEL.Rooms[0].dailyRateCurrency == 'USD' ){
					return '$ ' + roundedCost;
				} else {
					return roundedCost + shortstravel.itinerary.HOTEL.rooms[0].dailyRateCurrency;
				}
			}
			if( typeof shortstravel.itinerary.VEHICLE != 'undefined' ){
				if( shortstravel.itinerary.VEHICLE.currency == 'USD' ){
					return '$ ' + roundedCost;
				} else {
					return roundedCost + shortstravel.itinerary.VEHICLE.currency;
				}
			}

		}

	},

	continueToPurchase: function(){
		window.location = '/booking/index.cfm?action=couldyou.processSelection&searchId=' + shortstravel.search.searchID
			+ "&originalDate=" + dateFormat( shortstravel.couldyou.dates.originalDepart, 'mm-dd-yyyy', true )
			+ "&selectedDate=" + $("#btnContinuePurchase" ).val();
	}
};

$(document).ready(function(){
	$('#myModal').modal();
	shortstravel.couldyou.dates = shortstravel.couldyou.setupDates( shortstravel.search );
	shortstravel.couldyou.data = shortstravel.couldyou.initializeDataStore( shortstravel.couldyou.dates );

	$('#calendar1').fullCalendar({
        theme: true,
        header: {
        	left: '',
        	center: 'title',
        	right: ''
        },

        dayClick: function( date, allDay, jsEvent, view ) {
        	// console.log( date );
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

	for( var i=0; i<shortstravel.couldyou.data.length; i++ ){
		shortstravel.couldyou.getCouldYouForDate( shortstravel.search.searchID, shortstravel.couldyou.data[i] );
	}
})