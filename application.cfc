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
	
	<cffunction name="setupApplication">

		<cfset bf = createObject('component','coldspring.beans.DefaultXmlBeanFactory').init()>
		<cfset bf.loadBeans( expandPath('/booking/config/coldspring.xml') )>
		<cfset setBeanFactory(bf)>

		<cfset controller( 'setup.setApplication' )>
		<cfset application.bDebug = 1>
		<!---
		<cfset application.objHotelDetails  = createObject("component", "booking.services.hoteldetails")>
		<cfset application.objHotelPhotos  = createObject("component", "booking.services.hotelphotos")>
		<cfset application.objHotelPrice  = createObject("component", "booking.services.hotelprice")>
		<cfset application.objHotelRooms = createObject("component", "booking.services.hotelrooms")>
		--->
	</cffunction>

	<cffunction name="setupSession">

		<cfset session.searches = {}>
		<cfset session.aMessages = []>

	</cffunction>

	<cffunction name="before">

	</cffunction>

	<cffunction name="setupRequest" output="true">

		<cfset controller( 'setup.setSearchID' )>
		<cfset controller( 'setup.setFilter' )>
		<cfset controller( 'setup.setAcctID' )>
		<cfset controller( 'setup.setAccount' )>
		<cfset controller( 'setup.setPolicyID' )>
		<cfset controller( 'setup.setPolicy' )>
		<cfset request.context.Group = (StructKeyExists(request.context, 'Group') ? request.context.Group : '')>

	</cffunction>

	<cffunction name="onRequestEnd">

	</cffunction>
	
</cfcomponent>