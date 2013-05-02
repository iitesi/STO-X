<!--- <cfset local.bFormShown = false>
<cfset local.bCollapse = arguments.bCollapse>
<cfif Traveler.User_ID EQ 0>
<cfset bCollapse = false>
</cfif> --->
<cfoutput>
	<table width="500" height="290">
	<tr height="23">
		<td colspan="2" class="underline-heading"> <h2>Traveler</h2></td>
	</tr>
	<tr height="23">
		<td><label for="userID">Change Traveler</label></td>
		<td><select name="userID" id="userID">
			<option value="">SELECT A TRAVELER</option>
			<option value="0">GUEST TRAVELER</option>
			</select>
		</td>
</tr>
	<tr height="23">
		<td><label for="firstName">First Name</label></td>
		<td><input type="text" name="firstName" id="firstName"></td>
	</tr>
	<tr height="23">
		<td><label for="middleName">Middle Name</label></td>
		<td><input type="text" name="middleName" id="middleName">
			<input type="checkbox" name="NoMiddleName" value="1">
			No middle name</td>
	</tr>
	<tr height="23">
		<td><label for="lastName">Last Name</label></td>
		<td><input type="text" name="lastName" id="lastName"></td>
	</tr>
	<tr height="23">
		<td><label for="phoneNumber">Business Phone</label></td>
		<td><input type="text" name="phoneNumber" id="phoneNumber"></td>
	</tr>
	<tr height="23">
		<td><label for="wirelessPhone">Wireless Phone</label></td>
		<td><input type="text" name="wirelessPhone" id="wirelessPhone"></td>
	</tr>
	<tr height="23">
		<td><label for="email">Email</label></td>
		<td><input type="text" name="email" id="email" size="50"></td>
	</tr>
	<tr height="23">
		<td><label for="Month">Birthday</label></td>
		<td><select name="birthdayMonth" id="birthdayMonth">
			<option value=""></option>
			<cfloop from="1" to="12" index="i">
				<option value="#i#">#MonthAsString(i)#</option>
			</cfloop>
			</select>

			<select name="birthdayDay" id="birthdayDay">
			<option value=""></option>
			<cfloop from="1" to="31" index="i">
				<option value="#i#">#i#</option>
			</cfloop>
			</select>

			<select name="birthdayYear" id="birthdayYear">
			<option value=""></option>
			<option value="****" selected>****</option>
			<cfloop from="#Year(Now())#" to="#Year(Now())-100#" step="-1" index="i">
				<option value="#i#">#i#</option>
			</cfloop>
			</select></td>
	</tr>
	<tr height="23">
		<td><label for="gender">Gender</label></td>
		<td><select name="gender" id="gender">
			<option value=""></option>
			<option value="M">Male</option>
			<option value="F">Female</option>
			</select></td>
	</tr>
	<tr height="23">
		<td><label for="ccEmails">CC Emails</label></td>
		<td><input type="text" name="ccEmails" id="ccEmails" size="50"></td>
	</tr>
	<!---
	<!--- <cfdump var="#Traveler.OUs#"> --->
	<cfoutput query="qAllOUs" group="OU_ID">
		<tr height="23">
			<td>
				<label for="#qAllOUs.OU_Type##qAllOUs.OU_Position#" class="#(structKeyExists(Traveler.Errors, qAllOUs.OU_Type&qAllOUs.OU_Position) ? 'error' : '')#">#qAllOUs.OU_Name#</label><!--- Sort1 OR UDID55 --->
			</td>
			<td>
				<cfif bCollapse AND StructKeyExists(Traveler.OUs, qAllOUs.OU_ID) AND Traveler.OUs[qAllOUs.OU_ID].Value_ID NEQ ''>
					#Traveler.OUs[qAllOUs.OU_ID].Value_Display#
					<input type="hidden" name="#qAllOUs.OU_Type##qAllOUs.OU_Position#" id="#qAllOUs.OU_Type##qAllOUs.OU_Position#" value="#Traveler.OUs[qAllOUs.OU_Type&qAllOUs.OU_Position].Value_ID#">
				<cfelse>
					<cfif qAllOUs.OU_Freeform>
						<input type="text" name="#qAllOUs.OU_Type##qAllOUs.OU_Position#" id="#qAllOUs.OU_Type##qAllOUs.OU_Position#" <cfif StructKeyExists(Traveler.OUs, qAllOUs.OU_Type&qAllOUs.OU_Position)>value="#Traveler.OUs[qAllOUs.OU_Type&qAllOUs.OU_Position].Value_ID#"</cfif> size="#(qAllOUs.OU_Max GT 20 ? 20 : qAllOUs.OU_Max+1)#" maxlength="#qAllOUs.OU_Max#">
					<cfelse>
						<select name="#qAllOUs.OU_Type##qAllOUs.OU_Position#" id="#qAllOUs.OU_Type##qAllOUs.OU_Position#">
						<option value=""></option>
						<cfoutput>
							<option value="#qAllOUs.Value_Report#" <cfif StructKeyExists(Traveler.OUs, qAllOUs.OU_Type&qAllOUs.OU_Position) AND Traveler.OUs[qAllOUs.OU_Type&qAllOUs.OU_Position].Value_Report EQ qAllOUs.Value_Report>selected</cfif>>#qAllOUs.Value_Display#</option>
						</cfoutput>
						</select>
					</cfif>
					<cfset local.bFormShown = true>
				</cfif>
			</td>
		</tr>
		<input type="hidden" name="#qAllOUs.OU_Type##qAllOUs.OU_Position#_Required" value="#qAllOUs.OU_Required#">
	</cfoutput>
	<cfif Traveler.Type EQ 'Profiled' AND bFormShown>
		<tr height="23">
			<td colspan="2" align="right">
				<input type="checkbox" name="bSaveChanges" value="1" checked> Save changes to profile
			</td>
		</tr>
	</cfif>
	<cfif bCollapse AND Traveler.Type EQ 'Profiled'>
		<tr height="23">
			<td colspan="2">
				<a href="##" onClick="setTravelerForm(#nTraveler#, 0);">Edit All Traveler Information</a>
			</td>
		</tr>
	</cfif>--->
	</table>
</cfoutput>