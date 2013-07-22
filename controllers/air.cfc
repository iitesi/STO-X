<cfcomponent extends="abstract" accessors="true">

	<!--- // DEPENDENCY INJECTION --->
	<cfproperty name="general" setter="true" getter="false">


	<cffunction name="lowfare" output="false" hint="I assemble low fares for display.">
		<cfargument name="rc">

		<cfif structKeyExists(arguments.rc, "airlines") AND arguments.rc.airlines EQ 1>
			<cfset rc.filter.setAirlines("")>
		</cfif>

    	<cfif NOT structKeyExists(arguments.rc, 'bSelect')>
    	<!--- throw out threads and get lowfare pricing --->
			<cfset fw.getBeanFactory().getBean('airavailability').threadAvailability(argumentcollection=arguments.rc)>
			<cfset rc.stPricing = session.searches[arguments.rc.SearchID].stLowFareDetails.stPricing>
			<cfset fw.getBeanFactory().getBean('lowfare').threadLowFare(argumentcollection=arguments.rc)>
		<cfelse>
			<cfset fw.getBeanFactory().getBean('lowfare').selectAir(argumentcollection=arguments.rc)>
		</cfif>

		<!--- Setup some session flags to save if the user has clicked on any of the "find more " links in the filter --->
		<cfset checkFilterStatus(arguments.rc)>
		<cfset rc.totalFlights = getTotalFlights(arguments.rc)>

		<cfif structKeyExists(arguments.rc, 'bSelect')>

			<!--- if they click the buy button - remove other flights from the session --->
			<cfset removeOtherFlights(arguments.rc)>

			<cfif arguments.rc.Filter.getHotel()
				AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Vehicle')>
				<cfset variables.fw.redirect('hotel.search?SearchID=#arguments.rc.Filter.getSearchID()#')>
			</cfif>
			<cfif arguments.rc.Filter.getCar()
				AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Car')>
				<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.Filter.getSearchID()#')>
			</cfif>
			<cfif application.Accounts[ arguments.rc.Filter.getAcctID() ].couldYou EQ 1>
				<cfset variables.fw.redirect('couldYou?SearchID=#arguments.rc.Filter.getSearchID()#')>
			</cfif>
			<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="availability" output="true" hint="I get info on legs when button is clicked on search results.">
		<cfargument name="rc">

		<cfif NOT structKeyExists(arguments.rc, 'bSelect')>
			<cfset arguments.rc.sPriority = 'LOW'>
			<!--- Throw out a threads and get availability --->
			<cfset fw.getBeanFactory().getBean('airavailability').threadAvailability(argumentcollection=arguments.rc)>
			<cfset rc.stPricing = session.searches[arguments.rc.SearchID].stLowFareDetails.stPricing>
			<cfset fw.getBeanFactory().getBean('lowfare').threadLowFare(argumentcollection=arguments.rc)>
		<cfelse>
			<!--- Select --->
			<cfset fw.getBeanFactory().getBean('airavailability').selectLeg(argumentcollection=arguments.rc)>
		</cfif>

		<cfset rc.totalFlights = getTotalFlights(arguments.rc)>

		<cfif structKeyExists(arguments.rc, 'bSelect')>
			<cfloop array="#arguments.rc.Filter.getLegs()#" item="local.sLeg" index="local.nLeg">
				<cfif structIsEmpty(session.searches[arguments.rc.SearchID].stSelected[nLeg-1])>
					<cfset variables.fw.redirect('air.availability?SearchID=#arguments.rc.SearchID#&Group=#nLeg-1#')>
				</cfif>
			</cfloop>
			<cfset variables.fw.redirect('air.price?SearchID=#arguments.rc.SearchID#')>
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="price" output="false" hint="I run doAirPrice.">
		<cfargument name="rc">
		<cfset fw.getBeanFactory().getBean('AirPrice').doAirPrice(argumentcollection=arguments.rc)>
		<cfset variables.fw.redirect('air.lowfare?SearchID=#arguments.rc.SearchID#&filter=all')>
		<cfreturn />
	</cffunction>

	<cffunction name="popup" output="true" hint="I get details, seats, bags and for modal popup for each badge.">
		<cfargument name="rc">

				<!--- seatmap --->
				<cfset rc.sCabin = 'Y'>
				<cfset rc.nTripID = arguments.rc.nTripID>
				<cfset variables.fw.service('seatmap.doSeatMap', 'stSeats')>

				<!---details: do nothing --->

				<!--- baggage --->
				<cfset variables.fw.service('baggage.baggage', 'qBaggage')>

				<!--- email --->
				<cfset local.UserID = session.UserID>
				<cfset rc.qUser = variables.general.getUser( local.userID )>
				<cfset local.userId = session.filters[arguments.rc.searchID].getProfileID()>
				<cfset rc.qProfile = variables.general.getUser( local.userID )>

				<cfset variables.fw.setLayout("popup")>
		<cfreturn />
	</cffunction>

	<cffunction name="seatmap" output="true" hint="I get data to make a seat map.">
		<cfargument name="rc">
		<cfset rc.sCabin = 'Y'>
		<cfset rc.nTripID = arguments.rc.nTripID>
		<cfset rc.nSegment = arguments.rc.nSegment>
		<cfset variables.fw.service('seatmap.doSeatMap', 'stSeats')>
		<cfset request.layout = false>
		<cfreturn />
	</cffunction>

	<cffunction name="email" output="true" hint="I send an email">
		<cfargument name="rc">

		<cfset rc.bSuppress = 1>

		<cfset variables.fw.service('email.email', '')> <!--- , 'void' --->

		<cfset rc.message.AddInfo("Your email has been sent.")>
		<cfset variables.fw.redirect('air.lowfare?SearchID=#arguments.rc.SearchID#')>

		<cfreturn />
	</cffunction>

<!--- PRIVATE METHODS --->
	<cffunction name="removeflight" access="private" output="false" hint="I take a searchID and remove a flight from the session.">
		<cfargument name="rc">

		<cfset var result = fw.getBeanFactory().getBean('lowfare').removeFlight( arguments.rc.searchID )>

		<cfif structKeyExists(session, "searches")>
			<cfset newSearchID = ListLast( StructKeyList(session.searches) )>
		</cfif>

		<cfif result IS true>
			<cfset rc.message.AddInfo("Saved search deleted successfully!")>
			<cfset variables.fw.redirect( action="air.lowfare", queryString="searchid=#newSearchID#" )>
		<cfelse>
				<cfthrow message="Error removing a flight from the breadcrumb bar!"/>
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="removeOtherFlights" access="private" output="false" hint="I take a searchID and remove all other flights from the session.">
		<cfargument name="rc">

		<cfset local.flightsToDelete =  StructKeyArray(session.filters)>
		<cfset  ArrayDeleteAt(local.flightsToDelete, ArrayFind(local.flightsToDelete, arguments.rc.searchID))>

		<cfloop array="#local.flightsToDelete#" item="searchID">
			<cfset StructDelete(session.filters, searchID)>
			<cfset StructDelete(session.searches, searchID)>
		</cfloop>

		<cfreturn />
	</cffunction>

	<cffunction name="checkFilterStatus" access="private" output="false" hint="Setup some session flags to save if the user has clicked on any of the 'find more' links in the filter">
		<cfargument name="rc">

		<!--- This could probably be handled better but this works given the time constraints
			4:24 PM Friday, June 28, 2013 - Jim Priest - jpriest@shortstravel.com --->

		<!--- run on first search --->
			<cfif NOT structKeyExists(session, "filterStatus")>
				<cfset session.filterStatus = {}>
				<cfset session.filterStatus.searchID = arguments.rc.searchID>
				<cfset session.filterStatus.airlines = 0>
				<cfset session.filterStatus.refundableSearch = 0>
				<cfset session.filterStatus.cabinSearch = {}>
				<cfset session.filterStatus.cabinSearch.C = 0>
				<cfset session.filterStatus.cabinSearch.F = 0>
			</cfif>

			<!--- reset filterStatus if new search is created --->
			<cfif arguments.rc.searchID NEQ session.filterStatus.searchID>
				<cfset session.filterStatus.searchId = arguments.rc.searchID>
				<cfset session.filterStatus.airlines = 0>
				<cfset session.filterStatus.refundableSearch = 0>
				<cfset session.filterStatus.cabinSearch = {}>
				<cfset session.filterStatus.cabinSearch.C = 0>
				<cfset session.filterStatus.cabinSearch.F = 0>
		</cfif>

		<!--- update filterStatus if 'find more' fares/class/airlines is clicked in filter --->
		<cfif StructKeyExists(arguments.rc, "bRefundable") and arguments.rc.bRefundable EQ 1>
			<cfset session.filterStatus.refundableSearch = 1>
		</cfif>
		<cfif StructKeyExists(arguments.rc, "sCabins") and arguments.rc.sCabins EQ "C">
			<cfset session.filterStatus.cabinSearch.C = 1>
		</cfif>
		<cfif StructKeyExists(arguments.rc, "sCabins") and arguments.rc.sCabins EQ "F">
			<cfset session.filterStatus.cabinSearch.F = 1>
		</cfif>
		<cfif StructKeyExists(arguments.rc, "airlines") and arguments.rc.airlines EQ "1">
			<cfset session.filterStatus.airlines = 1>
		</cfif>
	</cffunction>

	<cffunction name="getTotalFlights" access="private" hint="I pull the total number of flights out of the session scope.">
		<cfargument name="rc" required="true">
		<cfset var totalFlights = 0>
		<cfif structKeyExists(session.searches[arguments.rc.SearchID].stLowFareDetails.stResults, "1")>
			<cfset totalFlights = totalFlights + session.searches[arguments.rc.SearchID].stLowFareDetails.stResults.1>
		</cfif>
		<cfif structKeyExists(session.searches[arguments.rc.SearchID].stLowFareDetails.stResults, "0")>
			<cfset totalFlights = totalFlights + session.searches[arguments.rc.SearchID].stLowFareDetails.stResults.0>
		</cfif>

		<cfreturn totalFlights />
	</cffunction>




</cfcomponent>