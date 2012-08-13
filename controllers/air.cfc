<cfcomponent>

	<cfset variables.fw = "">
	<cffunction name="init" output="false" returntype="any">
		<cfargument name="fw">
		<cfset variables.fw = arguments.fw>
		<cfreturn this>
	</cffunction>

<!--- air : lowfare --->
	<cffunction name="lowfare" output="false">
		<cfargument name="rc">
		
		<cfif NOT StructKeyExists(session.searches, request.context.Search_ID)>
			<cfset variables.fw.service('session.search', 'void')>
		</cfif>
		<cfif StructKeyExists(request.context, 'reloadair')>
			<cfset session.searches[request.context.Search_ID].Air_Status = 0>
		</cfif>
		
		<cfset variables.fw.service('policy.policyair', 'policyair')>
		<cfset variables.fw.service('policy.preferredair', 'preferredair')>
		
		<cfset variables.fw.service('airfare.doSearch', 'void')>
		
		<cfset variables.fw.service('airfare.parse', 'void')>
		<cfset variables.fw.service('air.policy', 'stSegments')>
		
		<cfreturn />
	</cffunction>

<!--- air : availability --->
	<cffunction name="availability" access="public" output="true">
		<cfargument name="rc">
		
		<cfset variables.fw.service('policy.policyair', 'policyair')>
		<cfset variables.fw.service('policy.preferredair', 'preferredair')>
		<cfset variables.fw.service('airavailability.AirAvailablity', 'message')>
		<cfset variables.fw.service('uapi.call', 'masterXML')>
		<cfset variables.fw.service('airparse.formatXML', 'masterXML')>
		<cfset variables.fw.service('airparse.searchkey', 'Search_Key')>
		<cfset variables.fw.service('airparse.dbsegments', 'strAirSegments')>
		<cfset variables.fw.service('airparse.dbtripsshell', 'void')>
		<cfset variables.fw.service('air.backfill', 'void')>
		<cfset variables.fw.service('air.results', 'results')>
		
		<cfreturn />
	</cffunction>
	
</cfcomponent>