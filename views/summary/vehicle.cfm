<cfoutput>

	<cfif rc.vehicleSelected>
		<!--- <div class="carrow" style="padding:0 0 15px 0;"> --->
			<div class="tripsummary-detail">
				<div class="row header">
					<div class="col s11">
					<cfif rc.Vehicle.getCorporate() IS TRUE AND rc.Vehicle.getPreferred() IS TRUE>
						<span class="ribbon ribbon-l-pref-cont"></span>
					<cfelseif rc.Vehicle.getPreferred() IS TRUE>
						<span class="ribbon ribbon-l-pref"></span>
					<cfelseif rc.Vehicle.getCorporate() IS TRUE>
						<span class="ribbon ribbon-l-cont"></span>
					</cfif>
						<h2>CAR</h2>
					</div>
					<div class="col s1">
						<a href="#buildURL('car.availability?SearchID=#rc.searchID#')#" 
						rel="popleft"
						data-content="Change or Remove"
						class="btn-floating btn-small waves-effect waves-light red  pull-right" 
						><i class="mdi mdi-restart"></i></a>
					</div>
				</div> <!-- ./row -->
				<div class="row">
					<div class="col s12">
					#(rc.Vehicle.getPolicy() ? '' : '<span rel="tooltip" class="outofpolicy" title="#ArrayToList(rc.Vehicle.getAPolicies())#" style="float:left; width:114px;">OUT OF POLICY *</span>')#

					<!--- All accounts when out of policy --->
					<cfif rc.showAll 
						OR (NOT rc.Vehicle.getPolicy()
						AND rc.Policy.Policy_CarReasonCode EQ 1)>
						<select name="carReasonCode" id="carReasonCode" class="form-control #(structKeyExists(rc.errors, 'carReasonCode') ? 'error' : '')#">
							<option value="">Select Reason for Booking Outside Policy</option>
							<cfloop query="rc.qOutOfPolicy_Car">
								<option value="#rc.qOutOfPolicy_Car.VehicleSavingsCode#">#rc.qOutOfPolicy_Car.Description#</option>
							</cfloop>
<!---
							<option value="D">Required car vendor does not provide service at origination and/or destination</option>
							<option value="S">Required car size sold out</option>
							<option value="V">Required car vendor sold out</option>
							<option value="M">Required a larger car size due to additional travelers/equipment</option>
							<option value="C">Preferred vendor rate was higher than another company</option>
							<option value="L">Leisure Rental (paying for it themselves)</option>
--->
						</select>

						<br><br>
					</cfif>

					<!--- STATE OF TEXAS --->
					<cfif rc.showAll 
						OR rc.Filter.getAcctID() EQ 235>
						<div class="#(structKeyExists(rc.errors, 'udid111') ? 'error' : '')#">
							<span style="float:left; width:114px;">STATE OF TEXAS *</span>
							<select name="udid111" id="udid111" class="form-control">
							<option value="">Select an Exception Code</option>
							<cfloop query="rc.qTXExceptionCodes">
								<option value="#rc.qTXExceptionCodes.FareSavingsCode#">#rc.qTXExceptionCodes.Description#</option>
							</cfloop>
							</select>
							<a href="http://www.window.state.tx.us/procurement/prog/stmp/exceptions-to-the-use-of-stmp-contracts/" target="_blank">View explanation of codes</a><br><br>
						</div>
					</cfif>
					</div>
				</div>

				<div class="row">
					<div class="col s12 m2">
						<img class="img-responsive " alt="#rc.Vehicle.getVendorCode()#" src="assets/img/cars/#rc.Vehicle.getVendorCode()#.png">
					</div>

					<div class="col s12 m7">

						<div class="card summary-details-card z-depth-1">
							<div class="card-content">
								<span class="card-title">
									#uCase(application.stCarVendors[rc.Vehicle.getVendorCode()])#
								</span>
								<p>
									#uCase(rc.Vehicle.getVehicleClass())# 
									<cfif rc.Vehicle.getDoorCount() NEQ ''>
										#rc.Vehicle.getDoorCount()# DOOR
									</cfif>
								</p>
								<p>
									Pick-up: <strong>#uCase(dateFormat(rc.Filter.getCarPickUpDateTime(), 'mmm d'))# #uCase(timeFormat(rc.Filter.getCarPickUpDateTime(), 'h:mm tt'))#</strong><br />
									Location:  <strong>
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
										#rc.Filter.getCarPickupAirport()#
										SHUTTLE OFF TERMINAL
									<cfelseif rc.Vehicle.getPickUpLocationType() EQ 'Terminal'>
										#rc.Filter.getCarPickupAirport()#
										ON TERMINAL
									<cfelse>
										#rc.Filter.getCarPickupAirport()#
									</cfif>
									</strong>
								</p>
								<p>
									Drop-off: <strong>#uCase(DateFormat(rc.Filter.getCarDropOffDateTime(), 'mmm d'))# #uCase(timeFormat(rc.Filter.getCarDropOffDateTime(), 'h:mm tt'))#</strong><br />
									Location: <strong>
									<cfif rc.Vehicle.getDropOffLocationType() EQ 'CityCenterDowntown'>
										<cfif len(rc.Vehicle.getDropOffLocationID())>
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
										<cfelse>
											<cfset local.dropoffLocation = local.pickupLocation />
										</cfif>
										#dropoffLocation#
									<cfelseif rc.Vehicle.getDropOffLocationType() EQ 'ShuttleOffAirport'>
										#rc.Filter.getCarDropoffAirport()#
										SHUTTLE OFF TERMINAL
									<cfelseif rc.Vehicle.getDropOffLocationType() EQ 'Terminal'>
										#rc.Filter.getCarDropoffAirport()#
										ON TERMINAL
									<cfelseif !len(rc.Vehicle.getDropOffLocationID()) AND structKeyExists(local, "pickupLocation")>
										<cfset local.dropoffLocation = local.pickupLocation />									
										#dropoffLocation#
									<cfelse>
										#rc.Filter.getCarDropoffAirport()#
									</cfif>
									</strong>
								</p>

							</div>
						</div>
					</div>

					<div class="col m3 s12">

						<div class="panel panel-primary summary-purchase-details">
							<div class="panel-heading">
								<h3 class="panel-title">
									#(rc.Vehicle.getCurrency() EQ 'USD' ? DollarFormat(rc.Vehicle.getEstimatedTotalAmount()) : numberFormat(rc.Vehicle.getEstimatedTotalAmount(), '____.__')&' '&rc.Vehicle.getCurrency())#
								</h3>
							</div>
							<div class="panel-body">
								<ul>
									<li>Estimated Total</li>
									<li>Taxes quoted at pick-up</li>
								</ul>

								<a class="waves-effect waves-light btn-small w100"
									rel="popover" data-original-title="Car payment and cancellation policy" 
									data-content="Payment is taken by the vendor. You may cancel at anytime for no fee." 
									href="javascript:void(0);" >
									<i class="mdi mdi-magnify-plus-outline right"></i>
									Vehicle Policy Details
								</a>

							</div>
						</div>

					</div>
				</div>

				<div class="loyalty row">
					<div class="col hide-on-small m2">&nbsp;</div>
					<div class="input-field col s12 m7">					
						<label for="carFF">#uCase(application.stCarVendors[rc.Vehicle.getVendorCode()])# LOYALTY ##</label>
						<input type="text" name="carFF" id="carFF" maxlength="20">
					</div>
				</div>
			
			</div>

	</cfif>

</cfoutput>
