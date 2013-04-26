<cfsetting showdebugoutput="false" />

<cfoutput>
  <div class="container">
    <div class="portfolio-items filterable">
      <div class="item ten columns">
        <!---#View('hotel/filter')#--->

        <a href="#buildURL('hotel.skip?SearchID=#rc.SearchID#')#">Continue without hotel</a>
        <span id="hotelcount" style="float:right;"></span>

        <div id="hotelcountwrapper">
          <div id="page_navigation"></div>
        </div>

        <div id="infoBox" style="visibility:hidden; position:absolute; top:0px; left:0px; width:260px; z-index:10000; font-family:Arial; font-size:10px">
          <div id="infoboxText" style="background-color:White; border-style:solid; border-width:medium; border-color:DarkOrange; min-height:100px; position:absolute; top:0px; left:23px; width:240px; ">
            <b id="infoboxTitle" style="position:absolute; top:10px; left:10px; width:220px;"></b>
            <img src="assets/img/close.png" alt="close" onclick="shortstravel.booking.hotel.closeInfoBox()" style="position:absolute;top:10px; right:10px;" />
            <a id="infoboxDescription" style="position:absolute; top:30px; left:10px; width:220px; color:##000000;"></a>
          </div>
        </div>

        <form method="post" action="#buildURL('hotel.search')#&SearchID=#rc.SearchID#" id="hotelForm">
          <input type="hidden" name="bSelect" value="1">
          <input type="hidden" name="SearchID" value="#rc.SearchID#">
          <input type="hidden" name="sHotel" id="sHotel" value="">
          <input type="hidden" name="sRoomDescription" id="sRoomDescription" value="">
          <input type="hidden" id="current_page" value="0" />
        </form>

        <!--- <br clear="both"> --->

        <div id="hotelResultsContainer" class="hotel" style="height: 760px; overflow: auto"></div>
      </div>
      <div class="item eight columns web-design">
        #View('hotel/map')#
      </div>
    </div>
  </div>
</cfoutput>

<script src="http://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=7.0&mkt=en-us" charset="UTF-8" type="text/javascript"></script>

<script type="text/javascript">

    if( typeof shortstravel == "undefined" ){
        var shortstravel = {};
    }

    if( typeof shortstravel.booking == "undefined" ){
        var shortstravel = {};
        shortstravel.booking = {};
    }

    $(document).ready(function(){

        shortstravel.booking.searchId = <cfoutput>#rc.SearchID#</cfoutput>;
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

</script>

<script src="/booking/assets/js/hotel/hotel.js"></script>
<script src="/booking/assets/js/hotel/HotelSearchResults.js"></script>


<!--- Prototype for rendering each hotel result --->

<div id="hotelResultTemplate" class="hotelRecord hidden" style="padding-left: 5px; padding-right: 5px; background-color: #FFFFFF; min-height:100px; border-bottom: 2px solid #EEEEEE; border-right: 2px solid #EEEEEE; border-left: 2px solid #EEEEEE; margin-top: 7px;" class="hidden">
    <table width="500px">
        <tbody>
            <tr>
                <td width="135px" style="margin-right: 5px;">
                    <div class="listcell hotelImage"><img class="hotelImage" src=""></div>
                </td>
                <td valign="top" width="360px">
                    <table width="365px">
                        <tbody>
                            <tr>
                                <td>
                                    <div class="recordNumber" style="float:left;"></div> - <span class="propertyName"></span>
                                </td>
                            </tr>
                            <tr>
                                <td><div class="hotelAddress"></div></td>
                            </tr>
                            <tr class="detailLinks">
                                <td>
                                    <div class="btn-group">
                                        <button class="hotel-details btn btn-mini" value="RT">Details</button>
                                        <button class="area-details btn btn-mini" value="RT">Area</button>
                                        <button class="hotel-amenities btn btn-mini" value="RT">Amenities</button>
                                        <button class="hotel-photos btn btn-mini" value="RT">Photos</button>

                                        <!---<a onclick="showDetails(266929,'95403','CZ','');return false;" class="button"><button type="button" class="textButton">Details</button>|</a>
                                        <a onclick="showRates(266929,'95403');return false;" class="button"><button type="button" class="textButton">Rooms</button>|</a>
                                        <a onclick="showAmenities(266929,'95403');return false;" class="button"><button type="button" class="textButton">Amenities</button>|</a>
                                        <a onclick="showPhotos(266929,'95403','CZ');return false;" class="button"><button type="button" class="textButton">Photos</button></a>--->
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
                <td class="fares" align="center">
                    <img class="loading" src="/booking/assets/img/ajax-loader.gif">
                    <span class="lowRate"></span>
                    <span class="room-details-wrapper hidden">
                        <span class="lowest-rate"></span>
                        <button class="room-details btn btn-mini" value="RT">Details</button>
                    </span>
                    <!---
                    <div class="seerooms button-wrapper">
                        <a onclick="showRates(266929,'95403');return false;" class="button"><span>See Rooms</span></a>
                    </div>
                    <div class="hiderooms button-wrapper hide">
                        <a onclick="hideRates('95403');return false;" class="button"><span>Hide Rooms</span></a>
                    </div>
                    --->
                </td>
            </tr>
            <tr class="hidden hotel-panel hotel-details">
                <td colspan="3" class="hotel-details"></td>
            </tr>
            <tr class="hidden hotel-panel area-details">
                <td colspan="3" class="area-details"></td>
            </tr>
            <tr class="hidden hotel-panel amenities">
                <td colspan="3" class="amenities"></td>
            </tr>
            <tr class="hidden hotel-panel photos">
                <td colspan="3" class="photos"></td>
            </tr>
            <tr class="hidden hotel-panel rooms">
                <td colspan="3" class="rooms"></td>
            </tr>
        </tbody>
    </table>
</div>
