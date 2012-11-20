<!---
NEED:
	variables.aRef
	variables.aMyCabins
	variables.sTrip
	variables.stTrips
--->
<cfoutput>
	<div id="#variables.sTrip#" class="badge" style="min-height:#variables.minwidth#px;">
		<table width="100%">
		<tr>
			<td width="125px" align="center">
				<cfloop collection="#variables.stTrip.Segments#" item="nSegment" >
					<cfif ArrayFind(application.stAccounts[session.Acct_ID].aPreferredAir, stTrip.Segments[nSegment].Carrier)>
						<span class="medium blue bold">PREFERRED</span><br>
						<cfbreak>
					</cfif>
				</cfloop>
				<img class="carrierimg" src="https://www.shortstravelonline.com/book/assets/img/airlines/#(ListLen(stTrip.Carriers) EQ 1 ? stTrip.Carriers : 'Mult')#.png">
				#(ListLen(stTrip.Carriers) EQ 1 ? '<br>'&application.stAirVendors[stTrip.Carriers].Name : '')#
			</td>
			<td class="fares" align="right">
				<cfif rc.action EQ 'air.lowfare'>
					<cfloop array="#aMyCabins#" index="sCabin">
						<cfloop array="#aRef#" index="sRef">
							<cfif StructKeyExists(stTrip, sCabin)
							AND StructKeyExists(stTrip[sCabin], sRef)>
								#(sCabin EQ 'Y' ? 'ECONOMY' : (sCabin EQ 'C' ? 'BUSINESS' : 'FIRST'))# CLASS
								<input type="submit" name="trigger" class="button#stTrip[sCabin][sRef].Policy#policy" value="$#NumberFormat(stTrip[sCabin][sRef].Total)#">
								<span class="fade">#(sRef EQ 0 ? 'NO REFUNDS' : 'REFUNDABLE')#</span> 
							</cfif>
						</cfloop>
					</cfloop>
				<cfelse>
					<input type="submit" name="trigger" class="button1policy" value="Select">
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
						<td class="fade medium" width="30%">
							<strong>#stGroup.Origin#</strong>
						</td>
						<td width="20%">
						</td>
						<td class="fade right medium" width="25%">
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
					<cfset cnt = 0>
					<cfloop collection="#stTrip.Segments#" item="nSegment" >
						<cfif stTrip.Segments[nSegment].Group EQ nGroup>
							<tr>
								<td class="fade" valign="top">
									#stTrip.Segments[nSegment].Carrier##stTrip.Segments[nSegment].FlightNumber#
								</td>
								<td class="fade" valign="top">
									Economy
								</td>
								<td class="right fade" valign="top">
									<cfif StructKeyExists(stTrip.Segments, nSegment+1)
									AND stTrip.Segments[nSegment+1].Group EQ nGroup>
										to #stTrip.Segments[nSegment].Destination#
									</cfif>
								</td>
								<td class="right fade" valign="top">
									<cfset cnt++>
									<cfif cnt EQ 1>
										#stGroup.TravelTime#
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
			<a href="#buildURL('air.details?Search_ID=#rc.nSearchID#&bSuppress=1&nTripID=#sTrip##(structKeyExists(rc, "Group") ? "&nGroup=#rc.Group#" : "")#')#" class="overlayTrigger" style="text-decoration:none">
				<button type="button" class="textButton">Details</button>|
			</a>
			<a href="#buildURL('air.seatmap?Search_ID=#rc.nSearchID#&bSuppress=1&nTripID=#sTrip#&nSegment=1#(structKeyExists(rc, "Group") ? "&nGroup=#rc.Group#" : "")#')#" class="overlayTrigger" style="text-decoration:none" target="_blank">
				<button type="button" class="textButton">Seats</button>|
			</a>
			<a href="#buildURL('air.baggage?Search_ID=#rc.nSearchID#&bSuppress=1&sCarriers=#stTrip.Carriers#')#" class="overlayTrigger" style="text-decoration:none">
				<button type="button" class="textButton">Bags</button>|
			</a>
			<a href="#buildURL('air.email?Search_ID=#rc.nSearchID#&bSuppress=1&nTripID=#sTrip#')#" class="overlayTrigger" style="text-decoration:none">
				<button type="button" class="textButton">Email</button>|
			</a>
			<a href="#buildURL('air.details?Search_ID=#rc.nSearchID#&bSuppress=1&nTripID=#sTrip#')#" class="overlayTrigger" style="text-decoration:none">
				<button type="button" class="textButton">CouldYou?</button>
			</a>
		</p>
	</div>
</cfoutput>