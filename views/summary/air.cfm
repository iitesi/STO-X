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
				<td class="bold large" width="150">
					<strong>FLIGHT</strong>
					<!--- <span style="float:right;"><a href="#buildURL('air.lowfare?Search_ID=#rc.nSearchID#')#">edit</a></span> --->
				</td>
<!--- 
DETAILS
--->
				<cfloop collection="#stItinerary.Air.Groups#" item="nGroup" >
					<td>
						#(NOT bAirPolicy ? 'Your flight is outside of policy.' : '')#
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
				<td width="150" class="right">
					<span class="blue bold large">#DollarFormat(stItinerary.Air.Total)#</span>
				</td>
			</tr>
			<tr>
				<td class="bold large" width="150">
				</td>
<!--- 
QUESTIONS
--->
				<td>
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

					<!--- <cfif rc.segmentsair.Carrier NEQ 'WN'
					AND NOT (rc.segmentsair.Carrier EQ 'DL' AND Left(rc.segmentsair.Fare_Basis, 1) EQ 'E')> --->
						<p>
							<select name="Seat" id="Seat">
							<option value="">GENERAL SEAT SELECTION</option>
							<option value="A">Aisle</option>
							<option value="W">Window</option>
							</select>
						</p>
					<!--- cfelse>
						<input type="hidden" name="Seat#i#" value="">
					</cfif> --->
					<p>
						<select name="Service_Requests" id="Service_Requests">
						<option value=""></option>
						<option value="BLND">Blind</option>
						<option value="DEAF">Deaf</option>
						<option value="UMNR">Unaccompanied Minor</option>
						<option value="WCHR">Wheelchair</option>
						</select>
					</p>
<!---
SPECIAL REQUEST
--->
					<!--- <cfif rc.policyair.Policy_AllowRequests EQ 1>
						<p>
							<label for="Special_Requests#i#">Special Requests</label>
							<textarea name="Special_Requests#i#" id="Special_Requests#i#" cols="50" rows="1">#variables.travelers[i]['Special_Requests']#</textarea>
							<cfif ListFindNoCase(rc.errors, 'Special_Requests#i#', ',')><img src="#application.serverurl#/assets/img/error.png" width="19"></cfif>
						</p>
						<cfif rc.processfees GT 0>
							<p>
								<label for=""></label>
								By entering special requests you will be charged
							</p>
							<p>
								<label for=""></label>
								an offline fee of #DollarFormat(rc.processfees)#.
							</p>
						</cfif>
					</cfif> --->
<!---
FREQUENT PROGRAM NUMBER
--->
				<cfloop array="#stItinerary.Air.Carriers#" item="sCarrier">
					<p>
						<input type="text" name="Air_FF#sCarrier##nTraveler#" id="Air_FF#sCarrier##nTraveler#" size="18" maxlength="20" placeholder="#sCarrier# Frequent Flyer Number">
					</p>
				</cfloop>

				</td>
				<td width="150">
				</td>
			</tr>
			</table>
			<!--- 
			<cfif NOT bAirPolicy>
				<span style="float:right;"><a href="#buildURL('air.lowfare?Search_ID=#rc.nSearchID#')#">Search Flights Inside Policy</a></span>
			</cfif> --->
		</div>
	</cfif>
</cfoutput>