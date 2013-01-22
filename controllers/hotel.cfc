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
		
		<cfif NOT structKeyExists(rc, 'bSelect')>
			<cfif NOT StructKeyExists(session, 'searches')
			OR NOT StructKeyExists(session.searches, rc.nSearchID)>
				<cfset variables.fw.redirect('main?Search_ID=#rc.nSearchID#') />
			</cfif>
			<cfset rc.stPolicy = application.stPolicies[session.searches[rc.nSearchID].nPolicyID] />
			<cfif StructKeyExists(rc, 'bReloadHotel')>
				
			</cfif>
			<cfset variables.fw.service('hotelsearch.doHotelSearch', 'void') />
		<cfelse>
			<!--- Select --->
			<cfset variables.fw.service('hotelsearch.selectHotel', 'void')>
		</cfif>
				
		<cfreturn />
	</cffunction>
	<cffunction name="endsearch" output="false">
		<cfargument name="rc">

		<cfif structKeyExists(arguments.rc, 'bSelect')>
			<cfif session.searches[arguments.rc.Search_ID].bCar
			AND NOT StructKeyExists(session.searches[arguments.rc.Search_ID].stItinerary, 'Car')>
				<cfset variables.fw.redirect('car.availability?Search_ID=#arguments.rc.Search_ID#')>
			</cfif>
			<cfset variables.fw.redirect('summary?Search_ID=#arguments.rc.Search_ID#')>
		</cfif>

		<cfreturn />
	</cffunction>
	
<!--- skip --->
	<cffunction name="skip" output="false">
		<cfargument name="rc" />
		
		<cfset variables.fw.service('hotelsearch.skipHotel', 'void')>
				
		<cfreturn />
	</cffunction>
	<cffunction name="endskip" output="false">
		<cfargument name="rc">

		<cfif session.searches[arguments.rc.Search_ID].bCar
		AND NOT StructKeyExists(session.searches[arguments.rc.Search_ID].stItinerary, 'Car')>
			<cfset variables.fw.redirect('car.availability?Search_ID=#arguments.rc.Search_ID#')>
		</cfif>
		<cfset variables.fw.redirect('summary?Search_ID=#arguments.rc.Search_ID#')>

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