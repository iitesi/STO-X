<cfcomponent extends="org.corfield.framework">
	
	<cfset this.mappings["booking"] = getDirectoryFromPath(getCurrentTemplatePath())>
	<cfset this.name = 'booking'>
	<cfset this.sessionManagement = true>
	<cfset this.sessionTimeout = CreateTimespan(0,1,0,0)>
	<cfset this.applicationManagement = true>
	
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
		generateSES = true,
		SESOmitIndex = false,
		baseURL = 'useCgiScriptName',
		suppressImplicitService = true,
		unhandledExtensions = 'cfc',
		unhandledPaths = '/external',
		preserveKeyURLKey = 'fw1pk',
		maxNumContextsPreserved = 10,
		cacheFileExists = false,
		applicationKey = 'org.corfield.framework'
	}>
	
	<cffunction name="setupApplication">
		<cfset application.serverurl = IIF( cgi.https EQ 'on', DE("https"), DE("http") )&'://'&cgi.Server_Name&'/'&GetToken(this.mappings["booking"], ListLen(this.mappings["booking"], '\'), '\')>
		<cfif cgi.SERVER_NAME EQ 'www.shortstravelonline.com'>
			<cfset application.portalurl = 'https://www.shortstravel.com'>
		<cfelseif cgi.SERVER_NAME EQ 'www.shortstravel.com'>
			<cfset application.portalurl = 'https://www.shortstravel.com'>
		<cfelseif cgi.SERVER_NAME EQ 'www.b-hives.com'>
			<cfset application.portalurl = 'https://www.b-hive.travel'>
		<cfelseif cgi.SERVER_NAME EQ 'localhost'>
			<cfset application.portalurl = 'http://localhost'>
		<cfelseif cgi.SERVER_NAME EQ 'localhost:8888'>
			<cfset application.portalurl = 'http://localhost:8888'>
		<cfelseif cgi.SERVER_NAME EQ 'hermes.shortstravel.com'>
			<cfset application.portalurl = 'https://hermes.shortstravel.com'>
		<cfelse>
			<cfabort>
		</cfif>
		<cfset application.HCM = 'ProHCM'>
		<cfset application.book = 'book'>
		<cfset application.allowedtravelers = 4>
		<cfset application.auth = ToBase64('Universal API/uAPI6148916507-02cbc4d4:Qq7?b6*X5B')>
	</cffunction>
	
	<cffunction name="setupSession">
		
	</cffunction>
	
	<cffunction name="setupRequest">
		
		<cfset controller( 'session.security' )>
		
	</cffunction>
	
	<cffunction name="onRequestEnd">
	</cffunction>
	
</cfcomponent>