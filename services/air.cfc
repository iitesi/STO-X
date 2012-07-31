<cfcomponent displayname="Air" output="true">
	
<!--- init --->
	<cffunction name="init" access="remote" output="false" returntype="any">
		<cfreturn this>
	</cffunction>
	
<!--- air : database --->
	<cffunction name="database" access="remote" returntype="void" output="true">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="airresults" type="any" required="false">
		
		<cfset var airresultsdb = arguments.airresults>
		<cfset var segmentcount = 0>
		<cfset var dbcount = 1>
		<cfset var currenttripcount = 0>
		<cfset var groupcount = 0>
		<cfset var trip = 0>
		<cfset var segment = 0>
		<cfset var currentsegmentcount = 0>
		
		<!---<cftry>--->
			<cfif IsStruct(airresultsdb) AND NOT StructIsEmpty(airresultsdb)>
				<cfset segmentcount = 0>
				<cfset dbcount = 1>
				<cfloop condition="dbcount LTE ArrayLen(StructKeyArray(airresultsdb))">
					<cfquery datasource="book">
					INSERT INTO Air_Trips (Air_ID, Air_Type, Token, Base_Fare, Carriers, Fare_Basis, Fare_Rules, Flights,
					PTC, Outbound_Depart, Outbound_Arrival, Penalty, Private_Fare, Refundable, Return_Depart,
					Return_Arrival, Search_ID, Stops, Taxes, Total_Fare, Trip_Time, Trip_Text, Class, Currency)
					<cfset currenttripcount = 0>
					<cfset groupcount = 0>
					<cfloop list="#StructKeyList(airresultsdb)#" index="trip">
						<cfset currenttripcount++>
						<cfif currenttripcount GTE dbcount AND currenttripcount LT (dbcount + 75)>
							<cfset groupcount++>
							<cfif groupcount NEQ 1>UNION ALL</cfif> SELECT
							<cfqueryparam value="#airresultsdb[trip].Air_ID#" cfsqltype="cf_sql_numeric" />,
							<cfqueryparam value="#airresultsdb[trip].Air_Type#" cfsqltype="cf_sql_varchar" />,
							<cfqueryparam value="#airresultsdb[trip].Token#" cfsqltype="cf_sql_varchar" />,
							<cfqueryparam value="#airresultsdb[trip].Base_Fare#" cfsqltype="cf_sql_money" />,
							<cfqueryparam value="#airresultsdb[trip].Carriers#" cfsqltype="cf_sql_varchar" />,
							<cfqueryparam value="#airresultsdb[trip].Fare_Basis#" cfsqltype="cf_sql_varchar" />,
							<cfqueryparam value="#airresultsdb[trip].Fare_Rules#" cfsqltype="cf_sql_varchar" />,
							<cfqueryparam value="#airresultsdb[trip].Flights#" cfsqltype="cf_sql_varchar" />,
							<cfqueryparam value="#airresultsdb[trip].PTC#" cfsqltype="cf_sql_varchar" />,
							<cfqueryparam value="#airresultsdb[trip].Outbound_Depart#" cfsqltype="cf_sql_timestamp" />,
							<cfqueryparam value="#airresultsdb[trip].Outbound_Arrival#" cfsqltype="cf_sql_timestamp" />,
							<cfqueryparam value="#airresultsdb[trip].Penalty#" cfsqltype="cf_sql_numeric" />,
							<cfqueryparam value="#airresultsdb[trip].Private_Fare#" cfsqltype="cf_sql_numeric" />,
							<cfqueryparam value="#airresultsdb[trip].Refundable#" cfsqltype="cf_sql_numeric" />,
							<cfif IsDate(airresultsdb[trip].Return_Depart)>
								<cfqueryparam value="#airresultsdb[trip].Return_Depart#" cfsqltype="cf_sql_timestamp" />,
							<cfelse>
								NULL,
							</cfif>
							<cfif IsDate(airresultsdb[trip].Return_Arrival)>
								<cfqueryparam value="#airresultsdb[trip].Return_Arrival#" cfsqltype="cf_sql_timestamp" />,
							<cfelse>
								NULL,
							</cfif>
							<cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />,
							<cfqueryparam value="#airresultsdb[trip].Stops#" cfsqltype="cf_sql_numeric" />,
							<cfqueryparam value="#airresultsdb[trip].Taxes#" cfsqltype="cf_sql_money" />,
							<cfqueryparam value="#airresultsdb[trip].Total_Fare#" cfsqltype="cf_sql_money" />,
							<cfqueryparam value="#airresultsdb[trip].Trip_Time#" cfsqltype="cf_sql_numeric" />,
							<cfqueryparam value="#airresultsdb[trip].Trip_Text#" cfsqltype="cf_sql_varchar" />,
							<cfqueryparam value="#airresultsdb[trip].Class#" cfsqltype="cf_sql_varchar" />,
							<cfqueryparam value="#airresultsdb[trip].Currency#" cfsqltype="cf_sql_varchar" />
							<cfset segmentcount = segmentcount + ArrayLen(StructKeyArray(airresultsdb[trip]['Segments']))>
						</cfif>
					</cfloop>
					</cfquery>
					<cfset dbcount = dbcount + 75>
				</cfloop>
				
				<cfset dbcount = 1>
				<cfloop condition="dbcount LTE segmentcount">
					<cfquery datasource="book">
					INSERT INTO Air_Segments (Air_ID, Segment_Number, Air_Type, Arrival_City, Arrival_DateTime, Carrier, Day_Change,
					Depart_City, Depart_DateTime, Direction, Elapsed_Time, Elapsed_Text, Equipment, Flight,
					Flight_Time, Flight_Text, Stop, Search_ID, Segment_Class)
					<cfset currenttripcount = 0>
					<cfset currentsegmentcount = 0>
					<cfset groupcount = 0>
					<cfloop list="#StructKeyList(airresultsdb)#" index="trip">
						<cfset currenttripcount++>
						<cfloop list="#StructKeyList(airresultsdb[trip].Segments)#" index="segment">
							<cfset currentsegmentcount++>
							<cfif currentsegmentcount GTE dbcount AND currentsegmentcount LT (dbcount + 75)>
								<cfset groupcount++>
								<cfif groupcount NEQ 1>UNION ALL</cfif> SELECT
								<cfqueryparam value="#airresultsdb[trip].Air_ID#" cfsqltype="cf_sql_numeric" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Segment_Number#" cfsqltype="cf_sql_numeric" />,
								<cfqueryparam value="#airresultsdb[trip].Air_Type#" cfsqltype="cf_sql_varchar" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Arrival_City#" cfsqltype="cf_sql_varchar" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Arrival_DateTime#" cfsqltype="cf_sql_timestamp" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Carrier#" cfsqltype="cf_sql_varchar" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Day_Change#" cfsqltype="cf_sql_numeric" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Depart_City#" cfsqltype="cf_sql_varchar" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Depart_DateTime#" cfsqltype="cf_sql_timestamp" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Direction#" cfsqltype="cf_sql_varchar" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Elapsed_Time#" cfsqltype="cf_sql_varchar" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Elapsed_Text#" cfsqltype="cf_sql_varchar" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Equipment#" cfsqltype="cf_sql_varchar" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Flight#" cfsqltype="cf_sql_numeric" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Flight_Time#" cfsqltype="cf_sql_numeric" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Flight_Text#" cfsqltype="cf_sql_varchar" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Stop#" cfsqltype="cf_sql_numeric" />,
								<cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />,
								<cfqueryparam value="#airresultsdb[trip]['Segments'][segment].Segment_Class#" cfsqltype="cf_sql_varchar" />
							</cfif>
						</cfloop>
					</cfloop>	
					</cfquery>
					<cfset dbcount = dbcount + 75>
				</cfloop>
			</cfif>
		<!---<cfcatch>
			<cf_error subject="STO 4.0" app="STO" cfcatchStruct="#cfcatch#" cgiStruct="#cgi#" sessionStruct="#session#">
		</cfcatch>
		</cftry>--->
		
		<cfreturn />
	</cffunction>
	
<!--- air : tripsbackfill --->
	<cffunction name="tripsbackfill" access="remote" returntype="void" output="true">
		<cfargument name="Search_ID" type="any" required="true">
		<cfargument name="Acct_ID" type="any" required="true">
		<cfargument name="Profile_ID" type="any" required="true">
		
		<cfset var getAllPreferred = ''>
		<cfset var getAllBlacklisted = ''>
		<cfset var getdups = ''>
		<cfset var airids = ArrayNew(1)>
		<cfset var count = 0>
		
		<cfquery datasource="book">
		UPDATE Air_Trips
		SET Policy_Text = ''
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		AND Air_Type = <cfqueryparam value="Fare" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<cfquery datasource="book">
		<!--- Remove private fares when multiple carriers are present --->
		UPDATE Air_Trips
		SET Active = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />,
		Policy = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />,
		Policy_Text = IsNull(Policy_Text, '')+'Multi carrier private fare<br>'
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		AND Carriers LIKE '%,%'
		AND Private_Fare = <cfqueryparam value="1" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<cfquery datasource="book">
		<!--- Populate airport name --->
		UPDATE Air_Segments
		SET Depart_Airport = Depart.Location_Display,
		Arrival_Airport = Arrival.Location_Display
		FROM lu_Geography AS Depart, lu_Geography AS Arrival
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		AND Depart.Location_Type = <cfqueryparam value="125" cfsqltype="cf_sql_numeric" />
		AND Arrival.Location_Type = <cfqueryparam value="125" cfsqltype="cf_sql_numeric" />
		AND Air_Segments.Depart_City = Depart.Location_Code
		AND Air_Segments.Arrival_City = Arrival.Location_Code
		AND Depart_Airport = <cfqueryparam value="" cfsqltype="cf_sql_varchar" />
		AND Arrival_Airport = <cfqueryparam value="" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<cfquery datasource="book">
		<!--- Populate carrier name --->	
		UPDATE Air_Segments
		SET Carrier_Name = Vendor_Name
		FROM lu_Vendors
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		AND Vendor_Type = <cfqueryparam value="A" cfsqltype="cf_sql_varchar" />
		AND Air_Segments.Carrier = lu_Vendors.Vendor_Code
		AND Carrier_Name = <cfqueryparam value="" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<cfquery datasource="book">
		<!--- Populate equipment name --->
		UPDATE Air_Segments
		SET Equipment_Name = Equip_Description
		FROM lu_equipment
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		AND Air_Segments.Equipment = lu_equipment.Equip_Code
		AND Equipment_Name = <cfqueryparam value="" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<cfquery datasource="book">
		<!--- Marked preferred carriers --->
		UPDATE Air_Trips
		SET Preferred = <cfqueryparam value="1" cfsqltype="cf_sql_numeric" />
		FROM Air_Trips, Air_Segments
		WHERE Air_Trips.Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		AND Air_Trips.Search_ID = Air_Segments.Search_ID
		AND Air_Trips.Air_Type = Air_Segments.Air_Type
		AND Air_Trips.Air_ID = Air_Segments.Air_ID
		AND Carrier IN (SELECT Vendor_ID 
						FROM Preferred_Vendors
						WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
						AND Type = <cfqueryparam value="A" cfsqltype="cf_sql_varchar" />)
		AND Preferred = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
		</cfquery>
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
		<!--- Remove non supported carriers --->
		<cfquery datasource="book">
		UPDATE Air_Trips
		SET Active = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />,
		Policy = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		AND (Carriers LIKE '%ZK%'
		OR Carriers LIKE '%SY%'
		OR Carriers LIKE '%NK%'
		OR Carriers LIKE '%G4%')
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
		<!--- Mark dup itineraries as inactive --->
		<cfquery name="getdups" datasource="book">
		SELECT Air_ID, Token, Total_Fare
		FROM Air_Trips
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		AND Air_Type = <cfqueryparam value="Fare" cfsqltype="cf_sql_varchar" />
		AND Active = <cfqueryparam value="1" cfsqltype="cf_sql_numeric" />
		AND Token IN (SELECT Token
					FROM (SELECT Token, COUNT(Token) AS TotalCount
							FROM Air_Trips
							WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
							AND Air_Type = <cfqueryparam value="Fare" cfsqltype="cf_sql_varchar" />
							GROUP BY Token) AS lkj
					WHERE TotalCount > <cfqueryparam value="1" cfsqltype="cf_sql_numeric" />)
		ORDER BY Token, Total_Fare
		</cfquery>
		<cfoutput query="getdups" group="Token">
			<cfset count = 0>
			<cfoutput>
				<cfset count++ >
				<cfif count NEQ 1>
					<cfset ArrayAppend(airids, Air_ID)>
				</cfif>
			</cfoutput>
		</cfoutput>
		<cfif NOT ArrayIsEmpty(airids)>
			<cfquery datasource="book">
			UPDATE Air_Trips
			SET Policy_Text = IsNull(Policy_Text, '')+'Duplicate itinerary<br>',
			Active = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" />
			WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
			AND Air_Type = <cfqueryparam value="Fare" cfsqltype="cf_sql_varchar" />
			AND Air_ID IN (#ArrayToList(airids)#)
			</cfquery>
		</cfif>
		
		<cfreturn />
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
	
<!--- air : checkpendingstatus --->
	<cffunction name="checkpendingstatus" access="remote" returntype="void" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="Air_Type" type="string" required="true">
		<cfargument name="t" type="numeric" required="true">
		
		<cfset var count = 0>
		<cfset var tripcount = 0>
		<cfset var getResults = ''>
		<cfset var getNewResults = ''>
		
		<cfquery name="getResults" datasource="book">
		SELECT COUNT(Air_ID) AS Trips
		FROM Air_Trips
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		AND Air_Type = <cfqueryparam value="#arguments.Air_Type#" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<cfloop condition="getResults.Trips EQ 0 AND count LTE 10">
			<cfset count++ />
			<cfset sleep(1000)>
			<cfquery name="getResults" datasource="book">
			SELECT COUNT(Air_ID) AS Trips
			FROM Air_Trips
			WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
			AND Air_Type = <cfqueryparam value="#arguments.Air_Type#" cfsqltype="cf_sql_varchar" />
			</cfquery>
		</cfloop>
		<cfset sleep(2000)>
		<cfset tripcount = getResults.Trips>
		<cfquery name="getNewResults" datasource="book">
		SELECT COUNT(Air_ID) AS Trips
		FROM Air_Trips
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		AND Air_Type = <cfqueryparam value="#arguments.Air_Type#" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<cfset count = 0>
		<cfloop condition="tripcount NEQ getNewResults.Trips AND count LTE 20">
			<cfset tripcount = getNewResults.Trips>
			<cfset sleep(2000)>
			<cfquery name="getNewResults" datasource="book">
			SELECT COUNT(Air_ID) AS Trips
			FROM Air_Trips
			WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
			AND Air_Type = <cfqueryparam value="#arguments.Air_Type#" cfsqltype="cf_sql_varchar" />
			</cfquery>
		</cfloop>
		<cfif getNewResults.Trips GT 0 AND arguments.Air_Type EQ 'Fare'>
			<cfset session.searches[arguments.t]['Air'] = 2>
		<cfelseif getNewResults.Trips EQ 0 AND arguments.Air_Type EQ 'Fare'>
			<cfset session.searches[arguments.t]['Air'] = 1>
		<cfelseif getNewResults.Trips GT 0 AND arguments.Air_Type EQ 'Schedule'>
			<cfset session.searches[arguments.t]['Air_Schedule'] = 2>
		<cfelseif getNewResults.Trips EQ 0 AND arguments.Air_Type EQ 'Schedule'>
			<cfset session.searches[arguments.t]['Air_Schedule'] = 1>
		</cfif>
		
		<cfreturn />
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