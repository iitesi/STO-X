<table width="475" align="center" class="popUpTable">
<cfoutput query="rc.qBaggage">
	<tr>
		<td colspan="3"><h3>#Name# Baggage Fees (one-way):</h3></td>
	<tr>
		<td colspan="3">&nbsp;</td>
	</tr>
	<cfif CreateUpdate_Datetime NEQ ''>
		<tr style="border-bottom:1px dashed ##CCCCCC">
			<td></td>
			<td align="center" class="bold">Paid at<br>online-checkin</td>
			<td align="center" class="bold">Paid at<br>airport check-in</td>
		</tr>
		<tr style="border-bottom:1px dashed ##CCCCCC">
			<td>1st Checked Bag:</td>
			<td align="center">#DollarFormat(OnlineDomBag1)#</td>
			<td align="center">#DollarFormat(DomBag1)#</td>
		</tr>
		<tr style="border-bottom:1px dashed ##CCCCCC">
			<td>2nd Checked Bag:</td>
			<td align="center">#DollarFormat(OnlineDomBag2)#</td>
			<td align="center">#DollarFormat(DomBag2)#</td>
		</tr>
		<tr style="border-bottom:1px dashed ##CCCCCC">
			<td>Total for 2 Bags (each way):</td>
			<td align="center">#DollarFormat(OnlineDomBag1 + OnlineDomBag2)#</td>
			<td align="center">#DollarFormat(DomBag1 + DomBag2)#</td>
		</tr>
		<tr style="border-bottom:1px dashed ##CCCCCC">
			<td>3+ or Oversized Bags:</td>
			<td align="center" colspan="2">Additional Fees Apply</td>
		</tr>
	<cfelse>
		<tr>
			<td colspan="3">Baggage Fee Information is not available for this airline (#rc.sCarriers#).</td>
		</tr>	
	</cfif>
	<tr>
		<td colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="3">To view the most current fee schedule and full policy details, please visit the <a href="#Baggage_Link#" target="_blank">#Name#</a> website.</td>
	</tr>
	<tr>
		<td colspan="3">&nbsp;</td>
	</tr>
</cfoutput>
<tr>
	<td colspan="3">Fees are displayed for informational purposes only.</td>
</tr>
<tr>
	<td colspan="3">Short's Travel Management does not take payment for baggage fees.</td>
</tr>
<tr>
	<td colspan="3">You will pay the airline upon online check-in or airport check-in for all baggage fees.</td>
</tr>
</table>