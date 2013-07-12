<cfcomponent extends="abstract">

<!--- availability --->
	<cffunction name="availability" output="false">
		<cfargument name="rc">

		<cfif NOT structKeyExists(arguments.rc, 'bSelect')>
			<cfset rc.sPriority = 'HIGH'>
			<cfset fw.getBeanFactory().getBean('car').doAvailability(argumentcollection=arguments.rc)>
			<!--- Below two lines used for populating the change search form. --->
			<cfset arguments.rc.search = fw.getBeanFactory().getBean( "SearchService" ).load( arguments.rc.searchId ) />
			<cfset arguments.rc.formData = fw.getBeanFactory().getBean('car').getSearchCriteria(argumentcollection=arguments.rc) />
		<cfelse>
			<!--- Move over the information into the stItinerary --->
			<cfset session.searches[rc.SearchID].stItinerary.Vehicle = fw.getBeanFactory().getBean('VehicleAdapter').load( session.searches[rc.SearchID].stCars[rc.sCategory][rc.sVendor] )>
			<cfset session.searches[rc.SearchID].stItinerary.Vehicle = session.searches[rc.SearchID].stItinerary.Vehicle.setVendorCode( rc.sVendor )>
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

<!--- search --->
	<!--- <cffunction name="search" output="false">
		<cfargument name="rc">

		<cfset rc.bSuppress = 1 />

		<cfset arguments.rc.search = fw.getBeanFactory().getBean( "SearchService" ).load( arguments.rc.searchId ) />
		<cfset arguments.rc.formData = fw.getBeanFactory().getBean('car').getSearchCriteria(argumentcollection=arguments.rc) />

		<cfreturn />
	</cffunction> --->

<!--- changeSearch --->
	<!--- <cffunction name="changeSearch" output="false">
		<cfargument name="rc">

		<cfset fw.getBeanFactory().getBean('car').updateSearch(argumentcollection=arguments.rc) />

		<cfreturn />
	</cffunction> --->

</cfcomponent>