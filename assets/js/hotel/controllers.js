var controllers = angular.module('app.controllers',[]);

controllers.controller( "HotelCtrl", function( $scope, $location, $routeParams, Search ){
	$scope.currentPage = 1;
	$scope.resultsPerPage = 20;

	Search.getSearch( $routeParams.searchId )
		.then( function( result ){
			$scope.search = result;
			console.log( $scope.search );
		});
	Search.doSearch( $routeParams.searchId )
		.then( function(result){
			$scope.hotels = result;

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

	//$scope.center = new Microsoft.Maps.Location( $scope.search.hotelLat, $scope.search.hotelLong);
    //$scope.mapOptions = {credentials: "AkxLdyqDdWIqkOGtLKxCG-I_Z5xEdOAEaOfy9A9wnzgXtvtPnncYjFQe6pjmpCJA", center: $scope.center, mapTypeId: Microsoft.Maps.MapTypeId.road, enableSearchLogo: false, zoom: 12}
    //$scope.map = new Microsoft.Maps.Map( document.getElementById("mapDiv"), $scope.mapOptions);
    //$scope.map.entities.push(new Microsoft.Maps.Pushpin( $scope.center, {icon: 'assets/img/center.png', zIndex:-51}));

});