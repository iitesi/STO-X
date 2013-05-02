<cfcomponent output="false">

<!---
init
--->
	<cffunction name="init" output="false">

		<cfreturn this>
	</cffunction>


<!--- 
payments
--->
	<cffunction name="payments" output="false" access="remote" returnformat="plain">
		<cfargument name="searchID">
		<cfargument name="nTraveler">
		<cfargument name="air">
		<cfargument name="hotel">
		<cfargument name="car">

		<cfset local.userID = session.searches[arguments.searchID].stTravelers[arguments.nTraveler].User_ID>
		<cfset local.valueID = session.searches[arguments.searchID].stTravelers[arguments.nTraveler].Value_ID>
		<cfset local.acctID = session.AcctID>

		<cfset local.FOPs = session.searches[arguments.searchID].stTravelers[arguments.nTraveler].listFOPs>
		<cfset local.AirFOP = getSelectedFOPs(arguments.searchID, arguments.nTraveler)>
		<cfset local.sForm = setPaymentForm(FOPs, AirFOP, arguments.air, arguments.hotel, arguments.car)>

		<cfreturn sForm/>
	</cffunction>

<!--- 
getSelectedFOPs
--->
	<cffunction name="getSelectedFOPs">
		<cfargument name="searchID">
		<cfargument name="nTraveler">

		<cfset local.AirFOP = {}>

		<!--- Get the data from the session struct if they already filled it out. --->
		<cfif structKeyExists(session.searches[arguments.searchID].stTravelers[arguments.nTraveler], "AirFOP")>
			<cfset AirFOP = session.searches[arguments.searchID].stTravelers[arguments.nTraveler].AirFOP>
		<!--- Default the data to blank if they haven't filled it out yet. --->
		<cfelse>
			<cfset AirFOP.AirFOP_ID = ''>
			<cfset AirFOP.FOP_ID = ''>
			<cfset AirFOP.BTA_ID = ''>
			<cfset AirFOP.CC_UseType = ''>
			<cfset AirFOP.CC_Number = ''>
			<cfset AirFOP.Billing_Name = ''>
			<cfset AirFOP.Billing_Address = ''>
			<cfset AirFOP.Billing_City = ''>
			<cfset AirFOP.Billing_State = ''>
			<cfset AirFOP.Billing_Zip = ''>
			<cfset AirFOP.Errors = {}>
		</cfif>

		<cfreturn AirFOP/>
	</cffunction>

<!---
setPaymentForm
--->
	<cffunction name="setPaymentForm" output="false">
		<cfargument name="FOPs">
		<cfargument name="AirFOP">
		<cfargument name="air">
		<cfargument name="hotel">
		<cfargument name="car">

		<cfsavecontent variable="local.sForm">
			<cfoutput>
				<!---
				AIR PAYMENT
				--->
				<cfif arguments.air>
					<cfset local.bExcludeEntry = false>
					<table width="500">
					<tr height="23">
						<td colspan="2" class="underline-heading"> <h2>Payment</h2></td>
					</tr>
					<tr>
						<td><label for="AirFOP_ID">Air Payment</label></td>
						<td>

						<select name="AirFOP_ID" id="AirFOP_ID" onChange="showManualCreditCard('Air');">
						<option value="">SELECT A PAYMENT</option>
						<cfif NOT structIsEmpty(arguments.FOPs)>
							<cfloop collection="#arguments.FOPs#" index="local.fopKey">
								<cfif arrayFind(arguments.FOPs[fopKey].Uses, 'A')>
									<option value="#fopKey#" <cfif arguments.AirFOP.AirFOP_ID EQ fopKey>selected</cfif>>#arguments.FOPs[fopKey].Billing_Name# - Ending in #NumberFormat(Right(arguments.FOPs[fopKey].CC_Number, 4), '0000')#</option>
									<cfif arguments.FOPs[fopKey].CC_Exclude>
										<cfset bExcludeEntry = true>
									</cfif>
								</cfif>
							</cfloop>
						</cfif>
						<cfif NOT bExcludeEntry>
							<option value="Manual" <cfif arguments.AirFOP.AirFOP_ID EQ 'Manual'>selected</cfif>>MANUAL ENTRY</option>
						</cfif>
						</select>

						</td>
					</tr>
					</table>
					<div id="AirManual" <cfif arguments.AirFOP.AirFOP_ID NEQ 'Manual'>style="display:none"</cfif>>
						<table width="500">
						<tr>
							<td><label for="AirCC_Code" class="#(structKeyExists(arguments.AirFOP.Errors, 'AirCC_Code') ? 'error' : '')#">Card Type</label></td>
							<td><select name="AirCC_Code" id="AirCC_Code">
								<option value=""></option>
								<option value="AX" <cfif arguments.AirFOP.AirFOP_ID EQ 'Manual' AND arguments.AirFOP.CC_Code EQ 'AX'>selected</cfif>>American Express</option>
								<option value="DS" <cfif arguments.AirFOP.AirFOP_ID EQ 'Manual' AND arguments.AirFOP.CC_Code EQ 'DS'>selected</cfif>>Discover</option>
								<option value="CA" <cfif arguments.AirFOP.AirFOP_ID EQ 'Manual' AND arguments.AirFOP.CC_Code EQ 'CA'>selected</cfif>>Mastercard</option>
								<option value="VI" <cfif arguments.AirFOP.AirFOP_ID EQ 'Manual' AND arguments.AirFOP.CC_Code EQ 'VI'>selected</cfif>>Visa</option>
								</select></td>
						</tr>
						<tr>
							<td><label for="AirCC_Number" class="#(structKeyExists(arguments.AirFOP.Errors, 'AirCC_Number') ? 'error' : '')#">Card Number</label></td>
							<td><input type="text" name="AirCC_Number" id="AirCC_Number" size="20" maxlength="16" autocomplete="off" <cfif arguments.AirFOP.AirFOP_ID EQ 'Manual'>value="#arguments.AirFOP.CC_Number#"</cfif>></td>
						</tr>
						<tr>
							<td><label for="AirCC_Month" class="#(structKeyExists(arguments.AirFOP.Errors, 'AirCC_Month') ? 'error' : '')#">Expiration Date</label></td>
							<td><select name="AirCC_Month" id="AirCC_Month">
								<option value=""></option>
								<cfloop from="1" to="12" index="m">
									<option value="#m#" <cfif arguments.AirFOP.AirFOP_ID EQ 'Manual' AND IsDate(arguments.AirFOP.CC_Expiration) AND Month(arguments.AirFOP.CC_Expiration) EQ m>selected</cfif>>#MonthAsString(m)#</option>
								</cfloop>
								</select>
								<select name="AirCC_Year">
								<option value=""></option>
								<cfloop from="#Year(Now())#" to="#Year(Now())+20#" index="y">
									<option value="#y#" <cfif arguments.AirFOP.AirFOP_ID EQ 'Manual' AND IsDate(arguments.AirFOP.CC_Expiration) AND Year(arguments.AirFOP.CC_Expiration) EQ y>selected</cfif>>#y#</option>
								</cfloop>
								</select> </td>
						</tr>
						<tr>
							<td><label for="AirBilling_Name" class="#(structKeyExists(arguments.AirFOP.Errors, 'AirBilling_Name') ? 'error' : '')#">Name as appears on Card</label></td>
							<td><input type="text" name="AirBilling_Name" id="AirBilling_Name" size="20" maxlength="50" <cfif arguments.AirFOP.AirFOP_ID EQ 'Manual'>value="#arguments.AirFOP.Billing_Name#"</cfif>></td>
						</tr>
						<tr>
							<td><label for="AirBilling_Address" class="#(structKeyExists(arguments.AirFOP.Errors, 'AirBilling_Address') ? 'error' : '')#">Billing Address</label></td>
							<td><input type="text" name="AirBilling_Address" id="AirBilling_Address" size="20" maxlength="50" <cfif arguments.AirFOP.AirFOP_ID EQ 'Manual'>value="#arguments.AirFOP.Billing_Address#"</cfif>></td>
						</tr>
						<tr>
							<td><label for="AirBilling_City" class="#(structKeyExists(arguments.AirFOP.Errors, 'AirBilling_City') ? 'error' : '')#">Billing City, State, Zip</label></td>
							<td><input type="text" name="AirBilling_City" id="AirBilling_City" size="20" maxlength="50" <cfif arguments.AirFOP.AirFOP_ID EQ 'Manual'>value="#arguments.AirFOP.Billing_City#"</cfif>>
								<input type="text" name="AirBilling_State" size="3" maxlength="2" <cfif arguments.AirFOP.AirFOP_ID EQ 'Manual'>value="#arguments.AirFOP.Billing_State#"</cfif>>,
								<input type="text" name="AirBilling_Zip" size="6" maxlength="15" <cfif arguments.AirFOP.AirFOP_ID EQ 'Manual'>value="#arguments.AirFOP.Billing_Zip#"</cfif>></td>
						</tr>
						<tr>
							<td><label for="AirBilling_CVV" class="#(structKeyExists(arguments.AirFOP.Errors, 'AirBilling_CVV') ? 'error' : '')#">CVV Code</label></td>
							<td><input type="text" name="AirBilling_CVV" id="AirBilling_CVV" size="4" maxlength="4" autocomplete="off" <cfif arguments.AirFOP.AirFOP_ID EQ 'Manual'>value="#arguments.AirFOP.Billing_CVV#"</cfif>></td></td>
						</tr>
						</table>
					</div>
				</cfif>
				<!---
				CAR PAYMENT
				<cfif arguments.Car>
					<table width="500">
					<tr>
						<td colspan="2">
							<h4>Car Payment</h4>
							<select name="CarFOP_ID" id="CarFOP_ID">
							<cfif arguments.bDB NEQ '' OR arguments.bCD NEQ ''>
								<cfif arguments.bDB NEQ ''>
									<option value="DB_#arguments.bDB#">Direct Bill</option>
								</cfif>
								<cfif arguments.bCD NEQ ''>
									<option value="CD_#arguments.bCD#">Individual Pay at Counter</option>
								</cfif>
							<cfelse>
								<option>Present Card at Counter</option>
							</cfif>
							</select>
						</td>
					</tr>
					</table>
				</cfif>
				--->
				</table>
				<!--- <cfdump var="#stTraveler#"> --->
			</cfoutput>
		</cfsavecontent>

		<cfreturn serializeJSON(sForm)>
	</cffunction>

</cfcomponent>