<!--- <cfdump var="#rc.Traveler[1]#"> --->
<cfoutput>
	<table width="100%">
		<tr>
			<td>
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td width="6%">
							<cfif rc.Air.privateFare AND rc.Air.preferred>
								<span class="ribbon ribbon-l-pref-cont"></span>
							<cfelseif rc.Air.preferred>
								<span class="ribbon ribbon-l-pref"></span>
							<cfelseif rc.Air.privateFare>
								<span class="ribbon ribbon-l-cont"></span>
							</cfif>
						</td>
						<td colspan="9">
							<h2>FLIGHT</h2>
						</td>
					</tr>
					<tr>
						<td rowspan="4"></td>
						<td rowspan="4" width="14%">
							<img class="carrierimg" src="assets/img/airlines/#(ArrayLen(rc.Air.Carriers) EQ 1 ? rc.Air.Carriers[1] : 'Mult')#.png"><br />
							<strong>#(ArrayLen(rc.Air.Carriers) EQ 1 ? '<br />'&application.stAirVendors[rc.Air.Carriers[1]].Name : '<br />Multiple Carriers')#</strong>
						</td>

						<cfloop collection="#rc.Air.Groups#" item="group" index="groupIndex" >
							<cfset count = 0>
							<cfloop collection="#group.Segments#" item="segment" index="segmentIndex" >
								<cfset count++>
								<td>
									<cfif count EQ 1>
										<strong>#dateFormat(group.DepartureTime, 'ddd, mmm d')#</strong>
									</cfif>
								</td>
								<td title="#application.stAirVendors[segment.Carrier].Name# Flt ###segment.FlightNumber#">
									#segment.Carrier# #segment.FlightNumber#
								</td>
								<td title="#application.stAirports[segment.Origin]# - #application.stAirports[segment.Destination]#">
									#segment.Origin# - #segment.Destination#
								</td>
								<td>
									#timeFormat(group.DepartureTime, 'h:mmt')# - #timeFormat(group.ArrivalTime, 'h:mmt')#
								</td>
								<td>
									#uCase(segment.Cabin)#
								</td>
								<td>
									SEAT xxx <!--- TO DO: Seat --->
								</td>
								<td>
									#uCase(application.stEquipment[segment.Equipment])#
								</td>
								<td>
									#group.TravelTime#
								</td>
								</tr>
								<tr>
									<cfif groupIndex NEQ (structCount(rc.Air.Groups) - 1)>
										<td colspan="8"><hr class="dashed" /></td></tr><tr>
									</cfif>
							</cfloop>
						</cfloop>
					</tr>
				</table>
			</td>
		</tr>
		<tr><td style="height:12px;"></td></tr>
		<!--- For each traveler with a flight --->
		<cfloop array="#rc.airTravelers#" item="traveler" index="travelerIndex">
			<tr>
				<td>
					<table width="100%" border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td width="6%"></td>
							<td width="14%">
								<cfif arrayLen(rc.vehicleTravelers) GT 1>
									<span class="blue"><strong>#rc.Traveler[travelerIndex].getFirstName()# #rc.Traveler[travelerIndex].getLastName()#</strong></span>
								</cfif>
							</td>
							<cfif arrayLen(rc.Air.aPolicies)>
									<td width="12%"><strong>OUT OF POLICY</strong></td>
									<td colspan="3">#ArrayToList(rc.Air.getAPolicies())#</td>
									<td width="8%"><strong>Reason</strong></td>
									<td>#rc.Traveler[travelerIndex].getBookingDetail().getAirReasonCode()#</td>
								</tr>
								<tr>
									<td colspan="2"></td>						
							</cfif>
							<td width="12%"><span class="blue"><strong>DL Confirmation</strong></span></td>
							<td width="8%"><span class="blue"><strong>xxx<!--- TO DO: #rc.Air.getConfirmation()# ---></strong></span></td>
							<td width="8%"><strong>DL Flyer ##</strong></td>
							<td>xxx<!--- TO DO: Flyer # ---></td>
							<td><strong>Seat Pref</strong></td>
							<td>#rc.Traveler[travelerIndex].getWindowAisle()#</td>
						</tr>
						<!--- If special service or note --->
						<tr>
							<td colspan="4"></td>
							<td><strong>Special Svc</strong></td>
							<td>
								<cfif len(#rc.Traveler[travelerIndex].getSpecialNeeds()#)>
									<cfswitch expression="#rc.Traveler[travelerIndex].getSpecialNeeds()#">
										<cfcase value="BLND">BLIND</cfcase>
										<cfcase value="DEAF">DEAF</cfcase>
										<cfcase value="UMNR">UNACCOMPANIED MINOR</cfcase>
										<cfcase value="WCHR">WHEELCHAIR</cfcase>
									</cfswitch>
								</cfif>								
							</td>
							<td><strong>Note</strong></td>
							<td>#rc.Traveler[travelerIndex].getBookingDetail().getSpecialRequests()#</td>
						</tr>
						<cfif travelerIndex NEQ arrayLen(rc.vehicleTravelers)>
							<tr>
								<td colspan="2"></td>
								<td colspan="6"><hr class="dashed" /></td>
							</tr>
						<cfelse>
							<tr><td colspan="8" style="height:12px;"></td></tr>
						</cfif>
					</table>
				</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>