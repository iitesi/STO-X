<cfoutput>
	<span class="underline-heading"> <h2>Traveler</h2></span>

	<div class="control-group">
		<label class="control-label" for="userID">Change Traveler</label>
		<div class="controls">
			<select name="userID" id="userID">
			<option value="">SELECT A TRAVELER</option>
			<option value="0">GUEST TRAVELER</option>
			<cfloop query="rc.allTravelers">
				<option value="#rc.allTravelers.User_ID#">#rc.allTravelers.Last_Name#/#rc.allTravelers.First_Name# #rc.allTravelers.Middle_Name#</option>
			</cfloop>
			</select>
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="firstName">First Name</label>
		<div class="controls">
			<input type="text" name="firstName" id="firstName">
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="middleName">Middle Name</label>
		<div class="controls">
			<input type="text" name="middleName" id="middleName">
			<input type="checkbox" name="noMiddleName" value="1">
			No Middle Name
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="lastName">Last Name</label>
		<div class="controls">
			<input type="text" name="lastName" id="lastName">
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="phoneNumber">Business Phone</label>
		<div class="controls">
			<input type="text" name="phoneNumber" id="phoneNumber">
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="wirelessPhone">Wireless Phone</label>
		<div class="controls">
			<input type="text" name="wirelessPhone" id="wirelessPhone">
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="email">Email</label>
		<div class="controls">
			<input type="text" name="email" id="email">
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="ccEmails">CC Email</label>
		<div class="controls">
			<input type="text" name="ccEmails" id="ccEmails">
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="month">Birthday</label>
		<div class="controls">
			<select name="month" id="month" class="input-medium">
			<option value=""></option>
			<cfloop from="1" to="12" index="i">
				<option value="#i#">#MonthAsString(i)#</option>
			</cfloop>
			</select>
			<select name="day" id="day" class="input-small">
			<option value=""></option>
			<cfloop from="1" to="31" index="i">
				<option value="#i#">#i#</option>
			</cfloop>
			</select>
			<select name="year" id="year" class="input-small">
			<option value=""></option>
			<cfloop from="#Year(Now())#" to="#Year(Now())-100#" step="-1" index="i">
				<option value="#i#">#i#</option>
			</cfloop>
			</select>
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="gender">Gender</label>
		<div class="controls">
			<select name="gender" id="gender">
			<option value=""></option>
			<option value="M">Male</option>
			<option value="F">Female</option>
			</select>
		</div>
	</div>

	<div id="orgUnits"> </div>

</cfoutput>