<cfoutput>

	<cfif rc.hotelSelected>
		<br class="clearfix">
		<div style="float:right;padding-right:20px;"><a href="#buildURL('hotel.search?SearchID=#rc.searchID#')#" style="color:##666">change / remove <span class="fa fa-remove"></a></div><br>
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
			
					
				<div class="tripsummary-detail">
					<div class="row">
						<div class="col-xs-12">
							<h2>HOTEL</h2>
						</div>
					</div>
				<div class="row">
						<div class="col-xs-12">
					<cfset isInPolicy = rc.Hotel.getRooms()[1].getIsInPolicy()>
					#(isInPolicy ? '' : '<div class="form-group"><label rel="tooltip" for="hotelReasonCode" class="control-label col-sm-4 col-xs-12 outofpolicy" title="#rc.Hotel.getRooms()[1].getOutOfPolicyMessage()#"><strong>OUT OF POLICY *</strong></label>')#

					<!--- All accounts when out of policy --->
					<cfif rc.showAll
						OR (NOT isInPolicy
						AND rc.Policy.Policy_HotelReasonCode)>
						<div class="col-sm-8 col-xs-12">
							<select name="hotelReasonCode" id="hotelReasonCode" class="form-control #(structKeyExists(rc.errors, 'hotelReasonCode') ? 'error' : '')#">
								<option value="">Select Reason for Booking Out of Policy</option>
								<!--- University of Washington --->
								<cfif rc.Filter.getAcctID() EQ 500>
									<option value="A">In policy (use also when no sleep is needed)</option>
									<option value="B">Attending conference/convention</option>
									<option value="C">Non-preferred hotel had lower rate</option>
									<option value="D">Preferred room type, chain or location</option>
									<option value="M">Recommended hotel</option>
									<option value="P">Preferred property/city sold out</option>
									<option value="R">Preferred room rate sold out</option>
								<cfelse>
									<option value="P">Required property sold out</option>
									<option value="R">Required room rate sold out</option>
									<option value="C">Required property was higher than another property</option>
									<option value="L">Leisure Rental (paying for it themselves)</option>
									<option value="B">I am booking a blacklisted hotel</option>
								</cfif>
							</select> 
						</div>
						</div>
					</cfif>

					<!--- State of Texas --->
					<cfif rc.showAll
						OR rc.Filter.getAcctID() EQ 235>
						<div class="#(structKeyExists(rc.errors, 'udid112') ? 'error' : '')#">
							<span style="float:left; width:114px;">STATE OF TEXAS *</span>
							<select name="udid112" id="udid112" class="input-xlarge">
							<option value="">Select an Exception Code</option>
							<cfloop query="rc.qTXExceptionCodes">
								<option value="#rc.qTXExceptionCodes.FareSavingsCode#">#rc.qTXExceptionCodes.Description#</option>
							</cfloop>
							</select>
							<a href="http://www.window.state.tx.us/procurement/prog/stmp/exceptions-to-the-use-of-stmp-contracts/" target="_blank">View explanation of codes</a><br><br>
						</div>
					</cfif>

					</div> <!-- /.col -->
				</div> <!-- /.row -->

			

				<div class="row">
					<div class="col-sm-2 col-xs-4">
						<cfif findNoCase('https://', rc.Hotel.getSignatureImage())>
						<img class="img-responsive" alt="#rc.Hotel.getPropertyName()#" src="#rc.Hotel.getSignatureImage()#">
						</cfif>
					</div>
					<div class="col-sm-8 col-xs-8">

						<strong>
							#rc.Hotel.getPropertyName()#<br>
						</strong>

						#uCase(rc.Hotel.getAddress())#,
						#uCase(rc.Hotel.getCity())#,
						#uCase(rc.Hotel.getState())#
						#uCase(rc.Hotel.getZip())#
						#uCase(rc.Hotel.getCountry())#<br>

						<div style="overflow:hidden;">#uCase(rc.Hotel.getRooms()[1].getDescription())#</div><br>

						<strong>
							CHECK-IN:
							#uCase(dateFormat(rc.Filter.getCheckInDate(), 'mmm d'))#
							<cfif len(rc.Hotel.getRooms()[1].getCheckInTime())>
								&nbsp;#timeFormat(rc.Hotel.getRooms()[1].getCheckInTime(), "h:mm tt")#&nbsp;
							</cfif>
							&nbsp;&nbsp;&nbsp;
							CHECK-OUT:
							#uCase(DateFormat(rc.Filter.getCheckOutDate(), 'mmm d'))#
							<cfif len(rc.Hotel.getRooms()[1].getCheckOutTime())>
								&nbsp;#timeFormat(rc.Hotel.getRooms()[1].getCheckOutTime(), "h:mm tt")#&nbsp;
							</cfif>
							<cfset nights = dateDiff('d', rc.Filter.getCheckInDate(), rc.Filter.getCheckOutDate())>
							(#nights# NIGHT<cfif nights GT 1>S</cfif>)
						</strong>

					</div>
					<div class="col-sm-2 col-xs-12">
					<cfif rc.Hotel.getRooms()[1].getTotalForStay() GT 0>
						<cfset currency = rc.Hotel.getRooms()[1].getTotalForStayCurrency()>
						<cfset hotelTotal = rc.Hotel.getRooms()[1].getTotalForStay()>
						<cfset hotelText = 'Total rate including taxes'>
					<cfelseif rc.Hotel.getRooms()[1].getBaseRate() GT 0>
						<cfset currency = rc.Hotel.getRooms()[1].getBaseRateCurrency()>
						<cfset hotelTotal = rc.Hotel.getRooms()[1].getBaseRate()>
						<cfset hotelText = 'Estimated Rate<br>Taxes quoted at check-in'>
					<cfelse>
						<cfset currency = rc.Hotel.getRooms()[1].getDailyRateCurrency()>
						<cfset hotelTotal = rc.Hotel.getRooms()[1].getDailyRate()*nights>
						<cfset hotelText = 'Estimated Rate<br>Taxes quoted at check-in'>
					</cfif>

					<cfif len(rc.Hotel.getRooms()[1].getPromo())>
						<span class="blue bold">
							#rc.Hotel.getRooms()[1].getPromo()#
						</span>
						<br />
					</cfif>

					<cfif rc.Filter.getFindIt() EQ 1>
						<cfset dailyRateCurrency = rc.Hotel.getRooms()[1].getDailyRateCurrency()>
						<cfset hotelDailyRate = rc.Hotel.getRooms()[1].getDailyRate()>
						<span class="blue bold large">
							#(dailyRateCurrency EQ 'USD' ? DollarFormat(hotelDailyRate) : numberFormat(hotelDailyRate, '____.__')&' '&dailyRateCurrency)#<br />
						</span>
						Average nightly rate<br />
					</cfif>

					<span class="blue bold large">
						#(currency EQ 'USD' ? DollarFormat(hotelTotal) : numberFormat(hotelTotal, '____.__')&' '&currency)#<br>
					</span>

					#hotelText#<br>

					<cfsavecontent variable="hotelPolicies">
						<cfif rc.Hotel.getRooms()[1].getDepositPolicy() NEQ ''
							OR rc.Hotel.getRooms()[1].getGuaranteePolicy() NEQ ''
							OR rc.Hotel.getRooms()[1].getCancellationPolicy() NEQ ''>
							<cfif rc.Hotel.getRooms()[1].getDepositPolicy() NEQ ''>
								Deposit: #rc.Hotel.getRooms()[1].getDepositPolicy()#<br>
							</cfif>
							<cfif rc.Hotel.getRooms()[1].getGuaranteePolicy() NEQ ''>
								Guarantee: #rc.Hotel.getRooms()[1].getGuaranteePolicy()#
							</cfif>
							Cancellation: #rc.Hotel.getRooms()[1].getCancellationPolicy()#<br>
						<cfelse>
							Hotel policies are not available at this time.
						</cfif>
					</cfsavecontent>

					<cfif UCASE(rc.Hotel.getRooms()[1].getAPISource()) EQ "PRICELINE">
						<span class="blue bold">
							<a rel="popover" href="javascript:$('##displayHotelCancellationPolicy').modal('show');" />
								Hotel payment and cancellation policy
							</a>
						</span>
					<cfelse>
						<span class="blue bold">
							<a rel="popover" data-original-title="Hotel payment and cancellation policy" data-content="#hotelPolicies#" href="##" />
								Hotel payment and cancellation policy
							</a>
						</span>
					</cfif>

					<cfif rc.Hotel.getRooms()[1].getDepositRequired()>
						<cfif rc.Hotel.getRooms()[1].getAPISource() EQ "Travelport">
							<span class="small red bold"><br />This rate requires payment at time of booking.</span>
						<cfelse>
							<span class="small red bold"><br />Websaver - Full pre-payment required upon booking.</span>
						</cfif>
					</cfif>
					</div>
					</div>
					<div class="loyalty row">

	
                    <cfif rc.Hotel.getRooms()[1].getAPISource() EQ "Travelport">
					<div class="form-group">
					<label for="hotelFF" class="col-sm-3 control-label">
					#uCase(application.stHotelVendors[rc.Hotel.getChainCode()])# LOYALTY ##
					</label>
					<div class="col-sm-7">
                    <input type="text" name="hotelFF" id="hotelFF" maxlength="20" class="form-control">
                    </div>
					</div>
					<cfelse>
					Frequent guest numbers cannot be applied to web rate reservations.
					&nbsp;&nbsp;&nbsp;
					<input type="hidden" name="hotelFF" id="hotelFF">
					</cfif>
					<div class="form-group">
					<label for="hotelSpecialRequests" class="col-sm-3 control-label">
					HOTEL SPECIAL REQUESTS
					</label>
					<div class="col-sm-7">
					<input type="text" name="hotelSpecialRequests" id="hotelSpecialRequests" maxlength="50" class="form-control">
					</div>
					</div> <!-- /.form-group -->
				</div>
			<cfif UCASE(rc.Hotel.getRooms()[1].getAPISource()) EQ "PRICELINE">
			<tr>
			<td colspan="5">
			&nbsp;&nbsp;&nbsp;
			<div class="darkBold preferred">You have selected a web rate. Please read and accept the terms of this rate below.</div>
			<br>
			<cfif len(LTRIM(RTRIM(rc.Hotel.getRooms()[1].getPPNRateDescription())))>
			<p>
			<span class="darkBold">Rate Description</span><br>
			#rc.Hotel.getRooms()[1].getPPNRateDescription()#
			</p>
			</cfif>
			<cfif len(LTRIM(RTRIM(rc.Hotel.getRooms()[1].getDepositPolicy())))>
			<p>
			<span class="darkBold">Pre-Pay Policy and Room Charge Disclosure</span><br>
			#rc.Hotel.getRooms()[1].getDepositPolicy()#
			</p>
			</cfif>
			<cfif len(LTRIM(RTRIM(rc.Hotel.getRooms()[1].getCancellationPolicy())))>
			<p>
			<span class="darkBold">Cancellation Policy</span><br>
			#rc.Hotel.getRooms()[1].getCancellationPolicy()#
			</p>
			</cfif>
			<cfif len(LTRIM(RTRIM(rc.Hotel.getRooms()[1].getGuaranteePolicy())))>
			<p>
			<span class="darkBold">Guarantee Policy</span><br>
			#rc.Hotel.getRooms()[1].getGuaranteePolicy()#
			</p>
			</cfif>
			<p>
			<span class="darkBold">Age Restriction Disclosure</span><br>
			The reservation holder must be 21 years of age or older.
			</p>
			<p>
			<input class="input-large" type="checkbox" name="pricelineAgreeTerms" id="pricelineAgreeTerms"> <span class="darkBold">I have read and agree to abide by the priceline.com <a rel="popover" href="javascript:$('##displayPricelineTermsAndConditions').modal('show');" />terms and conditions</a> and <a rel="popover" href="javascript:$('##displayPricelinePrivacyPolicy').modal('show');" />privacy policy</a></span> <span id="agreeToTermsError" class="small red bold notShown"> You must agree to the terms before purchasing.</span>
			</p>
			</tr>
			</cfif>
			
			<div id="displayHotelCancellationPolicy" class="modal searchForm fade" tabindex="-1" role="dialog" aria-labelledby="displayHotelCancellationPolicy" aria-hidden="true">
			<!--<div class="searchContainer">-->
					<div class="modal-header popover-content">
						<button type="button" class="close" data-dismiss="modal"><i class="fa fa-remove"></i></button>
						<h3 id="addModalHeader"><cfif UCASE(rc.Hotel.getRooms()[1].getAPISource()) EQ "PRICELINE">
						You have selected a web rate. Please read and accept the terms of this rate.
						<cfelse>
						Hotel Payment and Cancellation Policy
						</cfif>
						</h3>
					</div>
					<div class="modal-body popover-content">
						<div id="addModalBody">
							<cfif UCASE(rc.Hotel.getRooms()[1].getAPISource()) EQ "PRICELINE">
							#view( 'summary/hotelcancellationpolicy' )#
							<cfelse>
							#hotelPolicies#
							</cfif>
						</div>
					</div>
				<!--</div>-->
			</div>
			<div id="displayPricelineTermsAndConditions" class="modal searchForm hide fade" style="width:650px !important" tabindex="-1" role="dialog" aria-labelledby="displayPricelineTermsAndConditions" aria-hidden="true">
				<div class="searchContainer">
					<div class="modal-header popover-content">
						<button type="button" class="close" data-dismiss="modal"><i class="fa fa-remove"></i></button>
						<h3 id="addModalHeader">
						Short&##39;s Travel Management Web Site Terms &amp; Conditions
						</h3>
					</div>
					<div class="modal-body popover-content">
						<div id="addModalBody">
							#view( 'summary/priceline_terms' )#
						</div>
					</div>
				</div>
			</div>
			<div id="displayPricelinePrivacyPolicy" class="modal searchForm hide fade" style="width:650px !important" tabindex="-1" role="dialog" aria-labelledby="displayPricelineTermsAndConditions" aria-hidden="true">
				<div class="searchContainer">
					<div class="modal-header popover-content">
						<button type="button" class="close" data-dismiss="modal"><i class="fa fa-remove"></i></button>
						<h3 id="addModalHeader">
						Privacy Policy
						</h3>
					</div>
					<div class="modal-body popover-content">
						<div id="addModalBody">
							#view( 'summary/priceline_privacy' )#
						</div>
					</div>
				</div>
			</div>
		</div> <!-- add'l closer-->
	</cfif>
</cfoutput>
<!--- <cfdump var="#rc.Hotel#"> --->
