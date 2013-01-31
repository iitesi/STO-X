<cfoutput>
	<div>
		<cfif rc.bSelection EQ 0>
			<ul id="details-tabs">
				<cfset sURL = 'SearchID=#rc.SearchID#&nTripID=#rc.nTripID#&nGroup=#nGroup#'>
				<a onClick="$('##tabcontent').html('One moment please.');$('##overlayContent').load('?action=air.popup&sDetails=details&#sURL#')">
					<li <cfif rc.sDetails EQ 'details'>class="selected"</cfif>>
						Details
					</li>
				</a>
				<a onClick="$('##tabcontent').html('One moment please.');$('##overlayContent').load('?action=air.popup&sDetails=seatmap&#sURL#')">
					<li <cfif rc.sDetails EQ 'seatmap'>class="selected"</cfif>>
						Seats
					</li>
				</a>
				<a onClick="$('##tabcontent').html('One moment please.');$('##overlayContent').load('?action=air.popup&sDetails=baggage&#sURL#')">
					<li <cfif rc.sDetails EQ 'baggage'>class="selected"</cfif>>
						Bags
					</li>
				</a>
				<a onClick="$('##tabcontent').html('One moment please.');$('##overlayContent').load('?action=air.popup&sDetails=email&#sURL#')">
					<li <cfif rc.sDetails EQ 'email'>class="selected"</cfif>>
						Email
					</li>
				</a>
			</ul>
		</cfif>
		<br clear="all">
		<div id="tabcontent">
			#view('air/#rc.sDetails#')#
		</div>
	</div>
</cfoutput>