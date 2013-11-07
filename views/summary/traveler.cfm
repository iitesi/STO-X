<cfoutput>

	<h2>TRAVELER <cfif arrayLen(session.searches[rc.searchID].Travelers) GT 1>###rc.travelerNumber#</cfif></h2>

	<div class="control-group" id="userIDDiv">
		<label class="control-label" for="userID">Change Traveler&nbsp;&nbsp;</label>		
		<div class="controls">
			<select name="userID" id="userID" class="input-xlarge">
			<option value="0">GUEST TRAVELER</option>
			<cfloop query="rc.allTravelers">
				<option value="#rc.allTravelers.User_ID#">#rc.allTravelers.Last_Name#/#rc.allTravelers.First_Name# #rc.allTravelers.Middle_Name#</option>
			</cfloop>
			</select>
			<a rel="popover" class="blue icon-large icon-info-sign" data-original-title="Traveler Name Change" data-content="If you need to change your name, please return to the travel portal under the profile section and make the appropriate changes. You will then need to create a new booking. If you are booking on behalf of someone else please click on your company logo, and select 'Book on behalf of another traveler' then select the traveler from the drop down menu, before you check for flight options." href="##"></a>
		</div>
	</div>

	<div id="fullNameDiv" class="control-group #(structKeyExists(rc.errors, 'fullName') ? 'error' : '')#">
		<label class="control-label" for="firstName">Full Name *</label>
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

	<div class="control-group #(structKeyExists(rc.errors, 'phoneNumber') ? 'error' : '')#">
		<label class="control-label" for="phoneNumber">Business Phone *</label>
		<div class="controls">
			<input type="text" name="phoneNumber" id="phoneNumber" class="input-medium">
		</div>
	</div>

	<div class="control-group #(structKeyExists(rc.errors, 'wirelessPhone') ? 'error' : '')#">
		<label class="control-label" for="wirelessPhone">Mobile Phone *</label>
		<div class="controls">
			<input type="text" name="wirelessPhone" id="wirelessPhone" class="input-medium">
		</div>
	</div>

	<div class="control-group #(structKeyExists(rc.errors, 'email') ? 'error' : '')#">
		<label class="control-label" for="email">Email *</label>
		<div class="controls">
			<input type="text" name="email" id="email">
		</div>
	</div>

	<div class="control-group #(structKeyExists(rc.errors, 'ccEmails') ? 'error' : '')#">
		<label class="control-label" for="ccEmails">CC Email&nbsp;&nbsp;</label>
		<div class="controls">
			<input type="text" name="ccEmails" id="ccEmails">
		</div>
	</div>

	<div class="control-group #(structKeyExists(rc.errors, 'birthdate') ? 'error' : '')#">
		<label class="control-label" for="month">Birth Date *</label>
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

	<div class="control-group #(structKeyExists(rc.errors, 'gender') ? 'error' : '')#">
		<label class="control-label" for="gender">Gender *</label>
		<div class="controls">
			<select name="gender" id="gender">
			<option value=""></option>
			<option value="M">Male</option>
			<option value="F">Female</option>
			</select>
		</div>
	</div>

	<div id="orgUnits"> </div>

	<cfif rc.travelerNumber EQ 1>
		
		<input type="hidden" name="airNeeded" id="airNeeded" value="#(rc.airSelected ? 1 : 0)#">
		<input type="hidden" name="hotelNeeded" id="hotelNeeded" value="#(rc.hotelSelected ? 1 : 0)#">
		<input type="hidden" name="carNeeded" id="carNeeded" value="#(rc.vehicleSelected ? 1 : 0)#">

	<cfelse>

		<cfset travelServices = 0>
		<cfif rc.airSelected>
			<cfset travelServices++>
		</cfif>
		<cfif rc.hotelSelected>
			<cfset travelServices++>
		</cfif>
		<cfif rc.vehicleSelected>
			<cfset travelServices++>
		</cfif>
		<cfif travelServices GT 1>
			<div class="control-group #(structKeyExists(rc.errors, 'travelServices') ? 'error' : '')#">
				<label class="control-label" for="airNeeded">Travel Services For Traveler ###rc.travelerNumber#? *</label>
				<div class="controls">
				<cfif rc.airSelected>
					<label class="airNeeded">
						<input type="checkbox" name="airNeeded" id="airNeeded" value="1">
						Include Flights
					</label>
				<cfelse>
					<input type="hidden" name="airNeeded" id="airNeeded" value="0">
				</cfif>
				<cfif rc.hotelSelected>
					<label class="hotelNeeded">
						<input type="checkbox" name="hotelNeeded" id="hotelNeeded" value="1">
						Include Hotel
					</label>
				<cfelse>
					<input type="hidden" name="hotelNeeded" id="hotelNeeded" value="0">
				</cfif>
				<cfif rc.vehicleSelected>
					<label class="carNeeded">
						<input type="checkbox" name="carNeeded" id="carNeeded" value="1">
						Include Car
					</label>
				<cfelse>
					<input type="hidden" name="carNeeded" id="carNeeded" value="0">
				</cfif>
				</div>
			</div>
		<cfelse>
			<input type="hidden" name="airNeeded" id="airNeeded" value="#(rc.airSelected ? 1 : 0)#">
			<input type="hidden" name="hotelNeeded" id="hotelNeeded" value="#(rc.hotelSelected ? 1 : 0)#">
			<input type="hidden" name="carNeeded" id="carNeeded" value="#(rc.vehicleSelected ? 1 : 0)#">
		</cfif>

	</cfif>

	<div class="control-group" id="saveProfileDiv">
		<label class="control-label" for="saveProfile"></label>
		<div class="controls">
			<label class="saveProfile">
				<input type="checkbox" name="saveProfile" id="saveProfile" value="1">
				Save changes to profile
			</label>
		</div>
	</div>

	<div class="control-group" id="createProfileDiv">
		<label class="control-label" for="createProfile"></label>
		<div class="controls">
			<label class="createProfile">
				<input type="checkbox" name="createProfile" id="createProfile" value="1" />
				Create a profile and save this information for my next reservation
			</label>
		</div>
	</div>

	<div class="control-group" id="usernameDiv">
		<div class="control-group">
			<p><b>NOTE: Click "Create Profile" to save a profile regardless of whether the reservation is purchased.</b></p>
			<label class="control-label" for="username">Username</label>
			<div class="controls">
				<input type="text" name="username_disabled" id="username_disabled" disabled />
				<input type="hidden" name="username" id="username" />
			</div>
		</div>

		<div class="control-group #(structKeyExists(rc.errors, 'password') ? 'error' : '')#">
			<label class="control-label" for="password">Password</label>
			<div class="controls">
				<input type="password" name="password" id="password" />
				<a rel="popover" class="blue icon-large icon-info-sign" data-original-title="Password Requirements" data-content="<ul><li>Must be a minimum of 8 characters</li><li>Must contain three of the four items below:</li><li style='list-style-type:none;'><ul><li>Upper case letter</li><li>Lower case letter</li><li>Number</li><li>Special character</li></ul></li></ul>" href="##"></a>
			</div>
		</div>

		<div class="control-group #(structKeyExists(rc.errors, 'passwordConfirm') ? 'error' : '')#">
			<label class="control-label" for="passwordConfirm">Verify Password</label>
			<div class="controls">
				<input type="password" name="passwordConfirm" id="passwordConfirm" />
			</div>
		</div>

		<div class="control-group">
			<div class="controls">
				<input type="submit" name="trigger" id="profileButton" class="btn btn-primary" value="CREATE PROFILE">
			</div>
		</div>
	</div>

	<cfif rc.airSelected
		AND rc.Filter.getAirType() EQ 'RT'
		AND rc.Policy.Policy_HotelNotBooking EQ 1
		AND NOT rc.hotelSelected>
		<div class="control-group #(structKeyExists(rc.errors, 'hotelNotBooked') ? 'error' : '')#">
			<label class="control-label" for="hotelNotBooked">Reason for not booking a hotel *&nbsp;&nbsp;</label>
			<div class="controls">
				<select name="hotelNotBooked" id="hotelNotBooked">
				<option value=""></option>
				<option value="A">I will book my hotel later</option>
				<option value="B">I am attending a conference with pre-arranged hotel</option>
				<option value="C">I have a negotiated rate that is not available online</option>
				<option value="D">I have a preferred hotel that is not available online</option>
				<option value="E">I will shop around at other websites</option>
				<option value="F">I will be staying with family/friends</option>
				<option value="G">I do not need a hotel for this trip </option>
				</select>
			</div>
		</div>
	</cfif>
					
</cfoutput>