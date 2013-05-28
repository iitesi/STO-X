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
		reloadApplicationOnEveryRequest = IsLocalHost(cgi.remote_addr),
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
	</cffunction>

	<cffunction name="setupSession">
		<cfset session.searches = {}>
		<cfset session.aMessages = []>
	</cffunction>

	<cffunction name="setupRequest" output="true">
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

</cfcomponent>