<cfcomponent output="true">
	
<!--- air : backfill --->
	<cffunction name="backfill" returntype="void">
		<cfargument name="Search_ID" 		type="any" 		required="true">
		<cfargument name="preferredair" 	type="query" 	required="true">
		
		<cfset local.timer = getTickCount()>
		
		<cfstoredproc procedure="sp_Trips_RemoveDups"> 
			<cfprocparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric">
		</cfstoredproc>
		<cfstoredproc procedure="sp_Trips_MultiCarrier"> 
			<cfprocparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric">
		</cfstoredproc>
		<cfstoredproc procedure="sp_Trips_Preferred"> 
			<cfprocparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric">
			<cfprocparam value="#QuotedValueList(arguments.preferredair.Vendor_Code)#" cfsqltype="cf_sql_varchar">
		</cfstoredproc>
		<cfstoredproc procedure="sp_Trips_BlacklistCarrier"> 
			<cfprocparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric">
		</cfstoredproc>
		<cfstoredproc procedure="sp_Trips_CabinClass"> 
			<cfprocparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric">
		</cfstoredproc>
		
		
		<!---
		<cfquery name="getAllPreferred" datasource="Corporate_Production" cachedwithin="#CreateTimeSpan(1,0,0,0)#" >
		SELECT ShortCode
		FROM MP_Accts,Suppliers
		WHERE User_ID = <cfqueryparam value="#arguments.Profile_ID#" cfsqltype="cf_sql_numeric" />
		AND MP_Accts.Supplier = Suppliers.AccountID
		AND CustType = <cfqueryparam value="A" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<cfif getAllPreferred.RecordCount GT 0>
			<cfquery datasource="book">
			<!--- Marked traveler preferred --->
			UPDATE Air_Trips
			SET Traveler_Preferred = <cfqueryparam value="1" cfsqltype="cf_sql_numeric" />
			FROM Air_Trips, Air_Segments
			WHERE Air_Trips.Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
			AND Air_Trips.Search_ID = Air_Segments.Search_ID
			AND Air_Trips.Air_Type = Air_Segments.Air_Type
			AND Air_Trips.Air_ID = Air_Segments.Air_ID
			AND Carrier IN (#QuotedValueList(getAllPreferred.ShortCode)#)
			AND Traveler_Preferred = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
			</cfquery>
		</cfif>
		<cfquery datasource="book">
		<!--- Bags --->
		UPDATE Air_Trips
		SET Bag1 = Two.Bag1,
		Bag2 = Two.Bag2
		FROM Air_Trips, (				
				SELECT DISTINCT IsNull(DomBag1, 0) AS Bag1, IsNull(DomBag2, 0) AS Bag2, Air_ID
				FROM Air_Segments, Suppliers, OnlineCheckIn_Links
				WHERE Suppliers.CustType = <cfqueryparam value="A" cfsqltype="cf_sql_varchar" />
				AND OnlineCheckIn_Links.Link_Display = <cfqueryparam value="1" cfsqltype="cf_sql_numeric" />
				AND Air_Segments.Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
				AND Air_Segments.Air_Type = <cfqueryparam value="Fare" cfsqltype="cf_sql_varchar" />
				AND Air_Segments.Carrier = Suppliers.ShortCode
				AND Suppliers.AccountID = OnlineCheckIn_Links.AccountID
				) AS Two
		WHERE Air_Trips.Air_ID = Two.Air_ID
		AND Air_Trips.Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		AND Air_Trips.Air_Type = <cfqueryparam value="Fare" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<!--- Remove interline carriers --->
		<cfquery name="getAllBlacklisted" datasource="book" cachedwithin="#CreateTimespan(30,0,0,0)#">
		SELECT Carrier1, Carrier2
		FROM lu_CarrierInterline
		UNION
		SELECT Carrier2 AS Carrier1, Carrier1 AS Carrier2
		FROM lu_CarrierInterline
		</cfquery>
		<cfquery datasource="book">
		UPDATE Air_Trips
		SET Active = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />,
		Policy = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		AND (Carriers IN (<cfloop query="getAllBlacklisted">'#Carrier1#,#Carrier2#','#Carrier2#,#Carrier1#',</cfloop>'VOID')
		OR (Carriers LIKE '%,%'
			AND (Carriers LIKE '%WN%'
				OR Carriers LIKE '%FL%')))
		</cfquery>
		--->
		
		<cflog text="air.backfill 		: #(getTickCount()-timer)# ms" file="air.log" type="information">

		<cfreturn />
	</cffunction>
	
<!--- air : results --->
	<cffunction name="results" returntype="struct">
		<cfargument name="Search_ID" type="any" required="true">
		
		<!---<cfstoredproc procedure="sp_Trips_getSegments"> 
			<cfprocparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric">
			<cfprocresult name="local.getSegments">
		</cfstoredproc>--->
		<cfquery name="local.getSegments">
	    SELECT *
		FROM Trips, Trip_Segments, Segments
		WHERE Trips.Search_ID = Trip_Segments.Search_ID
		AND Trips.Search_Key = Trip_Segments.Search_Key
		AND Trips.Trip_ID = Trip_Segments.Trip_ID
		AND Trip_Segments.Search_ID = Segments.Search_ID
		AND Trip_Segments.Search_Key = Segments.Search_Key
		AND Trip_Segments.Segment_ID = Segments.Segment_ID
		AND Trips.Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_integer" >
		ORDER BY Token, Trips.Trip_ID, TotalPrice, [Group], SegmentNum
		</cfquery>
		
		<cfset local.results = {}>
		<cfoutput query="getSegments" group="token">
			<cfset local.count = 0>
			<cfset results[token].Preferred = Preferred>
			<cfset results[token].MultiCarrier = MultiCarrier>
			<cfoutput group="Trip_ID">
				<cfset count++>
				<cfset results[token].Fares[Refundable][CabinClass].Currency = Currency>
				<cfset results[token].Fares[Refundable][CabinClass].BasePrice = BasePrice>
				<cfset results[token].Fares[Refundable][CabinClass].Taxes = Taxes>
				<cfset results[token].Fares[Refundable][CabinClass].TotalPrice = TotalPrice>
				<cfset results[token].Fares[Refundable][CabinClass].PassengerType = PassengerType>
				<cfset results[token].Fares[Refundable][CabinClass].PrivateFare = PrivateFare>
				<cfset results[token].Fares[Refundable][CabinClass].Policy = Policy>
				<cfset results[token].Fares[Refundable][CabinClass].PolicyText = PolicyText>
				<cfset results[token].Fares[Refundable][CabinClass].MultiCarrier = MultiCarrier>
				<cfif count EQ 1>
					<cfset local.tempgroup = -1>
					<cfset local.carriers = StructNew()>
					<cfset local.stops = StructNew()>
					<cfset local.maxstops = 0>
					<cfoutput>
						<cfif tempgroup NEQ Group AND tempgroup NEQ -1><!--- destination of previous group --->
							<cfif maxstops LT stops[Group-1]>
								<cfset maxstops = stops[Group-1]>
							</cfif>
							<cfset results[token].Group[Group-1].Destination = results[token].Segments[count-1].Destination>
							<cfset results[token].Group[Group-1].DestinationAirport = results[token].Segments[count-1].DestinationAirport>
							<cfset results[token].Group[Group-1].ArrivalTime = results[token].Segments[count-1].ArrivalTime>
							<cfset results[token].Group[Group-1].Carriers = StructKeyList(carriers)>
						</cfif>
						<cfif tempgroup NEQ Group><!--- origin of the group --->
							<cfset local.stops[Group] = 0>
							<cfset results[token].Group[Group].Origin = Origin>
							<cfset results[token].Group[Group].OriginAirport = OriginAirport>
							<cfset results[token].Group[Group].DepartureTime = DepartureTime>
							<cfset results[token].Group[Group].TravelTime = TravelTime>
							<cfset tempgroup = Group>
						<cfelse>
							<cfset local.stops[Group]++>
						</cfif>
						<cfset results[token].Segments[count].Carrier = Carrier>
						<cfset results[token].Segments[count].CarrierName = CarrierName>
						<cfset carriers[Carrier] = ''>
						<cfset results[token].Segments[count].OperatingCarrier = OperatingCarrier>
						<cfset results[token].Segments[count].OperatingCarrierName = OperatingCarrierName>
						<cfset results[token].Segments[count].FlightNumber = FlightNumber>
						<cfset results[token].Segments[count].Origin = Origin>
						<cfset results[token].Segments[count].OriginAirport = OriginAirport>
						<cfset results[token].Segments[count].DepartureTime = DepartureTime>
						<cfset results[token].Segments[count].Destination = Destination>
						<cfset results[token].Segments[count].DestinationAirport = DestinationAirport>
						<cfset results[token].Segments[count].ArrivalTime = ArrivalTime>
						<cfset results[token].Segments[count].Group = Group>
						<cfset results[token].Segments[count].ClassOfService = ClassOfService>
						<cfset results[token].Segments[count].CabinClass = CabinClass>
						<cfset results[token].Segments[count].EquipmentName = EquipmentName>
						<cfset results[token].Segments[count].ChangeOfPlane = ChangeOfPlane>
						<cfset results[token].Segments[count].FlightTime = FlightTime>
						<cfset count++>
					</cfoutput>
					<cfif maxstops LT stops[tempgroup]>
						<cfset maxstops = stops[tempgroup]>
					</cfif>
					<cfset results[token].Group[tempgroup].Destination = results[token].Segments[count-1].Destination>
					<cfset results[token].Group[tempgroup].DestinationAirport = results[token].Segments[count-1].DestinationAirport>
					<cfset results[token].Group[tempgroup].ArrivalTime = results[token].Segments[count-1].ArrivalTime>
					<cfset results[token].Group[tempgroup].Carriers = StructKeyList(carriers)>
				</cfif>
				<cfset results[token].js = '"#token#",#Policy#,#MultiCarrier#,["#Replace(StructKeyList(carriers), ',', '","', 'ALL')#"],#Refundable#,"#TotalPrice#","#TravelTime#",#Preferred#,"#CabinClass#",#(maxstops LTE 2 ? maxstops : 2)#'>
			</cfoutput>
		</cfoutput>
		
		<cfreturn results/>
	</cffunction>
		
<!--- air : processpolicyair --->
	<cffunction name="processpolicyair" access="remote" returntype="void" output="true">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="policyair" type="any" required="true">
		<cfargument name="Policy_ID" required="false" default="#session.Policy_ID#">
		
		<cfset var search = ''>
		
		<cfinvoke component="book.services.general" method="search" Search_ID="#arguments.Search_ID#" returnvariable="search" />
		<cfquery datasource="book">
		<!--- Out of policy if the fare plus the padding is greater than the lowest available fare. --->
		<cfif policyair.Policy_AirLowRule EQ 1 AND IsNumeric(policyair.Policy_AirLowPad)>
			UPDATE Air_Trips
			SET Policy_Text = IsNull(Policy_Text, '')+'Not the lowest fare<br>',
			<cfif policyair.Policy_AirLowDisp EQ 1>
				Active = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />,
			</cfif>
			Policy = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
			WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
			AND Air_Type = <cfqueryparam value="Fare" cfsqltype="cf_sql_varchar" />
			AND Total_Fare > (SELECT (MIN(IsNull(Total_Fare, 10000)) + #policyair.Policy_AirLowPad#) AS Total_Fare
								FROM Air_Trips
								WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
								AND Air_Type = <cfqueryparam value="Fare" cfsqltype="cf_sql_varchar" />)
		</cfif>
		
		<!--- Out of policy if the total fare is over the maximum allowed fare. --->
		<cfif policyair.Policy_AirMaxRule EQ 1 AND IsNumeric(policyair.Policy_AirMaxTotal)>
			UPDATE Air_Trips
			SET Policy_Text = IsNull(Policy_Text, '')+'Fare greater than #DollarFormat(policyair.Policy_AirMaxTotal)#<br>',
			<cfif policyair.Policy_AirMaxDisp EQ 1>
				Active = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />,
			</cfif>
			Policy = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
			WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
			AND Total_Fare > <cfqueryparam value="#policyair.Policy_AirMaxTotal#" cfsqltype="cf_sql_money" />
		</cfif>		

		<!--- Don't display when non refundable --->
		<cfif policyair.Policy_AirRefRule EQ 1 AND policyair.Policy_AirRefDisp EQ 1>
			UPDATE Air_Trips
			SET Active = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />,
			Policy = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
			WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
			AND Refundable = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
			AND Air_Type = <cfqueryparam value="Fare" cfsqltype="cf_sql_varchar" />
		</cfif>
		
		<!--- Don't display when refundable --->
		<cfif policyair.Policy_AirNonRefRule EQ 1 AND policyair.Policy_AirNonRefDisp EQ 1>
			UPDATE Air_Trips
			SET Active = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />,
			Policy = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
			WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
			AND Refundable = <cfqueryparam value="1" cfsqltype="cf_sql_numeric" />
			AND Air_Type = <cfqueryparam value="Fare" cfsqltype="cf_sql_varchar" />
		</cfif>

		<!--- Out of policy if they cannot book non preferred carriers. --->
		<cfif policyair.Policy_AirPrefRule EQ 1 AND policyair.Policy_AirNonRefDisp EQ 1>
			UPDATE Air_Trips
			SET Policy_Text = IsNull(Policy_Text, '')+'Not a preferred carrier<br>',
			<cfif policyair.Policy_AirPrefDisp EQ 1>
				Active = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />,
			</cfif>
			Policy = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
			WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
			AND Preferred = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
		</cfif>

		<!--- Out of policy if the depart date is less than the advance purchase requirement. --->
		<cfif policyair.Policy_AirAdvRule EQ 1 AND policyair.Policy_AirNonRefDisp EQ 1>
			UPDATE Air_Trips
			SET Policy_Text = IsNull(Policy_Text, '')+'Advance purchase less than #policyair.Policy_AirAdv#<br>',
			<cfif policyair.Policy_AirAdvDisp EQ 1>
				Active = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />,
			</cfif>
			Policy = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
			WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
			AND DateDiff('d', Now(), Outbound_Depart) < #policyair.Policy_AirAdv#
		</cfif>
		
		<!--- Departure time is too close to current time. --->
		UPDATE Air_Trips
		SET Active = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />,
		Policy = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		AND Outbound_Depart <= #CreateODBCDateTime(DateAdd('h', 2, Now()))#
		
		UPDATE Air_Trips
		SET Policy = <cfqueryparam value="0" cfsqltype="cf_sql_integer">,
		Policy_Text = IsNull(Policy_Text, '')+'Out of policy carrier'
		FROM Air_Segments
		WHERE Air_Trips.Air_ID = Air_Segments.Air_ID
		AND Air_Trips.Air_Type = Air_Segments.Air_Type
		AND Air_Trips.Search_ID = Air_Segments.Search_ID
		AND Air_Trips.Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_integer">
		AND Carrier IN (SELECT Vendor_ID
						FROM OutofPolicy_Vendors
						WHERE Acct_ID = <cfqueryparam value="#search.Acct_ID#" cfsqltype="cf_sql_integer">
						AND Type = 'A')
		</cfquery>
		
		<!--- Remove first class UP fares --->
		<cfquery datasource="book" >
		DELETE FROM Air_Trips
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		AND Class = <cfqueryparam value="F" cfsqltype="cf_sql_varchar" />
		AND Refundable = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
		AND Air_Type = <cfqueryparam value="Fare" cfsqltype="cf_sql_varchar" />
		</cfquery>
		
		<cfinvoke
			component="book.services.customcode"
			method="processpolicyair"
			Search_ID="#arguments.Search_ID#"
			Policy_ID="#arguments.Policy_ID#" />
		
		<cfreturn />
	</cffunction>

<!--- air : airresults --->
	<cffunction name="airresults" access="remote" returntype="query" output="true">
		<cfargument name="t" type="numeric" required="true">
		<cfargument name="d" type="numeric" required="true">
		<cfargument name="action" required="true">
		<cfargument name="filtercarrier" required="false" default="">
		
		<cfset var onlyinclude = ''>
		<cfset var airresults = ''>
		<cfset var getAllBlacklisted = ''>
		
		<cfif arguments.action EQ 'air.default'>
			<cfstoredproc procedure="sp_airresultsfare" datasource="book">
				<cfprocparam value="#session.searches[arguments.t]['Search_ID']#" cfsqltype="cf_sql_numeric">
				<cfprocresult name="airresults">
			</cfstoredproc>
		<cfelse>
			<cfstoredproc procedure="sp_airresultsschedule" datasource="book">
				<cfprocparam value="#session.searches[arguments.t]['Search_ID']#" cfsqltype="cf_sql_numeric">
				<cfprocparam value="#arguments.d#" cfsqltype="cf_sql_char">
				<cfprocresult name="airresults">
			</cfstoredproc>
			<cfif ListFind('FL,B6,WN', arguments.filtercarrier)>
				<cfset onlyinclude = "'"&arguments.filtercarrier&"'">
				<cfif onlyinclude EQ 'B6'>
					<cfset onlyinclude = ListAppend(onlyinclude, "'AA'")>
				</cfif>
				<cfquery name="airresults" dbtype="query">
				SELECT *
				FROM airresults
				WHERE Carrier IN (#PreserveSingleQuotes(onlyinclude)#)
				</cfquery>
			<cfelse>
				<cfquery name="getAllBlacklisted" datasource="book" cachedwithin="#CreateTimespan(30,0,0,0)#">
				SELECT Carrier2
				FROM lu_CarrierInterline
				WHERE Carrier1 = <cfqueryparam value="#arguments.filtercarrier#" cfsqltype="cf_sql_varchar">
				UNION
				SELECT Carrier1 AS Carrier2
				FROM lu_CarrierInterline
				WHERE Carrier2 = <cfqueryparam value="#arguments.filtercarrier#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif getAllBlacklisted.RecordCount>
					<cfquery name="airresults" dbtype="query">
					SELECT *
					FROM airresults
					WHERE Carrier NOT IN (#QuotedValueList(getAllBlacklisted.Carrier2)#)
					</cfquery>
				</cfif>
			</cfif>
			
		</cfif>
		
		<cfreturn airresults />
	</cffunction>
	
<!--- air : airstruct --->
	<cffunction name="airstruct" access="remote" returntype="struct" output="true">
		<cfargument name="t" type="numeric" required="true">
		<cfargument name="airresults" type="query" required="true">
		
		<cfset var airstruct = StructNew()>
		<cfset var FirstClassDisplayed = ''>
		<cfset var AllClasses = ''>
		<cfset var SegmentNumber = 0>
		<cfset var InPolicy = 0>
		<cfset var tempDirection = 0>
		<cfset var prc = StructNew()>
		<cfoutput query="arguments.airresults" group="Token"><!--- per itinerary --->
			<cfset airstruct[Token]['Air_ID'] = Air_ID>
			<cfset airstruct[Token]['Selected'] = Selected>
			<cfset airstruct[Token]['Carriers'] = Carriers>
			<cfset airstruct[Token]['Flights'] = Flights>
			<cfset airstruct[Token]['Trip_Time'] = Trip_Time>
			<cfset airstruct[Token]['Trip_Text'] = Trip_Text>
			<cfset airstruct[Token]['Stops'] = Stops>
			<cfset airstruct[Token]['Outbound_Depart'] = Outbound_Depart>
			<cfset airstruct[Token]['Outbound_Arrival'] = Outbound_Arrival>
			<cfset airstruct[Token]['Return_Depart'] = Return_Depart>
			<cfset airstruct[Token]['Return_Arrival'] = Return_Arrival>
			<cfset airstruct[Token]['Preferred'] = Preferred>
			<cfset airstruct[Token]['Traveler_Preferred'] = Traveler_Preferred>
			<cfset airstruct[Token]['Bag1'] = Bag1>
			<cfset airstruct[Token]['Bag2'] = Bag2>
			<cfset airstruct[Token]['DefaultCOS'] = Class>
			<cfset airstruct[Token]['DefaultRef'] = Refundable>
			<cfset airstruct[Token]['FindIt'] = FindIt>
			<cfset airstruct[Token]['Refundable'] = Refundable>
			<cfset FirstClassDisplayed = ''>
			<cfset AllClasses = ''>
			<cfset SegmentNumber = 0>
			<cfset InPolicy = 0>
			<cfset tempDirection = 0>
			<cfset prc['Stops1'] = 0>
			<cfset prc['Stops2'] = 0>
			<cfset prc['Stops3'] = 0>
			<cfset prc['Stops4'] = 0>
			<cfset prc['Flights1'] = ''>
			<cfset prc['Flights2'] = ''>
			<cfset prc['Flights3'] = ''>
			<cfset prc['Flights4'] = ''>
			<cfset prc['Connection1'] = ''>
			<cfset prc['Connection2'] = ''>
			<cfset prc['Connection3'] = ''>
			<cfset prc['Connection4'] = ''>
			<cfoutput group="Segment_Number">
				<cfset SegmentNumber++ />
				<cfset airstruct[Token]['Segments'][SegmentNumber]['Direction'] = Direction>
				<cfset airstruct[Token]['Segments'][SegmentNumber]['Carrier'] = Carrier>
				<cfset airstruct[Token]['Segments'][SegmentNumber]['Carrier_Name'] = Carrier_Name>
				<cfset airstruct[Token]['Segments'][SegmentNumber]['Flight'] = Flight>
				<cfset airstruct[Token]['Segments'][SegmentNumber]['Flight_Text'] = Flight_Text>
				<cfset airstruct[Token]['Segments'][SegmentNumber]['Depart_City'] = Depart_City>
				<cfset airstruct[Token]['Segments'][SegmentNumber]['Depart_Airport'] = Depart_Airport>
				<cfset airstruct[Token]['Segments'][SegmentNumber]['Depart_DateTime'] = Depart_DateTime>
				<cfset airstruct[Token]['Segments'][SegmentNumber]['Arrival_City'] = Arrival_City>
				<cfset airstruct[Token]['Segments'][SegmentNumber]['Arrival_Airport'] = Arrival_Airport>
				<cfset airstruct[Token]['Segments'][SegmentNumber]['Arrival_DateTime'] = Arrival_DateTime>
				<cfset airstruct[Token]['Segments'][SegmentNumber]['Stop'] = Stop>
				<cfset airstruct[Token]['Segments'][SegmentNumber]['Equipment_Name'] = Equipment_Name>
				<cfset airstruct[Token]['Segments'][SegmentNumber]['Elapsed_Text'] = Elapsed_Text>
				<cfset prc['Stops#Direction#'] = prc['Stops#Direction#'] + Stop>
				<cfset prc['Flights#Direction#'] = ListAppend(prc['Flights#Direction#'], '<a title="#Carrier_Name# #Flight#">'&Carrier&Flight&'</a>')>
				<cfif tempDirection NEQ Direction>
					<cfset airstruct[Token]['Directions'][Direction]['Depart_City'] = Depart_City>
					<cfset airstruct[Token]['Directions'][Direction]['Depart_Airport'] = Depart_Airport>
					<cfset airstruct[Token]['Directions'][Direction]['Depart_DateTime'] = Depart_DateTime>
					<cfset airstruct[Token]['Directions'][Direction]['Elapsed_Text'] = Elapsed_Text>
					<cfset airstruct[Token]['Directions'][Direction]['Connection'] = ''>
					<cfset tempDirection = Direction>
				<cfelseif tempDirection EQ Direction>
					<cfset prc['Stops#Direction#'] = prc['Stops#Direction#'] + 1>
					<cfset prc['Connection#Direction#'] = prc['Connection#Direction#'] & '<a title="#Depart_Airport#">#Depart_City#</a> '>
				</cfif>
				<cfset airstruct[Token]['Directions'][Direction]['Arrival_Airport'] = Arrival_Airport>
				<cfset airstruct[Token]['Directions'][Direction]['Arrival_City'] = Arrival_City>
				<cfset airstruct[Token]['Directions'][Direction]['Arrival_DateTime'] = Arrival_DateTime>
			</cfoutput>
			<cfset airstruct[Token]['Directions'][1]['Connection'] = Replace(prc.Connection1, ',', ', ', 'ALL')>
			<cfset airstruct[Token]['Directions'][2]['Connection'] = Replace(prc.Connection2, ',', ', ', 'ALL')>
			<cfset airstruct[Token]['Directions'][3]['Connection'] = Replace(prc.Connection3, ',', ', ', 'ALL')>
			<cfset airstruct[Token]['Directions'][4]['Connection'] = Replace(prc.Connection4, ',', ', ', 'ALL')>
			<cfset airstruct[Token]['Directions'][1]['Stops'] = prc.Stops1>
			<cfset airstruct[Token]['Directions'][2]['Stops'] = prc.Stops2>
			<cfset airstruct[Token]['Directions'][3]['Stops'] = prc.Stops3>
			<cfset airstruct[Token]['Directions'][4]['Stops'] = prc.Stops4>
			<cfset airstruct[Token]['Directions'][1]['Flights'] = Replace(prc.Flights1, ',', ', ', 'ALL')>
			<cfset airstruct[Token]['Directions'][2]['Flights'] = Replace(prc.Flights2, ',', ', ', 'ALL')>
			<cfset airstruct[Token]['Directions'][3]['Flights'] = Replace(prc.Flights3, ',', ', ', 'ALL')>
			<cfset airstruct[Token]['Directions'][4]['Flights'] = Replace(prc.Flights4, ',', ', ', 'ALL')>
			<cfoutput>
				<cfif NOT ListFind(AllClasses, Class, ',')><!--- per class --->
					<cfset AllClasses = ListAppend(AllClasses, Class)>
					<cfset airstruct[Token]['Fares'][Class]['Currency'] = Currency>
					<cfset airstruct[Token]['Fares'][Class]['Refundable'] = Refundable>
					<cfset airstruct[Token]['Fares'][Class]['Base_Fare'] = Base_Fare>
					<cfset airstruct[Token]['Fares'][Class]['Taxes'] = Taxes>
					<cfset airstruct[Token]['Fares'][Class]['Class'] = Class>
					<cfif Class EQ 'Y'>
						<cfset airstruct[Token]['Fares'][Class]['Class_Name'] = 'Coach'>
					<cfelseif Class EQ 'C'>
						<cfset airstruct[Token]['Fares'][Class]['Class_Name'] = 'Business'>
					<cfelseif Class EQ 'F'>
						<cfset airstruct[Token]['Fares'][Class]['Class_Name'] = 'First'>
					<cfelse>
						<cfset airstruct[Token]['Fares'][Class]['Class_Name'] = ''>
					</cfif>
					<cfset airstruct[Token]['Fares'][Class]['Air_ID'] = Air_ID>
					<cfset airstruct[Token]['Fares'][Class]['Total_Fare'] = Total_Fare>
					<cfset airstruct[Token]['Fares'][Class]['Fare_Basis'] = Fare_Basis>
					<cfset airstruct[Token]['Fares'][Class]['Fare_Rules'] = Fare_Rules>
					<cfset airstruct[Token]['Fares'][Class]['Policy'] = Policy>
					<cfset airstruct[Token]['Fares'][Class]['Policy_Text'] = Policy_Text>
					<cfset airstruct[Token]['Fares'][Class]['Private_Fare'] = Private_Fare>
					<cfset airstruct[Token]['Fares'][Class]['PTC'] = PTC>
					<cfif Policy EQ 1>
						<cfset InPolicy = 1>
					</cfif>
				</cfif>		
			</cfoutput>
			<cfset airstruct[Token]['InPolicy'] = InPolicy>
		</cfoutput>
		
		<cfreturn airstruct />
	</cffunction>
	
<!--- air : jsstruct --->
	<cffunction name="jsstruct" access="remote" returntype="string" output="true">
		
		<cfset var jsstruct = 'var flightresults = ['>
		<cfset var count = 0>
		<cfset var newPTC = 0>
		<cfset var Itineraries = 0>
		<cfset var show = 0>
		<cfset var airresultsjs = 0>
		
		<cfquery name="airresultsjs" dbtype="query">
		SELECT *
		FROM airresults
		ORDER BY Token, Class, Total_Fare
		</cfquery>
		<cfoutput query="airresultsjs" group="Token">
			<cfoutput group="Class">
				<cfset count++ >
				<cfif count NEQ 1><cfset jsstruct = jsstruct&','></cfif>
				<cfset Itineraries = 0>
				<cfset show = 'hide'>
				<cfif Carriers CONTAINS ','>
					<cfset Itineraries = 1>
					<cfset show = 'hide'>
				</cfif>
				<cfif PTC EQ ''>
					<cfset newPTC = 0>
				<cfelse>
					<cfset newPTC = 1>
				</cfif>
				<cfset jsstruct = jsstruct&'[#Air_ID#,#Policy#,#Itineraries#,["#Replace(Carriers, ',', '","', 'ALL')#"],["#Replace(Flights, ',', '","', 'ALL')#"],#TimeFormat(Outbound_Depart, 'H.mm')#,#TimeFormat(Outbound_Arrival, 'H.mm')#,#TimeFormat(Return_Depart, 'H.mm')#,#TimeFormat(Return_Arrival, 'H.mm')#,#Refundable#,"#show#","#Stops#","#Total_Fare#","#Trip_Time#","#Token#",#Traveler_Preferred#,#Preferred#,"#Class#",#Selected#,#Private_Fare#,#newPTC#]'>
			</cfoutput>
		</cfoutput>
		<cfset jsstruct = jsstruct&'];'>
		
		<cfreturn jsstruct />
	</cffunction>
	
<!--- air : specific --->
	<cffunction name="specific" access="remote" returntype="query" output="true">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="Air_ID" type="numeric" required="true">
		<cfargument name="Air_Type" type="string" required="true">
		
		<cfset var specific = ''>
		
		<cfstoredproc procedure="sp_airspecific" datasource="book">
			<cfprocparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric">
			<cfprocparam value="#arguments.Air_Type#" cfsqltype="cf_sql_varchar">
			<cfprocparam value="#arguments.Air_ID#" cfsqltype="cf_sql_numeric">
			<cfprocresult name="specific">
		</cfstoredproc>
		
		<cfreturn specific/>
	</cffunction>	
	
<!--- air : selected --->
	<cffunction name="selected" access="remote" output="true">
		<cfargument name="t" type="numeric" required="true">
		<cfargument name="token" type="string" required="true">
		<cfargument name="cos" type="string" required="true">
		<cfargument name="ref" type="numeric" required="true">
		
		<cfset var tabs = StructKeyArray(session.searches)>
		<cfset var num = ''>
		<cfset var tempsearches = StructNew()>
		<cfset var getSpecificAirID = ''>
		<cfset var getSpecificInvoice = ''>
		<cfset var getSpecificSearch = ''>
		<cfset var getSpecificAirport = ''>
		<cfset var temp = ''>

		<!--- Find the specific Air_ID --->
		<cfquery name="getSpecificAirID" datasource="book">
		SELECT Air_ID, Total_Fare, Outbound_Depart, Return_Arrival
		FROM Air_Trips
		WHERE Search_ID = <cfqueryparam value="#session.searches[arguments.t]['Search_ID']#" cfsqltype="cf_sql_numeric" />
		AND Active = <cfqueryparam value="1" cfsqltype="cf_sql_numeric" />
		AND Air_Type = <cfqueryparam value="Fare" cfsqltype="cf_sql_varchar" />
		AND Token = <cfqueryparam value="#arguments.token#" cfsqltype="cf_sql_varchar" />
		AND Class = <cfqueryparam value="#arguments.cos#" cfsqltype="cf_sql_varchar" />
		AND Refundable = <cfqueryparam value="#arguments.ref#" cfsqltype="cf_sql_numeric" />
		ORDER BY Total_Fare
		</cfquery>
		<cfif getSpecificAirID.RecordCount GT 0>
			<!--- Save Air_ID in shell invoice --->
			<cfquery name="getSpecificInvoice" datasource="book">
			SELECT Search_ID
			FROM Invoices
			WHERE Search_ID = <cfqueryparam value="#session.searches[arguments.t]['Search_ID']#" cfsqltype="cf_sql_numeric" /> 
			</cfquery>
			<cfif getSpecificInvoice.RecordCount EQ 0>
				<cfquery name="getSpecificSearch" datasource="book">
				SELECT BookIt, Access_Timestamp
				FROM Searches
				WHERE Search_ID = <cfqueryparam value="#session.searches[arguments.t]['Search_ID']#" cfsqltype="cf_sql_numeric" /> 
				</cfquery>
				<cfquery datasource="book">
				INSERT INTO Invoices
				(Search_ID, Air_ID, Depart_DateTime, Arrival_DateTime, Value_ID, Policy_ID, BookIt, Search_Timestamp)
				VALUES
				(<cfqueryparam value="#session.searches[arguments.t]['Search_ID']#" cfsqltype="cf_sql_numeric" />,
				<cfqueryparam value="#getSpecificAirID.Air_ID#" cfsqltype="cf_sql_numeric" />,
				<cfqueryparam value="#getSpecificAirID.Outbound_Depart#" cfsqltype="cf_sql_timestamp" />,
				<cfqueryparam value="#getSpecificAirID.Return_Arrival#" cfsqltype="cf_sql_timestamp" null="true" />,
				<cfqueryparam value="#session.Value_ID#" cfsqltype="cf_sql_numeric" />,
				<cfqueryparam value="#session.Policy_ID#" cfsqltype="cf_sql_numeric" />,
				<cfqueryparam value="#getSpecificSearch.BookIt#" cfsqltype="cf_sql_numeric" />,
				<cfqueryparam value="#getSpecificSearch.Access_Timestamp#" cfsqltype="cf_sql_timestamp" />)
				</cfquery> 
			<cfelse>
				<cfquery datasource="book">
				UPDATE Invoices
				SET Air_ID = <cfqueryparam value="#getSpecificAirID.Air_ID#" cfsqltype="cf_sql_numeric" />,
				Depart_DateTime = <cfqueryparam value="#getSpecificAirID.Outbound_Depart#" cfsqltype="cf_sql_timestamp" />,
				Arrival_DateTime = <cfqueryparam value="#getSpecificAirID.Return_Arrival#" cfsqltype="cf_sql_timestamp" null="true" />,
				Value_ID = <cfqueryparam value="#session.Value_ID#" cfsqltype="cf_sql_numeric" />,
				Policy_ID = <cfqueryparam value="#session.Policy_ID#" cfsqltype="cf_sql_numeric" />
				WHERE Search_ID = <cfqueryparam value="#session.searches[arguments.t]['Search_ID']#" cfsqltype="cf_sql_numeric" />
				</cfquery>
			</cfif>
			<cfif ListFind('NYC,CHI,LON,PAR,MOW,TYO,WAS', session.searches[arguments.t].Arrival_City)
			AND (session.searches[arguments.t].Air_Type NEQ 'MD')>
				<cfquery name="getSpecificAirport" datasource="book">
				SELECT Arrival_City
				FROM Air_Segments
				WHERE Search_ID = <cfqueryparam value="#session.searches[arguments.t]['Search_ID']#" cfsqltype="cf_sql_numeric" />
				AND Air_ID = <cfqueryparam value="#getSpecificAirID.Air_ID#" cfsqltype="cf_sql_numeric" />
				AND Air_Type = <cfqueryparam value="Fare" cfsqltype="cf_sql_varchar" />
				AND Direction = <cfqueryparam value="1" cfsqltype="cf_sql_numeric" />
				ORDER BY Depart_DateTime DESC
				</cfquery>
				<cfset session.searches[arguments.t].Arrival_City = getSpecificAirport.Arrival_City>
			</cfif>
			<!--- Remove all other tabs --->
			<cfset ArraySort(tabs, 'numeric')>
			<cfset tabs = ArraytoList(tabs)>
			<cfloop list="#tabs#" index="num">			
				<cfif num NEQ arguments.t>
					<cfset temp = StructDelete(session.searches, num, "true" )>
				</cfif>
			</cfloop>
			<cfset tabs = StructKeyArray(session.searches)>
			<cfset ArraySort(tabs, 'numeric')>
			<cfset tabs = ArraytoList(tabs)>
			<cfloop list="#tabs#" index="num">			
				<cfset tempsearches[1] = session.searches[num]>
			</cfloop>
			<cfset session.searches = tempsearches>
			<cfset session.searches[1]['Air'] = 3>
		<cfelse>
			<cflocation url="../main/airnotfound" addtoken="false" >
		</cfif>
		
		<cfreturn />
	</cffunction>
		
</cfcomponent>