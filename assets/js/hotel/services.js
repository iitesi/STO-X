var services = angular.module('app.services', [])

services.factory( "SearchService", function( $http ){
	var SearchService = function(data) { angular.extend(this, data); };

	SearchService.getSearch = function( searchId ){
		return $http.get( "/booking/RemoteProxy.cfc?method=getSearch&searchId=" + searchId )
			.success(
				function(response) {
					return response
				}
			)
			.error(
				function(exception, cause) {
					return cause;
				}
			)
	}

	SearchService.updateSearch = function( search ){
		var postData = {
			searchId: search.searchID,
			hotelLat: search.hotelLat,
			hotelLong: search.hotelLong,
			hotelRadius: search.hotelRadius,
			hotelSearch: search.hotelSearch,
			hotelAddress: search.hotelAddress,
			hotelCity: search.hotelCity,
			hotelState: search.hotelState,
			hotelZip: search.hotelZip,
			hotelAirport: $("#hotel-airport" ).val(),
			officeID: search.officeID,
			checkInDate: dateFormat( search.checkInDate, 'mm/dd/yyyy' ),
			checkOutDate: dateFormat( search.checkOutDate, 'mm/dd/yyyy' )
		 	}
		return $http({
				url: '/booking/RemoteProxy.cfc?method=updateSearch',
				method: "POST",
				params: postData,
				headers: {'Content-Type': 'application/x-www-form-urlencoded'}
			})
			.then( function(response) { return response.data });
	}

	SearchService.doSearch = function( searchId, propertyId, requery, finditRequest, checkPriceline ) {
		return $http.get( "/booking/RemoteProxy.cfc?method=getHotelSearchResults&searchId=" + searchId + "&propertyId=" + propertyId + "&requery=" + requery + "&finditRequest=" + finditRequest + "&checkPriceline=" + checkPriceline)
			.then( function(response) {
				var result = {};
				result.hotels = [];

				for (var i = 0; i < response.data.data.length; i++) {
					var h = new Hotel();
					h.populate( response.data.data[i] );
					result.hotels.push( h );
				}
				result.messages = response.data.messages;
				result.errors = response.data.errors;
				return result;
			});
	}

	SearchService.loadPolicy = function( policyId ){
		return $http.get( "/booking/RemoteProxy.cfc?method=getPolicy&policyId=" + policyId )
			.then( function( response ){ return response.data })
	}

	SearchService.loadAccount = function( accountId ){
		return $http.get( "/booking/RemoteProxy.cfc?method=getAccount&accountId=" + accountId )
			.then( function( response ){ return response.data })
	}

	return SearchService;
});

services.factory( "HotelService", function( $window, $http ){
	var HotelService = function(data) { angular.extend(this, data); };

	HotelService.getHotelRates = function( searchId, Hotel, finditHotel, finditRatePlan, finditRate, policy, requery, checkPriceline ) {
		Hotel.roomsRequested = true;
		var url = "/booking/RemoteProxy.cfc?method=getAvailableHotelRooms&SearchID=" + searchId + "&PropertyId=" + Hotel.PropertyId + '&requery=' + requery + '&checkPriceline=' + checkPriceline;
		return $http.get( url )
			.then( function( response ){
				var rooms = [];
				//We only want to check things if rooms are returned (not sold out)
				if(response.data.length > 0)
					Hotel.allRoomsOutOfPolicy = true;					
				for (var i = 0; i < response.data.length; i++) {
					var hr = new HotelRoom();
					hr.populate( response.data[i] );
					hr.dailyRate = Math.round( hr.dailyRate );
					finditRate = Math.round( finditRate );
					if (Hotel.PropertyId == finditHotel) {
						if (hr.ratePlanType == finditRatePlan) {
							if (hr.dailyRate > finditRate) {
								hr.finditMessage = 'Higher Rate!';
							}
							else if (hr.dailyRate < finditRate) {
								hr.finditMessage = 'Lower Rate!';
							}
						}
					}
					hr.setInPolicy( policy, Hotel.outOfPolicyVendor );
					hr.setOutOfPolicyMessage( hr.isInPolicy, Hotel.outOfPolicyVendor );
					if (hr.displayRoom) {
						rooms.push( hr );
						Hotel.allRoomsOutOfPolicy = false;
					}
				}
				Hotel.roomsReturned = true;
				Hotel.rooms = rooms;
				Hotel.setInPolicy( policy );

				return Hotel;
			})
	}

	HotelService.getExtendedData = function( searchId, Hotel, datapoints ){
		Hotel.extendedDataRequested = true;
		var remoteURL = shortstravel.shortsAPIURL + "/booking/RemoteProxy.cfc?method=getHotelDetails&callback=JSON_CALLBACK&searchId=" + searchId + "&propertyId=" + Hotel.PropertyId;
		if ( typeof datapoints != 'undefined' ){
			remoteURL = remoteURL + '&datapoints=' + datapoints;
		}
		return $http.jsonp( remoteURL  )
			.then( function( response ){
				if( typeof response.data.data.starRating != 'undefined' ){
					Hotel.StarRating = response.data.data.starRating;
				}

				if( typeof response.data.data.images != 'undefined' ){
					Hotel.images = response.data.data.images;
					if( Hotel.images.length ){
						Hotel.selectedImage = Hotel.images[0].IMAGEURL;
					} else {
						Hotel.selectedImage = "";
					}
				}

				if( typeof response.data.data.signatureImage != 'undefined' ){
					Hotel.SignatureImage = response.data.data.signatureImage;
				}

				if( typeof response.data.data.amenityList != 'undefined' ){
					Hotel.createAmenityList();
				}

				if( typeof response.data.data.addressFlag != 'undefined' ){
					Hotel.Address = response.data.data.address_street ;
					Hotel.City = response.data.data.address_city ;
					Hotel.State = response.data.data.address_state ;
					Hotel.Zip = response.data.data.address_zip ;
				}

				if( typeof response.data.data.description != 'undefined' ){
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
					Hotel.details.transportation = response.data.data.transportation;
					Hotel.details.pricelineMatched = response.data.data.pricelineMatched;
					Hotel.details.neighborhood = response.data.data.neighborhood;
					Hotel.details.roomCount = response.data.data.roomCount;
				}
			})
	}

	HotelService.getHotelPhotos = function( searchId, Hotel ){
		Hotel.extendedDataRequested = true;
		var remoteURL = shortstravel.shortsAPIURL + "/booking/RemoteProxy.cfc?method=getHotelDetails&callback=JSON_CALLBACK&searchId=" + searchId + "&propertyId=" + Hotel.PropertyId;
		remoteURL = remoteURL + '&datapoints=images';

		return $http.jsonp( remoteURL  )
			.then( function( response ){
				if( typeof response.data.data.images != 'undefined' ){
					Hotel.images = response.data.data.images;
					if( Hotel.images.length ){
						Hotel.selectedImage = Hotel.images[0].IMAGEURL;
					} else {
						Hotel.selectedImage = "";
					}
					Hotel.imagesLoaded = true;
				}
				if( typeof response.data.data.signatureImage != 'undefined' ){
					Hotel.SignatureImage = response.data.data.signatureImage;
					Hotel.imagesLoaded = true;
				}
			})
	}

	HotelService.getRoomRateRules = function( searchId, Hotel, Room ){
		var remoteURL = shortstravel.shortsAPIURL + "/booking/RemoteProxy.cfc?method=getRoomRateRules&callback=JSON_CALLBACK&searchId=" + searchId + "&propertyId=" + Hotel.PropertyId + '&ratePlanType=' + Room.ratePlanType + '&ppnBundle=' + Room.ppnBundle + '&isRemote=1';
		return $http.jsonp( remoteURL  )
			.then( function( response ){
				if( typeof response.data.data.CANCELLATION != 'undefined' ){
					Room.cancellationMessage = response.data.data.CANCELLATION;
					Room.cancellationMessageLoaded = true;
					$('#cancellationPolicyLoading').hide();
					$('#cancellationPolicyCopy').html(Room.cancellationMessage);
					$('#cancellationPolicyCopy').show();
				}
			})
	}

	return HotelService;
})
