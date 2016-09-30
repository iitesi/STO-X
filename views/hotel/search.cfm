<cfsilent>
	<cfif cgi.https EQ "ON">
		<cfset googleMapsURL = "https://" />
	<cfelse>
		<cfset googleMapsURL = "http://" />
	</cfif>

	<cfset googleMapsURL = googleMapsURL & "maps.googleapis.com/maps/api/js?client="
						   & application.es.getGoogleMapsClientId()
						   & "&sensor=false&v=3.12" />
	<cfsavecontent variable="localAssets">
		<link href="assets/css/datepicker.css" rel="stylesheet" media="screen" />
		<link rel="stylesheet" type="text/css" href="assets/css/select2.css">
		<script src="<cfoutput>#googleMapsURL#</cfoutput>"></script>
		<script type="text/javascript" src="assets/js/StyledMarker.js"></script>
		<script type="text/javascript" src="assets/js/bootstrap-datepicker.js"></script>
		<script type="text/javascript" src="assets/js/date.format.js"></script>
		<script type="text/javascript" src="assets/js/select2.min.js"></script>
		<script type="text/javascript" src="assets/localdata/airports-us.js"></script>
		<script type="text/javascript" src="assets/js/hotel/hotelRoom.js"></script>
		<script src="assets/js/hotel/hotel.js"></script>
		<script src="assets/js/angular.min.js"></script>
		<script src="assets/js/angular-resource.min.js"></script>
		<script src="assets/js/purl.js"></script>
		<script src="assets/js/hotel/services.js"></script>
		<script src="assets/js/hotel/controllers.js"></script>
		<script src="assets/js/hotel/app.js"></script>
		<script type="text/javascript">
			shortstravel = {};
			<cfoutput>shortstravel.shortsAPIURL = '#rc.shortsAPIURL#';</cfoutput>
		</script>
	</cfsavecontent>
	<cfhtmlhead text="#localAssets#" />
</cfsilent>

<cfsetting showdebugoutput="false" />
<div id="hotel-search-wrapper" ng-app="hotelSearch">
	<div ng-view></div>
</div>


<div id="infoBox" style="visibility:hidden; position:absolute; top:0px; left:0px; width:260px; z-index:10000; font-family:Arial; font-size:10px">
  <div id="infoboxText" style="background-color:White; border-style:solid; border-width:medium; border-color:DarkOrange; min-height:100px; position:absolute; top:0px; left:23px; width:240px; ">
	<b id="infoboxTitle" style="position:absolute; top:10px; left:10px; width:220px;"></b>
	<img src="assets/img/close.png" alt="close" onclick="shortstravel.booking.hotel.closeInfoBox()" style="position:absolute;top:10px; right:10px;" />
	<a id="infoboxDescription" style="position:absolute; top:30px; left:10px; width:220px; color:##000000;"></a>
  </div>
</div>
