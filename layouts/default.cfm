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

			<cfoutput>
				<link href="#application.baseURL#assets/css/bootstrap.min.css" rel="stylesheet">
				<link href="#application.baseURL#assets/css/skeleton.css" rel="stylesheet">
				<link href="#application.baseURL#assets/css/smoothness/jquery-ui-1.9.2.custom.css" rel="stylesheet">
				<link href="#application.baseURL#assets/css/font-awesome.min.css" rel="stylesheet" >
				<!--[if IE 7]>
					<link rel="stylesheet" href="#application.baseURL#assets/css/font-awesome-ie7.min.css">
				<![endif]-->


				<link href="#application.baseURL#assets/css/layout.css" rel="stylesheet">
				<link href="#application.baseURL#assets/css/style.css" rel="stylesheet">

				<!--[if lt IE 9]>
							<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
				<![endif]-->


				<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
				<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>
				<script src="#application.baseURL#assets/js/jquery.plugins.min.js"></script>
				<script src="#application.baseURL#assets/js/bootstrap.min.js"></script>
				<script src="#application.baseURL#assets/js/booking.js"></script><!---Custom--->
		</cfoutput>
		</head>

		<cfsilent>
			<cfparam name="session.userID" default="" />
		</cfsilent>
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

				<div id="header-bottom">
					<cfif (rc.action EQ 'air.lowfare' OR rc.action EQ 'air.availability') AND ArrayLen(StructKeyArray(session.searches)) GTE 1>
						<div class="container">

						<!--- button to open search in modal window --->
						<div class="one columns newsearch">
							<cfoutput>
							<a href="##" id="searhModalButton" class="btn" data-framesrc="http://r.local/search/?acctid=#session.acctID#&amp;userid=#session.userID#&amp;modal=true" title="Start a new search"><i class="icon-search"></i></a>
							</cfoutput>
						</div>

						<cfoutput>#View('modal/search')#</cfoutput>

						<!--- // end modal window --->

							<div class="fifteen columns">
								<cfoutput>#View('air/breadcrumbs')#</cfoutput>
							</div>
						</div>
					<cfelse>
						<div class="container">
							<div class="sixteen columns newsearch">
								&nbsp;
							</div>
						</div>
					</cfif>
				</div>
			</header>

			<section id="main-content">
				<cfoutput>
				<div class="container">
					#view( "helpers/messages" )#
					<!--- Simple test to see if session still exists. --->
					<cfif Len(session.userID) AND StructKeyExists(session, "searches")>
						#body#
					<cfelse>
						Your session has timed out due to inactivity. Please start a <a href="#application.sPortalURL#">NEW SEARCH</a>.
					</cfif>
				</div>
				</cfoutput>
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


 <div id="searchModal" class="bigModal modal hide fade" tabindex="-1" role="dialog" aria-labelledby="searchModalLabel" aria-hidden="true">
	<div class="modal-header">
		<button type="button" class="close" data-dismiss="modal"><i class="icon-remove"></i></button>
		<h3><i class="icon-plane"></i> FLIGHT DETAILS</h3>
	</div>
	<div class="modal-body">
	</div>
</div>



		</body>
		</html>
</cfif>



<!---
<cfif IsLocalHost(cgi.remote_addr)>
	<cfdump var="#application#" expand="false">
	<cfdump var="#session.searches[rc.SearchID]#" expand="false">
</cfif>
 --->


