function Hotel(){

    this.Amenities =  [];
    this.policies = {};
    this.featuredProperty = false;
    this.hotelChain = "";
    this.details = {
    	loaded: false,
    	cancellation: "",
    	creditCard: "",
    	directions: "",
    	facility: "",
    	guarantee: "",
    	description: "",
    	location: "",
    	recreation: "",
    	services: "",
    	transportation: ""
    };
    this.policy = false;
    this.preferredProperty = false;
    this.preferredVendor = false;
    this.outOfPolicyVendor = false;
    this.rooms = [];
    this.roomsRequested = false;
    this.roomsReturned = false;
    this.images = [];
    this.isGovernmentRate = false;
    this.isCorporateRate = false;
    this.extendedDataRequested = false;

    this.PropertyId = 0 ;
    this.ChainCode = "";
    this.VendorName = "";
    this.PropertyName = "";
    this.Address = "";
    this.City = "";
    this.State = "";
    this.Zip = "";
    this.Country = "";
    this.Phone = "";
    this.Fax = "";
    this.CityCode = "";
    this.AirportCode = "";
    this.Status = "";
    this.AmenitiesList = "";
    this.Long = "";
    this.Lat = "";
    this.SignatureImage = "";
    this.Photos = "";
    this.LongLatError = "";
    this.ImageChecked = "";
    this.Internet = "";
    this.Business = "";
    this.Meeting = "";
    this.Transportation = "";
    this.Breakfast = "";
    this.Restaurant = "";
    this.RoomService = "";
    this.CheckIn = "";
    this.CheckOut = "";
    this.DetailsDateTime = "";
    this.ImagesDateTime = "";
    this.ServiceDetail = "";
    this.FacilityDetail = "";
    this.RoomDetail = "";
    this.RecreationDetail = "";
    this.PoliciesDateTime = "";
    this.CancelDetail = "";
    this.GuaranteeDetail = "";
    this.CCPolicyDetail = "";
    this.DepositPolicyDetail = "";
    this.FrequentDetail = "";
    this.AreaDateTime = "";
    this.HotelLocationDetail = "";
    this.DirectionDetail = "";
    this.AreaTransportationDetail = "";
    this.StarRating = 0;
    this.RatingService="";
    this.isInPolicy = true;
    this.distance = 0;

}

Hotel.prototype.populate = function( obj ){
    for(var propt in obj){
        this[propt] = obj[propt];
    }

    //Populate the Ameneities array from the list in the database
    if( this.AmenitiesList.length ){
        if( this.AmenitiesList.charAt(0) == "|"){
            this.AmenitiesList = this.AmenitiesList.slice( 1 );
        }

        var unsortedAmenities =
        this.Amenities = this.AmenitiesList.split("|" ).sort();

    }
}

Hotel.prototype.findLowestRoomRate = function(){
    var lowestRate = 0;

    for (var i = 0; i < this.rooms.length; i++) {
        var room = this.rooms[i];

        if( lowestRate == 0 && room.dailyRate > 0 ){
            lowestRate = room.dailyRate;
        }else if( room.dailyRate < lowestRate ){
            lowestRate = room.dailyRate;
        }
    }

    return lowestRate;
}

Hotel.prototype.isSoldOut = function(){

	if( this.findLowestRoomRate() == 0 && this.roomsReturned ){
		return true;
	} else {
		return false;
	}
}

Hotel.prototype.hasRoomsAvailable = function(){

	if( !this.isSoldOut() && this.roomsReturned ){
		return true;
	} else {
		return false;
	}

}

Hotel.prototype.setInPolicy = function( policy ){

	if( this.roomsReturned && this.rooms.length ){
		this.isInPolicy = false;
		/* Check all rooms to see if each of them are in policy
		 if any of them are, then the entire property is based
		 on the room rate policy check. There might be other reasons
		 why the hotel would be out of policy however.
		 */
		for( var i = 0; i < this.rooms.length; i++ ){
			if( this.rooms[i].isInPolicy == true ){
				this.isInPolicy = true;
				break;
			}
		}
	}
}

Hotel.prototype.hasCorporateRate = function(){
	var hasRate = false;

	for( var i = 0; i < this.rooms.length; i++ ){
		if( this.rooms[i].isCorporateRate ){
			hasRate = true;
			break;
		}
	}

	return hasRate;
}

Hotel.prototype.hasGovernmentRate = function(){
	var hasRate = false;

	for( var i = 0; i < this.rooms.length; i++ ){
		if( this.rooms[i].isGovernmentRate ){
			hasRate = true;
			break;
		}
	}

	return hasRate;
}