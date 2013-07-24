<cfcomponent extends="abstract">
	<cffunction name="default" output="false">
		<cfargument name="rc" />

		<cfset rc.itinerary = session.searches[rc.searchID].stItinerary />

		<cfset rc.airSelected = (structKeyExists(rc.itinerary, 'Air') ? true : false) />
		<cfset rc.Air = (structKeyExists(rc.itinerary, 'Air') ? rc.itinerary.Air : '') />

		<cfset rc.hotelSelected = (structKeyExists(rc.itinerary, 'Hotel') ? true : false) />
		<cfset rc.Hotel = (structKeyExists(rc.itinerary, 'Hotel') ? rc.itinerary.Hotel : '') />

		<cfset rc.vehicleSelected = (structKeyExists(rc.itinerary, 'Vehicle') ? true : false) />
		<cfset rc.Vehicle = (structKeyExists(rc.itinerary, 'Vehicle') ? rc.itinerary.Vehicle : '') />

		<!--- <cfset rc.qOutOfPolicy = fw.getBeanFactory().getBean('Summary').getOutOfPolicy(acctID = rc.Filter.getAcctID()) />

		<cfset rc.fees = fw.getBeanFactory().getBean('Summary').determineFees(userID = rc.Filter.getUserID()
																			, acctID = rc.Filter.getAcctID()
																			, Air = rc.Air 
																			, Filter = rc.Filter) /> --->

		<cfset rc.Travelers = session.searches[rc.SearchID].travelers />
		<cfset rc.airTravelers = arrayNew(1) />
		<cfset rc.hotelTravelers = arrayNew(1) />
		<cfset rc.vehicleTravelers = arrayNew(1) />

		<cfloop from="1" to="#arrayLen(rc.Travelers)#" index="travelerIndex">
			<cfset rc.Traveler[travelerIndex] = session.searches[rc.SearchID].travelers[travelerIndex] />
			<cfif rc.Traveler[travelerIndex].getBookingDetail().getAirNeeded()>
				<cfset arrayAppend(rc.airTravelers, travelerIndex) />
			</cfif>
			<cfif rc.Traveler[travelerIndex].getBookingDetail().getHotelNeeded()>
				<cfset arrayAppend(rc.hotelTravelers, travelerIndex) />
			</cfif>
			<cfif rc.Traveler[travelerIndex].getBookingDetail().getCarNeeded()>
				<cfset arrayAppend(rc.vehicleTravelers, travelerIndex) />
			</cfif>
		</cfloop>

		<cfreturn />
	</cffunction>
</cfcomponent>



<!--- <cfcomponent extends="abstract">

	<cffunction name="default" output="false">

			<cfset session.searches[rc.SearchID].travelers[rc.travelerNumber] = rc.Traveler>

</cfcomponent> --->