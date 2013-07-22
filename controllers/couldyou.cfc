<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">
		<cfif arguments.rc.Filter.getAir()>
			<cfset rc.startDate = arguments.rc.Filter.getDepartDateTime() />
			<cfset rc.endDate = arguments.rc.Filter.getArrivalDateTime() />
		<cfelseif arguments.rc.Filter.getHotel()>
			<cfset rc.startDate = arguments.rc.Filter.getCheckInDate() />
			<cfset rc.endDate = arguments.rc.Filter.getCheckOutDate() />
		<cfelseif arguments.rc.Filter.getCar()>
			<cfset rc.startDate = arguments.rc.Filter.getCarPickupDateTime() />
			<cfset rc.endDate = arguments.rc.Filter.getCarDropOffDateTime() />
		</cfif>

		<cfset rc.itinerary = session.searches[rc.searchID].stItinerary>

		<!---Check to see if currency values are all the same...if not, redirect to summary--->
		<cfset var currencies = arrayNew(1) />

		<cfif rc.Filter.getAir()>
			<cfset arrayAppend( currencies, "USD" ) />
		</cfif>
		<cfif rc.Filter.getHotel()>
			<cfif rc.itinerary.hotel.getRooms()[1].getTotalForStayCurrency() !=  "" >
				<cfset arrayAppend( currencies, rc.itinerary.hotel.getRooms()[1].getTotalForStayCurrency() ) />
			<cfelse>
				<cfset arrayAppend( currencies, rc.itinerary.hotel.getRooms()[1].getBaseRateCurrency() ) />
			</cfif>
		</cfif>
		<cfif rc.Filter.getCar()>
			<cfset arrayAppend( currencies, rc.itinerary.vehicle.getCurrency() ) />
		</cfif>

		<cfloop array="#currencies#" item="local.currency" index="local.idx">
			<cfif idx GT 1 AND currency NEQ currencies[ idx-1 ]>
				<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>
			</cfif>
		</cfloop>
		<!---End currency equality check--->

		<cfset rc.airSelected = (structKeyExists(rc.itinerary, 'Air') ? true : false)>
		<cfset rc.Air = (structKeyExists(rc.itinerary, 'Air') ? rc.itinerary.Air : '')>

		<cfset rc.hotelSelected = (structKeyExists(rc.itinerary, 'Hotel') ? true : false)>
		<cfset rc.Hotel = (structKeyExists(rc.itinerary, 'Hotel') ? rc.itinerary.Hotel : '')>

		<cfset rc.vehicleSelected = (structKeyExists(rc.itinerary, 'Vehicle') ? true : false)>
		<cfset rc.Vehicle = (structKeyExists(rc.itinerary, 'Vehicle') ? rc.itinerary.Vehicle : '')>

		<cfset rc.allTravelers = fw.getBeanFactory().getBean('UserService').getAuthorizedTravelers( userID = rc.Filter.getUserID()
																								, acctID = rc.Filter.getAcctID() )>
		<cfset rc.qOutOfPolicy = fw.getBeanFactory().getBean('Summary').getOutOfPolicy( acctID = rc.Filter.getAcctID() )>
		<cfset rc.qStates = fw.getBeanFactory().getBean('Summary').getStates()>
		<cfset rc.qTXExceptionCodes = fw.getBeanFactory().getBean('Summary').getTXExceptionCodes()>
		<cfset rc.fees = fw.getBeanFactory().getBean('Summary').determineFees(userID = rc.Filter.getUserID()
																			, acctID = rc.Filter.getAcctID()
																			, Air = rc.Air
																			, Filter = rc.Filter)>


		<cfreturn />
	</cffunction>

	<cffunction name="processSelection" access="public" output="false" returntype="void" hint="">
		<cfargument name="rc">

		<cfif rc.selectedDate NEQ rc.originalDate>

			<cfset var Search = session.filters[ rc.searchId ] />
			<cfset var couldYou = session.searches[ rc.searchId ].couldYou />

			<cfif Search.getAir()>
				<cfset var tripIDs = structKeyList( couldYou.air[ rc.selectedDate ] ) />
				<cfset var newFlight = couldYou.air[ rc.selectedDate ][ listGetAt( tripIDs, 1 ) ] />

				<!---Update search object in session--->

				<!---Update the stItinerary--->
				<cfset var session.searches[ rc.searchId ].stItinerary.air = newFlight />
			</cfif>

			<cfif Search.getHotel()>
				<cfset var newHotel = couldYou.hotel[ rc.selectedDate ] />

				<!---Update search object in session--->

				<!---Update the stItinerary--->
				<cfset var session.searches[ rc.searchId ].stItinerary.hotel = newHotel />

			</cfif>

			<cfif Search.getCar()>
				<cfset var newVehicle = couldYou.vehicle[ rc.selectedDate ] />

				<!---Update search object in session--->

				<!---Update the stItinerary--->
				<cfset var session.searches[ rc.searchId ].stItinerary.vehicle = newVehicle />
			</cfif>

			<!---Save the updated search object to the database--->


		</cfif>

		<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>

	</cffunction>
</cfcomponent>