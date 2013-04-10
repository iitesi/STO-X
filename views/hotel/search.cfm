<cfsetting showdebugoutput="false" />

<cfoutput>
  <div class="container">
    <div class="portfolio-items filterable">
      <div class="item ten columns">
        #View('hotel/filter')#

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

        <div id="hotelResultsContainer" class="hotel" height="100%"></div>
      </div>
      <div class="item eight columns web-design">
        #View('hotel/map')#
      </div>
    </div>
  </div>
</cfoutput>

<script src="http://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=7.0&mkt=en-us" charset="UTF-8" type="text/javascript"></script>

<script type="text/javascript">
    <cfoutput>
        var hotelresults = #serializeJSON(session.searches[rc.SearchID].HotelInformationQuery,true)#;
        var orderedpropertyids = "#ArrayToList(session.searches[rc.SearchID]['stSortHotels'])#";
    </cfoutput>
    orderedpropertyids = orderedpropertyids.split(',');

    <!--- var hotelresults2 = <cfoutput>#serialize(session.searches[rc.SearchID].stHotels)#</cfoutput>; --->

    if( typeof shortstravel == "undefined" ){
        var shortstravel = {};
    }

    if( typeof shortstravel.booking == "undefined" ){
        var shortstravel = {};
        shortstravel.booking = {};
    }
    shortstravel.booking.searchId = <cfoutput>#rc.SearchID#</cfoutput>;
    shortstravel.booking.hotel = {};

    <!---var hotelchains = [<cfoutput><cfset nCount = 0><cfloop array="#stHotelChains#" index="sTrip"><cfset nCount++>'#sTrip#'<cfif ArrayLen(stHotelChains) NEQ nCount>,</cfif></cfloop></cfoutput>];--->

    var map = "";
    var pins = new Object;
    var totalproperties = <cfoutput>#ArrayLen(session['searches'][rc.SearchID]['stsorthotels'])#</cfoutput>;
    var searchid = <cfoutput>#rc.SearchID#</cfoutput>;

</script>

<script src="/booking/assets/js/hotel.js"></script>
<script src="/booking/assets/js/hotelSearch.js"></script>


<!--- Prototype for rendering each hotel result --->

<div id="hotelResultTemplate" style="min-height:100px;" class="hidden">
    <table width="500px">
        <tbody>
            <tr>
                <td width="135px">
                    <div class="listcell hotelImage">image</div>
                </td>
                <td valign="top" width="365px">
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
                                    <a onclick="showDetails(266929,'95403','CZ','');return false;" class="button"><button type="button" class="textButton">Details</button>|</a>
                                    <a onclick="showRates(266929,'95403');return false;" class="button"><button type="button" class="textButton">Rooms</button>|</a>
                                    <a onclick="showAmenities(266929,'95403');return false;" class="button"><button type="button" class="textButton">Amenities</button>|</a>
                                    <a onclick="showPhotos(266929,'95403','CZ');return false;" class="button"><button type="button" class="textButton">Photos</button>|</a>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
                <td class="fares" align="center">
                    <span class="lowRate">$</span>
                    <div class="seerooms button-wrapper">
                        <a onclick="showRates(266929,'95403');return false;" class="button"><span>See Rooms</span></a>
                    </div>
                    <div class="hiderooms button-wrapper hide">
                        <a onclick="hideRates('95403');return false;" class="button"><span>Hide Rooms</span></a>
                    </div>
                </td>
            </tr>
            <tr>
                <td colspan="3" class="checkrates"></td>
            </tr>
        </tbody>
    </table>
</div>
