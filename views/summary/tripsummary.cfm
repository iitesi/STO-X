<cfoutput>

	<cfif structKeyExists(rc, "Air")
	    AND isStruct( rc.Air )
	    AND structKeyExists(rc.Air, 'PricingSolution')
		AND isObject(rc.Air.PricingSolution)>
		<cfset rc.Air.Total = replace(rc.Air.PricingSolution.getPricingInfo()[1].getTotalPrice(), 'USD', '')>
		<cfset rc.Air.Base = replace(rc.Air.PricingSolution.getPricingInfo()[1].getBasePrice(), 'USD', '')>
		<cfset rc.Air.ApproximateBase = replace(rc.Air.PricingSolution.getPricingInfo()[1].getApproximateBasePrice(), 'USD', '')>
		<cfset rc.Air.Taxes = replace(rc.Air.PricingSolution.getPricingInfo()[1].getTaxes(), 'USD', '')>
	</cfif>
	<div class="tripSummary purchase-summary">

		<div class="text-right row">
			<div class="col-xs-8"><strong></strong></div>
			<div class="col-xs-4"><strong>Total</strong></div>
		</div>

		<cfset tripTotal = 0>
		<cfset tripCurrency = 'USD'>

		<cfif rc.airSelected>
			
			<div class="text-right row">
				<div class="col-xs-8">Flight</div>
				<div class="col-xs-4 text-right" id="airTotalCol">#numberFormat(rc.Air[0].TotalPrice, '$____.__')#</div>
			</div>

			<input type="hidden" id="airTotal" value="#rc.Air[0].TotalPrice#">
			<cfset tripTotal = tripTotal + rc.Air[0].TotalPrice>
			<cfset tripCurrency = 'USD'>

		</cfif>
		<cfif rc.hotelSelected>

			<cfif rc.Hotel.getRooms()[1].getTotalForStay() GT 0>
				<cfset currency = rc.Hotel.getRooms()[1].getTotalForStayCurrency()>
				<cfset hotelTotal = rc.Hotel.getRooms()[1].getTotalForStay()>
				<cfset hotelText = 'Including taxes'>
			<cfelseif rc.Hotel.getRooms()[1].getBaseRate() GT 0>
				<cfset currency = rc.Hotel.getRooms()[1].getBaseRateCurrency()>
				<cfset hotelTotal = rc.Hotel.getRooms()[1].getBaseRate()>
				<cfset hotelText = 'Quoted at check-in'>
			<cfelse>
				<cfset nights = dateDiff('d', rc.Filter.getCheckInDate(), rc.Filter.getCheckOutDate())>
				<cfset currency = rc.Hotel.getRooms()[1].getDailyRateCurrency()>
				<cfset hotelTotal = rc.Hotel.getRooms()[1].getDailyRate()*nights>
				<cfset hotelText = 'Quoted at check-in'>
			</cfif>

			<div class="row text-right" id="hotelTotalRow">
				<div class="col-xs-8">Hotel</div>
				<!--- <div class="col-xs-3">
					<!--- Priceline requires explicit declaration of taxes --->
					<cfif rc.Hotel.getRooms()[1].getAPISource() EQ "Priceline" AND isNumeric(rc.Hotel.getRooms()[1].getDailyRate())>
						#numberFormat(rc.Hotel.getRooms()[1].getDailyRate(), '$____.__')#
					<cfelse>
						<!--- nothing to display ---->
					</cfif>
				</div> --->
				<!--- <div class="col-xs-8">
					<!--- Priceline requires explicit declaration of taxes with a popover disclaimer styles just-so --->
					<cfif rc.Hotel.getRooms()[1].getAPISource() EQ "Priceline" AND isNumeric(rc.Hotel.getRooms()[1].getTax())>
						<cfset taxStatementTitle = "Charges for Taxes and Fees"/>
						<cfset taxStatementContent = "
							<div id=tax_popover_content>
								<p>
									In connection with facilitating your hotel transaction, the charge to your debit or credit card will include a charge for Taxes and Fees. This charge includes an estimated amount to recover the amount we pay to the hotel in connection with your reservation for taxes owed by the hotel including, without limitation, sales and use tax, occupancy tax, room tax, excise tax, value added tax and/or other similar taxes.  In certain locations, the tax amount may also include government imposed service fees or other fees not paid directly to the taxing authorities but required by law to be collected by the hotel. The amount paid to the hotel in connection with your reservation for taxes may vary from the amount we estimate and include in the charge to you. The balance of the charge for Taxes and Fees is a fee we retain as part of the compensation for our services and to cover the costs of your reservation, including, for example, customer service costs. The charge for Taxes and Fees varies based on a number of factors including, without limitation, the amount we pay the hotel and the location of the hotel where you will be staying, and may include profit that we retain.
								</p>
								<p>
									Except as described below, we are not the vendor collecting and remitting taxes to the applicable taxing authorities. Our hotel suppliers, as vendors, include all applicable taxes in the amount billed to us and we pay over such amounts directly to the vendors. We are not a co-vendor associated with the vendor with whom we book or reserve our customer's travel arrangements. Taxability and the appropriate tax rate and the type of applicable taxes vary greatly by location.
								</p>
									For transactions involving hotels located within certain jurisdictions, the charge to your debit or credit card for Taxes and Fees includes a payment of tax that we are required to collect and remit to the jurisdiction for tax owed on amounts we retain as compensation for our services.
								</p>
								<p>
									Please note that we are unable to facilitate a rebate of Canadian Goods and Services Tax (GST) for customers booking Canadian hotel accommodations utilizing our services.
								</p>
							</div>
						"/>
						<style>
							##tax_popover_container .popover {
								width: 500px;
								height: 500px;
								max-width: none;
							}
							##tax_popover_content {
								height: 400px;
								overflow-x: hidden;
								overflow-y: scroll;
							}
						</style>
						<script>
							$(document).ready(function(){
								$('[data-toggle="tax_popover"]').popover({
									container: '##tax_popover_container',
									placement: 'auto left',
									trigger: 'focus',
									html: true
								});
							});
						</script>
						<div id="tax_popover_container">
							<a href="javascript:void(0);" data-toggle="tax_popover" title="#taxStatementTitle#" data-content="#taxStatementContent#">#numberFormat(rc.Hotel.getRooms()[1].getTax(), '$____.__')#</a>
						</div>
					<cfelse>
						#hotelText#
					</cfif>
				</div> --->
				<div class="col-xs-4" id="hotelTotalCol">#(currency EQ 'USD' ? numberFormat(hotelTotal, '$____.__') : numberFormat(hotelTotal, '____.__')&' '&currency)#</div>
			</div>

			<input type="hidden" id="hotelTotal" value="#hotelTotal#">
			<cfset tripTotal = (currency EQ 'USD' ? tripTotal + hotelTotal : 0)>
			<cfset tripCurrency = (tripCurrency EQ 'USD' ? currency : tripCurrency)>

		</cfif>

		<cfif rc.vehicleSelected>

			<cfset currency = rc.Vehicle.getCurrency()>
			<cfset vehicleTotal = rc.Vehicle.getEstimatedTotalAmount()>

			<div class="row text-right" id="carTotalRow">
				<div class="col-xs-8">Car</div>
				<!--- <div class="col-xs-3"></div> --->
				<!--- <div class="col-xs-3">Quoted at pick-up</div> --->
				<div class="col-xs-4" id="carTotalCol">#(currency EQ 'USD' ? numberFormat(vehicleTotal, '$____.__') : numberFormat(vehicleTotal, '____.__')&' '&currency)#</div>
			</div>
			<input type="hidden" id="carTotal" value="#vehicleTotal#">

			<cfset tripTotal = (currency EQ 'USD' ? tripTotal + vehicleTotal : 0)>
			<cfset tripCurrency = (tripCurrency EQ 'USD' ? currency : tripCurrency)>

		</cfif>

		<div class="row text-right #(rc.fees.fee EQ 0 ? 'hide' : '')#" id="bookingFeeRow">
			<div class="col-xs-8">Booking Fee</div>
			<div class="col-xs-4" id="bookingFeeCol">#numberFormat(rc.fees.fee, '$____.__')#</div>
		</div>
		<input type="hidden" name="bookingFee" id="bookingFee" value="#rc.fees.fee#">
		<input type="hidden" name="agent" value="#rc.fees.agent#">
		<input type="hidden" name="airFeeType" value="#rc.fees.airFeeType#">
		<input type="hidden" name="auxFeeType" value="#rc.fees.auxFeeType#">
		<input type="hidden" name="airAgentFee" id="airAgentFee" value="#rc.fees.airAgentFee#">

		<cfif tripCurrency EQ 'USD'>

			<cfset tripTotal = tripTotal + rc.fees.fee>

			<div class="row text-right" id="bookingTotalRow">
				<div class="col-xs-8 blue-text"><strong>Trip cost for current traveler</strong></div>
				<div class="col-xs-4 blue-text" id="totalCol">
					<strong>#numberFormat(tripTotal, '$____.__')#</strong>
				</div>
			</div>
			<div id="unusedtickeverbiage" class="blue right">
				before unused ticket credit
			</div>

		</cfif>
	</div>
</cfoutput>
<!--- <cfdump var="#rc.fees#" /> --->