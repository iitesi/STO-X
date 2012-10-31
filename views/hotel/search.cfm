<!--- <cfset application.hotelphotos = CreateObject('component','booking.services.hotelphotos') /> --->


<cfsetting showdebugoutput="false" />

<!--- Map --->

<!--- hotel : hotelstructure --->
<!--- <cffunction name="hotelstructure" access="remote" returntype="string" output="true">
	
	<cfset var hotelstructure = ''>
	<cfset var HotelImage = ''>
	
	<cfset hotelstructure = 'var hotelresults = new Object;'>
	<cfoutput query="hotelresults" group="Property_ID">
		<cfif Signature_Image NEQ ''>
			<cfset HotelImage = Signature_Image>
		<cfelse>
			<cfset HotelImage = application.serverurl&'/assets/img/MissingHotel.png'>
		</cfif>
		<cfset hotelstructure = hotelstructure&'hotelresults[#Property_ID#] = [0,0,"#Trim(Property_Name)#",#Internet#,#Business#,#Meeting#,#Transportation#,#Breakfast#,#Restaurant#,#RoomService#,"#HotelImage#",#LowChecked#,#Policy#,#SoldOut#,#LowRate#,"#Vendor_Code#","#Hotel_CityCode#","USD",0,#Lat#,#Long#,#Traveler_Preferred#,#Preferred#,"#Trim(Address)#<br>#Trim(City)#, #Trim(State)#"];'>
	</cfoutput>
	
	<cfreturn hotelstructure />
</cffunction>
 --->

<cfoutput>	
	<!--- #View('hotel/filter')# --->
	#View('hotel/map')#

	<br clear="both">

	<div class="hotel" heigth="100%">
		<cfset tripcount = 0 />
		<cfset stSortHotels = session.searches[rc.Search_ID].stSortHotels />
		<cfset stHotelChains = session.searches[rc.nSearchID].stHotelChains />
		<!--- <cfset HotelInformation = application.hotelphotos.HotelInformation(session.searches[rc.Search_ID].stHotels,rc.Search_ID) />
		<cfdump eval=HotelInformation> --->
		<cfset stHotels = session.searches[rc.Search_ID].stHotels />


		<cfdump var="#ArrayToList(session.searches[rc.Search_ID]['stSortHotels'])#" />

		<cfloop array="#stSortHotels#" index="sHotel">
			<cfset stHotel = session.searches[rc.Search_ID].stHotels[sHotel]>
			<!--- <cfdump eval=session.searches[rc.Search_ID].stHotels abort> --->
			<!--- <cfdump eval=stHotel abort> --->
			<cfset tripcount++ />

			<cfif tripcount LT 10>

				<cfset HotelAddress = '' /><!--- Set a default address, the original ddress returned is garbage --->
				<cfif stHotel.RoomsReturned><!--- We have the real address --->
					<cfset HotelAddress = structKeyExists(stHotel,'Property') ? stHotel['Property']['Address1'] : '' />
					<cfset HotelAddress&= structKeyExists(stHotel,'Property') AND Len(Trim(stHotel['Property']['Address2'])) ? ', '&stHotel['Property']['Address2'] : '' />		
				</cfif>
				
				<!--- We already have the rates/policy add them as data elements to the div --->
				<cfset DivElements = '' />
				<cfif stHotel.RoomsReturned>
					<cfset DivElements = 'data-policy="'&stHotel.Policy&'"' />
					<cfset DivElements&= 'data-minrate="'&stHotel.LowRate&'"' />
				</cfif>

				<div id="#sHotel#" style="min-height:100px;" data-chain="#stHotel.HotelChain#"#DivElements#>
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
								<td>#tripcount# - #stHotel.HotelChain# #stHotel.HotelInformation.Name#<font color="##FFFFFF"> #sHotel#</font></td>
							</tr>
							<tr>
								<td><div id="address#sHotel#">#HotelAddress#</div></td>
							</tr>
							<tr>
								<td>
									<a title="Details" id="details#sHotel#" class="linkbutton roundleft" onClick="hotelDetails(#sHotel#, 'details');return false;">Details</a>
									<a title="Rooms" id="rates#sHotel#" class="linkbutton" onClick="showRates(#sHotel#);return false;">Rooms</a>
									<a title="Amenities" id="amenities#sHotel#" class="linkbutton" onClick="hotelAmenities(#sHotel#);return false;">Amenities</a>									
									<!--- <a title="Photos" id="photos#sHotel#" class="linkbutton" onClick="hotelPhotos(#sHotel#, '#stPhotos[sHotel]#');return false;">Photos</a> --->									
									<a title="Area" id="area#sHotel#" class="linkbutton roundright" onClick="hotelDetails(#sHotel#, 'area');return false;">Area</a>
								</td>
							</tr>
							<!--- <cfset stHotelPhotos = application.hotelphotos.doHotelPhotoGallery(rc.Search_ID,sHotel,stHotel.HotelChain) />			
							<cfloop array="#stHotelPhotos[sHotel]['aHotelPhotos']#" index="local.Photo">
								<img src="#Photo#"><br/>
							</cfloop> --->
							</table>
						</td>
						<td class="fares" align="right">

							<cfif NOT stHotel.RoomsReturned>
								<script type="text/javascript">
								hotelPrice(#rc.Search_ID#, #sHotel#, '#stHotel.HotelChain#');
								</script>
								<div id="checkrates#sHotel#">
									<img src="assets/img/ajax-loader.gif" />
								</div>
							<cfelse>

								#stHotel.Policy#<br />
								<!--- #ArrayToList(stHotel.APolicies)#<br />
								#stHotel.PreferredVendor#<br /> --->
								<cfset RateText = StructKeyExists(stHotel,'LowRate') ? stHotel.LowRate NEQ 'Sold Out' ? DollarFormat(stHotel.LowRate) : stHotel.LowRate : 'Rates not found' />
								#RateText#
								<input type="submit" #RateText NEQ 'Sold Out' ? 'onClick="showRates(#rc.Search_ID#,#sHotel#);return false;"' : ''# class="button#stHotel.Policy#policy" name="trigger" value="#RateText NEQ 'Sold Out' ? 'See Rooms' : 'Sold Out'#">

							</cfif>	

							<!---<script type="text/javascript">
							showRates(#rc.Search_ID#,#sHotel#);
							</script>--->

							<!--- <cfinvoke component="services.hotelrooms" method="getRooms" nSearchID="#rc.nSearchID#" nHotelCode="#sHotel#" returnvariable="HotelRooms" />
							<cfdump var="#deSerializeJSON(HotelRooms)#"> --->
				

							<cfoutput>
								<a href="http://localhost:8888/booking/services/hotelprice.cfc?method=doHotelPrice&nSearchID=#rc.Search_ID#&nHotelCode=#sHotel#&sHotelChain=#stHotel.HotelChain#" target="_blank">Link</a><br>
							</cfoutput>

						</td>
					</tr>
					<tr>
						<td colspan="3">							
							<div id="hotelrooms#sHotel#">hello</div>
						</td>
					</tr>
					</table>
				</div>
			</cfif>
		</cfloop>
	</div>

	<script type="text/javascript">
	var hotelchains = [<cfset nCount = 0><cfloop array="#stHotelChains#" index="sTrip"><cfset nCount++>'#sTrip#'<cfif ArrayLen(stHotelChains) NEQ nCount>,</cfif></cfloop>];
	</script>

	<!--- #view('hotel/map')# --->


	<script src="https://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=7.0&s=1" charset="UTF-8" type="text/javascript"></script>
	<script type="text/javascript">
	var map = "";
	var pins = new Object;
	var totalproperties = <cfoutput>#ArrayLen(session['searches']['190514']['stsorthotels'])#</cfoutput>;

	$(document).ready(function loadMap(lat, long, centerimg) {
	
		var center = new Microsoft.Maps.Location(lat,long);
		var mapOptions = {credentials: "AkxLdyqDdWIqkOGtLKxCG-I_Z5xEdOAEaOfy9A9wnzgXtvtPnncYjFQe6pjmpCJA", center: center, mapTypeId: Microsoft.Maps.MapTypeId.road, enableSearchLogo: false, zoom: 12}
		map = new Microsoft.Maps.Map(document.getElementById("mapDiv"), mapOptions);
		map.entities.push(new Microsoft.Maps.Pushpin(center, {icon: centerimg, zIndex:-51}));
		
		<cfset orderedpropertyids = ArrayToList(session.searches[rc.Search_ID]['stSortHotels']) />
		<cfloop list="#orderedpropertyids#" index="i">
			<cfset propertyid = i />
			var hotelresults = #serialize(session.searches[rc.Search_ID].stHotels[propertyid])#;
			console.log(hotelresults);
		</cfloop>


		var orderedpropertyids = '#ArrayToList(session.searches[rc.Search_ID]['stSortHotels'])#';
		orderedpropertyids = orderedpropertyids.split(',');		
		
		for (loopcnt = 0; loopcnt < orderedpropertyids.length; loopcnt++) {
			var propertyid = orderedpropertyids[loopcnt];
			var property = HotelInformation[propertyid];
			var propertylat = property[19];
			var propertylong = property[20];
			var propertyname = property[2];
			var propertyaddress = property[23];
			pins[propertyid] = new Microsoft.Maps.Pushpin(new Microsoft.Maps.Location(propertylat,propertylong), {text:loopcnt, visible:true});
			pins[propertyid].title = propertyname;
			pins[propertyid].description = propertyaddress;
			//Microsoft.Maps.Events.addHandler(pins[propertyid], 'click', displayHotelInfo); shows information for specific hotel
			map.entities.push(pins[propertyid]);
		}
		//Microsoft.Maps.Events.addHandler(map, 'click', changeLatLongCenter); lets you re-search
		
		return false;
	});

	$(document).ready(function() {
		//$("##Hotel_Airport").autocomplete({ source: airports, minLength: 3 });
		//$("##Hotel_Landmark").autocomplete({ source: landmarks, minLength: 3 });
		//overall search hotel latitude and longitude
		loadMap(<cfoutput>#session.searches[rc.nSearchID].Hotel_Lat#,#session.searches[rc.nSearchID].Hotel_Long#,"http://localhost:8888/booking/assets/img/center.png"</cfoutput>);
		hotelstructure();
		//filterhotel();
		//stohotel();
		//toggleDiv('filterpref');
		//toggleDiv('filterchains');
		//toggleDiv('filtername');
	});

	</script>


</cfoutput>