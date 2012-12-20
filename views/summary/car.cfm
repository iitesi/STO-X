<cfoutput>
	<cfif bCar>
		<cfset bCarPolicy = (ArrayLen(stItinerary.Car.aPolicies) GT 0 ? false : true)>
		<table width="100%">
		<tr>
			<td>
			<strong>CAR</strong>
			#(NOT bCarPolicy ? 'Your car is outside of policy.' : '')#
			<span style="float:right;"><a href="#buildURL('car.availability?Search_ID=#rc.nSearchID#')#">edit</a></span>
			<br><br>
			</td>
		</tr>
		<tr>
			<td>
				#application.stCarVendors[stItinerary.Car.VendorCode]#
			</td>
		</tr>
		<tr>
			<td>
				#stItinerary.Car.VehicleClass# #stItinerary.Car.DoorCount#
			</td>
		</tr>
		<tr>
			<td>
				PICK-UP #DateFormat(session.searches[rc.nSearchID].dPickUp, 'mmm d,')# #TimeFormat(session.searches[rc.nSearchID].dPickUp, 'h:mm tt')#
			</td>
		</tr>
		<tr>
			<td>
				DROP-OFF #DateFormat(session.searches[rc.nSearchID].dDropOff, 'mmm d,')# #TimeFormat(session.searches[rc.nSearchID].dDropOff, 'h:mm tt')#
			</td>
		</tr>
		</table>
		<!--- All accounts when out of policy --->
		<cfif NOT bCarPolicy
		AND stPolicy.Policy_CarReasonCode EQ 1>
			<select name="Car_ReasonCode1" id="Car_ReasonCode1">
			<option value="">SELECT REASON FOR BOOKING OUTSIDE POLICY</option>
			<option value="D">Required car vendor does not provide service at destination</option>
			<option value="S">>Required car size sold out</option>
			<option value="V">Required car vendor sold out</option>
			<option value="M">Required a larger car size due to ## of travelers/equipment</option>
			<option value="C">Required rental rate was higher than another company</option>
			<option value="L">Leisure Rental (paying for it themselves)</option>
			</select>
		</cfif>
		<!--- STATE OF TEXAS --->
		<cfif session.Acct_ID EQ 235>
			<p>
				<label for="UDID1111">Exception code for Car</label>
				<select name="UDID1111" id="UDID1111">
				<option value="">SELECT AN EXCEPTION CODE</option>
				<cfloop query="rc.qTXExceptionCodes">
					<option value="#rc.qTXExceptionCodes.FareSavingsCode#">#rc.qTXExceptionCodes.Description#</option>
				</cfloop>
				</select>
			</p>
		</cfif>
		<cfif NOT bCarPolicy>
			<span style="float:right;"><a href="#buildURL('car.availability?Search_ID=#rc.nSearchID#')#">Search Cars Inside Policy</a></span>
		</cfif>
	</cfif>
</cfoutput>