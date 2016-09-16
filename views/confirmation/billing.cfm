<cfoutput>
	<div class="carrow" style="width:946px;padding:0px;margin-bottom:26px;">
		<cfloop array="#rc.Travelers#" item="local.traveler" index="travelerIndex">
			<cfset pricelineHotelBooked = false />
			<cfset pricelineSeparateFees = false />
			<cfif structKeyExists(rc, "hotelCancelled") AND rc.hotelCancelled>
				<cfset rc.Traveler[travelerIndex].getBookingDetail().setHotelNeeded(false) />
			</cfif>
			<cfif rc.Traveler[travelerIndex].getBookingDetail().getHotelNeeded() AND rc.Hotel.getRooms()[1].getAPISource() EQ "Priceline">
				<cfset pricelineHotelBooked = true />
				<cfif (len(rc.Hotel.getRooms()[1].getProcessingFee()) AND rc.Hotel.getRooms()[1].getProcessingFee() NEQ "0.00") OR (len(rc.Hotel.getRooms()[1].getInsuranceFee()) AND rc.Hotel.getRooms()[1].getInsuranceFee() NEQ "0.00") OR (len(rc.Hotel.getRooms()[1].getPropertyFee()) AND rc.Hotel.getRooms()[1].getPropertyFee() NEQ "0.00")>
					<cfset pricelineSeparateFees = true />
				</cfif>
			</cfif>
			<cfset totalText = "Total" />
			<cfset totalAmount = 0 />
			<cfset displayTotal = true />
			<cfset whichCurrency = "USD" />
			<table width="100%" cellpadding="6" cellspacing="0">
				<tr>
					<td valign="top" width="30%">
						<div class="blue"><strong>#uCase(rc.Traveler[travelerIndex].getFirstName())# #uCase(rc.Traveler[travelerIndex].getLastName())#</strong></div>
						<div class="blue"><strong>Reservation Code: #rc.Traveler[travelerIndex].getBookingDetail().getReservationCode()#</strong></div>
					</td>
					<td valign="top">
						<cfloop array="#rc.Traveler[travelerIndex].getOrgUnit()#" index="orgUnitIndex" item="orgUnit">
							<cfif orgUnit.getOUDisplay() EQ 1>
								<div><strong>#orgUnit.getOUName()#:</strong> #orgUnit.getValueDisplay()#</strong></div>
							</cfif>
						</cfloop>
					</td>
				</tr>
				<tr>
					<td valign="top" colspan="2">
						<table width="100%">
							<tr><td colspan="<cfif pricelineSeparateFees>8<cfelseif pricelineHotelBooked>7<cfelse>6</cfif>">&nbsp;</td></tr>
							<tr>
								<th valign="top" align="left" width="80">&nbsp;</th>
								<th valign="top" align="left" width="100">CARD USED</th>
								<th valign="top" align="left" width="60">CHARGE DATE</th>
								<th valign="top" align="right" width="70">
									BASE RATE
									<cfif pricelineHotelBooked>
										<br />(AVG PER NIGHT)
									</cfif>
								</th>
								<cfif pricelineHotelBooked>
									<cfset nights = dateDiff('d', rc.Filter.getCheckInDate(), rc.Filter.getCheckOutDate()) />
									<th valign="top" align="right" width="70">ROOM SUBTOTAL<br />FOR #nights# NIGHT(S)</th>
								</cfif>
								<th valign="top" align="right" width="60">TAXES</th>
								<cfif pricelineSeparateFees>
									<th valign="top" align="right" width="60">FEES</th>
								</cfif>
								<th valign="top" align="right" width="60">TOTAL</th>
							</tr>
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
								<tr>
									<td valign="top">Flight</td>
									<td valign="top">
										<cfif airCardNumber NEQ ''>
											#airCardType#... #right(airCardNumber, 4)#
										<cfelse>
											CBA
										</cfif></td>
									<td valign="top">#dateFormat(Now(), 'mmm d, yyyy')#</td>
									<!--- Per STM-2595, changed "Base" to "ApproximateBase" since Base can be in any currency and ApproximateBase is always in USD. --->
									<td valign="top" align="right">#(airCurrency EQ 'USD' ? DollarFormat(airApproximateBase) : numberFormat(airApproximateBase, '____.__')&' '&airCurrency)#</td>
									<!--- <td align="right">#(airCurrency EQ 'USD' ? DollarFormat(airBase) : airBase&' '&airCurrency)#</td> --->
									<cfif pricelineHotelBooked>
										<td valign="top" align="right">&nbsp;</td>
									</cfif>
									<td valign="top" align="right">#(airCurrency EQ 'USD' ? DollarFormat(airTaxes) : numberFormat(airTaxes, '____.__')&' '&airCurrency)#</td>
									<cfif pricelineSeparateFees>
										<td valign="top" align="right">&nbsp;</td>
									</cfif>
									<td valign="top" align="right">#(airCurrency EQ 'USD' ? DollarFormat(airTotal) : numberFormat(airTotal, '____.__')&' '&airCurrency)#</td>
									<cfset totalAmount = totalAmount + airTotal />
								</tr>
								<cfset whichCurrency = airCurrency />
							</cfif>
							<!--- If hotel --->
							<cfif rc.Traveler[travelerIndex].getBookingDetail().getHotelNeeded()>
								<!--- <cfdump var="#rc.Hotel.getRooms()[1]#"> --->
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
								<tr>
									<td valign="top">Hotel</td>
									<td valign="top"><cfif rc.Hotel.getRooms()[1].getAPISource() EQ "Priceline" AND len(rc.Traveler[travelerIndex].getBookingDetail().getHotelBillingName())>#rc.Traveler[travelerIndex].getBookingDetail().getHotelBillingName()# <cfelseif rc.Hotel.getRooms()[1].getAPISource() EQ "Priceline" AND len(rc.Traveler[travelerIndex].getBookingDetail().getHotelCCName())>#rc.Traveler[travelerIndex].getBookingDetail().getHotelCCName()# </cfif>#hotelCardType#... #right(hotelCardNumber, 4)#</td>
									<td valign="top">
										<cfif rc.Hotel.getRooms()[1].getDepositRequired()>
											#dateFormat(Now(), 'mmm d, yyyy')#
										<cfelse>
											AT CHECK-OUT
										</cfif>
									</td>
									<td valign="top" align="right">
										<cfif pricelineHotelBooked>
											<cfset dailyRateCurrency = rc.Hotel.getRooms()[1].getDailyRateCurrency()>
											<cfset hotelDailyRate = rc.Hotel.getRooms()[1].getDailyRate()>
											#(dailyRateCurrency EQ 'USD' ? DollarFormat(hotelDailyRate) : numberFormat(hotelDailyRate, '____.__')&' '&dailyRateCurrency)#
											<cfif len(rc.Hotel.getRooms()[1].getPromo())>
												<div class="blue bold">
													#rc.Hotel.getRooms()[1].getPromo()#
												</div>
											</cfif>
										<cfelseif len(hotelBase)>
											#(hotelCurrency EQ 'USD' ? DollarFormat(hotelBase) : numberFormat(hotelBase, '____.__')&' '&hotelCurrency)#
										</cfif>
									</td>
									<cfif pricelineHotelBooked>
										<cfset pricelineTotal = hotelDailyRate*nights />
										<td valign="top" align="right">
											#(dailyRateCurrency EQ 'USD' ? DollarFormat(pricelineTotal) : numberFormat(pricelineTotal, '____.__')&' '&dailyRateCurrency)#
										</td>
									</cfif>
									<cfif pricelineHotelBooked>
										<td valign="top" align="right">#(rc.Hotel.getRooms()[1].getTaxCurrency() EQ 'USD' ? DollarFormat(rc.Hotel.getRooms()[1].getTax()) : numberFormat(rc.Hotel.getRooms()[1].getTax(), '____.__')&' '&rc.Hotel.getRooms()[1].getTaxCurrency())#<br />
											<cfset hotelText = '<a rel="popover" href="javascript:$(''##displayTaxesAndFees'').modal(''show'');" />Taxes and fees</a>'>
											<cfif rc.Hotel.getRooms()[1].getRatePlanType() NEQ "MER">
												<cfset hotelText = hotelText & '<br /><span style="font-size:8px;">may apply</span>'>
											</cfif>
											#hotelText#
										</td>
										<cfif pricelineSeparateFees>
											<cfset hotelFees = rc.Hotel.getRooms()[1].getProcessingFee() + rc.Hotel.getRooms()[1].getInsuranceFee() + rc.Hotel.getRooms()[1].getPropertyFee() />
											<td valign="top" align="right">
												#(rc.Hotel.getRooms()[1].getTaxCurrency() EQ 'USD' ? DollarFormat(hotelFees) : numberFormat(hotelFees, '____.__')&' '&rc.Hotel.getRooms()[1].getTaxCurrency())#
											</td>
										</cfif>
									<cfelse>
										<td valign="top" align="right">#hotelTaxes#</td>
									</cfif>
									<td valign="top" align="right">#(hotelCurrency EQ 'USD' ? DollarFormat(hotelTotal) : numberFormat(hotelTotal, '____.__')&' '&hotelCurrency)#</td>
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
									<td valign="top">Car</td>
									<td valign="top">PRESENT AT PICK-UP</td>
									<td valign="top">AT DROP-OFF</td>
									<td valign="top" align="right">
										#(vehicleCurrency EQ 'USD' ? DollarFormat(vehicleBase) : numberFormat(vehicleBase, '____.__')&' '&vehicleCurrency)#
										<cfset vehicleTotal = vehicleBase />
										<cfif NOT vehicleDropOffChargesIncluded AND vehicleDropOffCharge NEQ 0>
											&nbsp;(+ #(vehicleCurrency EQ 'USD' ? DollarFormat(vehicleDropOffCharge) : numberFormat(vehicleDropOffCharge, '____.__')&' '&vehicleCurrency)# drop-off charge)
											<cfset vehicleTotal = vehicleTotal + vehicleDropOffCharge />
										</cfif>
									</td>
									<cfif pricelineHotelBooked>
										<td valign="top" align="right">&nbsp;</td>
									</cfif>
									<td valign="top" align="right">QUOTED AT PICK-UP</td>
									<cfif pricelineSeparateFees>
										<td valign="top" align="right">&nbsp;</td>
									</cfif>
									<cfset totalText = "Estimated Total" />
									<td valign="top" align="right">#(vehicleCurrency EQ 'USD' ? DollarFormat(vehicleTotal) : numberFormat(vehicleTotal, '____.__')&' '&vehicleCurrency)#</td>
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
									<td valign="top">Booking Fee</td>
									<td valign="top">
										<cfif rc.Traveler[travelerIndex].getBookingDetail().getAirNeeded()>
											<cfif airCardNumber NEQ ''>
												#airCardType#... #right(airCardNumber, 4)#
											<cfelse>
												CBA
											</cfif>
										<cfelseif rc.Traveler[travelerIndex].getBookingDetail().getHotelNeeded()>
											#hotelCardType#... #right(hotelCardNumber, 4)#
										</cfif>
									</td>
									<td valign="top">#dateFormat(Now(), 'mmm d, yyyy')#</td>
									<td valign="top" align="right">#dollarFormat(rc.Traveler[travelerIndex].getBookingDetail().getBookingFee())#</td>
									<cfif pricelineHotelBooked>
										<td valign="top" align="right">&nbsp;</td>
									</cfif>
									<td valign="top" align="right">&nbsp;</td>
									<cfif pricelineSeparateFees>
										<td valign="top" align="right">&nbsp;</td>
									</cfif>
									<td valign="top" align="right">#dollarFormat(rc.Traveler[travelerIndex].getBookingDetail().getBookingFee())#</td>
									<cfset totalAmount = totalAmount + rc.Traveler[travelerIndex].getBookingDetail().getBookingFee() />
								</tr>
							</cfif>
							<!--- Estimated total --->
							<tr>
								<td valign="top" colspan="<cfif pricelineSeparateFees>6<cfelseif pricelineHotelBooked>5<cfelse>4</cfif>">&nbsp;</td>
								<td valign="top" align="right"><span class="blue"><strong>#totalText#</strong></span></td>
								<td valign="top" align="right">
									<cfif displayTotal>
										<span class="blue"><strong>#(whichCurrency EQ 'USD' ? DollarFormat(totalAmount) : numberFormat(totalAmount, '____.__')&' '&whichCurrency)#</strong></span>
									</cfif>
								</td>
							</tr>
							<cfif unusedTicketSelected>
								<tr>
									<td valign="top" colspan="<cfif pricelineSeparateFees>8<cfelseif pricelineHotelBooked>7<cfelse>6</cfif>" align="right">
										<cfif displayTotal>
											<span class="blue"><strong>before unused ticket credit</strong></span>
										</cfif>
									</td>
								</tr>
							</cfif>
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
<div id="displayTaxesAndFees" class="modal searchForm hide fade" style="width:650px !important" tabindex="-1" role="dialog" aria-labelledby="displayPricelineTermsAndConditions" aria-hidden="true">
	<div class="searchContainer">
		<div class="modal-header popover-content">
			<button type="button" class="close" data-dismiss="modal"><i class="icon-remove"></i></button>
			<h3 id="addModalHeader">
			Taxes and Fees
			</h3>
		</div>
		<div class="modal-body popover-content">
			<div id="addModalBody">
				<h3>Charges for Taxes and Fees</h3>
				<p>
					In connection with facilitating your hotel transaction, the charge to your debit or credit card will include a charge for Taxes and Fees. This charge includes an estimated amount to recover the amount we pay to the hotel in connection with your reservation for taxes owed by the hotel including, without limitation, sales and use tax, occupancy tax, room tax, excise tax, value added tax and/or other similar taxes.  In certain locations, the tax amount may also include government imposed service fees or other fees not paid directly to the taxing authorities but required by law to be collected by the hotel. The amount paid to the hotel in connection with your reservation for taxes may vary from the amount we estimate and include in the charge to you. The balance of the charge for Taxes and Fees is a fee we retain as part of the compensation for our services and to cover the costs of your reservation, including, for example, customer service costs. The charge for Taxes and Fees varies based on a number of factors including, without limitation, the amount we pay the hotel and the location of the hotel where you will be staying, and may include profit that we retain.
				</p>
				<p>
					Except as described below, we are not the vendor collecting and remitting taxes to the applicable taxing authorities. Our hotel suppliers, as vendors, include all applicable taxes in the amount billed to us and we pay over such amounts directly to the vendors. We are not a co-vendor associated with the vendor with whom we book or reserve our customer's travel arrangements. Taxability and the appropriate tax rate and the type of applicable taxes vary greatly by location.
				</p>
				<p>
					For transactions involving hotels located within certain jurisdictions, the charge to your debit or credit card for Taxes and Fees includes a payment of tax that we are required to collect and remit to the jurisdiction for tax owed on amounts we retain as compensation for our services.
				</p>
				<p>
					Please note that we are unable to facilitate a rebate of Canadian Goods and Services Tax ("GST") for customers booking Canadian hotel accommodations utilizing our services.
				</p>
			</div>
		</div>
	</div>
</div>
<!--- <cfdump var="#rc.Traveler#" label="rc.Traveler"> --->