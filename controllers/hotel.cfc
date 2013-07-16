<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfreturn />
	</cffunction>

	<cffunction name="before" output="false">
		<cfargument name="rc">

		<cfset fw.getBeanFactory().getBean('car').doAvailability(argumentcollection=arguments.rc)>

		<cfreturn />
	</cffunction>

	<cffunction name="search" output="false">
		<cfargument name="rc">

		<cfreturn />
	</cffunction>

	<cffunction name="select">
		<cfargument name="rc" />

		<cfset variables.bf.getBean( "HotelService" ).selectRoom( searchId=arguments.rc.searchId,
													 propertyId=arguments.rc.propertyId,
													 ratePlanType=arguments.rc.ratePlanType,
													 totalForStay=arguments.rc.totalForStay,
													 isInPolicy=arguments.rc.isInPolicy ) />

		<cfif arguments.rc.Filter.getCar() AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Car')>

			<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.Filter.getSearchID()#')>

		<cfelseif arguments.rc.Filter.getCar()
			AND StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Car')
			AND application.accounts[ arguments.rc.Filter.getAcctID() ].couldYou EQ 1>

			<cfset variables.fw.redirect('couldyou?SearchID=#arguments.rc.Filter.getSearchID()#')>

		<cfelse>

			<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>

		</cfif>

	</cffunction>


	<cffunction name="skip" output="false">
		<cfargument name="rc" />

		<cfset variables.fw.service('hotelsearch.skipHotel', 'void')>

		<cfif arguments.rc.Filter.getCar() AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Car')>
			<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.Filter.getSearchID()#')>
		</cfif>
		<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>

		<cfreturn />
	</cffunction>

</cfcomponent>