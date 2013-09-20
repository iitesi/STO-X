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
			<div class="header">
				<div class="clearfix nav">
					<cfoutput>#View('main/tabs')#</cfoutput>
				</div>
			</div>

			<img class="logo" src="https://www.shortstravel.com/TravelPortalV2/Images/Clients/STO-Logo.gif">
			
			<br class="clearfix">

			<div id="content">
				<cfoutput>#body#</cfoutput>
		
				<div class="overlayWrapper" id="overlay">
					<a href="#" class="overlayClose">close</a>
					<div id="overlayContent">Please wait...</div>
				</div>
			
			</div>

			<br class="clearfix">

			<div id="footer">
				Short's Travel Management <cfoutput>#Year(Now())#</cfoutput>
			</div>

		</div>

	<cfelse>
		<p><cfoutput>#body#</cfoutput></p>
	</cfif>

	<cfif rc.currentEnvironment = "prod">
		<cfoutput>
			<script type="text/javascript">
				var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
				document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
			</script>
			<script type="text/javascript">
				try {
				var pageTracker = _gat._getTracker("UA-11345476-1");
				pageTracker._setDetectFlash(0);
				pageTracker._setAllowLinker(true);
				pageTracker._setVar("#UCase(session.account.Account_Name)#");
				pageTracker._trackPageview("#rc.action#");
				} catch(err) {}
			</script>
		</cfoutput>
	</cfif>

</body>

</html>
</cfif>