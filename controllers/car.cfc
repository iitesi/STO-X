<cfcomponent extends="abstract">

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

			<cfif application.Accounts[ arguments.rc.Filter.getAcctID() ].couldYou EQ 1>
				<cfset variables.fw.redirect('couldYou?SearchID=#arguments.rc.Filter.getSearchID()#')>
			</cfif>

			<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.SearchID#')>
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="skip" output="false">
		<cfargument name="rc">

		<cfset arguments.rc.Filter.setCar(0) />
		<cfset variables.bf.getBean("SearchService").save(searchID=arguments.rc.searchID, car=0) />

		<cfif structKeyExists(session.searches[arguments.rc.searchID].stItinerary, "Vehicle")>
			<cfset structDelete(session.searches[arguments.rc.searchID].stItinerary, "Vehicle") />
		</cfif>
		<cfif structKeyExists(session.searches[arguments.rc.searchID], "stCars")>
			<cfset structDelete(session.searches[arguments.rc.searchID], "stCars") />
		</cfif>
		<cfif structKeyExists(session.searches[arguments.rc.searchID], "CouldYou") AND structKeyExists(session.searches[arguments.rc.searchID].CouldYou, "Car")>
			<cfset structDelete(session.searches[arguments.rc.searchID].CouldYou, "Car") />
		</cfif>

		<cfif arguments.rc.Filter.getHotel() AND NOT StructKeyExists(session.searches[arguments.rc.searchID].stItinerary, "Hotel")>
			<cfset variables.fw.redirect("hotel.availability?SearchID=#arguments.rc.searchID#") />
		<cfelseif arguments.rc.Filter.getHotel()
			AND StructKeyExists(session.searches[arguments.rc.searchID].stItinerary, "Hotel")
			AND application.accounts[arguments.rc.Filter.getAcctID()].couldYou EQ 1>

			<cfset variables.fw.redirect("couldyou?SearchID=#arguments.rc.searchID#") />
		<cfelseif NOT arguments.rc.Filter.getHotel() AND application.accounts[arguments.rc.Filter.getAcctID()].couldYou EQ 1>
			<cfset variables.fw.redirect("couldyou?SearchID=#arguments.rc.searchID#") />
		<cfelse>
			<cfset variables.fw.redirect("summary?SearchID=#arguments.rc.searchID#") />
		</cfif>

		<cfreturn />
	</cffunction>
</cfcomponent>