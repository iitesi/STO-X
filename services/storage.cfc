<cfcomponent output="false" accessors="true">

	<cfproperty name="BookingDSN" />
	<cfproperty name="StorageLocation" />
	<cfproperty name="Requery" />

	<cffunction name="init" returntype="any" access="public" output="false">
		<cfargument name="BookingDSN" type="any" required="true"/>

		<cfset setBookingDSN( arguments.BookingDSN ) />
		<cfset setStorageLocation('Session') /><!--- Session or Database --->
		<cfset setRequery(false) /><!--- True or false--->

		<cfreturn this />
	</cffunction>

	<cffunction name="getStorage" returntype="any" access="public" output="false">
		<cfargument name="searchID" required="true" type="numeric">
		<cfargument name="request" required="true" type="any">

		<cfparam name="session.storage[#arguments.searchID#]" default="#structNew()#">

		<cfset local.response = structNew()>
		<cfset local.key = getKey(request = arguments.request)>

		<cfif structKeyExists(session.storage[arguments.searchID], local.key)
			AND NOT getRequery()>

			<cfif getStorageLocation() EQ 'Database'>

				<cfquery name="local.getJSON" datasource="#getBookingDSN()#">
					SELECT Payload
					FROM SearchData
					WHERE SearchId = #arguments.searchID#
						AND SearchToken = '#local.key#'
				</cfquery>

				<cfif local.getJSON.recordCount EQ 1>
					<cfset local.response = deserializeJSON(local.getJSON.Payload)>
				</cfif>

			<cfelseif getStorageLocation() EQ 'Session'>
				<cfset local.response = deserializeJSON(session.storage[arguments.searchID][local.key])>
			</cfif>
			
		</cfif>

		<cfreturn local.response />
	</cffunction>

	<cffunction name="store" returntype="any" access="public" output="false">
		<cfargument name="searchID" required="true" type="numeric">
		<cfargument name="request" required="true" type="any">
		<cfargument name="storage" required="true" type="any">

		<cfset local.key = getKey(	request = arguments.request )>

		<cfif getStorageLocation() EQ 'Database'>

			<cfquery datasource="#getBookingDSN()#">
				INSERT INTO SearchData
					( SearchId
					, SearchSegmentTypeId
					, SearchToken
					, Payload )
				VALUES
					( #arguments.searchID#
					, 1
					, '#local.key#'
					, '#serializeJSON(arguments.storage)#' )
			</cfquery>
			
			<cfset session.storage[arguments.searchID][local.key] = ''>
			
		<cfelse>
			<cfset session.storage[arguments.searchID][local.key] = serializeJSON(arguments.storage)>
		</cfif>

		<cfreturn true />
	</cffunction>

	<cffunction name="getKey" returntype="any" access="public" output="false">
		<cfargument name="request" required="true" type="any">

		<cfreturn hash(serializeJSON(arguments.request)) />
	</cffunction>

</cfcomponent>