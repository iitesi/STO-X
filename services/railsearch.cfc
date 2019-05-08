<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="KrakenService">
	<cfproperty name="Storage">
	<cfproperty name="LowFare">

	<cffunction name="init" output="false" hint="Init method.">
		<cfargument name="KrakenService">
		<cfargument name="Storage">
		<cfargument name="LowFare">

		<cfset setKrakenService(arguments.KrakenService)>
		<cfset setStorage(arguments.Storage)>
		<cfset setLowFare(arguments.LowFare)>

		<cfreturn this>
	</cffunction>

	<cffunction name="doRailSearch" output="false">
		<cfargument name="Filter">
		<cfargument name="SearchID">

		<cfset var requestBody = getRailSearchRequest(Policy = arguments.Policy,
													Filter = arguments.Filter)>
		
		<cfdump var=#serializeJSON(requestBody)#>
		
		<cfset var response = getStorage().getStorage(searchID = arguments.searchID,
													request = requestBody )>

		<cfif structIsEmpty(response)>

			<cfset response = getKrakenService().RailSearch(body = requestBody,
															SearchID = arguments.SearchID)>

			<cfset getStorage().store(searchID = arguments.searchID,
									request = requestBody,
									storage = response )>
		</cfif>

		<cfreturn response.RailSearchResponse.RailJourneys>
 	</cffunction>

	<cffunction name="getRailSearchRequest" returnType="struct" access="public">
		<cfargument name="Policy" type="struct" required="yes">
		<cfargument name="Filter" type="struct" required="yes">

		<cfscript>
			var RequestBody = {};
			var leg = {};

			var Refundable = false;
			if (arguments.Policy.Policy_AirRefRule EQ 1 AND arguments.Policy.Policy_AirNonRefRule EQ 0) {
				Refundable = true;
			}

			RequestBody.RailSearchRequest.Identity = {
				ArrangerId = Filter.getUserID(),
				TravelerName = Filter.getProfileUsername(),
				SearchId = Filter.getSearchID(),
				AccountId = Filter.getAcctID(),
				TravelerId = Filter.getProfileID(),
				IsGuestTraveler = Filter.getProfileID() EQ 0 ? true : false,
				GuestTravelerDepartmentId = Filter.getValueID(),
				//CandidateTravelerId = '',
				//CandidateTravelerDepartmentId = '',
				TravelerDepartmentId = Filter.getValueID()
			};

			RequestBody.RailSearchRequest.RailSearchOptions = {
				OnlyRefundableFares : Refundable,
				PreferredCabinClass : "Economy"
			};

			RequestBody.RailSearchRequest.Legs = [];

			if (arguments.Filter.getAirType() EQ 'OW'
				OR arguments.Filter.getAirType() EQ 'RT') {
				
				Leg = {};

				Leg = {
					OriginStationCode = 'T12A0269',
					DestinationStationCode = 'T12A0276',
					TimeRangeStart = Filter.getArrivalDateTimeActual() EQ 'Anytime' ? dateFormat(Filter.getDepartDateTime(), 'yyyy-mm-dd') & "T00:00:00.000Z" : dateFormat(Filter.getDepartDateTimeStart(), 'yyyy-mm-dd') & 'T' & timeFormat(Filter.getDepartDateTimeStart(), 'HH:mm:ss.lll') & "Z",
					TimeRangeEnd = Filter.getDepartDateTimeActual() EQ 'Anytime' ? dateFormat(Filter.getDepartDateTime(), 'yyyy-mm-dd') & "T23:59:00.000Z" : dateFormat(Filter.getDepartDateTimeEnd(), 'yyyy-mm-dd') & 'T' & timeFormat(Filter.getDepartDateTimeEnd(), 'HH:mm:ss.lll') & "Z",
					TimeRangeType = 'DepartureTime'
				};
				
				arrayAppend(RequestBody.RailSearchRequest["Legs"], Leg);

			}
			if (arguments.Filter.getAirType() EQ 'RT') {

				Leg = {};

				Leg = {
					OriginStationCode = 'T12A0276',
					DestinationStationCode = 'T12A0269',
					TimeRangeStart = Filter.getArrivalDateTimeActual() EQ 'Anytime' ? dateFormat(Filter.getArrivalDateTime(), 'yyyy-mm-dd') & "T00:00:00.000Z" : dateFormat(Filter.getArrivalDateTimeStart(), 'yyyy-mm-dd') & 'T' & timeFormat(Filter.getArrival_DateTimeStart(), 'HH:mm:ss.lll') & "Z",
					TimeRangeEnd = Filter.getArrivalDateTimeActual() EQ 'Anytime' ? dateFormat(Filter.getArrivalDateTime(), 'yyyy-mm-dd') & "T23:59:00.000Z" : dateFormat(Filter.getArrivalDateTimeEnd(), 'yyyy-mm-dd') & 'T' & timeFormat(Filter.getArrivalDateTimeEnd(), 'HH:mm:ss.lll') & "Z",
					TimeRangeType = 'DepartureTime'
				};
				
				arrayAppend(RequestBody.RailSearchRequest["Legs"], Leg);

			}

		</cfscript>

		<!--- <cfdump var=#serializeJSON(RequestBody)# abort> --->

		<cfreturn RequestBody>
	</cffunction>

	<!--- <cffunction name="parseRail" returnType="struct" access="public">
		<cfargument name="response" type="struct" required="yes">

		<cfloop collection="#arguments.response.RailSearchResponse.RailJourneys#" index="local.JourneyIndex" item="local.Journey">
			<cfdump var=#Journey# abort>
		</cfloop>

		<!--- <cfdump var=#serializeJSON(RequestBody)# abort> --->

		<cfreturn RequestBody>
	</cffunction> --->
 	
</cfcomponent>