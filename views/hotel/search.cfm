<cfsilent>
	<cfif cgi.https EQ "ON">
		<cfset googleMapsURL = "https://" />
	<cfelse>
		<cfset googleMapsURL = "http://" />
	</cfif>

	<cfset googleMapsURL = googleMapsURL & "maps.googleapis.com/maps/api/js?client="
						   & application.es.getGoogleMapsClientId()
						   & "&sensor=false&v=3.27" />
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
		<script src="assets/js/hotel/services.js?v=<cfoutput>#application.staticAssetVersion#</cfoutput>"></script>
		<script src="assets/js/hotel/controllers.js?v=<cfoutput>#application.staticAssetVersion#</cfoutput>"></script>
		<script src="assets/js/hotel/app.js?v=<cfoutput>#application.staticAssetVersion#</cfoutput>"></script>
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
<script>
	$(function(){
		$('body').on('click', '#filterbar .dropdown-toggle', function (e) {
			var $target = $(e.target);
			var $ddown = $target.parent();
			var $others = $('#filterbar a.dropdown-toggle').parent().filter(function(){
				return $(this).attr('id') != $ddown.attr('id');
			})
			$others.removeClass('open')
			$(this).parent().toggleClass('open');
		});
		$('body').on('click', function (e) {
			var $target = $(e.target);
			var $ddown = $target.closest('.dropdown');
			if (!$ddown.length){
				$('#filterbar .dropdown.open').removeClass('open')
			}
		});
	});
</script>
<style>
	#filterChains ul.dropdown-menu {
		width:350px;
	}
	#filterAmenities ul.dropdown-menu {
		width:350px;
	}
	#filterVendorName ul.dropdown-menu {
		width:400px;
	}
	#filterRatings  ul.dropdown-menu {
		width:200px;
	}
	#filterbar .nav-pills .dropdown.active a.dropdown-toggle {
		border-color: #337ab7!important;
		background-color:#eee!important;
	}
</style>
<div id="infoBox" style="visibility:hidden; position:absolute; top:0px; left:0px; width:260px; z-index:10000; font-family:Arial; font-size:10px">
  <div id="infoboxText" style="background-color:White; border-style:solid; border-width:medium; border-color:DarkOrange; min-height:100px; position:absolute; top:0px; left:23px; width:240px; ">
	<b id="infoboxTitle" style="position:absolute; top:10px; left:10px; width:220px;"></b>
	<img src="assets/img/close.png" alt="close" onclick="shortstravel.booking.hotel.closeInfoBox()" style="position:absolute;top:10px; right:10px;" />
	<a id="infoboxDescription" style="position:absolute; top:30px; left:10px; width:220px; color:##000000;"></a>
  </div>
</div>
