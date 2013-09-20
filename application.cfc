
<cfcomponent extends="org.corfield.framework">

	<cfset this.name = "booking_" & hash(getCurrentTemplatePath())>
	<cfset this.mappings["booking"] = getDirectoryFromPath(getCurrentTemplatePath())>
	<cfset this.sessionManagement = true>
	<cfset this.sessionTimeout = CreateTimespan(1,0,0,0)>
	<cfset this.applicationManagement = true>
	<cfset this.defaultdatasource = "book">

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
		reloadApplicationOnEveryRequest = IsLocalHost(cgi.local_addr),
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
		<cfset application.bDebug = 0>
		<cfset application.gmtOffset = '6:00'>
		<cfset application.developerEmail = "jpriest@shortstravel.com">
	</cffunction>

	<cffunction name="setupSession">
		<cfset session.searches = {}>
		<cfset session.aMessages = []>
	</cffunction>

	<cffunction name="setupRequest" output="true">

		<cfset controller( 'setup.setSearchID' )>
		<cfset controller( 'setup.setFilter' )>
		<cfset controller( 'setup.setAcctID' )>
		<cfset controller( 'setup.setAccount' )>
		<cfset controller( 'setup.setPolicyID' )>
		<cfset controller( 'setup.setPolicy' )>
		<cfset controller( 'setup.setGroup' )>
		<cfset request.context.currentEnvironment = getBeanFactory().getBean( 'EnvironmentService' ).getCurrentEnvironment() />

		<cfif structKeyExists( request.context, "reload" ) AND request.context.reload IS true>
			<cfset request.layout = false>
			<cfset setupApplication() />
		</cfif>

		<cfif NOT structKeyExists(request.context, 'SearchID')>
			<cfset var action = ListFirst(request.context.action, '.')>
			<cfset view( "main/notfound" )>
		<cfelse>

			<cfif NOT findNoCase( "RemoteProxy.cfc", cgi.script_name )>
				<cfif NOT structKeyExists( session, "isAuthorized" ) OR session.isAuthorized NEQ TRUE>

					<cfset session.isAuthorized = false />

					<cfif structKeyExists( request.context, "userId" ) AND structKeyExists( request.context, "acctId" ) AND structKeyExists( request.context, "date" ) AND structKeyExists( request.context, "token" )>
						<cfset session.isAuthorized = getBeanFactory().getBean( "AuthorizationService" ).checkCredentials( request.context.userId, request.context.acctId, request.context.date, request.context.token )>
					</cfif>

				</cfif>

				<cfif NOT session.isAuthorized>
					<cflocation url="#getBeanFactory().getBean( 'EnvironmentService' ).getPortalURL()#" addtoken="false">
				</cfif>
			</cfif>



		</cfif>

	</cffunction>

	<cffunction name="onMissingView" hint="I handle missing views.">
		<cfreturn view( "main/notfound" )>
	</cffunction>

	<cffunction name="onError" returnType="void">
		<cfargument name="Exception" required=true/>
		<cfargument name="EventName" type="String" required=true/>

		<cfif application.fw.factory.getBean( 'EnvironmentService' ).getEnableBugLog() IS true>
			 <cfset application.fw.factory.getBean('BugLogService').notifyService( message=arguments.exception.Message, exception=arguments.exception, severityCode='Fatal' ) />
			 <cfset super.onError( arguments.exception, arguments.eventName )>
		<cfelse>
			 <cfset super.onError( arguments.exception, arguments.eventName )>
		 </cfif>
	</cffunction>
</cfcomponent>