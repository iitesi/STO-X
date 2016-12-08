<cfsilent>
	<cfparam name="rc.bSelection" default="0">
	<cfparam name="rc.details" default="details">
</cfsilent>

<!--- 3:43 PM Monday, July 15, 2013 - Jim Priest - jpriest@shortstravel.com
active tabs from link are not included with bootstrap :\
alternatives are to check url and set active (as I did below)
or use js which has issues - see: https://github.com/twitter/bootstrap/issues/2415 --->

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
		Email_Subject: {
			minlength: 2,
			required: true
		},
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

<cfoutput>
	<cfif rc.bSelection EQ 0>
    <ul class="nav nav-tabs">
	    <li <cfif rc.sDetails EQ 'details'>class="active"</cfif>><a href="##tab-details" data-toggle="tab" title="View details">Info</a></li>
	    <li <cfif rc.sDetails EQ 'seatmap'>class="active"</cfif>><a href="##tab-seatmap" data-toggle="tab" title="View seat map">Seats</a></li>
	    <li <cfif rc.sDetails EQ 'baggage'>class="active"</cfif>><a href="##tab-baggage" data-toggle="tab" title="View baggage fees">Bags</a></li>
	    <li <cfif rc.sDetails EQ 'email'>class="active"</cfif>><a href="##tab-email" data-toggle="tab" title="Email this intinerary">Email</a></li>
    </ul>
		<div class="tab-content">
			<div class="tab-pane <cfif rc.sDetails EQ 'details'>active</cfif>" id="tab-details">#view('air/details')#</div>
			<div class="tab-pane <cfif rc.sDetails EQ 'seatmap'>active</cfif>" id="tab-seatmap">#view('air/seatmap')# </div>
			<div class="tab-pane <cfif rc.sDetails EQ 'baggage'>active</cfif>" id="tab-baggage">#view('air/baggage')# </div>
			<div class="tab-pane <cfif rc.sDetails EQ 'email'>active</cfif>" id="tab-email">#view('air/email')# </div>
		</div>
	</cfif>
</cfoutput>