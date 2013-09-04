<cfoutput>

	<cfif rc.airSelected>
		<cfset lowestFareTripID = session.searches[rc.searchid].stLowFareDetails.aSortFare[1] />
		<cfset lowestFare = session.searches[rc.searchid].stTrips[lowestFareTripID].Total />
		<cfset inPolicy = (ArrayLen(rc.Air.aPolicies) GT 0 ? false : true)>

		<input type="hidden" name="airLowestFare" value="#lowestFare#">

		<div style="float:right;padding-right:20px;"><a href="#buildURL('air.lowfare?SearchID=#rc.searchID#')#" style="color:##666">change <span class="icon-remove-sign"></a></div><br>

		<table width="1000">
		<tr>

			<td></td>

			<td valign="top">

				<cfif rc.Air.privateFare AND rc.Air.preferred>
					<span class="ribbon ribbon-l-pref-cont"></span>
				<cfelseif rc.Air.preferred>
					<span class="ribbon ribbon-l-pref"></span>
				<cfelseif rc.Air.privateFare>
					<span class="ribbon ribbon-l-cont"></span>
				</cfif>

				<h2>FLIGHT</h2>

			</td>

			<td colspan="2">

				#(rc.Air.Policy ? '' : '<span rel="tooltip" class="outofpolicy" title="#ArrayToList(rc.Air.aPolicies)#">OUT OF POLICY</span>&nbsp;&nbsp;&nbsp;')#

				<!---
				If they are out of policy
				AND they want to capture reason codes
				--->
				<cfif rc.showAll
					OR (NOT inPolicy
					AND rc.Policy.Policy_AirReasonCode EQ 1)>
					*&nbsp;&nbsp;
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
					*&nbsp;&nbsp;
					<div class="#(structKeyExists(rc.errors, 'lostSavings') ? 'error' : '')#">
						<select name="lostSavings" id="lostSavings" class="input-xlarge">
						<option value="">Select Reason for Not Booking the Lowest Fare</option>
						<cfloop query="rc.qOutOfPolicy">
							<option value="#rc.qOutOfPolicy.FareSavingsCode#">#rc.qOutOfPolicy.Description#</option>
						</cfloop>
						</select> <br><br>
					</div>

				<!---
				If the fare is the same
				--->
				<cfelseif rc.Air.Total EQ lowestFare>

					<input type="hidden" name="lostSavings" value="C">

				</cfif>

				<!--- State of Texas --->
				<cfif rc.showAll
					OR rc.Filter.getAcctID() EQ 235>
					*&nbsp;&nbsp;
					<div class="#(structKeyExists(rc.errors, 'udid113') ? 'error' : '')#">
						<select name="udid113" id="udid113" class="input-xlarge">
						<option value="">Select an Exception Code</option>
						<cfloop query="rc.qTXExceptionCodes">
							<option value="#rc.qTXExceptionCodes.FareSavingsCode#">#rc.qTXExceptionCodes.Description#</option>
						</cfloop>
						</select>
						<a href="http://www.window.state.tx.us/procurement/prog/stmp/exceptions-to-the-use-of-stmp-contracts/" target="_blank">View explanation of codes</a><br><br>
					</div>

				</cfif>

			</td>

		<tr>
		<tr>

			<td width="50"></td>

			<td valign="top" width="120">

				<img class="carrierimg" src="assets/img/airlines/#(ArrayLen(rc.Air.Carriers) EQ 1 ? rc.Air.Carriers[1] : 'Mult')#.png"><br>

				#(ArrayLen(rc.Air.Carriers) EQ 1 ? '<br />'&application.stAirVendors[rc.Air.Carriers[1]].Name : '<br />Multiple Carriers')#

			</td>

			<td width="630">
				<cfset seatFieldNames = ''>
				<table width="600" padding="0" align="center">
				<cfloop collection="#rc.Air.Groups#" item="group" index="groupIndex">
					<cfset count = 0>
					<cfloop collection="#group.Segments#" item="segment" index="segmentIndex">
						<cfset count++>
						<tr>
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
								#timeFormat(segment.DepartureTime, 'h:mmt')# - #timeFormat(segment.ArrivalTime, 'h:mmt')#
							</td>

							<td>
								#uCase(segment.Cabin)#
							</td>

<!--- seats --->
							<td id="#segmentIndex#">
								<cfif NOT listFind('WN,F9', segment.Carrier)><!--- Exclude Southwest and Frontier --->
									<cfset sURL = 'SearchID=#rc.SearchID#&amp;nTripID=#rc.air.nTrip#&amp;nSegment=#segmentIndex#'>
									<a href="?action=air.summarypopup&amp;sDetails=seatmap&amp;summary=true&amp;#sURL#" class="summarySeatMapModal" data-toggle="modal" data-target="##popupModal" title="Select a seat for this flight">Seat Map</a>
									&nbsp; <span class="label label-success" id="segment_#segmentIndex#_display"></span>
									<input type="hidden" name="segment_#segmentIndex#" id="segment_#segmentIndex#" value="">
									<cfset seatFieldNames = listAppend(seatFieldNames, 'segment_#segmentIndex#')>
								</cfif>
							</td>

						</tr>
					</cfloop>
					<tr>
						<td colspan="6">
						<hr>
						</td>
					</tr>
				</cfloop>
				</table>
			</td>
			<input type="hidden" name="seatFieldNames" id="seatFieldNames" value="#seatFieldNames#">

			<td width="200" valign="top">
				<span class="blue bold large">
					#dollarFormat(rc.Air.Total)#<br>
				</span>

				Total including taxes and refunds<br>
				#(rc.Air.Ref ? 'Refundable' : 'No Refunds')#<br>
				<span class="blue bold">
					<a rel="popover" data-original-title="Flight Change / Cancellation Policy" data-content="Ticket is #(rc.Air.Ref ? '' : 'non-')#refundable.<br>Change USD #rc.Air.changePenalty# for reissue" href="##" />
						Flight change/cancellation policy
					</a>
				</span>

			</td>
		<tr>

		<tr>
			<td colspan="4"><br></td>
		</tr>

		<tr>

			<td></td>

			<td colspan="3">

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
				<option value="WCHR">WHEELCHAIR</option>
				</select>
				<br>
<!---
SPECIAL REQUEST
--->
				<cfif rc.showAll
					OR rc.Policy.Policy_AllowRequests>
					<input name="specialRequests" id="specialRequests" class="input-block-level" type="text" placeholder="Add notes for our Travel Consultants (unused ticket credits, etc.)#(rc.fees.requestFee NEQ 0 ? 'for a #DollarFormat(rc.fees.requestFee)# fee' : '')#" style="margin-top:5px;">
				</cfif>

			</td>

		</tr>
		</table>

	</cfif>


#View('modal/popup')#


</cfoutput>

