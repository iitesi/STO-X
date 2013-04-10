function Hotel(){

    this.amenities =  [];
    this.policies = {};
    this.featuredProperty = false;
    this.hotelChain = "";
    this.hotelInformation = {};
    this.policy = false;
    this.preferredVendor = false;
    this.roomsReturned = false;

    this.PropertyId = 0 ;
    this.ChainCode = "";
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
    this.distance = 0;

    this.populate = function( obj ){
        for(var propt in obj){
            this[propt] = obj[propt];
        }
    }

}
