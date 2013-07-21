<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">
		<!---TODO: Replace this with logic to get the start/end date based on services selected--->
		<cfset rc.startDate = arguments.rc.Filter.getCheckInDate() />
		<cfset rc.endDate = arguments.rc.Filter.getCheckOutDate() />

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

		<cfdump var="#currencies#"/><cfabort>
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

</cfcomponent>