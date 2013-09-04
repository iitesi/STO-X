<cfoutput>

	<cfif rc.hotelSelected>
		<br class="clearfix">

		<!--- <div class="carrow" style="padding:0 0 15px 0;"> --->

		<div style="float:right;padding-right:20px;"><a href="#buildURL('hotel.search?SearchID=#rc.searchID#')#" style="color:##666">change / remove <span class="icon-remove-sign"></a></div><br>

			<table width="1000">
			<tr>

				<td></td>
				
				<td valign="top">
					
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

					<h2>HOTEL</h2>

				</td>

				<td colspan="3">
					<cfset isInPolicy = rc.Hotel.getRooms()[1].getIsInPolicy()>
					#(isInPolicy ? '' : '<span rel="tooltip" class="outofpolicy" title="Over maximum daily rate">OUT OF POLICY</span>&nbsp;&nbsp;&nbsp;')#

					<!--- All accounts when out of policy --->
					<cfif rc.showAll 
						OR (NOT isInPolicy
						AND rc.Policy.Policy_HotelReasonCode)>
						*&nbsp;&nbsp;
						<select name="hotelReasonCode" id="hotelReasonCode" class="input-xlarge #(structKeyExists(rc.errors, 'hotelReasonCode') ? 'error' : '')#">
						<option value="">Select Reason for Booking Out of Policy</option>
						<option value="P">Required property sold out</option>
						<option value="R">Required room rate sold out</option>
						<option value="C">Required property was higher than another property</option>
						<option value="L">Leisure Rental (paying for it themselves)</option>
						</select> <br><br>

					</cfif>

					<!--- State of Texas --->
					<cfif rc.showAll 
						OR rc.Filter.getAcctID() EQ 235>
						*&nbsp;&nbsp;
						<select name="udid112" id="udid112" class="input-xlarge #(structKeyExists(rc.errors, 'udid112') ? 'error' : '')#">
						<option value="">Select an Exception Code</option>
						<cfloop query="rc.qTXExceptionCodes">
							<option value="#rc.qTXExceptionCodes.FareSavingsCode#">#rc.qTXExceptionCodes.Description#</option>
						</cfloop>
						</select>
						<a href="http://www.window.state.tx.us/procurement/prog/stmp/exceptions-to-the-use-of-stmp-contracts/" target="_blank">View explanation of codes</a><br><br>

					</cfif>

				</td>

			</tr>
			<tr>

				<td width="50"></td>
				
				<td valign="top" width="120">
					<cfif findNoCase('https://', rc.Hotel.getSignatureImage())>
						<img alt="#rc.Hotel.getPropertyName()#" src="#rc.Hotel.getSignatureImage()#">
					</cfif>
				</td>

				<td width="630">

					<strong>
						#rc.Hotel.getPropertyName()#<br>
					</strong>

					#uCase(rc.Hotel.getAddress())#,
					#uCase(rc.Hotel.getCity())#,
					#uCase(rc.Hotel.getState())#
					#uCase(rc.Hotel.getZip())#
					#uCase(rc.Hotel.getCountry())#<br>

					<div style="width:630px;overflow:hidden;">#uCase(rc.Hotel.getRooms()[1].getDescription())#</div><br>

					<strong>
						CHECK-IN:
						#uCase(dateFormat(rc.Filter.getCheckInDate(), 'mmm d'))#
						&nbsp;&nbsp;&nbsp;
						CHECK-OUT: 
						#uCase(DateFormat(rc.Filter.getCheckOutDate(), 'mmm d'))#
						<cfset nights = dateDiff('d', rc.Filter.getCheckInDate(), rc.Filter.getCheckOutDate())>
						(#nights# NIGHT<cfif nights GT 1>S</cfif>)
					</strong>

				</td>

				<td width="200" valign="top">
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

					<span class="blue bold large">
						#(currency EQ 'USD' ? DollarFormat(hotelTotal) : hotelTotal&' '&currency)#<br>
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
		
					<span class="blue bold">
						<a rel="popover" data-original-title="Hotel payment and cancellation policy" data-content="#hotelPolicies#" href="##" />
							Hotel payment and cancellation policy
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

					#uCase(application.stHotelVendors[rc.Hotel.getChainCode()])# LOYALTY ##
					<input type="text" name="hotelFF" id="hotelFF" maxlength="20" class="input-medium">

				</td>

			</tr>
			</table>
		<!--- </div> --->

	</cfif>

</cfoutput>
<!--- <cfdump var="#rc.Hotel#"> --->