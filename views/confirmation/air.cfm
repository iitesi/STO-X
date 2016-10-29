<cfoutput>
	<div class="tripsummary-detail">
		<div class="row">
			<div class="col-xs-12 padded">
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
						<div class="col-sm-2 col-xs-12 center">
							<img class="img-responsive carrierimg center-block" src="assets/img/airlines/#(ArrayLen(rc.Air.Carriers) EQ 1 ? rc.Air.Carriers[1] : 'Mult')#.png">

							#(ArrayLen(rc.Air.Carriers) EQ 1 ? ''&application.stAirVendors[rc.Air.Carriers[1]].Name : 'Multiple Carriers')#
						</div>

					<div class="col-sm-10 col-xs-12">
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

		<!--- For each traveler with a flight --->
		<cfloop array="#rc.airTravelers#" item="traveler" index="travelerIndex">
			<div class='row'>
				<div class="col-sm-3 col-sm-offset-2">
					<cfif arrayLen(rc.Travelers) GT 1>
					<!--- <cfif arrayLen(rc.airTravelers) GT 1> --->
						<span class="blue"><strong>#uCase(rc.Traveler[travelerIndex].getFirstName())# #uCase(rc.Traveler[travelerIndex].getLastName())#</strong></span>
					</cfif>
				</div>
				<cfif structKeyExists(rc.Air, "aPolicies") AND arrayLen(rc.Air.aPolicies)>
					<div class="col-sm-2"><strong>OUT OF POLICY</strong></div>
					<div class="col-sm-2">#ArrayToList(rc.Air.aPolicies)#</div>
					<div class="col-sm-3">
						<cfif structKeyExists(rc.Traveler[travelerIndex].getBookingDetail(), "airReasonDescription")>
							<strong>Reason</strong>#rc.Traveler[travelerIndex].getBookingDetail().airReasonDescription#
						</cfif>
					</div>
				</cfif>
			</div>

			<cfloop collection="#rc.Air.Carriers#" item="carrier" index="carrierIndex">
				<div class='row padded'>
					<div class="col-sm-5 col-sm-offset-2">
						<cfif structKeyExists(rc.Traveler[travelerIndex].getBookingDetail().getAirConfirmation(), carrier) && len(rc.Traveler[travelerIndex].getBookingDetail().getAirConfirmation()[carrier])>
							<span class="blue"><strong>#carrier# Confirmation #rc.Traveler[travelerIndex].getBookingDetail().getAirConfirmation()[carrier]#</strong></span><
						</cfif>
					</div>
					<div class="col-sm-5">
						<cfloop collection="#rc.Traveler[travelerIndex].getLoyaltyProgram()#" item="program" index="programIndex">
							<cfif program.getShortCode() EQ carrier>
								<cfif len(program.getAcctNum())>
									<strong>#carrier# Flyer ##</strong> #program.getAcctNum()#
								</cfif>
							</cfif>
						</cfloop>
					</div>
				</div>
			</cfloop>

			<!--- If special service or note --->
			<cfif len(rc.Traveler[travelerIndex].getSpecialNeeds()) OR len(rc.Traveler[travelerIndex].getBookingDetail().getSpecialRequests())>
				<div class='row'>
					<div class="col-sm-5 col-sm-offset-2">
					<strong>Special Svc</strong>
						<cfif len(rc.Traveler[travelerIndex].getSpecialNeeds())>
							<cfswitch expression="#rc.Traveler[travelerIndex].getSpecialNeeds()#">
								<cfcase value="BLND">Blind</cfcase>
								<cfcase value="DEAF">Deaf</cfcase>
								<cfcase value="UMNR">Unaccompanied Minor</cfcase>
								<cfcase value="WCHR">Wheelchair</cfcase>
							</cfswitch>
						</cfif>
					</div>
					<div class="col-sm-5">
						<strong>Note</strong>#rc.Traveler[travelerIndex].getBookingDetail().getSpecialRequests()#
					</div>
				</div>
			</cfif>
			<cfif travelerIndex NEQ arrayLen(rc.airTravelers)>
				<hr class="dashed" />
			</cfif>
		</cfloop>
	</div>
</cfoutput>
