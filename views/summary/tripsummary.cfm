<cfoutput>
	<style>
	.minlineheight {
		line-height:10px;
	}
	</style>
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
				<div class="span1">#numberFormat(rc.Air.Base, '$____.__')#</div>
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
			<cfelse>
				<cfset currency = rc.Hotel.getRooms()[1].getBaseRateCurrency()>
				<cfset hotelTotal = rc.Hotel.getRooms()[1].getBaseRate()>
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

		<div class="row minlineheight #(rc.fees.fee EQ 0 ? 'hide' : '')#" id="bookingTotalRow">
			<div class="span1">Booking Fee</div>
			<div class="span1"></div>
			<div class="span2"></div>
			<div class="span1" id="bookingTotalCol">#numberFormat(rc.fees.fee, '$____.__')#</div>
		</div>
		<input type="hidden" id="bookingTotal" value="#rc.fees.fee#">

		<cfif tripCurrency EQ 'USD'>

			<cfset tripTotal = tripTotal + rc.fees.fee>

			<div class="row minlineheight" id="bookingTotalRow">
				<div class="span4 blue"><strong>Trip cost for current traveler</strong></div>
				<div class="span1 blue" id="totalCol"><strong>#numberFormat(tripTotal, '$____.__')#</strong></div>
			</div>

		</cfif>

	</div>
</cfoutput>