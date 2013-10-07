<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfquery name="local.getTrip" datasource="booking">
			SELECT tripData
			FROM FindItOptions
			WHERE SearchID = <cfqueryparam value="#rc.searchID#" cfsqltype="cf_sql_numeric">
				AND TripKey = <cfqueryparam value="#rc.tripKey#" cfsqltype="cf_sql_numeric">
		</cfquery>

		<cfset local.trip = deserializeJSON(local.getTrip.tripData)>

		<cfset local.stSelected = structNew("linked")>
		<cfset local.stSelected[0].Groups = structNew("linked")>
		<cfset local.stSelected[1].Groups = structNew("linked")>
		<cfset local.stSelected[2].Groups = structNew("linked")>
		<cfset local.stSelected[3].Groups = structNew("linked")>
		<cfloop from="0" to="#arrayLen(structKeyArray(trip.Groups))-1#" index="local.index">
			<cfset local.stSelected[local.index].Groups[0].segments = structNew("linked")>
			<cfloop array="#structSort(trip.Groups[local.index].segments, 'text', 'asc', 'departureTime')#" index="local.segmentIndex" item="local.segment">
				<cfset local.stSelected[local.index].Groups[0].segments[local.segment] = trip.Groups[local.index].segments[local.segment]>
			</cfloop>
		</cfloop>

		<cfset local.pricedTrip = fw.getBeanFactory().getBean('AirPrice').doAirPrice( searchID = rc.SearchID
																					, Account = rc.Account
																					, Policy = rc.Policy
																					, sCabin = 'Y'
																					, bRefundable = 0
																					, nTrip = ''
																					, nCouldYou = 0
																					, bSaveAirPrice = 0
																					, stSelected = stSelected
																					, findIt = 1)>
<!--- <cfdump var="#pricedTrip#" /><cfabort /> --->
		<cfset local.pricedTrip[structKeyList(local.pricedTrip)].aPolicies = local.trip.aPolicies>
		<cfset local.pricedTrip[structKeyList(local.pricedTrip)].policy = local.trip.policy>

		<cfset fw.getBeanFactory().getBean('airavailability').threadAvailability(argumentcollection=arguments.rc)>

		<cfif structKeyList(local.pricedTrip) NEQ ''>
			<cfset variables.fw.redirect('air.lowfare?searchID=#rc.searchID#&nTrip=#structKeyList(local.pricedTrip)#&bSelect=1')>
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
				<cfset local.flights = flights&segment.carrier>
				<cfset local.flights = listAppend(local.flights, local.segment.flightNumber)>
				<cfset local.flights = listAppend(local.flights, local.segment.class)>
				<cfset local.flights = listAppend(local.flights, dateFormat(local.segment.departureTime, 'mm/dd/yyyy'))>
				<cfset local.flights = listAppend(local.flights, local.segment.origin)>
				<cfset local.flights = listAppend(local.flights, local.segment.destination)>
				<cfset local.flights = listAppend(local.flights, timeFormat(local.segment.departureTime, 'hh:mm tt'))>
				<cfset local.flights = listAppend(local.flights, timeFormat(local.segment.arrivalTime, 'hh:mm tt'))>
				<cfset local.flights = flights&'~'>
			</cfloop>
			<cfset local.flights = left(local.flights, len(local.flights)-1)&'|'>
		</cfloop>
		<cfset local.flights = left(local.flights, len(local.flights)-1)>

		<cfquery name="local.getUser" datasource="Corporate_Production">
			SELECT Email
			FROM Users
			WHERE User_ID = <cfqueryparam value="#rc.Filter.getUserID()#" cfsqltype="cf_sql_numeric">
		</cfquery>

		<cfquery result="local.dbFindIt" datasource="Booking">
			INSERT INTO FindItRequests
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
				, <cfqueryparam value="#local.flights#" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="#rc.Filter.getUserID()#" cfsqltype="cf_sql_numeric">
				, <cfqueryparam value="#rc.Filter.getAcctID()#" cfsqltype="cf_sql_numeric">
				, <cfqueryparam value="#rc.searchID#" cfsqltype="cf_sql_numeric">
				, <cfqueryparam value="#rc.Filter.getPolicyID()#" cfsqltype="cf_sql_numeric">
				, <cfqueryparam value="" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="#local.trip.total#" cfsqltype="cf_sql_numeric">
				, <cfqueryparam value="#local.trip.total#" cfsqltype="cf_sql_numeric">
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
				, <cfqueryparam value="#serializeJSON(local.trip)#" cfsqltype="cf_sql_varchar">
				, <cfqueryparam value="" cfsqltype="cf_sql_varchar">)
		</cfquery>

		<cfquery name="local.getMax" datasource="booking">
			SELECT MAX(ID) AS ID
			FROM FindItRequests
			WHERE User_ID = <cfqueryparam value="#rc.Filter.getUserID()#" cfsqltype="cf_sql_numeric">
				Acct_ID = <cfqueryparam value="#rc.Filter.getAcctID()#" cfsqltype="cf_sql_numeric">
		</cfquery>

		<cfhttp method="post" url="https://www.shortstravelonline.com/findit?id=#getMax.ID#"/>

		<cfset variables.fw.redirect('air.lowfare?searchID=#rc.searchID#')>

	</cffunction>

</cfcomponent>