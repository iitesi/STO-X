<!--- <cfdump var="#rc.vehicle#" abort> --->
<cfoutput>
	<table width="100%">
		<tr>
			<td>
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td width="6%">
							<cfif rc.Vehicle.getCorporate()
								AND rc.Vehicle.getPreferred()>
								<span class="ribbon ribbon-l-pref-cont"></span>
							<cfelseif rc.Vehicle.getPreferred()>
								<span class="ribbon ribbon-l-pref"></span>
							<cfelseif rc.Vehicle.getCorporate()>
								<span class="ribbon ribbon-l-cont"></span>
							</cfif>
						</td>
						<td colspan="5">
							<h2>CAR</h2>
						</td>
					</tr>
					<tr>
						<td rowspan="4"></td>
						<td rowspan="4" width="12%">
							<img alt="#rc.Vehicle.getVendorCode()#" src="assets/img/cars/#rc.Vehicle.getVendorCode()#.png">
						</td>
						<td colspan="4">
							<strong>#uCase(application.stCarVendors[rc.Vehicle.getVendorCode()])#</strong>
						</td>
					</tr>
					<!--- <tr>
						<td colspan="2">
							<cfif rc.Vehicle.getLocation() EQ 'TERMINAL'>
								ON
							</cfif>
							#uCase(rc.Vehicle.getLocation())#
						</td>
					</tr> --->
					<tr>
						<td colspan="4">
							#uCase(rc.Vehicle.getVehicleClass())# 
							<cfif rc.Vehicle.getDoorCount() NEQ ''>
								#rc.Vehicle.getDoorCount()# DOOR
							</cfif>
						</td>
					</tr>
					<tr>
						<td width="39%"><strong>
							PICK-UP: #uCase(dateFormat(rc.Filter.getCarPickUpDateTime(), 'mmm d'))# #uCase(timeFormat(rc.Filter.getCarPickUpDateTime(), 'h:mm tt'))#<br />
							#rc.pickupLocation#
						</strong></td>
						<td><strong>
							DROP-OFF: #uCase(DateFormat(rc.Filter.getCarDropOffDateTime(), 'mmm d'))# #uCase(timeFormat(rc.Filter.getCarDropOffDateTime(), 'h:mm tt'))#<br />
							#rc.dropoffLocation#
						</strong></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr><td style="height:12px;"></td></tr>
		<!--- For each traveler with a car rental --->
		<cfloop array="#rc.vehicleTravelers#" item="traveler" index="travelerIndex">
			<tr>
				<td>
					<table width="100%" border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td width="6%"></td>
							<td width="12%">
								<cfif arrayLen(rc.Travelers) GT 1>
								<!--- <cfif arrayLen(rc.vehicleTravelers) GT 1> --->
									<span class="blue"><strong>#uCase(rc.Traveler[travelerIndex].getFirstName())# #uCase(rc.Traveler[travelerIndex].getLastName())#</strong></span>
								</cfif>
							</td>
							<cfif NOT rc.Vehicle.getPolicy()>
									<td width="12%" valign="top"><strong>OUT OF POLICY</strong></td>
									<td width="28%" valign="top">#ArrayToList(rc.Vehicle.getAPolicies())#</td>
									<cfif len(rc.Traveler[travelerIndex].getBookingDetail().getCarReasonCode())>
										<td width="8%" valign="top"><strong>REASON</strong></td>
										<td width="34%" valign="top">
											#rc.Traveler[local.travelerIndex].getBookingDetail().carReasonDescription#
<!---
											<cfswitch expression="#rc.Traveler[travelerIndex].getBookingDetail().getCarReasonCode()#">
												<cfcase value="D">Required car vendor does not provide service at origination and/or destination</cfcase>
												<cfcase value="S">Required car size sold out</cfcase>
												<cfcase value="V">Required car vendor sold out</cfcase>
												<cfcase value="M">Required a larger car size due to additional travelers/equipment</cfcase>
												<cfcase value="C">Preferred vendor rate was higher than another company</cfcase>
												<cfcase value="L">Leisure Rental (paying for it themselves)</cfcase>
											</cfswitch>
--->
										</td>
									<cfelse>
										<td width="8%"></td>
										<td width="34%"></td>
									</cfif>
								</tr>
								<tr>
									<td colspan="2"></td>						
							</cfif>
							<td width="12%"><span class="blue"><strong>Car Confirmation</strong></span></td>
							<td width="28%"><span class="blue"><strong>#rc.Traveler[travelerIndex].getBookingDetail().getCarConfirmation()#</strong></span></td>
							<cfif len(rc.Traveler[travelerIndex].getBookingDetail().getCarFF())>
								<td width="8%"><strong>Loyalty ##</strong></td>
								<td width="34%">#rc.Traveler[travelerIndex].getBookingDetail().getCarFF()#</td>
							<cfelse>
								<td width="8%"></td>
								<td width="34%"></td>
							</cfif>
						</tr>
						<cfif travelerIndex NEQ arrayLen(rc.vehicleTravelers)>
							<tr>
								<td colspan="2"></td>
								<td colspan="4"><hr class="dashed" /></td>
							</tr>
						<cfelse>
							<tr><td colspan="6" style="height:12px;"></td></tr>
						</cfif>
					</table>
				</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>