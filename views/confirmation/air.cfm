<cfoutput>
	<div class="tripsummary-detail">
		<div class="row">
			<div class="col-xs-11 col-xs-offset-1">
							<!--- create ribbon
							Note: Please do not display "CONTRACTED" flag on search results for Southwest.
							--->
							<cfif rc.Air.privateFare AND rc.Air.preferred>
								<cfif rc.Air.Carriers[1] EQ "WN">
									<cfif rc.Air.PTC EQ "GST">
										<span class="ribbon ribbon-l-pref-govt"></span>
									<cfelse>
										<span class="ribbon ribbon-l-pref"></span>
									</cfif>
								<cfelse>
									<span class="ribbon ribbon-l-pref-cont"></span>
								</cfif>
							<cfelseif rc.Air.preferred>
								<cfif rc.Air.PTC EQ "GST">
									<span class="ribbon ribbon-l-pref-govt"></span>
								<cfelse>
									<span class="ribbon ribbon-l-pref"></span>
								</cfif>
							<cfelseif rc.Air.privateFare AND rc.Air.Carriers[1] NEQ "WN">
								<span class="ribbon ribbon-l-cont"></span>
							<cfelseif rc.Air.PTC EQ "GST">
								<span class="ribbon ribbon-l-govt"></span>
							</cfif>

							<h2>FLIGHT</h2>
						</div>
					</div> <!-- ./row -->
					<div class="row">
						<div class="col-sm-2 col-xs-4 center">
							<img class="img-responsive carrierimg center-block" src="assets/img/airlines/#(ArrayLen(rc.Air.Carriers) EQ 1 ? rc.Air.Carriers[1] : 'Mult')#.png"><br>

							#(ArrayLen(rc.Air.Carriers) EQ 1 ? '<br />'&application.stAirVendors[rc.Air.Carriers[1]].Name : '<br />Multiple Carriers')#
						</div>

					<div class="col-sm-10 col-xs-8">
								<cfloop collection="#rc.Air.Groups#" item="group" index="groupIndex">
									<cfset count = 0>
									<cfset tripLength = rc.airhelpers.getTripDays(group.DepartureTime, group.ArrivalTime)>
									<cfloop collection="#group.Segments#" item="segment" index="segmentIndex">
										<cfset count++>
										<div class="summarySegment row">

												<cfif count EQ 1>
													<div class="col-xs-12">
													<strong>#dateFormat(group.DepartureTime, 'ddd, mmm d')#</strong>&nbsp;#tripLength#
												</div>
												</cfif>

											<div class="col-lg-2 col-sm-3 col-xs-6" title="#application.stAirVendors[segment.Carrier].Name# Flt ###segment.FlightNumber#">
												#segment.Carrier# #segment.FlightNumber#
											</div>
											<div class="col-lg-2 col-sm-3 col-xs-6" title="#application.stAirports[segment.Origin].airport# - #application.stAirports[segment.Destination].airport#">
												#segment.Origin# - #segment.Destination#
											</div>

											<div class="col-lg-2 col-sm-3 col-xs-6">
												#timeFormat(segment.DepartureTime, 'h:mmt')# - #timeFormat(segment.ArrivalTime, 'h:mmt')#
											</div>
											<div class="col-lg-2 col-sm-3 col-xs-6">
												#uCase(segment.Cabin)#
											</div>
											<div class="col-lg-2 col-sm-3">
												<cfset showIcon = false />
												<cfset seats = '' />
												<cfloop array="#rc.airTravelers#" item="traveler" index="travelerIndex">
													<cfloop collection="#rc.Traveler[travelerIndex].getBookingDetail().getSeats()#" item="seat" index="seatIndex">
														<cfif structKeyExists(segment, "key") AND (seat.segmentRef EQ segment.key)>
															<cfif seat.seat NEQ 'Unknown'>
																<cfset thisStatus = "unconfirmed" />
																<cfswitch expression="#seat.status#">
																	<cfcase value="PN">
																		<cfset thisStatus = "pending" />
																	</cfcase>
																	<cfcase value="HK">
																		<cfset thisStatus = "confirmed" />
																	</cfcase>
																	<cfcase value="NO">
																		<cfset thisStatus = "denied" />
																	</cfcase>
																	<cfcase value="KK">
																		<cfset thisStatus = "will be assigned" />
																	</cfcase>
																	<cfcase value="NN">
																		<cfset thisStatus = "to be requested" />
																	</cfcase>
																</cfswitch>
																<cfset thisSeat = seat.seat & " (" & thisStatus & ")" />
																<cfset seats = listAppend(seats, thisSeat) />
															<cfelse>
																<cfset seats = listAppend(seats, 'NA') />
																<cfset showIcon = true />
															</cfif>
														</cfif>
													</cfloop>
												</cfloop>
												SEAT #seats#
												<cfif showIcon><a rel="popover" class="blue icon-large icon-info-sign" data-original-title="Seat Not Assigned" data-content="Seat not assigned." href="##" /></a></cfif>
											</div>

												<cfif segment.Equipment NEQ ''>
													<div class="col-xs-12">
													#uCase(application.stEquipment[segment.Equipment])#
												</div>
												</cfif>


												<cfif count EQ structCount(group.Segments)
													AND group.TravelTime NEQ '0h 0m'>
														<div class="col-lg-2">
													#group.TravelTime#
												</div>
												</cfif>

										</div> <!-- .row  -->
									</cfloop>
									<cfif groupIndex NEQ (structCount(rc.Air.Groups) - 1)>
										<hr class="dashed" />
									</cfif>
								</cfloop>
							</div>

				</div>

		<tr><td style="height:12px;"></td></tr>
		<!--- For each traveler with a flight --->
		<cfloop array="#rc.airTravelers#" item="traveler" index="travelerIndex">
			<tr>
				<td>
					<table width="100%" border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td width="6%"></td>
							<td width="12%">
								<cfif arrayLen(rc.Travelers) GT 1>
								<!--- <cfif arrayLen(rc.airTravelers) GT 1> --->
									<span class="blue"><strong>#uCase(rc.Traveler[travelerIndex].getFirstName())# #uCase(rc.Traveler[travelerIndex].getLastName())#</strong></span>
								</cfif>
							</td>
							<cfif structKeyExists(rc.Air, "aPolicies") AND arrayLen(rc.Air.aPolicies)>
									<td width="110"><strong>OUT OF POLICY</strong></td>
									<td colspan="3">#ArrayToList(rc.Air.aPolicies)#</td>
									<cfif structKeyExists(rc.Traveler[travelerIndex].getBookingDetail(), "airReasonDescription")>
										<td width="80"><strong>Reason</strong></td>
										<td>#rc.Traveler[travelerIndex].getBookingDetail().airReasonDescription#</td>
									<cfelse>
										<td colspan="2"></td>
									</cfif>
								</tr>
								<tr>
									<td colspan="2"></td>
							</cfif>
							<cfloop collection="#rc.Air.Carriers#" item="carrier" index="carrierIndex">
								<cfif structKeyExists(rc.Traveler[travelerIndex].getBookingDetail().getAirConfirmation(), carrier) && len(rc.Traveler[travelerIndex].getBookingDetail().getAirConfirmation()[carrier])>
									<td width="110"><span class="blue"><strong>#carrier# Confirmation</strong></span></td>
									<td width="80"><span class="blue"><strong>#rc.Traveler[travelerIndex].getBookingDetail().getAirConfirmation()[carrier]#</strong></span></td>
								<cfelse>
									<td width="110"></td>
									<td width="80"></td>
								</cfif>
								<cfloop collection="#rc.Traveler[travelerIndex].getLoyaltyProgram()#" item="program" index="programIndex">
									<cfif program.getShortCode() EQ carrier>
										<cfif len(program.getAcctNum())>
											<td width="110"><strong>#carrier# Flyer ##</strong></td>
											<td width="120">#program.getAcctNum()#</td>
										<cfelse>
											<td width="110"></td>
											<td width="120"></td>
										</cfif>
									</cfif>
								</cfloop>
								<td width="60"></td>
								<td width="190"></td>
								<cfif carrierIndex NEQ arrayLen(rc.Air.Carriers)>
									</tr>
									<tr><td colspan="2">
								</cfif>
							</cfloop>
						</tr>
						<!--- If special service or note --->
						<cfif len(rc.Traveler[travelerIndex].getSpecialNeeds()) OR len(rc.Traveler[travelerIndex].getBookingDetail().getSpecialRequests())>
							<tr>
								<td colspan="4"></td>
								<td valign="top"><strong>Special Svc</strong></td>
								<td valign="top">
									<cfif len(rc.Traveler[travelerIndex].getSpecialNeeds())>
										<cfswitch expression="#rc.Traveler[travelerIndex].getSpecialNeeds()#">
											<cfcase value="BLND">Blind</cfcase>
											<cfcase value="DEAF">Deaf</cfcase>
											<cfcase value="UMNR">Unaccompanied Minor</cfcase>
											<cfcase value="WCHR">Wheelchair</cfcase>
										</cfswitch>
									</cfif>
								</td>
								<td valign="top"><strong>Note</strong></td>
								<td valign="top" width="120">#rc.Traveler[travelerIndex].getBookingDetail().getSpecialRequests()#</td>
							</tr>
						</cfif>
						<cfif travelerIndex NEQ arrayLen(rc.airTravelers)>
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
