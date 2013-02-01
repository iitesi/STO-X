<cfcomponent extends="org.corfield.framework">
	
	<cfset this.name = 'booking15'>
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
		
		<cfset bf = createObject('component','coldspring.beans.DefaultXmlBeanFactory').init()>
		<cfset bf.loadBeans( expandPath('/booking/config/coldspring.xml') )>
		<cfset setBeanFactory(bf)>
		<cfset controller( 'setup.setApplication' )>
		<cfset application.bDebug = 1>
		<cfset application.objHotelDetails  = createObject("component", "booking.services.hoteldetails")>
		<cfset application.objHotelPhotos  = createObject("component", "booking.services.hotelphotos")>
		<cfset application.objHotelPrice  = createObject("component", "booking.services.hotelprice")>
		<cfset application.objHotelRooms = createObject("component", "booking.services.hotelrooms")>

	</cffunction>
	
	<cffunction name="setupSession">

		<cfset session.searches = {}>
		<cfset session.aMessages = []>

	</cffunction>
	
	<cffunction name="setupRequest">

		<cfset request.context.SearchID = (StructKeyExists(request.context, 'SearchID') ? request.context.SearchID : 0)>
		<cfset controller( 'setup.setSearch' )>
		<!---Redirect the site if the search hasn't been loaded yet.--->
		<cfif (NOT StructKeyExists(session, 'searches')
		OR NOT StructKeyExists(session.searches, request.context.SearchID))
		AND request.context.action NEQ 'main.default'>
			<cfset redirect('main?SearchID=#request.context.SearchID#')>
		</cfif>
		<cfset request.context.AcctID = (structKeyExists(session, 'AcctID') ? session.AcctID : 0)>
		<cfset controller( 'setup.setAccount' )>
		<cfset request.context.PolicyID = (structKeyExists(session, 'PolicyID') ? session.PolicyID : 0)>
		<cfset controller( 'setup.setPolicy' )>


		<cfset request.context.Group = (StructKeyExists(request.context, 'Group') ? request.context.Group : '')>


	</cffunction>
	
	<cffunction name="onRequestEnd">

	</cffunction>
	
</cfcomponent>