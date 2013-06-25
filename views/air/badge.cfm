<cfparam name="variables.minheight" default="100"/>

<cfset ribbonClass = "">

<cfsavecontent variable="sBadge" trim="#true#">
	<cfoutput>
		<div class="badge">
<<<<<<< Updated upstream

			<!--- display ribbon --->

			<!--- TODO - all this should be moved into contoller / service as 'getRibbon()'
			3:45 PM Monday, June 24, 2013 - Jim Priest - jpriest@shortstravel.com --->
			<cfif stTrip.preferred EQ 1>
				<cfset ribbonClass = "ribbon-l-pref">
			<cfelseif bDisplayFare AND stTrip.PrivateFare>
				<cfset ribbonClass = "ribbon-l-cont">
			<cfelseif bDisplayFare AND stTrip.PrivateFare AND stTrip.preferred EQ 1>
				<cfset ribbonClass = "ribbon-l-pref-cont">
			</cfif>

			<!--- finally add default 'ribbon class' --->
			<cfif Len(ribbonClass)>
				<cfset ribbonClass = "ribbon " & ribbonClass>
			</cfif>
			<!--- display ribbon --->
			<span class="#ribbonClass#"></span>
			<!--- // end ribbon --->

			<p align="center">DEBUGGING:  #ncount# [ #stTrip.preferred# | #bDisplayFare# | #stTrip.PrivateFare# ] </p>


=======
			<span class="ribbon ribbon-r-pref-govt"></span>

			<p align="center">DEBUGGING:  #ncount#</p>
>>>>>>> Stashed changes

			<table height="#variables.minheight#" width="100%">
			<tr>
				<td colspan="2" align="center">
					#(NOT bSelected ? '' : '<span class="medium green bold">SELECTED</span><br>')#
					<img class="carrierimg" src="assets/img/airlines/#(ArrayLen(stTrip.Carriers) EQ 1 ? stTrip.Carriers[1] : 'Mult')#.png">
					#(ArrayLen(stTrip.Carriers) EQ 1 ? '<br />'&application.stAirVendors[stTrip.Carriers[1]].Name : '<br />Multiple Carriers')#
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