<cfoutput>
	<cfif rc.Filter.getProfileID() NEQ 0
		AND NOT arrayIsEmpty(session.searches[rc.searchID].unusedtickets)
		AND arrayFind( structKeyArray(rc.Filter.getUnusedTicketCarriers()), rc.Air.platingCarrier )>
		<div class="alert alert-success">
			You have unused ticket credits on this airline.<br>
			<small>
				Check below if you would like a Travel Consultant to review the airline's re-use rules to determine if your credit can be applied to this ticket.  
				<cfif rc.fees.airAgentFee NEQ 0>
					A #dollarFormat(rc.fees.airAgentFee)# Travel Consultant booking fee will apply.  
				</cfif>
			</small>
			<font color="##000000">
				<table width="100%">
				<tr>
					<td></td>
					<td>Airline</td>
					<td>Credit Value</td>
					<td>Expires</td>
					<td>Original Ticket Issued To</td>
				</tr>
				<input type="hidden" name="unusedTickets" value="">
				<cfloop array="#session.searches[rc.searchID].unusedtickets#" index="unusedTicketIndex" item="unusedTicketItem">
					<cfif rc.Air.platingCarrier EQ unusedTicketItem.getCarrier()>
						<tr>
							<td><input type="checkbox" name="unusedtickets" id="unusedtickets" value="#unusedTicketItem.getID()#"></td>
							<td>#unusedTicketItem.getCarrierName()#</td>
							<td>#dollarFormat(unusedTicketItem.getAirfare())#</td>
							<td>#dateFormat(unusedTicketItem.getExpirationDate(), 'm/d/yyyy')#</td>
							<td>#unusedTicketItem.getLastName()#/#unusedTicketItem.getFirstName()#</td>
						</tr>
					</cfif>
				</cfloop>
				</table>
			</font>
		</div>
	</cfif>
</cfoutput>