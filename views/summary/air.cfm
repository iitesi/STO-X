<cfoutput>

	<cfif rc.airSelected>
		<cfset lowestFare = session.LowestFare>

		<cfset inPolicy = rc.Air[0].OutOfPolicy ? false : true>

		<input type="hidden" name="airLowestFare" value="#lowestFare#">

		<cfif NOT rc.filter.getFindIt()
			OR rc.policy.Policy_FindItChangeAir>
			<div class="pull-right"><a href="#buildURL('air?SearchID=#rc.searchID#')#" style="color:##666">change <span class="mdi mdi-restart"></span></a></div><br>
		</cfif>

		<div class="tripsummary-detail">
			<div class="row">
				<div class="col s12">					
					<h2>FLIGHT</h2>
				</div>
			</div>
			<div class="row">
				<div class="col s12">
					<!---
					If they are out of policy
					AND they want to capture reason codes
					--->
					<cfif rc.showAll
						OR (rc.Air[0].OutOfPolicy
						AND rc.Policy.Policy_AirReasonCode EQ 1)>

						<div class="row mb0 #(structKeyExists(rc.errors, 'airReasonCode') ? 'error' : '')#">
							<div class="input-field with-icon col s12">
								<select name="airReasonCode" id="airReasonCode" class="#(structKeyExists(rc.errors, 'airReasonCode') ? 'error' : '')#">
									<option value="">Select Reason for Booking Out of Policy</option>
									<cfloop query="rc.qOutOfPolicy">
										<option value="#rc.qOutOfPolicy.FareSavingsCode#">#rc.qOutOfPolicy.Description#</option>
									</cfloop>
								</select>
								<label for="airReasonCode">Booking Out of Policy *</label>
								<a rel="popleft" class="mdi mdi-alert-circle" data-original-title="Out Of Policy" data-content="#ArrayToList(rc.Air[0].OutOfPolicyReason)#" href="javascript:void(0);"></a>
							</div>
						</div>
					</cfif>

					<!---
					If the fare is higher than the lowest
					AND they are in policy OR the above drop down isn't showing
					AND they want to capture lost savings
					--->
					<cfif rc.showAll
						OR (rc.Air[0].TotalPrice GT lowestFare
						AND (inPolicy OR rc.Policy.Policy_AirReasonCode EQ 0)
						AND rc.Policy.Policy_AirLostSavings EQ 1)>

						<div class="row mb0">
							<div class="input-field col s12">
								<select name="lostSavings" id="lostSavings">
									<option value="" disabled selected>Select Reason for Not Booking the Lowest Fare</option>
									<cfloop query="rc.qOutOfPolicy">
										<option value="#rc.qOutOfPolicy.FareSavingsCode#">#rc.qOutOfPolicy.Description#</option>
									</cfloop>
								</select>
								<label for="lostSavings">Not Booking Nowest Fare *</label>
							</div>
						</div>

					<!---
					If the fare is the same
					--->
					<cfelseif rc.Air[0].TotalPrice EQ lowestFare>
						<cfset defaultLostSavingsCode = "C" />
						<!--- If Peak TMC --->
						<cfif rc.Account.tmc.getTMCID() EQ 3>
							<cfset defaultLostSavingsCode = "L" />
						</cfif>
						<input type="hidden" name="lostSavings" value="#defaultLostSavingsCode#" />
					</cfif>

					<!--- State of Texas --->
					<cfif rc.showAll
						OR rc.Filter.getAcctID() EQ 235>

						<div class="row mb0">
							<div class="input-field mb0 col s12  #(structKeyExists(rc.errors, 'udid113') ? 'error' : '')#">
								<select name="udid113" id="udid113" class="#(structKeyExists(rc.errors, 'udid113') ? 'error' : '')#">
									<option value="" disabled selected>Select an Exception Code</option>
								<cfloop query="rc.qTXExceptionCodes">
									<option value="#rc.qTXExceptionCodes.FareSavingsCode#">#rc.qTXExceptionCodes.Description#</option>
								</cfloop>
								</select>
								<label for="udid113">State of Texas *</label>
							</div>
							<div class="col s12">
								<a href="http://www.window.state.tx.us/procurement/prog/stmp/exceptions-to-the-use-of-stmp-contracts/" target="_blank">View explanation of codes</a>
							</div>
						</div>

					</cfif>

				</div>
			</div> <!-- /.row -->
			 <div class="row">
				<div class="col s12 m9">
				    <cfset seatFieldNames = ''/>
					<cfloop index="Group" from="0" to="20" >
						<cfif structKeyExists(rc.Air, Group)>
							
							<cfset Segment = rc.Air[Group]/>
							<cfif structKeyExists(Segment, 'Flights')>
								<cfset firstFlight = Segment.Flights[1]/>
								<cfset lastFlight = Segment.Flights[ArrayLen(Segment.Flights)]/>
								<div class="panel panel-default trip-segment">
									<div class="panel-heading">
									<h3 class="panel-title" style="position:relative;">
										<span class="mdi mdi-airplane-takeoff hide-small"></span>
										<span class="hide-small">#application.stAirports[firstFlight.OriginAirportCode].airport#</span>
										<span class="fromto hide-small">To</span>
										<span class="mdi mdi-airplane-landing hide-small"></span>
										<span class="hide-small">#application.stAirports[lastFlight.DestinationAirportCode].airport#</span>
										<div class="panel-date">
											<span class="mdi mdi-calendar"></span>
											#DateFormat(firstFlight.DepartureTime, 'ddd, mmm d, yyyy')#
										</div>
									</h3>
									</div>
									<div class="panel-body">
										<cfset count = 0>
								<cfloop collection="#Segment.Flights#" index="FlightIndex" item="Flight">
									<cfset count++>
		
									<cfif count NEQ 1>
										<cfset layover = dateDiff('n', previousFlight.ArrivalTime, Flight.DepartureTime)>
										<div class="segment-stopover" data-minutes="#layover#">
											<div class="segment-stopover-row">
												<div>#int(layover/60)#H #layover%60#M layover</div>
												<div class="segment-middot">&middot;</div>
												<div>
													<span>#application.stAirports[previousFlight.DestinationAirportCode].Airport# </span>
													<span>&nbsp;</span>
													<span>(#previousFlight.DestinationAirportCode#)</span></span>
												</div>
											</div>
										</div>
									</cfif>		
									<div class="segment-details">
										<div class="segment-details-flights">
											<div class="segment-leg">
												<div class="segment-leg-inner">
													<div class="carrier-img-wrapper">
														<img class="carrierimg" src="assets/img/airlines/#Flight.CarrierCode#.png" title="#application.stAirVendors[Flight.CarrierCode].Name#" width="60">
													</div>
													<div class="segment-leg-connector"></div>
													<div class="segment-leg-details fs-s1">
														<div class="segment-leg-time"><span>#timeFormat(Flight.DepartureTime, 'h:mm tt')# - #dateFormat(Flight.DepartureTime, 'ddd, mmm d')#</span></span></div>
														<div class="segment-middot">&middot;</div>
														<div class="segment-leg-airport">
															<span>#application.stAirports[Flight.OriginAirportCode].Airport#</span>
															<span>&nbsp;</span>
															<span>(#Flight.OriginAirportCode#)</span>
														</div>
													</div>
													<div class="segment-leg-time-inair fs-1">
														<div>Flight time:&nbsp;<span>#Flight.FlightTime#</span></div>
													</div>
													<div class="segment-leg-details segment-leg-arrival fs-s1">
														<div class="segment-leg-time"><span>#timeFormat(Flight.ArrivalTime, 'h:mm tt')# - #dateFormat(Flight.ArrivalTime, 'ddd, mmm d')#</span></span></div>
														<div class="segment-middot">&middot;</div>
														<div class="segment-leg-airport">
															<span>#application.stAirports[Flight.DestinationAirportCode].Airport#</span>
															<span>&nbsp;</span>
															<span>(#Flight.DestinationAirportCode#)</span>
														</div>
													</div>
												</div>
												<div class="segment-leg-operation-details fs-1">
													<div class="segment-leg-operation-vendor">#application.stAirVendors[Flight.CarrierCode].Name#</div>
													<span class="segment-middot-sm">&middot;</span>
													<div class="segment-leg-operation-equipment">
														<div><span>#structKeyExists(application.stEquipment, Flight.Equipment) ? application.stEquipment[Flight.Equipment] : Flight.Equipment#</span></div>
													</div>
													<div class="segment-leg-operation-codes">
														<span class="segment-middot-sm">&middot;</span>
														<span><span>#Flight.CarrierCode#</span>&nbsp;<span>#Flight.FlightNumber#</span></span>
													</div>
												</div>
											</div>
										</div>
										<div class="segment-details-extras">
											<ul>
												<li>
													Cabin: #uCase(Replace(Flight.CabinClass, 'Premium', 'Premium '))#
												</li>
												<cfif NOT listFind('WN,F9', Flight.CarrierCode)><li>
													<a class="seatMapOpener" id="link_seatFlight#Flight.FlightNumber#" data-toggle="modal" data-target="##seatMapModal" data-id='#serializeJson(Flight)#'>
														<i class="mdi mdi-seat-legroom-normal"></i> Select Seat
													</a>
													<input type="hidden" id="input_seatFlight#Flight.FlightNumber#" name="input_seatFlight#Flight.FlightNumber#" value=""/>
												</li></cfif>
											</ul>
										</div>
									</div>
									<cfset previousFlight = Flight>
								</cfloop>
							</div>
					<cfset seatFieldNames = ''/>
						</div>
							</cfif>
						</cfif>
					</cfloop>
					<input type="hidden" name="seatFieldNames" id="seatFieldNames" value="#seatFieldNames#"/>
				</div>

				<div class="col s12 m3">
					<div class="panel panel-primary air-purchase-details">
						<div class="panel-heading">
							<h3 class="panel-title">
								#dollarFormat(rc.Air[0].TotalPrice)#
							</h3>
						</div>
						<div class="panel-body">
							<ul>
								<li>Total including taxes and refunds</li>
								<li>Ticket is: #(rc.air[0].Refundable ? 'Refundable' : 'Non Refundable')#</li>
								<li>
									<!--- TODO --->
									<a rel="popover" data-original-title="Flight Change / Cancellation Policy"
									data-content="
										Ticket is #(rc.air[0].Refundable ? 'refundable' : 'non-refundable')#
										<!--- <br>
										<cfif listFind('DL',rc.Air.platingCarrier) AND val(rc.Air.ref) EQ 0 AND val(rc.Air.changePenalty) EQ 0>
											Changes are not permitted<br>
											No pre-reserved seats
										<cfelse>
											Changes USD #rc.Air[0].changePenalty# for reissue
										</cfif> --->
									" href="##"/>
									Flight change/cancellation policy
								</a>
								</li>
							</ul>
							<div class="alert alert-danger">
								TICKET NOT YET ISSUED.<br />AIRFARE QUOTED IN ITINERARY IS NOT GUARANTEED UNTIL TICKETS ARE ISSUED.
							</div>
						</div>
					</div>
				</div>
			</div> <!-- /.row -->
			<div class="row">
				<div class="col s12">
					<div class="row">

						<!---
						FREQUENT PROGRAM NUMBER
						--->
						<div class="input-field col s12 m4">
							<input type="text" name="airFF#rc.Air[0].PlatingCarrier#" id="airFF#rc.Air[0].PlatingCarrier#" maxlength="20">
							<label for="airFF#rc.Air[0].PlatingCarrier#">#rc.Air[0].PlatingCarrier# Frequent Flyer ##</label>
						</div>

						<!---
						ADDITIONAL REQUESTS
						--->
						<div class="input-field col s12 m4">
							<select name="specialNeeds" id="specialNeeds">
								<option value="" disabled selected>SELECT</option>
								<option value="BLND">BLIND</option>
								<option value="DEAF">DEAF</option>
								<option value="UMNR">UNACCOMPANIED MINOR</option>
								<option value="WCHR">WHEELCHAIR - CAN CLIMB STAIRS</option>
								<option value="WCHC">WHEELCHAIR - IMMOBILE</option>
							</select>
							<label for="specialNeeds">Special Requests</label>
						</div>

						<!---
						GENERAL SEATS
						--->
						<cfset showWindowAisle = false />
						<cfif NOT listFind('WN,F9', rc.Air[0].PlatingCarrier)>
							<cfset showWindowAisle = true />
						</cfif>
						<cfif showWindowAisle>
							<div class="input-field col s12 m4">
								<select name="windowAisle" id="windowAisle">
									<option value="">SEATS</option>
									<option value="Window">WINDOW</option>
									<option value="Aisle">AISLE</option>
								</select>
								<label for="windowAisle">Special Requests</label>
							</div>
						</cfif>

					</div> <!-- / .row -->
				</div> <!-- /.col s12 -->
			<!---
			SPECIAL REQUEST
			--->
			<cfif 1 eq 1 OR rc.showAll
				OR rc.Policy.Policy_AllowRequests>
				<div class="input-field col s12">					
					<input name="specialRequests" id="specialRequests" class="form-control" type="text" placeholder="Add notes for our Travel Consultants (unused ticket credits, etc.)<!--- #(rc.fees.requestFee NEQ 0 ? 'for a #DollarFormat(rc.fees.requestFee)# fee' : '')# --->" >
					<label for="specialRequest" >Notes for our Travel Consultants (unused ticket credits, etc.)</label>
				</div>
			</cfif>
		</div> <!-- / .row -->
	</div> <!-- / .tripsummary-detail -->

	</cfif>


#View('modal/popup')#


</cfoutput>
