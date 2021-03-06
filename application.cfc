<cfcomponent extends="org.corfield.framework">

	<cfscript>
		this.name = "booking_" & hash(getCurrentTemplatePath());
		this.mappings["booking"] = getDirectoryFromPath(getCurrentTemplatePath());
		this.sessionManagement = true;
		this.applicationManagement = true;

		variables.framework = {
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
			reloadApplicationOnEveryRequest = (cgi.server_name EQ 'r.local' ? true : false),
			SESOmitIndex = false,
			siteWideLayoutSubsystem = 'common',
			subsystemDelimiter = ':',
			suppressImplicitService = true,
			trace = false,
			unhandledExtensions = 'cfc',
			unhandledPaths = '/external',
			usingSubsystems = false
		};
	</cfscript>

	<cffunction name="setupApplication">

		<cfset local.bf = createObject('component','coldspring.beans.DefaultXmlBeanFactory').init(defaultProperties = { currentServerName=cgi.server_name })/>
		<cfset bf.loadBeans( expandPath('/booking/config/coldspring.xml'))/>
		<cfset setBeanFactory(bf)/>
		<cfset controller('setup.setApplication')/>
		<cfset setupApplicationVariables()/>

	</cffunction>

	<cffunction name="setupSession">

		<cfset session.searches = {}/>
		<cfset session.filters = {}/>
		<cfset session.aMessages = []/>
		<cfset controller('setup.setAcctID')/>
		<cfset controller('setup.setAccount')/>

	</cffunction>

	<cffunction name="setupRequest">

		<cfif NOT IsAppInitted()>
			<cfset setupApplication()/>
		</cfif>

		<!--- FindIt request rediredted w/ token --->
		<cfif (request.context.action EQ "findIt.default"
				AND structKeyExists(url,"t"))
				AND structKeyExists(url,"searchId")
				AND (NOT structKeyExists(session, "IsAuthorized")
					OR (structKeyExists(session, "IsAuthorized")
						AND session.IsAuthorized EQ false))>
			<cfset session.SearchId = url.SearchId/> 
			<cfset var authService = getBeanFactory().getBean('AuthService').authenticate(
				redirectOnSuccesstUrl = '/booking/index.cfm?#cgi.query_string#'
			)/>
		<!--- C1 FindIt request w/o token (not yet acquired via SSO) --->
		<cfelseif (structKeyExists(url, "acctId") AND url.acctId EQ 581)
			AND (request.context.action EQ "findIt.default"
			AND NOT structKeyExists(url,"t"))
			AND structKeyExists(url,"searchId")
			AND (NOT structKeyExists(session, "IsAuthorized")
				OR (structKeyExists(session, "IsAuthorized")
					AND session.IsAuthorized EQ false))>
			<cfset var returnUrl = URLEncodedFormat("https://sto.shortstravel.com/booking/index.cfm?#cgi.query_string#")/>
			<cflocation url="https://authentication01.shortstravel.com/CapitalOne?ReturnUrl=#returnUrl#" addtoken="false"/>
		<!--- already signed in and requesting FindIt --->
		<cfelseif request.context.action EQ "findIt.default" 
			AND structKeyExists(url,"searchId")
			AND (structKeyExists(session, "IsAuthorized")
					AND session.IsAuthorized EQ true)>
			<cfset session.SearchId = url.searchId/>
		</cfif>

		<cfif structKeyExists(session, "isAuthorized") AND session.isAuthorized EQ True
			AND structKeyExists(session, "StmUserToken") AND session.StmUserToken NEQ "">
			<cfset request.krakenService = getBeanFactory().getBean("KrakenService")/>
			<cfset request.tokenResponse = request.krakenService.refreshToken(session.StmUserToken)/>
			<cfif request.tokenResponse.IsValid EQ True>
				<cfset session.StmUserToken = request.tokenResponse.StmUserToken/>
			</cfif>
		</cfif>

		<cfif NOT structKeyExists(request.context, 'additionalFooterJS')>
			<cfscript>
				request.context.additionalFooterJS = arrayNew(1);
			</cfscript>
		</cfif>

		<cfif listFind("main.logout,main.login,oauth.login",request.context.action)>
			<cfset controller('setup.setAcctID')/>
			<cfset controller('setup.setAccount')/>
		<cfelse>
			
			<cfset var actionList = 'main.notfound,main.menu,main.trips,main.search,main.contact,main.releasenotes,setup.resetPolicy,setup.setPolicy'>

			<cfif (NOT structKeyExists(request.context, 'SearchID')
				OR NOT isNumeric(request.context.searchID))
				AND !ListFind(local.actionList, request.context.action)>

				<cfset var action = ListFirst(request.context.action,".")>
				<cflocation url="#buildURL( "main.notfound" )#" addtoken="false">

			<cfelse>

				<cfset application.fw.factory.getBean("setup").authorizeRequest(request)>
				<cfset controller('setup.setSearchID')/>
				<cfset controller('setup.setFilter')/>
				<cfset controller('setup.setAcctID')/>
				<cfset controller('setup.setAccount')/>
				<cfset controller('setup.setTMC')/>
				<cfset controller('setup.setPolicyID')/>
				<cfset controller('setup.setPolicy')/>
				<cfset controller('setup.setGroup')/>
				<cfset controller('setup.setAccountIds')/>
				<cfset controller('setup.setInvoiceTableSuffix')/>

			</cfif>
		</cfif>

		<cfset controller('setup.cleanOutOldSearchIDs')/>

	</cffunction>

	<cffunction name="onMissingView" hint="I handle missing views.">
		<cfreturn view( "main/notfound" )>
	</cffunction>

	<cffunction name="onError" returnType="void">

		<cfargument name="Exception" required=true/>
		<cfargument name="EventName" type="String" required=true/>

		<cfset local.acctID = ""/>
		<cfset local.userID = ""/>
		<cfset local.username = ""/>
		<cfset local.department = ""/>
		<cfset local.searchID = ""/>

		<cftry>
			<!--- If the rc scope isn't defined then look a little more to see if we can track down the searchID and pull from the session. --->
			<cfif NOT structKeyExists(arguments, 'rc')
				OR NOT structKeyExists(arguments.rc, 'Filter')>
				<!--- Have to look directly at the url scope as the rc may or may not be defined.  Most likely not. --->
				<cfif (structKeyExists(arguments, 'rc')
					AND structKeyExists(arguments.rc, 'searchID'))
					OR (isDefined("url")
						AND structKeyExists(url, 'searchID'))>
					<!--- Move that searchID into the local scope --->
					<cfif structKeyExists(arguments, 'rc')
						AND structKeyExists(arguments.rc, 'searchID')>
						<cfset local.searchID = arguments.rc.searchID>
					<cfelseif isDefined("url")
						AND structKeyExists(url, 'searchID')>
						<cfset local.searchID = url.searchID>
					</cfif>
					<!--- Check the session for the filter --->
					<cfif structKeyExists(session, 'Filters')
						AND structKeyExists(session.Filters, searchID)>
						<cfset arguments.rc.Filter = session.Filters[searchID]>
					</cfif>
				</cfif>
			</cfif>
			<cfif structKeyExists(arguments, 'rc')
				AND structKeyExists(arguments.rc, 'Filter')>
				<cfset local.acctID = arguments.rc.Filter.getAcctID()>
				<cfset local.userID = arguments.rc.Filter.getUserID()>
				<cfset local.username = arguments.rc.Filter.getUsername()>
				<cfset local.department = arguments.rc.Filter.getDepartment()>
				<cfset local.searchID = arguments.rc.Filter.getSearchID()>
			</cfif>
			<cfcatch>
			</cfcatch>
		</cftry>

		<cfset local.errorException = structNew('linked')>
		<cfset local.errorException = {	acctID = local.acctID
										, userID = local.userID
										, username = local.username
										, department = local.department
										, searchID = local.searchID
										, exception = arguments.exception } >

		<cfif application.fw.factory.getBean('EnvironmentService').getEnableBugLog()>
			 <cfset application.fw.factory.getBean('BugLogService').notifyService( message=arguments.exception.Message, exception=local.errorException, severityCode='Error') />
			 <cfset super.onError( arguments.exception, arguments.eventName )>
		<cfelse>
			 <cfset super.onError( arguments.exception, arguments.eventName )>
		 </cfif>

		<cfif listFindNoCase('local,qa,beta', application.fw.factory.getBean('EnvironmentService').getCurrentEnvironment())>
			<cfdump var="#local.errorException#" />
		</cfif>
	</cffunction>

	<cffunction name="onCFCRequest" access="public" returnType="void" returnformat="plain">
		<cfargument name="cfcname" type="string" required="true">
		<cfargument name="method" type="string" required="true">
		<cfargument name="args" type="struct" required="true">

		<!--- if we are in production - lets check to see where the request is coming from
					if its not one of our servers we'll end things with a 403  --->
		<cfif application.fw.factory.getBean( "EnvironmentService" ).getCurrentEnvironment() EQ 'prod'>
			<cfif NOT (
					findNoCase( "shortstravel.com", cgi.http_referer ) OR
					findNoCase( "shortstravelonline.com", cgi.http_referer ) OR
					findNoCase( "b-hive.com", cgi.http_referer ) OR
					findNoCase( "b-hives.com", cgi.http_referer )
				)>
				<cfheader statusCode="403" statustext="Not Authorized" />
				<cfreturn />
			</cfif>
		</cfif>

		<!--- then we can check if our session.isAuthorized is already set
				  this should have been set in the original request from search
				  again, if this isn't present we'll abort with a 403 --->
		<cfif structKeyExists(session, "isAuthorized") AND session.isAuthorized EQ true>
			<cfinvoke component="#arguments.cfcname#" method="#arguments.method#" argumentcollection="#arguments.args#" returnvariable="local.result">
			<cfif NOT isSimpleValue( local.result )>
				<cfset local.result = serializeJSON( local.result ) />
			</cfif>
			<cfif isJSON( local.result )>
				<cfset local.responseMimeType = "application/json" />
			<cfelse>
				<cfset local.responseMimeType = "application/javascript" />
			</cfif>
			<cfset local.binaryResponse = toBinary(toBase64( local.result )) />
			<cfcontent type="#local.responseMimeType#" variable="#local.binaryResponse#" />
		<cfelse>
			<cfheader statusCode="403" statustext="Not Authorized" />
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="setupApplicationVariables" output="false">
		<cfscript>
			application.gmtOffset = "6:00";
			application.releaseVersion = "4.5.1.6";
			application.staticAssetVersion = application.releaseVersion;
			application.es = getBeanFactory().getBean('EnvironmentService');
		</cfscript>
	</cffunction>

	<cffunction name="IsAppInitted" returntype="boolean">
		<cfscript>
			// seeing missing app vars in the logs, check a few common ones until we can diagnose
			if ((!structKeyExists(application, "stAirports") || structIsEmpty(application.stAirports))
				|| (! structKeyExists(application, "stHotelVendors") || structIsEmpty(application.stHotelVendors))
				|| !structKeyExists(application, "staticAssetVersion")) {
				return false;
			}
			return true;
		</cfscript>
	</cffunction>

</cfcomponent>
