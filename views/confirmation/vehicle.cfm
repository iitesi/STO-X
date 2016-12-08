<!--- <cfdump var="#rc.vehicle#" abort> --->
<cfoutput>
	<div class="tripsummary-detail">
		<div class="row">
			<div class="col-xs-12 padded">
				<cfif rc.Vehicle.getCorporate()
					AND rc.Vehicle.getPreferred()>
					<span class="ribbon ribbon-l-pref-cont"></span>
				<cfelseif rc.Vehicle.getPreferred()>
					<span class="ribbon ribbon-l-pref"></span>
				<cfelseif rc.Vehicle.getCorporate()>
					<span class="ribbon ribbon-l-cont"></span>
				</cfif>
				<h2>CAR</h2>
			</div>
		</div> <!-- .row -->
		<div class="row">
			<div class="col-sm-2 col-xs-12 center">
				<img class="img-responsive carrierimg center-block" alt="#rc.Vehicle.getVendorCode()#" src="assets/img/cars/#rc.Vehicle.getVendorCode()#.png">
				#uCase(application.stCarVendors[rc.Vehicle.getVendorCode()])#
			</div>
			<div class="col-sm-10">
				<div class="row">
					<div class="col-xs-12 padded">
						#uCase(rc.Vehicle.getVehicleClass())#
						<cfif rc.Vehicle.getDoorCount() NEQ ''>
							#rc.Vehicle.getDoorCount()# DOOR
						</cfif>
					</div>
				</div>
				<div class="row">
					<div class="col-sm-6">
						<strong>
							PICK-UP: #uCase(dateFormat(rc.Filter.getCarPickUpDateTime(), 'mmm d'))# #uCase(timeFormat(rc.Filter.getCarPickUpDateTime(), 'h:mm tt'))#<br />
							#rc.pickupLocation#
					  </strong>
				  </div>
					<div class="col-sm-6">
						<strong>
							DROP-OFF: #uCase(DateFormat(rc.Filter.getCarDropOffDateTime(), 'mmm d'))# #uCase(timeFormat(rc.Filter.getCarDropOffDateTime(), 'h:mm tt'))#<br />
							#rc.dropoffLocation#
					 </strong>
				 </div>
				</div>
		  </div>
		</div> <!-- .row -->

		<!--- For each traveler with a car rental --->
		<cfloop array="#rc.vehicleTravelers#" item="traveler" index="travelerIndex">
			<div class="row">
				<div class="col-sm-2 col-sm-offset-2">
					<cfif arrayLen(rc.Travelers) GT 1>
					<!--- <cfif arrayLen(rc.vehicleTravelers) GT 1> --->
						<span class="blue"><strong>#uCase(rc.Traveler[travelerIndex].getFirstName())# #uCase(rc.Traveler[travelerIndex].getLastName())#</strong></span>
					</cfif>
				</div>
				<cfif NOT rc.Vehicle.getPolicy()>
						<div class="col-sm-2"><strong>OUT OF POLICY</strong></div>
						<div class="col-sm-3">#ArrayToList(rc.Vehicle.getAPolicies())#</div>
						<div class="col-sm-3">
						<cfif len(rc.Traveler[travelerIndex].getBookingDetail().getCarReasonCode())>
							<strong>REASON</strong>
							#rc.Traveler[local.travelerIndex].getBookingDetail().carReasonDescription#
						</cfif>
					</div>
				</cfif>
			</div>
			<div class="row padded">
				<div class="col-sm-3 col-sm-offset-2"><span class="blue"><strong>Car Confirmation</strong></span></div>
				<div class="col-sm-3"><span class="blue"><strong>#rc.Traveler[travelerIndex].getBookingDetail().getCarConfirmation()#</strong></span></div>
				<div class="col-sm-4">
					<cfif len(rc.Traveler[travelerIndex].getBookingDetail().getCarFF())>
						<strong>Loyalty ##</strong> #rc.Traveler[travelerIndex].getBookingDetail().getCarFF()#
					</cfif>
				</div>
			</div>
			<cfif travelerIndex NEQ arrayLen(rc.vehicleTravelers)>
				<hr class="dashed" />
			</cfif>
		</cfloop>
	</div>
</cfoutput>
