<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfset rc.itinerary = session.searches[rc.searchID].stItinerary>

		<!---Remove any CouldYou alternate trips logged for this search ID--->
		<cftry>
			<cfset fw.getBeanFactory().getBean( "CouldYouService" ).deleteTripsForSearch( rc.searchID ) />
			<cfcatch type="any">
				<!---Log this error, but do not prevent the request from completing because we can't write the log entry--->
				<cfif variables.fw.getBeanFactory().getBean( 'EnvironmentService' ).getEnableBugLog()>
					 <cfset variables.fw.getBeanFactory().getBean('BugLogService').notifyService( message=cfcatch.Message, exception=rc, severityCode='Fatal' ) />
				</cfif>
			</cfcatch>
		</cftry>

		<!---Redirect if not all specified services are selected--->
		<cfif arguments.rc.Filter.getAir() AND NOT structKeyExists( rc.itinerary, "Air" ) >
			<cfset variables.fw.redirect('air.lowfare?SearchID=#arguments.rc.Filter.getSearchID()#')>
		</cfif>
		<cfif arguments.rc.Filter.getHotel() AND NOT structKeyExists( rc.itinerary, "Hotel" )>
			<cfset variables.fw.redirect('hotel.search?SearchID=#arguments.rc.Filter.getSearchID()#')>
		</cfif>
		<cfif arguments.rc.Filter.getCar() AND NOT structKeyExists( rc.itinerary, "Vehicle" )>
			<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.Filter.getSearchID()#')>
		</cfif>

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



		<!---Check to see if currency values are all the same...if not, redirect to summary--->
		<cfset var currencies = arrayNew(1) />

		<cfif val(rc.Filter.getAir())>
			<cfset arrayAppend( currencies, "USD" ) />
		</cfif>
		<cfif val(rc.Filter.getHotel())>
			<cfif rc.itinerary.hotel.getRooms()[1].getTotalForStayCurrency() !=  "" >
				<cfset arrayAppend( currencies, rc.itinerary.hotel.getRooms()[1].getTotalForStayCurrency() ) />
			<cfelseif rc.itinerary.hotel.getRooms()[1].getBaseRateCurrency() !=  "">
				<cfset arrayAppend( currencies, rc.itinerary.hotel.getRooms()[1].getBaseRateCurrency() ) />
			<cfelseif rc.itinerary.hotel.getRooms()[1].getDailyRateCurrency() !=  "">
				<cfset arrayAppend( currencies, rc.itinerary.hotel.getRooms()[1].getDailyRateCurrency() ) />
			<cfelse>
				<cfset arrayAppend( currencies, "" ) />
			</cfif>
		</cfif>
		<cfif val(rc.Filter.getCar())>
			<cfset arrayAppend( currencies, rc.itinerary.vehicle.getCurrency() ) />
		</cfif>

		<cfloop array="#currencies#" item="local.currency" index="local.idx">
			<cfif idx GT 1 AND currency NEQ currencies[ idx-1 ]>
				<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>
			</cfif>
		</cfloop>
		<!---End currency equality check--->

		<!---Save original selections to CouldYou log--->
		<cftry>
			<cfset fw.getBeanFactory().getBean( "CouldYouService" ).logOriginalTrip( rc.SearchID, rc.itinerary ) />
			<cfcatch type="any">
				<!---Log this error, but do not prevent the request from completing because we can't write the log entry--->
				<cfif variables.fw.getBeanFactory().getBean( 'EnvironmentService' ).getEnableBugLog()>
					 <cfset variables.fw.getBeanFactory().getBean('BugLogService').notifyService( message=cfcatch.Message, exception=rc, severityCode='Fatal' ) />
				 </cfif>
			</cfcatch>
		</cftry>

		<cfset rc.airSelected = (structKeyExists(rc.itinerary, 'Air') ? true : false)>
		<cfset rc.Air = (structKeyExists(rc.itinerary, 'Air') ? rc.itinerary.Air : '')>

		<cfset rc.hotelSelected = (structKeyExists(rc.itinerary, 'Hotel') ? true : false)>
		<cfset rc.Hotel = (structKeyExists(rc.itinerary, 'Hotel') ? rc.itinerary.Hotel : '')>

		<cfset rc.vehicleSelected = (structKeyExists(rc.itinerary, 'Vehicle') ? true : false)>
		<cfset rc.Vehicle = (structKeyExists(rc.itinerary, 'Vehicle') ? rc.itinerary.Vehicle : '')>

		<cfset rc.allTravelers = fw.getBeanFactory().getBean('UserService').getAuthorizedTravelers( userID = rc.Filter.getUserID()
																								, acctID = rc.Filter.getAcctID() )>
		<cfset rc.qOutOfPolicy = fw.getBeanFactory().getBean('Summary').getOutOfPolicy( acctID = rc.Filter.getAcctID()
																						, tmcID = rc.Account.tmc.getTMCID() )>
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

		<cfset var newVals = structNew() />
		<cfset newVals.searchId = rc.searchID />
		<cfset var Search = session.filters[ rc.searchId ] />
		<cfset var couldYou = session.searches[ rc.searchId ].couldYou />

		<cfif NOT structIsEmpty( couldYou ) AND rc.selectedDate NEQ rc.originalDate>

			<cfif Search.getAir()>
				<!---Update search object in session--->
				<cfset var tripLength = abs( dateDiff( "d", Search.getDepartDateTime(), Search.getArrivalDateTime() ) ) />
				<cfset var newArrivalDate = dateAdd( "d", tripLength, rc.selectedDate ) />
				<cfset var tripIDs = structKeyList( couldYou.air[ rc.selectedDate ] ) />
				<cfset var newFlight = couldYou.air[ rc.selectedDate ][ listGetAt( tripIDs, 1 ) ] />
				<cfset newFlight.nTrip = listGetAt( tripIDs, 1 ) />

				<!---This may need to be populated differently--->
				<cfset var newFlight.aPolicies = arrayNew(1) />
				<cfset var newFlight.policy = Search.getPolicyID() />
				<cfset newVals.departDateTime = createDateTime( year( rc.selectedDate ),
																 month( rc.selectedDate ),
																 day( rc.selectedDate ),
																 hour( Search.getDepartDateTime() ),
																 minute( Search.getDepartDateTime() ),
																 second( Search.getDepartDateTime() ) ) />
				<cfset newVals.arrivalDateTime = createDateTime( year( newArrivalDate ),
																  month( newArrivalDate ),
																  day( newArrivalDate ),
																  hour( Search.getArrivalDateTime() ),
																  minute( Search.getArrivalDateTime() ),
																  second( Search.getArrivalDateTime() ) ) />

				<cfif NOT Search.getHotel()>
					<cfset newVals.checkInDate = rc.selectedDate />
					<cfset newVals.checkOutDate = dateAdd( 'd', tripLength, rc.selectedDate ) />
					<cfset Search.setCheckInDate( newVals.checkInDate ) />
					<cfset Search.setCheckOutDate( newVals.checkOutDate ) />
				</cfif>

				<cfif NOT Search.getCar()>
					<cfset newVals.carPickupDate = rc.selectedDate />
					<cfset newVals.carDropoffDate = dateAdd( 'd', tripLength, rc.selectedDate ) />
					<cfset Search.setCarPickupDateTime( newVals.carPickupDate ) />
					<cfset Search.setCarDropoffDateTime( newVals.carDropoffDate ) />
				</cfif>

				<cfset Search.setDepartDateTime( newVals.departDateTime ) />
				<cfset Search.setArrivalDateTime( newVals.arrivalDateTime ) />

				<!---Update the stItinerary--->
				<cfset session.searches[ rc.searchId ].stItinerary.air = newFlight />

				<!---Update the stTrips--->
				<cfset session.searches[ rc.searchId ].stTrips[ newFlight.nTrip ] = newFlight />
			</cfif>

			<cfif Search.getHotel()>
				<!---Update search object in session--->
				<cfset var tripLength = abs( dateDiff( "d", Search.getCheckInDate(), Search.getCheckOutDate() ) ) />
				<cfset var newHotel = couldYou.hotel[ rc.selectedDate ] />
				<cfset newVals.checkInDate = rc.selectedDate />
				<cfset newVals.checkOutDate = dateAdd( 'd', tripLength, rc.selectedDate ) />
				<cfset Search.setCheckInDate( newVals.checkInDate ) />
				<cfset Search.setCheckOutDate( newVals.checkOutDate ) />

				<cfif NOT Search.getCar()>
					<cfset newVals.carPickupDate = rc.selectedDate />
					<cfset newVals.carDropoffDate = dateAdd( 'd', tripLength, rc.selectedDate ) />
					<cfset Search.setCarPickupDateTime( newVals.carPickupDate ) />
					<cfset Search.setCarDropoffDateTime( newVals.carDropoffDate ) />
				</cfif>


				<!---Update the stItinerary--->
				<cfset session.searches[ rc.searchId ].stItinerary.hotel = newHotel />

				<cfset variables.bf.getBean( "HotelService" ).getRoomRateRules( searchId=arguments.rc.searchId,
																				propertyId=newHotel.getPropertyID(),
																				ratePlanType=newHotel.getRooms()[1].getRatePlanType() ) />

			</cfif>

			<cfif Search.getCar()>
				<!---Update search object in session--->
				<cfset var tripLength = abs( dateDiff( "d", Search.getCarPickupDateTime(), Search.getCarDropoffDateTime() ) ) />
				<cfset var newDropOffDate = dateAdd( "d", tripLength, rc.selectedDate ) />
				<cfset var newVehicle = couldYou.vehicle[ rc.selectedDate ] />
				<cfset newVals.carPickupDate = createDateTime( year( rc.selectedDate ),
																	month( rc.selectedDate ),
																	day( rc.selectedDate ),
																	hour( Search.getCarPickupDateTime() ),
																	minute( Search.getCarPickupDateTime() ),
																	second( Search.getCarPickupDateTime() ) ) />
				<cfset newVals.carDropoffDate = createDateTime( year( newDropOffDate ),
																	month( newDropOffDate ),
																	day( newDropOffDate ),
																	hour( Search.getCarDropoffDateTime() ),
																	minute( Search.getCarDropoffDateTime() ),
																	second( Search.getCarDropoffDateTime() ) ) />

				<cfset Search.setCarPickupDateTime( newVals.carPickupDate ) />
				<cfset Search.setCarDropoffDateTime( newVals.carDropoffDate ) />

				<cfif NOT Search.getAir() AND NOT Search.getHotel()>
					<cfset newVals.checkInDate = rc.selectedDate />
					<cfset newVals.checkOutDate = dateAdd( 'd', tripLength, rc.selectedDate ) />
					<cfset Search.setCheckInDate( newVals.checkInDate ) />
					<cfset Search.setCheckOutDate( newVals.checkOutDate ) />
				</cfif>

				<!---Update the stItinerary--->
				<cfset session.searches[ rc.searchId ].stItinerary.vehicle = newVehicle />

			</cfif>

			<!---Update the selection in the CouldYou log table--->
			<cftry>
				<cfset variables.fw.getBeanFactory().getBean( "CouldYouService" ).selectTrip( rc.searchId, rc.selectedDate ) />

				<cfcatch type="any">
					<!---Log this error, but do not prevent the request from completing because we can't write the log entry--->
					<cfif variables.fw.getBeanFactory().getBean( 'EnvironmentService' ).getEnableBugLog()>
						 <cfset variables.fw.getBeanFactory().getBean('BugLogService').notifyService( message=cfcatch.Message, exception=rc, severityCode='Fatal' ) />
					 </cfif>
				</cfcatch>
			</cftry>


			<!---Save the updated search object to the database--->
			<cfset fw.getBeanFactory().getBean('SearchService').save( argumentCollection = newVals ) />



		</cfif>

		<!---Set lowest trip cost found by CouldYou--->
		<cfset var dates = "" />
			<cfset var tripLowPrice = 99999 />

			<cfif structKeyExists( session.searches[ rc.searchId ], "couldYou" ) AND structKeyExists( session.searches[ rc.searchId ].couldYou, "AIR") >
				<cfset dates = structKeyList( session.searches[ rc.searchId ].couldYou.air ) />
			<cfelseif structKeyExists( session.searches[ rc.searchId ], "couldYou" ) AND structKeyExists( session.searches[ rc.searchId ].couldYou, "HOTEL") >
				<cfset dates = structKeyList( session.searches[ rc.searchId ].couldYou.hotel ) />
			<cfelseif structKeyExists( session.searches[ rc.searchId ], "couldYou" ) AND structKeyExists( session.searches[ rc.searchId ].couldYou, "VEHICLE") >
				<cfset dates = structKeyList( session.searches[ rc.searchId ].couldYou.vehicle ) />
			</cfif>

			<cfloop list="#dates#" item="local.loopDate">
				<cfset var loopDateTotal = 0 />
				<cfset var includeDate = true />

				<cfif structKeyExists( session.searches[ rc.searchId ], "couldYou" )>
					<cfif  Search.getAir()
						AND structKeyExists( session.searches[ rc.searchId ].couldYou, "AIR" )
						AND structKeyExists( session.searches[ rc.searchId ].couldYou, loopDate )
						AND isStruct( session.searches[ rc.searchId ].couldYou.Air[ loopDate ] ) >

						<cfset loopDateTotal = loopDateTotal + session.searches[ rc.searchId ].couldYou.air[ loopDate ][ listGetAt( structKeyList(session.searches[ rc.searchId ].couldYou.air[ loopDate ] ), 1  ) ].TOTAL />

					<cfelse>
						<cfset includeDate = false />
					</cfif>

					<cfif Search.getHotel()
						AND structKeyExists( session.searches[ rc.searchid ].couldYou, "HOTEL" )
						AND structKeyExists( session.searches[ rc.searchId ].couldYou.Hotel, loopDate )
						AND isObject( session.searches[ rc.searchId ].couldYou.Hotel[ loopDate ] )
						AND isArray( session.searches[ rc.searchId ].couldYou.Hotel[ loopDate ].getRooms() )>

						<cfset loopDateTotal = loopDateTotal + session.searches[ rc.searchId ].couldYou.Hotel[ loopDate ].getRooms()[ 1 ].getTotalForStay() />

					<cfelse>
						<cfset includeDate = false />
					</cfif>

					<cfif Search.getCar()
						AND structKeyExists( session.searches[ rc.searchid ].couldYou, "VEHICLE" )
						AND structKeyExists( session.searches[ rc.searchid ].couldYou.Vehicle, loopDate )
						AND isObject( session.searches[ rc.searchId ].couldYou.Vehicle[ loopDate ] ) >

						<cfset loopDateTotal = loopDateTotal + session.searches[ rc.searchId ].couldYou.vehicle[ loopDate ].getEstimatedTotalAmount() />

					<cfelse>
						<cfset includeDate = false />
					</cfif>
				</cfif>

				<cfif includeDate>
					<cfif loopDateTotal NEQ 0 AND loopDateTotal LT tripLowPrice>
						<cfset tripLowPrice = loopDateTotal />
					</cfif>
				</cfif>
			</cfloop>

			<cfset session.searches[ rc.searchId ].lowestCouldYouRate = tripLowPrice />


		<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>

	</cffunction>
</cfcomponent>