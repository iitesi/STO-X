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
		
		<cfif NOT structKeyExists(rc, 'bSelect')>
			<cfset variables.fw.service('car.doAvailability', 'void')>
		<cfelse>
			<!--- Select --->
			<cfset variables.fw.service('car.selectCar', 'void')>
		</cfif>

		<cfreturn />
	</cffunction>
	<cffunction name="endavailability" output="false">
		<cfargument name="Filter">
		<cfargument name="bSelect">

		<cfif structKeyExists(arguments.Filter, 'bSelect')>
			<cfif arguments.Filter.getHotel()
			AND NOT StructKeyExists(session.searches[arguments.Filter.getSearchID()].stItinerary, 'Hotel')>
				<cfset variables.fw.redirect('hotel.search?SearchID=#session.searches[arguments.Filter.getSearchID()#')>
			</cfif>
			<cfset variables.fw.redirect('summary?SearchID=#session.searches[arguments.Filter.getSearchID()#')>
		</cfif>

		<cfreturn />
	</cffunction>
	
<!--- locations --->
	<cffunction name="locations" output="false">
		<cfargument name="rc">
		
		<cfset variables.fw.service('locations.doLocations', 'stLocations')>
				
		<cfreturn />
	</cffunction>
	
</cfcomponent>