<!--- <cfset application.hotelphotos = CreateObject('component','booking.services.hotelphotos') /> --->

<cfsetting showdebugoutput="false" />

<!--- <cfoutput>
	#View('hotel/filter')#
</cfoutput> --->

<br clear="both">
<cfoutput>
	<div class="hotel" heigth="100%">
		<cfset tripcount = 0 />
		<cfset stSortHotels = session.searches[rc.Search_ID].stSortHotels />
		<cfset stHotelChains = session.searches[rc.nSearchID].stHotelChains />
		
		<cfset stPhotos = application.hotelphotos.getMainPhoto(stSortHotels) />

		<cfloop array="#stSortHotels#" index="sHotel">
			<cfset stHotel = session.searches[rc.Search_ID].stHotels[sHotel]>
			<!--- <cfdump eval=stHotel abort> --->
			<cfset tripcount++ />

			<cfif tripcount LT 10>

				<cfset HotelAddress = '' /><!--- Set a default address, the original ddress returned is garbage --->
				<cfif stHotel.RoomsReturned><!--- We have the real address --->
					<cfset HotelAddress = stHotel['Property']['Address1'] />
					<cfset HotelAddress&= Len(Trim(stHotel['Property']['Address2'])) ? ', '&stHotel['Property']['Address2'] : '' />		
				</cfif>
				<cfset NegotiatedRateCode = stHotel['NegotiatedRateCode'] />
				
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
								<img width="125px" src="#StructKeyExists(stPhotos,sHotel) ? stPhotos[sHotel] : 'assets/img/MissingHotel.png'#" />
							</div>
						</td>
						<td valign="top">
							<table width="400px">
							<tr>
								<td>#tripcount# - #stHotel.HotelChain# #stHotel.Name#<font color="##FFFFFF"> #sHotel#</font> #NegotiatedRateCode#</td>
							</tr>
							<tr>
								<td><div id="address#sHotel#">#HotelAddress#</div></td>
							</tr>
							<tr>
								<td>
									<a title="Details" id="details#sHotel#" class="linkbutton roundleft" onClick="hotelDetails(#sHotel#, 'details');return false;">Details</a>
									<a title="Rooms" id="rates#sHotel#" class="linkbutton" onClick="showRates(#sHotel#);return false;">Rooms</a>
									<a title="Amenities" id="amenities#sHotel#" class="linkbutton" onClick="hotelAmenities(#sHotel#);return false;">Amenities</a>									
									<a title="Photos" id="photos#sHotel#" class="linkbutton" onClick="hotelPhotos(#sHotel#, '#stPhotos[sHotel]#');return false;">Photos</a>									
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
								
								<!---
								<script type="text/javascript">
								showRates(#rc.Search_ID#,#sHotel#);
								</script>
								--->

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

</cfoutput>