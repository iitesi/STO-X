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
		
		<cfset rc.nStart = getTickCount()>
		<cfset rc.sAPIAuth = application.sAPIAuth>
		<cfset rc.nSearchID = url.Search_ID>
		<cfset rc.stAccount = application.stAccounts[session.Acct_ID]>
		<cfset rc.stPolicy = application.stPolicies[session.searches[url.Search_ID].Policy_ID]>
		<cfif StructKeyExists(rc, 'bReloadAir')>
			<cfset session.searches[rc.nSearchID].Pricing = {}>
			<cfset session.searches[rc.nSearchID].stTrips = {}>
			<cfset session.searches[rc.nSearchID].stSegments = {}>
		</cfif>
		<cfset variables.fw.service('lowfare.doLowFare', 'void')>
				
		<cfreturn />
	</cffunction>
	
	<cffunction name="endlowfare" output="false">
		<cfargument name="rc">
		
		<cfset rc.nTimer = (getTickCount()-rc.nStart)>
		
		<cfreturn />
	</cffunction>

<!--- air : airprice --->
	<cffunction name="price" output="false">
		<cfargument name="rc">
		
		<cfset rc.nStart = getTickCount()>
		<cfset rc.sAPIAuth = application.sAPIAuth>
		<cfset rc.nSearchID = url.Search_ID>
		<cfset rc.stPolicy = application.stPolicies[session.Acct_ID]>
		<cfset variables.fw.service('airprice.doAirPrice', 'void')>
				
		<cfreturn />
	</cffunction>
	
	<cffunction name="endairprice" output="false">
		<cfargument name="rc">
		
		<cfset rc.nTimer = (getTickCount()-rc.nStart)>
		
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