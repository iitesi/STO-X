<cfcomponent output="false">

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

	<cffunction name="car" output="false">
		<cfargument name="rc">

		<cfset rc.Vehicle = fw.getBeanFactory().getBean('VehicleAdapter').load( session.searches[rc.SearchID].stItinerary.Car )>

		<cfset rc.Traveler = fw.getBeanFactory().getBean('UserService').load( 3605 )>

		<cfset rc.LoyaltyProgram = fw.getBeanFactory().getBean('LoyaltyProgramService').load( 3605, '', 'c' )>
		<cfset rc.Traveler.addLoyaltyProgram( rc.LoyaltyProgram )>

		<cfset rc.Payment = fw.getBeanFactory().getBean('PaymentService').load( 1, 0, rc.Vehicle.getVendorCode() )>

		<cfset rc.ccEmails = fw.getBeanFactory().getBean('UserService').getUserCCEmails( 3605, 'string' )>
		<cfset rc.Traveler.setCCEmails( rc.ccEmails )>

		<cfset rc.homeAirport = fw.getBeanFactory().getBean('UserService').getAirportPrefs( 3605, 1, 'string' )>
		<cfset rc.Traveler.setHomeAirport( rc.homeAirport )>

		<cfset rc.userSort = fw.getBeanFactory().getBean('UserService').getUserSorts( 3605, 1, 1, 'string' )>
		<cfset rc.Traveler.setSort1( rc.userSort )>

		<cfset rc.userSort = fw.getBeanFactory().getBean('UserService').getUserSorts( 3605, 1, 2, 'string' )>
		<cfset rc.Traveler.setSort2( rc.userSort )>

		<cfset rc.userSort = fw.getBeanFactory().getBean('UserService').getUserSorts( 3605, 1, 3, 'string' )>
		<cfset rc.Traveler.setSort3( rc.userSort )>

		<cfset rc.userSort = fw.getBeanFactory().getBean('UserService').getUserSorts( 3605, 1, 4, 'string' )>
		<cfset rc.Traveler.setSort4( rc.userSort )>

		<cfset rc.accountID = fw.getBeanFactory().getBean('UserService').getAccountID( 3605, 1, 'string' )>
		<cfset rc.Traveler.setAccountID( rc.accountID )>

		<cfset rc.branchID = fw.getBeanFactory().getBean('UserService').getBranchID( 1, 'string' )>
		<cfset rc.Traveler.setBranchID( rc.branchID )>

		<cfset rc.message = fw.getBeanFactory().getBean('VehicleAdapter').create( rc.Traveler, rc.Payment, rc.Vehicle, rc.Filter )>
		
		<cfset rc.response = fw.getBeanFactory().getBean('UAPI').callUAPI( 'VehicleService', rc.message )>

		<cfset rc.Vehicle = fw.getBeanFactory().getBean('VehicleAdapter').parseVehicleRsp( rc.Vehicle, rc.response )>

		<cfif rc.Vehicle.getConfirmation() EQ ''>
			<cfset rc.errorMessage = fw.getBeanFactory().getBean('UAPI').parseError( rc.response )>
			<cfdump var="#rc.errorMessage#" abort="true">
		<cfelse>
			<cfdump var="#rc.Vehicle#" abort="true">
		</cfif>
		
		<!--- <cfdump var="#rc.Traveler#">
		<cfdump var="#rc.Payment#">
		<cfdump var="#rc.Vehicle#">
		<cfdump var="#rc.Filter#"> --->

		<cfabort>

		<cfreturn />
	</cffunction>
	
</cfcomponent>