<cfif NOT StructKeyExists(application, 'hotelphotos')>
	<cfset application.hotelphotos = CreateObject('component','booking.services.hotelphotos') />
</cfif>
<cfset application.hotelphotos = CreateObject('component','booking.services.hotelphotos') />

<cfsetting showdebugoutput="false" />
We're on the hotel page Preferred Hotels = <cfoutput>#ArrayToList(application.stAccounts[session.Acct_ID].aPreferredHotel)#</cfoutput>
<br /><br />

<!---
<cfoutput>
	#View('hotel/filter')#
</cfoutput>
--->
<!---<cfdump eval=session.searches[rc.Search_ID].stHotelProperties>--->

<br clear="both">
<cfoutput>
	<div class="hotel" heigth="100%">
		<cfset tripcount = 0 />
		<cfset stSortHotels = session.searches[rc.Search_ID].stSortHotels />
		
		<cfset stPhotos = application.hotelphotos.getPhotos(stSortHotels) />

		<cfloop array="#stSortHotels#" index="sHotel">
			<cfset stHotel = session.searches[rc.Search_ID].stHotels[sHotel]>

			<!--- <cfinvoke component="services.hotelrooms" method="rooms" nSearchID="178663" nHotelCode="34911" returnvariable="rooms" />
			<cfdump var="#rooms#"> --->
			<!--- <cfdump eval=stHotel> --->
			<cfset tripcount++ />

			<cfif tripcount LT 500>

				<cfset HotelAddress = '' />
				<cfif stHotel.RoomsReturned><!--- We have the real address --->
					<cfset HotelAddress = stHotel['Property']['Address1'] />
					<cfset HotelAddress&= Len(Trim(stHotel['Property']['Address2'])) ? ', '&stHotel['Property']['Address2'] : '' />		
				</cfif>
				<cfset NegotiatedRateCode = stHotel['NegotiatedRateCode'] />
				
				<div id="#sHotel#" style="min-height:100px;">
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
							<!--- <tr>
								<td>
									<a title="Details" id="details#sHotel#" class="linkbutton roundleft" onClick="hotelDetails(#sHotel#, 'details');return false;">Details</a>
									<a title="Rooms" id="rates#sHotel#" class="linkbutton" onClick="showRates(#sHotel#);return false;">Rooms</a>
									<a title="Amenities" id="amenities#sHotel#" class="linkbutton" onClick="hotelAmenities(#sHotel#);return false;">Amenities</a>
									<cfif structKeyExists(stPhotos,sHotel)>
										<a title="Photos" id="photos#sHotel#" class="linkbutton" onClick="hotelPhotos(#sHotel#, '#stPhotos[sHotel]#');return false;">Photos</a>
									</cfif>
									<a title="Area" id="area#sHotel#" class="linkbutton roundright" onClick="hotelDetails(#sHotel#, 'area');return false;">Area</a>
								</td>
							</tr> --->
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
									<img src="assets/img/ajax-loader.gif" />
								</div>
							<cfelse>

								<!--- #stHotel.Policy#<br />
								#ArrayToList(stHotel.APolicies)#<br />
								#stHotel.PreferredVendor#<br /> --->
								#StructKeyExists(stHotel,'LowRate') ? stHotel.LowRate NEQ 'Sold Out' ? DollarFormat(stHotel.LowRate) : stHotel.LowRate : 'Rates not found'#
								<input type="submit"onClick="showRates(#rc.Search_ID#,#sHotel#);return false;" class="button#stHotel.Policy#policy" name="trigger" value="See Rooms">
								
								<!---
								<script type="text/javascript">
								showRates(#rc.Search_ID#,#sHotel#);
								</script>
								<div id="hotelrooms#sHotel#">hello</div>
								--->

							</cfif>	

							<!--- <cfinvoke component="services.hotelrooms" method="getRooms" nSearchID="#rc.nSearchID#" nHotelCode="#sHotel#" returnvariable="HotelRooms" />
							<cfdump var="#deSerializeJSON(HotelRooms)#"> --->
				

							<cfoutput>
								<a href="http://localhost:8888/booking/services/hotelprice.cfc?method=doHotelPrice&nSearchID=#rc.Search_ID#&nHotelCode=#sHotel#&sHotelChain=#stHotel.HotelChain#" target="_blank">Link</a><br>
							</cfoutput>

						</td>
					</tr>

					</table>
				</div>
			</cfif>
		</cfloop>
	</div>

</cfoutput>