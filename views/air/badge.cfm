<cfparam name="variables.minheight" default="250"/>
<cfset ribbonClass = "">
<cfset carrierList = "">

<cfsavecontent variable="sBadge" trim="#true#">

			<!--- create ribbon --->
			<cfif bDisplayFare AND stTrip.PrivateFare AND stTrip.preferred EQ 1>
				<cfset ribbonClass = "ribbon-l-pref-cont">
			<cfelseif stTrip.preferred EQ 1>
				<cfset ribbonClass = "ribbon-l-pref">
			<cfelseif bDisplayFare AND stTrip.PrivateFare>
				<cfset ribbonClass = "ribbon-l-cont">
			</cfif>

			<!--- finally add default 'ribbon' class --->
			<cfif Len(ribbonClass)>
				<cfset ribbonClass = "ribbon " & ribbonClass>
			</cfif>

	<cfif len(rc.Group) AND structKeyExists(session.searches[rc.SearchID].stSelected[rc.Group], "sJavaScript")>
		<cfset bSelected = false />
		<cfset thisSelectedLeg = replace(listFirst(session.searches[rc.SearchID].stSelected[rc.Group].sJavaScript), """", "", "all") />
		<cfif nTripKey EQ thisSelectedLeg>
			<cfset bSelected = true />
		</cfif>
	</cfif>

	<cfoutput>
		<div class="badge">
			<!--- display ribbon --->
			<span class="#ribbonclass#"></span>

			<!--- TODO: uncomment for debugging
			<cfif IsLocalHost(cgi.local_addr)>
						<p align="center">DEBUGGING: #nTripKey# | Policy: #stTrip.Policy# | #ncount# [ #stTrip.preferred# | #bDisplayFare# | <cfif structKeyExists(stTrip,"privateFare")>#stTrip.PrivateFare#</cfif> ] </p>
			</cfif>
			--->

			<table height="#variables.minheight#" width="100%" border="0">
			<tr align="center">
				<td width="50%" colspan="2">
					<img class="carrierimg" src="assets/img/airlines/#(ArrayLen(stTrip.Carriers) EQ 1 ? stTrip.Carriers[1] : 'Mult')#.png">
					<strong>#(ArrayLen(stTrip.Carriers) EQ 1 ? '<br />'&application.stAirVendors[stTrip.Carriers[1]].Name : '<br />Multiple Carriers')#</strong><br>
				</td>
				<td colspan="2">
					<cfset btnClass = "">
					<cfif bDisplayFare>
						#(stTrip.Class EQ 'Y' ? 'ECONOMY' : (stTrip.Class EQ 'C' ? 'BUSINESS' : 'FIRST'))#
						<br>
						<cfif stTrip.policy EQ 1>
							<cfset btnClass = "btn-primary">
						</cfif>
						<input type="submit" class="btn #btnClass# btnmargin" value="$#NumberFormat(stTrip.Total)#" onClick="submitLowFare(#nTripKey#);">
						<br>
						<span rel="popover" class="popuplink" data-original-title="Flight Change / Cancellation Policy" data-content="Ticket is #(stTrip.Ref ? '' : 'non-')#refundable.<br>Change USD #stTrip.changePenalty# for reissue." href="##" />
							#(stTrip.Ref EQ 0 ? 'NO REFUNDS' : 'REFUNDABLE')#</span>
					<cfelse>
						<input type="submit" class="btn btn-primary btnmargin" value="Select" onClick="submitAvailability(#nTripKey#);">
					</cfif>
				</td>
			</tr>
			<cfif bSelected OR !stTrip.Policy>
				<tr align="center">
					<td colspan="2">#(NOT bSelected ? '' : '<span class="medium green bold">SELECTED</span>')#</td>
					<td colspan="2">#(stTrip.Policy ? '' : '<span rel="tooltip" class="popuplink" title="#Replace(ArrayToList(stTrip.aPolicies), ",", ", ")#">OUT OF POLICY</span>')#</td>
				</tr>
			</cfif>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<cfloop collection="#stTrip.Groups#" item="Group" >
				<cfset stGroup = stTrip.Groups[Group]>
				<tr>
					<td>&nbsp;</td>
					<td title="#application.stAirports[stGroup.Origin].airport#">
						<strong>#stGroup.Origin#</strong>
					</td>
					<td>&nbsp;</td>
					<td title="#application.stAirports[stGroup.Destination].airport#">
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
					<cfif NOT listFind(carrierList, stSegment.Carrier)>
						<cfset carrierList = ListAppend(carrierList, stSegment.Carrier)>
					</cfif>

					<tr>
						<td valign="top" title="#application.stAirVendors[stSegment.Carrier].Name# Flt ###stSegment.FlightNumber#">#stSegment.Carrier##stSegment.FlightNumber#</td>
						<td valign="top">#(bDisplayFare ? stSegment.Cabin : '')#</td>
						<td valign="top" title="#application.stAirports[stSegment.Destination].airport#">#(nCnt EQ 1 ? 'to <span>#stSegment.Destination#</span>' : '')#</td>
						<td valign="top">
							<cfif nCnt EQ 1>
								#stGroup.TravelTime#
								<cfset nFirstSeg = nSegment>
							</cfif>
						</td>
					</tr>
				</cfloop>
				<tr>
					<td colspan="4">&nbsp;</td>
				</tr>
			</cfloop>

			<!--- set bag fee into var so we can display in a tooltip below --->
			<cfsavecontent variable="tooltip">
				<cfloop list="#carrierList#" index="carrier">
					#application.stAirVendors[Carrier].Name#:&nbsp;<span class='pull-right'><i class='icon-suitcase'></i> = $#application.stAirVendors[Carrier].Bag1#&nbsp;&nbsp;<i class='icon-suitcase'></i>&nbsp;<i class='icon-suitcase'></i> = $#application.stAirVendors[Carrier].Bag2#</span><br>
				</cfloop>
			</cfsavecontent>

			<tr>
				<td height="100%" valign="bottom" align="center" colspan="4">
					<cfset sURL = 'SearchID=#rc.SearchID#&nTripID=#nTripKey#&Group=#nDisplayGroup#'>
					<a href="?action=air.popup&sDetails=details&#sURL#" class="popupModal" data-toggle="modal" data-target="##popupModal">
						Details 
						<span class="divider">/</span>
					</a>
					<cfif NOT ArrayFind(stTrip.Carriers, 'WN') AND NOT ArrayFind(stTrip.Carriers, 'FL')>
						<a href="?action=air.popup&sDetails=seatmap&#sURL#" class="popupModal" data-toggle="modal" data-target="##popupModal">
							Seats 
							<span class="divider">/</span>
						</a>
					</cfif>
					<a href="?action=air.popup&sDetails=baggage&#sURL#" class="popupModal" data-toggle="modal" data-target="##popupModal" rel="poptop" data-placement="top" data-content="#tooltip#" data-original-title="Baggage Fees">
						Bags 
						<span class="divider">/</span>
					</a>
					<a href="?action=air.popup&sDetails=email&#sURL#" class="popupModal" data-toggle="modal" data-target="##popupModal">
						Email
						<span class="divider">/</span>
					</a>
					 <a href="?action=findit.send&SearchID=#rc.searchID#&nTripID=#nTripKey#" >FindIt</a>
				</td>
			</tr>

		</table>
		</div>
	</cfoutput>
</cfsavecontent>

<!--- display badge --->
<cfoutput>
	<div id="flight#nTripKey#" style="min-height:#variables.minheight#px;float:left;">#sBadge#</div>
</cfoutput>