<cfoutput>
	<cfif bAir>
		<table with="100%">
		<tr>
			<td class="medium bold" colspan="2">
			<span class="blue">#DollarFormat(stItinerary.Air.Total)#</span>
			#(stItinerary.Air.Class EQ 'Y' ? 'Economy' : (stItinerary.Air.Class EQ 'C' ? 'Business' : 'First'))#
			Class
			#(stItinerary.Air.Ref EQ 0 ? 'No Refunds' : 'Refundable')#
			</td>
		</tr>
		<cfif rc.nY1TripKey NEQ ''><!--- They may not have business class returned on a flight --->
			<cfset nFareDiff = session.searches[rc.nSearchID].stTrips[rc.nY1TripKey].Total-stItinerary.Air.Total>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr>
				<td width="40">
					<input type="checkbox" name="nC0TripKey" value="rc.nY1TripKey">
				</td>
				<td>
					Not sure if your schedule will change?<br>
					Make your ticket fully refundable for
					#DollarFormat(nFareDiff)# more
				</td>
			</tr>
		</cfif>
		<cfif rc.nC0TripKey NEQ ''>
			<cfset nFareDiff = session.searches[rc.nSearchID].stTrips[rc.nC0TripKey].Total-stItinerary.Air.Total>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr>
				<td width="40">
					<input type="checkbox" name="nC0TripKey" value="rc.nC0TripKey">
				</td>
				<td>
					Rest. Relax. Fly with class.<br>
					Move up to business class for #DollarFormat(nFareDiff)# more.
				</td>
			</tr>
		</cfif>
		</table>
	</cfif>
</cfoutput>