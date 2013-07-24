<cfoutput>
	<table width="100%">
		<tr>
			<td>
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td width="6%">
							<cfif rc.Hotel.getRooms()[1].getIsCorporateRate()
								AND rc.Hotel.getPreferredVendor()>
								<span class="ribbon ribbon-l-pref-cont"></span>
							<cfelseif rc.Hotel.getRooms()[1].getIsGovernmentRate()
								AND rc.Hotel.getPreferredVendor()>
								<span class="ribbon ribbon-l-pref-govt"></span>
							<cfelseif rc.Hotel.getPreferredVendor()>
								<span class="ribbon ribbon-l-pref"></span>
							<cfelseif rc.Hotel.getRooms()[1].getIsGovernmentRate()>
								<span class="ribbon ribbon-l-govt"></span>
							<cfelseif rc.Hotel.getRooms()[1].getIsCorporateRate()>
								<span class="ribbon ribbon-l-cont"></span>
							</cfif>
						</td>
						<td colspan="3">
							<h2>HOTEL</h2>
						</td>
					</tr>
					<tr>
						<td rowspan="4"></td>
						<td rowspan="4" width="12%">
							<cfif findNoCase('https://', rc.Hotel.getSignatureImage())>
								<img alt="#rc.Hotel.getPropertyName()#" src="#rc.Hotel.getSignatureImage()#">
							</cfif>
						</td>
						<td <!--- width="200" ---> colspan="2">
							<strong>#uCase(rc.Hotel.getPropertyName())#</strong>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							#uCase(rc.Hotel.getAddress())#, #uCase(rc.Hotel.getCity())#, #uCase(rc.Hotel.getState())# #uCase(rc.Hotel.getZip())# #uCase(rc.Hotel.getCountry())#
						</td>
					</tr>
					<tr>
						<td colspan="2">
							#uCase(rc.Hotel.getRooms()[1].getDescription())#
						</td>
					</tr>
					<tr>
						<td width="18%">
							<strong>CHECK-IN: #uCase(dateFormat(rc.Filter.getCheckInDate(), 'mmm d'))#</strong>
						</td>
						<td>
							<strong>CHECK-OUT: #uCase(DateFormat(rc.Filter.getCheckOutDate(), 'mmm d'))#
							<cfset nights = dateDiff('d', rc.Filter.getCheckInDate(), rc.Filter.getCheckOutDate())>
							(#nights# NIGHT<cfif nights GT 1>S</cfif>)</strong>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr><td style="height:12px;"></td></tr>
		<!--- For each traveler with a hotel stay --->
		<cfloop array="#rc.hotelTravelers#" item="local.traveler" index="travelerIndex">
			<tr>
				<td>
					<table width="100%" border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td width="6%"></td>
							<td width="12%">
								<cfif arrayLen(rc.hotelTravelers) GT 1>
									<span class="blue"><strong>#rc.Traveler[travelerIndex].getFirstName()# #rc.Traveler[travelerIndex].getLastName()#</strong></span>
								</cfif>
							</td>
							<cfif NOT rc.Hotel.getRooms()[1].getIsInPolicy()>
									<td width="12%"><strong>OUT OF POLICY</strong></td>
									<td width="28%">Over maximum daily rate</td>
									<td width="8%"><strong>Reason</strong></td>
									<td>#rc.Traveler[travelerIndex].getBookingDetail().getHotelReasonCode()#</td>
								</tr>
								<tr>
									<td colspan="2"></td>						
							</cfif>
							<td width="12%"><span class="blue"><strong>Hotel Confirmation</strong></span></td>
							<td width="28%"><span class="blue"><strong>#rc.Hotel.getConfirmation()#</strong></span></td>
							<td width="8%"><strong>Loyalty ##</strong></td>
							<td>#rc.Traveler[travelerIndex].getBookingDetail().getHotelFF()#</td>
						</tr>
						<cfif travelerIndex NEQ arrayLen(rc.hotelTravelers)>
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