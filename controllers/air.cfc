<cfcomponent extends="abstract">

	<cffunction name="removeflight" output="false" hint="I take a searchID and remove a flight from the session.">
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
			<cfif arguments.rc.Filter.getCar()
				AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Car')>
				<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.Filter.getSearchID()#')>
			</cfif>
			<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>
		</cfif>

		<cfreturn />
	</cffunction>


<!---
availability
--->
	<cffunction name="availability" output="true">
		<cfargument name="rc">

		<cfif NOT structKeyExists(arguments.rc, 'bSelect')>
			<cfset arguments.rc.sPriority = 'LOW'>
			<!--- Throw out a threads --->
			<cfset rc.stPricing = session.searches[arguments.rc.SearchID].stLowFareDetails.stPricing>
			<cfset fw.getBeanFactory().getBean('lowfare').threadLowFare(argumentcollection=arguments.rc)>
			<!--- Do the availability search. --->
			<cfset fw.getBeanFactory().getBean('airavailability').threadAvailability(argumentcollection=arguments.rc)>
		<cfelse>
			<!--- Select --->
			<cfset fw.getBeanFactory().getBean('airavailability').selectLeg(argumentcollection=arguments.rc)>
		</cfif>
		<cfset rc.totalFlights = getTotalFlights(arguments.rc)>
		<cfreturn />
	</cffunction>

	<cffunction name="endavailability" output="true">
		<cfargument name="rc">

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

<!---
popup
--->
	<cffunction name="popup" output="true">
		<cfargument name="rc">

		<cfset rc.bSuppress = 1>
		<cfif rc.sDetails EQ 'seatmap'>
			<!--- Move needed variables into the rc scope. --->
			<cfset rc.sCabin = 'Y'>
			<cfset rc.nTripID = url.nTripID>
			<cfif structKeyExists(url, "nSegment")>
				<cfset rc.nSegment = url.nSegment>
			</cfif>
			<cfparam name="rc.bSelection" default="0">
			<!--- init objects --->
			<cfset variables.fw.service('UAPI.init', 'objUAPI')>
			<!--- Do the search. --->
			<cfset variables.fw.service('seatmap.doSeatMap', 'stSeats')>
		<cfelseif rc.sDetails EQ 'details'>
			<!--- do nothing --->
		<cfelseif rc.sDetails EQ 'baggage'>
			<cfset variables.fw.service('baggage.baggage', 'qBaggage')>
		<cfelseif rc.sDetails EQ 'email'>
			<cfset rc.UserID = session.User_ID>
			<cfset variables.fw.service('general.getUser', 'qUser')>
			<cfset rc.UserID = session.searches[rc.SearchID].ProfileID>
			<cfset variables.fw.service('general.getUser', 'qProfile')>
		</cfif>

		<cfreturn />
	</cffunction>

<!---
seatmap
--->
	<cffunction name="seatmap" output="true">
		<cfargument name="rc">

		<!--- Move needed variables into the rc scope. --->
		<cfset rc.bSuppress = 1>
		<cfset rc.sCabin = 'Y'>
		<cfset rc.nTripID = url.nTripID>
		<cfset rc.nSegment = url.nSegment>
		<!--- init objects --->
		<cfset variables.fw.service('UAPI.init', 'objUAPI')>
		<!--- Do the search. --->
		<cfset variables.fw.service('seatmap.doSeatMap', 'stSeats')>

		<cfreturn />
	</cffunction>

	<cffunction name="email" output="true" hint="I send an email">
		<cfargument name="rc">
		<cfset rc.bSuppress = 1>
		<cfset variables.fw.service('email.email', 'void')>
		<cfset variables.fw.redirect('air.lowfare?SearchID=#arguments.rc.SearchID#')>
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