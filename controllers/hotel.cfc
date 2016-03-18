<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfreturn />
	</cffunction>

	<cffunction name="search" output="false">
		<cfargument name="rc">

		<cfset arguments.rc.nFromHotel = 1 />
		<cfset fw.getBeanFactory().getBean('car').doAvailability(argumentcollection=arguments.rc)>

		<cfset arguments.rc.shortsAPIURL = fw.getBeanFactory().getBean('EnvironmentService').getShortsAPIURL() />
		<cfreturn />
	</cffunction>

	<cffunction name="select" output="false">
		<cfargument name="rc" />

		<cfset local.ppnBundle = replace(arguments.rc.ppnBundle, "xxx", "%", "ALL") />

		<cfset local.HotelService = variables.bf.getBean( "HotelService" ) />
		<cfset local.success = local.HotelService.selectRoom( searchId=arguments.rc.searchId,
												 propertyId=arguments.rc.propertyId,
												 ratePlanType=arguments.rc.ratePlanType,
												 ppnBundle=ppnBundle,
												 totalForStay=arguments.rc.totalForStay,
												 isInPolicy=arguments.rc.isInPolicy,
												 outOfPolicyMessage=arguments.rc.outOfPolicyMessage ) />

		<cfset local.HotelService.getRoomRateRules( searchId=arguments.rc.searchId,
												 	propertyId=arguments.rc.propertyId,
												 	ratePlanType=arguments.rc.ratePlanType,
												 	ppnBundle=ppnBundle ) />
		<cfif NOT arguments.rc.Filter.getHotel()>
			<cfset arguments.rc.Filter.setHotel( true ) />
			<cfset variables.bf.getBean( "SearchService" ).save( searchID=arguments.rc.searchId, hotel=true ) />
		</cfif>

		<cfset var hotelLowPrice = 99999 />

		<cfset local.hotels=HotelService.readHotels(arguments.rc.Filter.getSearchID())>
		<cfloop array="#hotels#" item="local.loopHotel">
			<cfset var loopHotelLowPrice = loopHotel.findLowestRoomRate() />
			<cfif loopHotelLowPrice NEQ 0 AND loopHotelLowPrice LT hotelLowPrice>
				<cfset hotelLowPrice = loopHotelLowPrice />
			</cfif>
		</cfloop>

		<cfset session.searches[ arguments.rc.Filter.getSearchID() ].lowestHotelRate = hotelLowPrice />

		<cfif arguments.rc.Filter.getCar() AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'vehicle')>
			<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.Filter.getSearchID()#')>
		<cfelseif arguments.rc.Filter.getCar()
			AND StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Vehicle')
			AND application.accounts[ arguments.rc.Filter.getAcctID() ].couldYou EQ 1>

			<cfset variables.fw.redirect('couldyou?SearchID=#arguments.rc.Filter.getSearchID()#')>
		<cfelseif NOT arguments.rc.Filter.getCar() AND application.accounts[ arguments.rc.Filter.getAcctID() ].couldYou EQ 1>
			<cfset variables.fw.redirect('couldyou?SearchID=#arguments.rc.Filter.getSearchID()#')>
		<cfelse>
			<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>
		</cfif>

	</cffunction>

	<cffunction name="skip" output="false">
		<cfargument name="rc" />

		<cfset arguments.rc.Filter.setHotel( false ) />
		<cfset variables.bf.getBean( "SearchService" ).save( searchID=arguments.rc.searchId, hotel=false ) />
		<cfif structKeyExists( session.searches[ arguments.rc.searchId ].stItinerary, "Hotel" )>
			<cfset structDelete( session.searches[ arguments.rc.searchId ].stItinerary, "Hotel" ) />
		</cfif>
		
		<cfset local.HotelService = variables.bf.getBean( "HotelService" ) />
		<cfset HotelService.skipHotels(arguments.rc.searchId)>
		
		<cfif structKeyExists( session.searches[ arguments.rc.searchId ], "CouldYou" ) AND structKeyExists( session.searches[ arguments.rc.searchId ].CouldYou, "Hotel" )>
			<cfset structDelete( session.searches[ arguments.rc.searchId ].CouldYou, "Hotel" ) />
		</cfif>

		<cfif arguments.rc.Filter.getCar() AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'vehicle')>
			<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.Filter.getSearchID()#')>
		<cfelseif arguments.rc.Filter.getCar()
			AND StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Vehicle')
			AND application.accounts[ arguments.rc.Filter.getAcctID() ].couldYou EQ 1>

			<cfset variables.fw.redirect('couldyou?SearchID=#arguments.rc.Filter.getSearchID()#')>
		<cfelseif NOT arguments.rc.Filter.getCar() AND application.accounts[ arguments.rc.Filter.getAcctID() ].couldYou EQ 1>
			<cfset variables.fw.redirect('couldyou?SearchID=#arguments.rc.Filter.getSearchID()#')>
		<cfelse>
			<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>
		</cfif>

	</cffunction>

</cfcomponent>