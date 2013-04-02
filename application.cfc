<cfcomponent extends="org.corfield.framework">
	
	<cfset this.name = 'booking20'>
	<cfset this.mappings["booking"] = getDirectoryFromPath(getCurrentTemplatePath())>
	<cfset this.sessionManagement = true>
	<cfset this.sessionTimeout = CreateTimespan(1,0,0,0)>
	<!--- <cfset this.sessionStorage = 'Sessions'>
	<cfset this.sessionCluster = true> --->
	<cfset this.applicationManagement = true>
	<cfset this.defaultdatasource = "book">

	<cfset variables.framework = {
		action = 'action',
		usingSubsystems = false,
		defaultSubsystem = 'home',
		defaultSection = 'main',
		defaultItem = 'default',
		subsystemDelimiter = ':',
		siteWideLayoutSubsystem = 'common',
		home = 'main.default', 
		error = 'main.error', 
		reload = 'reload',
		password = 'true',
		reloadApplicationOnEveryRequest = (cgi.server_name EQ 'localhost' ? true : false),
		generateSES = false,
		SESOmitIndex = false,
		baseURL = 'useCgiScriptName',
		suppressImplicitService = true,
		unhandledExtensions = 'cfc',
		unhandledPaths = '/external',
		preserveKeyURLKey = 'fw1pk',
		maxNumContextsPreserved = 10,
		cacheFileExists = false,
		applicationKey = 'fw'
	}>

<!---
setupApplication
--->
	<cffunction name="setupApplication">

		<cfset local.bf = createObject('component','coldspring.beans.DefaultXmlBeanFactory')
				.init( defaultProperties = { currentServerName=cgi.http_host }) />
		<cfset bf.loadBeans( expandPath('/booking/config/coldspring.xml') ) />
		<cfset setBeanFactory(bf)>

		<cfset controller( 'setup.setApplication' )>
		<cfset application.bDebug = 1>

	</cffunction>

<!---
setupSession
--->
	<cffunction name="setupSession">

		<cfset session.searches = {}>
		<cfset session.aMessages = []>

	</cffunction>

<!---
setupRequest
--->
	<cffunction name="setupRequest" output="true">

		<cfset controller( 'setup.setSearchID' )>
		<cfset controller( 'setup.setFilter' )>
		<cfset controller( 'setup.setAcctID' )>
		<cfset controller( 'setup.setAccount' )>
		<cfset controller( 'setup.setPolicyID' )>
		<cfset controller( 'setup.setPolicy' )>
		<cfset controller( 'setup.setGroup' )>

		<cfif NOT structKeyExists(request.context, 'SearchID')>
			Not A Valid Search<cfabort>
		</cfif>

	</cffunction>

<!---
onRequestEnd
--->
	<cffunction name="onRequestEnd">

	</cffunction>
	
</cfcomponent>