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
			<span rel="tooltip" id="travelerTooltip" class="blue icon-large icon-info-sign" title="If you need to change your name, please return to the travel portal under the profile section and make the appropriate changes. You will then need to create a new booking. If you are booking on behalf of someone else please click on your company logo, and select 'Book on behalf of another traveler' then select the traveler from the drop down menu, before you check for flight options."></span>
		</div>
	</div>
	
	<div class="control-group" id="fullNameDiv">
		<label class="control-label" for="firstName">Full Name</label>
		<span class="icon-info-sign"/>
		<div class="controls">
			<input type="text" name="firstName" id="firstName" placeholder="First Name" class="input-small">
			<input type="text" name="middleName" id="middleName" placeholder="Middle Name" class="input-small">
			<input type="text" name="lastName" id="lastName" placeholder="Last Name" class="input-small">
			<input type="hidden" name="firstName" id="firstName2">
			<input type="hidden" name="lastName" id="lastName2">
			<br>
			<label class="checkbox">
				<input type="checkbox" name="noMiddleName" id="noMiddleName" value="1">
				No Middle Name
			</label>
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="phoneNumber">Business Phone</label>
		<div class="controls">
			<input type="text" name="phoneNumber" id="phoneNumber" class="input-medium">
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="wirelessPhone">Mobile Phone</label>
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
		<label class="control-label" for="month">Birth Date</label>
		<div class="controls">
			<select name="month" id="month" class="input-small">
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