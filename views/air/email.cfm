<cfsavecontent variable="jsheader">
	<script src="assets/js/jquery.validate.min.js"></script>
</cfsavecontent>
<cfhtmlhead text="#jsheader#" />

<style>
	label.error {
		color: #CC3300;
		font-size: small;
	}

	.form-horizontal .control-group {
    margin-bottom: 5px;
	}
</style>

<script type="text/javascript">
// details popup email form validation
$(document).ready(function(){
	$('#emailitinerary').validate(
	{
	rules: {
		Email_Name: {
			minlength: 2,
			required: true
		},
		To_Address: {
			required: true,
			email: true
		},
		subject: {
			minlength: 2,
			required: true
		},
		message: {
			minlength: 2,
			required: true
		}
	},
	highlight: function(element) {
		$(element).closest('.control-group').removeClass('success').addClass('error');
	},
	success: function(element) {
		$(element).closest('.control-group').removeClass('error').addClass('success');
		}
	});
});
</script>


<div id="emailcontent">
	<cfoutput>
	<strong>We will email this itinerary to you. Please note, this itinerary is not confirmed.</strong>
	<p>Rates and availability are subject to change until booked.  You will need to return to the website and perform your search again when you are ready to book.</p>

	<form id="emailitinerary" action="#buildURL('air.email?SearchID=#rc.SearchID#&nTripID=#rc.nTripID#&Group=#rc.Group#')#" method="post" class="form-horizontal">
		<input type="hidden" name="bSubmit" value="1">
		<div class="control-group">
			<label class="control-label" for="Email_Name">Your name *</label>
			<div class="controls">
				<input type="text" id="Email_Name" name="Email_Name" placeholder="Your name" value="#rc.qUser.First_Name# #rc.qUser.Last_Name#">
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="Email_Address">Your email</label>
			<div class="controls">
				<input type="text" id="Email_Address" name="Email_Address" placeholder="Your email" value="#rc.qUser.Email#" class="uneditable-input">
				<span class="help-inline"><small>Your email is pulled from our system and cannot be changed.</small></span>
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="To_Address">To email *</label>
			<div class="controls">
				<input type="text" id="To_Address" name="To_Address" placeholder="To email" value="#rc.qProfile.Email#">
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="CC_Address">CC email</label>
			<div class="controls">
				<input type="text" id="CC_Address" placeholder="CC email" value="#rc.qProfile.Email#">
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="Email_Subject">Subject</label>
			<div class="controls">
				<input type="text" id="Email_Subject" placeholder="Email subject" value="Tentative itinerary for #rc.qProfile.First_Name# #rc.qProfile.Last_Name# departing TBD" class="input-xxlarge">
			</div>
		</div>
		<div class="control-group">
			<label class="control-label" for="Email_Message">Message</label>
			<div class="controls">
				<textarea rows="2" id="Email_Message" placeholder="Your message" class="input-xxlarge"></textarea>
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