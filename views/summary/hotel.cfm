<cfoutput>

	<cfif rc.hotelSelected>
			<div class="tripsummary-detail">
				<div class="row mb0 header">
					<div class="col s11">
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
								AND (rc.Hotel.getPreferredProperty() OR rc.Hotel.getPreferredVendor()) AND rc.acctID NEQ 532>
							<cfelseif rc.Hotel.getRooms()[1].getIsCorporateRate()
								AND (rc.Hotel.getPreferredProperty() OR rc.Hotel.getPreferredVendor()) AND rc.acctID EQ 532>
								<span class="ribbon ribbon-l-pref"></span>
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
					<div class="col s1">
						<a href="#buildURL('hotel.search?SearchID=#rc.searchID#')#" 
						rel="popleft"
						data-content="Change or Cancel"
						class="btn-floating btn-small waves-effect waves-light red  pull-right" 
						><i class="mdi mdi-restart"></i></a>
					</div>
				</div>
				<cfset OOPSelects = ""/>
			
				<cfset isInPolicy = rc.Hotel.getRooms()[1].getIsInPolicy()>
				<!--- All accounts when out of policy --->
				<cfif rc.showAll
					OR (NOT isInPolicy
					AND rc.Policy.Policy_HotelReasonCode)>
					<cfsavecontent variable="OOPSelects">#OOPSelects#
						<div class="input-field col s11 m5">
							<select name="hotelReasonCode" id="hotelReasonCode">
								<option value="" disabled selected>Select Reason for Booking Out of Policy</option>
								<cfloop query="rc.qOutOfPolicy_Hotel">
									<option value="#rc.qOutOfPolicy_Hotel.HotelSavingsCode#">#rc.qOutOfPolicy_Hotel.Description#</option>
								</cfloop>
							</select>
							<label for="hotelReasonCode">OUT OF POLICY *</label>
						</div>
						<div class="input-field col s1">
							<a href="javascript:void(0);" 
							rel="popover"
							data-content="#rc.Hotel.getRooms()[1].getOutOfPolicyMessage()#"
							class="btn-small btn-floating waves-effect waves-light blue darken-3" 
							><i class="mdi mdi-alert-circle-outline"></i></a>
						</div>
					</cfsavecontent>
				</cfif>

				<!--- State of Texas --->
				<cfif rc.showAll
					OR rc.Filter.getAcctID() EQ 235>
						<cfsavecontent variable="OOPSelects">#OOPSelects#
						<div class="input-field col s12 m6">
							<select name="udid112" id="udid112">
								<option value="" disabled selected>Select an Exception Code</option>
								<cfloop query="rc.qTXExceptionCodes">
									<option value="#rc.qTXExceptionCodes.FareSavingsCode#">#rc.qTXExceptionCodes.Description#</option>
								</cfloop>
							</select>
							<label for="udid112">STATE OF TEXAS *</label>
						</div>
						<div class="col s12 m6 right">
							<a href="http://www.window.state.tx.us/procurement/prog/stmp/exceptions-to-the-use-of-stmp-contracts/" target="_blank">View explanation of codes</a>
						</div>
						</cfsavecontent>
				</cfif>
				<cfif len(OOPSelects)>
				<div class="row">#OOPSelects#</div>
				</cfif>
				<div class="row">
					<div class="col hide-on-small-only m2">
						<cfif findNoCase('https://', rc.Hotel.getSignatureImage())>
							<img class="img-responsive" alt="#rc.Hotel.getPropertyName()#" src="#rc.Hotel.getSignatureImage()#">
						</cfif>
					</div>

					<div class="col s12 m7">
						<div class="card summary-details-card z-depth-1">
							<cfif findNoCase('https://', rc.Hotel.getSignatureImage())>
								<div class="card-image hide-on-med-and-up show-on-small">
									<img class="img-responsive" alt="#rc.Hotel.getPropertyName()#" src="#rc.Hotel.getSignatureImage()#">
								</div>
							</cfif>
							<div class="card-content">
								<span class="card-title">
									#rc.Hotel.getPropertyName()#
								</span>
								<p>
									#uCase(rc.Hotel.getAddress())#,
									#uCase(rc.Hotel.getCity())#,
									#uCase(rc.Hotel.getState())#
									#uCase(rc.Hotel.getZip())#
									#uCase(rc.Hotel.getCountry())#
								</p>
								<p>
									#uCase(rc.Hotel.getRooms()[1].getDescription())#
								</p>
								<div class="row">
									<div class="col s5 blue darken-3 white-text text-center">CHECK-IN</div>
									<div class="col s2">&nbsp;</div>
									<div class="col s5 blue darken-3 white-text text-center">CHECK-OUT</div>
								</div>
								<div class="row">
									<div class="col s5 text-center">#uCase(dateFormat(rc.Filter.getCheckInDate(), 'mmm d'))#</div>
									<div class="col s2">&nbsp;</div>
									<div class="col s5 text-center">#uCase(DateFormat(rc.Filter.getCheckOutDate(), 'mmm d'))#</div>
								</div>
								<div class="row">
									<div class="col s5 text-center">
										<cfif rc.Hotel.getRooms()[1].getrateChange()>
											<a id="breakdown"><span id="view">View</span> Rate Breakdown</a>
										<cfelse>&nbsp;</cfif>
									</div>
									<div class="col s2 text-center">&nbsp;</div>
									<cfset nights = dateDiff('d', rc.Filter.getCheckInDate(), rc.Filter.getCheckOutDate())>
									<div class="col s5 text-center">(#nights# NIGHT<cfif nights GT 1>S</cfif>)</div>
									
								</div>
								<div class="row">
									<cfif rc.Hotel.getRooms()[1].getrateChange()>
									<div class="col s12" id="rateComment" style="display: none;">#Replace(rc.Hotel.getRooms()[1].getrateComment(),'+','<br>','all')#</div>
									</cfif>
								</div>
							</div>
						  </div>
					</div>

					<div class="col s12 m3">
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
						<cfif rc.Filter.getFindIt() EQ 1>
							<cfset dailyRateCurrency = rc.Hotel.getRooms()[1].getDailyRateCurrency()>
							<cfset hotelDailyRate = rc.Hotel.getRooms()[1].getDailyRate()>
							<span class="blue bold large">
								#(dailyRateCurrency EQ 'USD' ? DollarFormat(hotelDailyRate) : numberFormat(hotelDailyRate, '____.__')&' '&dailyRateCurrency)#<br />
							</span>
							Average nightly rate<br />
							<cftry><cfif isArray(rc.hotel.getRooms()[1].getRateChangeText()) AND arrayLen(rc.hotel.getRooms()[1].getRateChangeText()) GT 1>
								<cfsavecontent variable="hotelRateChanges">
									<cfloop from="1" to="#arrayLen(rc.hotel.getRooms()[1].getRateChangeText())#" index="ii">
										#replace(replace(replace(rc.hotel.getRooms()[1].getRateChangeText()[ii], "USD", "$"), " per ", "/"), "nights", "night(s)")#<br />
									</cfloop>
								</cfsavecontent>
								<span class="blue bold">
									<a rel="popover" data-original-title="Hotel rate changes" data-content="#hotelRateChanges#" href="javascript:void(0);" />
										Hotel nightly rate variances
									</a>
								</span>
							</cfif>
							<cfcatch type='any'>

							</cfcatch>
							</cftry>
						</cfif>

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

						<div class="panel panel-primary summary-purchase-details">
							<div class="panel-heading">
								<h3 class="panel-title">
									#(currency EQ 'USD' ? DollarFormat(hotelTotal) : numberFormat(hotelTotal, '____.__')&' '&currency)#
								</h3>
							</div>
							<div class="panel-body">
								<ul>
									<li>#hotelText#</li>
									<cfif rc.Hotel.getRooms()[1].getAPISource() EQ "Priceline">
										<li><span class="red-text">#rc.Hotel.getRooms()[1].getPPNRateDescription()#</span></li>
									<cfelseif rc.Hotel.getRooms()[1].getDepositRequired()>
										<li><span class="red-text">This rate requires payment at time of booking.</span></li>
									</cfif>
								</ul>
								<cfif UCASE(rc.Hotel.getRooms()[1].getAPISource()) EQ "PRICELINE">
									<a class="waves-effect waves-light btn-small w100" rel="popover" 
										href="javascript:$('##displayHotelCancellationPolicy').modal('show');" >
										<i class="mdi mdi-magnify-plus-outline right"></i>
										Hotel Policy Details
									</a>
								<cfelse>
									<a class="waves-effect waves-light btn-small w100"
										rel="popover" data-original-title="Hotel payment and cancellation policy" 
										data-content="#hotelPolicies#" href="javascript:void(0);" >
										<i class="mdi mdi-magnify-plus-outline right"></i>
										Hotel Policy Details
									</a>
								</cfif>
							</div>
						</div>
					</div>
				</div>
				<div class="loyalty row">
					<div class="col s12 m6">
						<cfif rc.Hotel.getRooms()[1].getAPISource() EQ "Travelport">
							<div class="input-field">
								<label for="hotelFF">#uCase(application.stHotelVendors[rc.Hotel.getChainCode()])# Loyalty ##</label>
								<input type="text" name="hotelFF" id="hotelFF" maxlength="20">
							</div>
						<cfelse>
							Frequent guest numbers cannot be applied to web rate reservations.
							<input type="hidden" name="hotelFF" id="hotelFF">
						</cfif>
					</div>
					<div class="col s12 m6">
						<div class="input-field">
							<label for="hotelSpecialRequests">Special Requests</label>
							<input type="text" name="hotelSpecialRequests" id="hotelSpecialRequests" maxlength="50" class="form-control">
						</div>
					</div>
				</div> <!-- /.loyalty.row -->
				<cfif rc.Hotel.getRooms()[1].getAPISource() EQ "Priceline">
					<div class="row">
						<div class="col s12">
							<div class="card priceline-terms-card z-depth-0">
								<div class="card-content white-text blue darken-3">
								  	<span class="card-title">You have selected a web rate. Please read and accept the terms of this rate below.</span>
								 	<h4 class="white-text">Age Restriction Disclosure:</h4> 
								  	<p>The reservation holder must be 21 years of age or older.</p>
									<cfif len(LTRIM(RTRIM(rc.Hotel.getRooms()[1].getPPNRateDescription())))>
										<h4 class="white-text">Rate Description:</h4> 
										<p>#rc.Hotel.getRooms()[1].getPPNRateDescription()#</p>
									</cfif>
									<cfif len(LTRIM(RTRIM(rc.Hotel.getRooms()[1].getDepositPolicy())))>
										<h4 class="white-text">Pre-Pay Policy and Room Charge Disclosure:</h4> 
										<p>#rc.Hotel.getRooms()[1].getDepositPolicy()#</p>
									</cfif>
									<cfif len(LTRIM(RTRIM(rc.Hotel.getRooms()[1].getCancellationPolicy())))>
										<h4 class="white-text">Cancellation Policy:</h4>
										<p>#rc.Hotel.getRooms()[1].getCancellationPolicy()#</p>
									</cfif>
									<cfif len(LTRIM(RTRIM(rc.Hotel.getRooms()[1].getGuaranteePolicy())))>
										<h4 class="white-text">Guarantee Policy:</h4>
										<p>#rc.Hotel.getRooms()[1].getGuaranteePolicy()#</p>
									</cfif>
								</div>
								<div class="card-action ">
									<div class="input-field">
										<label for="pricelineAgreeTerms">
											<input type="checkbox" class="filled-in" name="pricelineAgreeTerms" id="pricelineAgreeTerms" value="1">
											<span>I have read and agree to abide by the <a href="http://secure.rezserver.com/hotels/help/terms/?refid=6821" target="_blank">priceline.com terms and conditions and privacy policy</a>.</span>
										</label>
									</div>
								</div>
								<div id="agreeToTermsError" class="small red-text bold notShown"> You must agree to the terms before purchasing.</div>
							</div>
						</div>
					</div>
				</cfif>
			</div>
			<div id="displayHotelCancellationPolicy" class="modal searchForm hide fade" tabindex="-1" role="dialog" aria-labelledby="displayHotelCancellationPolicy" aria-hidden="true">
				<div class="modal-dialog">
					<div class="modal-content">
						<div class="modal-header popover-content">
						<button type="button" class="close" data-dismiss="modal"><i class="icon-remove"></i></button>
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
				</div>
				</div> <!-- /.modal-dialog -->
			</div> <!-- / displayHotelCancellationPolicy -->
	</cfif>
</cfoutput>
<script>
$(document).ready(function () {
    $('#breakdown').click(function () {
       $( '#rateComment' ).toggle();
       $('#view').text($('#view').text() == 'View' ? 'Hide' : 'View');
    });
});
</script>
<!--- <cfdump var="#rc.Hotel#"> --->
