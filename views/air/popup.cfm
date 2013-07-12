<cfsilent>
	<cfparam name="rc.bSelection" default="0">
</cfsilent>

<cfoutput>
    <ul class="nav nav-tabs">
	    <li class="active"><a href="##home" data-toggle="tab">Details</a></li>
	    <li><a href="##profile" data-toggle="tab">Seat Map</a></li>
	    <li><a href="##messages" data-toggle="tab">Bags</a></li>
	    <li><a href="##settings" data-toggle="tab">Email</a></li>
    </ul>
		<div class="tab-content">
			<div class="tab-pane active" id="home">#view('air/details')#</div>
			<div class="tab-pane" id="profile">#view('air/seatmap')# </div>
			<div class="tab-pane" id="messages">#view('air/baggage')# </div>
			<div class="tab-pane" id="settings">#view('air/email')# </div>
		</div>


	<!--- <div>
		<cfif rc.bSelection EQ 0>
			<ul id="details-tabs">
				<cfset sURL = 'SearchID=#rc.SearchID#&nTripID=#rc.nTripID#&Group=#Group#'>
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
	</div> --->
</cfoutput>