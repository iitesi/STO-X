<cfsetting showdebugoutput="false" />
We're on the hotel page

<!---
<cfoutput>
	#View('hotel/filter')#
</cfoutput>
--->
<!---<cfdump eval=session.searches[rc.Search_ID].stHotelProperties>--->

<br clear="both">
<cfoutput>
	<div id="aircontent">
		<cfset tripcount = 0 />
		<cfloop array="#session.searches[rc.Search_ID].stSortHotels#" index="sHotel">
			<cfset stHotel = session.searches[rc.Search_ID].stHotelProperties[sHotel]>
			<cfset tripcount++ />

			<cfset HotelAddress = '' />
			<cfif stHotel.RoomsReturned><!--- We have the real address --->
				<cfset HotelAddress = stHotel['Property']['Address1'] />
				<cfset HotelAddress&= Len(Trim(stHotel['Property']['Address2'])) ? ', '&stHotel['Property']['Address2'] : '' />		
			</cfif>
			
			<div id="#sHotel#" style="min-height:100px;">
				<table width="600px">
				<tr>
					<td>
						<table width="100px">
						<tr>
							<td>Image Placeholder</td>
						</tr>
						</table>
					</td>
					<td>
						<table width="400px">
						<tr>
							<td>#tripcount# - #stHotel.HotelChain# #stHotel.Name#<font color="##FFFFFF"> #sHotel#</font></td>
						</tr>
						<tr>
							<td><div id="address#sHotel#">#HotelAddress#</div></td>
						</tr>
						<!---
						<tr>
							<td>
								<a title="Details" id="details#sHotel#" class="linkbutton roundleft" onClick="hotelDetails(#sHotel#, 'details');return false;">Details</a>
								<a title="Rooms" id="rates#sHotel#" class="linkbutton" onClick="showRates(#sHotel#);return false;">Rooms</a>
								<a title="Amenities" id="amenities#sHotel#" class="linkbutton" onClick="hotelAmenities(#sHotel#);return false;">Amenities</a>
								<a title="Photos" id="photos#sHotel#" class="linkbutton" onClick="hotelPhotos(#sHotel#, '#Photos#');return false;">Photos</a>
								<a title="Area" id="area#sHotel#" class="linkbutton roundright" onClick="hotelDetails(#sHotel#, 'area');return false;">Area</a>
							</td>
						</tr>
						--->
					</div>
						<!---
						<img class="carrierimg" src="https://www.shortstravelonline.com/book/assets/img/airlines/#(ListLen(sHotel.Carriers) EQ 1 ? sHotel.Carriers : 'Mult')#.png">
						#(ListLen(sHotel.Carriers) EQ 1 ? '<br>'&application.stAirVendors[sHotel.Carriers].Name : '')#
						--->
						</table>
					</td>
					<td class="fares" align="right">

						<cfif NOT stHotel.RoomsReturned>
							<script type="text/javascript">
							hotelPrice(#rc.Search_ID#, #sHotel#, '#stHotel.HotelChain#');
							</script>
							<div id="checkrates#sHotel#">
								<img src="assets/img/ajax-loader.gif">
								<cfoutput>
									<a href="http://localhost:8888/booking/services/hotelprice.cfc?method=doHotelPrice&nSearchID=#rc.Search_ID#&nHotelCode=#sHotel#&sHotelChain=#stHotel.HotelChain#" target="_blank">
										http://localhost:8888/booking/services/hotelprice.cfc?method=doHotelPrice&nSearchID=#rc.Search_ID#&nHotelCode=#sHotel#&sHotelChain=#stHotel.HotelChain#
									</a><br>
								</cfoutput>
							</div>
						<cfelse>
							#StructKeyExists(stHotel,'LowFare') ? DollarFormat(stHotel.LowFare) : 'Rates not found'#
						</cfif>

					</td>
				</tr>

				</table>
			</div>

		</cfloop>
	</div>

</cfoutput>