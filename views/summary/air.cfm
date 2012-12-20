<cfoutput>
	<cfif bAir>
		<cfset bAirPolicy = (ArrayLen(stItinerary.Air.aPolicies) GT 0 ? false : true)>
		<table width="100%">
		<tr>
			<td colspan="2">
			<strong>FLIGHT</strong>
			#(NOT bAirPolicy ? 'Your flight is outside of policy.' : '')#
			<span style="float:right;"><a href="#buildURL('air.lowfare?Search_ID=#rc.nSearchID#')#">edit</a></span>
			<br><br>
			</td>
		</tr>
		<tr>
		<cfloop collection="#stItinerary.Air.Groups#" item="nGroup" >
			<td width="50%">
				<table width="100%">
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
		</tr>			
		</table>
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
		<cfif NOT bAirPolicy>
			<span style="float:right;"><a href="#buildURL('air.lowfare?Search_ID=#rc.nSearchID#')#">Search Flights Inside Policy</a></span>
		</cfif>
	</cfif>
</cfoutput>