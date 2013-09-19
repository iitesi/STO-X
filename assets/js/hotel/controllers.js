var controllers = angular.module('app.controllers',[]);

controllers.controller( "HotelCtrl", function( $scope, $location, SearchService, HotelService ){
	/* Scope variables that will be used to modify state of items in the view */
	$scope.searchId = $.url().param( 'SearchID' );
	$scope.searchCompleted = false;
	$scope.totalProperties = 0;
	$scope.search = {};
	$scope.account = {};
	$scope.hotels = [];
	$scope.filteredHotels = [];
	$scope.visibleHotels = [];
	$scope.markers = [];
	$scope.infoWindows = [];
	$scope.errors = [];
	$scope.messages = [];

	//Collection of items that we can filter our hotel results by
	$scope.filterItems = {};
	$scope.filterItems.currentPage = 1;
	$scope.filterItems.resultsPerPage = 20;
	$scope.filterItems.vendors = [];
	$scope.filterItems.amenities = [];
	$scope.filterItems.ratings = [
		{rating: 5, checked: false},
		{rating: 4, checked: false},
		{rating: 3, checked: false},
		{rating: 2, checked: false},
		{rating: 1, checked: false}
	];
	$scope.filterItems.noSoldOut = false;
	$scope.filterItems.inPolicyOnly = false;
	$scope.filterItems.vendorsFilterApplied = false;
	$scope.filterItems.amenitiesFilterApplied = false;
	$scope.filterItems.showVendorFilter = false;
	$scope.filterItems.showAmenitiesFilter = false;
	$scope.filterItems.showRatingsFilter = false;


	/* Methods that this controller uses to get work done */
	$scope.loadSearch = function( searchId ){

		SearchService.getSearch( $scope.searchId )
			.then( function( result ){

				$scope.search = result.data;

				SearchService.loadAccount( $scope.search.acctID )
					.then( function( result ){
						$scope.account = result;
					});
				$scope.initializeMap( $scope.search.hotelLat, $scope.search.hotelLong );
				$scope.loadPolicy( $scope.search.policyID );
			});
	}

	$scope.loadPolicy = function( policyId ){
		SearchService.loadPolicy( policyId )
			.then( function( result ){
				$scope.policy = result;
				$scope.search.checkInDate = new Date( $scope.search.checkInDate );
				$scope.search.checkOutDate = new Date( $scope.search.checkOutDate );
				$scope.getSearchResults( false );
				$scope.configureChangeSearchForm();
			});
	}

	$scope.updateSearch = function(){
		if( $('#hotel-in-date' ).val() != "" ){
			$scope.search.checkInDate = new Date( $('#hotel-in-date' ).val() );
		}
		if( $('#hotel-out-date' ).val() != '' ){
			$scope.search.checkOutDate = new Date( $('#hotel-out-date' ).val() );
		}
		$('#changeSearchWindow').modal('hide');
		$('#searchWindow').modal('show');

		SearchService.updateSearch( $scope.search )
			.then( function(result){

				if( result.success ){
					$scope.search = result.data;
					$scope.search.checkInDate = new Date( $scope.search.checkInDate );
					$scope.search.checkOutDate = new Date( $scope.search.checkOutDate );
					$scope.getSearchResults( true );
					$scope.map.setZoom( $scope.calculateMapZoom())
				}

				$scope.errors = result.errors;
				$scope.messages = result.messages;


			} )
	}

	$scope.getSearchResults = function( requery ){
		SearchService.doSearch( $scope.searchId, requery )
			.then( function(result){
				$scope.hotels = result.hotels;
				$scope.filteredHotels = result.hotels;
				$scope.totalProperties = result.hotels.length;
				$scope.searchCompleted = true;
				$scope.messages = result.messages;
				$scope.errors = result.errors;

				//Build vendor array for filter
				$scope.buildVendorArrayFromSearchResults( $scope.filterItems.vendors, result.hotels );

				//Build the amenities array for filter
				$scope.buildAmenitiesArrayFromSearchResults( $scope.filterItems.amenities, result.hotels );
				$scope.updateVisibleHotels();
				$('#searchWindow').modal('hide');
			});
	}

	$scope.getHotelRates = function( Hotel, requery ){
		if( !Hotel.roomsReturned ){
			HotelService.getHotelRates( $scope.searchId, Hotel, $scope.policy, requery )
				.then( function(result){
					if( !$scope.hotelFilter( result ) ){
						$scope.filterHotels();
					}
				})
		}
	}

	//Watches to see if any of the items in the filter bar change and kicks off the filterHotels process
	$scope.$watch( "filterItems", function(newValue){

		var selectedAmenities = 0;
		for( var i=0; i < $scope.filterItems.amenities.length; i++ ){
			if( $scope.filterItems.amenities[i].checked == true ){
				selectedAmenities++;
			}
		}

		if( selectedAmenities > 0 ){
			$scope.filterItems.amenitiesFilterApplied = true;
		} else {
			$scope.filterItems.amenitiesFilterApplied = false;
		}

		var selectedVendors = 0;
		for( var h=0; h < $scope.filterItems.vendors.length; h++ ){
			if( $scope.filterItems.vendors[h].checked == true ){
				selectedVendors++;
			}
		}

		if( selectedVendors > 0 ){
			$scope.filterItems.vendorsFilterApplied = true;
		} else {
			$scope.filterItems.vendorsFilterApplied = false;
		}

		if( $scope.searchCompleted ){
			$scope.filterHotels();
		}
	}, true)

	$scope.updateVisibleHotels = function(){
		try{
			$scope.clearMarkers();
		} catch(e){

		}

		var visibleHotels = [];
		var startIndex = ( $scope.filterItems.currentPage - 1 ) * $scope.filterItems.resultsPerPage;
		if( startIndex > $scope.filteredHotels.length ){
			startIndex = 0;
		}
		var endIndex = startIndex + $scope.filterItems.resultsPerPage;
		if( endIndex > $scope.filteredHotels.length ){
			endIndex = $scope.filteredHotels.length;
		}

		for( var i=startIndex; i<endIndex; i++ ){
			var Hotel = $scope.filteredHotels[i];

			$scope.addMarker( i+1, Hotel );
			if( !Hotel.roomsRequested && !Hotel.roomsReturned ){
				$scope.getHotelRates( Hotel, false );
			}

			if( !Hotel.extendedDataRequested ){
				var datapoints = [];
				if( Hotel.StarRating == 0 ){
					datapoints.push( 'rating' );
				}
				if( Hotel.SignatureImage.indexOf( "MissingHotel" ) != -1 ){
					datapoints.push( 'signatureImage' );
				}

				HotelService.getExtendedData( $scope.searchId, Hotel, datapoints.toString() );
			}

			visibleHotels.push( { propertyNumber: i+1, hotel: Hotel } );

		}

		if( $scope.filterItems.currentPage > $scope.calculatePages() ){
			$scope.filterItems.currentPage = 1;
		};

		$scope.visibleHotels = visibleHotels;

	}

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
				vendors.push( {code: hotel.ChainCode, name: hotel.VendorName, checked: false })
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

		var corpAmenities = ['Air Conditioning','High Speed Internet','Breakfast','Coffee Shop','Computer Bus Center','Concierge Level','Continental Breakfast','Free Transportation','Handicap Facilities',
			'Health Club','Microwave Oven','Kitchen','Laundry/Valet','Lounge','Meeting Facilities','Multilingual','Non-Smoking Room','Parking','Free Parking','POOL Pool','Refrigerator','Restaurant','Room Service','Private Bath'];

		/* This is for future use if/when we decide to populate the account branch
		var leisureAmenities = ['Air Conditioning','Child Care','Balcony','Children\'s Programs','High Speed Internet','Breakfast','Casino','Coffee Shop','Children Stay Free','Computer Bus Center','Concierge Desk',
			'Concierge Level','Connect Rooms','Continental Breakfast','Entertainment','Family Plan','Free Transportation','Game Room','Golf','Handicap Facilities','Health Club','Microwave Oven','Kitchen','Laundry/Valet',
			'Lounge','Meal Plan','Meeting Facilities','Mini Bar','Movies In Room','Multilingual','Non-Smoking Room','Parking','Free Parking','Small Pets Allowed','Pool','Indoor Pool','Outdoor Pool','Refrigerator','Restaurant',
			'Room Service','Sauna','Skiing','Snow Skiing','Water Skiing','Spa','Tennis Court','Private Bath','Wet Bar','Jogging Track','Sofa Bed','Photo Copy Service'];
		*/
		var availableAmenities = corpAmenities;

		for( var i=0; i < hotels.length; i++ ){
			var hotel = hotels[i];

			for( var k=0; k < hotel.Amenities.length; k++ ){

				//First decide if the current amenity is in the availableAmenities array
				var inList = false;
				for( var a=0; a < availableAmenities.length; a++ ){
					if( availableAmenities[a].toLowerCase() == hotel.Amenities[k].toLowerCase() ){
						inList = true;
					}
				}

				//If the amenity is in the approved list, check to see if it's already in the list to build filters from
				if( inList == true ){

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
			HotelService.getExtendedData( $scope.searchId, Hotel );
		}

	}

	$scope.clearFilters = function(){
		for( var i=0; i < $scope.filterItems.vendors.length; i++ ){
			var vendor = $scope.filterItems.vendors[i];
			vendor.checked = false;
		}
		for( var j=0; j < $scope.filterItems.amenities.length; j++ ){
			var amenity = $scope.filterItems.amenities[j];
			amenity.checked = false;
		}
		for( var r=0; r < $scope.filterItems.ratings.length; r++ ){
			var rating = $scope.filterItems.ratings[r];
			rating.checked = false;
		}
		$scope.filterItems.noSoldOut = false;
		$scope.filterItems.inPolicyOnly = false;
		$scope.filterItems.vendorsFilterApplied = false;
		$scope.filterItems.amenitiesFilterApplied = false;
		$scope.filterItems.showVendorFilter = false;
		$scope.filterItems.showAmenitiesFilter = false;
	}

	$scope.filtersApplied = function(){
		if( $scope.filteredHotels.length && $scope.filteredHotels.length < $scope.hotels.length){
			return true;
		} else {
			return false;
		}
	}

	$scope.filterHotels = function(){
		var filteredHotels = [];
		var visibleHotels = [];

		for( var i=0; i < $scope.hotels.length; i++ ){
			if( $scope.hotelFilter( $scope.hotels[i] ) ){
				filteredHotels.push( $scope.hotels[i] );
			}
		}
		$scope.filteredHotels = filteredHotels;
		$scope.updateVisibleHotels();
	}

	$scope.hotelFilter = function( hotel ){

		var display = true;

		//Hotel chain check
		var selectedVendors = [];

		//Check to see if the user has selected any vendors to filter by
		for( var h=0; h < $scope.filterItems.vendors.length; h++ ){
			var vendor = $scope.filterItems.vendors[h];
			if( vendor.checked ){
				selectedVendors.push( vendor );
			}
		}

		//Only apply this filter condition if the user has selected at least 1 vendor
		if( selectedVendors.length ){
			display = false;
			for( var g = 0; g < selectedVendors.length; g++ ){
				if( selectedVendors[g].code == hotel.ChainCode ){
					display = true;
					break;
				}
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

		// Ratings check
		if( display ){
			var selectedRatings = [];

			//Check to see if the user has selected any ratings to filter by
			for( var r=0; r < $scope.filterItems.ratings.length; r++ ){
				var item = $scope.filterItems.ratings[r];
				if( item.checked ){
					selectedRatings.push( item.rating );
				}
			}

			if( selectedRatings.length ){
				if( hotel.StarRating == 0 ){
					display = false;
				} else {
					var found = false;

					for( var sr=0; sr < selectedRatings.length; sr ++ ){
						if( hotel.StarRating == selectedRatings[sr] ){
							found = true;
							break;
						}
					}

					if( found == false ){
						display = false;
					}
				}
			}
		}

		//Policy check
		if( display ){

			if( $scope.filterItems.inPolicyOnly && hotel.roomsReturned && !hotel.isInPolicy ){
				display = false;
			}
		}

		//Sold out check
		if( display ){

			if( $scope.filterItems.noSoldOut && hotel.roomsReturned && hotel.isSoldOut() ){
				display = false;
			}

		}

		return display;

	}

	$scope.setCurrentPage = function( pageNumber ){
		var totalPages = $scope.calculatePages();

		if( pageNumber <= totalPages ){
			$scope.filterItems.currentPage = 1;
		} else {
			$scope.filterItems.currentPage = pageNumber;
		}

		$scope.filterHotels();
	}

	$scope.calculatePages = function(){
		var pages = $scope.filteredHotels.length / $scope.filterItems.resultsPerPage;
		if( pages > 0 && pages < 1 ){
			return 1;
		} else if ( pages > 1 && pages%1 > 0 ){
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
		$(".airport-select2").select2("val", $scope.search.hotelAirport );

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
			minimumInputLength: 2,
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

	$scope.updateTooltips = function(){
		$("[rel='tooltip']").tooltip();
	}

	$scope.selectRoom = function( Hotel, Room ){
		window.location = '/booking/index.cfm?action=hotel.select&SearchID=' + $scope.search.searchID
							+ '&propertyId=' + Hotel.PropertyId
							+ '&ratePlanType=' + Room.ratePlanType
							+ '&totalForStay=' + Room.totalForStay
							+ '&isInPolicy=' + Room.isInPolicy;
	}


	$scope.initializeMap = function( lat, lon ){

		google.maps.visualRefresh = true;
		var mapCenter =  new google.maps.LatLng( lat, lon );
		var mapOptions = {
          center: mapCenter,
          zoom: 8,
          mapTypeId: google.maps.MapTypeId.ROADMAP,
          disableDoubleClickZoom: true,
          panControl: false,
          zoom: $scope.calculateMapZoom(),
          zoomControlOptions: {
			style: google.maps.ZoomControlStyle.LARGE,
			position: google.maps.ControlPosition.LEFT_CENTER
		  }
        };
        $scope.map = new google.maps.Map( document.getElementById("mapDiv"), mapOptions);

		var marker = new google.maps.Marker({
			position: mapCenter,
			map: $scope.map,
			icon: '/booking/assets/img/center.png'
		});

		$scope.markers.push( marker );

		google.maps.event.addListener($scope.map, 'dblclick', function(e) {
			$scope.map.setCenter( e.latLng );
			$scope.search.hotelLat = e.latLng.ob;
			$scope.search.hotelLong = e.latLng.pb;
			$scope.search.hotelSearch = 'latlong';
			$scope.updateSearch();
		  });

		google.maps.event.addListener($scope.map, 'click', function(e) {
			$scope.clearInfoWindows()
		  })
	}

	$scope.calculateMapZoom = function(){
		if( $scope.search.hotelRadius == 1 ){
			return 14;
		}
		if( $scope.search.hotelRadius == 2 ){
			return 13;
		}
		if( $scope.search.hotelRadius == 5 ){
			return 11;
		}
		if( $scope.search.hotelRadius == 10 ){
			return 10;
		}
		if( $scope.search.hotelRadius == 15 ){
			return 10;
		}
		if( $scope.search.hotelRadius == 20 ){
			return 9;
		}

		return 9;
	}

	$scope.addMarker = function( propertyNumber, Hotel ){

    	var infoWindowContent = '<h4 class="infoWindowTitle">' + Hotel.PropertyName + '</h4>'+
			'<div class="infoWindowContent">' + Hotel.Address +
			'<br>' + Hotel.City + ', ' + Hotel.State + ' ' + Hotel.Zip;
			if( Hotel.Phone != '' ){
				infoWindowContent += 'Phone: ' + Hotel.Phone;
			}
			infoWindowContent += '</div>';

		var infoWindow = new google.maps.InfoWindow({
			content: infoWindowContent
		});
		$scope.infoWindows.push( infoWindow);

    	var latlng = new google.maps.LatLng( Hotel.Lat, Hotel.Long );

    	var styleIcon = new StyledIcon(StyledIconTypes.MARKER,{color:"#0044CC",text: propertyNumber.toString(),fore: "#fff"});
    	var marker = new StyledMarker({styleIcon:styleIcon,position:latlng,map:$scope.map});

		google.maps.event.addListener(marker, 'click', function() {
			$scope.clearInfoWindows();
			infoWindow.open( $scope.map, marker);
		});

		$scope.markers.push( marker );

	}

	$scope.clearInfoWindows = function(){
		for( var i=0; i<$scope.infoWindows.length; i++ ){
			$scope.infoWindows[i].close();
		}
	}

	$scope.clearMarkers = function(){
		for( var i=0; i<$scope.markers.length; i++ ){
			$scope.markers[i].setMap(null);
		}
		$scope.markers = [];

		var mapCenter =  new google.maps.LatLng( $scope.search.hotelLat, $scope.search.hotelLong );
		var marker = new google.maps.Marker({
			position: mapCenter,
			map: $scope.map,
			icon: '/booking/assets/img/center.png'
		});

		$scope.markers.push( marker );
	}


	/* Items executed when controller is loaded */

	$('#searchWindow').modal('show');

	$scope.loadSearch( $scope.searchId );

	$('.continue-link').attr( 'href', '/booking/index.cfm?action=hotel.skip&searchId=' + $scope.searchId );

});

