<cfcomponent extends="abstract" output="false">

	<cfset variables.fw = "">
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="fw">

		<cfset variables.fw = arguments.fw>
		<cfset variables.bf = fw.getBeanFactory()>

		<cfreturn this>
	</cffunction>

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<!--- <cfset rc.stAir = session.searches[arguments.rc.SearchID].stItinerary.Air>
		<cfset variables.bf.getBean("AirCreate").doAirCreate(argumentcollection=arguments.rc)> --->
		<!--- <cfset session.Users[1] = fw.getBeanFactory().getBean('TravelerService').load(3605, 1)>
		<cfset rc.stItinerary = session.searches[rc.SearchID].stItinerary> --->

		<cfreturn />
	</cffunction>

	<cffunction name="hotel" output="false">
		<cfargument name="rc">

		<cfset rc.Hotel = session.searches[rc.searchID].stItinerary.Hotel>

		<cfset rc.Traveler = fw.getBeanFactory().getBean('UserService').load( session.userID )>

		<cfset rc.Traveler.addLoyaltyProgram( fw.getBeanFactory().getBean('LoyaltyProgramService').load( session.userID, '', 'h' ) )>

		<cfset rc.Payment = fw.getBeanFactory().getBean('PaymentService').new( )>
		<cfset rc.Payment.setAcctNum( '4111111111111111' )>
		<cfset rc.Payment.setExpireDate( createDate( 2014, 06, 30 ) )>
		<cfset rc.Payment.setHotelUse( true )>
		<cfset rc.Payment.setFOPCode( 'VI' )>

		<cfset rc.Traveler.setCCEmails( fw.getBeanFactory().getBean('UserService').getUserCCEmails( session.userID, 'string' ) )>
		<cfset rc.Traveler.setHomeAirport( fw.getBeanFactory().getBean('UserService').getAirportPrefs( session.userID, session.acctID, 'string' ) )>

		<cfset rc.Traveler.setSort1( fw.getBeanFactory().getBean('UserService').getUserSorts( session.userID, session.acctID, 1, 'string' ) )>
		<cfset rc.Traveler.setSort2( fw.getBeanFactory().getBean('UserService').getUserSorts( session.userID, session.acctID, 2, 'string' ) )>
		<cfset rc.Traveler.setSort3( fw.getBeanFactory().getBean('UserService').getUserSorts( session.userID, session.acctID, 3, 'string' ) )>
		<cfset rc.Traveler.setSort4( fw.getBeanFactory().getBean('UserService').getUserSorts( session.userID, session.acctID, 4, 'string' ) )>

		<cfset rc.Traveler.setAccountID( fw.getBeanFactory().getBean('UserService').getAccountID( session.userID, session.acctID, 'string' ) )>
		<cfset rc.Traveler.setBranchID( fw.getBeanFactory().getBean('UserService').getBranchID( session.acctID, 'string' ) )>

		<cfset rc.response = fw.getBeanFactory().getBean('HotelAdapter').create( rc.Traveler, rc.Payment, rc.Hotel, rc.Filter )>

		<cfset rc.Hotel = fw.getBeanFactory().getBean('HotelAdapter').parseHotelRsp( rc.Hotel, rc.response )>

		<cfif rc.Hotel.getConfirmation() EQ ''>
			<cfset rc.errorMessage = fw.getBeanFactory().getBean('UAPI').parseError( rc.response )>
			<cfdump var="#rc.errorMessage#" abort="true">
		<cfelse>
			<cfdump var="#rc.Hotel#" abort="true">
		</cfif>

		<!--- <cfdump var="#rc.Traveler#">
		<cfdump var="#rc.Payment#">
		<cfdump var="#rc.Vehicle#">
		<cfdump var="#rc.Filter#"> --->

		<cfabort>

		<cfreturn />
	</cffunction>

	<cffunction name="car" output="false">
		<cfargument name="rc">

		<cfset rc.Vehicle = session.searches[rc.SearchID].stItinerary.Vehicle>

		<cfset rc.Traveler.setHomeAirport( fw.getBeanFactory().getBean('UserService').getAirportPrefs( session.userID, session.acctID, 'string' ) )>
		<cfset rc.Traveler.setAccountID( fw.getBeanFactory().getBean('UserService').getAccountID( session.userID, session.acctID, 'string' ) )>
		<cfset rc.Traveler.setBranchID( fw.getBeanFactory().getBean('UserService').getBranchID( session.acctID, 'string' ) )>

		<cfset rc.response = fw.getBeanFactory().getBean('VehicleAdapter').create( rc.Traveler, rc.Payment, rc.Vehicle, rc.Filter )>

		<cfset rc.Vehicle = fw.getBeanFactory().getBean('VehicleAdapter').parseVehicleRsp( rc.Vehicle, rc.response )>

		<cfif rc.Vehicle.getConfirmation() EQ ''>
			<cfset rc.errorMessage = fw.getBeanFactory().getBean('UAPI').parseError( rc.response )>
			<cfdump var="#rc.errorMessage#" abort="true">
		<cfelse>
			<cfdump var="#rc.Vehicle#" abort="true">
		</cfif>

		<cfabort>

		<cfreturn />
	</cffunction>

</cfcomponent>