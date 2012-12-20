<cfcomponent>

	<cfset variables.fw = '' />
	<cffunction name="init" output="false" returntype="any">
		<cfargument name="fw" />

		<cfset variables.fw = arguments.fw />
		
		<cfreturn this />
	</cffunction>
	
<!--- search --->
	<cffunction name="search" output="false">
		<cfargument name="rc" />
		
		<cfif NOT StructKeyExists(session.searches, rc.nSearchID)>
			<cfset variables.fw.redirect('main?Search_ID=#rc.nSearchID#') />
		</cfif>
		<cfset rc.stPolicy = application.stPolicies[session.searches[rc.nSearchID].nPolicyID] />
		<cfif StructKeyExists(rc, 'bReloadHotel')>
			
		</cfif>
		<cfset variables.fw.service('hotelsearch.doHotelSearch', 'void') />
				
		<cfreturn />
	</cffunction>

<!--- 
HOTELSELECTION
--->
	<cffunction name="hotelSelection" output="false">
		<cfargument name="rc">

		<cfif structKeyExists(rc, 'bSelect')>
			<!--- Select --->
			<cfset variables.fw.service('hotel.selectHotel', 'void')>
		</cfif>

		<cfreturn />
	</cffunction>

<!---
popup
--->	
	<cffunction name="popup" output="true">
		<cfargument name="rc">
		
		<cfset rc.bSuppress = 1>
		
		<cfreturn />
	</cffunction>
	
</cfcomponent>