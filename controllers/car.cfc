<cfcomponent extends="abstract">

	<cffunction name="availability" output="false">
		<cfargument name="rc">

		<cfparam name="rc.pickUpLocationKey" default="">
		<cfparam name="rc.dropOffLocationKey" default="">

		<cfif rc.pickUpLocationKey NEQ ''>
			<cfset rc.pickUpLocation = session.searches[rc.searchID].vehicleLocations[rc.Filter.getCarPickUpAirport()][rc.pickUpLocationKey]>
		<cfelse>
			<cfset rc.pickUpLocation = ''>
		</cfif>
		<cfif rc.Filter.getCarDifferentLocations()
			AND rc.dropOffLocationKey NEQ ''>
			<cfset rc.dropOffLocation = session.searches[rc.searchID].vehicleLocations[rc.Filter.getCarDropOffAirport()][rc.dropOffLocationKey]>
		<cfelseif NOT rc.Filter.getCarDifferentLocations()>
			<cfset rc.dropOffLocation = rc.pickUpLocation>
		<cfelse>
			<cfset rc.dropOffLocation = ''>
		</cfif>

		<cfif (rc.acctID EQ 254 OR rc.acctID EQ 255) AND (NOT structKeyExists(application, 'stAirports') OR structIsEmpty(application.stAirports))>
			<cfset fw.getBeanFactory().getBean('setup').setAirports() />
		</cfif>

		<cfif NOT structKeyExists(arguments.rc, 'bSelect')>

			<cfset rc.sPriority = 'HIGH'>
			<cfset fw.getBeanFactory().getBean('car').doAvailability( argumentcollection = arguments.rc )>
			<!--- Below two lines used for populating the change search form. --->
			<cfset arguments.rc.search = fw.getBeanFactory().getBean( "SearchService" ).load( arguments.rc.searchId ) />
			<cfset arguments.rc.formData = fw.getBeanFactory().getBean('car').getSearchCriteria( argumentcollection = arguments.rc ) />
		<cfelse>
			<!--- Move over the information into the stItinerary --->
			<cfset local.vehicle = fw.getBeanFactory().getBean('VehicleAdapter').load( session.searches[rc.SearchID].stCars[rc.sCategory][rc.sVendor] )>
			<cfif rc.pickUpLocationKey NEQ ''>
				<cfset local.vehicle.setPickUpLocationType( '#rc.pickUpLocation.locationType#' )>
				<cfset local.vehicle.setPickUpLocationID( '#rc.pickUpLocation.vendorLocationID#' )>
			<cfelse>
				<cfset local.vehicle.setPickUpLocationType( '#rc.pickUpLocationType#' )>
				<cfset local.vehicle.setPickUpLocationID( '#rc.pickUpLocationKey#' )>
			</cfif>
			<cfif rc.dropOffLocationKey NEQ ''>
				<cfset local.vehicle.setDropOffLocationType( '#rc.dropOffLocation.locationType#' )>
				<cfset local.vehicle.setDropOffLocationID( '#rc.dropOffLocation.vendorLocationID#' )>
			<cfelse>
				<cfset local.vehicle.setDropOffLocationType( '#rc.dropOffLocationType#' )>
				<cfset local.vehicle.setDropOffLocationID( '#rc.dropOffLocationKey#' )>
			</cfif>
			<cfset local.vehicle.setVendorCode( rc.sVendor )>
			<cfset local.vehicle = Vehicle.setVendorCode( rc.sVendor )>
			<cfset session.searches[rc.SearchID].stItinerary.Vehicle = local.vehicle>
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
			<cfset variables.fw.redirect("hotel.search?SearchID=#arguments.rc.searchID#") />
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