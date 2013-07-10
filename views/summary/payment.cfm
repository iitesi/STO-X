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
				<label class="control-label" for="AirCC_Number">Card Number</label>
				<div class="controls">
					<input type="text" name="AirCC_Number" id="AirCC_Number" size="20" maxlength="16" autocomplete="off">
				</div>
			</div>

			<div class="control-group">
				<label class="control-label" for="AirCC_Month">Expiration</label>
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
				<label class="control-label" for="AirBilling_Address">CVV Security Code</label>
				<div class="controls">
					<input type="text" name="AirBilling_CVV" id="AirBilling_CVV" maxlength="4" autocomplete="off" class="input-small">
				</div>
			</div>

			<div class="control-group">
				<label class="control-label" for="AirBilling_Name">Name on Card</label>
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
				<label class="control-label" for="AirBilling_Address">City</label>
				<div class="controls">
					<input type="text" name="AirBilling_City" id="AirBilling_City" maxlength="50" class="input-medium">
				</div>
			</div>

			<div class="control-group">
				<label class="control-label" for="AirBilling_Address">State, Zip</label>
				<div class="controls">
					<select name="AirBilling_State" id="AirBilling_State" class="input-small">
						<option value=""></option>
						<cfloop query="rc.qStates">
							<option value="#State_Code#">#State_Code#</option>
						</cfloop>
					</select>
					<input type="text" name="AirBilling_Zip" maxlength="15" class="input-small">
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
				<label class="control-label" for="hotelCC_Number">Card Number</label>
				<div class="controls">
					<input type="text" name="hotelCC_Number" id="hotelCC_Number" size="20" maxlength="16" autocomplete="off">
				</div>
			</div>

			<div class="control-group">
				<label class="control-label" for="hotelCC_Month">Expiration</label>
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
				<label class="control-label" for="hotelBilling_Address">CVV Security Code</label>
				<div class="controls">
					<input type="text" name="hotelBilling_CVV" id="hotelBilling_CVV" maxlength="4" autocomplete="off" class="input-small">
				</div>
			</div>

			<div class="control-group">
				<label class="control-label" for="hotelBilling_Name">Name on Card</label>
				<div class="controls">
					<input type="text" name="hotelBilling_Name" id="hotelBilling_Name" size="20" maxlength="50">
				</div>
			</div>

			<div class="control-group">
				<label class="control-label" for="hotelBilling_Address">Billing Address</label>
				<div class="controls">
					<input type="text" name="hotelBilling_Address" id="hotelBilling_Address" size="20" maxlength="50">
				</div>
			</div>

			<div class="control-group">
				<label class="control-label" for="hotelBilling_Address">City</label>
				<div class="controls">
					<input type="text" name="hotelBilling_City" id="hotelBilling_City" maxlength="50" class="input-medium">
				</div>
			</div>

			<div class="control-group">
				<label class="control-label" for="hotelBilling_Address">State, Zip</label>
				<div class="controls">
					<select name="hotelBilling_State" id="hotelBilling_State" class="input-small">
						<option value=""></option>
						<cfloop query="rc.qStates">
							<option value="#State_Code#">#State_Code#</option>
						</cfloop>
					</select>
					<input type="text" name="hotelBilling_Zip" maxlength="15" class="input-small">
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