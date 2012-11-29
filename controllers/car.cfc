<cfcomponent>

	<cfset variables.fw = "">
	<cffunction name="init" output="false" returntype="any">
		<cfargument name="fw">
		<cfset variables.fw = arguments.fw>
		<cfreturn this>
	</cffunction>
	
<!--- before --->
	<cffunction name="before" output="false">
		<cfargument name="rc">
		
		<cfif NOT StructKeyExists(session.searches, url.Search_ID)>
			<cfset variables.fw.redirect('main?Search_ID=#url.Search_ID#')>
		</cfif>
		<cfset rc.nSearchID = url.Search_ID>
		<cfset rc.stAccount = application.stAccounts[session.Acct_ID]>
		<cfset rc.stPolicy = application.stPolicies[session.searches[url.Search_ID].nPolicyID]>
		<cfif StructKeyExists(rc, 'bReloadCar')>
			<cfset session.searches[rc.nSearchID].stCars = {}>
		</cfif>
				
		<cfreturn />
	</cffunction>
	
<!--- availability --->
	<cffunction name="availability" output="false">
		<cfargument name="rc">
		
		<cfset variables.fw.service('car.doAvailability', 'void')>
				
		<cfreturn />
	</cffunction>
	
<!--- locations --->
	<cffunction name="locations" output="false">
		<cfargument name="rc">
		
		<cfset variables.fw.service('locations.doLocations', 'stLocations')>
				
		<cfreturn />
	</cffunction>
	
</cfcomponent>