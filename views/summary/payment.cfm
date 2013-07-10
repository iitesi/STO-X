<cfoutput>

	<span class="underline-heading"> <h2>Payment</h2></span>

	<div class="control-group">
		<label class="control-label" for="airFOPID">Air Payment</label>
		<div class="controls">
			<select name="airFOPID" id="airFOPID">
			</select>
		</div>
	</div>

	<div id="airManual" class="hide">

		<div class="control-group">
			<label class="control-label" for="AirCC_Code">Card Type</label>
			<div class="controls">
				<select name="AirCC_Code" id="AirCC_Code" class="input-medium">
					<option value=""></option>
					<option value="AX">American Express</option>
					<option value="DS">Discover</option>
					<option value="CA">Mastercard</option>
					<option value="VI">Visa</option>
				</select>
			</div>
		</div>

		<div class="control-group">
			<label class="control-label" for="AirCC_Number">Card Number</label>
			<div class="controls">
				<input type="text" name="AirCC_Number" id="AirCC_Number" size="20" maxlength="16" autocomplete="off">
			</div>
		</div>

		<div class="control-group">
			<label class="control-label" for="AirCC_Month">Expiration Date</label>
			<div class="controls">
				<select name="AirCC_Month" id="AirCC_Month" class="input-medium">
					<option value=""></option>
					<cfloop from="1" to="12" index="m">
						<option value="#m#">#MonthAsString(m)#</option>
					</cfloop>
				</select>
				<select name="AirCC_Year" id="AirCC_Year" class="input-small">
					<option value=""></option>
					<cfloop from="#Year(Now())#" to="#Year(Now())+20#" index="y">
						<option value="#y#">#y#</option>
					</cfloop>
				</select>
			</div>
		</div>

		<div class="control-group">
			<label class="control-label" for="AirBilling_Name">Name as appears on Card</label>
			<div class="controls">
				<input type="text" name="AirBilling_Name" id="AirBilling_Name" size="20" maxlength="50">
			</div>
		</div>

		<div class="control-group">
			<label class="control-label" for="AirBilling_Address">Billing Address</label>
			<div class="controls">
				<input type="text" name="AirBilling_Address" id="AirBilling_Address" size="20" maxlength="50">
			</div>
		</div>

		<div class="control-group">
			<label class="control-label" for="AirBilling_Address">Billing City, State, Zip</label>
			<div class="controls">
				<input type="text" name="AirBilling_City" id="AirBilling_City" maxlength="50" class="input-medium">
				<input type="text" name="AirBilling_State" maxlength="2" class="input-small">,
				<input type="text" name="AirBilling_Zip" maxlength="15" class="input-small">
			</div>
		</div>

		<div class="control-group">
			<label class="control-label" for="AirBilling_Address">CVV Code</label>
			<div class="controls">
				<input type="text" name="AirBilling_CVV" id="AirBilling_CVV" maxlength="4" autocomplete="off" class="input-small">
			</div>
		</div>

	</div>

	<div class="control-group">
		<label class="control-label" for="hotelFOPID">Hotel Payment</label>
		<div class="controls">
			<select name="hotelFOPID" id="hotelFOPID">
			</select>
		</div>
	</div>

	<div id="hotelManual" class="hide">

		<div class="control-group">
			<label class="control-label" for="hotelCC_Code">Card Type</label>
			<div class="controls">
				<select name="hotelCC_Code" id="hotelCC_Code" class="input-medium">
					<option value=""></option>
					<option value="AX">American Express</option>
					<option value="DS">Discover</option>
					<option value="CA">Mastercard</option>
					<option value="VI">Visa</option>
				</select>
			</div>
		</div>

		<div class="control-group">
			<label class="control-label" for="hotelCC_Number">Card Number</label>
			<div class="controls">
				<input type="text" name="hotelCC_Number" id="hotelCC_Number" size="20" maxlength="16" autocomplete="off">
			</div>
		</div>

		<div class="control-group">
			<label class="control-label" for="hotelCC_Month">Expiration Date</label>
			<div class="controls">
				<select name="hotelCC_Month" id="hotelCC_Month" class="input-medium">
					<option value=""></option>
					<cfloop from="1" to="12" index="m">
						<option value="#m#">#MonthAsString(m)#</option>
					</cfloop>
				</select>
				<select name="hotelCC_Year" id="hotelCC_Year" class="input-small">
					<option value=""></option>
					<cfloop from="#Year(Now())#" to="#Year(Now())+20#" index="y">
						<option value="#y#">#y#</option>
					</cfloop>
				</select>
			</div>
		</div>

		<div class="control-group">
			<label class="control-label" for="hotelBilling_Name">Name as appears on Card</label>
			<div class="controls">
				<input type="text" name="hotelBilling_Name" id="hotelBilling_Name" size="20" maxlength="50">
			</div>
		</div>

	</div>

	<div class="control-group">
		<label class="control-label" for="carFOPID">Car Payment</label>
		<div class="controls">
			<select name="carFOPID" id="carFOPID">
			</select>
		</div>
	</div>

</cfoutput>