<cfoutput>
	<cfif bAir>
		<br><br>
		<div class="fulldiv">
			<table align="right">
			<tr>
				<td class="blue bold medium">
					Booking Fee
				</td>
				<td class="blue bold medium right" style="padding-left:25px;">
					#DollarFormat(rc.stFees.nRequestFee)#
				</td>
			</tr>
			<tr>
				<td class="blue bold medium">
					Total Trip Cost
				</td>
				<td class="blue bold medium right" style="padding-left:25px;">
					#(bTotalTrip NEQ 'CURR' ? DollarFormat(bTotalTrip) : 'MULT CURRENCIES')#
				</td>
			</tr>
			</table>
			<br clear="all">
			<br clear="all">
			<table align="right">
			<tr>
				<td>
					<input type="submit" name="btnAdd" class="button0policy" value="ADD A TRAVELER">
				</td>
				<td style="padding-left:20px;">
					<input type="submit" name="btnConfirm" class="button1policy" value="CONFIRM YOUR PURCHASE">
				</td>
			</tr>
			</table>
		</div>
	</cfif>
</cfoutput>