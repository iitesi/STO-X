<!--- <cfdump var="#session.searches[rc.nSearchID]#"> --->
<!--- <cfset structDelete(session.searches,214484) /> --->
<cfsetting showdebugoutput="false" />

<cfoutput>	
	#View('hotel/filter')#
	#View('hotel/map')#
	<a href="#buildURL('hotel.skip?Search_ID=#rc.nSearchID#')#">Continue without hotel</a>

	<form method="post" action="#buildURL('hotel.search')#&Search_ID=#rc.nSearchID#" id="hotelForm">
		<input type="hidden" name="bSelect" value="1">
		<input type="hidden" name="Search_ID" value="#rc.nSearchID#">
		<input type="hidden" name="sHotel" id="sHotel" value="">
		<input type="hidden" id="current_page" value="0" />
	</form>

	<br clear="both">

	<div class="hotel" height="100%">
		<cfset tripcount = 0 />
		<cfset stSortHotels 	= session.searches[rc.Search_ID].stSortHotels />
		<cfset stHotelChains	= session.searches[rc.nSearchID].stHotelChains />
		<cfset stHotels 			= session.searches[rc.Search_ID].stHotels />

		<cfloop array="#stSortHotels#" index="sHotel">

			<cfset stHotel = stHotels[sHotel] />
			<cfset tripcount++ />		
			<cfset PropertyID = sHotel />
			<cfset HotelChain = stHotel.HotelChain />
			<cfset HotelAddress = '' /><!--- Set a default address, the original ddress returned is garbage --->
			<cfif stHotel.RoomsReturned><!--- We have the real address --->
				<cfset HotelAddress = structKeyExists(stHotel,'Property') ? stHotel['Property']['Address1'] : '' />
				<cfset HotelAddress&= structKeyExists(stHotel,'Property') AND Len(Trim(stHotel['Property']['Address2'])) ? ', '&stHotel['Property']['Address2'] : '' />		
			</cfif>

			<div id="#sHotel#" style="min-height:100px;">

				<cfset RoomRatePlanType = '' />
				<cfif structKeyExists(stHotel,'Rooms')>
					<cfloop list="#StructKeyList(stHotel.Rooms,'|')#" index="OneRoom" delimiters="|">
						<cfif Len(Trim(stHotel.Rooms[OneRoom].RoomRatePlanType))>
							<cfset RoomRatePlanType = stHotel.Rooms[OneRoom].RoomRatePlanType />
							<cfbreak />
						</cfif>
					</cfloop>		
				</cfif>

				<table width="600px">
				<tr>
					<td width="135px">
						<div id="hotelimage#sHotel#" class="listcell" style="width:125px; overflow:none; border:1px solid ##FFFFFF">
							<cfset Signature_Image = StructKeyExists(stHotels[sHotel],'HOTELINFORMATION') AND StructKeyExists(stHotels[sHotel]['HOTELINFORMATION'],'SIGNATURE_IMAGE') ? stHotels[sHotel]['HOTELINFORMATION']['SIGNATURE_IMAGE'] : 'assets/img/MissingHotel.png' />
							<img width="125px" src="#Signature_Image#" />
						</div>
					</td>
					<td valign="top">
						<table width="400px">
						<tr>
							<td><div id="number#sHotel#" style="float:left;">#tripcount#</div> - #HotelChain# #stHotel.HotelInformation.Name#<font color="##FFFFFF"> #sHotel#</font></td>
						</tr>
						<tr>
							<td><div id="address#sHotel#">#HotelAddress#</div></td>
						</tr>
						<cfif NOT stHotel.RoomsReturned OR (StructKeyExists(stHotel,'LowRate') AND stHotel.LowRate NEQ 'Sold Out')>
							<tr id="DetailLinks#sHotel#">
								<td>
									<a onClick="showDetails(#rc.nSearchID#,'#sHotel#','#HotelChain#','#RoomRatePlanType#');return false;" class="button"><button type="button" class="textButton">Details</button>|</a>
									<a onClick="showRates(#rc.nSearchID#,'#sHotel#');return false;" class="button"><button type="button" class="textButton">Rooms</button>|</a>
									<a onClick="showAmenities(#rc.nSearchID#,'#sHotel#');return false;" class="button"><button type="button" class="textButton">Amenities</button>|</a>
									<a onClick="showPhotos(#rc.nSearchID#,'#sHotel#','#HotelChain#');return false;" class="button"><button type="button" class="textButton">Photos</button>|</a>
								</td>
							</tr>
						</cfif>
						</table>
					</td>
					<td class="fares" align="center" id="checkrates2#sHotel#">

						<cfif NOT stHotel.RoomsReturned>
							<script type="text/javascript">
							hotelPrice(#rc.Search_ID#, '#sHotel#', '#HotelChain#');
							</script>
							<img src="assets/img/ajax-loader.gif" />
						<cfelse>
							<cfset RateText = StructKeyExists(stHotel,'LowRate') ? stHotel.LowRate NEQ 'Sold Out' ? DollarFormat(stHotel.LowRate) : stHotel.LowRate : 'Rates not found' />
							#RateText#
							<cfif RateText NEQ 'Sold Out'>							
								<div id="seerooms#sHotel#" class="button-wrapper">
									<a onClick="showRates(#rc.nSearchID#,'#sHotel#');return false;" class="button"><span>See Rooms</span></a>
								</div>
								<div id="hiderooms#sHotel#" class="button-wrapper hide">
									<a onClick="hideRates('#sHotel#');return false;" class="button"><span>Hide Rooms</span></a>
								</div>									
							</cfif>
						</cfif>	
						<!--- <a href="http://localhost:8888/booking/services/hotelprice.cfc?method=doHotelPrice&nSearchID=#rc.Search_ID#&nHotelCode=#sHotel#&sHotelChain=#HotelChain#" target="_blank">Link</a><br> --->
					</td>
				</tr>
				<tr>
					<td colspan="3" id="checkrates#sHotel#"></td>
				</tr>
				</table>
			</div>
		</cfloop>
	</div>

	<script src="http://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=7.0&mkt=en-us" charset="UTF-8" type="text/javascript"></script>
	<script type="text/javascript">
		var hotelchains = [<cfset nCount = 0><cfloop array="#stHotelChains#" index="sTrip"><cfset nCount++>'#sTrip#'<cfif ArrayLen(stHotelChains) NEQ nCount>,</cfif></cfloop>];

		var map = "";
		var pins = new Object;
		var totalproperties = <cfoutput>#ArrayLen(session['searches'][rc.Search_ID]['stsorthotels'])#</cfoutput>;

		function loadMap(lat, long, centerimg) {
		
			var center = new Microsoft.Maps.Location(lat,long);
			var mapOptions = {credentials: "AkxLdyqDdWIqkOGtLKxCG-I_Z5xEdOAEaOfy9A9wnzgXtvtPnncYjFQe6pjmpCJA", center: center, mapTypeId: Microsoft.Maps.MapTypeId.road, enableSearchLogo: false, zoom: 12}
			var map = new Microsoft.Maps.Map(document.getElementById("mapDiv"), mapOptions);
			map.entities.push(new Microsoft.Maps.Pushpin(center, {icon: centerimg, zIndex:-51}));		
			
			var orderedpropertyids = "#ArrayToList(session.searches[rc.Search_ID]['stSortHotels'])#";
			orderedpropertyids = orderedpropertyids.split(',');	

			var hotelresults = #serialize(session.searches[rc.Search_ID].stHotels)#;
			for (loopcnt = 0; loopcnt < orderedpropertyids.length; loopcnt++) {
				var propertyid = orderedpropertyids[loopcnt];
				var property = hotelresults[propertyid]['HOTELINFORMATION'];
				var propertylat = property['LATITUDE'];
				var propertylong = property['LONGITUDE'];
				var propertyname = property['NAME'];
				var propertyaddress = property['HOTELADDRESS'];
				pins[propertyid] = new Microsoft.Maps.Pushpin(new Microsoft.Maps.Location(propertylat,propertylong), {text:loopcnt, visible:true});
				pins[propertyid].title = propertyname;
				pins[propertyid].description = propertyaddress;
				Microsoft.Maps.Events.addHandler(pins[propertyid], 'click', displayHotelInfo);
				map.entities.push(pins[propertyid]);
			}
			//Microsoft.Maps.Events.addHandler(map, 'click', changeLatLongCenter); lets you re-search			
			return false;
		}

		$(document).ready(function() {
			//$("##Hotel_Airport").autocomplete({ source: airports, minLength: 3 });
			//$("##Hotel_Landmark").autocomplete({ source: landmarks, minLength: 3 });
			//overall search hotel latitude and longitude
			loadMap(<cfoutput>#session.searches[rc.nSearchID].Hotel_Lat#,#session.searches[rc.nSearchID].Hotel_Long#,"http://localhost:8888/booking/assets/img/center.png"</cfoutput>);
			//hotelstructure();
			//filterhotel();
			//stohotel();
			//toggleDiv('filterpref');
			//toggleDiv('filterchains');
			//toggleDiv('filtername');
		});
	</script>
</cfoutput>

<script type="text/javascript">
$( filterhotel() );
</script>