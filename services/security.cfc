<cfcomponent output="false">
	
<!--- session : search --->
	<cffunction name="search" access="remote" output="false" returntype="void">
		<cfargument name="Search_ID" 	required="true"> 
		<cfargument name="Append" 		required="false" default="0" > 
		
		<!--- Testing setting --->
		<cfset local.refresh = 0>
		
		<cfset local.done = 0>
		<cfif StructKeyExists(session, 'searches')
		AND IsStruct(session.searches)
		AND StructKeyExists(session.searches, arguments.Search_ID)
		AND StructKeyExists(session.searches[arguments.Search_ID], 'nPolicyID')>
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
			WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_integer">
			ORDER BY Search_ID DESC
			</cfquery>
			<cfif getsearch.Air_Type EQ 'MD'>
				<cfquery name="local.getsearchlegs" datasource="book">
				SELECT Depart_City, Arrival_City, Depart_DateTime, Depart_TimeType
				FROM Searches_Legs
				WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
				</cfquery>
			</cfif>

			<cfset local.tab = {}>
			<!--- Search related items --->
			<cfset tab.bAir = getsearch.Air EQ 1 ? true : false>
			<cfset tab.bCar = getsearch.Car EQ 1 ? true : false>
			<cfset tab.bHotel = getsearch.Hotel EQ 1 ? true : false>
			<cfset tab.sAirType = getsearch.Air_Type>
			<cfset tab.sDepartCity = getsearch.Depart_City>
			<cfset tab.dDepartDate = getsearch.Depart_DateTime>
			<cfset tab.sDepartType = getsearch.Depart_TimeType>
			<cfset tab.sArrivalCity = getsearch.Arrival_City>
			<cfset tab.dArrivalDate = getsearch.Arrival_DateTime>
			<cfset tab.sArrivalType = getsearch.Arrival_TimeType>
			<cfset tab.sAirlines = getsearch.Airlines>
			<cfset tab.bInternational = getsearch.International EQ 1 ? true : false>
			<cfset tab.sCOS = getsearch.ClassOfService>
			<cfset tab.sBookingFor = ''>
			<cfset tab.sDestination = ''>
			<cfset tab.sHeading = ''>
			<cfset tab.nProfileID = getsearch.Profile_ID>
			<cfset tab.nPolicyID = getsearch.Policy_ID>
			<cfset tab.nValueID = getsearch.Value_ID>
			<cfset tab.stLegs = StructNew('linked')>
			<cfset tab.stItinerary = {}>
			<!--- Air - low fare search --->
			<cfset tab.stTrips = {}>
			<cfset tab.stLowFareDetails = {}>
			<cfset tab.stLowFareDetails.aCarriers = {}>
			<cfset tab.stLowFareDetails.stPricing = {}>
			<cfset tab.stLowFareDetails.stResults = {}>
			<cfset tab.stLowFareDetails.stPriced = {}>
			<cfset tab.stLowFareDetails.aSortArrival = []>
			<cfset tab.stLowFareDetails.aSortBag = []>
			<cfset tab.stLowFareDetails.aSortDepart = []>
			<cfset tab.stLowFareDetails.aSortDuration = []>
			<cfset tab.stLowFareDetails.aSortFare = []>
			<!--- Air - availability search --->
			<cfset tab.stAvailTrips = {}>
			<cfset tab.stSelected = StructNew('linked')><!--- Place holder for selected legs --->
			<cfset tab.stSelected[0] = {}>
			<cfset tab.stSelected[1] = {}>
			<cfset tab.stSelected[2] = {}>
			<cfset tab.stSelected[3] = {}>
			<cfset tab.stAvailTrips[0] = {}><!--- Leg details by group --->
			<cfset tab.stAvailTrips[1] = {}>
			<cfset tab.stAvailTrips[2] = {}>
			<cfset tab.stAvailTrips[3] = {}>
			<cfset tab.stAvailDetails.stGroups = {}>
			<cfset tab.stAvailDetails.stCarriers = {}>
			
			<cfif getsearch.Profile_ID EQ getsearch.User_ID>
				<cfset tab.sBookingFor = ''><!--- Booking for themselves --->
			<cfelseif getsearch.Profile_ID EQ 0>
				<cfset tab.sBookingFor = 'Guest Traveler'><!--- Guest traveler --->
			<cfelse>
				<cfquery name="local.getuser" datasource="Corporate_Production">
				SELECT First_Name, Last_Name, Email
				FROM Users
				WHERE User_ID = <cfqueryparam value="#getsearch.Profile_ID#" cfsqltype="cf_sql_integer" >
				</cfquery>
				<cfset tab.sBookingFor = getuser.First_Name&' '&getuser.Last_Name><!--- Booking for someone else --->
			</cfif>
			
			<!--- Round trip tab --->
			<cfif getsearch.Air AND getsearch.Air_Type EQ 'RT'>
				<cfif DateFormat(getsearch.Depart_DateTime) NEQ DateFormat(getsearch.Arrival_DateTime)>
					<cfset tab.sHeading = getsearch.Depart_City&'-'&getsearch.Arrival_City&' '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')&' to '&DateFormat(getsearch.Arrival_DateTime, 'm/d')>
				<cfelse>
					<cfset tab.sHeading = getsearch.Depart_City&'-'&getsearch.Arrival_City&' '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')>
				</cfif>
				<cfset tab.sDestination = application.stAirports[getsearch.Arrival_City]>
				<cfset tab.stLegs[0] = getsearch.Depart_City&' to '&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')>
				<cfset tab.stLegs[1] = getsearch.Arrival_City&' to '&getsearch.Depart_City&' on '&DateFormat(getsearch.Arrival_DateTime, 'ddd, m/d')>
			<!--- One way trip tab --->
			<cfelseif getsearch.Air AND getsearch.Air_Type EQ 'OW'>
				<cfset tab.sHeading = getsearch.Depart_City&'-'&getsearch.Arrival_City&' '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')>
				<cfset tab.sDestination = application.stAirports[getsearch.Arrival_City]>
				<cfset tab.stLegs[0] = getsearch.Depart_City&' to '&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')>
			<!--- Multi destination trip tab --->
			<cfelseif getsearch.Air AND getsearch.Air_Type EQ 'MD'>
				<cfset tab.sDestination = ''>
				<cfset tab.sHeading = getsearch.Depart_City&'-'&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')&' '>
				<cfset tab.stLegs[0] = getsearch.Depart_City&' to '&getsearch.Arrival_City&' on '&DateFormat(getsearch.Depart_DateTime, 'ddd, m/d')>
				<cfloop query="getsearchlegs">
					<cfset tab.sHeading = tab.sHeading&getsearchlegs.Depart_City&'-'&getsearchlegs.Arrival_City&' on '&DateFormat(getsearchlegs.Depart_DateTime, 'ddd, m/d')&' '>
					<cfset tab.stLegs[getsearchlegs.CurrentRow] = getsearchlegs.Depart_City&' to '&getsearchlegs.Arrival_City&' on '&DateFormat(getsearchlegs.Depart_DateTime, 'ddd, m/d')>
				</cfloop>
			<cfelseif NOT getsearch.Air AND getsearch.Car>
				<cfset tab.sDestination = application.stAirports[getsearch.Arrival_City]>
			</cfif>
			
			<cflock timeout="30" scope="session" type="exclusive">
				<cfset session.searches[arguments.Search_ID] = tab>
				<cfset session.User_ID = getsearch.User_ID>
				<cfset session.Username = getsearch.Username>
				<cfset session.Acct_ID = getsearch.Acct_ID>
			</cflock>
		</cfif>
		
		<cfreturn />
	</cffunction>
	
<!--- close --->
	<cffunction name="close" output="false">
		<cfargument name="nSearchID"> 
		
		<cfset local.temp = StructDelete(session.searches, arguments.nSearchID)>
		<cfset local.nNewSearchID = ''>
		<cfloop collection="#session.searches#" item="local.nSearchID">
			<cfset nNewSearchID = nSearchID>
			<cfbreak>
		</cfloop>
		
		<cfreturn nNewSearchID/>
	</cffunction>
	
</cfcomponent>