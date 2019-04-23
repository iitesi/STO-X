<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="UAPIFactory">
	<cfproperty name="uAPISchemas">
	<cfproperty name="AirParse">
	<cfproperty name="KrakenService">

	<cffunction name="init" output="false">
		<cfargument name="UAPIFactory">
		<cfargument name="uAPISchemas">
		<cfargument name="AirParse">
		<cfargument name="KrakenService">

		<cfset setUAPIFactory(arguments.UAPIFactory)>
		<cfset setUAPISchemas( arguments.uAPISchemas )>
		<cfset setAirParse(arguments.AirParse)>
		<cfset setKrakenService(arguments.KrakenService)>

		<cfreturn this>
	</cffunction>

	<cffunction name="threadAvailability" output="false">
		<cfargument name="bRefundable" required="false" default="false">
		<cfargument name="Filter" required="true">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="Group" required="false">
		<cfargument name="sCabins" required="false">
		<cfargument name="reQuery" default="false">

		<cfset local.sPriority = ''>
		<cfset local.stTrips = {}>
		<cfif IsNumeric(arguments.Group)>
			<cfif arguments.reQuery OR !StructKeyExists(session.searches[arguments.Filter.getSearchID()],'stAvailTrips')
						OR (StructKeyExists(session.searches[arguments.Filter.getSearchID()],'stAvailTrips') AND !StructKeyExists(session.searches[arguments.Filter.getSearchID()].stAvailTrips,arguments.Group))
						OR (StructKeyExists(session.searches[arguments.Filter.getSearchID()].stAvailTrips,arguments.Group) AND !StructCount(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group]))>

				<!--- Create a thread for every leg. Give priority to the group specifically selected. --->
				<cfif arguments.Filter.getClassOfService() EQ ''>
					<cfset local.aCabins = ['X']>
				<cfelseif Len(arguments.sCabins)>
					<!--- if find more class is clicked from filter bar - arguments.sCabins (from rc.cabins) will exist --->
					<cfset local.aCabins = [arguments.sCabins]>
				<cfelse>
					<!--- otherwise get the class/cabin passed from the widget --->
					<cfset local.aCabins = [arguments.Filter.getClassOfService()]>
				</cfif>

				<cfset local.stTrips = doAvailabilityNew( Refundable = arguments.bRefundable,
													Filter = arguments.Filter
													, Group = arguments.Group
													, Account = arguments.Account
													, Policy = arguments.Policy
													, sPriority = 'HIGH'
													, sCabins = local.aCabins)>

				<cfset session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group] = getAirParse().mergeTrips(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], local.stTrips)>
				<!--- Add list of available carriers per leg --->
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.stCarriers[arguments.Group] = getAirParse().getCarriers(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group])>
				<!--- Add sorting per leg --->
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortDepart[arguments.Group] = StructSort(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], 'numeric', 'asc', 'Depart')>
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortArrival[arguments.Group] = StructSort(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], 'numeric', 'asc', 'Arrival')>
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortDuration[arguments.Group]	= StructSort(session.searches[arguments.Filter.getSearchID()].stAvailTrips[arguments.Group], 'numeric', 'asc', 'Duration')>
				<!--- Sorting with preferred departure or arrival time taken into account --->
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortDepartPreferred[arguments.Group] = sortByPreferredTime("aSortDepart", arguments.Filter.getSearchID(), arguments.Group, arguments.Filter) />
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.aSortArrivalPreferred[arguments.Group] = sortByPreferredTime("aSortArrival", arguments.Filter.getSearchID(), arguments.Group, arguments.Filter) />
				<!--- Mark this leg as priced --->
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailDetails.stGroups[arguments.Group] = 1>
				<cfset session.searches[arguments.Filter.getSearchID()].stAvailTrips = addTripIDstAvailTrips(stAvailTrips = session.searches[arguments.Filter.getSearchID()].stAvailTrips)>
			</cfif>
		</cfif>
		<cfreturn />
	</cffunction>

	<cffunction name = "parseConnections" returnType = "struct" access="private">
			<cfargument name="legs">

			<cfset local.stTrips = StructNew('linked')>
			<cfset local.nHashNumeric = ''>
			<cfset local.field = ''>
			<cfset local.arrayfields = ["Arrival","ArrivalTime","Departure","DepartureTime","Origin","Destination","Carrier","FlightNumber","CabinClass","FlightTime"]>
			<cfloop collection="#arguments.legs#" item="local.route">
				<cfset local.HashKey = ''>
				<cfset local.leg = arguments.legs[local.route]>
				<cfloop collection="#local.leg#" item="local.j">
					<cfloop array="#local.arrayfields#" index="local.field" >
						<cfset local.HashKey &= local.leg[local.j][local.field]>
					</cfloop>
				</cfloop>
				<cfset local.nHashNumeric = getUAPI().HashNumeric(local.HashKey)>
				<cfif NOT(StructKeyExists(local.stTrips, local.nHashNumeric)) OR uCase(local.leg[1]["Source"]) NEQ "QPX">
            <cfset local.stTrips[nHashNumeric].Segments = arguments.legs[local.route]>
            <cfset local.stTrips[nHashNumeric].Class = 'X'>
            <cfset local.stTrips[nHashNumeric].Ref = 'X'>
        </cfif>
			</cfloop>

			<cfreturn local.stTrips />

	</cffunction>

	<cffunction name="addTripIDstAvailTrips" output="false">
		<cfargument name="stAvailTrips" required="true">

		<!--- Add a tripID to each each trip --->
		<cfloop collection="#arguments.stAvailTrips#" index="local.overallGroupIndex" item="local.overallGroupItem">
			<cfloop collection="#local.overallGroupItem#" index="local.tripIndex" item="local.tripItem">
				<cfloop collection="#local.tripItem.Groups#" index="local.groupIndex" item="local.groupItem">
					<cfset local.tripID = ''>
					<cfloop collection="#local.groupItem.Segments#" index="local.segmentIndex" item="local.segmentItem">
						<cfset local.tripID = listAppend(local.tripID, local.segmentItem.Carrier&local.segmentItem.FlightNumber&' '&local.segmentItem.Origin&'-'&local.segmentItem.Destination, ',')>
					</cfloop>
					<cfset arguments.stAvailTrips[overallGroupIndex][local.tripIndex].Groups[local.groupIndex].tripID = local.tripID>
				</cfloop>
			</cfloop>
		</cfloop>

		<cfreturn arguments.stAvailTrips/>
	</cffunction>

	<cffunction name="sortByPreferredTime" output="false" hint="I take the depart/arrival sorts and weight the legs closest to requested departure or arrival time.">
		<cfargument name="StructToSort" required="true" />
		<cfargument name="SearchID" required="true" />
		<cfargument name="Group" required="true" />
		<cfargument name="Filter" required="true" />

		<cfset local.aSortArray = "session.searches[" & arguments.SearchID & "].stAvailDetails." & arguments.StructToSort & "[" & arguments.Group & "]" />

		<!--- TODO: Get MD working. --->
		<!--- Note: legs start with 1, groups start with 0 --->
		<cfif arguments.Filter.getAirType() IS "MD">
			<cfset local.nLeg = arguments.Group + 1 />
			<cfset local.preferredDepartTime = arguments.Filter.getLegs()[1].Depart_DateTime[local.nLeg] />
			<cfset local.preferredDepartTimeType = arguments.Filter.getLegs()[1].Depart_TimeType[local.nLeg] />
		<cfelse>
			<cfset local.preferredDepartTime = arguments.Filter.getDepartDateTime() />
			<cfset local.preferredDepartTimeType = arguments.Filter.getDepartTimeType() />
		</cfif>

		<cfif arguments.Filter.getAirType() IS "RT">
			<cfset local.preferredArrivalTime = arguments.Filter.getArrivalDateTime() />
			<cfset local.preferredArrivalTimeType = arguments.Filter.getArrivalTimeType() />
		<cfelse>
			<cfset local.preferredArrivalTime = "" />
			<cfset local.preferredArrivalTimeType = "" />
		</cfif>

		<cfset local.aPreferredSort = [] />
		<cfset local.sortQuery = QueryNew("nTripKey, departDiff, arrivalDiff", "varchar, numeric, numeric") />
		<cfset local.newRow = QueryAddRow(sortQuery, arrayLen(Evaluate(local.aSortArray))) />
		<cfset local.queryCounter = 1 />

		<cfloop array="#evaluate(local.aSortArray)#" index="local.nTripKey">
			<cfset local.stTrip = session.searches[arguments.SearchID].stAvailTrips[arguments.Group][local.nTripKey] />

			<cfif arguments.Filter.getDepartTimeType() IS 'A'>
				<cfset local.departDateDiff = abs(dateDiff("n", local.preferredDepartTime, local.stTrip.arrival)) />
			<cfelse>
				<cfset local.departDateDiff = abs(dateDiff("n", local.preferredDepartTime, local.stTrip.depart)) />
			</cfif>
			<cfif arguments.Filter.getAirType() IS "RT">
				<cfif arguments.Filter.getArrivalTimeType() IS 'A'>
					<cfset local.arrivalDateDiff = abs(dateDiff("n", local.preferredArrivalTime, local.stTrip.arrival)) />
				<cfelse>
					<cfset local.arrivalDateDiff = abs(dateDiff("n", local.preferredArrivalTime, local.stTrip.depart)) />
				</cfif>
			<cfelse>
				<cfset local.arrivalDateDiff = 0 />
			</cfif>

			<cfset local.temp = querySetCell(local.sortQuery, "nTripKey", local.nTripKey, local.queryCounter) />
			<cfset local.temp = querySetCell(local.sortQuery, "departDiff", local.departDateDiff, local.queryCounter) />
			<cfset local.temp = querySetCell(local.sortQuery, "arrivalDiff", local.arrivalDateDiff, local.queryCounter) />
			<cfset local.queryCounter++ />
		</cfloop>

		<cfquery name="local.preferredSort" dbtype="query">
			SELECT nTripKey, departDiff, arrivalDiff
			FROM sortQuery
			<cfif (arguments.Filter.getAirType() IS "RT") AND (arguments.Group EQ 1)>
				ORDER BY arrivalDiff
			<cfelse>
				ORDER BY departDiff
			</cfif>
		</cfquery>

		<cfif local.preferredSort.recordCount>
			<cfset local.aPreferredSort = listToArray(valueList(local.preferredSort.nTripKey)) />
		</cfif>

		<cfreturn local.aPreferredSort />
	</cffunction>

</cfcomponent>
