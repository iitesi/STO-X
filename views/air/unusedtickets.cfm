<cfoutput>
	<cfif rc.Filter.getProfileID() NEQ 0
		AND NOT arrayIsEmpty(session.searches[rc.searchID].unusedtickets)>
		<div id="usermessage" class="alert alert-success">
			You have unused ticket credits on the following airlines:<br>
			<font color="##000000">
				<table width="50%">
				<tr>
					<td>Airline</td>
					<td>Credit Value</td>
					<td>Expires</td>
					<td>Original Ticket Issued To</td>
				</tr>
				<cfloop array="#session.searches[rc.searchID].unusedtickets#" index="unusedTicketIndex" item="unusedTicketItem">
					<tr>
						<td>#unusedTicketItem.getCarrierName()#</td>
						<td>#dollarFormat(unusedTicketItem.getAirfare())#</td>
						<td>#dateFormat(unusedTicketItem.getExpirationDate(), 'm/d/yyyy')#</td>
						<td>#unusedTicketItem.getLastName()#/#unusedTicketItem.getFirstName()#</td>
					</tr>
				</cfloop>
				</table>
			</font>
			<small>
				<font color="##000000" style="font-weight:normal;">
					Ticket credit is subject to airline re-use rules. Credit may not be applicable to all itineraries listed. A Travel Consultant will validate airline re-use rules before issuing a new ticket.
				</font>
			</small>
			<button type="button" class="closemsg close pull-right" title="Close message"><i class="icon-remove"></i></button>
		</div>
	</cfif>
</cfoutput>