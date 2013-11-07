<cfoutput>

	<h2>PAYMENT</h2>

	<cfif rc.airSelected>
		<div id="airPayment">
		
		<div class="control-group">
			<label class="control-label" for="airFOPID"><strong>Flight Payment *</strong></label>
			<div class="controls" id="airFOPIDDiv">
				<i id="airSpinner" class="blue icon icon-spin icon-spinner"></i>
				<select name="airFOPID" id="airFOPID">
				</select>
			</div>
		</div>

		<div id="airNewCard" class="control-group">
			<label class="control-label" for="newAirCC">Enter New Card</label>
			<div class="controls newCard">
				<input type="checkbox" name="newAirCC" id="newAirCC" value="1" />
			</div>
		</div>

		<div id="airManual" class="hide">

			<div class="control-group #(structKeyExists(rc.errors, 'airCCNumber') ? 'error' : '')#">
				<label class="control-label" for="airCCNumber">Card Number *</label>
				<div class="controls">
					<input type="text" name="airCCNumber" id="airCCNumber" size="20" maxlength="16" autocomplete="off">
				</div>
			</div>

			<div class="control-group #(structKeyExists(rc.errors, 'airCCExpiration') ? 'error' : '')#">
				<label class="control-label" for="airCCMonth">Expiration *</label>
				<div class="controls">
					<select name="airCCMonth" id="airCCMonth" class="input-medium">
						<option value=""></option>
						<cfloop from="1" to="12" index="m">
							<option value="#m#">#MonthAsString(m)#</option>
						</cfloop>
					</select>
					<select name="airCCYear" id="airCCYear" class="input-small">
						<option value=""></option>
						<cfloop from="#Year(Now())#" to="#Year(Now())+20#" index="y">
							<option value="#y#">#y#</option>
						</cfloop>
					</select>
				</div>
			</div>

			<div class="control-group #(structKeyExists(rc.errors, 'airCCCVV') ? 'error' : '')#">
				<label class="control-label" for="airCCCVV">CVV Security Code *</label>
				<div class="controls">
					<input type="text" name="airCCCVV" id="airCCCVV" maxlength="4" autocomplete="off" class="input-small">
				</div>
			</div>

			<div class="control-group #(structKeyExists(rc.errors, 'airBillingName') ? 'error' : '')#">
				<label class="control-label" for="airBillingName">Name on Card *</label>
				<div class="controls">
					<input type="text" name="airBillingName" id="airBillingName" maxlength="50">
				</div>
			</div>

			<div class="control-group #(structKeyExists(rc.errors, 'airBillingAddress') ? 'error' : '')#">
				<label class="control-label" for="airBillingAddress">Billing Address *</label>
				<div class="controls">
					<input type="text" name="airBillingAddress" id="airBillingAddress" maxlength="50">
				</div>
			</div>

			<div class="control-group #(structKeyExists(rc.errors, 'airBillingCity') ? 'error' : '')#">
				<label class="control-label" for="airBillingCity">City *</label>
				<div class="controls">
					<input type="text" name="airBillingCity" id="airBillingCity" maxlength="50" class="input-medium">
				</div>
			</div>

			<div class="control-group #(structKeyExists(rc.errors, 'airBillingState') ? 'error' : '')#">
				<label class="control-label" for="airBillingState">State, Zip *</label>
				<div class="controls">
					<select name="airBillingState" id="airBillingState" class="input-small">
						<option value=""></option>
						<cfloop query="rc.qStates">
							<option value="#State_Code#">#State_Code#</option>
						</cfloop>
					</select>
					<input type="text" name="airBillingZip" id="airBillingZip" maxlength="15" class="input-small">
				</div>
			</div>

		</div>

		<div class="blue bold" style="text-align:right; margin:-10px 0 10px;">
			<a rel="popover" data-original-title="Flight change/cancellation policy" data-content="Cancellations: Ticket is #(rc.Air.Ref ? '' : 'non-')#refundable.<br>Changes: Change USD #rc.Air.changePenalty# for reissue." href="##" />
				Flight change/cancellation policy
			</a>
		</div>

		</div>
	</cfif>

	<cfif rc.hotelSelected>
		<div id="hotelPayment">
			
		<div class="control-group">
			<label class="control-label" for="hotelFOPID"><strong>Hotel Payment *</strong></label>
			<div class="controls" id="hotelFOPIDDiv">
				<i id="hotelSpinner" class="blue icon icon-spin icon-spinner"></i>
				<select name="hotelFOPID" id="hotelFOPID">
				</select>
			</div>
		</div>

		<div id="hotelNewCard" class="control-group">
			<label class="control-label" for="newHotelCC">Enter New Card</label>
			<div class="controls newCard">
				<input type="checkbox" name="newHotelCC" id="newHotelCC" value="1" />
			</div>
		</div>

		<div id="hotelManual" class="hide">

			<div class="control-group #(rc.airSelected EQ 0 ? 'hide' : '')#" id="copyAirCCDiv">
				<label class="control-label" for="copyAirCC"></label>
				<div class="controls">
					<label class="copyAirCC">
						<input type="checkbox" name="copyAirCC" id="copyAirCC" value="1">
						Copy air payment
					</label>
				</div>
			</div>

			<div class="control-group #(structKeyExists(rc.errors, 'hotelCCNumber') ? 'error' : '')#">
				<label class="control-label" for="hotelCCNumber">Card Number *</label>
				<div class="controls">
					<input type="text" name="hotelCCNumber" id="hotelCCNumber" size="20" maxlength="16" autocomplete="off">
				</div>
			</div>

			<div class="control-group #(structKeyExists(rc.errors, 'hotelCCExpiration') ? 'error' : '')#">
				<label class="control-label" for="hotelCCMonth">Expiration *</label>
				<div class="controls">
					<select name="hotelCCMonth" id="hotelCCMonth" class="input-medium">
						<option value=""></option>
						<cfloop from="1" to="12" index="m">
							<option value="#m#">#MonthAsString(m)#</option>
						</cfloop>
					</select>
					<select name="hotelCCYear" id="hotelCCYear" class="input-small">
						<option value=""></option>
						<cfloop from="#Year(Now())#" to="#Year(Now())+20#" index="y">
							<option value="#y#">#y#</option>
						</cfloop>
					</select>
				</div>
			</div>

			<div class="control-group #(structKeyExists(rc.errors, 'hotelBillingName') ? 'error' : '')#">
				<label class="control-label" for="hotelBillingName">Name on Card *</label>
				<div class="controls">
					<input type="text" name="hotelBillingName" id="hotelBillingName" size="20" maxlength="50">
				</div>
			</div>

		</div>

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

		<div class="blue bold" style="text-align:right; margin:-10px 0 10px;">
			<a rel="popover" data-original-title="Hotel payment and cancellation policy" data-content="#hotelPolicies#" href="##" />
				Hotel payment and cancellation policy  
			</a>
		</div>

		</div>
	</cfif>

	<cfif rc.vehicleSelected>
		<div id="carPayment">
		
		<div class="control-group">
			<label class="control-label" for="carFOPID"><strong>Car Payment *</strong></label>
			<div class="controls">
				<i id="carSpinner" class="blue icon icon-spin icon-spinner"></i>
				<select name="carFOPID" id="carFOPID">
				</select>
			</div>
		</div>

		<div class="blue bold" style="text-align:right; margin:-10px 0 10px;">
			<a rel="popover" data-original-title="Car payment and cancellation policy" data-content="Payment is taken by the vendor. You may cancel at anytime for no fee." href="##" />
				Car payment and cancellation policy
			</a>
		</div>

		</div>
	</cfif>

</cfoutput>