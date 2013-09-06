<cfset airlines = ValueList(rc.qBaggage.shortCode)>

<cfoutput>
<div id="baggage">
<div class="accordion" id="accordion2">
		<cfloop query="rc.qBaggage">
	<div class="accordion-group">
		<div class="accordion-heading active">
			<a class="accordion-toggle" data-toggle="collapse" data-parent="##accordion2" href="##collapse#shortCode#">
				<img src="assets/img/airlines/#rc.qBaggage.ShortCode#_sm.png"> #rc.qBaggage.Name# Baggage Fees <small>(one way)</small>
			</a>
		</div>
		<div id="collapse#shortCode#" class="accordion-body collapse <cfif currentRow EQ 1>in</cfif>">
			<div class="accordion-inner">
				<cfif rc.qBaggage.CreateUpdate_Datetime NEQ "">
					<table class="table table-hover table-condensed">
						<thead>
						<tr>
							<td>&nbsp;</td>
							<td class="bold">Paid at online check-in</td>
							<td class="bold">Paid at airport check-in</td>
						</tr>
						</thead>
						<tbody>
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
						</tbody>
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
			</div>
		</div>
	</div>
</cfloop>
</div>

	<ul class="unstyled muted">
		<li>To view the most current fee schedule and full policy details, please visit the <a href="#rc.qBaggage.Baggage_Link#" target="_blank">#rc.qBaggage.Name#</a> website.</li>
		<li>Fees are displayed for informational purposes only.</li>
		<li>Short's Travel Management does not take payment for baggage fees.</li>
		<li>You will pay the airline upon online check-in or airport check-in for all baggage fees.</li>
	</ul>
</div>
</cfoutput>

