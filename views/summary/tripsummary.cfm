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
	<div class="carrow" style="padding:15px; float:right;">

		<div class="row minlineheight">
			<div class="span1"></div>
			<div class="span1"><strong>Base Rate</strong></div>
			<div class="span2"><strong>Taxes</strong></div>
			<div class="span1"><strong>Total</strong></div>
		</div>

		<cfset tripTotal = 0>
		<cfset tripCurrency = 'USD'>

		<cfif rc.airSelected>

			<div class="row minlineheight" id="airTotalRow">
				<div class="span1">Flight</div>
				<!--- Per STM-2595, changed "Base" to "ApproximateBase" since Base can be in any currency and ApproximateBase is always in USD. --->
				<div class="span1">#numberFormat(rc.Air.ApproximateBase, '$____.__')#</div>
				<!--- <div class="span1">#numberFormat(rc.Air.Base, '$____.__')#</div> --->
				<div class="span2">#numberFormat(rc.Air.Taxes, '$____.__')#</div>
				<div class="span1" id="airTotalCol">#numberFormat(rc.Air.Total, '$____.__')#</div>
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
				<cfset currency = rc.Hotel.getRooms()[1].getDailyRateCurrency()>
				<cfset hotelTotal = rc.Hotel.getRooms()[1].getDailyRate()*nights>
				<cfset hotelText = 'Quoted at check-in'>
			</cfif>

			<div class="row minlineheight" id="hotelTotalRow">
				<div class="span1">Hotel</div>
				<div class="span1"></div>
				<div class="span2">#hotelText#</div>
				<div class="span1" id="hotelTotalCol">#(currency EQ 'USD' ? numberFormat(hotelTotal, '$____.__') : hotelTotal&' '&currency)#</div>
			</div>
			<input type="hidden" id="hotelTotal" value="#hotelTotal#">

			<cfset tripTotal = (currency EQ 'USD' ? tripTotal + hotelTotal : 0)>
			<cfset tripCurrency = (tripCurrency EQ 'USD' ? currency : tripCurrency)>

		</cfif>
		
		<cfif rc.vehicleSelected>

			<cfset currency = rc.Vehicle.getCurrency()>
			<cfset vehicleTotal = rc.Vehicle.getEstimatedTotalAmount()>

			<div class="row minlineheight" id="carTotalRow">
				<div class="span1">Car</div>
				<div class="span1"></div>
				<div class="span2">Quoted at pick-up</div>
				<div class="span1" id="carTotalCol">#(currency EQ 'USD' ? numberFormat(vehicleTotal, '$____.__') : vehicleTotal&' '&currency)#</div>
			</div>
			<input type="hidden" id="carTotal" value="#vehicleTotal#">

			<cfset tripTotal = (currency EQ 'USD' ? tripTotal + vehicleTotal : 0)>
			<cfset tripCurrency = (tripCurrency EQ 'USD' ? currency : tripCurrency)>

		</cfif>

		<div class="row minlineheight #(rc.fees.fee EQ 0 ? 'hide' : '')#" id="bookingFeeRow">
			<div class="span1">Booking Fee</div>
			<div class="span1"></div>
			<div class="span2"></div>
			<div class="span1" id="bookingFeeCol">#numberFormat(rc.fees.fee, '$____.__')#</div>
		</div>
		<input type="hidden" name="bookingFee" id="bookingFee" value="#rc.fees.fee#">
		<input type="hidden" name="agent" value="#rc.fees.agent#">
		<input type="hidden" name="airFeeType" value="#rc.fees.airFeeType#">
		<input type="hidden" name="auxFeeType" value="#rc.fees.auxFeeType#">
		<input type="hidden" name="airAgentFee" id="airAgentFee" value="#rc.fees.airAgentFee#">

		<cfif tripCurrency EQ 'USD'>

			<cfset tripTotal = tripTotal + rc.fees.fee>

			<div class="row minlineheight" id="bookingTotalRow">
				<div class="span4 blue"><strong>Trip cost for current traveler</strong></div>
				<div class="span1 blue" id="totalCol">
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