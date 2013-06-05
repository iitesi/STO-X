<cfif cgi.SCRIPT_NAME DOES NOT CONTAIN '.cfc'>
		<!DOCTYPE html>
		<!--[if lt IE 7]> <html class="lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
		<!--[if IE 7]>    <html class="lt-ie9 lt-ie8" lang="en"> <![endif]-->
		<!--[if IE 8]>    <html class="lt-ie9" lang="en"> <![endif]-->
		<!--[if gt IE 8]><!--><html lang="en"><!--<![endif]-->

		<head>
				<meta charset="utf-8">
				<title>STO .:. The New Generation of Corporate Online Booking</title>
				<meta name="viewport" content="width=device-width, initial-scale=1.0">
				<meta name="description" content="">
				<meta name="author" content="">

				<!-- Le Styles -->
				<link href="assets/css/bootstrap.min.css" rel="stylesheet">
				<link href="assets/css/skeleton.css" rel="stylesheet">
				<link href="assets/css/smoothness/jquery-ui-1.9.2.custom.css" rel="stylesheet">
				<link rel="stylesheet" href="assets/css/font-awesome.min.css">
				<!--[if IE 7]>
					<link rel="stylesheet" href="assets/css/font-awesome-ie7.min.css">
				<![endif]-->


				<link href="assets/css/layout.css" rel="stylesheet">
				<link href="assets/css/style.css" rel="stylesheet">

				<!--[if lt IE 9]>
							<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
				<![endif]-->


				<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
				<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>
				<script src="http://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=7.0&mkt=en-us" charset="UTF-8" type="text/javascript"></script>
				<script src="assets/js/jquery.plugins.min.js"></script>
				<script src="assets/js/bootstrap.min.js"></script>
				<script src="assets/js/hotel/hotel.js"></script>
				<script src="assets/js/angular.min.js"></script>
				<script src="assets/js/angular-resource.min.js"></script>
				<script src="assets/js/purl.js"></script>
				<script src="assets/js/hotel/services.js"></script>
				<script src="assets/js/hotel/controllers.js"></script>
				<script src="assets/js/hotel/app.js"></script>
				<script src="assets/js/booking.js"></script><!---Custom--->
		</head>

		<body>
			<div id="main-wrapper" class="wide">

			<header id="main-header">

					<div id="header-top">
							<div class="container">
									<div class="sixteen columns">
										<div id="logo-container">
												<div id="logo-center"><!---logo here--->
												<cfoutput>
												<a href="#application.sPortalURL#" title="Home"><img src="assets/img/stm.gif" alt="Short's Travel Management"></a>
												</cfoutput>
												</div>
										</div>
										<cfoutput>#View('main/navigation')#</cfoutput>
									</div>
							</div>
					</div>

				<cfif (rc.action EQ 'air.lowfare' OR rc.action EQ 'air.availability') AND ArrayLen(StructKeyArray(session.searches)) GTE 1>
					<div id="header-bottom">
							<div class="container">
									<div class="one columns newsearch">
											<!---
											TODO: switch this out to use modal window to call widget STM-652
											10:37 AM Tuesday, June 04, 2013 - Jim Priest - jpriest@shortstravel.com
											--->
											<a href="/search/?acctid=1&userid=3605" class="btn" title="Start a new search"><i class="icon-search"></i></a>
										</div>
									<div class="fifteen columns">
										<cfoutput>#View('air/breadcrumbs')#</cfoutput>
									</div>
							</div>
					</div>
				</cfif>
			</header>

			<section id="main-content">
				<div class="container">
				<cfoutput>#body#</cfoutput>
			</div>
			</section>

			<footer id="footer">

					<div id="footer-top">
							<div class="container">
					<cfoutput>
						#View('main/policy')#
						#View('main/unusedtickets')#
					</cfoutput>
							</div>
					</div>

					<div id="footer-bottom">
							<div class="container">
									<div class="eight columns">
											Copyright Short's Travel Management <cfoutput>#Year(Now())#</cfoutput>. All Rights Reserved.
									</div>
							</div>
					</div>

			</footer>

		</div>

		</body>

		</html>
</cfif>


<!--- CFDUMP: Debugging --->
<cfdump var="#application#" label="Dump ( session )" metainfo="true" abort="true" format="html">
