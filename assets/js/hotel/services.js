var services = angular.module('app.services', [])

services.factory( "Search", function($http ){
	var Search = function(data) { angular.extend(this, data); };

	Search.getSearch = function( searchId ){
		return $http.get( "/booking/RemoteProxy.cfc?method=getSearch&searchId=" + searchId )
			.then( function(response) { return response.data });

	}

	Search.doSearch = function( searchId ) {
		return $http.get( "/booking/RemoteProxy.cfc?method=getHotelSearchResults&searchId=" + searchId )
			.then( function(response) {
				var hotels = [];

				for (var i = 0; i < response.data.length; i++) {
					var h = new Hotel();
					h.populate( response.data[i] );
					hotels.push( h );
				}
				return hotels;
				});
	}

	Search.getHotelRates = function( searchId, hotel ) {
		return $http.get( "/booking/RemoteProxy.cfc?method=getAvailableHotelRooms&SearchID=" + searchId + "&PropertyId=" + hotel.PropertyId )
			.then( function( response ){
				hotel.roomsReturned = true;
				hotel.rooms = response.data;
			})
	}

	return Search;
});