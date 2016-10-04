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
			<div class="col-xs-offset-3 col-xs-3"><strong>Base Rate</strong></div>
			<div class="col-xs-3"><strong>Taxes</strong></div>
			<div class="col-xs-3"><strong>Total</strong></div>
		</div>

		<cfset tripTotal = 0>
		<cfset tripCurrency = 'USD'>

		<cfif rc.airSelected>

			<div class="row" id="airTotalRow">
				<div class="col-xs-3">Flight</div>
				<!--- Per STM-2595, changed "Base" to "ApproximateBase" since Base can be in any currency and ApproximateBase is always in USD. --->
				<div class="col-xs-3">#numberFormat(rc.Air.ApproximateBase, '$____.__')#</div>
				<!--- <div class="span1">#numberFormat(rc.Air.Base, '$____.__')#</div> --->
				<div class="col-xs-3">#numberFormat(rc.Air.Taxes, '$____.__')#</div>
				<div class="col-xs-3 text-right" id="airTotalCol">#numberFormat(rc.Air.Total, '$____.__')#</div>
			</div>
			<input type="hidden" id="airTotal" value="#rc.Air.Total#">

			<cfset tripTotal = tripTotal + rc.Air.Total>
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
				<div class="col-xs-3">Hotel</div>
				<div class="col-xs-3"></div>
				<div class="col-xs-3">#hotelText#</div>
				<div class="col-xs-3" id="hotelTotalCol">#(currency EQ 'USD' ? numberFormat(hotelTotal, '$____.__') : numberFormat(hotelTotal, '____.__')&' '&currency)#</div>
			</div>
			<input type="hidden" id="hotelTotal" value="#hotelTotal#">

			<cfset tripTotal = (currency EQ 'USD' ? tripTotal + hotelTotal : 0)>
			<cfset tripCurrency = (tripCurrency EQ 'USD' ? currency : tripCurrency)>

		</cfif>
		
		<cfif rc.vehicleSelected>

			<cfset currency = rc.Vehicle.getCurrency()>
			<cfset vehicleTotal = rc.Vehicle.getEstimatedTotalAmount()>

			<div class="row text-right" id="carTotalRow">
				<div class="col-xs-3">Car</div>
				<div class="col-xs-3"></div>
				<div class="col-xs-3">Quoted at pick-up</div>
				<div class="col-xs-3" id="carTotalCol">#(currency EQ 'USD' ? numberFormat(vehicleTotal, '$____.__') : numberFormat(vehicleTotal, '____.__')&' '&currency)#</div>
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
				<div class="col-xs-8 blue"><strong>Trip cost for current traveler</strong></div>
				<div class="col-xs-4 blue" id="totalCol">
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