<cfoutput>
	<div class="carrow" style="width:946px;padding:0px;margin-bottom:26px;">
		<cfloop array="#rc.Travelers#" item="local.traveler" index="travelerIndex">
			<cfset totalText = "Total" />
			<cfset totalAmount = 0 />
			<cfset displayTotal = true />
			<cfset whichCurrency = "USD" />
			<table width="100%" cellpadding="6" cellspacing="0">
				<tr>
					<td>
						<div class="blue"><strong>#uCase(rc.Traveler[travelerIndex].getFirstName())# #uCase(rc.Traveler[travelerIndex].getLastName())#</strong></div>
						<div class="blue"><strong>Reservation Code: #rc.Traveler[travelerIndex].getBookingDetail().getReservationCode()#</strong></div>
						<div style="height:24px;"></div>

						<cfloop array="#rc.Traveler[travelerIndex].getOrgUnit()#" index="orgUnitIndex" item="orgUnit">
							<div><strong>#orgUnit.getOUName()#:</strong> #orgUnit.getValueDisplay()#</strong></div>
						</cfloop>
					</td>
					<td valign="top">
						<table width="92%">
							<tr><td colspan="6">&nbsp;</td></tr>
							<tr>
								<th align="left" width="40">&nbsp;</th>
								<th align="left" width="100">CARD USED</th>
								<th align="left" width="80">CHARGE DATE</th>
								<th align="right" width="70">BASE RATE</th>
								<th align="right" width="100">TAXES</th>
								<th align="right" width="60">TOTAL</th>
							</tr>
							<!--- If flight --->
							<cfif rc.Traveler[travelerIndex].getBookingDetail().getAirNeeded()>
								<cfset airCardNumber = rc.Traveler[travelerIndex].getBookingDetail().getAirCCNumber() />
								<cfset airCardType = "" />
								<cfif left(airCardNumber, 1) EQ 4>
									<cfset airCardType = "VI" />
								<cfelseif left(airCardNumber, 1) EQ 5>
									<cfset airCardType = "MC" />
								<cfelseif left(airCardNumber, 1) EQ 6>
									<cfset airCardType = "DS" />
								<cfelseif left(airCardNumber, 1) EQ 3>
									<cfset airCardType = "AX" />
								</cfif>
								<cfset airCurrency = left(rc.Air.PricingSolution.getPricingInfo()[1].getTotalPrice(), 3) />
								<cfset airBase = replace(rc.Air.PricingSolution.getPricingInfo()[1].getBasePrice(), airCurrency, '') />
								<cfset airTaxes = replace(rc.Air.PricingSolution.getPricingInfo()[1].getTaxes(), airCurrency, '') />
								<cfset airTotal = replace(rc.Air.PricingSolution.getPricingInfo()[1].getTotalPrice(), airCurrency, '') />
								<tr>
									<td>Flight</td>
									<td>#airCardType#... #right(airCardNumber, 4)#</td>
									<td>#dateFormat(Now(), 'mmmm dd, yyyy')#</td>
									<td align="right">#(airCurrency EQ 'USD' ? DollarFormat(airBase) : airBase&' '&airCurrency)#</td>
									<td align="right">#(airCurrency EQ 'USD' ? DollarFormat(airTaxes) : airTaxes&' '&airCurrency)#</td>
									<td align="right">#(airCurrency EQ 'USD' ? DollarFormat(airTotal) : airTotal&' '&airCurrency)#</td>
									<cfset totalAmount = totalAmount + airTotal />
								</tr>
								<cfset whichCurrency = airCurrency />
							</cfif>
							<!--- If hotel --->
							<cfif rc.Traveler[travelerIndex].getBookingDetail().getHotelNeeded()>
								<cfset hotelCardNumber = rc.Traveler[travelerIndex].getBookingDetail().getHotelCCNumber() />
								<cfset hotelCardType = "" />
								<cfif left(hotelCardNumber, 1) EQ 4>
									<cfset hotelCardType = "VI" />
								<cfelseif left(hotelCardNumber, 1) EQ 5>
									<cfset hotelCardType = "MC" />
								<cfelseif left(hotelCardNumber, 1) EQ 6>
									<cfset hotelCardType = "DS" />
								<cfelseif left(hotelCardNumber, 1) EQ 3>
									<cfset hotelCardType = "AX" />
								</cfif>
								<cfif rc.Hotel.getRooms()[1].getTotalForStay() GT 0>
									<cfset hotelCurrency = rc.Hotel.getRooms()[1].getTotalForStayCurrency() />
									<cfset hotelBase = "" />
									<cfset hotelTaxes = "INCLUDING TAXES" />
									<cfset hotelTotal = rc.Hotel.getRooms()[1].getTotalForStay() />
								<cfelseif rc.Hotel.getRooms()[1].getBaseRate() GT 0>
									<cfset hotelCurrency = rc.Hotel.getRooms()[1].getBaseRateCurrency() />
									<cfset hotelBase = rc.Hotel.getRooms()[1].getBaseRate() />
									<cfset hotelTaxes = "QUOTED AT CHECK-IN" />
									<cfset hotelTotal = rc.Hotel.getRooms()[1].getBaseRate() />
									<cfset totalText = "Estimated Total" />
								<cfelse>
									<cfset hotelCurrency = rc.Hotel.getRooms()[1].getDailyRateCurrency() />
									<cfset hotelBase = rc.Hotel.getRooms()[1].getDailyRate()*nights />
									<cfset hotelTaxes = "QUOTED AT CHECK-IN" />
									<cfset hotelTotal = rc.Hotel.getRooms()[1].getDailyRate()*nights />
									<cfset totalText = "Estimated Total" />
								</cfif>
								<tr>
									<td>Hotel</td>
									<td>#hotelCardType#... #right(hotelCardNumber, 4)#</td>
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
								<cfset vehicleDropOffCharge = rc.Vehicle.getDropOffCharge() />
								<cfset vehicleDropOffChargesIncluded = rc.Vehicle.getDropOffChargesIncluded() />
								<tr>
									<td>Car</td>
									<td>PRESENT AT PICK-UP</td>
									<td>AT DROP-OFF</td>
									<td align="right">
										#(vehicleCurrency EQ 'USD' ? DollarFormat(vehicleBase) : vehicleBase&' '&vehicleCurrency)#
										<cfset vehicleTotal = vehicleBase />
										<cfif NOT vehicleDropOffChargesIncluded AND vehicleDropOffCharge NEQ 0>
											&nbsp;(+ #(vehicleCurrency EQ 'USD' ? DollarFormat(vehicleDropOffCharge) : vehicleDropOffCharge&' '&vehicleCurrency)# drop-off charge)
											<cfset vehicleTotal = vehicleTotal + vehicleDropOffCharge />
										</cfif>
									</td>
									<td align="right">QUOTED AT PICK-UP</td>
									<cfset totalText = "Estimated Total" />
									<td align="right">#(vehicleCurrency EQ 'USD' ? DollarFormat(vehicleTotal) : vehicleTotal&' '&vehicleCurrency)#</td>
									<cfset totalAmount = totalAmount + vehicleTotal />
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
									<td>
										<cfif rc.Traveler[travelerIndex].getBookingDetail().getAirNeeded()>
											#airCardType#... #right(airCardNumber, 4)#
										<cfelseif rc.Traveler[travelerIndex].getBookingDetail().getHotelNeeded()>
											#hotelCardType#... #right(hotelCardNumber, 4)#
										</cfif>
									</td>
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
			<cfif travelerIndex NEQ arrayLen(rc.Travelers)>
				<hr />
			</cfif>
		</cfloop>
	</div>
</cfoutput>
<!--- <cfdump var="#rc.Traveler#" label="rc.Traveler"> --->