var services = angular.module('app.services', [])

services.factory( "SearchService", function( $http ){
	var SearchService = function(data) { angular.extend(this, data); };

	SearchService.getSearch = function( searchId ){
		return $http.get( "/booking/RemoteProxy.cfc?method=getSearch&searchId=" + searchId )
			.then( function(response) { return response.data });
	}

	SearchService.updateSearch = function( search ){
		return $http.get( "/booking/RemoteProxy.cfc?method=updateSearch&searchId=" + search.searchID + "&hotelLat=" + search.hotelLat + "&hotelLong=" + search.hotelLong )
			.then( function(response) { return response.data });
	}

	SearchService.doSearch = function( searchId ) {
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

	return SearchService;
});

services.factory( "HotelService", function( $http ){
	var HotelService = function(data) { angular.extend(this, data); };

	HotelService.getHotelRates = function( searchId, Hotel ) {
		return $http.get( "/booking/RemoteProxy.cfc?method=getAvailableHotelRooms&SearchID=" + searchId + "&PropertyId=" + Hotel.PropertyId )
			.then( function( response ){
				Hotel.roomsReturned = true;
				Hotel.rooms = response.data;
			})
	}

	HotelService.getExtendedData = function( Hotel ){
		return $http.get( "/booking/RemoteProxy.cfc?method=getHotelDetails&propertyId=" + Hotel.PropertyId )
			.then( function( response ){
				console.log( response );
				Hotel.details.loaded = true;
				Hotel.details.description = response.data.data.description;
				Hotel.details.cancellation = response.data.data.cancellation;
				Hotel.details.creditCard = response.data.data.creditCardPolicy;
				Hotel.details.directions = response.data.data.directions;
				Hotel.details.facility = response.data.data.facility;
				Hotel.details.guarantee =  response.data.data.guarantee;
				Hotel.details.location = response.data.data.location;
				Hotel.details.ratingService = response.data.data.ratingService;
				Hotel.details.recreation = response.data.data.recreation;
				Hotel.details.services =  response.data.data.services;
				Hotel.details.starRating = response.data.data.starRating;
				Hotel.details.transportation = response.data.data.transportation;
			})
	}

	return HotelService;
})