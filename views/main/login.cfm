<cfscript>
	// service handles auth and redirects
	application.fw.factory.getBean("AuthService").authenticate(
		acctId = 1, // only stm in beta
		data = form
	);
</cfscript>

<div id="Main">
	<br class="hidden-xs">
	<br>
	<div class="container">
		<div class="row">
			<div class="col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3 col-lg-4 col-lg-offset-4">
				<cfoutput>
				<form name="logInForm" id="logInForm" action="?action=main.login" method="post">
					<div class="panel panel-default">
						<div class="panel-heading">
							<h1 class="panel-title">Log In</h1>
						</div>
						<div class="panel-body">
							<cfif isDefined("invalidLogin")>
								<p style="color:red;font-weight:bold;text-align:center;">
									Username and Password not found.
								</p>
							</cfif>
							<div class="form-group">
								<label for="username">Username:</label>
								<input type="text" name="username" id="username" class="form-control" placeholder="Username" autofocus="" required="required">
							</div>
							<div class="form-group">
								<label for="password">Password:</label>
								<input type="password" name="password" id="password" class="form-control" placeholder="Password" required="required">
							</div>
							<div class="text-right">
								<button type="submit" name="btn_LogIn" id="btn_LogIn" class="btn btn-primary">
									<i class="fa fa-sign-in with-text"></i> Log In
								</button>
							</div>
						</div>
					</div>
				</form>
				</cfoutput>
			</div>
		</div>
	</div>
	<br class="hidden-xs">
	<br>
</div>