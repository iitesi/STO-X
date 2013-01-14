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
		<!--- <cfset void = structdelete(session.searches, 209349)> --->
		<cfset request.context.nSearchID = (StructKeyExists(request.context, 'Search_ID') ? request.context.Search_ID : (StructKeyExists(request.context, 'nSearchID') ? request.context.nSearchID : 0))>
		<cfset request.context.Search_ID = request.context.nSearchID>
		<cfset request.context.nGroup = (StructKeyExists(request.context, 'Group') ? request.context.Group : (StructKeyExists(request.context, 'nGroup') ? request.context.nGroup : ''))>
		<cfset request.context.Group = request.context.nGroup>

		<cfif structKeyExists(url, 'bClear')>
			<cfset session.searches[request.context.nSearchID].stTrips = {}>
			<cfset session.searches[request.context.nSearchID].stLowFareDetails.aSortFare = {}>
			<cfset session.searches[request.context.nSearchID].stLowFareDetails.aSortFare = {}>
			<cfset session.searches[request.context.nSearchID].stAvailTrips = {}>
			<cfset session.searches[request.context.nSearchID].stCars = {}>
			<cfset session.searches[request.context.nSearchID].stTrips = {}>
			<cfset session.searches[request.context.nSearchID].stLowFareDetails = {}>
			<cfset session.searches[request.context.nSearchID].stLowFareDetails.aCarriers = {}>
			<cfset session.searches[request.context.nSearchID].stLowFareDetails.stPricing = {}>
			<cfset session.searches[request.context.nSearchID].stLowFareDetails.stResults = {}>
			<cfset session.searches[request.context.nSearchID].stLowFareDetails.stPriced = {}>
			<cfset session.searches[request.context.nSearchID].stLowFareDetails.aSortArrival = []>
			<cfset session.searches[request.context.nSearchID].stLowFareDetails.aSortBag = []>
			<cfset session.searches[request.context.nSearchID].stLowFareDetails.aSortDepart = []>
			<cfset session.searches[request.context.nSearchID].stLowFareDetails.aSortDuration = []>
			<cfset session.searches[request.context.nSearchID].stLowFareDetails.aSortFare = []>
			<cfset session.searches[request.context.nSearchID].stAvailTrips = {}>
			<cfset session.searches[request.context.nSearchID].stSelected = StructNew('linked')>
			<cfset session.searches[request.context.nSearchID].stSelected[0] = {}>
			<cfset session.searches[request.context.nSearchID].stSelected[1] = {}>
			<cfset session.searches[request.context.nSearchID].stSelected[2] = {}>
			<cfset session.searches[request.context.nSearchID].stSelected[3] = {}>
			<cfset session.searches[request.context.nSearchID].stAvailTrips[0] = {}>
			<cfset session.searches[request.context.nSearchID].stAvailTrips[1] = {}>
			<cfset session.searches[request.context.nSearchID].stAvailTrips[2] = {}>
			<cfset session.searches[request.context.nSearchID].stAvailTrips[3] = {}>
			<cfset session.searches[request.context.nSearchID].stAvailDetails.stGroups = {}>
			<cfset session.searches[request.context.nSearchID].stAvailDetails.stCarriers[0] = []>
			<cfset session.searches[request.context.nSearchID].stAvailDetails.stCarriers[1] = []>
		</cfif>
		
		<cfset application.bDebug = 1>
		<cfset controller( 'setup.setApplication' )>
		<cfset controller( 'setup.setSession' )>
		
	</cffunction>
	
	<cffunction name="onRequestEnd">
		
	</cffunction>
	
</cfcomponent>