<cfoutput>
	<div class="summarydiv container-fluid padded">
		<cfloop array="#rc.Travelers#" item="local.traveler" index="travelerIndex">
			<cfset totalText = "Total" />
			<cfset totalAmount = 0 />
			<cfset displayTotal = true />
			<cfset whichCurrency = "USD" />
			<div>
				<div class="row">

						<div class="blue col-sm-4"><strong>Name: #uCase(rc.Traveler[travelerIndex].getFirstName())# #uCase(rc.Traveler[travelerIndex].getLastName())#</strong></div>
						<div class="blue col-sm-4"><strong>Reservation Code: #rc.Traveler[travelerIndex].getBookingDetail().getReservationCode()#</strong></div>
						<div class="col-sm-4">

						<cfloop array="#rc.Traveler[travelerIndex].getOrgUnit()#" index="orgUnitIndex" item="orgUnit">
							<cfif orgUnit.getOUDisplay() EQ 1>
								<div><strong>#orgUnit.getOUName()#:</strong> #orgUnit.getValueDisplay()#</strong></div>
							</cfif>
						</cfloop>
					</div>
					</div>
<hr>
					<div class="row hidden-xs">
						<div class="col-sm-offset-2 col-sm-2"><strong>Payment</strong></div>
						<div class="col-sm-2"><strong>Charge Date</strong></div>
						<div class="col-sm-2"><strong>Base Rate</strong></div>
						<div class="col-sm-2"><strong>Taxes</strong></div>
						<div class="col-sm-2"><strong>Total</strong></div>
					</div>


							<!--- If flight --->
							<cfif rc.Traveler[travelerIndex].getBookingDetail().getAirNeeded()>
								<cfset airCardNumber = rc.Traveler[travelerIndex].getBookingDetail().getAirCCNumber() />
								<cfset airCardType = "" />
								<cfif len(rc.Traveler[travelerIndex].getBookingDetail().getAirCCType())>
									<cfset airCardType = rc.Traveler[travelerIndex].getBookingDetail().getAirCCType() />
									<cfif airCardType IS "CA">
										<cfset airCardType = "MC" />
									</cfif>
								</cfif>
								<cfset airCurrency = left(rc.Air.PricingSolution.getPricingInfo()[1].getTotalPrice(), 3) />
								<cfset airBase = replace(rc.Air.PricingSolution.getPricingInfo()[1].getBasePrice(), airCurrency, '') />
								<cfset airApproximateBase = replace(rc.Air.PricingSolution.getPricingInfo()[1].getApproximateBasePrice(), airCurrency, '') />
								<cfset airTaxes = replace(rc.Air.PricingSolution.getPricingInfo()[1].getTaxes(), airCurrency, '') />
								<cfset airTotal = replace(rc.Air.PricingSolution.getPricingInfo()[1].getTotalPrice(), airCurrency, '') />
								<div class="row">
									<div class="col-sm-2"><strong>Flight</strong></div>
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Payment: </strong></span>
										<cfif airCardNumber NEQ ''>
											#airCardType#... #right(airCardNumber, 4)#
										<cfelse>
											CBA
										</cfif></div>
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Charge Date: </strong></span>#dateFormat(Now(), 'mmm d, yyyy')#</div>
									<!--- Per STM-2595, changed "Base" to "ApproximateBase" since Base can be in any currency and ApproximateBase is always in USD. --->
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Base Rate: </strong></span> #(airCurrency EQ 'USD' ? DollarFormat(airApproximateBase) : numberFormat(airApproximateBase, '____.__')&' '&airCurrency)#</div>
									<!--- <td align="right">#(airCurrency EQ 'USD' ? DollarFormat(airBase) : airBase&' '&airCurrency)#</td> --->
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Taxes: </strong></span> #(airCurrency EQ 'USD' ? DollarFormat(airTaxes) : numberFormat(airTaxes, '____.__')&' '&airCurrency)#</div>
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Flight Total: </strong></span>#(airCurrency EQ 'USD' ? DollarFormat(airTotal) : numberFormat(airTotal, '____.__')&' '&airCurrency)#</div>
									<cfset totalAmount = totalAmount + airTotal />
								</div>
								<hr class="visible-xs">
								<cfset whichCurrency = airCurrency />
							</cfif>
							<!--- If hotel --->
							<cfif rc.Traveler[travelerIndex].getBookingDetail().getHotelNeeded()>
								<cfset hotelCardNumber = rc.Traveler[travelerIndex].getBookingDetail().getHotelCCNumber() />
								<cfset hotelCardType = "" />
								<cfif len(rc.Traveler[travelerIndex].getBookingDetail().getHotelCCType())>
									<cfset hotelCardType = rc.Traveler[travelerIndex].getBookingDetail().getHotelCCType() />
									<cfif hotelCardType IS "CA">
										<cfset hotelCardType = "MC" />
									</cfif>
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
									<cfset nights = dateDiff('d', rc.Filter.getCheckInDate(), rc.Filter.getCheckOutDate()) />
									<cfset hotelCurrency = rc.Hotel.getRooms()[1].getDailyRateCurrency() />
									<cfset hotelBase = rc.Hotel.getRooms()[1].getDailyRate()*nights />
									<cfset hotelTaxes = "QUOTED AT CHECK-IN" />
									<cfset hotelTotal = rc.Hotel.getRooms()[1].getDailyRate()*nights />
									<cfset totalText = "Estimated Total" />
								</cfif>
								<div class="row">
									<div class="col-sm-2"><strong>Hotel</strong></div>
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Payment: </strong></span>#hotelCardType#... #right(hotelCardNumber, 4)#</div>
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Charge Date: </strong></span>At check-out</div>
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Base Rate: </strong></span>
										<cfif len(hotelBase)>
											#(hotelCurrency EQ 'USD' ? DollarFormat(hotelBase) : numberFormat(hotelBase, '____.__')&' '&hotelCurrency)#
										</cfif>
									</div>
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Taxes: </strong></span>#hotelTaxes#</div>
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Hotel Total: </strong></span>#(hotelCurrency EQ 'USD' ? DollarFormat(hotelTotal) : numberFormat(hotelTotal, '____.__')&' '&hotelCurrency)#</div>
									<cfset totalAmount = totalAmount + hotelTotal />
								</div>
								<hr class="visible-xs">
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
								<div class="row">
									<div class="col-sm-2"><strong>Car</strong></div>
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Payment: </strong></span>PRESENT AT PICK-UP</div>
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Charge Date: </strong></span> AT DROP-OFF</div>
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Base Rate: </strong></span>
										#(vehicleCurrency EQ 'USD' ? DollarFormat(vehicleBase) : numberFormat(vehicleBase, '____.__')&' '&vehicleCurrency)#
										<cfset vehicleTotal = vehicleBase />
										<cfif NOT vehicleDropOffChargesIncluded AND vehicleDropOffCharge NEQ 0>
											&nbsp;(+ #(vehicleCurrency EQ 'USD' ? DollarFormat(vehicleDropOffCharge) : numberFormat(vehicleDropOffCharge, '____.__')&' '&vehicleCurrency)# drop-off charge)
											<cfset vehicleTotal = vehicleTotal + vehicleDropOffCharge />
										</cfif>
									</div>
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Taxes: </strong></span> QUOTED AT PICK-UP</div>
									<cfset totalText = "Estimated Total" />
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Car Total: </strong></span>#(vehicleCurrency EQ 'USD' ? DollarFormat(vehicleTotal) : numberFormat(vehicleTotal, '____.__')&' '&vehicleCurrency)#</div>
									<cfset totalAmount = totalAmount + vehicleTotal />
								</div>
								<hr class="visible-xs">
								<cfif (rc.airSelected AND (vehicleCurrency NEQ airCurrency)) OR (rc.hotelSelected AND (vehicleCurrency NEQ hotelCurrency))>
									<cfset displayTotal = false />
								<cfelse>
									<cfset whichCurrency = vehicleCurrency />
								</cfif>
							</cfif>
							<!--- If booking fee --->
							<cfif rc.Traveler[travelerIndex].getBookingDetail().getBookingFee() NEQ 0>
								<div class="row">
									<div class="col-sm-2"><strong>Booking Fee<strong></div>
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Payment: </strong></span>
										<cfif rc.Traveler[travelerIndex].getBookingDetail().getAirNeeded()>
											<cfif airCardNumber NEQ ''>
												#airCardType#... #right(airCardNumber, 4)#
											<cfelse>
												CBA
											</cfif>
										<cfelseif rc.Traveler[travelerIndex].getBookingDetail().getHotelNeeded()>
											#hotelCardType#... #right(hotelCardNumber, 4)#
										</cfif>
									</div>
									<div class="col-sm-2"><span class="visible-xs-inline"><strong>Charge Date: </strong></span>#dateFormat(Now(), 'mmm d, yyyy')#</div>

									<div class="col-sm-offset-4 col-sm-2"><span class="visible-xs-inline"><strong>Total Booking Fee: </strong></span>#dollarFormat(rc.Traveler[travelerIndex].getBookingDetail().getBookingFee())#</div>
									<cfset totalAmount = totalAmount + rc.Traveler[travelerIndex].getBookingDetail().getBookingFee() />
								</div>
								<hr class="visible-xs">
							</cfif>
							<!--- Estimated total --->

							<div class="row">

								<div class="col-sm-offset-8 col-sm-2 col-xs-6"><span class="blue"><strong>#totalText#</strong></span></div>
								<div class="col-sm-2 col-xs-6">
									<cfif displayTotal>
										<span class="blue"><strong>#(whichCurrency EQ 'USD' ? DollarFormat(totalAmount) : numberFormat(totalAmount, '____.__')&' '&whichCurrency)#</strong></span>
									</cfif>
								</div>
							</div>
							<cfif unusedTicketSelected>
								<div class="row">
									<div class="text-right col-xs-12">
										<cfif displayTotal>
											<span class="blue"><strong>before unused ticket credit</strong></span>
										</cfif>
									</div>
								</div>
							</cfif>



			</div>
			<cfif travelerIndex NEQ arrayLen(rc.Travelers)>
				<hr />
			</cfif>
		</cfloop>
	</div>
</cfoutput>
<!--- <cfdump var="#rc.Traveler#" label="rc.Traveler"> --->
