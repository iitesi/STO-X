<!--- <cfdump var="#rc.Traveler[1].getBookingDetail()#" label="rc.Traveler.bookingDetail" abort> --->
<cfoutput>
	<div class="carrow" style="width:946px;margin-bottom:26px;">
		<cfloop array="#rc.Travelers#" item="local.traveler" index="travelerIndex">
			<cfset totalText = "Total" />
			<cfset totalAmount = 0 />
			<cfset displayTotal = true />
			<cfset whichCurrency = "USD" />
			<table width="100%" cellpadding="6" cellspacing="0">
				<tr>
					<td>
						<div class="blue"><strong>#rc.Traveler[travelerIndex].getFirstName()# #rc.Traveler[travelerIndex].getLastName()#</strong></div>
						<div class="blue"><strong>Reservation Code: ABVDE4</strong></div>
						<div style="height:24px;"></div>
						<div><strong>Department:</strong> IT Department</strong></div>
						<div><strong>Cost Center:</strong> 6548787</strong></div>
						<div><strong>Job Code:</strong> 1243434</strong></div>
					</td>
					<td valign="top">
						<table width="100%">
							<tr><td colspan="6">&nbsp;</td></tr>
							<tr>
								<th align="left">&nbsp;</th>
								<th align="left">CARD USED</th>
								<th align="left">CHARGE DATE</th>
								<th align="right">BASE RATE</th>
								<th align="right">TAXES</th>
								<th align="right">TOTAL</th>
							</tr>
							<!--- If flight --->
							<cfif rc.Traveler[travelerIndex].getBookingDetail().getAirNeeded()>
								<cfset airCurrency = "USD" />
								<cfset airBase = rc.Air.Base />
								<cfset airTaxes = rc.Air.Taxes />
								<cfset airTotal = rc.Air.Total />
								<tr>
									<td>Flight</td>
									<td>VI... 1111</td>
									<td>#dateFormat(Now(), 'mmmm dd, yyyy')#</td>
									<td align="right">#(airCurrency EQ 'USD' ? DollarFormat(airBase) : airBase&' '&airCurrency)#</td>
									<td align="right">#(airCurrency EQ 'USD' ? DollarFormat(airTaxes) : airTaxes&' '&airCurrency)#</td>
									<td align="right">#(airCurrency EQ 'USD' ? DollarFormat(airTotal) : airTotal&' '&airCurrency)#</td>
									<cfset totalAmount = totalAmount + rc.Air.Total />
								</tr>
								<cfset whichCurrency = airCurrency />
							</cfif>
							<!--- If hotel --->
							<cfif rc.Traveler[travelerIndex].getBookingDetail().getHotelNeeded()>
								<cfif rc.Hotel.getRooms()[1].getTotalForStay() GT 0>
									<cfset hotelCurrency = rc.Hotel.getRooms()[1].getTotalForStayCurrency() />
									<cfset hotelBase = "" />
									<!--- TO DO: Fix the getTaxes() function below --->
									<cfset hotelTaxes = "INCLUDING TAXES" />
									<cfset hotelTotal = rc.Hotel.getRooms()[1].getTotalForStay() />
								<cfelse>
									<cfset hotelCurrency = rc.Hotel.getRooms()[1].getBaseRateCurrency() />
									<cfset hotelBase = rc.Hotel.getRooms()[1].getBaseRate() />
									<cfset hotelTaxes = "QUOTED AT CHECK-IN" />
									<cfset hotelTotal = rc.Hotel.getRooms()[1].getBaseRate() />
									<cfset totalText = "Estimated Total" />
								</cfif>
								<tr>
									<td>Hotel</td>
									<td>VI... 1111</td>
									<td>AT CHECK-OUT</td>
									<td align="right">
										<cfif len(hotelBase)>
											#(hotelCurrency EQ 'USD' ? DollarFormat(hotelBase) : hotelBase&' '&hotelCurrency)#
										</cfif>
									</td>
									<td align="right">#hotelTaxes#</td>
									<td align="right">#(hotelCurrency EQ 'USD' ? DollarFormat(hotelTotal) : hotelTotal&' '&hotelCurrency)#</td>
									<cfset totalAmount = totalAmount + hotelTotal />
								</tr>
								<cfif rc.airSelected AND (hotelCurrency NEQ airCurrency)>
									<cfset displayTotal = false />
								<cfelse>
									<cfset whichCurrency = hotelCurrency />
								</cfif>
							</cfif>
							<!--- If car --->
							<cfif rc.Traveler[travelerIndex].getBookingDetail().getCarNeeded()>
								<cfset vehicleCurrency = rc.Vehicle.getCurrency() />
								<cfset vehicleBase = rc.Vehicle.getEstimatedTotalAmount() />
								<tr>
									<td>Car</td>
									<td>VI... 1111</td>
									<td>AT DROP-OFF</td>
									<td align="right">#(vehicleCurrency EQ 'USD' ? DollarFormat(vehicleBase) : vehicleBase&' '&vehicleCurrency)#</td>
									<td align="right">QUOTED AT PICK-UP</td>
									<cfset totalText = "Estimated Total" />
									<td align="right">#(vehicleCurrency EQ 'USD' ? DollarFormat(vehicleBase) : vehicleBase&' '&vehicleCurrency)#</td>
									<cfset totalAmount = totalAmount + vehicleBase />
								</tr>
								<cfif (rc.airSelected AND (vehicleCurrency NEQ airCurrency)) OR (rc.hotelSelected AND (vehicleCurrency NEQ hotelCurrency))>
									<cfset displayTotal = false />
								<cfelse>
									<cfset whichCurrency = vehicleCurrency />
								</cfif>
							</cfif>
							<!--- If booking fee --->
							<cfif rc.Traveler[travelerIndex].getBookingDetail().getBookingFee() NEQ 0>
								<tr>
									<td>Booking Fee</td>
									<td>VI... 1111</td>
									<td>#dateFormat(Now(), 'mmmm dd, yyyy')#</td>
									<td align="right">#dollarFormat(rc.Traveler[travelerIndex].getBookingDetail().getBookingFee())#</td>
									<td align="right">&nbsp;</td>
									<td align="right">#dollarFormat(rc.Traveler[travelerIndex].getBookingDetail().getBookingFee())#</td>
									<cfset totalAmount = totalAmount + rc.Traveler[travelerIndex].getBookingDetail().getBookingFee() />
								</tr>
							</cfif>
							<!--- Estimated total --->
							<tr>
								<td colspan="4">&nbsp;</td>
								<td align="right"><span class="blue"><strong>#totalText#</strong></span></td>
								<td align="right">
									<cfif displayTotal>
										<span class="blue"><strong>#(whichCurrency EQ 'USD' ? DollarFormat(totalAmount) : totalAmount&' '&whichCurrency)#</strong></span>
									</cfif>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<hr />
		</cfloop>
	</div>
</cfoutput>
<!--- <cfdump var="#rc.Traveler#" label="rc.Traveler"> --->