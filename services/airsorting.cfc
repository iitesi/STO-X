<cfcomponent output="true">
	
<!--- air : fare --->
	<cffunction name="fare" returntype="query">
		<cfargument name="Search_ID" 		type="any" 		required="true">
		
		<cfquery name="local.sorting">
		SELECT Token, MIN(TotalPrice) AS Total
		FROM Trips
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" >
		GROUP BY Token
		ORDER BY Total
		</cfquery>
		
		<cfreturn sorting />
	</cffunction>
	
<!--- air : depart --->
	<cffunction name="depart" returntype="query">
		<cfargument name="Search_ID" 		type="any" 		required="true">
		
		<cfquery name="local.sorting">
		SELECT Token, MIN(DepartureTime) AS Depart
		FROM Trips, Trip_Segments, Segments
		WHERE Trips.Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" >
		AND Trips.Search_ID = Trip_Segments.Search_ID
		AND Trips.Search_Key = Trip_Segments.Search_Key
		AND Trips.Trip_ID = Trip_Segments.Trip_ID
		AND Trip_Segments.Search_ID = Segments.Search_ID
		AND Trip_Segments.Search_Key = Segments.Search_Key
		AND Trip_Segments.Segment_ID = Segments.Segment_ID
		GROUP BY Token
		ORDER BY Depart
		</cfquery>
		
		<cfreturn sorting />
	</cffunction>
	
<!--- air : arrival --->
	<cffunction name="arrival" returntype="query">
		<cfargument name="Search_ID" 		type="any" 		required="true">
		
		<cfquery name="local.sorting">
		SELECT Token, MAX(ArrivalTime) AS Depart
		FROM Trips, Trip_Segments, Segments
		WHERE Trips.Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" >
		AND [Group] = <cfqueryparam value="0" cfsqltype="cf_sql_numeric" >
		AND Trips.Search_ID = Trip_Segments.Search_ID
		AND Trips.Search_Key = Trip_Segments.Search_Key
		AND Trips.Trip_ID = Trip_Segments.Trip_ID
		AND Trip_Segments.Search_ID = Segments.Search_ID
		AND Trip_Segments.Search_Key = Segments.Search_Key
		AND Trip_Segments.Segment_ID = Segments.Segment_ID
		GROUP BY Token
		ORDER BY Depart
		</cfquery>
		
		<cfreturn sorting />
	</cffunction>
	
<!--- air : carriers --->
	<cffunction name="carriers" returntype="query">
		<cfargument name="Search_ID" 		type="any" 		required="true">
		
		<cfquery name="local.carriers">
		SELECT DISTINCT Carrier, CarrierName
		FROM Segments
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" >
		ORDER BY CarrierName
		</cfquery>
		
		<cfreturn carriers />
	</cffunction>
	
</cfcomponent>