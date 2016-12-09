<cfscript>
	// returned in callback from auth
	param name="url.code" default="";
	// service handles auth and redirects
	application.fw.factory.getBean("SecureAuthService").authenticate(
		acctId = 532,
		code = url.code
	);
</cfscript>
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
						<button type="submit" onclick="window.location='https://auth.mycompanyview.com/secureauth423/secureauth.aspx?grant_type=authorization_code&response_type=code&scope=openid&client_id=5f7372597cb148a698e7243d0771a314&state=RANDOM_STRING&redirect_uri=<cfoutput>#application.fw.factory.getBean('SecureAuthService').getSecureAuthRedirectUri()#</cfoutput>';" name="btn_LogIn" id="btn_LogIn_SecureAuth" class="btn btn-primary"><i class="fa fa-sign-in with-text"></i> Login using your Dycom account</button>
					</div>
				</div>
			</div>
		</div>
	</div>
	<br class="hidden-xs">
	<br>
</div>