<cfcomponent>

	<cfset variables.fw = '' />
	<cffunction name="init" output="false" returntype="any">
		<cfargument name="fw" />

		<cfset variables.fw = arguments.fw />
		
		<cfreturn this />
	</cffunction>
	
<!--- search --->
	<cffunction name="search" output="false">
		<cfargument name="Filter" />
		<cfargument name="bSelect" />
		<cfargument name="bReloadHotel" />
		
		<cfif NOT structKeyExists(arguments, 'bSelect')>
			<cfset rc.stPolicy = application.stPolicies[arguments.Filter.getPolicyID()] />
			<cfif StructKeyExists(arguments, 'bReloadHotel')>
				
			</cfif>
			<cfset variables.fw.service('hotelsearch.doHotelSearch', 'void') />
		<cfelse>
			<!--- Select --->
			<cfset variables.fw.service('hotelsearch.selectHotel', 'void')>
		</cfif>
				
		<cfreturn />
	</cffunction>
	<cffunction name="endsearch" output="false">
		<cfargument name="Filter" />
		<cfargument name="bSelect" />

		<cfif structKeyExists(arguments, 'bSelect')>
			<cfif arguments.Filter.getCar()
			AND NOT StructKeyExists(session.searches[arguments.Filter.getSearchID()].stItinerary, 'Car')>
				<cfset variables.fw.redirect('car.availability?Search_ID=#arguments.Filter.getSearchID()#')>
			</cfif>
			<cfset variables.fw.redirect('summary?Search_ID=#arguments.Filter.getSearchID()#')>
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
		<cfargument name="Filter">

		<cfif arguments.Filter.getCar()
		AND NOT StructKeyExists(session.searches[arguments.Filter.getSearchID()].stItinerary, 'Car')>
			<cfset variables.fw.redirect('car.availability?Search_ID=#arguments.Filter.getSearchID()#')>
		</cfif>
		<cfset variables.fw.redirect('summary?Search_ID=#arguments.Filter.getSearchID()#')>

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