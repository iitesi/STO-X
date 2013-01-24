<cfoutput>
	<cfif bAir>
		<br><br>
		<div class="summarydiv background">
			<cfset sCarCurr = Left(stItinerary.Car.EstimatedTotalAmount, 3)>
			<cfset sCarTotal = Mid(stItinerary.Car.EstimatedTotalAmount, 4)>
			<cfset bCarPolicy = (ArrayLen(stItinerary.Car.aPolicies) GT 0 ? false : true)>
			<table width="1000">
			<tr>
<!--- 
HEADING
--->
				<td colspan="2">
					<h4>CAR</h4>
					#(NOT bCarPolicy ? 'Your car is outside of policy.' : '')#
					<span style="float:right;"><a href="#buildURL('car.availability?Search_ID=#rc.nSearchID#')#" style="color:##666">change car <div class="close">x</div></a>
				</td>
			<tr>
			</tr>
<!--- 
DETAILS
--->
				<td>
					#application.stCarVendors[stItinerary.Car.VendorCode]#<br>
					#stItinerary.Car.VehicleClass# #stItinerary.Car.DoorCount#<br>
					Pick-up #DateFormat(session.searches[rc.nSearchID].dPickUp, 'mmm d,')# #TimeFormat(session.searches[rc.nSearchID].dPickUp, 'h:mm tt')#<br>
					Drop-off #DateFormat(session.searches[rc.nSearchID].dDropOff, 'mmm d,')# #TimeFormat(session.searches[rc.nSearchID].dDropOff, 'h:mm tt')#
				</td>
<!--- 
COST
--->
				<td width="100">
					<cfset bTotalTrip = (sCarCurr EQ 'USD' ? bTotalTrip + sCarTotal : 'CURR')>
					<span class="blue bold large">#(sCarCurr EQ 'USD' ? DollarFormat(sCarTotal) : sCarTotal&' '&sCarCurr)#</span><br>
					<span class="blue">
						Estimated total<br>
						Taxes quoted at counter
					</span>

				</td>
			</tr>
			<tr>
				<td>
<!---
OUT OF POLICY
--->
					<!--- All accounts when out of policy --->
					<cfif NOT bCarPolicy
					AND stPolicy.Policy_CarReasonCode EQ 1>
						<select name="Car_ReasonCode" id="Car_ReasonCode">
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
						<label for="UDID1111">Exception code for Car</label>
						<select name="UDID1111" id="UDID1111">
						<option value="">SELECT AN EXCEPTION CODE</option>
						<cfloop query="rc.qTXExceptionCodes">
							<option value="#rc.qTXExceptionCodes.FareSavingsCode#">#rc.qTXExceptionCodes.Description#</option>
						</cfloop>
						</select>
					</cfif>
<!---
FREQUENT PROGRAM NUMBER
--->
					#application.stCarVendors[stItinerary.Car.VendorCode]# ##
					<input type="text" name="Car_FF" id="Car_FF" size="18" maxlength="20" placeholder="Enter Loyalty Number">
				</td>
				<td>
					
				</td>
			</tr>
			</table>
		</div>
	</cfif>
</cfoutput>