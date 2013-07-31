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

		<cfif rc.Vehicle.getPickupLocationType() IS ''>
			<cfset rc.pickupLocation = rc.Filter.getCarPickupAirport() />
		<cfelse>
			<cfset vehicleLocation = session.searches[rc.searchID].vehicleLocations[rc.Filter.getCarPickUpAirport()] />
			<cfset rc.pickupLocation = application.stCarVendors[vehicleLocation[rc.Vehicle.getPickupLocationID()].vendorCode] & ' - '
				& vehicleLocation[rc.Vehicle.getPickupLocationID()].street & ' ('
				& vehicleLocation[rc.Vehicle.getPickupLocationID()].city & ')' />
		</cfif>

		<cfif rc.Vehicle.getDropoffLocationType() IS ''>
			<cfif rc.Filter.getCarDropoffAirport() NEQ rc.Filter.getCarPickupAirport()>
				<cfset rc.dropoffLocation = rc.Filter.getCarDropoffAirport() />
			<cfelse>
				<cfset rc.dropoffLocation = rc.pickupLocation />
			</cfif>
		<cfelse>
			<cfset vehicleLocation = session.searches[rc.searchID].vehicleLocations[rc.Filter.getCarDropoffAirport()] />
			<cfset rc.dropoffLocation = application.stCarVendors[vehicleLocation[rc.Vehicle.getDropoffLocationID()].vendorCode] & ' - '
				& vehicleLocation[rc.Vehicle.getDropoffLocationID()].street & ' ('
				& vehicleLocation[rc.Vehicle.getDropoffLocationID()].city & ')' />
		</cfif>

		<cfset rc.Travelers = session.searches[rc.SearchID].travelers />
		<cfset rc.airTravelers = arrayNew(1) />
		<cfset rc.hotelTravelers = arrayNew(1) />
		<cfset rc.vehicleTravelers = arrayNew(1) />

		<cfloop from="1" to="#arrayLen(rc.Travelers)#" index="travelerIndex">
			<cfset rc.Traveler[travelerIndex] = session.searches[rc.SearchID].travelers[travelerIndex] />
			<cfif rc.Traveler[travelerIndex].getBookingDetail().getAirNeeded()>
				<cfset arrayAppend(rc.airTravelers, travelerIndex) />
				<cfif len(rc.Traveler[travelerIndex].getBookingDetail().getAirReasonCode())>
					<cfset rc.Traveler[travelerIndex].getBookingDetail().airReasonDescription = fw.getBeanFactory().getBean('confirmation').getOOPReason(rc.Traveler[travelerIndex].getBookingDetail().getAirReasonCode()) />
				</cfif>
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