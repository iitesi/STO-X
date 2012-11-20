<cfcomponent extends="org.corfield.framework">
	
	<cfset this.name = 'booking21'>
	<cfset this.mappings["booking"] = getDirectoryFromPath(getCurrentTemplatePath())>
	<cfset this.sessionManagement = true>
	<cfset this.sessionTimeout = CreateTimespan(1,0,0,0)>
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
		reloadApplicationOnEveryRequest = true,
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
	
	<cffunction name="setupApplication">
		
		<cfset controller( 'setup.setApplication' )>
		
	</cffunction>
	
	<cffunction name="setupSession">
		
		<cfset controller( 'setup.setSession' )>

	</cffunction>
	
	<cffunction name="setupRequest">

		<cfset application.bDebug = 1>
		<cfset controller( 'setup.setApplication' )>
		<cfset controller( 'setup.setSession' )>
		
	</cffunction>
	
	<cffunction name="onRequestEnd">
		
	</cffunction>
	
</cfcomponent>