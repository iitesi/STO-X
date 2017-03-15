<cfsilent>
	<cfparam name="session.userID" default="" />
</cfsilent>

<cfif cgi.SCRIPT_NAME DOES NOT CONTAIN '.cfc'>
	<!DOCTYPE html>
	<!--[if lt IE 7]> <html class="lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
	<!--[if IE 7]>    <html class="lt-ie9 lt-ie8" lang="en"> <![endif]-->
	<!--[if IE 8]>    <html class="lt-ie9" lang="en"> <![endif]-->
	<!--[if gt IE 8]><!--><html lang="en"><!--<![endif]-->
	<head>
		<meta charset="utf-8">
		<title>
			<cfif structKeyExists(rc, "filter") AND len(rc.filter.getTitle())>
				<cfoutput>#rc.filter.getTitle()#</cfoutput>
			<cfelse>
				STO .:. The New Generation of Corporate Online Booking
			</cfif>
		</title>
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<meta name="description" content="Short's Travel Online">
		<meta name="author" content="Short's Travel Management">
		<cfoutput>
			<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
			<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css" integrity="sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r" crossorigin="anonymous">
			<link href="//code.jquery.com/ui/1.9.2/themes/smoothness/jquery-ui.css" rel="stylesheet" media="screen">

			<!--[if IE 7]>
				<link rel="stylesheet" href="assets/css/font-awesome-ie7.min.css" media="screen">
			<![endif]-->
			<link href="assets/css/layout.css?v=112016" rel="stylesheet" media="screen">
			<link href="assets/css/style.css?v-032017" rel="stylesheet" media="screen">
			<link href="assets/css/print.css" rel="stylesheet" media="print">
			<link href='https://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css'>

			<!--- override header colors for TMC so their light logos will display properly --->
			<cfif structKeyExists(rc,"account") AND StructKeyExists(rc.account,"tmc") AND rc.account.tmc.getIsExternal() EQ 1>
				<style type="text/css">
					##main-header {background-color: ##292929}
					##header-top {background-color: ##F1F1F1}
					##main-nav ul li.active, ##main-nav ul li:hover {background-color: ##555}
				</style>
			</cfif>

			<!--- overried header colors if getPassthrough is sent from widget - usually for other shorts accounts
				These can be set in account config and passed on URL from widget	--->
			<cfif structKeyExists(rc,"filter") AND rc.filter.getPassthrough() EQ 1>
				<style type="text/css">
					body {background-color: ###rc.filter.getBodyColor()#;}
					##main-header, ##header-top {background-color: ###rc.filter.getHeaderColor()#;}
				</style>
			</cfif>

			<!--[if lt IE 9]>
				<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
			<![endif]-->
			<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.2/jquery.min.js"></script>
			<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script>
			<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
			<script src="https://use.fontawesome.com/4ba3a7fb90.js"></script>
			<script src="assets/js/jquery.plugins.min.js"></script>
			<script src="//cdnjs.cloudflare.com/ajax/libs/moment.js/2.5.1/moment.min.js"></script>
			<script src="//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.6.0/underscore-min.js"></script>
			<script type="text/javascript" charset="UTF-8" src="assets/js/responsive-paginate.js"></script>
			<script type="text/javascript" charset="UTF-8" src="assets/js/js.cookie.js"></script>
			<script type="text/javascript" charset="UTF-8" src="assets/js/booking.js?v=201703094"></script>
		</cfoutput>
	</head>
	<body>
		<div id="main-wrapper" class="wide">
			<header id="main-header">

				<div id="header-top">
					<nav class="navbar navbar-inverse">
  							<!-- Brand and toggle get grouped for better mobile display -->
 							<div class="navbar-header">
 							  <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse-1" aria-expanded="false">
 								<span class="sr-only">Toggle navigation</span>
 								<span class="icon-bar"></span>
 								<span class="icon-bar"></span>
								<span class="icon-bar"></span>
 							  </button>
							<cfoutput>

							<cfif NOT structKeyExists(rc,"account") OR listFind("main.login,main.logout",request.context.action)>

								<a class="navbar-brand" id="mainlogo">
									<img src="/booking/assets/img/clients/STO-Logo.png" alt="Shorts Travel Management" class="img-responsive">
								</a>

							<cfelseif rc.account.tmc.getIsExternal() EQ 1>

								<div id="logo-container">
									<div id="header">
										<cfif structKeyExists(session,"acctId") AND session.acctId EQ 532>
											<a class="navbar-brand" id="mainlogo"  href="https://www.shortstravel.com/TravelPortalV2/mcv" title="Home">
										<cfelseif structKeyExists(cookie,"loginOrigin") AND cookie.loginOrigin EQ "STO">
											<a class="navbar-brand" id="mainlogo"  href="?action=main.menu" title="Home">
										<cfelse>
											<a href="#application.sPortalURL#" title="Home">
										</cfif>
											<img src="assets/img/logos/findit-logo.png" alt="FindIt" class="pull-left">
										</a>
										<div id="headerContent">
											<cfif structKeyExists(rc, "account")
												AND isStruct(rc.account)
												AND NOT structIsEmpty(rc.account)
												AND rc.account.acct_ID NEQ 1
												AND len(trim(rc.account.account_logo))
												AND FileExists("http://www.shortstravel.com/TravelPortalV2/Images/Clients/#URLEncodedFormat(rc.account.account_logo)#")>
												<img src="https://www.shortstravel.com/TravelPortalV2/Images/Clients/#rc.account.account_logo#" alt="#rc.account.account_name#" class="pull-right" />
											</cfif>
										</div>
									</div>
								</div> <!--- // logo-container --->

							<cfelse>

								<cfif structKeyExists(session,"acctId") AND session.acctId EQ 532>

									<a class="navbar-brand" id="mainlogo"  href="https://www.shortstravel.com/TravelPortalV2/mcv" title="Home">

								<cfelseif structKeyExists(cookie,"loginOrigin") AND cookie.loginOrigin EQ "STO">
									<a class="navbar-brand" id="mainlogo"  href="?action=main.menu" title="Home">
								<cfelseif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getSiteUrl()))>
									<a class="navbar-brand" id="mainlogo"  href="#rc.filter.getSiteUrl()#" title="Home">
								<cfelse>
									<a class="navbar-brand" id="mainlogo"  href="#application.sPortalURL#" title="Home">
								</cfif>
									<cfif structKeyExists(rc, "account")
										AND isStruct(rc.account)
										AND NOT structIsEmpty(rc.account)
										AND rc.account.acct_ID NEQ 1
										AND len(trim(rc.account.account_logo))
										AND FileExists("http://www.shortstravel.com/TravelPortalV2/Images/Clients/#URLEncodedFormat(rc.account.account_logo)#")>
										<img src="https://www.shortstravel.com/TravelPortalV2/Images/Clients/#rc.account.account_logo#" alt="#rc.account.account_name#"/>
									<cfelse>
										<img src="/booking/assets/img/clients/STO-Logo.png" alt="Short's Travel Management" />
									</cfif>
								</a>
							</div> <!-- // navbar-header -->
							</cfif>

							#View('main/navigation')#

							</cfoutput>

							<cfif structKeyExists(rc, 'filter')
								AND rc.Filter.getProfileID() NEQ rc.Filter.getUserID()>
								<div id="onbehalfof">
									Booking on behalf of
									<cfif rc.Filter.getProfileID() NEQ 0>
										<cfoutput>#rc.Filter.getProfileUsername()#</cfoutput>
									<cfelse>
										Guest Traveler
									</cfif>
								</div>
							</cfif>
					  </div><!-- /.container-fluid -->
 					</nav>
				</div> <!--- // header-top --->
				<cfoutput>#View('modal/search')#</cfoutput>
				<div id="header-bottom">
					<cfif (rc.action EQ 'air.lowfare' OR rc.action EQ 'air.availability') AND ArrayLen(StructKeyArray(session.searches)) GTE 1>
						<div class="container">
							<cfif structKeyExists(session, 'cookieToken')
								AND structKeyExists(session, 'cookieDate')>
								<cfif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getWidgetUrl()))>
									<cfset frameSrc = (cgi.https EQ 'on' ? 'https' : 'http')&'://'&cgi.Server_Name&'/search/index.cfm?'&rc.filter.getWidgetUrl() & '&token=#session.cookieToken#&date=#session.cookieDate#'/>
								<cfelse>
									<cfset frameSrc = application.searchWidgetURL  & '?acctid=#rc.filter.getAcctID()#&userid=#rc.filter.getUserId()#&token=#session.cookieToken#&date=#session.cookieDate#' />
								</cfif>
							<cfelse>
								<cfset frameSrc = ''>
							</cfif>

							<!--- button to open search in modal window --->
							<div class="one columns newsearch">
								<cfoutput>
								<a href="##" class="btn searchModalButton" data-framesrc="#frameSrc#&amp;modal=true&amp;requery=true" title="Start a new search"><i class="fa fa-search"></i></a>
								</cfoutput>
							</div>

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
						<cfelseif listFind("main.logout,main.login,dycom.login",request.context.action)>
							#body#
						<cfelse>
							<cfif structKeyExists(cookie,"loginOrigin") AND cookie.loginOrigin EQ "STO">
								<cflocation url="/booking/?action=main.logout">
							<cfelse>
								Your session has timed out due to inactivity.
								Please start a <a href="#application.sPortalURL#">NEW SEARCH</a>.
							</cfif>
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
			<button type="button" class="close" data-dismiss="modal"><i class="fa fa-remove"></i></button>
			<h3><i class="fa fa-plane"></i> FLIGHT DETAILS</h3>
		</div>
		<div class="modal-body"></div>

	</div>

	<cfoutput>
		#view('main/developers')#
	</cfoutput>

	<cfif application.es.getCurrentEnvironment() EQ "prod">
		<!--- on the new login screen these may not yet be defined --->
		<cfif structKeyExists(session,"acctId") AND val(session.acctId) AND structKeyExists(application.accounts,session.acctId)>
			<cfset account_name = ucase(application.accounts[session.acctId].account_name)/>
		<cfelse>
			<cfset account_name = "Unknown: Not Logged In"/>
		</cfif>
		<cfif structKeyExists(rc,"action") AND len(rc.action)>
			<cfset action = rc.action/>
		<cfelse>
			<cfset action = "login">
		</cfif>
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
				pageTracker._setVar("#account_name#");
				pageTracker._trackPageview("#action#");
				} catch(err) {}
			</script>
		</cfoutput>
	</cfif>
	</body>
	</html>
</cfif>

<!-- %%%build-stamp%%% -->
