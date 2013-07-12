<cfoutput>

	<cfif rc.hotelSelected>
		<br class="clearfix">

		<div class="carrow" style="padding:0 0 15px 0;">

			<div style="float:right;padding-right:20px;"><a href="#buildURL('car.availability?SearchID=#rc.searchID#')#" style="color:##666">change / remove <span class="icon-remove-sign"></a></div><br>

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
					<cfset isInPolicy = 0> <!--- rc.Hotel.getIsInPolicy() --->
					#(isInPolicy ? '' : '<span rel="tooltip" class="outofpolicy" title="Over maximum daily rate">OUT OF POLICY</span>&nbsp;&nbsp;&nbsp;')#

					<!--- All accounts when out of policy --->
					<cfif NOT isInPolicy
						AND rc.Policy.Policy_HotelReasonCode EQ 1>

						<select name="hotelReasonCode" id="hotelReasonCode" class="input-xlarge">
						<option value="">Select Reason for Booking Out of Policy</option>
						<option value="P">Required property sold out</option>
						<option value="R">Required room rate sold out</option>
						<option value="C">Required property was higher than another property</option>
						<option value="L">Leisure Rental (paying for it themselves)</option>
						</select> &nbsp;&nbsp;&nbsp; <i>(required)</i><br><br>

					</cfif>

					<!--- State of Texas --->
					<cfif rc.Filter.getAcctID() EQ 235>

						<select name="udid112" id="udid112" class="input-xlarge">
						<option value="">SELECT AN EXCEPTION CODE</option>
						<cfloop query="rc.qTXExceptionCodes">
							<option value="#rc.qTXExceptionCodes.FareSavingsCode#">#rc.qTXExceptionCodes.Description#</option>
						</cfloop>
						</select> &nbsp;&nbsp;&nbsp; <i>(required)</i><br><br>

					</cfif>

				</td>

			</tr>
			<tr>

				<td width="50"></td>
				
				<td valign="top" width="120">

					<img alt="#rc.Hotel.getPropertyName()#" src="#rc.Hotel.getSignatureImage()#">

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

					#uCase(rc.Hotel.getRooms()[1].getDescription())#<br>

					<strong>
						CHECK-IN:
						#uCase(dateFormat(rc.Filter.getCheckInDate(), 'mmm d'))#
						&nbsp;&nbsp;&nbsp;
						CHECK-OUT: 
						#uCase(DateFormat(rc.Filter.getCheckOutDate(), 'mmm d'))#
					</strong>

				</td>

				<td width="200" valign="top">

					<cfset tripTotal = (rc.Hotel.getRooms()[1].getTotalForStayCurrency() EQ 'USD' ? tripTotal + rc.Hotel.getRooms()[1].getTotalForStay() : 'CURR')>

					<span class="blue bold large">
						#(rc.Hotel.getRooms()[1].getTotalForStayCurrency() EQ 'USD' ? DollarFormat(rc.Hotel.getRooms()[1].getTotalForStay()) : rc.Hotel.getRooms()[1].getTotalForStay()&' '&rc.Hotel.getRooms()[1].getTotalForStayCurrency())#<br>
					</span>

					Estimated Rate<br>
					Taxes quoted at check-in<br>

					<span class="blue bold">
						Hotel payment and cancellation policy
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
		</div>

	</cfif>

</cfoutput>
<!--- <cfdump var="#rc.Hotel#"> --->