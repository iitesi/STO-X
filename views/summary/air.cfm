<cfoutput>
	<cfif bAir>
		<br><br>
		<div class="summarydiv background">
			<cfset bAirPolicy = (ArrayLen(stItinerary.Air.aPolicies) GT 0 ? false : true)>
			<table width="1000">
			<tr>
<!--- 
HEADING
--->
				<td colspan="5">
					<span class="bold large">FLIGHT</span>
					#(NOT bAirPolicy ? 'Your flight is outside of policy.' : '')#
					<span style="float:right;"><a href="#buildURL('air.lowfare?Search_ID=#rc.nSearchID#')#" style="color:##666">change flight <div class="close">x</div></a>
				</td>
			</tr>
			<tr>
<!--- 
DETAILS
--->
				<cfloop collection="#stItinerary.Air.Groups#" item="nGroup" >
					<td>
						
						<table width="300">
						<cfset stGroup = stItinerary.Air.Groups[nGroup]>
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
				<td colspan="#nGroup+1#">
<!---
OUT OF POLICY
--->
					<!---
					If they are out of policy
					AND they want to capture reason codes
					--->
					<cfif NOT bAirPolicy
					AND stPolicy.Policy_AirReasonCode EQ 1>
						<select name="Air_ReasonCode1" id="Air_ReasonCode1">
						<option value="">SELECT REASON FOR BOOKING OUTSIDE POLICY</option>
						<cfloop query="rc.qOutOfPolicy">
							<option value="#rc.qOutOfPolicy.FareSavingsCode#">#rc.qOutOfPolicy.Description#</option>
						</cfloop>
						</select>
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
					AND (bAirPolicy OR stPolicy.Policy_AirReasonCode EQ 0)
					AND stPolicy.Policy_AirLostSavings EQ 1>
						<select name="LostSavings" id="LostSavings">
						<option value="">SELECT REASON FOR NOT BOOKING THE LOWEST FARE</option>
						<cfloop query="rc.qOutOfPolicy">
							<option value="#rc.qOutOfPolicy.FareSavingsCode#">#rc.qOutOfPolicy.Description#</option>
						</cfloop>
						</select>
					<!---
					If the fare is the same
					--->
					<cfelseif stItinerary.Air.Total EQ nLowestFare>
						<input type="hidden" name="LostSavings" value="C">
					</cfif>
<!---
SPECIAL REQUEST
--->
					<cfif stPolicy.Policy_AllowRequests EQ 1>
						<textarea name="Special_Requests" id="Special_Requests" cols="55" rows="1" placeholder="Notes for our travel consultants #(rc.stFees.nRequestFee NEQ 0 ? 'for a #DollarFormat(rc.stFees.nRequestFee)# fee' : '')#" style="height:15px;"></textarea>
					</cfif>
<!---
GENERAL SEAT ASSIGNMENTS
--->
					<cfif NOT ArrayFind(stItinerary.Air.Carriers, 'WN')><!--- NOT (rc.segmentsair.Carrier EQ 'DL' AND Left(rc.segmentsair.Fare_Basis, 1) EQ 'E') --->
						<select name="Seats" id="Seats">
						<option value="">GENERAL SEAT SELECTION</option>
						<option value="A" <cfif stTraveler.Window_Aisle EQ 'A'>selected</cfif>>AISLE SEATS</option>
						<option value="W" <cfif stTraveler.Window_Aisle EQ 'W'>selected</cfif>>WINDOW SEATS</option>
						</select>
					<cfelse>
						<input type="hidden" name="Seat#i#" value="">
					</cfif>
<!---
FREQUENT PROGRAM NUMBER
--->
					<cfloop array="#stItinerary.Air.Carriers#" item="sCarrier">
						<strong>#sCarrier# ##</strong>
						<input type="text" name="Air_FF#sCarrier#" id="Air_FF#sCarrier#" size="18" maxlength="20" placeholder="Frequent Flyer Number">
					</cfloop>
<!---
ADDITIONAL REQUESTS
--->
					<select name="Service_Requests" id="Service_Requests">
					<option value="">SPECIAL REQUESTS</option>
					<option value="BLND">Blind</option>
					<option value="DEAF">Deaf</option>
					<option value="UMNR">Unaccompanied Minor</option>
					<option value="WCHR">Wheelchair</option>
					</select>

				</td>
				<td>
				</td>
			</tr>
			</table>
		</div>
	</cfif>
</cfoutput>