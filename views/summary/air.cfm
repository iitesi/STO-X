<cfoutput>

	<cfif rc.airSelected>
		<cfset lowestFareTripID = session.searches[rc.searchid].stLowFareDetails.aSortFare[1] />
		<cfset lowestFare = session.searches[rc.searchid].stTrips[lowestFareTripID].Total />
		<cfset inPolicy = (ArrayLen(rc.Air.aPolicies) GT 0 ? false : true)>

		<div class="carrow" style="padding:0 0 15px 0;">

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
					<cfif NOT inPolicy
						AND rc.Policy.Policy_AirReasonCode EQ 1>

						<select name="airReasonCode" id="airReasonCode" class="input-xlarge">
						<option value="">Select Reason for Booking Out of Policy</option>
						<cfloop query="rc.qOutOfPolicy">
							<option value="#rc.qOutOfPolicy.FareSavingsCode#">#rc.qOutOfPolicy.Description#</option>
						</cfloop>
						</select> &nbsp;&nbsp;&nbsp; <i>(required)</i><br><br>

					</cfif>

					<!---
					If the fare is higher than the lowest
					AND they are in policy OR the above drop down isn't showing
					AND they want to capture lost savings
					--->
					<cfif rc.Air.Total GT lowestFare
						AND (inPolicy OR rc.Policy.Policy_AirReasonCode EQ 0)
						AND rc.Policy.Policy_AirLostSavings EQ 1>

						<select name="lostSavings" id="lostSavings">
						<option value="">Select Reason for Not Booking the Lowest Fare</option>
						<cfloop query="rc.qOutOfPolicy">
							<option value="#rc.qOutOfPolicy.FareSavingsCode#">#rc.qOutOfPolicy.Description#</option>
						</cfloop>
						</select> &nbsp;&nbsp;&nbsp; <i>(required)</i><br><br>

					<!---
					If the fare is the same
					--->
					<cfelseif rc.Air.Total EQ lowestFare>

						<input type="hidden" name="lostSavings" value="C">

					</cfif>

					<!--- State of Texas --->
					<cfif rc.Filter.getAcctID() EQ 235>

						<select name="udid113" id="udid113" class="input-xlarge">
						<option value="">SELECT AN EXCEPTION CODE</option>
						<cfloop query="rc.qTXExceptionCodes">
							<option value="#rc.qTXExceptionCodes.FareSavingsCode#">#rc.qTXExceptionCodes.Description#</option>
						</cfloop>
						</select> &nbsp;&nbsp;&nbsp; <i>(required)</i><br><br>

					</cfif>

				</td>

			<tr>
			<tr>

				<td width="50"></td>
				
				<td valign="top" width="120">

					<img class="carrierimg" src="assets/img/airlines/#(ArrayLen(rc.Air.Carriers) EQ 1 ? rc.Air.Carriers[1] : 'Mult')#.png"><br>

					#(ArrayLen(rc.Air.Carriers) EQ 1 ? '<br />'&application.stAirVendors[rc.Air.Carriers[1]].Name : '<br />Multiple Carriers')#
					
				</td>

				<td with="630">

					<table width="600" padding="0" align="center">
					<cfloop collection="#rc.Air.Groups#" item="group" index="groupIndex" >
						<cfset count = 0>
						<cfloop collection="#group.Segments#" item="segment" index="segmentIndex" >
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
									#timeFormat(group.DepartureTime, 'h:mmt')# - #timeFormat(group.ArrivalTime, 'h:mmt')#
								</td>

								<td>
									#uCase(segment.Cabin)#
								</td>

								<td>
									Seat Map
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

				<td width="200" valign="top">

					<cfset tripTotal = tripTotal + rc.Air.Total>

					<span class="blue bold large">
						#dollarFormat(rc.Air.Total)#<br>
					</span>

					Total including taxes and refunds<br>
					#(rc.Air.Ref ? 'Refundable' : 'No Refunds')#<br>

					<span class="blue bold">
						Flight change/cancellation policy
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
SPECIAL REQUEST
--->
					<cfif rc.Policy.Policy_AllowRequests EQ 1>
						 <!--- #(rc.stFees.nRequestFee NEQ 0 ? 'for a #DollarFormat(rc.stFees.nRequestFee)# fee' : '')# --->

						<textarea name="specialRequests" id="specialRequests" cols="40" rows="1" placeholder="Notes for our travel consultants"> </textarea>
						&nbsp;&nbsp;&nbsp;

					</cfif>
<!---
ADDITIONAL REQUESTS
--->
					Special Requests
					<select name="serviceRequests" id="serviceRequests">
					<option value="">SPECIAL REQUESTS</option>
					<option value="BLND">BLIND</option>
					<option value="DEAF">DEAF</option>
					<option value="UMNR">UNACCOMPANIED MINOR</option>
					<option value="WCHR">WHEELCHAIR</option>
					</select>
				
				</td>

			</tr>
			</table>
		</div>

	</cfif>

</cfoutput>
