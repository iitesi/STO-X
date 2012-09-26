<cfcomponent>

	<cfset variables.fw = "">
	<cffunction name="init" output="false" returntype="any">
		<cfargument name="fw">
		<cfset variables.fw = arguments.fw>
		<cfreturn this>
	</cffunction>
	
<!--- search --->
	<cffunction name="search" output="false">
		<cfargument name="rc">
		
		<cfset rc.nSearchID = url.Search_ID>
		<cfif NOT StructKeyExists(session.searches, url.Search_ID)>
			<cfset variables.fw.redirect('main?Search_ID=#url.Search_ID#')>
		</cfif>
		<cfset rc.stPolicy = application.stPolicies[session.searches[url.Search_ID].Policy_ID]>
		<cfif StructKeyExists(rc, 'bReloadHotel')>
			
		</cfif>
		<cfset variables.fw.service('hotelsearch.doHotelSearch', 'void')>
				
		<cfreturn />
	</cffunction>
	
</cfcomponent>