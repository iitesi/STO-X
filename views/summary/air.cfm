<cfoutput>

	<cfif rc.airSelected>
		<cfset lowestFareTripID = session.searches[rc.searchid].stLowFareDetails.aSortFare[1] />
		<cfset lowestFare = session.searches[rc.searchid].stTrips[lowestFareTripID].Total />
		<cfset inPolicy = (ArrayLen(rc.Air.aPolicies) GT 0 ? false : true)>

		<input type="hidden" name="airLowestFare" value="#lowestFare#">

		<cfif NOT rc.filter.getFindIt()
			OR rc.policy.Policy_FindItChangeAir>
			<div style="float:right;padding-right:20px;"><a href="#buildURL('air.lowfare?SearchID=#rc.searchID#')#" style="color:##666">change <span class="fa fa-times"></a></div><br>
		</cfif>

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
		
		<div class="row">
			<div class="col-xs-12">
				<h2>FLIGHT</h2>
			</div>
		</div> <!-- ./row -->
		<div class="row">
			<div class="col-xs-12">
				<!---
				If they are out of policy
				AND they want to capture reason codes
				--->
				<cfif rc.showAll
					OR (NOT inPolicy
					AND rc.Policy.Policy_AirReasonCode EQ 1)>

					<span rel="tooltip" class="outofpolicy" title="#ArrayToList(rc.Air.aPolicies)#" style="float:left; width:114px;">OUT OF POLICY *</span>

					<select name="airReasonCode" id="airReasonCode" class="input-xlarge #(structKeyExists(rc.errors, 'airReasonCode') ? 'error' : '')#">
					<option value="">Select Reason for Booking Out of Policy</option>
					<cfloop query="rc.qOutOfPolicy">
						<option value="#rc.qOutOfPolicy.FareSavingsCode#">#rc.qOutOfPolicy.Description#</option>
					</cfloop>
					</select> <br><br>

				</cfif>

				<!---
				If the fare is higher than the lowest
				AND they are in policy OR the above drop down isn't showing
				AND they want to capture lost savings
				--->
				<cfif rc.showAll
					OR (rc.Air.Total GT lowestFare
					AND (inPolicy OR rc.Policy.Policy_AirReasonCode EQ 0)
					AND rc.Policy.Policy_AirLostSavings EQ 1)>

					<span rel="tooltip" class="outofpolicy" title="#ArrayToList(rc.Air.aPolicies)#" style="float:left; width:180px;">NOT BOOKING LOWEST FARE *</span>

					<select name="lostSavings" id="lostSavings" class="input-xlarge #(structKeyExists(rc.errors, 'lostSavings') ? 'error' : '')#">
					<option value="">Select Reason for Not Booking the Lowest Fare</option>
					<cfloop query="rc.qOutOfPolicy">
						<option value="#rc.qOutOfPolicy.FareSavingsCode#">#rc.qOutOfPolicy.Description#</option>
					</cfloop>
					</select> <br><br>

				<!---
				If the fare is the same
				--->
				<cfelseif rc.Air.Total EQ lowestFare>
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
					<div class="#(structKeyExists(rc.errors, 'udid113') ? 'error' : '')#">
						<span style="float:left; width:114px;">STATE OF TEXAS *</span>
						<select name="udid113" id="udid113" class="input-xlarge">
						<option value="">Select an Exception Code</option>
						<cfloop query="rc.qTXExceptionCodes">
							<option value="#rc.qTXExceptionCodes.FareSavingsCode#">#rc.qTXExceptionCodes.Description#</option>
						</cfloop>
						</select>
						<a href="http://www.window.state.tx.us/procurement/prog/stmp/exceptions-to-the-use-of-stmp-contracts/" target="_blank">View explanation of codes</a><br><br>
					</div>

				</cfif>

			</div>
		</div> <!-- /.row -->
		<div class="row">
			<div class="col-sm-2 col-xs-4">
				<img class="img-responsive carrierimg" src="assets/img/airlines/#(ArrayLen(rc.Air.Carriers) EQ 1 ? rc.Air.Carriers[1] : 'Mult')#.png"><br>

				#(ArrayLen(rc.Air.Carriers) EQ 1 ? '<br />'&application.stAirVendors[rc.Air.Carriers[1]].Name : '<br />Multiple Carriers')#
			</div>

			<div class="col-sm-8 col-xs-8">
				<cfset seatFieldNames = ''>
				<cfset totalCount = 0>
				<div class="container">
				<cfloop collection="#rc.Air.Groups#" item="group" index="groupIndex">
					<cfset tripLength = rc.airhelpers.getTripDays(group.DepartureTime, group.ArrivalTime)>
					<cfset count = 0>
					<cfloop collection="#group.Segments#" item="segment" index="segmentIndex">
						<cfset count++>
						<cfset totalCount++>
						<div class="summarySegment row">
							<div class="col-lg-2 col-md-3">
								<cfif count EQ 1>
									<strong>#dateFormat(group.DepartureTime, 'ddd, mmm d')#</strong> #tripLength#
								</cfif>
							</div>

							<div class="col-lg-2 col-md-3" title="#application.stAirVendors[segment.Carrier].Name# Flt ###segment.FlightNumber#">
								#segment.Carrier# #segment.FlightNumber#
							</div>

							<div class="col-lg-2 col-md-3" title="#application.stAirports[segment.Origin].airport# - #application.stAirports[segment.Destination].airport#">
								#segment.Origin# - #segment.Destination#
							</div>

							<div class="col-lg-2 col-md-3">
								#timeFormat(segment.DepartureTime, 'h:mmt')# - #timeFormat(segment.ArrivalTime, 'h:mmt')#
							</div>

							<div class="col-lg-2 col-md-3">
								#uCase(segment.Cabin)#
							</div>

<!--- seats --->
							<div class="col-lg-2 col-md-3" id="#totalCount#">
								<cfif NOT listFind('WN,F9', segment.Carrier)><!--- Exclude Southwest and Frontier --->
									<cfset sURL = 'SearchID=#rc.SearchID#&amp;nTripID=#rc.air.nTrip#&amp;nSegment=#segmentIndex#&amp;sClass=#segment.Class#&amp;nTotalCount=#totalCount#'>
									<a href="?action=air.summarypopup&amp;sDetails=seatmap&amp;summary=true&amp;#sURL#" class="summarySeatMapModal" data-toggle="modal" data-target="##popupModal" title="Select a seat for this flight">Seat Map</a>
									&nbsp; <span class="label label-success" id="segment_#totalCount#_display"></span>
									<input type="hidden" name="segment_#totalCount#" id="segment_#totalCount#" value="">
									<cfset seatFieldNames = listAppend(seatFieldNames, 'segment_#totalCount#')>
									<!--- <cfset sURL = 'SearchID=#rc.SearchID#&amp;nTripID=#rc.air.nTrip#&amp;nSegment=#segmentIndex#'>
									<a href="?action=air.summarypopup&amp;sDetails=seatmap&amp;summary=true&amp;#sURL#" class="summarySeatMapModal" data-toggle="modal" data-target="##popupModal" title="Select a seat for this flight">Seat Map</a>
									&nbsp; <span class="label label-success" id="segment_#segmentIndex#_display"></span>
									<input type="hidden" name="segment_#segmentIndex#" id="segment_#segmentIndex#" value="">
									<cfset seatFieldNames = listAppend(seatFieldNames, 'segment_#segmentIndex#')> --->
								</cfif>
							</div>

						</div>
					</cfloop>
				</cfloop>
				</div>
			</div>
			<input type="hidden" name="seatFieldNames" id="seatFieldNames" value="#seatFieldNames#">

			<div class="col-sm-2 col-xs-12">
				<span class="blue bold large">
					<cfif NOT structKeyExists(rc.Air, 'PricingSolution')
						OR NOT isObject(rc.Air.PricingSolution)>
						#dollarFormat(rc.Air.Total)#
					<cfelse>
						#replace(rc.Air.PricingSolution.getPricingInfo()[1].getTotalPrice(), 'USD', '$')#
					</cfif>
					<br>
				</span>

				Total including taxes and refunds<br>
				#(rc.air.ref ? 'Refundable' : 'No Refunds')#<br>
				<span class="blue bold">
					<a rel="popover" data-original-title="Flight Change / Cancellation Policy" data-content="Ticket is #(session.searches[rc.SearchID].RequestedRefundable ? '' : 'non-')#refundable.<br>Change USD #rc.Air.changePenalty# for reissue" href="##" />
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

<!---
FREQUENT PROGRAM NUMBER
--->
				<cfloop array="#rc.Air.Carriers#" item="sCarrier">

					#sCarrier# Frequent Flyer ##
					<input type="text" name="airFF#sCarrier#" id="airFF#sCarrier#" maxlength="20" class="input-medium">
					&nbsp;&nbsp;&nbsp;

				</cfloop>
<!---
ADDITIONAL REQUESTS
--->
				<select name="specialNeeds" id="specialNeeds">
				<option value="">SPECIAL REQUESTS</option>
				<option value="BLND">BLIND</option>
				<option value="DEAF">DEAF</option>
				<option value="UMNR">UNACCOMPANIED MINOR</option>
				<option value="WCHR">WHEELCHAIR - CAN CLIMB STAIRS</option>
				<option value="WCHC">WHEELCHAIR - IMMOBILE</option>
				</select>
<!---
GENERAL SEATS
--->
				<cfset showWindowAisle = false />
				<cfloop array="#rc.Air.Carriers#" item="sCarrier">
					<cfif NOT listFind('WN,F9', sCarrier)>
						<cfset showWindowAisle = true />
					</cfif>
				</cfloop>
				<cfif showWindowAisle>
					<select name="windowAisle" id="windowAisle">
						<option value="">SEATS</option>
						<option value="Window">WINDOW</option>
						<option value="Aisle">AISLE</option>
					</select>
					<br />
				</cfif>
<!---
SPECIAL REQUEST
--->
				<cfif rc.showAll
					OR rc.Policy.Policy_AllowRequests>
					<input name="specialRequests" id="specialRequests" class="input-block-level" type="text" placeholder="Add notes for our Travel Consultants (unused ticket credits, etc.)#(rc.fees.requestFee NEQ 0 ? 'for a #DollarFormat(rc.fees.requestFee)# fee' : '')#" style="margin-top:5px;">
				</cfif>

			</div>

		</div>
		

	</cfif>


#View('modal/popup')#


</cfoutput>

