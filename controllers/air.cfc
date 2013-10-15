<cfcomponent extends="abstract" accessors="true">

	<!--- // DEPENDENCY INJECTION --->
	<cfproperty name="general" setter="true" getter="false">


	<cffunction name="lowfare" output="false" hint="I assemble low fares for display.">
		<cfargument name="rc">

		<cfif structKeyExists(arguments.rc, "airlines")
			AND arguments.rc.airlines EQ 1>
			<cfset rc.filter.setAirlines("")>
		</cfif>

		<!--- Even though measures are in place on the search widget to prevent users from selecting a start date that is earlier than now, a few users have gotten through --->
		<cfif structKeyExists(arguments.rc, "filter")
			AND dateCompare(arguments.rc.filter.getDepartDateTime(), now()) EQ 1>
		    <cfif NOT structKeyExists(arguments.rc, 'bSelect')>
	    	<!--- throw out threads and get lowfare pricing --->
				<cfset fw.getBeanFactory().getBean('airavailability').threadAvailability(argumentcollection=arguments.rc)>
				<cfset rc.stPricing = session.searches[arguments.rc.SearchID].stLowFareDetails.stPricing>
				<cfset fw.getBeanFactory().getBean('lowfare').threadLowFare(argumentcollection=arguments.rc)>


				<!--- if we're coming from FindIt we need to run the search (above) then pass it along to selectAir with our nTripKey --->
				<cfif structKeyExists(arguments.rc, "findIt") AND arguments.rc.findIt EQ 1>
					<cfset sleep(10000)>
					<cfset fw.getBeanFactory().getBean('lowfare').selectAir(argumentcollection=arguments.rc)>
				</cfif>
			<cfelse>
				<cfset fw.getBeanFactory().getBean('lowfare').selectAir( searchID = rc.searchID
																		, nTrip = rc.nTrip )>
				<cfset session.searches[rc.searchID].stCars = {}>
			</cfif>

			<!--- Setup some session flags to save if the user has clicked on any of the "find more " links in the filter --->
			<cfset checkFilterStatus(arguments.rc)>
			<cfset rc.totalFlights = getTotalFlights(arguments.rc)>

			<cfif structKeyExists(arguments.rc, 'bSelect')>
				<cfset removeOtherFlights(arguments.rc)>

				<cfif arguments.rc.Filter.getHotel()
					AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Hotel')>
					<cfset variables.fw.redirect('hotel.search?SearchID=#arguments.rc.Filter.getSearchID()#')>
				</cfif>
				<cfif arguments.rc.Filter.getCar()
					AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Vehicle')>
					<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.Filter.getSearchID()#')>
				</cfif>
				<cfif rc.Account.couldYou EQ 1>
					<cfset variables.fw.redirect('couldYou?SearchID=#arguments.rc.Filter.getSearchID()#')>
				</cfif>

				<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>
			</cfif>
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="availability" output="false" hint="I get info on legs when button is clicked on search results.">
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

		<!--- TODO: need to refactor this count as it doesn't accurately show leg/schedule counts
			* might just need to count in badges?
		--->
		<cfset rc.totalFlights = getTotalFlights(arguments.rc)>

		<cfif structKeyExists(arguments.rc, 'bSelect')>

			<!--- need to set a flag for the first group added and then check it for
				NW flights, which can't be combined with other carriers --->
			<cfif NOT structKeyExists(arguments.rc, "firstSelectedGroup")>
				<cfset rc.southWestMatch = false>
				<cfset rc.firstSelectedGroup = arguments.rc.group>
				<cfif session.searches[arguments.rc.SearchID].stSelected[arguments.rc.group].carriers[1] EQ "WN">
					<cfset rc.southWestMatch = true>
				</cfif>
			</cfif>

			<!--- continue looping over legs and populating stSelected --->
			<cfloop array="#arguments.rc.Filter.getLegsForTrip()#" item="local.nLeg" index="local.nLegIndex">
				<cfif structIsEmpty(session.searches[arguments.rc.SearchID].stSelected[local.nLegIndex-1])>
					<cfset variables.fw.redirect(action='air.availability', queryString='SearchID=#arguments.rc.SearchID#&Group=#local.nLegIndex-1#'
						, preserve='firstSelectedGroup,southWestMatch')>
				</cfif>
			</cfloop>

			<cfset variables.fw.redirect('air.price?SearchID=#arguments.rc.SearchID#')>
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="price" output="false" hint="I run doAirPrice.">
		<cfargument name="rc">

		<cfset fw.getBeanFactory().getBean('AirPrice').doAirPrice(argumentcollection=arguments.rc)>

		<cfset session.searches[rc.SearchID].stSelected = StructNew('linked')><!--- Place holder for selected legs --->
		<cfset session.searches[rc.SearchID].stSelected[0] = {}>
		<cfset session.searches[rc.SearchID].stSelected[1] = {}>
		<cfset session.searches[rc.SearchID].stSelected[2] = {}>
		<cfset session.searches[rc.SearchID].stSelected[3] = {}>

		<cfset variables.fw.redirect('air.lowfare?SearchID=#rc.SearchID#&filter=all')>

		<cfreturn />
	</cffunction>

	<cffunction name="popup" output="false" hint="I get details, seats, bags and for modal popup for each badge.">
		<cfargument name="rc">

				<!--- seatmap --->
				<cfset rc.sCabin = 'Y'>
				<cfset rc.nTripID = arguments.rc.nTripID>
				<cfset variables.fw.service('seatmap.doSeatMap', 'stSeats')>

				<!---details: do nothing --->

				<!--- baggage --->
				<cfset variables.fw.service('baggage.baggage', 'qBaggage')>

				<!--- email --->
				<cfset local.userID = session.userID>
				<cfset rc.qUser = variables.general.getUser( local.userID )>
				<cfset local.userID = session.filters[arguments.rc.searchID].getProfileID()>
				<cfset rc.qProfile = variables.general.getUser( local.userID )>

				<!--- TO DO: Update this logic once a flag is built into the system.  Also update the
				code above to pull from the com object verses the general service. --->
				<cfif rc.qUser.First_Name EQ 'STODefaultUser'>
					<cfset rc.qUser = variables.general.getUser( 0 )>
					<cfset rc.qProfile = variables.general.getUser( 0 )>
				</cfif>

				<cfset variables.fw.setLayout("popup")>
		<cfreturn />
	</cffunction>


	<cffunction name="print" output="false" hint="I display a printer friendly version of the air search results.">
		<cfargument name="rc">
			<cfset variables.fw.setLayout("print")>
		<cfreturn />
	</cffunction>

	<cffunction name="summarypopup" output="false" hint="I get seat map for modal popup for summary page.">
		<cfargument name="rc">

				<cfset rc.sCabin = 'Y'>
				<cfset rc.nTripID = arguments.rc.nTripID>
				<cfset variables.fw.service('seatmap.doSeatMap', 'stSeats')>

				<cfset variables.fw.setLayout("popup")>
		<cfreturn />
	</cffunction>


	<cffunction name="seatmap" output="false" hint="I get data to make a seat map.">
		<cfargument name="rc">
		<cfset rc.sCabin = 'Y'>
		<cfset rc.nTripID = arguments.rc.nTripID>
		<cfset rc.nSegment = arguments.rc.nSegment>
		<cfset variables.fw.service('seatmap.doSeatMap', 'stSeats')>
		<cfset request.layout = false>
		<cfreturn />
	</cffunction>

	<cffunction name="email" output="false" hint="I send an email">
		<cfargument name="rc">

		<cfset rc.bSuppress = 1>
		<cfset fw.getBeanFactory().getBean('email').doEmail( argumentcollection = arguments.rc )>

		<cfset rc.message.AddInfo("Your email has been sent.")>
		<cfset variables.fw.redirect('air.lowfare?SearchID=#arguments.rc.SearchID#')>

		<cfreturn />
	</cffunction>

	<cffunction name="removeflight" output="false" hint="I take a searchID and remove a flight from the session.">
		<cfargument name="rc">

		<cfset local.newSearchID = "">
		<cfset fw.getBeanFactory().getBean('lowfare').removeFlight( arguments.rc.searchID )>

		<cfset local.newSearchID = ListLast( StructKeyList(session.searches) )>
		<cfset rc.message.AddInfo("Saved search deleted successfully!")>
		<cfset variables.fw.redirect( action="air.lowfare", queryString="searchid=#newSearchID#" )>

		<cfreturn />
	</cffunction>

	<cffunction name="addAir" output="false" hint="I give users the chance to search for air even if air wasn't selected in the original search.">
		<cfargument name="rc">

		<cfreturn />
	</cffunction>

<!--- PRIVATE METHODS --->
	<cffunction name="removeOtherFlights" access="private" output="false" hint="I take a searchID and remove all other flights from the session.">
		<cfargument name="rc">

		<cfset local.flightsToDelete =  StructKeyArray(session.filters)>
		<cfset  ArrayDeleteAt(local.flightsToDelete, ArrayFind(local.flightsToDelete, arguments.rc.searchID))>

		<cfloop array="#local.flightsToDelete#" item="local.searchID">
			<cfset StructDelete(session.filters, searchID)>
			<cfset StructDelete(session.searches, searchID)>
		</cfloop>

		<cfreturn />
	</cffunction>

	<cffunction name="checkFilterStatus" access="private" output="false" hint="Setup some session flags to save if the user has clicked on any of the 'find more' links in the filter">
		<cfargument name="rc">

		<!--- run on first search --->
		<!--- reset filterStatus if new search is created --->
		<cfif NOT structKeyExists(session, "filterStatus")
				OR NOT IsStruct(session.filterStatus)
				OR NOT structKeyExists(session.filterStatus, "searchID")
				OR arguments.rc.searchID NEQ session.filterStatus.searchID>

			<cfset session.filterStatus = {}>
			<cfset session.filterStatus.searchID = arguments.rc.searchID>
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

		<cfset local.errorMessage = "">
		<cfset local.totalFlights = 0>

		<cfif structKeyExists(session.searches[arguments.rc.SearchID], "stLowFareDetails")
				AND structKeyExists(session.searches[arguments.rc.SearchID].stLowFareDetails, "aSortFare")>
			<cfset local.totalFlights = arrayLen(session.searches[arguments.rc.SearchID].stLowFareDetails.aSortFare)>
		<cfelse>
			<!--- <cfif IsLocalHost(cgi.remote_addr)>
				<cfset local.errorMessage = "stLowFareDetails.aSortFare is empty which usually indicates an issue with Travelport returning a faultcode in availability or lowfare. Check the uAPI logs with SearchID: #arguments.rc.SearchID#.">
			</cfif>
			<cfthrow message="There was a problem retrieving flights from Travelport. (#local.errorMessage#)"/> --->
		</cfif>

		<cfreturn local.totalFlights>
	</cffunction>

</cfcomponent>