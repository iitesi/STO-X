<p>It appears we've run into an error.  The developers have been notified.</p>
<p>You may click your browsers 'back' button and try again or use the navigation menu at the top to return to the home page.</p>
<cfset request.layout = false>


<!DOCTYPE html>
<!--[if lt IE 7]> <html class="lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="lt-ie9 lt-ie8" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="lt-ie9" lang="en"> <![endif]-->
<!--[if gt IE 8]><!--><html lang="en"><!--<![endif]-->

	<head>
		<meta charset="utf-8">
		<title>Error</title>
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<meta name="description" content="">
		<meta name="author" content="">
		<cfoutput>
			<link href="#application.assetURL#/css/bootstrap.min.css" rel="stylesheet">
			<link href="#application.assetURL#/css/skeleton.css" rel="stylesheet">
			<link href="#application.assetURL#/css/smoothness/jquery-ui-1.9.2.custom.css" rel="stylesheet">
			<link href="#application.assetURL#/css/font-awesome.min.css" rel="stylesheet" >
			<!--[if IE 7]>
				<link rel="stylesheet" href="#application.assetURL#/css/font-awesome-ie7.min.css">
			<![endif]-->
			<link href="#application.assetURL#/css/layout.css" rel="stylesheet">
			<link href="#application.assetURL#/css/style.css" rel="stylesheet">
			<!--[if lt IE 9]>
						<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
			<![endif]-->
			<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
			<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>
			<script src="#application.assetURL#/js/jquery.plugins.min.js"></script>
			<script src="#application.assetURL#/js/bootstrap.min.js"></script>
			<script src="#application.assetURL#/js/booking.js"></script><!---Custom--->
		</cfoutput>
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
										<cfif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getSiteUrl()))>
											<a href="#rc.filter.getSiteUrl()#" title="Home">
										<cfelse>
											<a href="#application.sPortalURL#" title="Home">
										</cfif>
										<cfif structKeyExists(rc, "account") AND isStruct(rc.account) AND NOT structIsEmpty(rc.account) AND rc.account.acct_ID NEQ 1 AND len(trim(rc.account.logo)) AND FileExists("https://www.shortstravel.com/TravelPortalV2/Images/Clients/#rc.account.logo#")>
											<img src="https://www.shortstravel.com/TravelPortalV2/Images/Clients/#rc.account.logo#" alt="#rc.account.account_name#" />
										<cfelse>
											<img src="assets/img/clients/STO-Logo.gif" alt="Short's Travel Management" />
										</cfif>
										</a>
									</cfoutput>
								</div>
							</div>
							<cfoutput>#View('main/navigation')#</cfoutput>
						</div>
						<cfif structKeyExists(rc, 'filter')
							AND rc.Filter.getProfileID() NEQ rc.Filter.getUserID()>
							<div style="color:#999;float:right;font-weight:bold">
								Booking on behalf of
								<cfif rc.Filter.getProfileID() NEQ 0>
									<cfoutput>#rc.Filter.getProfileUsername()#</cfoutput>
								<cfelse>
									Guest Traveler
								</cfif>
							</div>
						</cfif>
					</div>
				</div>

				<div id="header-bottom">
					<cfif (rc.action EQ 'air.lowfare' OR rc.action EQ 'air.availability') AND ArrayLen(StructKeyArray(session.searches)) GTE 1>
						<div class="container">
							<cfif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getWidgetUrl()))>
								<cfset frameSrc = (cgi.https EQ 'on' ? 'https' : 'http')&'://'&cgi.Server_Name&'/search/index.cfm?'&rc.filter.getWidgetUrl()/>
							<cfelse>
								<cfset frameSrc = application.searchWidgetURL  & '?acctid=#rc.filter.getAcctID()#&userid=#rc.filter.getUserId()#' />
							</cfif>

						<!--- button to open search in modal window --->
							<div class="one columns newsearch">
								<cfoutput>
								<a href="##" class="btn searchModalButton" data-framesrc="#frameSrc#&amp;modal=true" title="Start a new search"><i class="icon-search"></i></a>
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
					    	<cfif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1>
								<a href="mailto:#rc.filter.getSiteEmail()#">QUESTIONS/COMMENTS</a><br />
					    	<cfelse>
								#View('main/policy')#
								#View('main/unusedtickets')#
							</cfif>
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
<cfif application.es.getCurrentEnvironment() NEQ "prod"
	AND rc.Filter.getAcctID() NEQ 441>
	<style type="text/css">
	<!--
	.watermark {
		font-size:50px;
		z-index:-1;
		font-weight:bold;
		position: fixed;
		bottom: 0;
		right: 0;
		padding:20px;
		color:#eee;
	}
	-->
	</style>
	<div class="watermark"><cfoutput>#uCase(application.es.getCurrentEnvironment())#</cfoutput></div>
</cfif>
		<cfif application.es.getCurrentEnvironment() EQ "prod">
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
					pageTracker._setVar("#UCase(application.accounts[ session.acctId ].Account_Name)#");
					pageTracker._trackPageview("#rc.action#");
					} catch(err) {}
				</script>
			</cfoutput>
		</cfif>
	</body>
	</html>






















<!---
<h1>An Error Occurred</h1>
<p>I am the subsystem error view: home:main.error.</p>
<p>Details of the exception:</p>
<cfoutput>
    <ul>
    <li>Failed action: <cfif structKeyExists( request, 'failedAction' )>#request.failedAction#<cfelse>unknown</cfif></li>
	<li>Application event: #request.event#</li>
	<li>Exception type: #request.exception.type#</li>
	<li>Exception message: #request.exception.message#</li>
	<li>Exception detail: #request.exception.detail#</li>
</ul>
</cfoutput>
<cfset structDelete(request.exception.cause, 'StackTrace')>
<cfdump var="#request.exception#"/>
<cfset request.layout = false> --->