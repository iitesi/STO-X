<cfcomponent extends="org.corfield.framework">

	<cfset this.name = "booking_" & hash(getCurrentTemplatePath())>
	<cfset this.mappings["booking"] = getDirectoryFromPath(getCurrentTemplatePath())>
	<cfset this.sessionManagement = true>
	<!--- <cfset this.sessionStorage="sessionCache"> --->
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
		<cfset controller( 'setup.setAccount' )>
	</cffunction>


	<cffunction name="setupRequest">
		<!--- <cfif isDefined("url.reinit")>
			<cfset ApplicationStop()>
			<cflocation url="index.cfm" addtoken="false">
		</cfif> --->

		<cfif (NOT structKeyExists(request.context, 'SearchID')
			OR NOT isNumeric(request.context.searchID))
			AND request.context.action NEQ 'main.notfound'
			AND request.context.action NEQ 'setup.resetPolicy'
			AND request.context.action NEQ 'setup.setPolicy'
			AND request.context.action NEQ 'logout.default'>
			<cfset var action = ListFirst(request.context.action, '.')>
			<cflocation url="#buildURL( "main.notfound" )#" addtoken="false">
		<cfelse>
			<cfif NOT findNoCase( ".cfc", cgi.script_name )>
				<cfif NOT structKeyExists( session, "isAuthorized" ) OR session.isAuthorized NEQ TRUE>

					<cfset session.isAuthorized = false />

					<cfif structKeyExists( request.context, "userId" ) AND structKeyExists( request.context, "acctId" ) AND structKeyExists( request.context, "date" ) AND structKeyExists( request.context, "token" )>
						<cfset session.isAuthorized = getBeanFactory().getBean( "AuthorizationService" ).checkCredentials( request.context.userId, request.context.acctId, request.context.date, request.context.token )>

						<cfif session.isAuthorized>
							<cfcookie domain="#cgi.http_host#" secure="yes" name="userId" value="#request.context.userId#" />
							<cfcookie domain="#cgi.http_host#" secure="yes" name="acctId" value="#request.context.acctId#" />
							<cfcookie domain="#cgi.http_host#" secure="yes" name="date" value="#request.context.date#" />
							<cfcookie domain="#cgi.http_host#" secure="yes" name="token" value="#request.context.token#" />

							<cfset var apiURL = getBeanFactory().getBean('EnvironmentService').getShortsAPIURL() />
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
				</cfif>

				<cfif NOT session.isAuthorized>
					<cflocation url="#getBeanFactory().getBean( 'EnvironmentService' ).getPortalURL()#" addtoken="false">
				</cfif>
			</cfif>

			<cfset controller( 'setup.setSearchID' )>
			<cfset controller( 'setup.setFilter' )>
			<cfset controller( 'setup.setAcctID' )>
			<cfset controller( 'setup.setAccount' )>
			<cfset controller( 'setup.setTMC' )>
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
		<cfset local.errorException = {	acctID = local.acctID
										, userID = local.userID
										, username = local.username
										, department = local.department
										, searchID = local.searchID
										, exception = arguments.exception } >

		<cfif application.fw.factory.getBean( 'EnvironmentService' ).getEnableBugLog()>
			 <cfset application.fw.factory.getBean('BugLogService').notifyService( message=arguments.exception.Message, exception=local.errorException, severityCode='Error' ) />
			 <cfset super.onError( arguments.exception, arguments.eventName )>
		<cfelse>
			 <cfset super.onError( arguments.exception, arguments.eventName )>
		 </cfif>

		<cfif listFindNoCase('local,qa', application.fw.factory.getBean( 'EnvironmentService' ).getCurrentEnvironment())>
			<cfdump var="#local.errorException#" />
		</cfif>
	</cffunction>


	<cffunction name="onCFCRequest" access="public" returnType="void" returnformat="plain">
		<cfargument name="cfcname" type="string" required="true">
		<cfargument name="method" type="string" required="true">
		<cfargument name="args" type="struct" required="true">

		<!--- if we are in production - lets check to see where the request is coming from
					if its not one of our servers we'll end things with a 403  --->
		<cfif application.fw.factory.getBean( "EnvironmentService" ).getCurrentEnvironment() EQ 'prod'>
			<cfif NOT (
					findNoCase( "shortstravel.com", cgi.http_referer ) OR
					findNoCase( "shortstravelonline.com", cgi.http_referer ) OR
					findNoCase( "b-hive.com", cgi.http_referer ) OR
					findNoCase( "b-hives.com", cgi.http_referer )
				)>
				<cfheader statusCode="403" statustext="Not Authorized" />
				<cfreturn />
			</cfif>
		</cfif>

		<!--- If trying to cancel a Priceline hotel reservation from the portal --->
		<cfif structKeyExists(arguments.args, "invoiceID") AND (NOT structKeyExists(session, "isAuthorized") OR NOT session.isAuthorized)>
			<cfset session.isAuthorized = false />

			<cfif structKeyExists( request.context, "userId" ) AND structKeyExists( request.context, "acctId" ) AND structKeyExists( request.context, "date" ) AND structKeyExists( request.context, "token" )>
				<cfset session.isAuthorized = getBeanFactory().getBean( "AuthorizationService" ).checkCredentials( request.context.userId, request.context.acctId, request.context.date, request.context.token )>
				<cfif NOT structKeyExists(session, "TMC") OR NOT isObject(session.TMC)>
					<cfset application.Accounts[request.context.acctId] = application.fw.factory.getBean( "setup" ).setAccount( AcctID=request.context.acctId ) />
					<cfset application.Accounts[request.context.acctId].TMC = application.fw.factory.getBean( "AccountService" ).getAccountTMC( application.Accounts[request.context.acctId].AccountBrand ) />
					<cfset session.TMC = application.Accounts[request.context.acctId].TMC />
				</cfif>
			</cfif>
		</cfif>

		<!--- then we can check if our session.isAuthorized is already set
				  this should have been set in the original request from search
				  again, if this isn't present we'll abort with a 403 --->
		<cfif structKeyExists(session, "isAuthorized") AND session.isAuthorized EQ true>
			<cfinvoke component="#arguments.cfcname#" method="#arguments.method#" argumentcollection="#arguments.args#" returnvariable="local.result">
			<cfif IsNull(local.result)>
				<cfset local.result = ArrayNew(1)>
			</cfif>
			<cfif NOT isSimpleValue( local.result )>
				<cfset local.result = serializeJSON( local.result ) />
			</cfif>
			<cfif isJSON( local.result )>
				<cfset local.responseMimeType = "application/json" />
			<cfelse>
				<cfset local.responseMimeType = "application/javascript" />
			</cfif>
			<cfset local.binaryResponse = toBinary(toBase64( local.result )) />
			<cfcontent type="#local.responseMimeType#" variable="#local.binaryResponse#" />
		<cfelse>
			<cfheader statusCode="403" statustext="Not Authorized" />
		</cfif>

		<cfreturn />
	</cffunction>

</cfcomponent>
