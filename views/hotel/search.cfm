<cfsetting showdebugoutput="false" />
<div ng-app="hotelSearch">
	<div ng-view></div>
</div>


<div id="infoBox" style="visibility:hidden; position:absolute; top:0px; left:0px; width:260px; z-index:10000; font-family:Arial; font-size:10px">
  <div id="infoboxText" style="background-color:White; border-style:solid; border-width:medium; border-color:DarkOrange; min-height:100px; position:absolute; top:0px; left:23px; width:240px; ">
	<b id="infoboxTitle" style="position:absolute; top:10px; left:10px; width:220px;"></b>
	<img src="assets/img/close.png" alt="close" onclick="shortstravel.booking.hotel.closeInfoBox()" style="position:absolute;top:10px; right:10px;" />
	<a id="infoboxDescription" style="position:absolute; top:30px; left:10px; width:220px; color:##000000;"></a>
  </div>
</div>