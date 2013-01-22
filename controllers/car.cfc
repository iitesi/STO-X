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
		
		<cfif NOT StructKeyExists(session, 'searches')
		OR NOT StructKeyExists(session.searches, rc.nSearchID)>
			<cfset variables.fw.redirect('main?Search_ID=#url.Search_ID#')>
		</cfif>
		<cfif StructKeyExists(rc, 'bReloadCar')>
			<cfset session.searches[rc.nSearchID].stCars = {}>
		</cfif>
				
		<cfreturn />
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
		<cfargument name="rc">

		<cfif structKeyExists(arguments.rc, 'bSelect')>
			<cfif session.searches[arguments.rc.Search_ID].bHotel
			AND NOT StructKeyExists(session.searches[arguments.rc.Search_ID].stItinerary, 'Hotel')>
				<cfset variables.fw.redirect('hotel.search?Search_ID=#arguments.rc.Search_ID#')>
			</cfif>
			<cfset variables.fw.redirect('summary?Search_ID=#arguments.rc.Search_ID#')>
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