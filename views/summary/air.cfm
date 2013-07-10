<cfoutput>
	<cfif rc.airSelected>
		<cfset lowestFareTripID = session.searches[rc.searchid].stLowFareDetails.aSortFare[1] />
		<cfset lowestFare = session.searches[rc.searchid].stTrips[lowestFareTripID].Total />
		<br><br clear="both">
		<div class="summarydiv" style="background-color: ##FFF">
			<cfset inPolicy = (ArrayLen(rc.Air.aPolicies) GT 0 ? false : true)>
			<table width="1000">
			<tr>
<!--- 
HEADING
--->
				<td colspan="5">
                    <div class="underline-heading">
                        <h2>Flights</h2>
						#(NOT inPolicy ? 'Your flight is outside of policy.' : '')#
				        <span style="float:right;"><a href="#buildURL('air.lowfare?SearchID=#rc.SearchID#')#" style="color:##666">Edit Flights</a>
                    </div>
				</td>
			</tr>
			<tr>
<!--- 
DETAILS
--->
				<cfloop collection="#rc.Air.Groups#" item="Group" >
					<td>
						
						<table width="300">
						<cfset stGroup = rc.Air.Groups[Group]>
						<tr>
							<td class="medium" colspan="4">
								<strong>#DateFormat(stGroup.DepartureTime, 'ddd, mmm d')#</strong>
							</td>
						</tr>
						<cfloop collection="#stGroup.Segments#" item="nSegment" >
							<cfset stSegment = stGroup.Segments[nSegment]>
							<tr>
								<td>#stSegment.Carrier#</td>
								<td>#stSegment.FlightNumber#</td>
								<td>#stSegment.Origin# to #stSegment.Destination#</td>
								<td>#TimeFormat(stSegment.DepartureTime, 'h:mm tt')# to #TimeFormat(stSegment.ArrivalTime, 'h:mm tt')#</td>
							</tr>
						</cfloop>
						</table>
					</td>
				</cfloop>
<!--- 
COST
--->			
				<td width="100">
					<cfset tripTotal = tripTotal + rc.Air.Total>
					<span class="blue bold large">#DollarFormat(rc.Air.Total)#</span><br>
					<span class="blue">
						#(rc.Air.Class EQ 'Y' ? 'Economy' : (rc.Air.Class EQ 'C' ? 'Business' : 'First'))#<br>
						#(rc.Air.Ref ? 'Refundable' : 'Nonrefundable')#
					</span>
				</td>
			</tr>
			<tr>
				<td colspan="#Group+1#">
					<table width="100%">
<!---
OUT OF POLICY
--->
					<cfset nTD = 0>
					<tr>
					<!---
					If they are out of policy
					AND they want to capture reason codes
					--->
					<cfif NOT inPolicy
					AND rc.Policy.Policy_AirReasonCode EQ 1>
						<td>
							<label for="Air_ReasonCode">Reason for booking outside of policy</label>
						</td>
						<td>
							<select name="Air_ReasonCode" id="Air_ReasonCode">
							<option value=""></option>
							<cfloop query="rc.qOutOfPolicy">
								<option value="#rc.qOutOfPolicy.FareSavingsCode#">#rc.qOutOfPolicy.Description#</option>
							</cfloop>
							</select>
						</td>
						<cfset nTD++><cfif nTD EQ 2></tr><tr><cfset nTD = 0></cfif>
					</cfif>
<!---
NOT LOWEST FARE
--->
					<!---
					If the fare is higher than the lowest
					AND they are in policy OR the above drop down isn't showing
					AND they want to capture lost savings
					--->

					<cfif rc.Air.Total GT lowestFare
					AND (inPolicy OR rc.Policy.Policy_AirReasonCode EQ 0)
					AND rc.Policy.Policy_AirLostSavings EQ 1>
							<td>
								<label for="LostSavings">Reason for not booking the lowest fare</label>
							</td>
							<td>
								<select name="LostSavings" id="LostSavings">
								<option value=""></option>
								<cfloop query="rc.qOutOfPolicy">
									<option value="#rc.qOutOfPolicy.FareSavingsCode#">#rc.qOutOfPolicy.Description#</option>
								</cfloop>
								</select>
							</td>
						<cfset nTD++><cfif nTD EQ 2></tr><tr><cfset nTD = 0></cfif>
					<!---
					If the fare is the same
					--->
					<cfelseif rc.Air.Total EQ lowestFare>
						<input type="hidden" name="LostSavings" value="C">
					</cfif>
<!---
GENERAL SEAT ASSIGNMENTS
--->
					<cfif NOT ArrayFind(rc.Air.Carriers, 'WN')
					AND NOT ArrayFind(rc.Air.Carriers, 'FL')><!--- NOT (rc.segmentsair.Carrier EQ 'DL' AND Left(rc.segmentsair.Fare_Basis, 1) EQ 'E') --->
							<td>
								General Seat Selection
							</td>
							<td>
								<select name="Seats" id="Seats">
								<option value="">GENERAL SEAT SELECTION</option>
								<option value="A">AISLE SEATS</option>
								<option value="W">WINDOW SEATS</option>
								</select>
							</td>
							<cfset nTD++><cfif nTD EQ 2></tr><tr><cfset nTD = 0></cfif>
							 <td>
								Specific Seat Seletion
							</td>
							<td>
								Seat Maps
								<cfloop collection="#rc.Air.Groups#" index="GroupKey" item="stGroup">
									<cfloop collection="#stGroup.Segments#" index="sSegKey" item="stSegment">
										<cfset sFieldName = '#stSegment.Carrier##stSegment.FlightNumber##stSegment.Origin##stSegment.Destination#'>
										<input type="text" name="Seat#sFieldName#_view" id="Seat#sFieldName#_view" size="3" maxlength="4" class="input-small">
									</cfloop>
								</cfloop>
							</td>
						<cfset nTD++><cfif nTD EQ 2></tr><tr><cfset nTD = 0></cfif>
					<cfelse>
						<input type="hidden" name="Seat#i#" value="">
					</cfif>
<!---
FREQUENT PROGRAM NUMBER
--->
					<cfloop array="#rc.Air.Carriers#" item="sCarrier">
							<td>
								#sCarrier# Frequent Flyer Number
							</td>
							<td>
								<input type="text" name="Air_FF#sCarrier#" id="Air_FF#sCarrier#" size="18" maxlength="20">
							</td>
						<cfset nTD++><cfif nTD EQ 2></tr><tr><cfset nTD = 0></cfif>
					</cfloop>
<!---
SPECIAL REQUEST
--->
					<cfif rc.Policy.Policy_AllowRequests EQ 1>
							<td>
								Notes for our travel consultants <!--- #(rc.stFees.nRequestFee NEQ 0 ? 'for a #DollarFormat(rc.stFees.nRequestFee)# fee' : '')# --->
							</td>
							<td>
								<textarea name="Special_Requests" id="Special_Requests" cols="40" rows="1" placeholder=""> </textarea>
							</td>
						<cfset nTD++><cfif nTD EQ 2></tr><tr><cfset nTD = 0></cfif>
					</cfif>
<!---
ADDITIONAL REQUESTS
--->
						<td>
							Special Requests
						</td>
						<td>
							<select name="Service_Requests" id="Service_Requests">
							<option value="">SPECIAL REQUESTS</option>
							<option value="BLND">BLIND</option>
							<option value="DEAF">DEAF</option>
							<option value="UMNR">UNACCOMPANIED MINOR</option>
							<option value="WCHR">WHEELCHAIR</option>
							</select>
						</td>
					</tr>
					</table>
				</td>
				<td>
				</td>
			</tr>
			</table>
		</div>
	</cfif>
</cfoutput>