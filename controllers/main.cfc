<cfcomponent extends="abstract" output="false">

	<cffunction name="default" output="false">
		<cfargument name="rc">
		
		<cfif structKeyExists(arguments.rc, 'Filter') AND IsObject(arguments.rc.Filter)>

			<cfparam name="rc.Service" default="">
			<cfset var SetGroup = false>
			<cfif NOT structKeyExists(rc, 'Group') 
				OR NOT IsNumeric(rc.Group)>
				<cfset rc.Group = 0>
				<cfset SetGroup = true>
			</cfif>
			<cfparam name="rc.Add" default="false">
			<cfparam name="rc.Remove" default="false">

			<cfset var AirCompleted = false>
			<cfset var HotelCompleted = false>
			<cfset var CarCompleted = false>
			<cfset var ChangedFlow = false>
			<cfset var AirReview = false>

			<!--- Add travel types needed. --->
			<cfif (rc.Add AND rc.Service EQ 'Air')
				OR (rc.Service EQ 'Air' AND NOT session.Filters[rc.SearchId].getAir())>
				<cfset session.Filters[rc.SearchId].setAir(true)>
			<cfelseif (rc.Add AND rc.Service EQ 'Hotel')
				OR (rc.Service EQ 'Hotel' AND NOT session.Filters[rc.SearchId].getHotel())>
				<cfset session.Filters[rc.SearchId].setHotel(true)>
			<cfelseif (rc.Add AND rc.Service EQ 'Car')
				OR (rc.Service EQ 'Car' AND NOT session.Filters[rc.SearchId].getCar())>
				<cfset session.Filters[rc.SearchId].setCar(true)>
			</cfif>

			<!--- Remove travel types originally requested. --->
			<cfif rc.Remove>
				<cfif rc.Service EQ 'Air'>
					<cfset session.Filters[rc.SearchId].setAir(false)>
					<cfset structDelete(session.Searches[rc.SearchId].stItinerary, 'Air')>
					<cfset AirCompleted = true>
				<cfelseif rc.Service EQ 'Hotel'>
					<cfset session.Filters[rc.SearchId].setHotel(false)>
					<cfset structDelete(session.Searches[rc.SearchId].stItinerary, 'Hotel')>
					<cfset HotelCompleted = true>
				<cfelseif rc.Service EQ 'Car'>
					<cfset session.Filters[rc.SearchId].setCar(false)>
					<cfset structDelete(session.Searches[rc.SearchId].stItinerary, 'Vehicle')>
					<cfset CarCompleted = true>
				</cfif>
				<cfset rc.Service = ''>
			</cfif>

			<cfif session.Filters[rc.SearchId].getAir()>

				<!--- Are all segments selected? --->
				<cfset var TotalGroups = 0>
				<cfset var GroupsCompleted = 0>
				<cfloop array="#session.Filters[rc.SearchId].getLegsForTrip()#" index="local.SegmentIndex" item="local.SegmentItem">
					<cfset TotalGroups++>
					<cfif structKeyExists(session.searches[SearchID].stItinerary, 'Air')
						AND structKeyExists(session.searches[SearchID].stItinerary.Air, SegmentIndex-1)
						AND NOT structIsEmpty(session.searches[SearchID].stItinerary.Air[SegmentIndex-1])>
						<cfset GroupsCompleted++>
						<cfif SetGroup>
							<cfset rc.Group = SegmentIndex>
						</cfif>
					</cfif>
				</cfloop>
				<cfif rc.Group GT TotalGroups>
					<cfset AirReview = true>
				</cfif>

				<!--- Is the price selected? --->
				<cfif TotalGroups EQ GroupsCompleted>
					<cfif structKeyExists(session.searches[SearchID].stItinerary.Air[0], 'TotalPrice')>
						<cfset AirCompleted = true>
					</cfif>
				</cfif>

				<!--- Remove future segments already selected if they are changing a previous segment. --->
				<cfloop array="#session.Filters[rc.SearchId].getLegsForTrip()#" index="local.SegmentIndex" item="local.SegmentItem">
					<cfif SegmentIndex-1 GTE rc.Group>
						<cfset session.searches[SearchID].stItinerary.Air[SegmentIndex-1] = {}>
					</cfif>
				</cfloop>

				<!--- Move them back a segment if they haven't selected one for the previous segment. --->
				<cfif rc.Group NEQ 0
					AND (NOT structKeyExists(session.searches[SearchID].stItinerary, 'Air')
					OR NOT structKeyExists(session.searches[SearchID].stItinerary.Air, rc.Group-1)
					OR structIsEmpty(session.searches[SearchID].stItinerary.Air[rc.Group-1]))>
					<cfset rc.Group = rc.Group-1>
					<cfset ChangedFlow = true>
				</cfif>

			<cfelse>

				<cfset AirCompleted = true>

			</cfif>

			<cfif session.Filters[rc.SearchId].getHotel()>

				<!--- Is a hotel selected? --->
				<cfif structKeyExists(session.searches[SearchID].stItinerary, 'Hotel')
					AND NOT structIsEmpty(session.searches[SearchID].stItinerary.Hotel)>
					<cfset HotelCompleted = true>
				</cfif>

			<cfelse>

				<cfset HotelCompleted = true>

			</cfif>

			<cfif session.Filters[rc.SearchId].getCar()>

				<!--- Is a car selected? --->
				<cfif structKeyExists(session.searches[SearchID].stItinerary, 'Car')
					AND NOT structIsEmpty(session.searches[SearchID].stItinerary.Car)>
					<cfset CarCompleted = true>
				</cfif>

			<cfelse>

				<cfset CarCompleted = true>

			</cfif>

			<cfif rc.Service EQ 'Air'
				OR NOT AirCompleted>

				<cfif rc.Service NEQ '' 
					AND rc.Service NEQ 'Air'>
					
					<cfset ChangedFlow = true>
					
				</cfif>

				<cfif NOT AirReview>
					
					<cfset variables.fw.redirect('air?SearchID=#arguments.rc.SearchID#&Group=#rc.Group#&Order=#ChangedFlow ? 1 : 0#&Main=')>

				<cfelse>

					<cfset variables.fw.redirect('air.review?SearchID=#arguments.rc.SearchID#&Order=#ChangedFlow ? 1 : 0#&Main=')>

				</cfif>

			<cfelseif rc.Service EQ 'Hotel'
				OR (rc.Service EQ '' AND NOT HotelCompleted)>

				<cfset variables.fw.redirect('hotel.search?SearchID=#arguments.rc.SearchID#&Main=')>

			<cfelseif rc.Service EQ 'Car'
				OR (rc.Service EQ '' AND NOT CarCompleted)>

				<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.SearchID#&Main=')>

			</cfif>

			<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.SearchID#&Main=')>
		</cfif>

	</cffunction>

</cfcomponent>
