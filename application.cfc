
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
		<cfset application.baseURL = "">
	</cffunction>

	<cffunction name="setupSession">
		<cfset session.searches = {}>
		<cfset session.aMessages = []>
	</cffunction>

	<cffunction name="setupRequest" output="true">


		<cfif structKeyExists( URL, "reload" ) AND URL.reload IS true>
			<cfset onApplicationStart() />
			<cfreturn view( "main/reload" )>
		</cfif>

		<cfif NOT structKeyExists(request.context, 'SearchID')>
			<cfset var action = ListFirst(rc.action, ':')>
			<cfreturn view( "main/notfound" )>
		<cfelse>
			<cfset controller( 'setup.setSearchID' )>
			<cfset controller( 'setup.setFilter' )>
			<cfset controller( 'setup.setAcctID' )>
			<cfset controller( 'setup.setAccount' )>
			<cfset controller( 'setup.setPolicyID' )>
			<cfset controller( 'setup.setPolicy' )>
			<cfset controller( 'setup.setGroup' )>
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