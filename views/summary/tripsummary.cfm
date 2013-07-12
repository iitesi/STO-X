<cfoutput>
	<table width="100%">
	<tr style="border-bottom:1px solid ##000">
		<td colspan="4"><h3>Trip Summary</h3></td>
	</tr>
	<tr>
		<td></td>
		<td>Base Rate</td>
		<td>Taxes</td>
		<td>Total</td>
	</tr>
	<cfset nTotalTrip = 0>
	<cfif structKeyExists(stItinerary, 'Air')>
		<cfset Air = true>
		<tr>
			<td>Flight</td>
			<td>#DollarFormat(stItinerary.Air.Base)#</td>
			<td>#DollarFormat(stItinerary.Air.Taxes)#</td>
			<td class="right">#DollarFormat(stItinerary.Air.Total)#</td>
		</tr>
		<cfset nTotalTrip = nTotalTrip + stItinerary.Air.Total>
	</cfif>
	<cfif structKeyExists(stItinerary, 'Hotel')>
		<cfset Hotel = true>
		<tr>
			<td>Hotel</td>
			<td></td>
			<td></td>
			<td class="right"></td>
		</tr>
		<cfset nTotalTrip = nTotalTrip + hoteltotalhere>
	</cfif>
	<cfif structKeyExists(stItinerary, 'Car')>
		<cfset Car = true>
		<cfset sCarCurr = Left(stItinerary.Car.EstimatedTotalAmount, 3)>
		<cfset sCarTotal = Mid(stItinerary.Car.EstimatedTotalAmount, 4)>
		<tr>
			<td>Car</td>
			<td>#(sCarCurr EQ 'USD' ? DollarFormat(sCarTotal) : sCarTotal)#</td>
			<td>At pick up</td>
			<td class="right">#(sCarCurr EQ 'USD' ? DollarFormat(sCarTotal) : sCarTotal)#</td>
		</tr>
		<cfset nTotalTrip = (sCarCurr EQ 'USD' AND IsNumeric(nTotalTrip) ? nTotalTrip + sCarTotal : 'Unknown')>
	</cfif>
	<tr>
		<td>Booking Fee</td>
		<td></td>
		<td></td>
		<td class="right">#DollarFormat(rc.stFees.nSpecificFee)#</td>
	</tr>
	<cfif IsNumeric(nTotalTrip)>
		<cfset nTotalTrip = nTotalTrip + rc.stFees.nSpecificFee>
		<tr style="border-top:1px solid ##000">
			<td>Trip Cost</td>
			<td></td>
			<td></td>
			<td class="right">#DollarFormat(nTotalTrip)#</td>
		</tr>
	</cfif>
	</table>
</cfoutput>