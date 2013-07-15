


<cfoutput>
<img class="carrierimg" src="assets/img/airlines/#rc.qBaggage.ShortCode#.png" style="float:left;padding-right:20px;">
<h3>#rc.qBaggage.Name# Baggage Fees (one-way)</h3>

<cfif rc.qBaggage.CreateUpdate_Datetime NEQ "">

		<table class="table">
			<tr>
				<td>&nbsp;</td>
				<td class="bold">Paid at online-checkin</td>
				<td class="bold">Paid at airport check-in</td>
			</tr>
			<tr>
				<td>1st Checked Bag</td>
				<td>#DollarFormat(rc.qBaggage.OnlineDomBag1)#</td>
				<td>#DollarFormat(rc.qBaggage.DomBag1)#</td>
			</tr>
			<tr>
				<td>2nd Checked Bag</td>
				<td>#DollarFormat(rc.qBaggage.OnlineDomBag2)#</td>
				<td>#DollarFormat(rc.qBaggage.DomBag2)#</td>
			</tr>
			<tr>
				<td>Total for 2 Bags (each way)</td>
				<td>#DollarFormat(rc.qBaggage.OnlineDomBag1 + rc.qBaggage.OnlineDomBag2)#</td>
				<td>#DollarFormat(rc.qBaggage.DomBag1 + rc.qBaggage.DomBag2)#</td>
			</tr>
			<tr>
				<td>3+ or Oversized Bags</td>
				<td colspan="2">Additional Fees Apply</td>
			</tr>
		</table>

	<cfelse>

			<p>&nbsp;</p>
			<p>
				<span class="icon-stack">
  				<i class="icon-suitcase"></i>
  				<i class="icon-ban-circle icon-stack-base text-error"></i>
				</span>
				Baggage Fee Information is not available for #rc.qBaggage.name#.</p>
				<p>&nbsp;</p>
	</cfif>

	<ul class="unstyled muted">
		<li>To view the most current fee schedule and full policy details, please visit the <a href="#rc.qBaggage.Baggage_Link#" target="_blank">#rc.qBaggage.Name#</a> website.</li>
		<li>Fees are displayed for informational purposes only.</li>
		<li>Short's Travel Management does not take payment for baggage fees.</li>
		<li>You will pay the airline upon online check-in or airport check-in for all baggage fees.</li>
	</ul>
</cfoutput>

