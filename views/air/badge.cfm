<!---
NEED:
	variables.aRef
	variables.aMyCabins
	variables.sTrip
	variables.stTrips
--->
<cfoutput>
	<div id="#variables.sTrip#" class="badge" style="min-height:#variables.minwidth#px;"><!--- #variables.id# --->
		<table width="100%">
		<tr>
			<td width="125px" align="center">
				<cfif stTrip.Preferred>
					<span class="medium blue bold">PREFERRED</span><br>
				</cfif>
				<cfif rc.action EQ 'air.lowfare' AND stTrip.PrivateFare>
					<span class="medium blue bold">CONTRACTED</span><br>
				</cfif>
				<cfif StructKeyExists(session.searches[rc.nSearchID].stLowFareDetails.stPriced, variables.sTrip)>
					<span class="medium blue bold">SELECTED</span><br>
				</cfif>
				<cfset sImg = (ListLen(stTrip.Carriers) EQ 1 ? stTrip.Carriers : 'Mult')>
				<img class="carrierimg" src="https://www.shortstravelonline.com/book/assets/img/airlines/#sImg#.png" <cfif sImg NEQ 'Mult'>title="#application.stAirVendors[sImg].Name#"<cfelse>title="Multiple Carriers"</cfif>>
				#(ListLen(stTrip.Carriers) EQ 1 ? '<br>'&application.stAirVendors[stTrip.Carriers].Name : '')#
			</td>
			<td class="fares" align="right">
				<cfif rc.action EQ 'air.lowfare'>
					#(stTrip.Class EQ 'Y' ? 'ECONOMY' : (stTrip.Class EQ 'C' ? 'BUSINESS' : 'FIRST'))# CLASS
					<input type="submit" name="trigger" class="button1policy" value="$#NumberFormat(stTrip.Total)#">
					<span class="fade">#(stTrip.Ref EQ 0 ? 'NO REFUNDS' : 'REFUNDABLE')#</span> 
				<cfelse>
					<form method="post" action="#buildURL('air.availability')#">
						<input type="hidden" name="bSelect" value="1"><!--- Flag to trigger the 'select' code --->
						<input type="hidden" name="Search_ID" value="#rc.nSearchID#">
						<input type="hidden" name="nTrip" value="#variables.sTrip#">
						<input type="hidden" name="Group" value="#rc.nGroup#">
						<input type="submit" class="button1policy" value="Select">
					</form>
				</cfif>
			</td>
		</tr>
		<cfloop collection="#stTrip.Groups#" item="nGroup" >
			<tr>
				<td colspan="2" align="center">
					<br>
					<cfset stGroup = stTrip.Groups[nGroup]>
					<table width="90%">
					<tr>
						<td width="25%">
						</td>
						<td class="fade medium" width="30%" title="#application.stAirports[stGroup.Origin]#">
							<strong>#stGroup.Origin#</strong>
						</td>
						<td width="20%">
						</td>
						<td class="fade right medium" width="25%" title="#application.stAirports[stGroup.Destination]#">
							<strong>#stGroup.Destination#</strong>
						</td>
					</tr>
					<tr>
						<td class="bold medium">
							<strong>#DateFormat(stGroup.DepartureTime, 'ddd')#</strong>
						</td>
						<td class="bold medium">
							<strong>#TimeFormat(stGroup.DepartureTime, 'h:mmt')#</strong>
						</td>
						<td class="bold large center">
							-
						</td>
						<td class="bold right medium">
							<strong>#TimeFormat(stGroup.ArrivalTime, 'h:mmt')#</strong>
						</td>
					</tr>
					<cfset nCnt = 0>
					<cfset aKeys = structKeyArray(stTrip.Segments)>
					<cfloop collection="#stTrip.Segments#" item="nSegment" >
						<cfif stTrip.Segments[nSegment].Group EQ nGroup>
							<cfset nCnt++>
							<tr>
								<td class="fade" valign="top" title="#application.stAirVendors[stTrip.Segments[nSegment].Carrier].Name# Flt ###stTrip.Segments[nSegment].FlightNumber#">
									#stTrip.Segments[nSegment].Carrier##stTrip.Segments[nSegment].FlightNumber#
								</td>
								<td class="fade" valign="top">
									<cfif rc.action EQ 'air.lowfare'>
										#stTrip.Segments[nSegment].Cabin#
									</cfif>
								</td>
								<td class="right fade" valign="top">
									<cfif nCnt EQ 1
									AND stTrip.Segments[aKeys[nCnt+1]].Group EQ nGroup>
										to <span title="#application.stAirports[stTrip.Segments[nSegment].Destination]#">#stTrip.Segments[nSegment].Destination#</span>
									</cfif>
								</td>
								<td class="right fade" valign="top">
									<cfif nCnt EQ 1>
										#stGroup.TravelTime#
										<cfset nFirstSeg = nSegment>
									</cfif>
								</td>
							</tr>
						</cfif>
					</cfloop>
					</table>
				</td>
			</tr>
		</cfloop>
		</table>
		<br><br>
		<p>
			<a href="#buildURL('air.details?Search_ID=#rc.nSearchID#&bSuppress=1&nTripID=#sTrip##(rc.action EQ 'air.availability' ? "&nGroup=#rc.Group#" : "")#')#" class="overlayTrigger" style="text-decoration:none">
				<button type="button" class="textButton">Details</button>|
			</a>
			<a href="#buildURL('air.seatmap?Search_ID=#rc.nSearchID#&bSuppress=1&nTripID=#sTrip#&nSegment=#nFirstSeg##(rc.action EQ 'air.availability' ? "&nGroup=#rc.Group#" : "")#')#" class="overlayTrigger" style="text-decoration:none" target="_blank">
				<button type="button" class="textButton">Seats</button>|
			</a>
			<a href="#buildURL('air.baggage?Search_ID=#rc.nSearchID#&bSuppress=1&sCarriers=#stTrip.Carriers#')#" class="overlayTrigger" style="text-decoration:none">
				<button type="button" class="textButton">Bags</button>|
			</a>
			<a href="#buildURL('air.email?Search_ID=#rc.nSearchID#&bSuppress=1&nTripID=#sTrip#')#" class="overlayTrigger" style="text-decoration:none">
				<button type="button" class="textButton">Email</button>|
			</a>
			<cfif rc.action EQ 'air.lowfare'>
				<a href="#buildURL('air.details?Search_ID=#rc.nSearchID#&bSuppress=1&nTripID=#sTrip#')#" class="overlayTrigger" style="text-decoration:none">
					<button type="button" class="textButton">CouldYou?</button>
				</a>
			</cfif>
		</p>
		<cfif rc.action EQ 'air.lowfare'>
			<ul class="smallnav">
				<li class="main">+
					<ul>
						<cfloop list="Y,C,F" index="sClass">
							<cfloop list="0,1" index="bRef">
								<cfif stTrip.Class EQ sClass AND stTrip.Ref EQ bRef>
									<li>#(sClass EQ 'Y' ? 'Economay' : (sClass EQ 'C' ? 'Business' : 'First'))# Class - #(bRef EQ 0 ? 'Non' : '')# Refundable - $#NumberFormat(stTrip.Total)#</li>
								<cfelse>
									<li><a href="#buildURL('air.price?Search_ID=#rc.nSearchID#&nTrip=#sTrip#&sCabin=#sClass#&bRefundable=#bRef#')#">#(sClass EQ 'Y' ? 'Economay' : (sClass EQ 'C' ? 'Business' : 'First'))# Class - #(bRef EQ 0 ? 'Non' : '')# Refundable</a></li>
								</cfif>
							</cfloop>
						</cfloop>
					</ul>
				</li>
			</ul>
		</cfif>
	</div>
</cfoutput>