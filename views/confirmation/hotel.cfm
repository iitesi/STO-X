<cfoutput>
	<table width="100%">
		<tr>
			<td>
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td width="6%">
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
						</td>
						<td colspan="4">
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
						<td width="2%">&nbsp;</td>
						<td width="50%" colspan="2">
							<strong>#uCase(rc.Hotel.getPropertyName())#</strong>
						</td>
						<cfif rc.Hotel.getRooms()[1].getAPISource() EQ "Priceline">
							<td>
								<span class="blue bold">
									<a rel="popover" href="javascript:$('##displayHotelCancellationPolicy').modal('show');" />
										Hotel payment and cancellation policy
									</a>
								</span>
							</td>
						<cfelse>
							<td>&nbsp;</td>
						</cfif>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<td colspan="2">
							#uCase(rc.Hotel.getAddress())#, #uCase(rc.Hotel.getCity())#, #uCase(rc.Hotel.getState())# #uCase(rc.Hotel.getZip())# #uCase(rc.Hotel.getCountry())#<br />
							HOTEL PHONE NUMBER: #rc.Hotel.getPhone()#
						</td>
						<cfif rc.Hotel.getRooms()[1].getAPISource() EQ "Priceline" AND rc.Hotel.getRooms()[1].getIsCancellable()>
							<td><span style="padding:25px;"><a href="" style="color:red;">CANCEL THIS RESERVATION</a></span>
						<cfelse>
							<td>&nbsp;</td>
						</cfif>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<td colspan="3">
							#uCase(rc.Hotel.getRooms()[1].getDescription())#
						</td>
					</tr>
					<cfif rc.Hotel.getRooms()[1].getAPISource() EQ "Priceline">
						<cfset formatToUse = "dddd mmm d" />
					<cfelse>
						<cfset formatToUse = "mmm d" />
					</cfif>
					<tr>
						<td>&nbsp;</td>
						<td width="18%">
							<strong>CHECK-IN: #uCase(dateFormat(rc.Filter.getCheckInDate(), formatToUse))#</strong>
						</td>
						<td colspan="2">
							<strong>CHECK-OUT: #uCase(DateFormat(rc.Filter.getCheckOutDate(), formatToUse))#
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
								<cfif arrayLen(rc.Travelers) GT 1>
								<!--- <cfif arrayLen(rc.hotelTravelers) GT 1> --->
									<span class="blue"><strong>#uCase(rc.Traveler[travelerIndex].getFirstName())# #uCase(rc.Traveler[travelerIndex].getLastName())#</strong></span>
								</cfif>
							</td>
							<cfif NOT rc.Hotel.getRooms()[1].getIsInPolicy()>
									<td valign="top" width="12%"><strong>OUT OF POLICY</strong></td>
									<td valign="top" width="28%">#rc.Hotel.getRooms()[1].getOutOfPolicyMessage()#</td>
									<cfif len(rc.Traveler[travelerIndex].getBookingDetail().getHotelReasonCode())>
										<td valign="top" width="8%"><strong>Reason</strong></td>
										<td valign="top">
											<!--- University of Washington --->
											<cfif rc.Filter.getAcctID() EQ 500>
												<cfswitch expression="#rc.Traveler[travelerIndex].getBookingDetail().getHotelReasonCode()#">
													<cfcase value="A">In policy (use also when no sleep is needed)</cfcase>
													<cfcase value="B">Attending conference/convention</cfcase>
													<cfcase value="C">Non-preferred hotel had lower rate</cfcase>
													<cfcase value="D">Preferred room type, chain or location</cfcase>
													<cfcase value="M">Recommended hotel</cfcase>
													<cfcase value="P">Preferred property/city sold out</cfcase>
													<cfcase value="R">Preferred room rate sold out</cfcase>
												</cfswitch>
											<cfelse>
												<cfswitch expression="#rc.Traveler[travelerIndex].getBookingDetail().getHotelReasonCode()#">
													<cfcase value="P">Required property sold out</cfcase>
													<cfcase value="R">Required room rate sold out</cfcase>
													<cfcase value="C">Required property was higher than another property</cfcase>
													<cfcase value="L">Leisure Rental (paying for it themselves)</cfcase>
													<cfcase value="B">I am booking a blacklisted hotel</cfcase>
												</cfswitch>
											</cfif>
										</td>
									<cfelse>
										<td width="8%"></td>
										<td></td>
									</cfif>
								</tr>
								<tr>
									<td colspan="2"></td>						
							</cfif>
							<td valign="top" width="12%"><span class="blue"><strong>Hotel Confirmation</strong></span></td>
							<td valign="top" width="28%"><span class="blue"><strong>#rc.Traveler[travelerIndex].getBookingDetail().getHotelConfirmation()#</strong></span></td>
							<cfif len(rc.Traveler[travelerIndex].getBookingDetail().getHotelFF())>
								<td valign="top" width="8%"><strong>Loyalty ##</strong></td>
								<td valign="top">
									<cfif rc.Hotel.getRooms()[1].getAPISource() EQ "Travelport">
										#rc.Traveler[travelerIndex].getBookingDetail().getHotelFF()#
									<cfelse>
										Frequent guest numbers cannot be applied to web rate reservations.
									</cfif>
								</td>
							<cfelse>
								<td width="8%"></td>
								<td></td>
							</cfif>
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
	<div id="displayHotelCancellationPolicy" class="modal searchForm hide fade" tabindex="-1" role="dialog" aria-labelledby="displayHotelCancellationPolicy" aria-hidden="true">
		<div class="searchContainer">
			<div class="modal-header popover-content">
				<button type="button" class="close" data-dismiss="modal"><i class="icon-remove"></i></button>
				<h3 id="addModalHeader">Hotel Payment and Cancellation Policy</h3>
			</div>
			<div class="modal-body popover-content">
				<div id="addModalBody">
					#view("summary/hotelcancellationpolicy")#
				</div>
			</div>
		</div>
	</div>
</cfoutput>