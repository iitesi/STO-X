<cfif cgi.SCRIPT_NAME DOES NOT CONTAIN '.cfc'>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<title>STO .:. The New Generation of Corporate Online Booking</title>
	<cfif NOT structKeyExists(rc, "bSuppress")>
		<link href="assets/css/reset.css" rel="stylesheet" media="screen" />
		<link href="assets/css/style.css" rel="stylesheet" media="screen" />
		<link href="assets/css/smoothness/jquery-ui-1.9.2.custom.css" rel="stylesheet" >
		<link href='http://fonts.googleapis.com/css?family=Bree+Serif' rel='stylesheet' type='text/css'>
		<!--- <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.0/themes/pepper-grinder/jquery-ui.css" rel="stylesheet" > --->
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
		<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>
		<script src="assets/js/jqModal.js"></script>
		<script src="assets/js/booking.js"></script>
	</cfif>
</head>
<body>
	<cfif NOT structKeyExists(rc, "bSuppress")>
		
		<div id="wrapper">
			<div class="headerbar">
				<div id="header-wrap">
					<div class="header">
						<div class="clearfix nav">
							<cfoutput>#View('main/tabs')#</cfoutput>
						</div>
						<div class="clearfix login-tab">
						<div class="clearDiv"></div>
					</div>
				</div>
			</div>
		
				<a href="http://www.ithelpdesksoftware.com/">
					<img class="logo" src="https://www.shortstravel.com/TravelPortalV2/Images/Clients/STO-Logo.gif" style="background-color:##FFFFFF">
				</a>
		<br><br>	
			<!--- <div id="header">
				<cfparam name="rc.filter" default="">
				<ul id="nav">
					<li style="float:right;position:absolute;padding:0;">
						<a href="#" class="main"></a>
						<ul>
							<cfoutput>
								<li><a href="#buildURL('air.lowfare?Search_ID=#rc.nSearchID#&bReloadAir=1')#">Reload Air</a></li>
								<li><a href="#buildURL('main.logs?Search_ID=#rc.nSearchID#')#" target="_blank">View Logs</a></li>
							</cfoutput>
						</ul>
					</li>
				</ul>
				<cfoutput>#View('main/tabs')#</cfoutput>
			</div><!-- #header--> --->

			<div id="content">
				<cfoutput>#body#</cfoutput>
		
				<div class="overlayWrapper" id="overlay">
					<a href="#" class="overlayClose">close</a>
					<div id="overlayContent">Please wait...</div>
				</div>
			
			</div><!-- #content-->

			<br clear="both">
			<div id="footer">
				Short's Travel Management <cfoutput>#Year(Now())#</cfoutput>
			</div><!-- #footer -->
		</div><!-- #wrapper -->

	<cfelse>
		<p><cfoutput>#body#</cfoutput></p>
	</cfif>
	
</body>

</html>
</cfif>