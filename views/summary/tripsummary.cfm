<cfoutput>
	<style>
	.minlineheight {
		line-height:10px;
	}
	</style>
	<cfif structKeyExists(rc, "Air")
	    AND isStruct( rc.Air )
	    AND structKeyExists(rc.Air, 'PricingSolution')
		AND isObject(rc.Air.PricingSolution)>
		<cfset rc.Air.Total = replace(rc.Air.PricingSolution.getPricingInfo()[1].getTotalPrice(), 'USD', '')>
		<cfset rc.Air.Base = replace(rc.Air.PricingSolution.getPricingInfo()[1].getBasePrice(), 'USD', '')>
		<cfset rc.Air.ApproximateBase = replace(rc.Air.PricingSolution.getPricingInfo()[1].getApproximateBasePrice(), 'USD', '')>
		<cfset rc.Air.Taxes = replace(rc.Air.PricingSolution.getPricingInfo()[1].getTaxes(), 'USD', '')>
	</cfif>
	<cfif rc.hotelSelected>
		<cfset baseHotelRate = rc.Hotel.getRooms()[1].getDailyRate()>
		<cfif rc.Hotel.getRooms()[1].getTotalForStay() GT 0>
			<cfset nights = dateDiff('d', rc.Filter.getCheckInDate(), rc.Filter.getCheckOutDate())>
			<cfset currency = rc.Hotel.getRooms()[1].getTotalForStayCurrency()>
			<cfset hotelBase = rc.Hotel.getRooms()[1].getDailyRate()*nights />
			<cfset hotelTotal = rc.Hotel.getRooms()[1].getTotalForStay()>
			<cfset hotelText = 'Including taxes'>
				<cfif UCASE(rc.Hotel.getRooms()[1].getAPISource()) EQ "PRICELINE">
					<cfset hotelTaxes = rc.Hotel.getRooms()[1].getTax() />
					<cfset hotelFees = rc.Hotel.getRooms()[1].getProcessingFee() + rc.Hotel.getRooms()[1].getInsuranceFee() />
					<cfset resortFee = rc.Hotel.getRooms()[1].getPropertyFee() />
					<cfset feeText = "" />
					<cfif hotelFees NEQ 0>
						<cfset feeText = '<br />'&(rc.Hotel.getRooms()[1].getTaxCurrency() EQ 'USD' ? numberFormat(hotelFees, '$____.__') : numberFormat(hotelFees, '____.__')&' '&rc.Hotel.getRooms()[1].getTaxCurrency())&' fees' />
					</cfif>
					<cfif resortFee NEQ 0>
						<cfset feeText = feeText&'<br />'&(rc.Hotel.getRooms()[1].getTaxCurrency() EQ 'USD' ? numberFormat(resortFee, '$____.__') : numberFormat(resortFee, '____.__')&' '&rc.Hotel.getRooms()[1].getTaxCurrency())&' resort fee' />
					</cfif>
					<cfset hotelText = (rc.Hotel.getRooms()[1].getTaxCurrency() EQ 'USD' ? numberFormat(hotelTaxes, '$____.__') : numberFormat(hotelTaxes, '____.__')&' '&rc.Hotel.getRooms()[1].getTaxCurrency())&' taxes'&feeText />
					<cfif rc.Hotel.getRooms()[1].getRatePlanType() NEQ 'MER'>
						<cfset hotelText = hotelText & '<br/><span style="font-size:8px;">may apply</span>'>
					</cfif>
				</cfif>
		<cfelseif rc.Hotel.getRooms()[1].getBaseRate() GT 0>
			<cfset nights = dateDiff('d', rc.Filter.getCheckInDate(), rc.Filter.getCheckOutDate())>
			<cfset currency = rc.Hotel.getRooms()[1].getBaseRateCurrency()>
			<cfset hotelBase = rc.Hotel.getRooms()[1].getDailyRate()*nights />
			<cfset hotelTotal = rc.Hotel.getRooms()[1].getBaseRate()>
			<cfset hotelText = 'Quoted at check-in'>
		<cfelse>
			<cfset nights = dateDiff('d', rc.Filter.getCheckInDate(), rc.Filter.getCheckOutDate())>
			<cfset currency = rc.Hotel.getRooms()[1].getDailyRateCurrency()>
			<cfset hotelBase = rc.Hotel.getRooms()[1].getDailyRate()*nights />
			<cfset hotelTotal = rc.Hotel.getRooms()[1].getDailyRate()*nights>
			<cfset hotelText = 'Quoted at check-in'>
		</cfif>
  </cfif>
	<div class="carrow tripSummary" style="padding:15px; float:right;">

		<div class="row minlineheight" style="float:right;">
			<div class="span1"></div>
			<div class="span1" align="right"><strong>Base Rate</strong></div>
			<div class="span2" align="right">
				<strong>
				<cfif rc.hotelSelected AND rc.Hotel.getRooms()[1].getTotalForStay() GT 0 AND UCASE(rc.Hotel.getRooms()[1].getAPISource()) EQ "PRICELINE">
					<a rel="popover" href="javascript:$('##displayTaxesAndFees').modal('show');" />Taxes and Fees</a>
				<cfelse>
					Taxes and Fees
				</cfif>
				</strong>
			</div>
			<cfif rc.hotelSelected><div class="span2" align="right"><strong>Room Subtotal<br>for #nights# night(s)</strong></div></cfif>
			<div class="span1" align="right"><strong>Total Charges</strong></div>
		</div>

		<cfset tripTotal = 0>
		<cfset tripCurrency = 'USD'>

		<cfif rc.airSelected>

			<div class="row minlineheight" id="airTotalRow" style="float:right;">
				<div class="span1" align="right">Flight</div>
				<!--- Per STM-2595, changed "Base" to "ApproximateBase" since Base can be in any currency and ApproximateBase is always in USD. --->
				<div class="span1" align="right">#numberFormat(rc.Air.ApproximateBase, '$____.__')#</div>
				<!--- <div class="span1">#numberFormat(rc.Air.Base, '$____.__')#</div> --->
				<div class="span2" align="right">#numberFormat(rc.Air.Taxes, '$____.__')#</div>
				<cfif rc.hotelSelected><div class="span2"></div></cfif>
				<div class="span1" id="airTotalCol" align="right">#numberFormat(rc.Air.Total, '$____.__')#</div>
			</div>
			<input type="hidden" id="airTotal" value="#rc.Air.Total#">

			<cfset tripTotal = tripTotal + rc.Air.Total>
			<cfset tripCurrency = 'USD'>

		</cfif>
		<cfif rc.hotelSelected>
			<div class="row minlineheight" id="hotelTotalRow" style="float:right;">
				<div class="span1" align="right">Hotel</div>
				<div class="span1" align="right">#(currency EQ 'USD' ? numberFormat(baseHotelRate, '$____.__') : numberFormat(baseHotelRate, '____.__')&' '&currency)#<br><span style="font-size:8px;">avg per night</span></div>
				<div class="span2" align="right">#hotelText#</div>
				<div class="span2" align="right">#(currency EQ 'USD' ? numberFormat(hotelBase, '$____.__') : numberFormat(hotelBase, '____.__')&' '&currency)#</div>
				<div class="span1" id="hotelTotalCol" align="right">#(currency EQ 'USD' ? numberFormat(hotelTotal, '$____.__') : numberFormat(hotelTotal, '____.__')&' '&currency)#
					<cfif UCASE(rc.Hotel.getRooms()[1].getAPISource()) EQ "PRICELINE" AND rc.Hotel.getRooms()[1].getRatePlanType() NEQ 'MER'>
						<br><span style="font-size:8px;">estimated total <br>+ applicable taxes</span>
					</cfif>
				</div>
			</div>
			<input type="hidden" id="hotelTotal" value="#hotelTotal#">

			<cfset tripTotal = (currency EQ 'USD' ? tripTotal + hotelTotal : 0)>
			<cfset tripCurrency = (tripCurrency EQ 'USD' ? currency : tripCurrency)>

		</cfif>

		<cfif rc.vehicleSelected>

			<cfset currency = rc.Vehicle.getCurrency()>
			<cfset vehicleTotal = rc.Vehicle.getEstimatedTotalAmount()>

			<div class="row minlineheight" id="carTotalRow" style="float:right;">
				<div class="span1" align="right">Car</div>
				<div class="span1"></div>
				<div class="span2" align="right">Quoted at pick-up</div>
				<cfif rc.hotelSelected><div class="span2"></div></cfif>
				<div class="span1" id="carTotalCol" align="right">#(currency EQ 'USD' ? numberFormat(vehicleTotal, '$____.__') : numberFormat(vehicleTotal, '____.__')&' '&currency)#</div>
			</div>
			<input type="hidden" id="carTotal" value="#vehicleTotal#">

			<cfset tripTotal = (currency EQ 'USD' ? tripTotal + vehicleTotal : 0)>
			<cfset tripCurrency = (tripCurrency EQ 'USD' ? currency : tripCurrency)>

		</cfif>

		<div class="row minlineheight #(rc.fees.fee EQ 0 ? 'hide' : '')#" id="bookingFeeRow" style="float:right;">
			<div class="span1" align="right">Booking Fee</div>
			<div class="span1"></div>
			<div class="span2"></div>
			<cfif rc.hotelSelected><div class="span2"></div></cfif>
			<div class="span1" id="bookingFeeCol" align="right">#numberFormat(rc.fees.fee, '$____.__')#</div>
		</div>
		<input type="hidden" name="bookingFee" id="bookingFee" value="#rc.fees.fee#">
		<input type="hidden" name="agent" value="#rc.fees.agent#">
		<input type="hidden" name="airFeeType" value="#rc.fees.airFeeType#">
		<input type="hidden" name="auxFeeType" value="#rc.fees.auxFeeType#">
		<input type="hidden" name="airAgentFee" id="airAgentFee" value="#rc.fees.airAgentFee#">

		<cfif tripCurrency EQ 'USD'>

			<cfset tripTotal = tripTotal + rc.fees.fee>

			<div class="row minlineheight" id="bookingTotalRow" style="float:right;">
				<cfif rc.hotelSelected>
					<cfset numSpan = 6 />
				<cfelse>
					<cfset numSpan = 4 />
				</cfif>
				<div class="span#numSpan# blue" align="right"><strong>Trip cost for current traveler</strong></div>
				<div class="span1 blue" id="totalCol" align="right">
					<strong>#numberFormat(tripTotal, '$____.__')#</strong>
				</div>
			</div>
			<div id="unusedtickeverbiage" class="blue right" align="right">
				before unused ticket credit
			</div>

		</cfif>
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

<!--- <cfdump var="#rc.fees#" /> --->
