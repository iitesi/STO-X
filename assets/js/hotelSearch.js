$(document).ready(function(){

    shortstravel.booking.hotel.propertiesPerPage = 20;
    shortstravel.booking.hotel.currentPage = 1;

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

shortstravel.booking.hotel.initializeMap = function(lat, long, centerimg) {

    var center = new Microsoft.Maps.Location(lat,long);
    var mapOptions = {credentials: "AkxLdyqDdWIqkOGtLKxCG-I_Z5xEdOAEaOfy9A9wnzgXtvtPnncYjFQe6pjmpCJA", center: center, mapTypeId: Microsoft.Maps.MapTypeId.road, enableSearchLogo: false, zoom: 12}
    shortstravel.booking.hotel.map = new Microsoft.Maps.Map( document.getElementById("mapDiv"), mapOptions);
    shortstravel.booking.hotel.map.entities.push(new Microsoft.Maps.Pushpin(center, {icon: centerimg, zIndex:-51}));

    return false;
}

shortstravel.booking.hotel.doSearch = function( searchId ){

    $.ajax({
        type: "GET",
        url: "/booking/RemoteProxy.cfc?method=getHotelSearchResults&searchId=" + searchId,
        success: function( response ){

            shortstravel.booking.hotel.searchResults = [];

            $.each(response, function(item) {
                var h = new Hotel();
                h.populate( response[item] );
				shortstravel.booking.hotel.searchResults.push( h );
			});

			shortstravel.booking.hotel.updateResultsDisplay();

        },
        dataType: "json"
    });


}

shortstravel.booking.hotel.displayHotelInfo = function(e) {
  if (e.targetType == "pushpin") {
    var infoboxTitle = $('#infoboxTitle')[0];
    infoboxTitle.innerHTML = e.target.title;
    var infoboxDescription = $('#infoboxDescription')[0];
    infoboxDescription.innerHTML = e.target.description;
    var infobox2 = $('#infoBox')[0];
    infobox2.style.visibility = "visible";
    document.getElementById('mapDiv').appendChild(infobox2);
  }
  return false;
}

shortstravel.booking.hotel.closeInfoBox = function() {
  var infobox2 = $('#infoBox')[0];
  infobox2.style.visibility = "hidden";
  return false;
}

shortstravel.booking.hotel.changeLatLongCenter = function(e) {
  if (e.targetType == "map") {
    var zoom = map.getZoom();
    var infoboxvisibility = document.getElementById('infoBox').style.visibility;
    shortstravel.booking.hotel.closeInfoBox();
    if (zoom >= 12 && infoboxvisibility == 'hidden') {
      $("#dialog").dialog({
        buttons: { "Yes": function() {
        var point = new Microsoft.Maps.Point(e.getX(), e.getY());
        var loc = e.target.tryPixelToLocation(point);
        $( "#latlong" ).val(loc['latitude']+','+loc['longitude']);
        $( "#changelatlong" ).submit();
        $(this).dialog("close");
        },
      'No': function() {
        $(this).dialog("close");
        }
      }
      });
    }
  }
  return false;
}

shortstravel.booking.hotel.filterhotel = function() {
  // pages & sorting
  var start_from = $( "#current_page" ).val() * 20;
  var end_on = start_from + 20;
  var matchcriteriacount = 0;

  for (var t = 0; t < orderedpropertyids.length; t++) {
    // start the loop with 7 because property_id, signature_image, lat, long, chain_code, policy, lowrate, SOLDOUT are 0-7
    for (var i = 7; i < hotelresults.COLUMNS.length; i++) {
      var ColumnName = hotelresults.COLUMNS[i];
      var propertymatch = 1;
      if ($("#" + ColumnName + ":checked").val() != undefined) {
        if (hotelresults.DATA[ColumnName][t] == 0) {// if the value is checked and it's not active for this property mark propertymatch as 0
          propertymatch = 0;
          break;
        }
      }
    }

    // check chain code match
    var chaincode = hotelresults.DATA['CHAIN_CODE'][t];
    if (propertymatch == 1) {
      if ($("#HotelChain" + chaincode + ":checked").val() == undefined) {
        propertymatch = 0;
      }
    }

    // check Policy
    var Policy = $( "input:checkbox[name=Policy]:checked" ).val();
    var PolicyValue = hotelresults.DATA['POLICY'][t];
    if (propertymatch == 1 && Policy == 'on' && PolicyValue != '1') {
      propertymatch = 0;
    }

    // check Sold Out
    var SoldOut = $( "input:checkbox[name=SoldOut]:checked" ).val();
    var SoldOutValue = hotelresults.DATA['SOLDOUT'][t];
    //console.log('new property' + t);
    //console.log(hotelresults.DATA['SOLDOUT']);
    //console.log(SoldOut);
    //console.log(SoldOutValue);
    if (propertymatch == 1 && SoldOut == 'on' && SoldOutValue == '1') {
      propertymatch = 0;
      //console.log('hide' + propertyid);
    }

    var propertyid = hotelresults.DATA['PROPERTY_ID'][t];
    if (propertymatch == 1) {
      $("#" + propertyid ).show('fade');
      pins[propertyid].setOptions({visible: true});
      matchcriteriacount++;
      if (matchcriteriacount >= start_from && matchcriteriacount < end_on) {
        $("#"+propertyid ).show('fade');
        $("#number"+propertyid).html(matchcriteriacount);
        pins[propertyid].setOptions({visible:true, text:'' + matchcriteriacount + '', zIndex:1000});
      }
      else {
        $("#" + propertyid ).hide('fade');
        pins[propertyid].setOptions({visible: false});
      }
    }
    else {
      $("#" + propertyid ).hide('fade');
      pins[propertyid].setOptions({visible: false});
    }
  }

  writePages(matchcriteriacount);
  if (matchcriteriacount != totalproperties) {
    $( "#hotelcount" ).html(matchcriteriacount + ' of ' + totalproperties + ' total properties');
  }
  else {
    $( "#hotelcount" ).html(totalproperties +' total properties');
  }
  return false;
}

shortstravel.booking.hotel.updateResultsDisplay = function(){

    var startRecord = ( shortstravel.booking.hotel.currentPage - 1 ) * shortstravel.booking.hotel.propertiesPerPage;
    var endRecord = ( startRecord + shortstravel.booking.hotel.propertiesPerPage ) - 1;

    if( endRecord > shortstravel.booking.hotel.searchResults.length ){
        endRecord = shortstravel.booking.hotel.searchResults.length;
    }
    $("#hotelResultsContainer").html('');

    for( var i=startRecord; i <= endRecord; i++ ){
        var h = shortstravel.booking.hotel.searchResults[ i ];
        shortstravel.booking.hotel.renderProperty( h );
        shortstravel.booking.hotel.addPin(
            $.inArray( h, shortstravel.booking.hotel.searchResults ) + 1,
            h.Lat,
            h.Long,
            h.PropertyName,
            h.Address
        )
    }

}

shortstravel.booking.hotel.renderProperty = function( h ){

    //First we get a copy of the rendering template that we want to use
    var newHotel = $("#hotelResultTemplate").clone();

    //Then we insert the values from the hotel property specified (h)
    $( newHotel ).first().attr( "id", h.PropertyId );
    $( newHotel ).find( "div.recordNumber").html( $.inArray( h, shortstravel.booking.hotel.searchResults ) + 1 );
    $( newHotel ).find( "span.propertyName" ).html( h.PropertyName );
    $( newHotel ).find( "span.hotelAddress").html( h.Address + ', ' + h.City + " " + h.State + " " + h.Zip + " " + h.Country );

    //Lastly, we add it to the container div
    $( newHotel ).first().removeClass( 'hidden' );
    $("#hotelResultsContainer").append( newHotel );

}

shortstravel.booking.hotel.addPin = function( propertyNumber, lat, long, propertyName, propertyAddress ){
    var pin = new Microsoft.Maps.Pushpin(new Microsoft.Maps.Location(lat,long), {text:propertyNumber.toString(), visible:true});
    pin.title = propertyName;
    pin.description = propertyAddress;
    Microsoft.Maps.Events.addHandler(pin, 'click', shortstravel.booking.hotel.displayHotelInfo);
    shortstravel.booking.hotel.map.entities.push(pin);

}