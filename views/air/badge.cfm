<cfset nOverallStart = getTickCount('nano')>
<cfoutput>
	<cfset sCacheFileName = '/cache/'&rc.nSearchID&'/'&Hash(stTrip.toString())&'.html'>
	<cfset nOverallStart = getTickCount('nano') - nOverallStart>
	<cfif NOT directoryExists('/cache/'&rc.nSearchID)>
		<cfdirectory action="create" directory="/cache/#rc.nSearchID#">
	</cfif>
</cfoutput>

<cfif NOT fileExists(sCacheFileName)>
	<cfsavecontent variable="sBadge" trim="#true#">
		<cfoutput>
			<div class="badge">
				<table width="100%">
				<tr>
					<td colspan="2" align="center">
						#(NOT bSelected ? '' : '<span class="medium green bold">SELECTED</span><br>')#
						#(NOT stTrip.Preferred ? '' : '<span class="medium blue bold">PREFERRED</span><br>')#
						#(NOT bDisplayFare OR NOT stTrip.PrivateFare ? '' : '<span class="medium blue bold">CONTRACTED</span><br>')#
						<!---  <cfset sImg = (ListLen(stTrip.Carriers) EQ 1 ? stTrip.Carriers : 'Mult')><cfif sImg NEQ 'Mult'>title="#application.stAirVendors[sImg].Name#"<cfelse>title="Multiple Carriers"</cfif> --->
						<img class="carrierimg" src="assets/img/airlines/#(ArrayLen(stTrip.Carriers) EQ 1 ? stTrip.Carriers[1] : 'Mult')#.png">
						#(ArrayLen(stTrip.Carriers) EQ 1 ? '<br>'&application.stAirVendors[stTrip.Carriers[1]].Name : '')#
					</td>
					<td colspan="2" class="fares" align="right">
						<cfif bDisplayFare>
							#(stTrip.Policy ? '' : '<span class="red bold" title="#ArrayToList(stTrip.aPolicies)#">OUT OF POLICY</span><br>')#
							#(stTrip.Class EQ 'Y' ? 'ECONOMY' : (stTrip.Class EQ 'C' ? 'BUSINESS' : 'FIRST'))#<br>
							<input type="submit" class="button#stTrip.Policy#policy" value="$#NumberFormat(stTrip.Total)#" onClick="submitLowFare(#nTripKey#);">
							<span class="fade">#(stTrip.Ref EQ 0 ? 'NO REFUNDS' : 'REFUNDABLE')#</span>
						<cfelse>
							<input type="submit" class="button#stTrip.Policy#policy" value="Select" onClick="submitAvailability(#nTripKey#);">
						</cfif>
					</td>
				</tr>
				<cfloop collection="#stTrip.Groups#" item="nGroup" >
					<cfset stGroup = stTrip.Groups[nGroup]>
					<tr>
						<td colspan="4">&nbsp;</td>
					</tr>
					<tr>
						<td> </td>
						<td class="fade medium upper" title="#application.stAirports[stGroup.Origin]#">
							<strong>#stGroup.Origin#</strong>
						</td>
						<td> </td>
						<td class="fade right medium upper" title="#application.stAirports[stGroup.Destination]#">
							<strong>#stGroup.Destination#</strong>
						</td>
					</tr>
					<tr>
						<td class="bold medium upper">
							<strong>#DateFormat(stGroup.DepartureTime, 'ddd')#</strong>
						</td>
						<td class="bold medium upper">
							<strong>#TimeFormat(stGroup.DepartureTime, 'h:mmt')#</strong>
						</td>
						<td class="bold large center">
							-
						</td>
						<td class="bold right medium upper">
							<strong>#TimeFormat(stGroup.ArrivalTime, 'h:mmt')#</strong>
						</td>
					</tr>
					<cfset nCnt = 0>
					<cfloop collection="#stGroup.Segments#" item="nSegment" >
						<cfset nCnt++>
						<cfset stSegment = stGroup.Segments[nSegment]>
						<tr>
							<td class="fade" valign="top" title="#application.stAirVendors[stSegment.Carrier].Name# Flt ###stSegment.FlightNumber#">#stSegment.Carrier##stSegment.FlightNumber#</td>
							<td class="fade" valign="top">#(bDisplayFare ? stSegment.Cabin : '')#</td>
							<td class="right fade" valign="top" title="#application.stAirports[stSegment.Destination]#">#(nCnt EQ 1 ? 'to <span>#stSegment.Destination#' : '')#</span><!---  ---></td>
							<td class="right fade" valign="top">
								<cfif nCnt EQ 1>
									#stGroup.TravelTime#
									<cfset nFirstSeg = nSegment>
								</cfif>
							</td>
						</tr>
					</cfloop>
				</cfloop>
				</table>
				<br><br>
				<cfset sURL = 'Search_ID=#rc.nSearchID#&nTripID=#nTripKey#&nGroup=#nDisplayGroup#'>
				<a href="?action=air.popup&sDetails=details&#sURL#" class="overlayTrigger"><button type="button" class="textButton">Details</button>|</a>
				<cfif NOT ArrayFind(stTrip.Carriers, 'WN') AND NOT ArrayFind(stTrip.Carriers, 'FL')>
					<a href="?action=air.popup&sDetails=seatmap&#sURL#" class="overlayTrigger" target="_blank"><button type="button" class="textButton">Seats</button>|</a>
				</cfif>
				<a href="?action=air.popup&sDetails=baggage&#sURL#" class="overlayTrigger"><button type="button" class="textButton">Bags</button>|</a>
				<a href="?action=air.popup&sDetails=email&#sURL#" class="overlayTrigger"><button type="button" class="textButton">Email</button></a>
				<cfif bDisplayFare>
					<ul class="smallnav">
						<li class="main">+
							<ul>
								<li><a href="?action=air.price&Search_ID=#rc.nSearchID#&nTrip=#nTripKey#&sCabin=Y&bRefundable=0">Economy Class - Non Refundable</a></li>							
								<li><a href="?action=air.price&Search_ID=#rc.nSearchID#&nTrip=#nTripKey#&sCabin=Y&bRefundable=1">Economy Class - Refundable</a></li>							
								<li><a href="?action=air.price&Search_ID=#rc.nSearchID#&nTrip=#nTripKey#&sCabin=C&bRefundable=0">Business Class - Non Refundable</a></li>							
								<li><a href="?action=air.price&Search_ID=#rc.nSearchID#&nTrip=#nTripKey#&sCabin=C&bRefundable=1">Business Class - Refundable</a></li>							
								<li><a href="?action=air.price&Search_ID=#rc.nSearchID#&nTrip=#nTripKey#&sCabin=F&bRefundable=0">First Class - Non Refundable</a></li>							
							</ul>
						</li>
					</ul>
				</cfif>
			</div>
		</cfoutput>
	</cfsavecontent>
	<cfset fileWrite(sCacheFileName, sBadge)>
<cfelseif nCount LTE 5>
	<cfset sBadge = fileRead(sCacheFileName)>
</cfif>
<cfoutput>
	<cfif nCount GT 5>
		<div id="#nTripKey#" style="min-height:#variables.minheight#px;float:left;">
		</div>
		<script type="text/javascript">
		$("###nTripKey#").load("#sCacheFileName#");
		</script>
	<cfelse>
		<div id="#nTripKey#" style="min-height:#variables.minheight#px;float:left;">
			#sBadge#
		</div>
	</cfif>
</cfoutput>