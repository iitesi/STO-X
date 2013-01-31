<cfcomponent extends="org.corfield.framework">
	
	<cfset this.name = 'booking8'>
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

	</cffunction>
	
	<cffunction name="setupRequest">

		<cfset controller( 'setup.setSession' )>

		<!---Set some default variables that are used throughout the site.--->
		<cfset request.context.SearchID = (StructKeyExists(request.context, 'SearchID') ? request.context.SearchID : 0)>
		<cfset request.context.Group = (StructKeyExists(request.context, 'Group') ? request.context.Group : '')>

		<!---Redirect the site if the search hasn't been loaded yet.--->
		<cfif (NOT StructKeyExists(session, 'searches')
		OR NOT StructKeyExists(session.searches, request.context.SearchID))
		AND request.context.action NEQ 'main.default'>
			<cfset redirect('main?SearchID=#request.context.SearchID#')>
		</cfif>

		<!---Always defined.  Filter, Account & Policy for the given SearchID passed in.--->
		<cfset request.context.Filter = (StructKeyExists(session, 'filters') AND StructKeyExists(session.filters, request.context.SearchID) ? session.filters[request.context.SearchID] : '')>

		<cfif StructKeyExists(session, 'AcctID')>
			<cfset request.context.Account = (StructKeyExists(application, 'Accounts') AND StructKeyExists(application.Accounts, session.AcctID) ? application.Accounts[session.AcctID] : '')>
			<cfset request.context.Policy = (StructKeyExists(application, 'Policies') AND StructKeyExists(application.Policies, session.PolicyID) ? application.Policies[session.PolicyID] : '')>
		</cfif>
	</cffunction>
	
	<cffunction name="onRequestEnd">

	</cffunction>
	
</cfcomponent>