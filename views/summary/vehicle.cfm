<cfoutput>

	<cfif rc.vehicleSelected>
		<br class="clearfix">

		<!--- <div class="carrow" style="padding:0 0 15px 0;"> --->

			<div style="float:right;padding-right:20px;"><a href="#buildURL('car.availability?SearchID=#rc.searchID#')#" style="color:##666">change / remove <span class="icon-remove-sign"></a></div><br>

			<table width="1000">
			<tr>

				<td></td>
				
				<td valign="top">

					
					<cfif rc.Vehicle.getCorporate()
						AND rc.Vehicle.getPreferred()>
						<span class="ribbon ribbon-l-pref-cont"></span>
					<cfelseif rc.Vehicle.getPreferred()>
						<span class="ribbon ribbon-l-pref"></span>
					<cfelseif rc.Vehicle.getCorporate()>
						<span class="ribbon ribbon-l-cont"></span>
					</cfif>

					<h2>CAR</h2>

				</td>

				<td colspan="3">

					#(rc.Vehicle.getPolicy() ? '' : '<span rel="tooltip" class="outofpolicy" title="#ArrayToList(rc.Vehicle.getAPolicies())#">OUT OF POLICY</span>&nbsp;&nbsp;&nbsp;')#

					<!--- All accounts when out of policy --->
					<cfif rc.showAll 
						OR (NOT rc.Vehicle.getPolicy()
						AND rc.Policy.Policy_CarReasonCode EQ 1)>

						<select name="carReasonCode" id="carReasonCode" class="input-xlarge #(structKeyExists(rc.errors, 'carReasonCode') ? 'error' : '')#">
						<option value="">Select Reason for Booking Outside Policy</option>
						<option value="D">Required car vendor does not provide service at destination</option>
						<option value="S">Required car size sold out</option>
						<option value="V">Required car vendor sold out</option>
						<option value="M">Required a larger car size due to ## of travelers/equipment</option>
						<option value="C">Required rental rate was higher than another company</option>
						<option value="L">Leisure Rental (paying for it themselves)</option>
						</select> &nbsp;&nbsp;&nbsp; <i>(required)</i><br><br>

					</cfif>

					<!--- STATE OF TEXAS --->
					<cfif rc.showAll 
						OR rc.Filter.getAcctID() EQ 235>

						<select name="udid111" id="udid111" class="input-xlarge #(structKeyExists(rc.errors, 'udid111') ? 'error' : '')#">
						<option value="">Select an Exception Code</option>
						<cfloop query="rc.qTXExceptionCodes">
							<option value="#rc.qTXExceptionCodes.FareSavingsCode#">#rc.qTXExceptionCodes.Description#</option>
						</cfloop>
						</select> &nbsp;&nbsp;&nbsp; <i>(required)</i><br><br>
						<a href="http://www.window.state.tx.us/procurement/prog/stmp/exceptions-to-the-use-of-stmp-contracts/" target="_blank">View explanation of codes</a><br><br>

					</cfif>

				</td>

			</tr>
			<tr>

				<td width="50"></td>
				
				<td valign="top" width="120">

					<img alt="#rc.Vehicle.getVendorCode()#" src="assets/img/cars/#rc.Vehicle.getVendorCode()#.png">

				</td>

				<td width="200">

					<strong>
						#uCase(application.stCarVendors[rc.Vehicle.getVendorCode()])#<br>
					</strong>

					<strong>
						<cfif rc.Vehicle.getLocation() EQ 'TERMINAL'>
							ON
						</cfif>
						#uCase(rc.Vehicle.getLocation())#<br>
					</strong>

					#uCase(rc.Vehicle.getVehicleClass())# 
					<cfif rc.Vehicle.getDoorCount() NEQ ''>
						#rc.Vehicle.getDoorCount()# DOOR
					</cfif><br>

					<strong>
						PICK-UP:
						#uCase(dateFormat(rc.Filter.getCarPickUpDateTime(), 'mmm d'))# #uCase(timeFormat(rc.Filter.getCarPickUpDateTime(), 'h:mm tt'))# (#rc.Filter.getCarPickupAirport()#)<br>
					</strong>

				</td>

				<td valign="bottom" width="430">

					<strong>
						DROP-OFF: 
						#uCase(DateFormat(rc.Filter.getCarDropOffDateTime(), 'mmm d'))# #uCase(timeFormat(rc.Filter.getCarDropOffDateTime(), 'h:mm tt'))# (#rc.Filter.getCarDropoffAirport()#)

					</strong>

				</td>

				<td width="200" valign="top">

					<span class="blue bold large">
						#(rc.Vehicle.getCurrency() EQ 'USD' ? DollarFormat(rc.Vehicle.getEstimatedTotalAmount()) : rc.Vehicle.getEstimatedTotalAmount()&' '&rc.Vehicle.getCurrency())#<br>
					</span>

					Estimated Total<br>
					Taxes quoted at pick-up<br>

					<span class="blue bold">
						<a rel="popover" data-original-title="Car payment and cancellation policy" data-content="Payment is taken by the vendor. You may cancel at anytime for no fee." href="##" />
							Car payment and cancellation policy
						</a>
					</span>

				</td>
			<tr>

			<tr>
				<td colspan="5"><br></td>		
			</tr>

			<tr>

				<td></td>
				<td></td>
				
				<td colspan="3">

					#uCase(application.stCarVendors[rc.Vehicle.getVendorCode()])# LOYALTY ##
					<input type="text" name="carFF" id="carFF" maxlength="20" class="input-medium">
				
				</td>

			</tr>
			</table>
		<!--- </div> --->

	</cfif>

</cfoutput>
