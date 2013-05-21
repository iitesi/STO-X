<cfsetting showdebugoutput="false" />

<cfoutput>

  <div class="container" ng-app="hotelSearch">
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

		<!-- here is where the magic happens -->
		<div id="hotelResultsContainer" class="hotel" style="height: 500px; overflow: auto">
        	<div ng-view></div>
        </div>
      </div>
      <div class="item eight columns web-design">
        #View('hotel/map')#
      </div>
    </div>
  </div>
</cfoutput>
