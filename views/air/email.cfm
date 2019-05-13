<div id="emailcontent">
	<cfoutput>
	<strong>We will email this itinerary to you. Please note, this itinerary is not confirmed.</strong>
	<p>Rates and availability are subject to change until booked.  You will need to return to the website and perform your search again when you are ready to book.</p>
	<form id="emailitinerary" action="#buildURL('air.email?SearchID=#rc.SearchID#&Group=#rc.Group#')#" method="post" class="form-horizontal">
		<input type="hidden" name="SendEmail" value="1">
		<input type="hidden" id="Email_Segment" name="Email_Segment" value="">
		<div class="form-field form-field--is-filled">
			<div class="form-field__control">
				<label for="Email_Name" class="form-field__label">Your name *</label>
				<input id="Email_Name" name="Email_Name" type="text" class="form-field__input" value="#rc.User.First_Name# #rc.User.Last_Name#" />
			</div>
		</div>
		<div class="form-field form-field--is-filled">
			<div class="form-field__control">
				<label for="Email_Address" class="form-field__label">Your name *</label>
				<input id="Email_Address" readonly name="Email_Address" type="text" class="form-field__input" value="#rc.User.Email#" />
			</div>
			<cfif isValid('email', rc.User.Email)>
				<span class="help-inline"><small>Your email is pulled from our system and cannot be changed.</small></span>
			</cfif>
		</div>
		<div class="form-field form-field--is-filled">
			<div class="form-field__control">
				<label for="Email_To" class="form-field__label">To email *</label>
				<input id="Email_To" name="Email_To" type="text" class="form-field__input" value="#rc.User.Email#"/>
			</div>
		</div>
		<div class="form-field">
			<div class="form-field__control">
				<label for="Email_CC" class="form-field__label">CC email</label>
				<input id="Email_CC" name="Email_CC" type="text" class="form-field__input" />
			</div>
		</div>
		<div class="form-field">
			<div class="form-field__control <cfif rc.Profile.First_Name NEQ ''>form-field--is-filled</cfif>">
				<label for="Email_Subject" class="form-field__label">Subject *</label>
				<input id="Email_Subject" name="Email_Subject" type="text" class="form-field__input"  value="Tentative itinerary <cfif rc.Profile.First_Name NEQ ''>for #rc.Profile.First_Name# #rc.Profile.Last_Name#</cfif>"/>
			</div>
		</div>
		<div class="form-field">
			<div class="form-field__control">
				<label for="Email_Message" class="form-field__label">Message</label>
				<textarea id="Email_Message" name="Email_Message" class="form-field__textarea"></textarea>
			</div>
		</div>
		<div class="form-field form-field-right">
			<button type="submit" class="btn btn-primary">Send Email</button>
		</div>
	</form>
	</cfoutput>
</div>
