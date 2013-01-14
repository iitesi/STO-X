<cfoutput>
	<div class="summarydiv">
		<div id="paymentForm"> </div>
		<!--- <cfset stTraveler 	= (StructKeyExists(session.searches[rc.nSearchID].stTravelers, nTraveler) ? session.searches[rc.nSearchID].stTravelers[nTraveler] : {})>
		<cfset sType 		= (StructKeyExists(stTraveler, 'Type') ? stTraveler.Type : 'New')>
		<h2 style="width:500px">PAYMENT INFORMATION</h2>
<!---
AIR PAYMENT
--->
		<cfif bAir>
			<cfset bExcludeEntry = false>
			<p>
				<br><h4>Air Payment</h4>
				<select name="AirFOP_ID" id="AirFOP_ID" onChange="showManualCreditCard('Air');">
				<option value="">SELECT A PAYMENT</option>
				<cfloop collection="#stTraveler.stFOPs#" index="nFOP">
					<cfif ArrayFind(stTraveler.stFOPs[nFOP].aUses, 'A')>
						<option value="#nFOP#">#stTraveler.stFOPs[nFOP].Billing_Name# - Ending in #NumberFormat(Right(stTraveler.stFOPs[nFOP].CC_Number, 4), '0000')#</option>
						<cfif stTraveler.stFOPs[nFOP].CC_Exclude>
							<cfset bExcludeEntry = true>
						</cfif>
					</cfif>
				</cfloop>
				<cfif NOT bExcludeEntry>
					<option value="Manual">MANUAL ENTRY</option>
				</cfif>
				</select>
			</p>
			<div id="AirManual" style="display:none">
				<table>
				<tr>
					<td><label for="AirCC_Code">Card Type</label></td>
					<td><select name="AirCC_Code" id="AirCC_Code">
						<option value=""></option>
						<option value="AX">American Express</option>
						<option value="DS">Discover</option>
						<option value="CA">Mastercard</option>
						<option value="VI">Visa</option>
						</select></td>
				</tr>
				<tr>
					<td><label for="AirCC_Number">Card Number</label></td>
					<td><input type="text" name="AirCC_Number" id="AirCC_Number" size="20" maxlength="16" autocomplete="off"></td>
				</tr>
				<tr>
					<td><label for="AirCC_Month">Expiration Date</label></td>
					<td><select name="AirCC_Month" id="AirCC_Month">
						<option value=""></option>
						<cfloop from="1" to="12" index="m">
							<option value="#m#">#MonthAsString(m)#</option>
						</cfloop>
						</select>
						<select name="AirCC_Year">
						<option value=""></option>
						<cfloop from="#Year(Now())#" to="#Year(Now())+20#" index="y">
							<option value="#y#">#y#</option>
						</cfloop>
						</select> </td>
				</tr>
				<tr>
					<td><label for="AirBilling_Name">Name as appears on Card</label></td>
					<td><input type="text" name="AirBilling_Name" id="AirBilling_Name" size="20" maxlength="50"></td>
				</tr>
				<tr>
					<td><label for="AirBilling_Address">Billing Address</label></td>
					<td><input type="text" name="AirBilling_Address" id="AirBilling_Address" size="20" maxlength="50"></td>
				</tr>
				<tr>
					<td><label for="AirBilling_City">Billing City, State, Zip</label></td>
					<td><input type="text" name="AirBilling_City" id="AirBilling_City" size="20" maxlength="50">
						<input type="text" name="AirBilling_State" size="3" maxlength="2">,
						<input type="text" name="AirBilling_Zip" size="6" maxlength="15"></td>
				</tr>
				<tr>
					<td><label for="AirBilling_CVV">CVV Code</label></td>
					<td><input type="text" name="AirBilling_CVV" id="AirBilling_CVV" size="4" maxlength="4" autocomplete="off"></td>
				</tr>
				</table>
			</div>
		</cfif>
<!---
HOTEL PAYMENT
--->
		<cfif bHotel>
			<p>
				Hotel Payment<br>
				<select name="HotelFOP_ID" id="HotelFOP_ID" onChange="showManualCreditCard('Hotel');">
				<option value="">SELECT A PAYMENT</option>
				<cfloop collection="#stTraveler.stFOPs#" index="nFOP">
					<cfif ArrayFind(stTraveler.stFOPs[nFOP].aUses, 'H')>
						<option value="#nFOP#">#stTraveler.stFOPs[nFOP].Billing_Name# - Ending in #NumberFormat(Right(stTraveler.stFOPs[nFOP].CC_Number, 4), '0000')#</option>
						<cfif stTraveler.stFOPs[nFOP].CC_Exclude>
							<cfset bExcludeEntry = true>
						</cfif>
					</cfif>
				</cfloop>
				<cfif NOT bExcludeEntry>
					<option value="Manual">MANUAL ENTRY</option>
				</cfif>
				</select>
			</p>
			<div id="HotelManual" style="display:none">
				<table width="100%">
				<tr>
					<td><label for="HotelCC_Code">Card Type</label></td>
					<td><select name="HotelCC_Code" id="HotelCC_Code">
						<option value=""></option>
						<option value="AX">American Express</option>
						<option value="DS">Discover</option>
						<option value="CA">Mastercard</option>
						<option value="VI">Visa</option>
						</select></td>
				</tr>
				<tr>
					<td><label for="HotelCC_Number">Card Number</label></td>
					<td><input type="text" name="HotelCC_Number" id="HotelCC_Number" size="20" maxlength="16" autocomplete="off"></td>
				</tr>
				<tr>
					<td><label for="HotelCC_Month">Expiration Date</label></td>
					<td><select name="HotelCC_Month" id="HotelCC_Month">
						<option value=""></option>
						<cfloop from="1" to="12" index="m">
							<option value="#m#">#MonthAsString(m)#</option>
						</cfloop>
						</select>
						<select name="AirCC_Year">
						<option value=""></option>
						<cfloop from="#Year(Now())#" to="#Year(Now())+20#" index="y">
							<option value="#y#">#y#</option>
						</cfloop>
						</select> </td>
				</tr>
				<tr>
					<td><label for="HotelBilling_Name">Name as appears on Card</label></td>
					<td><input type="text" name="HotelBilling_Name" id="HotelBilling_Name" size="20" maxlength="50"></td>
				</tr>
				<tr>
					<td><label for="AirBilling_Address">Billing Address</label></td>
					<td><input type="text" name="HotelBilling_Address" id="HotelBilling_Address" size="20" maxlength="50"></td>
				</tr>
				<tr>
					<td><label for="HotelBilling_City">Billing City, State, Zip</label></td>
					<td><input type="text" name="HotelBilling_City" id="HotelBilling_City" size="20" maxlength="50">
						<input type="text" name="HotelBilling_State" size="3" maxlength="2">,
						<input type="text" name="HotelBilling_Zip" size="6" maxlength="15"></td>
				</tr>
				<tr>
					<td><label for="AirBilling_CVV">CVV Code</label></td>
					<td><input type="text" name="HotelBilling_CVV" id="HotelBilling_CVV" size="4" maxlength="4" autocomplete="off"></td>
				</tr>
				</table>
			</div>
		</cfif>
<!---
CAR PAYMENT
--->
		<cfif bCar>
			<p>
				<br><h4>Car Payment</h4>
				<select name="CarFOP_ID" id="CarFOP_ID">
				<cfif StructKeyExists(stPolicy, 'stCDNumbers')
				AND StructKeyExists(stPolicy.stCDNumbers, stItinerary.Car.VendorCode)>
					<cfset stCD = stPolicy.stCDNumbers[stItinerary.Car.VendorCode]>
					<cfif stCD.DB NEQ ''>
						<option value="DB_#stCD.DB#">Direct Bill</option>
					</cfif>
					<cfif stCD.CD NEQ ''>
						<option value="CD_#stCD.CD#">Individual Pay at Counter</option>
					</cfif>
				<cfelse>
					<option>Present Card at Counter</option>
				</cfif>
				</select>
			</p>
		</cfif> --->
	</div>
</cfoutput>