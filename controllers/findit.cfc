<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfquery name="getTrip" datasource="booking">
			SELECT tripData
			FROM FindItOptions
			WHERE SearchID = <cfqueryparam value="#rc.searchID#" cfsqltype="cf_sql_numeric">
				AND TripKey = <cfqueryparam value="#rc.tripKey#" cfsqltype="cf_sql_numeric">
		</cfquery>

		<cfset trip = deserializeJSON(getTrip.tripData)>

		<cfset local.stSelected = structNew("linked")>
		<cfset stSelected[0].Groups = structNew("linked")>
		<cfset stSelected[1].Groups = structNew("linked")>
		<cfset stSelected[2].Groups = structNew("linked")>
		<cfset stSelected[3].Groups = structNew("linked")>
		<cfloop from="0" to="#arrayLen(structKeyArray(trip.Groups))-1#" index="local.index">
			<cfset stSelected[index].Groups[0].segments = structNew("linked")>
			<cfloop array="#structSort(trip.Groups[index].segments, 'text', 'asc', 'departureTime')#" index="local.segmentIndex" item="local.segment">
				<cfset stSelected[index].Groups[0].segments[segment] = trip.Groups[index].segments[segment]>
			</cfloop>
		</cfloop>

		<cfset local.pricedTrip = fw.getBeanFactory().getBean('AirPrice').doAirPrice( searchID = rc.SearchID
																					, Account = rc.Account
																					, Policy = rc.Policy
																					, sCabin = 'Y'
																					, bRefundable = trip.Ref
																					, nTrip = ''
																					, nCouldYou = 0
																					, bSaveAirPrice = 0 
																					, stSelected = stSelected)>
<!--- <cfdump var="#pricedTrip#" /><cfabort /> --->
		<cfset pricedTrip[structKeyList(pricedTrip)].aPolicies = trip.aPolicies>
		<cfset pricedTrip[structKeyList(pricedTrip)].policy = trip.policy>

		<cfset fw.getBeanFactory().getBean('airavailability').threadAvailability(argumentcollection=arguments.rc)>

		<cfif structKeyList(pricedTrip) NEQ ''>
			<cfset variables.fw.redirect('air.lowfare?searchID=#rc.searchID#&nTrip=#structKeyList(pricedTrip)#&bSelect=1')>
		<cfelse>
			<cfset rc.message.addError('The flight from FindIt is no longer available.')>
			<cfset variables.fw.redirect('air.lowfare?searchID=#rc.searchID#')>
		</cfif>

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
				, <cfqueryparam value="#(getUser.email EQ '' ? 'cdohmen@shortstravel.com' : getUser.email)#" cfsqltype="cf_sql_varchar">
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