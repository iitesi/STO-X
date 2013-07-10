<cfoutput>
	<span class="underline-heading"> <h2>Traveler</h2></span>

	<div class="control-group">
		<label class="control-label" for="userID">Change Traveler</label>
		<div class="controls">
			<select name="userID" id="userID" class="input-xlarge">
			<option value="">SELECT A TRAVELER</option>
			<option value="0">GUEST TRAVELER</option>
			<cfloop query="rc.allTravelers">
				<option value="#rc.allTravelers.User_ID#">#rc.allTravelers.Last_Name#/#rc.allTravelers.First_Name# #rc.allTravelers.Middle_Name#</option>
			</cfloop>
			</select>
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="firstName">Full Name</label>
		<div class="controls">
			<input type="text" name="firstName" id="firstName" placeholder="First" class="input-medium">
			<input type="text" name="middleName" id="middleName" placeholder="Middle" class="input-medium">
			<input type="text" name="lastName" id="lastName" placeholder="Last" class="input-medium">
			<br>
			<input type="checkbox" name="noMiddleName" value="1">
			<span class="help-inline">No Middle Name</span>
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="phoneNumber">Business Phone</label>
		<div class="controls">
			<input type="text" name="phoneNumber" id="phoneNumber" class="input-medium">
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="wirelessPhone">Wireless Phone</label>
		<div class="controls">
			<input type="text" name="wirelessPhone" id="wirelessPhone" class="input-medium">
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