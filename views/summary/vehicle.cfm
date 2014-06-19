<cfoutput>

	<cfif rc.vehicleSelected>
		<br class="clearfix">

		<!--- <div class="carrow" style="padding:0 0 15px 0;"> --->

			<div style="float:right;padding-right:20px;"><a href="#buildURL('car.availability?SearchID=#rc.searchID#')#" style="color:##666">change / remove <span class="icon-remove-sign"></a></div><br>

			<table width="1000">
			<tr>

				<td></td>
				
				<td valign="top">

					
					<cfif rc.Vehicle.getCorporate() IS TRUE AND rc.Vehicle.getPreferred() IS TRUE>
						<span class="ribbon ribbon-l-pref-cont"></span>
					<cfelseif rc.Vehicle.getPreferred() IS TRUE>
						<span class="ribbon ribbon-l-pref"></span>
					<cfelseif rc.Vehicle.getCorporate() IS TRUE>
						<span class="ribbon ribbon-l-cont"></span>
					</cfif>

					<h2>CAR</h2>

				</td>

				<td colspan="3">

					#(rc.Vehicle.getPolicy() ? '' : '<span rel="tooltip" class="outofpolicy" title="#ArrayToList(rc.Vehicle.getAPolicies())#" style="float:left; width:114px;">OUT OF POLICY *</span>')#

					<!--- All accounts when out of policy --->
					<cfif rc.showAll 
						OR (NOT rc.Vehicle.getPolicy()
						AND rc.Policy.Policy_CarReasonCode EQ 1)>
						<select name="carReasonCode" id="carReasonCode" class="input-xlarge #(structKeyExists(rc.errors, 'carReasonCode') ? 'error' : '')#">
						<option value="">Select Reason for Booking Outside Policy</option>
						<option value="D">Required car vendor does not provide service at origination and/or destination</option>
						<option value="S">Required car size sold out</option>
						<option value="V">Required car vendor sold out</option>
						<option value="M">Required a larger car size due to additional travelers/equipment</option>
						<option value="C">Preferred vendor rate was higher than another company</option>
						<option value="L">Leisure Rental (paying for it themselves)</option>
						</select> <br><br>

					</cfif>

					<!--- STATE OF TEXAS --->
					<cfif rc.showAll 
						OR rc.Filter.getAcctID() EQ 235>
						<div class="#(structKeyExists(rc.errors, 'udid111') ? 'error' : '')#">
							<span style="float:left; width:114px;">STATE OF TEXAS *</span>
							<select name="udid111" id="udid111" class="input-xlarge">
							<option value="">Select an Exception Code</option>
							<cfloop query="rc.qTXExceptionCodes">
								<option value="#rc.qTXExceptionCodes.FareSavingsCode#">#rc.qTXExceptionCodes.Description#</option>
							</cfloop>
							</select>
							<a href="http://www.window.state.tx.us/procurement/prog/stmp/exceptions-to-the-use-of-stmp-contracts/" target="_blank">View explanation of codes</a><br><br>
						</div>
					</cfif>

				</td>

			</tr>
			<tr>

				<td width="50"></td>
				
				<td valign="top" width="120">

					<img alt="#rc.Vehicle.getVendorCode()#" src="assets/img/cars/#rc.Vehicle.getVendorCode()#.png">

				</td>

				<td width="600">

					<strong>
						#uCase(application.stCarVendors[rc.Vehicle.getVendorCode()])#<br>
					</strong>

					<strong>
						<!--- <cfif rc.Vehicle.getLocation() EQ 'TERMINAL'>
							ON
						</cfif>
						#uCase(rc.Vehicle.getLocation())#<br> --->
					</strong>

					#uCase(rc.Vehicle.getVehicleClass())# 
					<cfif rc.Vehicle.getDoorCount() NEQ ''>
						#rc.Vehicle.getDoorCount()# DOOR
					</cfif><br>

					<strong>
						<table>
						<tr>
						<td width="240" valign="top">
							PICK-UP: #uCase(dateFormat(rc.Filter.getCarPickUpDateTime(), 'mmm d'))# #uCase(timeFormat(rc.Filter.getCarPickUpDateTime(), 'h:mm tt'))#<br />
							<cfif rc.Vehicle.getPickUpLocationType() EQ 'CityCenterDowntown' AND rc.Vehicle.getPickUpLocationID()>
								<cfset local.vehicleLocation = session.searches[rc.searchID].vehicleLocations[rc.Filter.getCarPickUpAirport()] />
								<cfset local.locationKey = ''>
								<cfset local.pickupLocation = ''>
								<cfloop array="#local.vehicleLocation#" index="local.locationIndex" item="local.location">
									<cfif rc.Vehicle.getPickupLocationID() EQ location.vendorLocationID>
										<cfset local.locationKey = local.locationIndex>
										<cfbreak>
									</cfif>
								</cfloop>
								<cfset pickupLocation = application.stCarVendors[local.vehicleLocation[local.locationKey].vendorCode] & ' - '
									& local.vehicleLocation[local.locationKey].street & ' ('
									& local.vehicleLocation[local.locationKey].city & ')' />
								#pickupLocation#
							<cfelseif rc.Vehicle.getPickUpLocationType() EQ 'ShuttleOffAirport'>
								#rc.Filter.getCarPickupAirport()#<br />
								SHUTTLE OFF TERMINAL
							<cfelseif rc.Vehicle.getPickUpLocationType() EQ 'Terminal'>
								#rc.Filter.getCarPickupAirport()#<br />
								ON TERMINAL
							<cfelse>
								#rc.Filter.getCarPickupAirport()#<br />
							</cfif>
						</td>
						<td valign="top">
							DROP-OFF: #uCase(DateFormat(rc.Filter.getCarDropOffDateTime(), 'mmm d'))# #uCase(timeFormat(rc.Filter.getCarDropOffDateTime(), 'h:mm tt'))#<br />
							<cfif rc.Vehicle.getDropOffLocationType() EQ 'CityCenterDowntown' AND rc.Vehicle.getDropOffLocationID()>
								<cfset local.vehicleLocation = session.searches[rc.searchID].vehicleLocations[rc.Filter.getCarDropoffAirport()] />
								<cfset local.locationKey = ''>
								<cfset local.dropoffLocation = ''>
								<cfloop array="#vehicleLocation#" index="local.locationIndex" item="local.location">
									<cfif rc.Vehicle.getDropoffLocationID() EQ location.vendorLocationID>
										<cfset local.locationKey = local.locationIndex>
										<cfbreak>
									</cfif>
								</cfloop>
								<cfset dropoffLocation = application.stCarVendors[local.vehicleLocation[local.locationKey].vendorCode] & ' - '
									& local.vehicleLocation[local.locationKey].street & ' ('
									& local.vehicleLocation[local.locationKey].city & ')' />
								#dropoffLocation#
							<cfelseif rc.Vehicle.getDropOffLocationType() EQ 'ShuttleOffAirport'>
								#rc.Filter.getCarDropoffAirport()#<br />
								SHUTTLE OFF TERMINAL
							<cfelseif rc.Vehicle.getDropOffLocationType() EQ 'Terminal'>
								#rc.Filter.getCarDropoffAirport()#<br />
								ON TERMINAL
							<cfelse>
								#rc.Filter.getCarDropoffAirport()#<br />
							</cfif>
						</td>
						</tr>
						</table>
						<br>
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
