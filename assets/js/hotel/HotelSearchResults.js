function HotelSearchResults(){
    
    this.propertiesPerPage = 20;
    this.currentPage = 1;
    this.searchResults = [];


}

HotelSearchResults.prototype.initializeMap = function(lat, long, centerimg) {

    var center = new Microsoft.Maps.Location(lat,long);
    var mapOptions = {credentials: "AkxLdyqDdWIqkOGtLKxCG-I_Z5xEdOAEaOfy9A9wnzgXtvtPnncYjFQe6pjmpCJA", center: center, mapTypeId: Microsoft.Maps.MapTypeId.road, enableSearchLogo: false, zoom: 12}
    this.map = new Microsoft.Maps.Map( document.getElementById("mapDiv"), mapOptions);
    this.map.entities.push(new Microsoft.Maps.Pushpin(center, {icon: centerimg, zIndex:-51}));

    return false;
}

HotelSearchResults.prototype.doSearch = function( searchId ){

    $.ajax({
        type: "GET",
        url: "/booking/RemoteProxy.cfc?method=getHotelSearchResults&searchId=" + searchId,
        success: function( response ){
            $.each(response, function(item) {
                var h = new Hotel();
                h.populate( response[item] );
				shortstravel.booking.hotel.searchResults.push( h );
			});
            var totalHotels = response.length;
            var totalLabel = totalHotels + " total propert";
            if( totalHotels == 1 ){
                totalLabel = totalLabel + "y";
            }else{
                totalLabel = totalLabel + "ies";
            }
            $("#hotelcount").html( totalLabel );

            shortstravel.booking.hotel.renderPagination();
			shortstravel.booking.hotel.updateResultsDisplay();

        },
        dataType: "json"
    });


}

HotelSearchResults.prototype.displayHotelInfo = function(e) {
  if (e.targetType == "pushpin") {
    var infoboxTitle = $('#infoboxTitle')[0];
    infoboxTitle.innerHTML = e.target.title;
    var infoboxDescription = $('#infoboxDescription')[0];
    infoboxDescription.innerHTML = e.target.description;
    var infobox2 = $('#infoBox')[0];
    infobox2.style.visibility = "visible";
    $('#mapDiv').append(infobox2);
  }
  return false;
}

HotelSearchResults.prototype.closeInfoBox = function() {
  var infobox2 = $('#infoBox')[0];
  infobox2.style.visibility = "hidden";
  return false;
}

HotelSearchResults.prototype.changeLatLongCenter = function(e) {
  if (e.targetType == "map") {
    var zoom = map.getZoom();
    var infoboxvisibility = document.getElementById('infoBox').style.visibility;
    this.closeInfoBox();
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

//TODO: Refactor or remove this method
HotelSearchResults.prototype.filterhotel = function() {
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

HotelSearchResults.prototype.updateResultsDisplay = function(){

    var startRecord = ( this.currentPage - 1 ) * this.propertiesPerPage;
    var endRecord = ( startRecord + this.propertiesPerPage ) - 1;

    if( endRecord > this.searchResults.length ){
        endRecord = this.searchResults.length;
    }

    //$("#hotelcount").prepend( (startRecord+1) + '-' + (endRecord+1) + ' of ' );

    $("#hotelResultsContainer").html(''); //Clear the search results left column
    this.map.entities.clear(); //Clear pins from the map in the right column

    for( var i=startRecord; i <= endRecord; i++ ){
        var h = this.searchResults[ i ];
        this.renderProperty( h );
        this.addPin(
            $.inArray( h, this.searchResults ) + 1,
            h.Lat,
            h.Long,
            h.PropertyName,
            h.Address
        )
    }

    //Add handlers to buttons

    $( "label.hotel-details").on( "click", function(){
        var hotelRecord = $( this ).parents( ".hotelRecord" );
        var detailsRow = $( hotelRecord ).find( "tr.hotel-details" );
        if( $( detailsRow ).hasClass( "hidden" ) ){
            $( hotelRecord ).find( "tr.hotel-panel" ).addClass( "hidden" );
            $( detailsRow ).removeClass( "hidden" );
        }else{
            $( detailsRow ).addClass( "hidden" );
        }
    })
    $( "label.area-details").on( "click", function(){
        var hotelRecord = $( this ).parents( ".hotelRecord" );
        var areaRow = $( hotelRecord ).find( "tr.area-details" );
        if( $( areaRow ).hasClass( "hidden" ) ){
            $( hotelRecord ).find( "tr.hotel-panel" ).addClass( "hidden" );
           $( areaRow ).removeClass( "hidden" );
        }else{
            $( areaRow ).addClass( "hidden" );
        }
    })
    $( "label.hotel-amenities").on( "click", function(){
        var hotelRecord = $( this ).parents( ".hotelRecord" );
        var amenitiesRow = $( hotelRecord ).find( "tr.amenities" );
        if( $( amenitiesRow ).hasClass( "hidden" ) ){
            $( hotelRecord ).find( "tr.hotel-panel" ).addClass( "hidden" );
           $( amenitiesRow ).removeClass( "hidden" );
        }else{
            $( amenitiesRow ).addClass( "hidden" );
        }
    })
    $( "label.hotel-photos").on( "click", function(){
        var hotelRecord = $( this ).parents( ".hotelRecord" );
        var photosRow = $( hotelRecord ).find( "tr.photos" );
        if( $( photosRow ).hasClass( "hidden" ) ){
            $( hotelRecord ).find( "tr.hotel-panel" ).addClass( "hidden" );
           $( photosRow ).removeClass( "hidden" );
        }else{
            $( photosRow ).addClass( "hidden" );
        }
    })


}

HotelSearchResults.prototype.renderProperty = function( h ){

    //First we get a copy of the rendering template that we want to use
    var hotelRenderer = $("#hotelResultTemplate").clone();

    //Then we insert the values from the hotel property specified (h)
    $( hotelRenderer ).first().attr( "id", h.PropertyId );
    $( hotelRenderer ).find( "span.recordNumber").html( $.inArray( h, this.searchResults ) + 1 );
    $( hotelRenderer ).find( "span.propertyName" ).html( h.PropertyName  );
    $( hotelRenderer ).find( "div.hotelAddress").html( h.Address + ', ' + h.City );
    $( hotelRenderer ).find( "div.hotelDistance").html( h.distance + ' miles' );
    $( hotelRenderer ).find( "img.hotelImage").attr( "src", h.SignatureImage );

    //Next build the hotel details panel
    var table = '<table width="100%"><tr><td class="bold">HOTEL DETAILS</td></tr>';
    table+='</table>';
    $( hotelRenderer ).find( "td.hotel-details").html(table);

    //Next build the area details panel
    var table = '<table width="100%"><tr><td class="bold">AREA DETAILS</td></tr>';
    table+='</table>';
    $( hotelRenderer ).find( "td.area-details").html(table);

    //Next we build the amenities display
    var table = '<table width="100%"><tr><td class="bold">HOTEL AMENITIES</td></tr>';
    var count = 0;
    $.each(h.Amenities, function(val) {
        count++;
        if (count % 3 == 1) {
            table+='<tr>';
        }
        table+='<td width="33%">'+ h.Amenities[val]+'</td>';
        if (count % 3 == 0) {
            table+='</tr>';
        }
    });
    table+='</table>';
    $( hotelRenderer ).find( "td.amenities").html(table);

    //Next build the Photos list
    var table = '<table width="100%"><tr><td class="bold">HOTEL PHOTOS</td></tr>';
    table+='</table>';
    $( hotelRenderer ).find( "td.photos").html(table);

    //Next build the room list panel
    var table = '<table width="100%"><tr><td class="bold">ROOMS</td></tr>';
    table+='</table>';
    $( hotelRenderer ).find( "td.rooms").html(table);


    //Next, we add it to the container div
    $( hotelRenderer ).first().removeClass( 'hidden' );
    $("#hotelResultsContainer").append( hotelRenderer );

    //Lastly, we update the extended information for the hotel (area, rooms, etc)
    if( h.roomsReturned ){
       var lowestRate = Math.ceil( h.findLowestRoomRate() );

        $( hotelRenderer ).find( "img.loading" ).addClass( "hidden" );

        if( h.rooms.length == 0 || lowestRate == 0 ){
            $( hotelRenderer ).find( "span.sold-out" ).removeClass( "hidden" );
            $( hotelRenderer ).find( "span.room-details-wrapper" ).addClass( "hidden" );
        }else{
            $( hotelRenderer ).find( "span.room-details-wrapper" ).removeClass( "hidden" );
            $( hotelRenderer ).find( "span.lowest-rate" ).html( Math.ceil( h.findLowestRoomRate() ) );

            //Add event handler to "See Rooms" button
            $( hotelRenderer ).find( "button.room-details" ).on( "click", function(){
                var hotelRecord = $( this ).parents( ".hotelRecord" );
                var detailsRow = $( hotelRecord ).find( "tr.rooms" );
                if( $( detailsRow ).hasClass( "hidden" ) ){
                    $( hotelRecord ).find( "tr.hotel-panel" ).addClass( "hidden" );
                    $( detailsRow ).removeClass( "hidden" );
                    $( this ).html( "HIDE ROOMS" );
                }else{
                    $( detailsRow ).addClass( "hidden" );
                    $( this ).html( "SEE ROOMS" );
                }
            })
        }
    }else{
        this.getAvailableRooms( h, hotelRenderer );
    }

}

HotelSearchResults.prototype.getAvailableRooms = function( h, el ) {

	$.ajax({
	    type: "GET",
		url:"/booking/RemoteProxy.cfc?method=getAvailableHotelRooms&SearchID=" + shortstravel.booking.searchId + "&PropertyId=" + h.PropertyId,
		dataType: 'json',
		success:function(rooms) {
            h.roomsReturned = true;
            h.rooms = rooms;

            var lowestRate = Math.ceil( h.findLowestRoomRate() );

            $( el ).find( "img.loading" ).addClass( "hidden" );

            if( h.rooms.length == 0 || lowestRate == 0 ){
                $( el ).find( "span.sold-out" ).removeClass( "hidden" );
                $( el ).find( "span.room-details-wrapper" ).addClass( "hidden" );
            }else{
                $( el ).find( "span.room-details-wrapper" ).removeClass( "hidden" );
                $( el ).find( "span.lowest-rate" ).html( Math.ceil( h.findLowestRoomRate() ) );

                //Add event handler to "See Rooms" button
                $( el ).find( "button.room-details" ).on( "click", function(){
                    var hotelRecord = $( this ).parents( ".hotelRecord" );
                    var detailsRow = $( hotelRecord ).find( "tr.rooms" );
                    if( $( detailsRow ).hasClass( "hidden" ) ){
                        $( hotelRecord ).find( "tr.hotel-panel" ).addClass( "hidden" );
                        $( detailsRow ).removeClass( "hidden" );
                        $( this ).html( "HIDE ROOMS" );
                    }else{
                        $( detailsRow ).addClass( "hidden" );
                        $( this ).html( "SEE ROOMS" );
                    }
                })
            }
		}
	});
	return false;
}

HotelSearchResults.prototype.addPin = function( propertyNumber, lat, long, propertyName, propertyAddress ){
    var pin = new Microsoft.Maps.Pushpin(new Microsoft.Maps.Location(lat,long), {text:propertyNumber.toString(), visible:true});
    pin.title = propertyName;
    pin.description = propertyAddress;
    Microsoft.Maps.Events.addHandler(pin, 'click', this.displayHotelInfo);
    this.map.entities.push(pin);

}

HotelSearchResults.prototype.renderPagination = function( ){

    var pages = 0;

    if( this.searchResults.length % this.propertiesPerPage > 0 ){
        pages = Math.floor( this.searchResults.length / this.propertiesPerPage ) + 1;
    }else{
        pages = this.searchResults.length / this.propertiesPerPage;
    }

    for( var i=1; i<= pages; i++ ){
        $( "#page_navigation" ).append( '<a href="#" onclick="shortstravel.booking.hotel.setCurrentPage(' + i + ')">' + i + '</a>&nbsp;')
    }

}

HotelSearchResults.prototype.setCurrentPage = function( pageNumber ){
    this.currentPage = pageNumber;
    this.updateResultsDisplay();
    return false;
}
