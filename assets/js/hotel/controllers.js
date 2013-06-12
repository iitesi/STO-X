var controllers = angular.module('app.controllers',[]);

controllers.controller( "HotelCtrl", function( $scope, $location, SearchService, HotelService ){
	/* Scope variables that will be used to modify state of items in the view */
	$scope.searchId = $.url().param( 'SearchID' );
	$scope.currentPage = 1;
	$scope.resultsPerPage = 20;
	$scope.searchCompleted = false;
	$scope.totalProperties = 0;
	$scope.search = {};
	$scope.hotels = [];
	$scope.filteredHotels = [];
	$scope.errors = [];
	$scope.messages = [];

	//Collection of items that we can filter our hotel results by
	$scope.filterItems = {};
	$scope.filterItems.vendors = [];
	$scope.filterItems.amenities = [];
	$scope.filterItems.noSoldOut = false;
	$scope.filterItems.inPolicyOnly = false;


	/* Methods that this controller uses to get work done */
	$scope.loadSearch = function( searchId ){
		SearchService.getSearch( $scope.searchId )
			.then( function( result ){
				$scope.search = result.data;
				$scope.loadPolicy( $scope.search.policyID );
			});
	}

	$scope.loadPolicy = function( policyId ){
		HotelService.loadPolicy( policyId )
			.then( function( result ){
				$scope.initializeMap();
				$scope.search.checkInDate = new Date( $scope.search.checkInDate );
				$scope.search.checkOutDate = new Date( $scope.search.checkOutDate );
				$scope.getSearchResults( false );
				$scope.configureChangeSearchForm();
			});
	}

	$scope.updateSearch = function(){
		$scope.search.checkInDate = new Date( $('#hotel-in-date' ).val() );
		$scope.search.checkOutDate = new Date( $('#hotel-out-date' ).val() );
		$('#changeSearchWindow').modal('hide');
		$('#searchWindow').modal('show');

		SearchService.updateSearch( $scope.search )
			.then( function(result){

				if( result.success ){
					$scope.search = result.data;
					$scope.search.checkInDate = new Date( $scope.search.checkInDate );
					$scope.search.checkOutDate = new Date( $scope.search.checkOutDate );
					$scope.mapCenter = new Microsoft.Maps.Location( $scope.search.hotelLat, $scope.search.hotelLong);
					$scope.map.setView({center: $scope.mapCenter, mapTypeId: Microsoft.Maps.MapTypeId.road, zoom: 12});
					$scope.getSearchResults( true );
				}

				$scope.errors = result.errors;
				$scope.messages = result.messages;


			} )
	}

	$scope.getSearchResults = function( requery ){
		SearchService.doSearch( $scope.searchId, requery )
			.then( function(result){
				$scope.hotels = result;
				$scope.totalProperties = result.length;
				$scope.searchCompleted = true;

				//Build vendor array for filter
				$scope.buildVendorArrayFromSearchResults( $scope.filterItems.vendors, result );

				//Build the amenities array for filter
				$scope.buildAmenitiesArrayFromSearchResults( $scope.filterItems.amenities, result );

				//Fire off calls to get room rates for these hotels
				for( var i=0; i<$scope.resultsPerPage; i++ ){
					try{
						$scope.getHotelRates( $scope.hotels[i], requery );
					}
					catch( err ){

					}

				}

				$('#searchWindow').modal('hide');
			});
	}

	$scope.getHotelRates = function( Hotel, requery ){
		if( !Hotel.roomsReturned ){
			HotelService.getHotelRates( $scope.searchId, Hotel, requery );
		}
	}

	$scope.$watch( "filteredHotels.length + currentPage", function(newValue){

		if( $scope.filteredHotels.length && typeof $scope.map != 'undefined'){
			//Clear pins from map
			$scope.map.entities.clear();

			//Plot pins on map
			for( var i=0; i < $scope.filteredHotels.length; i++ ){
				var hotel = $scope.filteredHotels[i];
				var address = hotel.Address + ', ' + hotel.City + ' ' + hotel.State + ' ' + hotel.Zip;
				$scope.addPin( i+1, hotel.Lat, hotel.Long, hotel.propertyName, address );
			}
		}

	}, true)

	$scope.buildVendorArrayFromSearchResults = function( vendors, hotels ){

		for( var i=0; i < hotels.length; i++ ){
			var hotel = hotels[i];
			var found = false;
			for( var j=0; j < vendors.length; j++ ){
				var vendor = vendors[j];
				if( hotel.ChainCode == vendor.code ){
					found = true;
					break;
				}
			}
			if( !found ){
				vendors.push( {code: hotel.ChainCode, name: hotel.VendorName, checked: true })
			}
		}

		vendors.sort( function(a,b) {
		  if (a.name < b.name)
			 return -1;
		  if (a.name > b.name)
			return 1;
		  return 0;
		});
	}

	$scope.buildAmenitiesArrayFromSearchResults = function( amenities, hotels ){

		for( var i=0; i < hotels.length; i++ ){
			var hotel = hotels[i];

			for( var k=0; k < hotel.Amenities.length; k++ ){

				var found = false;
				for( var m=0; m < amenities.length; m++ ){
					if( amenities[m].name.toLowerCase() == hotel.Amenities[k].toLowerCase() ){
						found = true;
						break;
					}
				}

				if( !found ){
					amenities.push( {name: hotel.Amenities[k], checked: false } );
				}

			}
		}
		amenities.sort( function(a,b) {
		  if (a.name < b.name)
			 return -1;
		  if (a.name > b.name)
			return 1;
		  return 0;
		});
	}

	$scope.loadExtendedHotelData = function( Hotel ){

		if( !Hotel.details.loaded ){
			HotelService.getExtendedData( Hotel );
		}

	}

	$scope.toggleInPolicyOnly = function(){
		if( $scope.filterItems.inPolicyOnly == true ){
			$scope.filterItems.inPolicyOnly = false;
		} else {
			$scope.filterItems.inPolicyOnly = true;
		}
	}

	$scope.toggleNoSoldOut = function(){
		if( $scope.filterItems.noSoldOut == true ){
			$scope.filterItems.noSoldOut = false;
		} else {
			$scope.filterItems.noSoldOut = true;
		}
	}

	$scope.clearFilters = function(){
		for( var i=0; i < $scope.filterItems.vendors.length; i++ ){
			var vendor = $scope.filterItems.vendors[i];
			vendor.checked = true;
		}
		for( var j=0; j < $scope.filterItems.amenities.length; j++ ){
			var amenity = $scope.filterItems.amenities[j];
			amenity.checked = false;
		}
		$scope.filterItems.noSoldOut = false;
		$scope.filterItems.inPolicyOnly = false;
	}

	$scope.filtersApplied = function(){
		if( $scope.filteredHotels.length && $scope.filteredHotels.length < $scope.hotels.length){
			return true;
		} else {
			return false;
		}
	}

	$scope.hotelFilter = function( hotel ){

		var display = true;

		//Hotel chain check
		for( var i=0; i < $scope.filterItems.vendors.length; i++ ){
			var vendor = $scope.filterItems.vendors[i];
			if( vendor.code == hotel.ChainCode ){
				display = vendor.checked;
			}
		}

		//Sold out check
		if( display ){

			if( $scope.filterItems.noSoldOut && hotel.roomsReturned && hotel.isSoldOut() ){
				display = false;
			}

		}

		// Amenities check
		if( display ){

			var selectedAmenities = [];

			//Check to see if the user has selected any amenities to filter by
			for( var j=0; j < $scope.filterItems.amenities.length; j++ ){
				var amenity = $scope.filterItems.amenities[j];
				if( amenity.checked ){
					selectedAmenities.push( amenity.name );
				}
			}

			//Only apply this filter condition if the user has selected at least 1 amenity

			if( selectedAmenities.length ){

				for( var m=0; m < selectedAmenities.length; m++ ){

					//This is sub-optimal, but jQuery's inArray() is failing me for some reason
					var found = false;

					for( var n=0; n < hotel.Amenities.length; n++){
						if( selectedAmenities[m].toString().toLowerCase() == hotel.Amenities[n].toString().toLowerCase() ){
							found = true;
							break;
						}
					}

					if( found == false ){
						display = false;
						break;
					}
				}
			}
		}

		//Policy check
		if( display ){

			if( $scope.filterItems.inPolicyOnly && hotel.roomsReturned && !hotel.isInPolicy() ){
				display = false;
			}
		}

		return display;

	}

	$scope.initializeMap = function(){

		$scope.mapCenter = new Microsoft.Maps.Location( $scope.search.hotelLat, $scope.search.hotelLong);
		$scope.mapOptions = {
			height: 500,
			width: 600,
			credentials: "AkxLdyqDdWIqkOGtLKxCG-I_Z5xEdOAEaOfy9A9wnzgXtvtPnncYjFQe6pjmpCJA",
			enableSearchLogo: false
			}
		$scope.map = new Microsoft.Maps.Map( document.getElementById("mapDiv"), $scope.mapOptions);
		$scope.map.setView({center: $scope.mapCenter, mapTypeId: Microsoft.Maps.MapTypeId.road, zoom: 12});
		$scope.map.entities.push(new Microsoft.Maps.Pushpin( $scope.mapCenter, {icon: 'assets/img/mapCenter.png', zIndex:-51}));

		Microsoft.Maps.Events.addHandler( $scope.map, "dblclick", function(e){
			var center = $scope.map.getCenter();
			$scope.search.hotelLat = center.latitude;
			$scope.search.hotelLong = center.longitude;

			$scope.updateSearch();
		})

	}

	$scope.addPin = function( propertyNumber, lat, long, propertyName, propertyAddress ){

    	var pin = new Microsoft.Maps.Pushpin(new Microsoft.Maps.Location( lat, long ), {text:propertyNumber.toString(), visible:true});
    	pin.title = propertyName;
    	pin.description = propertyAddress;
    	Microsoft.Maps.Events.addHandler(pin, 'click', function(){
			var infoboxTitle = $('#infoboxTitle')[0];
			infoboxTitle.innerHTML = pin.title;
			var infoboxDescription = $('#infoboxDescription')[0];
			infoboxDescription.innerHTML = pin.description;
			var infobox2 = $('#infoBox')[0];
			infobox2.style.visibility = "visible";
			$('#mapDiv').append(infobox2);
		});
    	$scope.map.entities.push( pin );
	}

	$scope.calculatePages = function(){
		var pages = $scope.filteredHotels.length / $scope.resultsPerPage;
		if ( pages%1 > 0 ){
			pages = parseInt( pages );
			pages++;
		}
		return pages;
	}

	$scope.numberToArray = function( num ){
		return new Array( num );
	}

	$scope.showChangeSearchWindow = function(){
		$('#changeSearchWindow').modal('show');
	}

	$scope.configureChangeSearchForm = function(){

		//Now that we have the search data, we're going to set the search parameters into the change search form
		$(".airport-select2").select2( "val", $scope.search.hotelAirport );

		//Initialization for the change search modal window
		$("btn-group button.btn").on( "click", function(event){ event.preventDefault() });
		var calendarStartDate = dateFormat( new Date(), "mm/dd/yyyy", true );
		$("#start-calendar-wrapper" ).datepicker({
			startDate: calendarStartDate
			})
			.on( "changeDate", function( event ){
				$("#hotel-in-date" ).val( dateFormat( event.date, "mmm dd, yyyy", true ) );
				var endDate = event.date;
				endDate.setDate( endDate.getDate() + 1 );
				var endWrapper = $("#end-calendar-wrapper" );
				endWrapper.data( 'datepicker' ).setStartDate( endDate );
				endWrapper.data( 'datepicker' ).setDate( endDate );
				endWrapper.data( 'datepicker' ).update();
			});

		$("#end-calendar-wrapper" ).datepicker({
			startDate: calendarStartDate
			})
			.on( "changeDate", function( event ){
				$("#hotel-out-date" ).val( dateFormat( event.date, "mmm dd, yyyy", true ) );
			});

		$("#start-calendar-wrapper" ).data( 'datepicker' ).setDate( $scope.search.checkInDate );
		$("#start-calendar-wrapper" ).data( 'datepicker' ).update();
		$("#end-calendar-wrapper" ).data( 'datepicker' ).setDate( $scope.search.checkOutDate );
		$("#end-calendar-wrapper" ).data( 'datepicker' ).update();
		$(".airport-select2" ).select2({
			data: airports,
			width: "100%",
			sortResults: function(results, container, query) {
				if (query.term) {
					for (var i = 0; i < results.length; i++) {
						if( results[i].id.toUpperCase() == query.term.toUpperCase() ){
							results.move( i, 0 );
						}
					}
				}
				return results;
			}
		})

	}
	/* Items executed when controller is loaded */

	$('#searchWindow').modal('show');

	$scope.loadSearch( $scope.searchId );

});