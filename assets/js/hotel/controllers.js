var controllers = angular.module('app.controllers',[]);

controllers.controller( "HotelCtrl", function( $scope, $location, $routeParams, Search ){
	$scope.currentPage = 1;
	$scope.resultsPerPage = 20;
	$scope.totalProperties = 0;

	//Hard coded for now until we extract them from the results list
	$scope.vendors = [];
	$scope.amenities = [];

	Search.getSearch( $routeParams.searchId )
		.then( function( result ){
			$scope.search = result;

			//$scope.mapCenter = new Microsoft.Maps.Location( result.hotelLat, result.hotelLong);
			//console.log( $scope.mapCenter );
			//$scope.mapOptions = {height: 450, width: 450, credentials: "AkxLdyqDdWIqkOGtLKxCG-I_Z5xEdOAEaOfy9A9wnzgXtvtPnncYjFQe6pjmpCJA", mapCenter: $scope.mapCenter, mapTypeId: Microsoft.Maps.MapTypeId.road, enableSearchLogo: false, zoom: 12}
			//$scope.map = new Microsoft.Maps.Map( document.getElementById("mapDiv"), $scope.mapOptions);
			//$scope.map.entities.push(new Microsoft.Maps.Pushpin( $scope.mapCenter, {icon: 'assets/img/mapCenter.png', zIndex:-51}));

		});
	Search.doSearch( $routeParams.searchId )
		.then( function(result){
			$scope.hotels = result;
			$scope.totalProperties = result.length;

			//Build vendor array for filter
			$scope.buildVendorArrayFromSearchResults( $scope.vendors, result );
			
			//Build the amenities array for filter
			$scope.buildAmenitiesArrayFromSearchResults( $scope.amenities, result );

			//Fire off calls to get room rates for these hotels
			for( var i=0; i<$scope.resultsPerPage; i++ ){
				if( !$scope.hotels[i].roomsReturned ){
					Search.getHotelRates( $routeParams.searchId, $scope.hotels[i] );
				}
			}
		});

	$scope.toggleHotelDetails = function(hotel) {

		if($scope.showHotelDetails) {
			$scope.showHotelDetails = false;
		} else {
			$scope.showAreaDetails = false;
			$scope.showAmenities = false;
			$scope.showPhotos = false;
			$scope.showRooms = false;
			$scope.showHotelDetails = true;
		}
	}

	$scope.toggleAreaDetails = function(hotel) {

		if($scope.showAreaDetails) {
			$scope.showAreaDetails = false;
		} else {
			$scope.showAmenities = false;
			$scope.showPhotos = false;
			$scope.showRooms = false;
			$scope.showHotelDetails = false;
			$scope.showAreaDetails = true;
		}
	}

	$scope.toggleAmenities = function(hotel) {

		if($scope.showAmenities) {

			$scope.showAmenities = false;
		} else {
			$scope.showAreaDetails = false;
			$scope.showPhotos = false;
			$scope.showRooms = false;
			$scope.showHotelDetails = false;
			$scope.showAmenities = true;
		}
	}

	$scope.togglePhotos = function(hotel) {

		if($scope.showPhotos) {
			$scope.showPhotos = false;
		} else {
			$scope.showAreaDetails = false;
			$scope.showRooms = false;
			$scope.showHotelDetails = false;
			$scope.showAmenities = false;
			$scope.showPhotos = true;
		}
	}

	$scope.toggleRooms = function(hotel) {

		if($scope.showRooms) {
			$scope.showRooms = false;
		} else {
			$scope.showAreaDetails = false;
			$scope.showHotelDetails = false;
			$scope.showAmenities = false;
			$scope.showPhotos = false;
			$scope.showRooms = true;
		}
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
				vendors.push( {code: hotel.ChainCode, name: hotel.VendorName })
			}
		}

		vendors.sort( function(a,b) {
		  if (a.name < b.name)
			 return -1;
		  if (a.name > b.name)
			return 1;
		  return 0;
		})
	}

	$scope.buildAmenitiesArrayFromSearchResults = function( amenities, hotels ){

		for( var i=0; i < hotels.length; i++ ){
			var hotel = hotels[i];

			for( var k=0; k < hotel.Amenities.length; k++ ){

				if( $.inArray( hotel.Amenities[k], amenities) == -1 ){
					amenities.push( hotel.Amenities[k] );
				}

			}
		}
		amenities.sort();
	}


});