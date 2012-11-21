<cfif cgi.SCRIPT_NAME DOES NOT CONTAIN '.cfc'>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<title>STO .:. The New Generation of Corporate Online Booking</title>
	<cfif NOT structKeyExists(rc, "bSuppress")>
		<link 	rel="stylesheet" href="assets/css/reset.css" media="screen" />
		<link 	rel="stylesheet" href="http://fonts.googleapis.com/css?family=Capriola|Karla|Chivo" type="text/css">
		<link 	rel="stylesheet" href="assets/css/style.css" media="screen" />
		<link 	rel="stylesheet" href="assets/css/custom-theme/jquery-ui-1.8.23.custom.css">
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script>
		<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.23/jquery-ui.min.js"></script>
		<script src="assets/js/jqModal.js"></script>
		<script src="assets/js/booking.js"></script>
	</cfif>
</head>
<style>

#wrapper {
	width: 100%;
	min-width: 1000px;
}


/* Header
-----------------------------------------------------------------------------*/



/* Footer
-----------------------------------------------------------------------------*/

</style>
<body>
	<cfif NOT structKeyExists(rc, "bSuppress")>
		
		<div id="wrapper">

			<div id="header">
				<cfoutput>#View('main/tabs')#</cfoutput>
			</div><!-- #header-->

			<div id="content">
				<cfoutput>#body#</cfoutput>
			</div><!-- #content-->

			<br clear="both">
			<div id="footer">
				Short's Travel Management <cfoutput>#Year(Now())#</cfoutput>
			</div><!-- #footer -->

		</div><!-- #wrapper -->
		
	<cfelse>
		<p><cfoutput>#body#</cfoutput></p>
	</cfif>

	<div class="overlayWrapper" id="overlay">
		<a href="#" class="overlayClose">close</a>
		<div id="overlayContent">Please wait...</div>
	</div>
	
</body>

</html>
</cfif>