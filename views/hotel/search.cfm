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

        //TODO: THIS SHOULD REALLY NOT BE NESTED THIS WAY
        $.ajax({
            type: "GET",
            url: "/booking/RemoteProxy.cfc?method=getSearch&searchId=" + shortstravel.booking.searchId,
            dataType: "json",
            success: function( response ){
                shortstravel.booking.Search = response.data;
                shortstravel.booking.hotel.initializeMap( shortstravel.booking.Search.hotelLat, shortstravel.booking.Search.hotelLong,"assets/img/center.png" );

                $.ajax({
                    type: "GET",
                    url: "/booking/RemoteProxy.cfc?method=getAccount&accountId=" + shortstravel.booking.Search.acctID,
                    dataType: "json",
                    success: function( response ){

                        shortstravel.booking.Account = response;
                        $.ajax({
                            type: "GET",
                            url: "/booking/RemoteProxy.cfc?method=getAccountPolicies&accountId=" + shortstravel.booking.Search.acctID,
                            dataType: "json",
                            success: function( response ){
                                shortstravel.booking.Account.policies = response;
                                shortstravel.booking.hotel.doSearch( shortstravel.booking.searchId );
                            }
                        })
                    }
                })
            },
            error: function( e ){

            }
        });

    });

</script>

<script src="/booking/assets/js/hotel/hotel.js"></script>
<script src="/booking/assets/js/hotel/HotelSearchResults.js"></script>


<!--- Prototype for rendering each hotel result --->

<div id="hotelResultTemplate" class="hotelRecord hidden" style="padding-bottom: 15px; padding-left: 5px; padding-right: 5px; background-color: #FFFFFF; min-height:100px; border-bottom: 2px solid #EEEEEE; border-right: 2px solid #EEEEEE; border-left: 2px solid #EEEEEE; margin-top: 7px;" class="hidden">
    <table width="500px">
        <tbody>
            <tr>
                <td style="width: 100px;">
                    <img class="hotelImage" src="" heigh>
                </td>
                <td valign="top" style="padding-left: 20px; width: 280px;">
                    <div class="hotelName" style="width: 100%; clear: both; font-weight: bold;">
                        <span class="recordNumber"></span> - <span class="propertyName"></span>
                    </div>

                    <div class="hotelAddress" style="width: 100%; clear: both; font-size: 11px;"></div>
                    <div class="hotelDistance" style="width: 100%; clear: both; font-size: 11px; font-weight: bolder;"></div>

                    <div class="detailLinks">
                        <div class="ui-buttonset">
                            <label class="hotel-details ui-button ui-widget ui-state-default ui-button-text-only ui-corner-left" role="button" aria-disabled="false">
                                <span class="ui-button-text">Details</span>
                            </label>

                            <label class="area-details ui-button ui-widget ui-state-default ui-button-text-only ui-corner-left" role="button" aria-disabled="false">
                                <span class="ui-button-text">Area</span>
                            </label>

                            <label class="hotel-amenities ui-button ui-widget ui-state-default ui-button-text-only ui-corner-left" role="button" aria-disabled="false">
                                <span class="ui-button-text">Amenities</span>
                            </label>

                            <label class="hotel-photos ui-button ui-widget ui-state-default ui-button-text-only ui-corner-left" role="button" aria-disabled="false">
                                <span class="ui-button-text">Photos</span>
                            </label>
                        </div>

                    </div>

                </td>
                <td class="fares" align="center" style="width: 100px;">
                    <img class="loading" src="/booking/assets/img/ajax-loader.gif">
                    <span class="sold-out hidden" style="color: #FF0000; font-weight: bold;">SOLD OUT</span>
                    <span class="room-details-wrapper hidden">
                        <span class="lowest-rate" style="clear: both;"></span>
                        <button class="room-details btn btn-mini btn-primary">SEE ROOMS</button>
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

