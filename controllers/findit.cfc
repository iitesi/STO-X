<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfsavecontent variable="trip">
			{'TOTAL':'225.80','NTRIPKEY':'1494427677','DEPART':createDateTime(2013,9,26,6,30,0,0,"America/Chicago"),'CLASS':'Y','PRIVATEFARE':false,'PREFERRED':0,'PTC':'ADT','REF':1,'STOPS':0,'TOTALBAG':225.8,'CARRIERS':['WN'],'DURATION':130,'APOLICIES':[],'BASE':'189.77','ARRIVAL':createDateTime(2013,9,27,10,55,0,0,"America/Chicago"),'CHANGEPENALTY':0,'POLICY':1,'TOTALBAG2':225.8,'TAXES':'36.03','GROUPS':{'0':{'STOPS':0,'DEPARTURETIME':createDateTime(2013,9,26,6,30,0,0,"America/Chicago"),'SEGMENTS':{'21T':{'CABIN':'Economy','ChangeOfPlane':false,'DepartureTime':createDateTime(2013,9,26,6,30,0,0,"America/Chicago"),'Origin':'LAS','CLASS':'M','Equipment':'737','ArrivalGMT':createDateTime(2013,9,26,16,35,0,0,"America/Chicago"),'Destination':'LAX','FlightTime':'65','DepartureGMT':createDateTime(2013,9,26,13,30,0,0,"America/Chicago"),'TravelTime':'65','Carrier':'WN','Group':'0','ArrivalTime':createDateTime(2013,9,26,7,35,0,0,"America/Chicago"),'FlightNumber':'4554'}},'TRAVELTIME':'1h 5m','ORIGIN':'LAS','DESTINATION':'LAX','ARRIVALTIME':createDateTime(2013,9,26,7,35,0,0,"America/Chicago")},'1':{'STOPS':0,'DEPARTURETIME':createDateTime(2013,9,27,9,50,0,0,"America/Chicago"),'SEGMENTS':{'48T':{'CABIN':'Economy','ChangeOfPlane':false,'DepartureTime':createDateTime(2013,9,27,9,50,0,0,"America/Chicago"),'Origin':'LAX','CLASS':'O','Equipment':'733','ArrivalGMT':createDateTime(2013,9,27,19,55,0,0,"America/Chicago"),'Destination':'LAS','FlightTime':'65','DepartureGMT':createDateTime(2013,9,27,16,50,0,0,"America/Chicago"),'TravelTime':'65','Carrier':'WN','Group':'1','ArrivalTime':createDateTime(2013,9,27,10,55,0,0,"America/Chicago"),'FlightNumber':'598'}},'TRAVELTIME':'1h 5m','ORIGIN':'LAX','DESTINATION':'LAS','ARRIVALTIME':createDateTime(2013,9,27,10,55,0,0,"America/Chicago")}},'SJAVASCRIPT':'"1494427677",1,0,["WN"],"1",0,"Y",0'}
		</cfsavecontent>

		<cfset trip = deserializeJSON(trip)>

		<cfset local.stSelected = StructNew("linked")>
		<cfset stSelected[0].Groups = StructNew("linked")>
		<cfset stSelected[1].Groups = StructNew("linked")>
		<cfset stSelected[2].Groups = StructNew("linked")>
		<cfset stSelected[3].Groups = StructNew("linked")>
		<cfloop collection="#trip.Groups#" item="local.Group">
			<cfset stSelected[Group].Groups[0] = trip.Groups[Group]>
		</cfloop>

		<cfset local.pricedTrip = fw.getBeanFactory().getBean('AirPrice').doAirPrice( searchID = rc.SearchID
																					, Account = rc.Account
																					, Policy = rc.Policy
																					, sCabin = trip.Class
																					, bRefundable = trip.Ref
																					, nTrip = ''
																					, nCouldYou = 0
																					, bSaveAirPrice = 0 
																					, stSelected = stSelected)>

		<cfset fw.getBeanFactory().getBean('airavailability').threadAvailability(argumentcollection=arguments.rc)>
		
		<cfset variables.fw.redirect('air.lowfare?searchID=#rc.searchID#&nTrip=#structKeyList(pricedTrip)#&bSelect=1')>
	
	</cffunction>

	<cffunction name="send" output="false">
		<cfargument name="rc">

		<!--- <cfdump var="#session.searches[rc.searchID].stTrips[rc.nTripID]#" /> --->

		<cfset local.trip = session.searches[rc.searchID].stTrips[rc.nTripID]>
		<cfset local.flights = ''>
		<cfloop collection="#trip.groups#" index="local.groupIndex" item="local.group">
			<cfloop collection="#group.segments#" index="local.segmentIndex" item="local.segment">
				<cfset flights = flights&segment.carrier>
				<cfset flights = listAppend(flights, segment.flightNumber)>
				<cfset flights = listAppend(flights, segment.class)>
				<cfset flights = listAppend(flights, dateFormat(segment.departureTime, 'mm/dd/yyyy'))>
				<cfset flights = listAppend(flights, segment.origin)>
				<cfset flights = listAppend(flights, segment.destination)>
				<cfset flights = listAppend(flights, timeFormat(segment.departureTime, 'hh:mm tt'))>
				<cfset flights = listAppend(flights, timeFormat(segment.arrivalTime, 'hh:mm tt'))>
				<cfset flights = flights&'~'>
			</cfloop>
			<cfset flights = left(flights, len(flights)-1)&'|'>
		</cfloop>
		<cfset flights = left(flights, len(flights)-1)>
		
		<!--- <cfdump var="#flights#" /> --->

		<cfquery name="getUser" datasource="Corporate_Production">
			SELECT Email
			FROM Users
			WHERE User_ID = <cfqueryparam value="#rc.Filter.getUserID()#" cfsqltype="cf_sql_numeric">
		</cfquery>

		<cfquery result="dbFindIt" datasource="Book">
			INSERT INTO BookItRequests
				(Worked
				,WorkedBySTO
				,Error
				,Email_Type
				,Traveler
				,Flights
				,User_ID
				,Acct_ID
				,Search_ID
				,Policy_ID
				,Air_IDs
				,Total_Fare
				,Airfare
				,FromEmail
				,ToEmail
				,WebSite
				,Portal
				,DateOfEmail
				,Added_TimeStamp
				,Worked_TimeStamp
				,WorkedBySTO_TimeStamp
				,EmailBundleNumber
				,CCEmail
				,Subject
				,Header
				,BodyOfEmail
				,FlightsOriginal)
			VALUES
				( <cfqueryparam value="1" cfsqltype="cf_sql_numeric">
				, <cfqueryparam value="0" cfsqltype="cf_sql_numeric">
				, <cfqueryparam value="0" cfsqltype="cf_sql_numeric">
				, <cfqueryparam value="" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="#rc.Filter.getUsername()#" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="#flights#" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="#rc.Filter.getUserID()#" cfsqltype="cf_sql_numeric">
				, <cfqueryparam value="#rc.Filter.getAcctID()#" cfsqltype="cf_sql_numeric">
				, <cfqueryparam value="#rc.searchID#" cfsqltype="cf_sql_numeric">
				, <cfqueryparam value="#rc.Filter.getPolicyID()#" cfsqltype="cf_sql_numeric">
				, <cfqueryparam value="" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="#trip.total#" cfsqltype="cf_sql_numeric">
				, <cfqueryparam value="#trip.total#" cfsqltype="cf_sql_numeric">
				, <cfqueryparam value="#getUser.email#" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="findit@shortstravel.com" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="sto" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="https://www.shortstravel.com/shorts" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
				, <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
				, <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
				, <cfqueryparam value="" cfsqltype="cf_sql_timestamp" null="true">
				, <cfqueryparam value="" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="#serializeJSON(trip)#" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="" cfsqltype="cf_sql_varchar">)
		</cfquery>

		<!--- <cfdump var="#dbFindIt.IDENTITYCOL#" /> --->

		<cfhttp method="post" url="https://beta.shortstravelonline.com/findit?id=#dbFindIt.IDENTITYCOL#"/>

		<cfset variables.fw.redirect('air.lowfare?searchID=#rc.searchID#')>

	</cffunction>

</cfcomponent>