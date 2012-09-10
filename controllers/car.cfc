<cfcomponent>

	<cfset variables.fw = "">
	<cffunction name="init" output="false" returntype="any">
		<cfargument name="fw">
		<cfset variables.fw = arguments.fw>
		<cfreturn this>
	</cffunction>
	
<!--- availability --->
	<cffunction name="availability" output="false">
		<cfargument name="rc">
		
		<cfset rc.nStart = getTickCount()>
		<cfset rc.sAPIAuth = application.sAPIAuth>
		<cfset rc.nSearchID = url.Search_ID>
		<cfset rc.stAccount = application.stAccounts[session.Acct_ID]>
		<cfif NOT StructKeyExists(session.searches, url.Search_ID)>
			<cfset variables.fw.redirect('main?Search_ID=#url.Search_ID#')>
		</cfif>
		<cfset rc.stPolicy = application.stPolicies[session.searches[url.Search_ID].Policy_ID]>
		<cfif StructKeyExists(rc, 'bReloadCar')>
			<cfset session.searches[rc.nSearchID].stCars = {}>
		</cfif>
		<cfset variables.fw.service('car.doAvailability', 'void')>
				
		<cfreturn />
	</cffunction>
	<cffunction name="endavailability" output="false">
		<cfargument name="rc">
		
		<cfset rc.nTimer = (getTickCount()-rc.nStart)>
		
		<cfreturn />
	</cffunction>
	
<!--- locations --->
	<cffunction name="locations" output="false">
		<cfargument name="rc">
		
		<cfset rc.nStart = getTickCount()>
		<cfset rc.sAPIAuth = application.sAPIAuth>
		<cfset rc.nSearchID = url.Search_ID>
		<cfif NOT StructKeyExists(session.searches, url.Search_ID)>
			<cfset variables.fw.redirect('main?Search_ID=#url.Search_ID#')>
		</cfif>
		<cfset variables.fw.service('locations.doLocations', 'stLocations')>
				
		<cfreturn />
	</cffunction>
	<cffunction name="endlocations" output="false">
		<cfargument name="rc">
		
		<cfset rc.nTimer = (getTickCount()-rc.nStart)>
		
		<cfreturn />
	</cffunction>
	
</cfcomponent>