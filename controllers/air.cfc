<cfcomponent>

	<cfset variables.fw = "">
	<cffunction name="init" output="false" returntype="any">
		<cfargument name="fw">
		<cfset variables.fw = arguments.fw>
		<cfreturn this>
	</cffunction>
	
<!--- lowfare --->
	<cffunction name="lowfare" output="false">
		<cfargument name="rc">
		
		<cfset rc.nStart = getTickCount()>
		<cfset rc.sAPIAuth = application.sAPIAuth>
		<cfset rc.nSearchID = url.Search_ID>
		<cfset rc.stAccount = application.stAccounts[session.Acct_ID]>
		<cfif NOT StructKeyExists(session.searches, url.Search_ID)>
			<cfset variables.fw.redirect('main?Search_ID=#url.Search_ID#')>
		</cfif>
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

<!--- price --->
	<cffunction name="price" output="false">
		<cfargument name="rc">
		<!--- Not used in production.  Just a wrapper to test the ajax call for pricing one itinerary. --->
		
		<cfset rc.nStart = getTickCount()>
		<cfset rc.Search_ID = url.nSearchID>
		<cfset variables.fw.service('airprice.doAirPriceTesting', 'void')>
				
		<cfreturn />
	</cffunction>
	<cffunction name="endairprice" output="false">
		<cfargument name="rc">
		
		<cfset rc.nTimer = (getTickCount()-rc.nStart)>
		
		<cfreturn />
	</cffunction>
	
<!--- availability --->
	<cffunction name="availability" access="public" output="true">
		<cfargument name="rc">
		
		<cfset rc.nStart = getTickCount()>
		<cfset rc.sAPIAuth = application.sAPIAuth>
		<cfset rc.nSearchID = url.Search_ID>
		<cfset rc.stAccount = application.stAccounts[session.Acct_ID]>
		<cfif NOT StructKeyExists(session.searches, url.Search_ID)>
			<cfset variables.fw.redirect('main?Search_ID=#url.Search_ID#')>
		</cfif>
		<cfset rc.stPolicy = application.stPolicies[session.searches[url.Search_ID].Policy_ID]>
		<cfif StructKeyExists(rc, 'bReloadAir')>
			<cfset session.searches[rc.nSearchID].stAvailability = {}>
		</cfif>
		<cfset variables.fw.service('airavailability.doAirAvailability', 'void')>
		
		<cfreturn />
	</cffunction>
	<cffunction name="endavailability" output="false">
		<cfargument name="rc">
		
		<cfset rc.nTimer = (getTickCount()-rc.nStart)>
		
		<cfreturn />
	</cffunction>
	
<!--- close --->
	<cffunction name="close" output="false">
		<cfargument name="rc">
		
		<cfset rc.nSearchID = url.Search_ID>
		<cfset variables.fw.service('security.close', 'void')>
				
		<cfreturn />
	</cffunction>
	
	<cffunction name="endclose" output="false">
		<cfargument name="rc">
		
		<cfset variables.fw.redirect('air.lowfare?Search_ID=#rc.nSearchID#')>
		
		<cfreturn />
	</cffunction>
	
</cfcomponent>