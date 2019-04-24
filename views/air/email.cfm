<div id="emailcontent">
	<cfoutput>
	<strong>We will email this itinerary to you. Please note, this itinerary is not confirmed.</strong>
	<p>Rates and availability are subject to change until booked.  You will need to return to the website and perform your search again when you are ready to book.</p>
	<form id="emailitinerary" action="#buildURL('air.email?SearchID=#rc.SearchID#&Group=#rc.Group#')#" method="post" class="form-horizontal">
		<input type="hidden" name="SendEmail" value="1">
		<input type="text" id="Email_Segment" name="Email_Segment" value="">
		<div class="control-group">
			<label class="control-label" for="Email_Name">Your name *</label>
			<div class="controls">
				<input type="text" id="Email_Name" name="Email_Name" placeholder="Your name" value="#rc.User.First_Name# #rc.User.Last_Name#">
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="Email_Address">Your email</label>
			<div class="controls">
				<input type="text" readonly id="Email_Address" name="Email_Address" placeholder="Your email" value="#rc.User.Email#" <cfif isValid('email', rc.User.Email)>class="uneditable-input"</cfif>>
				<cfif isValid('email', rc.User.Email)>
					<span class="help-inline"><small>Your email is pulled from our system and cannot be changed.</small></span>
				</cfif>
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="Email_To">To email *</label>
			<div class="controls">
				<input type="text" id="Email_To" name="Email_To" placeholder="To email" value="#rc.Profile.Email#">
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="Email_CC">CC email </label>
			<div class="controls">
				<input type="text" id="Email_CC" name="Email_CC" placeholder="To email">
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="Email_Subject">Subject *</label>
			<div class="controls">
				<input type="text" id="Email_Subject" name="Email_Subject" placeholder="Email subject" value="Tentative itinerary <cfif rc.Profile.First_Name NEQ ''>for #rc.Profile.First_Name# #rc.Profile.Last_Name#</cfif>" class="input-xxlarge">
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="Email_Message">Message</label>
			<div class="controls">
				<textarea rows="2" id="Email_Message" name="Email_Message" placeholder="Your message" class="input-xxlarge"></textarea>
			</div>
		</div>
		<div class="control-group">
			<div class="controls">
				<button type="submit" class="btn btn-primary">Send Email</button>
			</div>
		</div>
	</form>
	</cfoutput>
</div>
