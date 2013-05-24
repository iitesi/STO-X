var app = angular.module( 'hotelSearch' , [ 'app.controllers','app.services' ]);

app.config([ '$routeProvider', function( $routeProvider) {
	$routeProvider.
		when('/search/:searchId', {
			controller: 'HotelCtrl',
			templateUrl: '/booking/views/hotel/searchResults.html'
		} ).
		otherwise({
			redirectTo: '/',
			controller: 'HotelCtrl'
		});
}]);



