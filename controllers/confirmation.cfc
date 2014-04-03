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

		<cfif isStruct(rc.Vehicle)>
			<cfif rc.Vehicle.getPickupLocationType() IS ''
				OR rc.Vehicle.getPickupLocationType() IS 'Terminal'
				OR rc.Vehicle.getPickupLocationType() IS 'Airport'>
				<cfset rc.pickupLocation = rc.Filter.getCarPickupAirport() />
			<cfelse>
				<cfset local.vehicleLocation = session.searches[rc.searchID].vehicleLocations[rc.Filter.getCarPickUpAirport()] />
				<cfset local.locationKey = ''>
				<cfloop array="#local.vehicleLocation#" index="local.locationIndex" item="local.location">
					<cfif rc.Vehicle.getPickupLocationID() EQ location.vendorLocationID>
						<cfset local.locationKey = local.locationIndex>
						<cfbreak>
					</cfif>
				</cfloop>
				<cfset rc.pickupLocation = application.stCarVendors[local.vehicleLocation[local.locationKey].vendorCode] & ' - '
					& local.vehicleLocation[local.locationKey].street & ' ('
					& local.vehicleLocation[local.locationKey].city & ')' />
			</cfif>

			<cfif rc.Vehicle.getDropoffLocationType() IS ''
				OR rc.Vehicle.getDropoffLocationType() IS 'Terminal'
				OR rc.Vehicle.getDropoffLocationType() IS 'Airport'>
				<cfif rc.Filter.getCarDropoffAirport() NEQ rc.Filter.getCarPickupAirport()>
					<cfset rc.dropoffLocation = rc.Filter.getCarDropoffAirport() />
				<cfelse>
					<cfset rc.dropoffLocation = rc.pickupLocation />
				</cfif>
			<cfelse>
				<cfset local.vehicleLocation = session.searches[rc.searchID].vehicleLocations[rc.Filter.getCarDropoffAirport()] />
				<cfset local.locationKey = ''>
				<cfloop array="#vehicleLocation#" index="local.locationIndex" item="local.location">
					<cfif rc.Vehicle.getDropoffLocationID() EQ location.vendorLocationID>
						<cfset local.locationKey = local.locationIndex>
						<cfbreak>
					</cfif>
				</cfloop>
				<cfset rc.dropoffLocation = application.stCarVendors[local.vehicleLocation[local.locationKey].vendorCode] & ' - '
					& local.vehicleLocation[local.locationKey].street & ' ('
					& local.vehicleLocation[local.locationKey].city & ')' />
			</cfif>
		</cfif>

		<cfset rc.Travelers = session.searches[rc.SearchID].travelers />
		<cfset rc.airTravelers = arrayNew(1) />
		<cfset rc.hotelTravelers = arrayNew(1) />
		<cfset rc.vehicleTravelers = arrayNew(1) />

		<cfloop from="1" to="#arrayLen(rc.Travelers)#" index="local.travelerIndex">
			<cfset rc.Traveler[local.travelerIndex] = session.searches[rc.SearchID].travelers[local.travelerIndex] />
			<cfif rc.Traveler[local.travelerIndex].getBookingDetail().getAirNeeded()>
				<cfset arrayAppend(rc.airTravelers, local.travelerIndex) />
				<cfif len(rc.Traveler[local.travelerIndex].getBookingDetail().getAirReasonCode())>
					<cfset rc.Traveler[local.travelerIndex].getBookingDetail().airReasonDescription = fw.getBeanFactory().getBean('confirmation').getOOPReason( fareSavingsCode = rc.Traveler[local.travelerIndex].getBookingDetail().getAirReasonCode()																																								
																																								, acctID = rc.Filter.getAcctID()
																																								, tmcID = rc.Account.tmc.getTMCID() ) />
				</cfif>
			</cfif>
			<cfif rc.Traveler[local.travelerIndex].getBookingDetail().getHotelNeeded()>
				<cfset arrayAppend(rc.hotelTravelers, local.travelerIndex) />
			</cfif>
			<cfif rc.Traveler[local.travelerIndex].getBookingDetail().getCarNeeded()>
				<cfset arrayAppend(rc.vehicleTravelers, local.travelerIndex) />
			</cfif>
		</cfloop>

		<cfreturn />
	</cffunction>
</cfcomponent>