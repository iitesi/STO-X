<cfif cgi.SCRIPT_NAME DOES NOT CONTAIN '.cfc'>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<title>STO .:. The New Generation of Corporate Online Booking</title>
	<link rel="stylesheet" href="assets/css/reset.css" media="screen" />
	<link href='http://fonts.googleapis.com/css?family=Capriola|Karla|Chivo' rel='stylesheet' type='text/css'>
	<link rel="stylesheet" href="assets/css/style.css" media="screen" />
	<link rel="stylesheet" href="assets/css/custom-theme/jquery-ui-1.8.23.custom.css">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js"></script>
	<script src="assets/js/booking.js"></script>
</head>

<body>
	
	<header id="header" class="group">
		<hgroup>
			<cfoutput>#View('main/tabs')#</cfoutput>
		</hgroup>
	</header>
	
	<div id="content">
		<p><cfoutput>#body#</cfoutput></p>
	</div>
	
	<div id="waiting" style="display:none;">
		One moment...
	</div>
	
	<!---<footer role="contentinfo">
		<div class="inner">
			<p id="copyright">Short's Travel Management <cfoutput>#Year(Now())#</cfoutput></p>
		</div>
	</footer>
	
	<cfdump eval=session>--->
	
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js"></script>
			
</body>

</html>
</cfif>