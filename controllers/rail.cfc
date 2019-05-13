<cfcomponent extends="abstract" accessors="true">

	<!--- // DEPENDENCY INJECTION --->
	<cfproperty name="RailSearch" setter="true" getter="false">
	<cfproperty name="Itinerary" setter="true" getter="false">

	<cffunction name="default" output="false" hint="I assemble low fares for display.">
		<cfargument name="rc">

		<cfset var SearchID = SearchID>


		<cfif NOT structKeyExists(arguments.rc, 'Group') OR arguments.rc.Group EQ ''>
			<cfset fw.redirect('rail?SearchID=#arguments.rc.SearchID#&Group=0')>
		</cfif>

		<cfset var Group = arguments.rc.Group>

		<cfloop array="#arguments.rc.Filter.getLegsForTrip()#" index="local.SegmentIndex" item="local.SegmentItem">
			<cfif SegmentIndex-1 GTE Group>
				<cfset session.searches[SearchID].stItinerary.Rail[SegmentIndex-1] = {}>
			</cfif>
		</cfloop>

		<cfif Group NEQ 0
			AND (NOT structKeyExists(session.searches[SearchID].stItinerary, 'Rail')
			OR NOT structKeyExists(session.searches[SearchID].stItinerary.Rail, Group-1)
			OR structIsEmpty(session.searches[SearchID].stItinerary.Rail[Group-1]))>
			
			<cfset fw.redirect('rail?SearchID=#arguments.rc.SearchID#&Group=#Group-1#&Order=')>

		</cfif>

		<cfif structKeyExists(rc, 'RailSelected')>

			<cfset session.searches[SearchID].stItinerary = Itinerary.selectRail(form = form,
																				Itinerary = session.searches[SearchID].stItinerary,
																				Group = Group,
																				Groups = arrayLen(arguments.rc.Filter.getLegsForTrip()))>

			<!--- <cfdump var=#session.searches[SearchID].stItinerary# abort> --->
			<cfloop array="#arguments.rc.Filter.getLegsForTrip()#" index="local.SegmentIndex" item="local.SegmentItem">
				<cfif Group+2 EQ local.SegmentIndex>
					<cfset fw.redirect('rail?SearchID=#arguments.rc.SearchID#&Group=#SegmentIndex-1#')>
				</cfif>
			</cfloop>

			<!--- <cfdump var=#session.searches[SearchID].Selected# abort> --->
			<cfset session.Filters[SearchID].setRail(true)>

		</cfif>

		<cfset rc.trips = variables.railsearch.doRailSearch(Account = arguments.rc.Account,
													Policy = arguments.rc.Policy,
													Filter = arguments.rc.Filter,
													SearchID = SearchID,
													Group = Group,
													SelectedTrip = session.searches[SearchID].stItinerary.Rail)><!---(structKeyExists(arguments.rc, 'sCabins') ? arguments.rc.sCabins : '')--->

		<cfreturn />
	</cffunction>

</cfcomponent>
