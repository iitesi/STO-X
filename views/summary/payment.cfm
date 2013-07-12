<cfoutput>

	<span class="underline-heading"> <h2>Payment</h2></span>

	<cfif rc.airSelected>
		
		<div class="control-group">
			<label class="control-label" for="airFOPID"><strong>Flight Payment</strong></label>
			<div class="controls">
				<select name="airFOPID" id="airFOPID">
				</select>
			</div>
		</div>

		<div id="airManual" class="hide">

			<div class="control-group">
				<label class="control-label" for="airCCNumber">Card Number</label>
				<div class="controls">
					<input type="text" name="airCCNumber" id="airCCNumber" size="20" maxlength="16" autocomplete="off">
				</div>
			</div>

			<div class="control-group">
				<label class="control-label" for="airCCMonth">Expiration</label>
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

			<div class="control-group">
				<label class="control-label" for="airBillingCVV">CVV Security Code</label>
				<div class="controls">
					<input type="text" name="airBillingCVV" id="airBillingCVV" maxlength="4" autocomplete="off" class="input-small">
				</div>
			</div>

			<div class="control-group">
				<label class="control-label" for="airBillingName">Name on Card</label>
				<div class="controls">
					<input type="text" name="airBillingName" id="airBillingName" size="20" maxlength="50">
				</div>
			</div>

			<div class="control-group">
				<label class="control-label" for="airBillingAddress">Billing Address</label>
				<div class="controls">
					<input type="text" name="airBillingAddress" id="airBillingAddress" size="20" maxlength="50">
				</div>
			</div>

			<div class="control-group">
				<label class="control-label" for="airBillingCity">City</label>
				<div class="controls">
					<input type="text" name="airBillingCity" id="airBillingCity" maxlength="50" class="input-medium">
				</div>
			</div>

			<div class="control-group">
				<label class="control-label" for="airBillingState">State, Zip</label>
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

			<div class="control-group hide" id="airSaveCardDiv">
				<div class="controls">
					<label class="checkbox">
						<input type="checkbox" name="airSaveCard" id="airSaveCard" value="1">
						Save this card to my profile
					</label>
				</div>
			</div>

			<div class="control-group hide" id="airSaveNameDiv">
				<label class="control-label" for="airSaveName">Name this card</label>
				<div class="controls">
					<input type="text" name="airSaveName" id="airSaveName" maxlength="50" class="input-medium">
				</div>
			</div>

		</div>

	</cfif>

	<cfif rc.hotelSelected>
			
		<div class="control-group">
			<label class="control-label" for="hotelFOPID"><strong>Hotel Payment</strong></label>
			<div class="controls">
				<select name="hotelFOPID" id="hotelFOPID">
				</select>
			</div>
		</div>

		<div id="hotelManual" class="hide">

			<div class="control-group">
				<label class="control-label" for="hotelCCNumber">Card Number</label>
				<div class="controls">
					<input type="text" name="hotelCCNumber" id="hotelCCNumber" size="20" maxlength="16" autocomplete="off">
				</div>
			</div>

			<div class="control-group">
				<label class="control-label" for="hotelCCMonth">Expiration</label>
				<div class="controls">
					<select name="hotelCC_Month" id="hotelCCMonth" class="input-medium">
						<option value=""></option>
						<cfloop from="1" to="12" index="m">
							<option value="#m#">#MonthAsString(m)#</option>
						</cfloop>
					</select>
					<select name="hotelCC_Year" id="hotelCCYear" class="input-small">
						<option value=""></option>
						<cfloop from="#Year(Now())#" to="#Year(Now())+20#" index="y">
							<option value="#y#">#y#</option>
						</cfloop>
					</select>
				</div>
			</div>

			<div class="control-group">
				<label class="control-label" for="hotelBillingName">Name on Card</label>
				<div class="controls">
					<input type="text" name="hotelBillingName" id="hotelBillingName" size="20" maxlength="50">
				</div>
			</div>

			<div class="control-group hide" id="hotelSaveCardDiv">
				<div class="controls">
					<label class="checkbox">
						<input type="checkbox" name="hotelSaveCard" id="hotelSaveCard" value="1">
						Save this card to my profile
					</label>
				</div>
			</div>

			<div class="control-group hide" id="hotelSaveNameDiv">
				<label class="control-label" for="hotelSaveName">Name this card</label>
				<div class="controls">
					<input type="text" name="hotelSaveName" id="hotelSaveName" maxlength="50" class="input-medium">
				</div>
			</div>

		</div>

	</cfif>

	<cfif rc.vehicleSelected>
		
		<div class="control-group">
			<label class="control-label" for="carFOPID">Car Payment</label>
			<div class="controls">
				<select name="carFOPID" id="carFOPID">
				</select>
			</div>
		</div>

	</cfif>

</cfoutput>