<cfparam name="variables.minheight" default="100"/>

<cfsavecontent variable="sBadge" trim="#true#">
	<cfoutput>
		<div class="badge">
			<table height="#variables.minheight#" width="100%">
			<tr>
				<td colspan="2" align="center">
					#(NOT bSelected ? '' : '<span class="medium green bold">SELECTED</span><br>')#

					#(NOT bDisplayFare OR NOT stTrip.PrivateFare ? '' : '<span class="medium blue bold">CONTRACTED</span><br>')#
					<!---  <cfset sImg = (ListLen(stTrip.Carriers) EQ 1 ? stTrip.Carriers : 'Mult')><cfif sImg NEQ 'Mult'>title="#application.stAirVendors[sImg].Name#"<cfelse>title="Multiple Carriers"</cfif> --->
					<img class="carrierimg" src="assets/img/airlines/#(ArrayLen(stTrip.Carriers) EQ 1 ? stTrip.Carriers[1] : 'Mult')#.png">
					#(ArrayLen(stTrip.Carriers) EQ 1 ? '<br>'&application.stAirVendors[stTrip.Carriers[1]].Name : '')#
					#(NOT stTrip.Preferred ? '' : '<span class="medium blue bold">PREFERRED</span><br>')#
				</td>
				<td colspan="2" class="fares" align="right">
					<cfif bDisplayFare>
						#(stTrip.Policy ? '' : '<span rel="tooltip" class="outofpolicy" title="#ArrayToList(stTrip.aPolicies)#">OUT OF POLICY</span><br>')#
						#(stTrip.Class EQ 'Y' ? 'ECONOMY' : (stTrip.Class EQ 'C' ? 'BUSINESS' : 'FIRST'))#<br>
						<input type="submit" class="button#stTrip.Policy#policy" value="$#NumberFormat(stTrip.Total)#" onClick="submitLowFare(#nTripKey#);">
						#(stTrip.Ref EQ 0 ? 'NO REFUNDS' : 'REFUNDABLE')#
					<cfelse>
						<input type="submit" class="button#stTrip.Policy#policy" value="Select" onClick="submitAvailability(#nTripKey#);">
					</cfif>
				</td>
			</tr>
			<cfloop collection="#stTrip.Groups#" item="Group" >
				<cfset stGroup = stTrip.Groups[Group]>
				<tr>
					<td> </td>
					<td title="#application.stAirports[stGroup.Origin]#">
						<strong>#stGroup.Origin#</strong>
					</td>
					<td> </td>
					<td title="#application.stAirports[stGroup.Destination]#">
													<strong>#stGroup.Destination#</strong>
					</td>
				</tr>
				<tr>
					<td>
						<strong>#DateFormat(stGroup.DepartureTime, 'ddd')#</strong>
					</td>
					<td>
						<strong>#TimeFormat(stGroup.DepartureTime, 'h:mmt')#</strong>
					</td>
					<td>
						-
					</td>
					<td>
						<strong>#TimeFormat(stGroup.ArrivalTime, 'h:mmt')#</strong>
					</td>
				</tr>
				<cfset nCnt = 0>
				<cfloop collection="#stGroup.Segments#" item="nSegment" >
					<cfset nCnt++>
					<cfset stSegment = stGroup.Segments[nSegment]>
					<tr>
						<td valign="top" title="#application.stAirVendors[stSegment.Carrier].Name# Flt ###stSegment.FlightNumber#">#stSegment.Carrier##stSegment.FlightNumber#</td>
						<td valign="top">#(bDisplayFare ? stSegment.Cabin : '')#</td>
						<td valign="top" title="#application.stAirports[stSegment.Destination]#">#(nCnt EQ 1 ? 'to <span>#stSegment.Destination#' : '')#</span><!---  ---></td>
						<td valign="top">
							<cfif nCnt EQ 1>
								#stGroup.TravelTime#
								<cfset nFirstSeg = nSegment>
							</cfif>
						</td>
					</tr>
				</cfloop>
			</cfloop>
			<tr>
				<td height="100%" valign="bottom" colspan="4">
					<cfset sURL = 'SearchID=#rc.SearchID#&nTripID=#nTripKey#&Group=#nDisplayGroup#'>
					<a href="?action=air.popup&sDetails=details&#sURL#" class="overlayTrigger">Details <span class="divider">/</span></a>
					<cfif NOT ArrayFind(stTrip.Carriers, 'WN') AND NOT ArrayFind(stTrip.Carriers, 'FL')>
						<a href="?action=air.popup&sDetails=seatmap&#sURL#" class="overlayTrigger" target="_blank">Seats <span class="divider">/</span></a>
					</cfif>
					<a href="?action=air.popup&sDetails=baggage&#sURL#" class="overlayTrigger">Bags <span class="divider">/</span></a>
					<a href="?action=air.popup&sDetails=email&#sURL#" class="overlayTrigger">Email</a>
					<cfif bDisplayFare>
						<ul class="smallnav">
							<li class="main">+
								<ul>
									<li><a href="?action=air.price&SearchID=#rc.SearchID#&nTrip=#nTripKey#&sCabin=Y&bRefundable=0">Economy Class - Non Refundable</a></li>
									<li><a href="?action=air.price&SearchID=#rc.SearchID#&nTrip=#nTripKey#&sCabin=Y&bRefundable=1">Economy Class - Refundable</a></li>
									<li><a href="?action=air.price&SearchID=#rc.SearchID#&nTrip=#nTripKey#&sCabin=C&bRefundable=0">Business Class - Non Refundable</a></li>
									<li><a href="?action=air.price&SearchID=#rc.SearchID#&nTrip=#nTripKey#&sCabin=C&bRefundable=1">Business Class - Refundable</a></li>
									<li><a href="?action=air.price&SearchID=#rc.SearchID#&nTrip=#nTripKey#&sCabin=F&bRefundable=0">First Class - Non Refundable</a></li>
								</ul>
							</li>
						</ul>
					</cfif>
				</td>
							</tr>
							</table>
		</div>
	</cfoutput>
</cfsavecontent>
<cfoutput>
	<div id="flight#nTripKey#" style="min-height:#variables.minheight#px;float:left;">
		#sBadge#
	</div>
</cfoutput>