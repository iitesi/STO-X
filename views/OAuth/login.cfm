<cfscript> 
	param name="session.userID" default="0";
	param name="variables.auth.securityCode" default="";
	// allow params to passed by form or url
	structAppend(variables.auth,url,true);
	structAppend(variables.auth,form,true);
	variables.auth.account = application.fw.factory.getBean("AuthService").init( 
		secureAuthRedirectUri = '' 
	).getAccountInfo(variables.auth.securityCode); 
	session.acct_id = variables.auth.account.acct_id;  
	// default auth params (set for portal)
	param name="variables.auth.code" default="";
	param name="variables.auth.baseUri" default="http#iif(cgi.https eq 'off',de(''),de('s'))#://#cgi.server_name#/travelportalv2/";
	param name="variables.auth.redirectUri" default="#variables.auth.account.providerSTORedirectURL#";
	param name="variables.auth.onSuccessUri" default="#variables.auth.baseUri#?Display=Home/index.cfm";
	param name="variables.auth.onErrorUri" default="#variables.auth.baseUri#auth/oauth/?invalidLogin"; 
	if (Trim(auth.account.sso_idp) == 'Google') {		
		param name="variables.auth.tokenURL" default="https://accounts.google.com/o/oauth2/token";
		param name="variables.auth.ssoIdentifier" default="email";
	}
	param name="variables.auth.client_id" default="#variables.auth.account.clientID#";
	param name="variables.auth.client_secret" default="#variables.auth.account.clientSecret#";
	param name="variables.auth.providerAuthURL" default="#variables.auth.account.providerAuthURL#";
 	param name="variables.auth.scopeURL" default = "https://www.googleapis.com/auth/userinfo.email";
	// service handles auth and redirects
	application.fw.factory.getBean("AuthService").init(
		tokenURL = variables.auth.tokenURL,
		ssoIdentifier = variables.auth.ssoIdentifier
	).authenticate(session.acct_id,variables.auth.code); 
</cfscript>  
<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">

		<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
		<meta http-equiv="Pragma" content="no-cache">
		<meta http-equiv="Expires" content="0">

		<link rel="shortcut icon" href="http://www.shortstravelmanagement.com/favicon.ico">
		<link rel="apple-touch-icon" href="Assets/Images/apple-touch-icon.png">
		<link rel="apple-touch-icon" sizes="72x72" href="Assets/Images/apple-touch-icon-72x72.png">
		<link rel="apple-touch-icon" sizes="114x114" href="Assets/Images/apple-touch-icon-114x114.png">

		<link rel="stylesheet" href="Assets/Libraries/bootstrap-3.3.6-dist/css/bootstrap.min.css">
		<link rel="stylesheet" href="Assets/Libraries/bootstrap-3.3.6-dist/css/bootstrap-theme.min.css">
		<script src="Assets/Libraries/bootstrap-3.3.6-dist/js/bootstrap.min.js"></script>

		<link rel="stylesheet" href="Assets/CSS/Stylesheet.css?{ts '2016-11-15 17:54:50'}">

		<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
		<!--[if lt IE 9]>
			<script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
			<script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
		<![endif]-->
	</head>
	<body>
		<nav class="navbar navbar-static-top">
			<div class="navbar-header">
				<img src="Assets/Images/STO-Logo.gif" alt="Shorts Travel Management" class="img-responsive">
			</div>
		</nav>
		<div id="Main">
			<br class="hidden-xs">
			<br>
			<div class="container">
				<div class="row">
					<div class="col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3 col-lg-4 col-lg-offset-4">
						<div class="panel panel-default">
							<div class="panel-heading" id="login-head">
								<h1 class="panel-title">Log In</h1>
							</div>
							<div class="panel-body" id="login-body" style="text-align:center;padding:25px 0 25px 0;">
								<cfif isDefined("invalidLogin")>
									<p style="color:red;font-weight:bold;padding:5px 20px 20px 20px;">
										Error Logging In: Please contact the<br>
										Help Desk at 877-392-6646 if you need<br>
										assistance accessing the travel website.
									</p>
								</cfif> 
								<cfoutput>
								<button type="submit" onclick="window.location='#variables.auth.providerAuthURL#?scope=#URLEncodedFormat(variables.auth.scopeURL)#&state=%2Fprofile&client_id=#variables.auth.client_id#&redirect_uri=#variables.auth.redirectUri#&response_type=code&access_type=offline&approval_prompt=force';" name="btn_LogIn" id="btn_LogIn_SecureAuth" class="btn btn-primary"><i class="fa fa-sign-in with-text"></i> Login using your account</button>
								</cfoutput>

							</div>
						</div>
					</div>
				</div>
			</div>
			<br class="hidden-xs">
			<br>
		</div>
		<footer>
			<div class="container text-center hidden-md hidden-lg">
				<small>
					Copyright Shorts Travel Management <cfoutput>#year(now())#</cfoutput>.
					<br>All Rights Reserved.
				</small>
			</div>
		</footer>
	</body>
</html> 