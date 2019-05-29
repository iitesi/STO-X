<cfoutput>

	<div class="row">
		<h2 class="col s12">TRAVELER <cfif arrayLen(session.searches[rc.searchID].Travelers) GT 1>###rc.travelerNumber#</cfif></h2>
	</div>
	<script>
		let travelersResults = {COLUMNS:[],DATA:[]};
		try {	
			travelersResults = <cfoutput>#serializeJSON(rc.allTravelers)#</cfoutput>;	
		}
		catch(e){
			if(console){
				console.log("Failed to create travelersResults object from query");
				console.log(e);
			}
		}
		$(function(){
			$("##traveler-control").travelersAutocomplete({
				elementName: 'userID',
				query:travelersResults,
				userId:'',
				accountId:'#StructKeyExists(rc,'acctid') ? rc.acctid : ""#',
				queryLimit:0
			});
		});
	</script>

	<div class="mb0 row #(structKeyExists(rc.errors, 'phoneNumber') ? 'error' : '')#" id="userIDDiv">
		<div class="input-field with-icon col s12" id="traveler-control">
			<a rel="popleft" class="fa fa-lg fa-info-circle" data-original-title="Traveler Name Change" data-content="If you need to change your name, please return to the travel portal under the profile section and make the appropriate changes. You will then need to create a new booking. If you are booking on behalf of someone else please click on your company logo, and select 'Book on behalf of another traveler' then select the traveler from the drop down menu, before you check for flight options." href="javascript:void(0);"></a>
			<label for="userID">Change Traveler</label>
		</div>
	</div>

	<div id="fullNameDiv" class=" #(structKeyExists(rc.errors, 'fullName') ? 'error' : '')#">
		<div class="row mb0">
			<div class="input-field col s12">
				<input type="text" name="firstName" id="firstName">
				<label for="firstName">First Name *</label>
			</div>
		</div>
		<div class="row mb0">
			<div class="input-field col s8">
				<input type="text" name="middleName" id="middleName">
				<label for="middleName">Middle Name</label>
			</div>
			<div class="input-field col s4">
				<label for="noMiddleName">
					<input type="checkbox" class="filled-in" name="noMiddleName" id="noMiddleName" value="1">
					<span class="noMiddleNameLabel">No Middle Name</span>
				</label>
			</div>
		</div>
		<div class="row mb0">
			<div class="input-field col s12">
				<input type="text" name="lastName" id="lastName">
				<label for="lastName">Last Name *</label>
			</div>
		</div>
		<div class="row mb0">
			<div class="input-field col s12">
				<select name="suffix" id="suffix">
					<option value="" disabled selected>Choose an option</option>
					<option value="JR">JR</option>
					<option value="SR">SR</option>
					<option value="II">II</option>
					<option value="III">III</option>
					<option value="IV">IV</option>
					<option value="V">V</option>
					<option value="VI">VI</option>
					<option value="F">Female</option>
				</select>
				<label for="suffix">Suffix</label>
			</div>
		</div>
	</div>

	<div id="nameCheckDiv" class="form-group hide">
		<div class="controls blue bold">
			<a rel="popover" class="blue fa fa-lg fa-info-cicrl" data-original-title="Name Verification" data-content="We have detected a space in your first name and a blank middle name. Your middle name may be appearing as part of your first name. Please update your first and/or middle names, as needed, and check 'Save changes to profile' before confirming your purchase." href="javascript:void(0);"></a> <span style="color:red">Please check your name!</span>
		</div>
	</div>

	<div class="row mb0 #(structKeyExists(rc.errors, 'phoneNumber') ? 'error' : '')#">
		<div class="input-field col s12">
			<input type="tel" name="phoneNumber" id="phoneNumber" class="validate">
			<label for="phoneNumber">Business Phone *</label>
		</div>
	</div>

	<div class="row mb0 #(structKeyExists(rc.errors, 'wirelessPhone') ? 'error' : '')#">
		<div class="input-field col s12">
			<input type="tel" name="wirelessPhone" id="wirelessPhone" class="validate">
			<label for="wirelessPhone">Mobile Phone *</label>
		</div>
	</div>

	<div class="row mb0 #(structKeyExists(rc.errors, 'email') ? 'error' : '')#">
		<div class="input-field with-icon col s12">
			<input type="email" class="form-control email-vo validate" name="email" id="email" style="display:none;"/>
			<i class="material-icons mask-icon email-vo" style="display:none" title="Hide"
				onclick="$('.email-v').show();$('.email-vo').hide();">visibility_off</i>
			<input type="email" class="form-control email-v" value="**********" readonly/>
			<i class="material-icons mask-icon email-v" title="Show"
				onclick="$('.email-vo').show();$('.email-v').hide();">visibility</i>
			<label for="email">Email *</label>
		</div>
	</div>

	<div class="row mb0 #(structKeyExists(rc.errors, 'ccEmails') ? 'error' : '')#">
		<div class="input-field with-icon col s12">
			<input type="email" class="form-control ccEmails-vo validate" name="ccEmails" id="ccEmails" style="display:none;"/>
			<i class="material-icons mask-icon ccEmails-vo" style="display:none" title="Hide"
				onclick="$('.ccEmails-v').show();$('.ccEmails-vo').hide();">visibility_off</i>
			<input type="email" class="form-control ccEmails-v" value="**********" readonly/>
			<i class="material-icons mask-icon ccEmails-v" title="Show"
				onclick="$('.ccEmails-vo').show();$('.ccEmails-v').hide();">visibility</i>
			<label for="ccEmails">CC Email</label>
		</div>
	</div>

	<cfif rc.airSelected OR rc.vehicleSelected>
		<div class="row mb0 #(structKeyExists(rc.errors, 'birthdate') ? 'error' : '')#">
			<div class="input-field with-icon col s12 controls dob-v">
				<label for="dob_mask">Birth Date *</label>
				<input type="text" name="dob_mask" id="dob_mask" value="**/**/****" readonly/>
				<i class="material-icons mask-icon dob-v" title="Show"
					onclick="$('.dob-vo').show();$('.dob-v').hide();">visibility</i>
			</div>
			<div class="controls dob-vo" style="display:none;">
				<div class="input-field col s5">
					<select name="month" id="month">
					<option value="" disabled selected>Select</option>
					<cfloop from="1" to="12" index="i">
						<option value="#i#">#MonthAsString(i)#</option>
					</cfloop>
					</select>
					<label for="month">Month *</label>
				</div>
				<div class="input-field col s3">
					<select name="day" id="day">
						<option value="" disabled selected>Select</option>
						<cfloop from="1" to="31" index="i">
							<option value="#i#">#i#</option>
						</cfloop>
					</select>
					<label for="day">Day *</label>
				</div>
				<div class="input-field col s4">
					<select name="year" id="year">
						<option value="" disabled selected>Select</option>
						<cfloop from="#Year(Now())#" to="#Year(Now())-100#" step="-1" index="i">
							<option value="#i#">#i#</option>
						</cfloop>
					</select>
					<label for="year">Year *</label>
				</div>
				<div class="input-field">
					<i class="material-icons mask-icon dob-vo" title="Hide"
						onclick="$('.dob-v').show();$('.dob-vo').hide();">visibility_off</i>
				</div>
			</div>
		</div>
	</cfif>
	
	<cfif rc.airSelected>
		<div class="row mb0 #(structKeyExists(rc.errors, 'gender') ? 'error' : '')#">
			<div class="input-field col s12">
				<select name="gender" id="gender">
					<option value="" disabled>Choose an option</option>
					<option value="M">Male</option>
					<option value="F">Female</option>
				</select>
				<label for="gender">Gender *</label>
			</div>
		</div>
	</cfif>

	<cfif rc.airSelected>
		<div class="row mb0">
			<div class="input-field with-icon col s12">
				<input type="text" name="redress" id="redress">
				<label for="redress">Traveler Redress ##</label>
				<a rel="popleft" class="fa fa-lg fa-info-circle" data-original-title="Redress Number" data-content="A redress number is a unique number issued by the Transportation Security Administration (TSA) to passengers who have experienced secondary security screenings at airports because they have names similar to or the same as names on the current terrorist watch list. If you have been given a redress number by the TSA, you are required to enter it on this page." href="javascript:void(0);"></a>
			</div>
		</div>

		<div class="row mb0 #(structKeyExists(rc.errors, 'travelNumber') ? 'error' : '')#">
			<div class="input-field with-icon col s12 mb0">
				<input type="hidden" name="travelNumberType" id="travelNumberType" value="TrustedTraveler">
				<input type="text" name="travelNumber" id="travelNumber">
				<label for="travelNumber">Known Traveler ##</label>
				<a rel="popleft" class="fa fa-lg fa-info-circle" data-original-title="Known Traveler" data-content="A Known Traveler Number is a unique number issued by the U.S. Government to uniquely identify passengers who participate in a known traveler program (e.g. Global Entry, SENTRI, NEXUS). For more information, visit <a href='http://www.tsa.gov/tsa-precheck/participation-tsa-precheck' target='_blank'>http://www.tsa.gov/tsa-precheck/participation-tsa-precheck</a>." href="javascript:void(0);"></a>
			</div>
			<cfif len(rc.KTLinks)>
				<div class="col s12">#rc.KTLinks#</div>
			</cfif>
		</div>
	</cfif>

	<div id="orgUnits" class="row mb0"></div>

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
			<div class="form-group #(structKeyExists(rc.errors, 'travelServices') ? 'error' : '')#">
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

	<div class="row" id="saveProfileDiv">
		<div class="input-field col s12">
			<label for="saveProfile">
				<input type="checkbox" class="filled-in" name="saveProfile" id="saveProfile" value="1">
				<span>Save Changes To Profile</span>
			</label>
		</div>
	</div>

	<div class="row" id="createProfileDiv">
		<div class="input-field col s12">
			<label for="createProfile">
				<input type="checkbox" class="filled-in" name="createProfile" id="createProfile" value="1">
				<span>Create a profile and save this information for my next reservation</span>
			</label>
		</div>
	</div>

	<div class="row" id="usernameDiv">
		<div class="input-field col s12 mb0 new-profile-notes">
			NOTE: Click "Create Profile" to save a profile regardless of whether the reservation is purchased.
		</div>
		<div class="input-field col s12">
			<input type="hidden" name="username" id="username">
			<input type="text" name="username_disabled" id="username_disabled" disabled />
			<label for="username_disabled">Username</label>
		</div>

		<div class="input-field with-icon col s12 #(structKeyExists(rc.errors, 'password') ? 'error' : '')#">
			<input type="password" name="password" id="password" />
			<a rel="popleft" class="fa fa-lg fa-info-cicle" data-original-title="Password Requirements" data-content="<ul><li>Must be a minimum of 8 characters</li><li>Must contain three of the four items below:</li><li style='list-style-type:none;'><ul><li>Upper case letter</li><li>Lower case letter</li><li>Number</li><li>Special character</li></ul></li></ul>" href="javascript:void(0);"></a>
			<label for="password">Password</label>
		</div>

		<div class="input-field col s12 #(structKeyExists(rc.errors, 'passwordConfirm') ? 'error' : '')#">
			<input type="password" name="passwordConfirm" id="passwordConfirm" />
			<label for="passwordConfirm">Verify Password</label>
		</div>
		
		<div class="input-field col s12">
			<button class="btn waves-effect waves-light" id="profileButton" type="submit" name="trigger">Create Profile</button>
		</div>
	</div>

    <!--- <cfif rc.airSelected
        AND rc.Filter.getAirType() EQ 'RT'
        AND rc.Policy.Policy_HotelNotBooking EQ 1
		AND NOT rc.hotelSelected> --->
	<cfset overnightStay = false />
	<!--- If NASCAR --->
	<cfif rc.acctID EQ 348>
		<cfif (rc.airSelected
				AND isDate(rc.Filter.getArrivalDateTime())
				AND dateDiff('d', rc.Filter.getDepartDateTime(), rc.Filter.getArrivalDateTime()) GTE 1)
			OR (rc.vehicleSelected
				AND dateDiff('d', rc.Filter.getCarPickUpDateTime(), rc.Filter.getCarDropOffDateTime()) GTE 1)>
			<cfset overnightStay = true />
		</cfif>
	<cfelseif rc.airSelected
		AND rc.Filter.getAirType() EQ 'RT'
		AND rc.Policy.Policy_HotelNotBooking EQ 1>
		<cfset overnightStay = true />
	</cfif>

	<cfif overnightStay AND NOT rc.hotelSelected>
		<div class="form-group #(structKeyExists(rc.errors, 'hotelNotBooked') ? 'error' : '')#">
			<label class="control-label col-sm-4 col-xs-12" for="hotelNotBooked">Reason for not booking a hotel *&nbsp;&nbsp;</label>
			<div class="controls col-sm-8 col-xs-12">
				<select class="form-control" name="hotelNotBooked" id="hotelNotBooked">
					<option value=""></option>
					<!--- If not NASCAR (348) and not C1 (581), display the reasons that have always been displayed --->
					<cfif rc.acctID NEQ 348
						AND rc.acctID NEQ 581>
						<option value="A">I will book my hotel later</option>
						<option value="B">I am attending a conference with pre-arranged hotel</option>
						<option value="C">I have a negotiated rate that is not available online</option>
						<option value="D">I have a preferred hotel that is not available online</option>
						<option value="E">I will shop around at other websites</option>
						<option value="F">I will be staying with family/friends</option>
						<option value="G">I do not need a hotel for this trip </option>
					<cfelseif rc.acctID EQ 581>
						<option value="NHA">I will book my hotel later</option>
				        <option value="NHB">Attending Conference with pre-arranged hotel</option>
				        <option value="NHC">Negotiated rate was not available</option>
				        <option value="NHD">Preferred hotel not available online</option>
				        <option value="NHE">Will shop on other websites</option>
				        <option value="NHF">Staying with family/friends</option>
				        <option value="NHG">No hotel needed for trip</option>
					<!--- If NASCAR, display the new reasons for NASCAR --->
					<cfelseif rc.acctID EQ 348>
						<option value="H">Staying in a pre-arranged room block</option>
						<option value="I">Reservation already made</option>
						<option value="J">Staying with family/friends (business travel)</option>
						<option value="K">Leisure (non-business travel)</option>
					</cfif>
				</select>
			</div>
		</div>
		<!--- If NASCAR --->
		<cfif rc.acctID EQ 348>
			<div id="hotelWhereStayingDiv" class="control-group#(structKeyExists(rc.errors, 'hotelWhereStaying') ? ' error' : '')#">
				<label class="control-label col-sm-4 col-xs-12" for="hotelWhereStaying">Where will you be staying? *</label>
				<div class="controls col-sm-8 col-xs-12">
					<input type="text" name="hotelWhereStaying" id="hotelWhereStaying" maxlength="60" />
				</div>
			</div>
		</cfif>
	</cfif>
</cfoutput>