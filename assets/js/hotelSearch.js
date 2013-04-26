$(document).ready(function(){

    shortstravel.booking.hotel = new HotelSearchResults();

    $.ajax({
        type: "GET",
        url: "/booking/RemoteProxy.cfc?method=getSearch&searchId=" + shortstravel.booking.searchId,
        success: function( response ){
            shortstravel.booking.Search = response;
            shortstravel.booking.hotel.initializeMap( shortstravel.booking.Search.hotelLat, shortstravel.booking.Search.hotelLong,"assets/img/center.png" );
            shortstravel.booking.hotel.doSearch( shortstravel.booking.searchId );
        },
        dataType: "json"
    });

});
