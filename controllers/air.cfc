<cfcomponent extends="abstract" accessors="true">

	<!--- // DEPENDENCY INJECTION --->
	<cfproperty name="Air" setter="true" getter="false">
	<cfproperty name="airPrice" setter="true" getter="false">
	<cfproperty name="email" setter="true" getter="false">
	<cfproperty name="general" setter="true" getter="false">
	<cfproperty name="lowFare" setter="true" getter="false">
	<cfproperty name="lowFareavail" setter="true" getter="false">
	<cfproperty name="Itinerary" setter="true" getter="false">

	<cffunction name="default" output="false" hint="I assemble low fares for display.">
		<cfargument name="rc">

		<cfset var SearchID = SearchID>
		<cfset var Group = structKeyExists(arguments.rc, 'Group') AND arguments.rc.Group NEQ '' ? arguments.rc.Group : 0>

		<cfloop array="#arguments.rc.Filter.getLegsForTrip()#" index="local.SegmentIndex" item="local.SegmentItem">
			<cfif SegmentIndex-1 GTE Group>
				<cfset session.searches[SearchID].stItinerary.Air[SegmentIndex-1] = {}>
			</cfif>
		</cfloop>

		<cfif structKeyExists(rc, 'FlightSelected')>

			<cfset session.searches[SearchID].stItinerary = Itinerary.selectAir(	form = form,
																					stItinerary = session.searches[SearchID].stItinerary,
																					Group = Group,
																					Groups = arrayLen(arguments.rc.Filter.getLegsForTrip()))>

			<!--- <cfdump var=#session.searches[SearchID].stItinerary# abort> --->
			<cfloop array="#arguments.rc.Filter.getLegsForTrip()#" index="local.SegmentIndex" item="local.SegmentItem">
				<cfif Group+2 EQ local.SegmentIndex>
					<cfset fw.redirect('air?SearchID=#arguments.rc.SearchID#&Group=#SegmentIndex-1#')>
				</cfif>
			</cfloop>

			<!--- <cfdump var=#session.searches[SearchID].Selected# abort> --->
			<cfset session.Filters[SearchID].setAir(true)>
			<cfset variables.fw.redirect('air.review?SearchID=#arguments.rc.SearchID#')>
		</cfif>

		<!--- <cfif structKeyExists(session.searches[SearchID], 'unusedtickets')>
			<cfset session.Filters[SearchID].setUnusedTicketCarriers( variables.general.getUnusedTickets( ProfileID = arguments.rc.Filter.getProfileID() ) )>
			<cfdump var=#session.Filters[SearchID].getUnusedTicketCarriers()# abort>
		</cfif> --->

		<cfset rc.trips = variables.air.doSearch(Account = arguments.rc.Account,
												Policy = arguments.rc.Policy,
												Filter = arguments.rc.Filter,
												SearchID = SearchID,
												Group = Group,
												SelectedTrip = session.searches[SearchID].stItinerary.Air,
												cabins = '')><!---(structKeyExists(arguments.rc, 'sCabins') ? arguments.rc.sCabins : '')--->

		<cfset rc.User = variables.general.getUser(UserId = arguments.rc.Filter.getUserId())>
		<cfset rc.Profile = variables.general.getUser(UserId = arguments.rc.Filter.getProfileId())>

		<cfreturn />
	</cffunction>

	<cffunction name="review" output="false">
		<cfargument name="rc">

		<cfset rc.Pricing = variables.airprice.doAirPrice(	Account = arguments.rc.Account,
															Policy = arguments.rc.Policy,
															Filter = arguments.rc.Filter,
															SearchID = SearchID,
															Group = arguments.rc.Group,
															Selected = session.searches[SearchID].stItinerary.Air)>

		<cfreturn />
	</cffunction>

	<cffunction name="email" output="false">
		<cfargument name="rc">

		<cfset variables.email.doEmail(	Email_Segment = form.Email_Segment,
										Email_Name = form.Email_Name,
										Email_Address = form.Email_Address,
										Email_To = form.Email_To,
										Email_CC = form.Email_CC,
										Email_Message = form.Email_Message,
										Email_Subject = form.Email_Subject)>

		<cfset fw.redirect('air?SearchID=#arguments.rc.SearchID#&Group=#arguments.rc.Group#')>

		<cfreturn />
	</cffunction>

</cfcomponent>
