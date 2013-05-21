var app = angular.module( 'hotelSearch' , [ 'app.controllers','app.services' ]);

app.config([ '$routeProvider', function( $routeProvider) {
	$routeProvider.
		when('/search/:searchId', {
			controller: 'HotelCtrl',
			templateUrl: '/booking/views/partials/hotelRenderer.html'
		} ).
		otherwise({
			redirectTo: '/',
			controller: 'HotelCtrl'
		});
}]);



