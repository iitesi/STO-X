var app = angular.module( 'hotelSearch' , [ 'app.controllers','app.services' ]);


app.config([ '$routeProvider', function( $routeProvider) {
	$routeProvider.
		when('/', {
			controller: 'HotelCtrl',
			templateUrl: '/booking/views/hotel/searchResults.html'
		})
}]);

Array.prototype.move = function (old_index, new_index) {
	if (new_index >= this.length) {
		var k = new_index - this.length;
		while ((k--) + 1) {
			this.push(undefined);
		}
	}
	this.splice(new_index, 0, this.splice(old_index, 1)[0]);
};

