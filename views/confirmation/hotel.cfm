<cfoutput>
	<div class="tripsummary-detail">
		<div class="row">
			<div class="col-xs-12 padded">
							<!--- If DHL --->
							<cfif rc.Filter.getAcctID() EQ 497 OR rc.Filter.getAcctID() EQ 499>
								<cfif rc.Hotel.getPreferredProperty()>
									<span class="ribbon ribbon-l-DHL-prefprop"></span>
								<cfelseif rc.Hotel.getPreferredVendor()>
									<span class="ribbon ribbon-l-DHL-prefvendor"></span>
								</cfif>
							<!--- if NASCAR --->
							<cfelseif rc.Filter.getAcctID() EQ 348>
								<cfif rc.Hotel.getRooms()[1].getIsCorporateRate()
									AND (rc.Hotel.getPreferredProperty() OR rc.Hotel.getPreferredVendor())>
									<span class="ribbon ribbon-l-pref-disc"></span>
								<cfelseif rc.Hotel.getPreferredProperty() OR rc.Hotel.getPreferredVendor()>
									<span class="ribbon ribbon-l-pref"></span>
								<cfelseif rc.Hotel.getRooms()[1].getIsCorporateRate()>
									<span class="ribbon ribbon-l-disc"></span>
								</cfif>
							<!--- If any other account --->
							<cfelse>
								<cfif rc.Hotel.getRooms()[1].getIsCorporateRate()
									AND (rc.Hotel.getPreferredProperty() OR rc.Hotel.getPreferredVendor())>
									<span class="ribbon ribbon-l-pref-cont"></span>
								<cfelseif rc.Hotel.getRooms()[1].getIsGovernmentRate()
									AND (rc.Hotel.getPreferredProperty() OR rc.Hotel.getPreferredVendor())>
									<span class="ribbon ribbon-l-pref-govt"></span>
								<cfelseif rc.Hotel.getPreferredProperty() OR rc.Hotel.getPreferredVendor()>
									<span class="ribbon ribbon-l-pref"></span>
								<cfelseif rc.Hotel.getRooms()[1].getIsGovernmentRate()>
									<span class="ribbon ribbon-l-govt"></span>
								<cfelseif rc.Hotel.getRooms()[1].getIsCorporateRate()>
									<span class="ribbon ribbon-l-cont"></span>
								</cfif>
							</cfif>
							<h2>HOTEL</h2>
						</div>
					</div> <!-- .row -->
					<div class="row">
						<div class="col-sm-2 col-xs-12 center">
							<cfif findNoCase('https://', rc.Hotel.getSignatureImage())>
								<img class="img-responsive center-block" alt="#rc.Hotel.getPropertyName()#" src="#rc.Hotel.getSignatureImage()#">
							</cfif>
						</div>
						<div class="col-sm-10">
							<strong>#uCase(rc.Hotel.getPropertyName())#</strong>
							<br />
							#uCase(rc.Hotel.getAddress())#, #uCase(rc.Hotel.getCity())#, #uCase(rc.Hotel.getState())# #uCase(rc.Hotel.getZip())# #uCase(rc.Hotel.getCountry())#
							<br />
							#uCase(rc.Hotel.getRooms()[1].getDescription())#
							<br />
							<strong>CHECK-IN: #uCase(dateFormat(rc.Filter.getCheckInDate(), 'mmm d'))#</strong>
							<br />
							<strong>CHECK-OUT: #uCase(DateFormat(rc.Filter.getCheckOutDate(), 'mmm d'))#
							<cfset nights = dateDiff('d', rc.Filter.getCheckInDate(), rc.Filter.getCheckOutDate())>
							(#nights# NIGHT<cfif nights GT 1>S</cfif>)</strong>
						</div>
					</div>


		<!--- For each traveler with a hotel stay --->
		<cfloop array="#rc.hotelTravelers#" item="local.traveler" index="travelerIndex">
			<div class="row">
				<div class="col-sm-offset-2 col-sm-2">
					<cfif arrayLen(rc.Travelers) GT 1>
					<!--- <cfif arrayLen(rc.hotelTravelers) GT 1> --->
						<span class="blue"><strong>#uCase(rc.Traveler[travelerIndex].getFirstName())# #uCase(rc.Traveler[travelerIndex].getLastName())#</strong></span>
					</cfif>
				</div>
				<cfif NOT rc.Hotel.getRooms()[1].getIsInPolicy()>
					<div class="col-sm-2"><strong>OUT OF POLICY</strong></div>
					<div class="col-sm-3">#rc.Hotel.getRooms()[1].getOutOfPolicyMessage()#</div>
					<div class="col-sm-3">
						<cfif len(rc.Traveler[travelerIndex].getBookingDetail().getHotelReasonCode())>
							<strong>Reason</strong>#rc.Traveler[local.travelerIndex].getBookingDetail().hotelReasonDescription#
						</cfif>
					</div>
				</cfif>
			</div>
			<div class="row padded">
				<div class="col-sm-offset-2 col-sm-5">
					<span class="blue"><strong>Hotel Confirmation #rc.Traveler[travelerIndex].getBookingDetail().getHotelConfirmation()#</strong></span>
				</div>
				<div class="col-sm-5">
					<cfif len(rc.Traveler[travelerIndex].getBookingDetail().getHotelFF())>
						<strong>Loyalty ##</strong> #rc.Traveler[travelerIndex].getBookingDetail().getHotelFF()#
					</cfif>
				</div>
		  </div>
			<cfif travelerIndex NEQ arrayLen(rc.hotelTravelers)>
					<hr class="dashed" />
			</cfif>
		</cfloop>
	</div>
</cfoutput>
