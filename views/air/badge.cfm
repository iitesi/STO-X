<cfparam name="variables.minheight" default="50"/>
<cfset ribbonClass = "">
<cfset carrierList = "">
<cfset thisSelectedLeg = "">


	<cfsavecontent variable="sBadge" trim="#true#">
			<!--- create ribbon
			Note: Please do not display "CONTRACTED" flag on search results for Southwest.
			--->

			<cfif bDisplayFare AND stTrip.PrivateFare AND stTrip.preferred EQ 1>
				<cfif stTrip.Carriers[1] EQ "WN">
					<cfif structKeyExists(stTrip, "PTC") AND stTrip.PTC EQ "GST">
						<cfset ribbonClass = "ribbon-l-pref-govt">
					<cfelse>
						<cfset ribbonClass = "ribbon-l-pref">
					</cfif>
				<cfelse>
					<cfset ribbonClass = "ribbon-l-pref-cont">
				</cfif>
			<cfelseif stTrip.preferred EQ 1>
				<cfif structKeyExists(stTrip, "PTC") AND stTrip.PTC EQ "GST">
					<cfset ribbonClass = "ribbon-l-pref-govt">
				<cfelse>
					<cfset ribbonClass = "ribbon-l-pref">
				</cfif>
			<cfelseif bDisplayFare AND stTrip.PrivateFare AND stTrip.Carriers[1] NEQ "WN">
				<cfset ribbonClass = "ribbon-l-cont">
			<cfelseif bDisplayFare AND (structKeyExists(stTrip, "PTC") AND stTrip.PTC EQ "GST")>
				<cfset ribbonClass = "ribbon-l-govt">
			</cfif>

			<!--- finally add default 'ribbon' class --->
			<cfif Len(ribbonClass)>
				<cfset ribbonClass = "ribbon " & ribbonClass>
			</cfif>

			<cfif len(rc.Group) AND structKeyExists(session.searches[rc.SearchID].stSelected[rc.Group], "nTripKey")>
				<cfset bSelected = false />
				<cfset thisSelectedLeg = session.searches[rc.SearchID].stSelected[rc.Group].nTripKey />
				<cfif nTripKey EQ thisSelectedLeg>
					<cfset bSelected = true />
				</cfif>
			</cfif>

	<cfoutput>
		<div class="screenbadge badge">
			<!--- display ribbon --->
			<span class="#ribbonclass#"></span>

			<!--- TODO: uncomment for debugging - this will display on each badge!
			<cfif IsLocalHost(cgi.local_addr)>
						<p align="center">DEBUGGING: #nTripKey# | Policy: #stTrip.Policy# | #ncount# [ #stTrip.preferred# | #bDisplayFare# | <cfif structKeyExists(stTrip,"privateFare")>#stTrip.PrivateFare#</cfif> ] </p>
			</cfif>
			--->

			<cfset flightnumbers = ''>
			<cfloop collection="#stTrip.Groups#" item="Group" >
				<cfset stGroup = stTrip.Groups[Group]>
				<cfloop collection="#stGroup.Segments#" item="nSegment" >
					<cfset stSegment = stGroup.Segments[nSegment]>
					<cfset flightnumbers = listAppend(flightnumbers, stGroup.Segments[nSegment].flightNumber)>
				</cfloop>
			</cfloop>

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
						<cfif bSelected>
							<cfset btnClass = "btn-success">
						</cfif>

						<input type="submit" class="btn #btnClass# btnmargin" value="$#NumberFormat(stTrip.Total)#" onClick="submitLowFare(#nTripKey#);" title="Click to purchase!">
						<br><span rel="popover" class="popuplink" data-original-title="Flight Change / Cancellation Policy" data-content="Ticket is #(stTrip.Ref ? '' : 'non-')#refundable.<br>Change USD #stTrip.changePenalty# for reissue." href="##" />
							#(stTrip.Ref EQ 0 ? 'NO REFUNDS' : 'REFUNDABLE')#</span>
						<cfif arrayFind( structKeyArray(rc.Filter.getUnusedTicketCarriers()), stTrip.platingCarrier )>
							<br><span rel="popover" class="popuplink" style="width:1000px" data-original-title="UNUSED TICKETS - #application.stAirVendors[stTrip.platingCarrier].Name#" data-content="#rc.Filter.getUnusedTicketCarriers()[stTrip.platingCarrier]#" data-viewport="width:700px;" href="##" />UNUSED TKT AVAIL</span>
						</cfif>
					<cfelse>
						<input type="submit" class="btn btn-primary btnmargin" value="Select" onClick="submitAvailability(#nTripKey#);" title="Click to select this flight.">
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
				<td colspan="4">&nbsp;
					<font color="white">#flightnumbers#</font>
				</td>
			</tr>
			<cfloop collection="#stTrip.Groups#" item="Group">
				<cfset stGroup = stTrip.Groups[Group]>

				<!--- set times for badges, and get total times so we can set time sliders in filter --->
				<cfset departureTime = TimeFormat(stGroup.DepartureTime, 'HH:mm')>
				<cfset departureTime = (hour(departureTime)*60) + (minute(departureTime))>
				<cfset arrivalTime = TimeFormat(stGroup.ArrivalTime, 'HH:mm')>
				<cfset arrivalTime = (hour(arrivalTime)*60) + (minute(arrivalTime))>
				<cfset "timeFilter.departureTime#group#" = departureTime>
				<cfset "timeFilter.arrivalTime#group#" = arrivalTime>

				<!--- 4:40 PM Wednesday, December 04, 2013 - Jim Priest - jpriest@shortstravel.com
				STM-2544 need to create a container of min/max times so we can use to set filters
				See code in lowfare.cfm

				<cfset arrayAppend(timeFilterTotal, departureTime)>
				<cfset arrayAppend(timeFilterTotal, arrivalTime)> --->


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
					<td width="50">	-	</td>
					<cfset tripLength = rc.airhelpers.getTripDays(stGroup.DepartureTime, stGroup.ArrivalTime)>
					<td>
						<strong>#TimeFormat(stGroup.ArrivalTime, 'h:mmt')# #tripLength#</strong>
					</td>
				</tr>
				<cfset nCnt = 0>
				<cfset segmentCount = arrayLen(structKeyArray(stGroup.Segments))>
				<cfloop collection="#stGroup.Segments#" item="nSegment" >
					<cfset nCnt++>
					<cfset stSegment = stGroup.Segments[nSegment]>
					<cfif NOT listFind(carrierList, stSegment.Carrier)>
						<cfset carrierList = ListAppend(carrierList, stSegment.Carrier)>
					</cfif>
					<tr>
						<td valign="top" title="#application.stAirVendors[stSegment.Carrier].Name# Flt ###stSegment.FlightNumber#">#stSegment.Carrier##stSegment.FlightNumber#</td>
						<td valign="top">#(bDisplayFare ? stSegment.Cabin : '')#
										<font color="white">(#(bDisplayFare ? stSegment.Class : '')#)</font>
										</td>
						<td valign="top" title="#application.stAirports[stSegment.Destination].airport#">#(nCnt EQ 1 AND segmentCount NEQ 1 ? 'to <span>#stSegment.Destination#</span>' : '')#</td>
						<td valign="top">
							<cfif nCnt EQ 1>
								#stGroup.TravelTime#
								<cfset nFirstSeg = nSegment>
								<cfset sClass = stSegment.Class />
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
						<a href="?action=air.popup&sDetails=seatmap&#sURL#&sClass=#sClass#" class="popupModal" data-toggle="modal" data-target="##popupModal">
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
					</a>
					<cfif (application.es.getCurrentEnvironment() NEQ 'prod'
						AND application.es.getCurrentEnvironment() NEQ 'beta')
						OR listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID())>
						<span class="divider">/</span>
						<a href="?action=findit.send&SearchID=#rc.searchID#&nTripID=#nTripKey#">FindIt</a>
					</cfif>
				</td>
			</tr>
		</table>
		</div>

		<!--- printer friendly badge - this is hidden via CSS --->
		<div class="printbadge">
			<table width="600" border="0" id="printschedule" <cfif #nCount# MOD 2>class="back"</cfif>>
			<tr>
				<td align="center" width="125">
					<img class="carrierimg" src="assets/img/airlines/#(ArrayLen(stTrip.Carriers) EQ 1 ? stTrip.Carriers[1] : 'Mult')#.png">
					<br><strong>#(ArrayLen(stTrip.Carriers) EQ 1 ? '<br />'&application.stAirVendors[stTrip.Carriers[1]].Name : '<br />Multiple Carriers')#</strong>
				</td>
				<td>
					<table width="350" cellpadding="0" cellspacing="0" border="0">
						<cfloop collection="#stTrip.Groups#" item="Group">
							<cfset stGroup = stTrip.Groups[Group]>
							<tr class="topborder">
								<td width="100">&nbsp;</td>
								<td width="100" class="legtext"><strong>#stGroup.Origin#</strong></td>
								<td width="100">&nbsp;</td>
								<td width="100" class="legtext"><strong>#stGroup.Destination#</strong></td>
							</tr>
							<tr>
								<td class="flighttext"><strong>#DateFormat(stGroup.DepartureTime, 'ddd')#</strong></td>
								<td class="flighttext">#TimeFormat(stGroup.DepartureTime, 'h:mmt')#</td>
								<td class="flighttext">	-	</td>
								<td class="flighttext">#TimeFormat(stGroup.ArrivalTime, 'h:mmt')#</td>
							</tr>
							<cfset nCnt = 0>
							<cfset segmentCount = arrayLen(structKeyArray(stGroup.Segments))>
							<cfloop collection="#stGroup.Segments#" item="nSegment" >
								<cfset nCnt++>
								<cfset stSegment = stGroup.Segments[nSegment]>
								<tr>
									<td valign="top"class="flighttext">#stSegment.Carrier##stSegment.FlightNumber#</td>
									<td valign="top"class="flighttext">#(bDisplayFare ? stSegment.Cabin : '')#</td>
									<td valign="top"class="flighttext" nowrap>#(nCnt EQ 1 AND segmentCount NEQ 1 ? 'to <span>#stSegment.Destination#</span>' : '')#</td>
									<td valign="top"class="flighttext">
										<cfif nCnt EQ 1>
											#stGroup.TravelTime#
											<cfset nFirstSeg = nSegment>
										</cfif>
									</td>
								</tr>
							</cfloop>
						</cfloop>
					</table>
				</td>
				<td align="center" width="125">
						<cfif StructKeyExists(stTrip, "total")>
							<strong class="largetext">$#NumberFormat(stTrip.Total)#</strong><br>
						</cfif>
						<span class="smalltext">
						#(stTrip.Class EQ 'Y' ? 'ECONOMY' : (stTrip.Class EQ 'C' ? 'BUSINESS' : 'FIRST'))#<br>
						#(stTrip.Ref EQ 0 ? 'NO REFUNDS' : 'REFUNDABLE')#<br>
						#(stTrip.Policy ? '' : 'OUT OF POLICY<br>')#

						<cfif bDisplayFare AND stTrip.PrivateFare AND stTrip.preferred EQ 1>
							<cfif stTrip.Carriers[1] EQ "WN">
								PREFERRED<br>
							<cfelse>
								PREFERRED / CONTRACTED<br>
							</cfif>
						<cfelseif stTrip.preferred EQ 1>
								PREFERRED<br>
						<cfelseif bDisplayFare AND stTrip.PrivateFare AND stTrip.Carriers[1] NEQ "WN">
								CONTRACTED<br>
						</cfif>
						</span>
				</td>
			</tr>
			</table>
		</div>

	</cfoutput>
</cfsavecontent>


<!--- set unique data-attributes for each badge for filtering by time --->
<cfset dataString = "">
<cfloop collection="#timeFilter#" item="timeFilterItem" index="timeFilterIndex">
	<cfset dataString = listAppend(dataString, "data-" & timeFilterIndex & '="#timeFilterItem#"', ' ')>
</cfloop>

<!--- display badge --->
<cfoutput>
	<div id="flight#nTripKey#" #dataString# class="pull-left">#sBadge#</div>
</cfoutput>