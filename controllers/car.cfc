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
		
		<cfif NOT structKeyExists(arguments.rc, 'bSelect')>
			<cfset rc.sPriority = 'HIGH'>
			<cfset fw.getBeanFactory().getBean('car').doAvailability(argumentcollection=arguments.rc)>
		<cfelse>
			<cfset fw.getBeanFactory().getBean('car').selectCar(argumentcollection=arguments.rc)>
		</cfif>

		<cfreturn />
	</cffunction>
	<cffunction name="endavailability" output="false">
		<cfargument name="rc">

		<cfif structKeyExists(arguments.rc, 'bSelect')>
			<cfif arguments.rc.Filter.getHotel()
			AND NOT StructKeyExists(session.searches[arguments.rc.SearchID].stItinerary, 'Hotel')>
				<cfset variables.fw.redirect('hotel.search?SearchID=#arguments.rc.SearchID#')>
			</cfif>
			<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.SearchID#')>
		</cfif>

		<cfreturn />
	</cffunction>
	
</cfcomponent>