<cfcomponent extends="abstract">

	<cfset variables.bookingDSN = "booking" />

	<!--- Change DSN to DB1 if we are testing Jeff's VB apps
				otherwise we'll use Zeus
	<cfif cgi.local_host IS 'RailoQA'>
		<cfset variables.bookingDSN = "findit">
	</cfif> --->

	<cffunction name="default" output="false">
		<cfargument name="rc">
		<cfset local.getTrip = variables.bf.getBean("general").getTrip(rc.searchID,rc.propertyID)> 
		<cfif getTrip.recordCount AND isJSON(local.getTrip.ResultsJSON)>
			<cfset local.trip = deserializeJSON(local.getTrip.ResultsJSON) />
			<cfif structKeyExists(rc, "roomSelected")>
				<!--- roomSelected can be lowestPrePaidTravelportRoom, lowestPrePaidPricelineRoom, lowestNonPrePaidTravelportRoom, or lowestNonPrePaidPricelineRoom --->
				<cfset local.roomSelected = rc.roomSelected />
				<cfset local.room = trip["#roomSelected#"] />
				<cfset local.ratePlanType = local.room.ratePlanType />
				<cfset local.dailyRate = local.room.dailyRate />

				<cfset local.selectedHotel = new com.shortstravel.hotel.Hotel() />
				<cfset local.selectedHotel.populateFromStruct( local.trip.hotelObject ) />
				<cfset local.selectedHotel.setSignatureImage( local.trip.image ) />
				<cfset local.selectedHotelRoom = new com.shortstravel.hotel.HotelRoom() />
				<cfset local.selectedHotelRoom.populateFromStruct( local.room ) />
				<cfset session.searches[rc.searchID].stItinerary.Hotel = local.selectedHotel />
				<cfset session.searches[rc.searchID].stItinerary.Hotel.setRooms( arrayNew(1) ) />
				<cfset arrayAppend(session.searches[rc.searchID].stItinerary.Hotel.getRooms(), local.selectedHotelRoom) /> 
				 
				 <cfset local.account = application.Accounts[rc.filter.getAcctID()]/>
				<cfset local.policy = application.Policies[rc.filter.getPolicyID()]/>  
				<cfset variables.bf.getBean( "HotelService" ).getRoomRateRules( searchId=rc.searchID,
																			 	propertyId=rc.propertyID,
																			 	ratePlanType=local.ratePlanType,
																			 	ppnBundle=local.selectedHotelRoom.getPPNBundle() ) />
				<cfset local.selectedHotelRoom.setIsInPolicy(variables.bf.getBean( "HotelService" ).checkHotelRoomInPolicy( 
																				policy= local.policy,
																			 	account=local.account,
																			 	room=local.selectedHotelRoom,
																			 	hotel = local.selectedHotel ) 
																			 	)>
				<!--- Parameters must be "SearchID", "PropertyID", and "RatePlanType" to process properly in the AngularJS code --->
				<!--- <cfset variables.fw.redirect("hotel.search?SearchID=#rc.searchID#&PropertyID=#rc.propertyID#&RatePlanType=#local.ratePlanType#&DailyRate=#local.dailyRate#") /> --->
				<!--- Originally was sending user to hotel results page and preselecting the room; now sending straight to summary page --->
				<cfset variables.fw.redirect("summary?SearchID=#rc.searchID#") />
			<cfelse>
				<cfset variables.fw.redirect("hotel.search?SearchID=#rc.searchID#&PropertyID=#rc.propertyID#") />
			</cfif>

		<cfelse>
			<cfset rc.message.addError("We could not find the requested hotel. Here are other properties that are close to the requested location.") />
			<cfset variables.fw.redirect("hotel.search?SearchID=#rc.searchID#") />
		</cfif>

	</cffunction>

</cfcomponent>