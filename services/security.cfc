<cfcomponent output="false">
	
<!--- session : search --->
	<cffunction name="search" access="remote" output="false" returntype="void">
		<cfargument name="SearchID" 	required="true">
		<cfargument name="Append" 		required="false" default="0" > 

		<cfset local.searchfilter = createObject("component", "booking.model.searchfilter").init()>

		<!--- Testing setting --->
		<cfset local.refresh = 0>
		
		<cfset local.done = 0>
		<cfif StructKeyExists(session, 'filters')
		AND IsStruct(session.filters)
		AND StructKeyExists(session.filters, arguments.SearchID)>
			<cfset done = 1>
		</cfif>

		<cfif NOT done OR refresh>
			<cfif NOT StructKeyExists(session, 'searches') OR NOT IsStruct(session.searches)>
				<cfset session.searches = StructNew()>
			</cfif>
			<cfif NOT StructKeyExists(session, 'aMessages') OR NOT IsArray(session.aMessages)>
				<cfset session.aMessages = []>
			</cfif>
			
			<!--- 
			Create a shell structure.  Could be done below but cleaner code seeing all the
			elements at once.
			--->
			
			<cfquery name="local.getsearch" datasource="book">
			SELECT TOP 1 Acct_ID, Search_ID, Air, Car, Hotel, Policy_ID, Profile_ID, Value_ID, User_ID, Username,
			Air_Type, Depart_City, Depart_DateTime, Arrival_City, Arrival_DateTime, Airlines, International, Depart_TimeType,
			Arrival_TimeType, ClassOfService
			FROM Searches
			WHERE Search_ID = <cfqueryparam value="#arguments.SearchID#" cfsqltype="cf_sql_integer">
			ORDER BY Search_ID DESC
			</cfquery>
			<cfif getsearch.Air_Type EQ 'MD'>
				<cfquery name="local.getsearchlegs" datasource="book">
				SELECT Depart_City, Arrival_City, Depart_DateTime, Depart_TimeType
				FROM Searches_Legs
				WHERE Search_ID = <cfqueryparam value="#arguments.SearchID#" cfsqltype="cf_sql_numeric" />
				</cfquery>
			</cfif>

			<!--- Search related items --->
			<cfset searchfilter.setSearchID(getsearch.Search_ID)>
			<cfset searchfilter.setAir(getsearch.Air EQ 1 ? true : false)>
			<cfset searchfilter.setCar(getsearch.Car EQ 1 ? true : false)>
			<cfset searchfilter.setHotel(getsearch.Hotel EQ 1 ? true : false)>
			<cfset searchfilter.setAirType(getsearch.Air_Type)>
			<cfset searchfilter.setDepartCity(getsearch.Depart_City)>
			<cfset searchfilter.setDepartDate(getsearch.Depart_DateTime)>
			<cfset searchfilter.setDepartType(getsearch.Depart_TimeType)>
			<cfset searchfilter.setArrivalCity(getsearch.Arrival_City)>
			<cfset searchfilter.setArrivalDate(getsearch.Arrival_DateTime)>
			<cfset searchfilter.setArrivalType(getsearch.Arrival_TimeType)>
			<cfset searchfilter.setAirlines(getsearch.Airlines)>
			<cfset searchfilter.setInternational(getsearch.International EQ 1 ? true : false)>
			<cfset searchfilter.setCOS(getsearch.ClassOfService)>
			<cfset searchfilter.setProfileID(getsearch.Profile_ID)>
			<cfset searchfilter.setPolicyID(getsearch.Policy_ID)>
			<cfset searchfilter.setValueID(getsearch.Value_ID)>
			<cfset searchfilter.setUserID(getsearch.User_ID)>
			<cfset searchfilter.setAcctID(getsearch.Acct_ID)>
			<cfset searchfilter.setUsername(getsearch.Username)>

			<cfif getsearch.Profile_ID EQ getsearch.User_ID>
				<cfset searchfilter.setBookingFor('')><!--- Booking for themselves --->
			<cfelseif getsearch.Profile_ID EQ 0>
				<cfset searchfilter.setBookingFor('Guest Traveler')><!--- Guest traveler --->
			<cfelse>
				<cfquery name="local.getuser" datasource="Corporate_Production">
				SELECT First_Name, Last_Name, Email
				FROM Users
				WHERE User_ID = <cfqueryparam value="#getsearch.Profile_ID#" cfsqltype="cf_sql_integer" >
				</cfquery>
				<cfset searchfilter.setBookingFor(getuser.First_Name&' '&getuser.Last_Name)><!--- Booking for someone else --->
			</cfif>
			
			<!--- Round trip tab --->
			<cfif getsearch.Air AND getsearch.Air_Type EQ 'RT'>
				<cfif DateFormat(getsearch.Depart_DateTime) NEQ DateFormat(getsearch.Arrival_DateTime)>
					<cfset searchfilter.setHeading(getsearch.Depart_City&'-'&getsearch.Arrival_City&' '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')&' to '&DateFormat(getsearch.Arrival_DateTime, 'm/d'))>
				<cfelse>
					<cfset searchfilter.setHeading(getsearch.Depart_City&'-'&getsearch.Arrival_City&' '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d'))>
				</cfif>
				<cfset searchfilter.setDestination(application.stAirports[getsearch.Arrival_City])>
				<cfset searchfilter.addLeg(getsearch.Depart_City&' to '&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d'))>
				<cfset searchfilter.addLeg(getsearch.Arrival_City&' to '&getsearch.Depart_City&' on '&DateFormat(getsearch.Arrival_DateTime, 'ddd, m/d'))>
			<!--- One way trip tab --->
			<cfelseif getsearch.Air AND getsearch.Air_Type EQ 'OW'>
				<cfset searchfilter.setHeading(getsearch.Depart_City&'-'&getsearch.Arrival_City&' '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d'))>
				<cfset searchfilter.setDestination(application.stAirports[getsearch.Arrival_City])>
				<cfset searchfilter.addLeg(getsearch.Depart_City&' to '&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d'))>
			<!--- Multi destination trip tab --->
			<cfelseif getsearch.Air AND getsearch.Air_Type EQ 'MD'>
				<!---<cfset searchfilter.setDestination('')>
				<cfset searchfilter.setHeading(getsearch.Depart_City&'-'&getsearch.Arrival_City&' '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d'))>
				<cfset tab.Heading = getsearch.Depart_City&'-'&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')&' '>--->
				<!---<cfset tab.Legs[0] = getsearch.Depart_City&' to '&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')>
				<cfloop query="getsearchlegs">
					<cfset tab.Heading = tab.Heading&getsearchlegs.Depart_City&'-'&getsearchlegs.Arrival_City&' on '&DateFormat(getsearchlegs.Depart_DateTime, 'ddd, m/d')&' '>
					<cfset tab.Legs[getsearchlegs.CurrentRow] = getsearchlegs.Depart_City&' to '&getsearchlegs.Arrival_City&' on '&DateFormat(getsearchlegs.Depart_DateTime, 'ddd, m/d')>
				</cfloop>--->
			<cfelseif NOT getsearch.Air AND getsearch.Car>
				<cfset searchfilter.setDestination(application.stAirports[getsearch.Arrival_City])>
			</cfif>

			<cfset session.AcctID = getSearch.Acct_ID>
			<cfset session.PolicyID = getSearch.Policy_ID>
			<cfset session.filters[arguments.SearchID] = searchfilter>
			<cfset session.searches[arguments.SearchID].stAvailTrips[0] = {}>
			<cfset session.searches[arguments.SearchID].stAvailTrips[1] = {}>
			<cfset session.searches[arguments.SearchID].stAvailTrips[2] = {}>
			<cfset session.searches[arguments.SearchID].stAvailTrips[3] = {}>
			<cfset session.searches[arguments.SearchID].stAvailDetails = {}>
			<cfset session.searches[arguments.SearchID].stAvailDetails.stGroups = {}>
			<cfset session.searches[arguments.SearchID].stTrips = {}>
			<cfset session.searches[arguments.SearchID].stLowFareDetails.stPricing = {}>
			<cfset session.searches[arguments.SearchID].stLowFareDetails.stPriced = {}>
			<cfset session.searches[arguments.SearchID].stLowFareDetails.aCarriers = {}>
			<cfset session.searches[arguments.SearchID].stLowFareDetails.stResults = {}>
			<cfset session.searches[arguments.SearchID].stItinerary = {}>
			<cfset session.searches[arguments.SearchID].stSelected[1] = {}>
			<cfset session.searches[arguments.SearchID].stSelected[2] = {}>
			<cfset session.searches[arguments.SearchID].stSelected[3] = {}>
			<cfset session.searches[arguments.SearchID].stSelected[0] = {}>

		</cfif>

		<cfreturn />
	</cffunction>
	
<!--- close --->
	<cffunction name="close" output="false">
		<cfargument name="SearchID">
		
		<cfset local.temp = StructDelete(session.searches, arguments.SearchID)>
		<cfset local.nNewSearchID = ''>
		<cfloop collection="#session.searches#" item="local.SearchID">
			<cfset nNewSearchID = SearchID>
			<cfbreak>
		</cfloop>
		
		<cfreturn nNewSearchID/>
	</cffunction>
	
</cfcomponent>