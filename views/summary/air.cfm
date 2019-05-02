<cfoutput>

	<cfif rc.airSelected>
		<cfset lowestFare = session.LowestFare>

		<cfset inPolicy = rc.Air[0].OutOfPolicy ? false : true>

		<input type="hidden" name="airLowestFare" value="#lowestFare#">

		<cfif NOT rc.filter.getFindIt()
			OR rc.policy.Policy_FindItChangeAir>
			<div class="pull-right"><a href="#buildURL('air?SearchID=#rc.searchID#')#" style="color:##666">change <span class="fa fa-times"></a></div><br>
		</cfif>


		<div class="tripsummary-detail">
			<div class="row">
				<div class="col-xs-12">					
					<h2>FLIGHT</h2>
				</div>
			</div>
			<div class="row">
				<div class="col-xs-12">
					<!---
					If they are out of policy
					AND they want to capture reason codes
					--->
					<cfif rc.showAll
						OR (rc.Air[0].OutOfPolicy
						AND rc.Policy.Policy_AirReasonCode EQ 1)>

						<div class="form-group #(structKeyExists(rc.errors, 'hotelNotBooked') ? 'error' : '')#">
							<span rel="tooltip" class="outofpolicy" title="#ArrayToList(rc.Air.aPolicies)#" style="float:left; width:114px;">Out Of Policy *</span>
							<div class="controls col-sm-8 col-xs-12">
								<select name="airReasonCode" id="airReasonCode" class="form-control #(structKeyExists(rc.errors, 'airReasonCode') ? 'error' : '')#">
								<option value="">Select Reason for Booking Out of Policy</option>
								<cfloop query="rc.qOutOfPolicy">
									<option value="#rc.qOutOfPolicy.FareSavingsCode#">#rc.qOutOfPolicy.Description#</option>
								</cfloop>
								</select>
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

						<div class="form-group #(structKeyExists(rc.errors, 'hotelNotBooked') ? 'error' : '')#">
							<label class="control-label col-sm-4 col-xs-12" for="hotelNotBooked">Not Booking Lowest Fare *</label>
							<div class="controls col-sm-8 col-xs-12">
								<select class="form-control" name="lostSavings" id="lostSavings #(structKeyExists(rc.errors, 'lostSavings') ? 'error' : '')#">
								<option value="">Select Reason for Not Booking the Lowest Fare</option>
								<cfloop query="rc.qOutOfPolicy">
									<option value="#rc.qOutOfPolicy.FareSavingsCode#">#rc.qOutOfPolicy.Description#</option>
								</cfloop>
								</select>
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

						<div class="form-group #(structKeyExists(rc.errors, 'udid113') ? 'error' : '')#">
							<label class="control-label col-sm-4 col-xs-12" for="hotelNotBooked">State of Texas *</label>
							<div class="controls col-sm-8 col-xs-12">
								<select class="form-control" name="udid113" id="udid113 #(structKeyExists(rc.errors, 'udid113') ? 'error' : '')#">
								<option value="">Select an Exception Code</option>
								<cfloop query="rc.qTXExceptionCodes">
									<option value="#rc.qTXExceptionCodes.FareSavingsCode#">#rc.qTXExceptionCodes.Description#</option>
								</cfloop>
								</select>
								<a href="http://www.window.state.tx.us/procurement/prog/stmp/exceptions-to-the-use-of-stmp-contracts/" target="_blank">View explanation of codes</a><br><br>
							</div>
						</div>

					</cfif>

				</div>
			</div> <!-- /.row -->
			 <div class="row">
				<div class="col-sm-9 col-xs-8">
					<div class="container-fluid">
					<cfloop collection="#rc.Air#" index="GroupIndex" item="Group">
						<div class="col-sm-2 col-xs-4">
							<img class="img-responsive carrierimg" src="assets/img/airlines/#Group.CarrierCode#.png">
						</div>
						<cfloop collection="#Group.Flights#" index="FlightIndex" item="Flight">
							<div class="summarySegment row">
								<!--- <cfif count EQ 1>
									<div class="col-xs-12">
										<strong>#dateFormat(Flight.DepartureTime, 'ddd, mmm d')#</strong>
									</div>
								</cfif> --->
								<div class="col-lg-2 col-sm-3" title="#application.stAirVendors[Flight.CarrierCode].Name# Flt ###Flight.FlightNumber#">
									#Flight.CarrierCode# #Flight.FlightNumber#
								</div>
								<div class="col-lg-2 col-sm-3" title="#application.stAirports[Flight.OriginAirportCode].airport# - #application.stAirports[Flight.DestinationAirportCode].airport#">
									#Flight.OriginAirportCode# - #Flight.DestinationAirportCode#
								</div>
 								<div class="col-lg-3 col-sm-3">
									#timeFormat(Flight.DepartureTime, 'h:mmt')# - #timeFormat(Flight.ArrivalTime, 'h:mmt')#
								</div>
								<div class="col-lg-2 col-sm-3">
									#uCase(Replace(Flight.CabinClass, 'Premium', 'Premium '))#
								</div>
								<div class="col-lg-2 col-sm-3">
									<cfif NOT listFind('WN,F9', Flight.CarrierCode)><!--- Exclude Southwest and Frontier --->
										Seat Map
									</cfif>
								</div> 
								<hr class="visible-xs-block" />
							</div>
						</cfloop>
					</cfloop>
					</div>
				</div>
				<!--- <input type="hidden" name="seatFieldNames" id="seatFieldNames" value=""> --->

				<div class="col-sm-3 col-xs-12">
					<span class="blue bold large">
						#dollarFormat(rc.Air[0].TotalPrice)#
						<br>
					</span>
					Total including taxes and refunds<br>
					#(rc.air[0].Refundable ? 'Refundable' : 'No Refunds')#<br>
					<!--- To Do --->
					<span class="blue bold">
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
					</span>

					<span class="red bold">
						TICKET NOT YET ISSUED.<br />AIRFARE QUOTED IN ITINERARY IS NOT GUARANTEED UNTIL TICKETS ARE ISSUED.
					</span>

				</div>
			</div> <!-- /.row -->
			<div class="row">
			<div class="col-xs-12">
				<div class="form-inline">

				<!---
				FREQUENT PROGRAM NUMBER
				--->
					<div class="form-group">
						<label for="airFF#rc.Air[0].PlatingCarrier#">#rc.Air[0].PlatingCarrier# Frequent Flyer ##</label>
						<input type="text" name="airFF#rc.Air[0].PlatingCarrier#" id="airFF#rc.Air[0].PlatingCarrier#" maxlength="20" class="form-control">
					</div>
				<!---
				ADDITIONAL REQUESTS
				--->
					<div class="form-group">
						<label for="specialNeeds"  >Special Requests</label>
						<select name="specialNeeds" id="specialNeeds" class="form-control">
							<option value="">SPECIAL REQUESTS</option>
							<option value="BLND">BLIND</option>
							<option value="DEAF">DEAF</option>
							<option value="UMNR">UNACCOMPANIED MINOR</option>
							<option value="WCHR">WHEELCHAIR - CAN CLIMB STAIRS</option>
							<option value="WCHC">WHEELCHAIR - IMMOBILE</option>
						</select>
					</div>
				<!---
				GENERAL SEATS
				--->
					<cfset showWindowAisle = false />
					<cfif NOT listFind('WN,F9', rc.Air[0].PlatingCarrier)>
						<cfset showWindowAisle = true />
					</cfif>
					<cfif showWindowAisle>
						<div class="form-group">
							<label for="windowAisle" >Seats</label>
							<select name="windowAisle" id="windowAisle" class="form-control">
								<option value="">SEATS</option>
								<option value="Window">WINDOW</option>
								<option value="Aisle">AISLE</option>
							</select>
						</div>
					</cfif>

				</div> <!-- / .form-inline -->
			</div> <!-- /.col-xs-12 -->
			<!---
			SPECIAL REQUEST
			--->
			<cfif rc.showAll
				OR rc.Policy.Policy_AllowRequests>
				<div class="col-xs-12">
					<div class="form-group">
						<label for="specialRequest"  >Notes for our Travel Consultants (unused ticket credits, etc.)</label>
						<input name="specialRequests" id="specialRequests" class="form-control" type="text" placeholder="Add notes for our Travel Consultants (unused ticket credits, etc.)<!--- #(rc.fees.requestFee NEQ 0 ? 'for a #DollarFormat(rc.fees.requestFee)# fee' : '')# --->" >
					</div>
				</div>
			</cfif>
		</div> <!-- / .row -->
	</div> <!-- / .tripsummary-detail -->

	</cfif>


#View('modal/popup')#


</cfoutput>
