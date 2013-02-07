<cfoutput>
	<cfif Air>
		<br><br clear="both">
		<div class="summarydiv" style="background-color: ##FFF">
			<cfset AirPolicy = (ArrayLen(stItinerary.Air.aPolicies) GT 0 ? false : true)>
			<table width="1000">
			<tr>
<!--- 
HEADING
--->
				<td colspan="5">
                    <div class="underline-heading">
                        <h2>Flights</h2>
						#(NOT AirPolicy ? 'Your flight is outside of policy.' : '')#
				        <span style="float:right;"><a href="#buildURL('air.lowfare?SearchID=#rc.SearchID#')#" style="color:##666">Edit Flights</a>
                    </div>
				</td>
			</tr>
			<tr>
<!--- 
DETAILS
--->
				<cfloop collection="#stItinerary.Air.Groups#" item="Group" >
					<td>
						
						<table width="300">
						<cfset stGroup = stItinerary.Air.Groups[Group]>
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
					<cfset bTotalTrip = bTotalTrip + stItinerary.Air.Total>
					<span class="blue bold large">#DollarFormat(stItinerary.Air.Total)#</span><br>
					<span class="blue">
						#(stItinerary.Air.Class EQ 'Y' ? 'Economy' : (stItinerary.Air.Class EQ 'C' ? 'Business' : 'First'))#<br>
						#(stItinerary.Air.Ref ? 'Refundable' : 'Nonrefundable')#
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
					<cfif NOT AirPolicy
					AND rc.Policy.Policy_AirReasonCode EQ 1>
							<td>
								Reason for booking outside of policy
							</td>
							<td>
								<select name="Air_ReasonCode1" id="Air_ReasonCode1">
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
					<cfif stItinerary.Air.Total GT nLowestFare
					AND (AirPolicy OR rc.Policy.Policy_AirReasonCode EQ 0)
					AND rc.Policy.Policy_AirLostSavings EQ 1>
							<td>
								Reason for not booking the lowest fare
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
					<cfelseif stItinerary.Air.Total EQ nLowestFare>
						<input type="hidden" name="LostSavings" value="C">
					</cfif>
<!---
GENERAL SEAT ASSIGNMENTS
--->
					<cfif NOT ArrayFind(stItinerary.Air.Carriers, 'WN')
					AND NOT ArrayFind(stItinerary.Air.Carriers, 'FL')><!--- NOT (rc.segmentsair.Carrier EQ 'DL' AND Left(rc.segmentsair.Fare_Basis, 1) EQ 'E') --->
							<td>
								General Seat Selection
							</td>
							<td>
								<select name="Seats" id="Seats">
								<option value="">GENERAL SEAT SELECTION</option>
								<option value="A" <cfif stTraveler.Window_Aisle EQ 'A'>selected</cfif>>AISLE SEATS</option>
								<option value="W" <cfif stTraveler.Window_Aisle EQ 'W'>selected</cfif>>WINDOW SEATS</option>
								</select>
							</td>
						<cfset nTD++><cfif nTD EQ 2></tr><tr><cfset nTD = 0></cfif>
							<td>
								Specific Seat Seletion
							</td>
							<td>
								<a href="?action=air.popup&sDetails=seatmap&SearchID=#rc.SearchID#&nTripID=#stItinerary.Air.nTrip#&Group=&bSelection=1" class="overlayTrigger" target="_blank">
									Seat Maps
									<cfloop collection="#stItinerary.Air.Groups#" index="GroupKey" item="stGroup">
										<cfloop collection="#stGroup.Segments#" index="sSegKey" item="stSegment">
											<cfset sFieldName = '#stSegment.Carrier##stSegment.FlightNumber##stSegment.Origin##stSegment.Destination#'>
											<cfparam name="session.searches[#rc.SearchID#].stTravelers[nTraveler].stSeats.#sFieldName#" default="">
											<input type="text" name="Seat#sFieldName#_view" id="Seat#sFieldName#_view" size="3" maxlength="4" value="#session.searches[rc.SearchID].stTravelers[nTraveler].stSeats[sFieldName]#" disabled>
											<input type="hidden" name="Seat#sFieldName#" id="Seat#sFieldName#" value="#session.searches[rc.SearchID].stTravelers[nTraveler].stSeats[sFieldName]#">
										</cfloop>
									</cfloop>
								</a>
							</td>
						<cfset nTD++><cfif nTD EQ 2></tr><tr><cfset nTD = 0></cfif>
					<cfelse>
						<input type="hidden" name="Seat#i#" value="">
					</cfif>
<!---
FREQUENT PROGRAM NUMBER
--->
					<cfloop array="#stItinerary.Air.Carriers#" item="sCarrier">
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
								Notes for our travel consultants #(rc.stFees.nRequestFee NEQ 0 ? 'for a #DollarFormat(rc.stFees.nRequestFee)# fee' : '')#
							</td>
							<td>
								<textarea name="Special_Requests" id="Special_Requests" cols="40" rows="1" placeholder="" style="height:15px;"></textarea>
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
							<option value="BLND">Blind</option>
							<option value="DEAF">Deaf</option>
							<option value="UMNR">Unaccompanied Minor</option>
							<option value="WCHR">Wheelchair</option>
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