<cfif NOT findNoCase( ".cfc", cgi.script_name )>
	<cfif NOT structKeyExists( session, "isAuthorized" ) OR session.isAuthorized NEQ TRUE>

		<cfset session.isAuthorized = false />

		<cfif structKeyExists( request.context, "userId" ) AND structKeyExists( request.context, "acctId" ) AND structKeyExists( request.context, "date" ) AND structKeyExists( request.context, "token" )>
			<cfset session.isAuthorized = fw.getBeanFactory().getBean( "AuthorizationService" ).checkCredentials( request.context.userId, request.context.acctId, request.context.date, request.context.token )>

			<cfif session.isAuthorized>
				<cfcookie domain="#cgi.http_host#" secure="yes" name="userId" value="#request.context.userId#" />
				<cfcookie domain="#cgi.http_host#" secure="yes" name="acctId" value="#request.context.acctId#" />
				<cfcookie domain="#cgi.http_host#" secure="yes" name="date" value="#request.context.date#" />
				<cfcookie domain="#cgi.http_host#" secure="yes" name="token" value="#request.context.token#" />

				<cfset var apiURL = fw.getBeanFactory().getBean('EnvironmentService').getShortsAPIURL() />
				<cfset apiURL = replace( replace( apiURL, "http://", "" ), "https://", "") />

				<cfif apiURL NEQ cgi.http_host>
					<cfcookie domain="#apiURL#" secure="yes" name="userId" value="#request.context.userId#" />
					<cfcookie domain="#apiURL#" secure="yes" name="acctId" value="#request.context.acctId#" />
					<cfcookie domain="#apiURL#" secure="yes" name="date" value="#request.context.date#" />
					<cfcookie domain="#apiURL#" secure="yes" name="token" value="#request.context.token#" />
				</cfif>
				<cfset session.cookieDate = request.context.date />
				<cfset session.cookieToken = request.context.token />
			</cfif>

		</cfif>
	<cfelse>
		<cfset var apiURL = fw.getBeanFactory().getBean('EnvironmentService').getShortsAPIURL() />
		<cfset apiURL = replace( replace( apiURL, "http://", "" ), "https://", "") />
		<cfif structKeyExists(request.context, 'date')>
			<cfset session.cookieDate = request.context.date>
			<cfcookie domain="#cgi.http_host#" secure="yes" name="date" value="#request.context.date#" />								
			<cfif apiURL NEQ cgi.http_host>
				<cfcookie domain="#apiURL#" secure="yes" name="date" value="#request.context.date#" />
			</cfif>
		</cfif>
		<cfif structKeyExists(request.context, 'token')>
			<cfset session.cookieToken = request.context.token>
			<cfcookie domain="#cgi.http_host#" secure="yes" name="token" value="#request.context.token#" />
			<cfif apiURL NEQ cgi.http_host>
				<cfcookie domain="#apiURL#" secure="yes" name="token" value="#request.context.token#" />
			</cfif>
		</cfif>
	</cfif>

	<cfif NOT session.isAuthorized>
		<cfif structKeyExists(cookie,"loginOrigin") AND cookie.loginOrigin EQ "STO">
			<cfif structKeyExists(cookie,"acctId") AND cookie.acctId EQ 532>
				<cflocation url="#fw.getBeanFactory().getBean('EnvironmentService').getSTOURL()#/?action=dycom.login" addtoken="false">
			<cfelse>
				<cflocation url="#fw.getBeanFactory().getBean('EnvironmentService').getSTOURL()#/?action=main.login" addtoken="false">
			</cfif>
		<cfelse>
			<cflocation url="#fw.getBeanFactory().getBean('EnvironmentService').getPortalURL()#" addtoken="false">
		</cfif>
	</cfif>

</cfif>