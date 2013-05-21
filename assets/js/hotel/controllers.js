var controllers = angular.module('app.controllers',[]);

controllers.controller( "HotelCtrl", function( $scope, $location, $routeParams, $http, Search ){

	$scope.search = Search.getSearch( $routeParams.searchId );
	$scope.hotels = Search.doSearch( $routeParams.searchId );

	$scope.currentPage = 1;

	$scope.toggleHotelDetails = function(hotel) {

		if($scope.showHotelDetails) {
			$scope.showHotelDetails = false;
		} else {
			$scope.showAreaDetails = false;
			$scope.showAmenitiess = false;
			$scope.showPhotos = false;
			$scope.showRooms = false;
			$scope.showHotelDetails = true;
		}
	}

	$scope.toggleAreaDetails = function(hotel) {

		if($scope.showAreaDetails) {
			$scope.showAreaDetails = false;
		} else {
			$scope.showAmenitiess = false;
			$scope.showPhotos = false;
			$scope.showRooms = false;
			$scope.showHotelDetails = false;
			$scope.showAreaDetails = true;
		}
	}

	$scope.toggleAmenities = function(hotel) {

		if($scope.showAmenitiess) {

			$scope.showAmenitiess = false;
		} else {
			$scope.showAreaDetails = false;
			$scope.showPhotos = false;
			$scope.showRooms = false;
			$scope.showHotelDetails = false;
			$scope.showAmenitiess = true;
		}
	}

	$scope.togglePhotos = function(hotel) {

		if($scope.showPhotos) {
			$scope.showPhotos = false;
		} else {
			$scope.showAreaDetails = false;
			$scope.showRooms = false;
			$scope.showHotelDetails = false;
			$scope.showAmenitiess = false;
			$scope.showPhotos = true;
		}
	}

	$scope.toggleRooms = function(hotel) {

		if($scope.showRooms) {
			$scope.showRooms = false;
		} else {
			$scope.showAreaDetails = false;
			$scope.showHotelDetails = false;
			$scope.showAmenitiess = false;
			$scope.showPhotos = false;
			$scope.showRooms = true;
		}
	}
});