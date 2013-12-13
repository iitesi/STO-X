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
			<link href="#application.assetURL#/css/bootstrap.min.css" rel="stylesheet" media="screen">
			<link href="#application.assetURL#/css/skeleton.css" rel="stylesheet" media="screen">
			<link href="#application.assetURL#/css/smoothness/jquery-ui-1.9.2.custom.css" rel="stylesheet" media="screen">
			<link href="#application.assetURL#/css/font-awesome.min.css" rel="stylesheet" media="screen">
			<!--[if IE 7]>
				<link rel="stylesheet" href="#application.assetURL#/css/font-awesome-ie7.min.css" media="screen">
			<![endif]-->
			<link href="#application.assetURL#/css/layout.css" rel="stylesheet" media="screen">
			<link href="#application.assetURL#/css/style.css" rel="stylesheet" media="screen">
			<link href="#application.assetURL#/css/print.css" rel="stylesheet" media="print">
			<link href='https://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css'>

			<!--- 11:29 AM Thursday, December 12, 2013 - Jim Priest - jpriest@shortstravel.com
			should be 1!  Set to 0 until TMC policy info is populated in DB --->

			<!--- override header colors for TMC so their light logos will display properly --->
			<cfif rc.account.tmc.getIsExternal() EQ 0>
				<style type="text/css">
					##main-header {background-color: ##292929}
					##header-top {background-color: ##F1F1F1}
					##main-nav ul li.active, ##main-nav ul li:hover {background-color: ##555}
				</style>
			</cfif>

			<cfif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1>
				<style type="text/css">
					body {
						background-color: ###rc.filter.getBodyColor()#;
					}
					##main-header, ##header-top {
						background-color: ###rc.filter.getHeaderColor()#;
					}
				</style>
			</cfif>
			<!--[if lt IE 9]>
						<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
			<![endif]-->
			<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
			<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>
			<script src="#application.assetURL#/js/jquery.plugins.min.js"></script>
			<script src="#application.assetURL#/js/bootstrap.min.js"></script>
			<script src="#application.assetURL#/js/booking.js"></script>
		</cfoutput>
	</head>
	<body>
		<div id="main-wrapper" class="wide">
			<header id="main-header">


				<div id="header-top">
					<div class="container">
						<div class="sixteen columns">
<cfoutput>


<!---
<img src="http://dummyimage.com/100x50/f0f/fff" alt=""/>
http://jsfiddle.net/thecrumb/DWZjB/
http://stackoverflow.com/questions/18707761/left-center-right-divs-with-vertical-alignment --->

<div id="logo-container">
	<div id="header">
		<a href="#application.sPortalURL#" title="Home">
			<img src="assets/img/logos/findit-logo.png" alt="FindIt" class="pull-left">
		</a>
		<div id="headerContent">
			<cfif structKeyExists(rc, "account")
				AND isStruct(rc.account)
				AND NOT structIsEmpty(rc.account)
				AND rc.account.acct_ID NEQ 1
				AND len(trim(rc.account.account_logo))
				AND FileExists("https://www.shortstravel.com/TravelPortalV2/Images/Clients/#rc.account.account_logo#")>
				<img src="https://www.shortstravel.com/TravelPortalV2/Images/Clients/#rc.account.account_logo#" alt="#rc.account.account_name#" class="pull-right" />
			</cfif>
		</div>
	</div>








</div> <!--- // logo-container --->



<!---
<cfif rc.account.tmc.getIsExternal() EQ 0>


<cfelse>

	<cfif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getSiteUrl()))>
		<a href="#rc.filter.getSiteUrl()#" title="Home">
	<cfelse>
		<a href="#application.sPortalURL#" title="Home">
	</cfif>
		<cfif structKeyExists(rc, "account")
			AND isStruct(rc.account)
			AND NOT structIsEmpty(rc.account)
			AND rc.account.acct_ID NEQ 1
			AND len(trim(rc.account.account_logo))
			AND FileExists("https://www.shortstravel.com/TravelPortalV2/Images/Clients/#rc.account.account_logo#")>
			<img src="https://www.shortstravel.com/TravelPortalV2/Images/Clients/#rc.account.account_logo#" alt="#rc.account.account_name#"/>
		<cfelse>
			<img src="assets/img/clients/STO-Logo.gif" alt="Short's Travel Management" />
		</cfif>
	</a>
</cfif> --->






</cfoutput>



							<cfoutput>#View('main/navigation')#</cfoutput>
						</div> <!--- // sixteen columns --->
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
					</div> <!--- // container --->
				</div> <!--- // header-top --->



				<div id="header-bottom">
					<cfif (rc.action EQ 'air.lowfare' OR rc.action EQ 'air.availability') AND ArrayLen(StructKeyArray(session.searches)) GTE 1>
						<div class="container">
							<cfif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getWidgetUrl()))>
								<cfset frameSrc = (cgi.https EQ 'on' ? 'https' : 'http')&'://'&cgi.Server_Name&'/search/index.cfm?'&rc.filter.getWidgetUrl() & '&token=#cookie.token#&date=#cookie.date#'/>
							<cfelse>
								<cfset frameSrc = application.searchWidgetURL  & '?acctid=#rc.filter.getAcctID()#&userid=#rc.filter.getUserId()#&token=#cookie.token#&date=#cookie.date#' />
							</cfif>

						<!--- button to open search in modal window --->
							<div class="one columns newsearch">
								<cfoutput>
								<a href="##" class="btn searchModalButton" data-framesrc="#frameSrc#&amp;modal=true&amp;requery=true" title="Start a new search"><i class="icon-search"></i></a>
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
<cfoutput>
	#view('main/developers')#
</cfoutput>
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
</cfif>

<!--- uncomment for debugging
<cfif IsLocalHost(cgi.local_addr)>
	<cfdump var="#application#" expand="false">
	<cfdump var="#session.searches[rc.SearchID]#" expand="false">
	<cfdump var="#session.filters#" expand="false">
</cfif>
--->