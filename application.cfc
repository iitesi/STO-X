
<cfcomponent extends="org.corfield.framework">

	<cfset this.name = "booking_" & hash(getCurrentTemplatePath())>
	<cfset this.mappings["booking"] = getDirectoryFromPath(getCurrentTemplatePath())>
	<cfset this.sessionManagement = true>
	<cfset this.applicationManagement = true>

	<cfset variables.framework = {
		action = 'action',
		applicationKey = 'fw',
		baseURL = 'useCgiScriptName',
		cacheFileExists = false,
		defaultItem = 'default',
		defaultSection = 'main',
		defaultSubsystem = 'home',
		error = 'main.error',
		generateSES = false,
		home = 'main.default',
		maxNumContextsPreserved = 10,
		password = 'true',
		preserveKeyURLKey = 'fw1pk',
		reload = 'reload',
		reloadApplicationOnEveryRequest = (NOT isLocalHost(cgi.remote_addr) ? false : true),
		SESOmitIndex = false,
		siteWideLayoutSubsystem = 'common',
		subsystemDelimiter = ':',
		suppressImplicitService = true,
		trace = false,
		unhandledExtensions = 'cfc',
		unhandledPaths = '/external',
		usingSubsystems = false
	}>

	<cffunction name="setupApplication">
		<cfset local.bf = createObject('component','coldspring.beans.DefaultXmlBeanFactory')
				.init( defaultProperties = { currentServerName=cgi.http_host }) />
		<cfset bf.loadBeans( expandPath('/booking/config/coldspring.xml') ) />
		<cfset setBeanFactory(bf)>
		<cfset controller( 'setup.setApplication' )>
		<cfset application.gmtOffset = '6:00'>
		<cfset application.es = getBeanFactory().getBean('EnvironmentService') />
	</cffunction>

	<cffunction name="setupSession">
		<cfset session.searches = {}>
		<cfset session.filters = {}>
		<cfset session.aMessages = []>
	</cffunction>

	<cffunction name="setupRequest">

		<cfif (NOT structKeyExists(request.context, 'SearchID')
			OR NOT isNumeric(request.context.searchID))
			AND request.context.action NEQ 'main.notfound'>
			<cfset var action = ListFirst(request.context.action, '.')>

			<cflocation url="#buildURL( "main.notfound" )#" addtoken="false">

		<cfelse>
			<cfif NOT findNoCase( ".cfc", cgi.script_name )>
				<cfif NOT structKeyExists( session, "isAuthorized" ) OR session.isAuthorized NEQ TRUE>

					<cfset session.isAuthorized = false />

					<cfif structKeyExists( request.context, "userId" ) AND structKeyExists( request.context, "acctId" ) AND structKeyExists( request.context, "date" ) AND structKeyExists( request.context, "token" )>
						<cfset session.isAuthorized = getBeanFactory().getBean( "AuthorizationService" ).checkCredentials( request.context.userId, request.context.acctId, request.context.date, request.context.token )>

						<cfif session.isAuthorized>
							<cfcookie domain="#cgi.http_host#" name="userId" value="#request.context.userId#" />
							<cfcookie domain="#cgi.http_host#" name="acctId" value="#request.context.acctId#" />
							<cfcookie domain="#cgi.http_host#" name="date" value="#request.context.date#" />
							<cfcookie domain="#cgi.http_host#" name="token" value="#request.context.token#" />

							<cfset var apiURL = getBeanFactory().getBean('EnvironmentService').getShortsAPIURL() />
							<cfset apiURL = replace( replace( apiURL, "http://", "" ), "https://", "") />

							<cfif apiURL NEQ cgi.http_host>
								<cfcookie domain="#apiURL#" name="userId" value="#request.context.userId#" />
								<cfcookie domain="#apiURL#" name="acctId" value="#request.context.acctId#" />
								<cfcookie domain="#apiURL#" name="date" value="#request.context.date#" />
								<cfcookie domain="#apiURL#" name="token" value="#request.context.token#" />
							</cfif>

						</cfif>

					</cfif>
				</cfif>

				<cfif NOT session.isAuthorized>
					<cflocation url="#getBeanFactory().getBean( 'EnvironmentService' ).getPortalURL()#" addtoken="false">
				</cfif>

			</cfif>

			<cfset controller( 'setup.setSearchID' )>
			<cfset controller( 'setup.setFilter' )>
			<cfset controller( 'setup.setAcctID' )>
			<cfset controller( 'setup.setAccount' )>
			<cfset controller( 'setup.setPolicyID' )>
			<cfset controller( 'setup.setPolicy' )>
			<cfset controller( 'setup.setGroup' )>
			<cfset controller( 'setup.setBlackListedCarrierPairing' )>
		</cfif>

	</cffunction>

	<cffunction name="onMissingView" hint="I handle missing views.">
		<cfreturn view( "main/notfound" )>
	</cffunction>

	<cffunction name="onError" returnType="void">
		<cfargument name="Exception" required=true/>
		<cfargument name="EventName" type="String" required=true/>

		<cfset local.acctID = ''>
		<cfset local.userID = ''>
		<cfset local.username = ''>
		<cfset local.department = ''>
		<cfset local.searchID = ''>

		<cftry>
			<!--- If the rc scope isn't defined then look a little more to see if we can track down the searchID and pull from the session. --->
			<cfif NOT structKeyExists(arguments, 'rc')
				OR NOT structKeyExists(arguments.rc, 'Filter')>
				<!--- Have to look directly at the url scope as the rc may or may not be defined.  Most likely not. --->
				<cfif (structKeyExists(arguments, 'rc')
					AND structKeyExists(arguments.rc, 'searchID'))
					OR (isDefined("url")
						AND structKeyExists(url, 'searchID'))>
					<!--- Move that searchID into the local scope --->
					<cfif structKeyExists(arguments, 'rc')
						AND structKeyExists(arguments.rc, 'searchID')>
						<cfset local.searchID = arguments.rc.searchID>
					<cfelseif isDefined("url")
						AND structKeyExists(url, 'searchID')>
						<cfset local.searchID = url.searchID>
					</cfif>
					<!--- Check the session for the filter --->
					<cfif structKeyExists(session, 'Filters')
						AND structKeyExists(session.Filters, searchID)>

						<cfset arguments.rc.Filter = session.Filters[searchID]>

					</cfif>

				</cfif>

			</cfif>
			<cfif structKeyExists(arguments, 'rc')
				AND structKeyExists(arguments.rc, 'Filter')>
				<cfset local.acctID = arguments.rc.Filter.getAcctID()>
				<cfset local.userID = arguments.rc.Filter.getUserID()>
				<cfset local.username = arguments.rc.Filter.getUsername()>
				<cfset local.department = arguments.rc.Filter.getDepartment()>
				<cfset local.searchID = arguments.rc.Filter.getSearchID()>
			</cfif>
		<cfcatch>
		</cfcatch>
		</cftry>

		<cfset local.errorException = structNew('linked')>
		<cfset local.errorException = {
									acctID = local.acctID
								, userID = local.userID
								, username = local.username
								, department = local.department
								, searchID = local.searchID
								, exception = arguments.exception
								} >

		<cfif application.fw.factory.getBean( 'EnvironmentService' ).getEnableBugLog()>
			 <cfset application.fw.factory.getBean('BugLogService').notifyService( message=arguments.exception.Message, exception=local.errorException, severityCode='Fatal' ) />
			 <cfset super.onError( arguments.exception, arguments.eventName )>
		<cfelse>
			 <cfset super.onError( arguments.exception, arguments.eventName )>
		 </cfif>

		<cfif listFindNoCase('local,qa', application.fw.factory.getBean( 'EnvironmentService' ).getCurrentEnvironment())>
			<cfdump var="#arguments.exception#" />
		</cfif>

	</cffunction>

	<cffunction name="onCFCRequest" access="public" returnType="void" returnformat="plain">
        <cfargument name="cfcname" type="string" required="true">
        <cfargument name="method" type="string" required="true">
        <cfargument name="args" type="struct" required="true">
		<!---TODO: Figure out how to make this happen. Widget reporting cgi.http_referrer is an empty string--->
		<!---
		<cfif application.fw.factory.getBean( "EnvironmentService" ).getCurrentEnvironment() EQ 'PROD' AND NOT
			(
				findNoCase( "shortstravel.com", cgi.http_referrer ) OR
				findNoCase( "shortstravelonline.com", cgi.http_referrer ) OR
				findNoCase( "b-hive.com", cgi.http_referrer ) OR
				findNoCase( "b-hives.com", cgi.http_referrer )
			)>

			<cfheader statusCode="403" statustext="Not Authorized" />
			<cfreturn />
		</cfif>
		--->
		<cfif NOT structKeyExists( cookie, "userId" ) OR  NOT structKeyExists( cookie, "acctId" ) OR NOT structKeyExists( cookie, "date" ) OR NOT structKeyExists( cookie, "token" )>
			<cfset local.isAuthorized = false />
		<cfelse>
			<cfset local.isAuthorized = application.fw.factory.getBean( "AuthorizationService" ).checkCredentials( cookie.userId, cookie.acctId, cookie.date, cookie.token )>
		</cfif>

		<cfif local.isAuthorized>
			<cfinvoke component="#arguments.cfcname#" method="#arguments.method#" argumentcollection="#arguments.args#" returnvariable="local.result">

			<cfif NOT isSimpleValue( local.result )>
				<cfset local.result = serializeJSON( local.result ) />
			</cfif>

			<cfif isJSON( local.result )>
				<cfset local.responseMimeType = "application/json" />
			<cfelse>
				<cfset local.responseMimeType = "application/javascript" />
			</cfif>

			<cfset local.binaryResponse = toBinary(toBase64( local.result )) />

			<!---<cfheader name="content-length" value="#arrayLen( local.binaryResponse )#" />--->

			<cfcontent type="#local.responseMimeType#" variable="#local.binaryResponse#" />

		<cfelse>
			<cfheader statusCode="403" statustext="Not Authorized" />
		</cfif>

		<cfreturn />
	</cffunction>

</cfcomponent>