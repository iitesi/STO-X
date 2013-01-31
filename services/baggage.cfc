<cfcomponent output="false">
	
<!---
baggage
---> 
	<cffunction name="baggage" output="false">
		<cfargument name="SearchID" 	required="true">
		<cfargument name="nTripID" 		required="true">
		<cfargument name="Group" 		required="false"	default="">
		
		<cfset local.sCarriers = ''>
		<cfif arguments.Group EQ ''>
			<cfset sCarriers = ArrayToList(session.searches[arguments.SearchID].stTrips[arguments.nTripID].Carriers)>
		<cfelse>
			<cfloop collection="#session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTripID].Groups#" index="local.Group">
				<cfif arguments.Group EQ Group>
					<cfloop collection="#session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTripID].Groups[Group].Segments#" index="local.nSegment">
						<cfset sCarriers = ListAppend(sCarriers, session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTripID].Groups[Group].Segments[nSegment].Carrier)>
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>

		<cfquery name="local.qBaggage" datasource="Corporate_Production">
		SELECT ShortCode, Name, IsNull(OnlineDomBag1,0) AS OnlineDomBag1, IsNull(DomBag1,0) AS DomBag1, IsNull(OnlineDomBag2,0) AS OnlineDomBag2, IsNull(DomBag2,0) AS DomBag2, Baggage_Link, CreateUpdate_Datetime
		FROM Suppliers LEFT OUTER JOIN OnlineCheckIn_Links ON OnlineCheckIn_Links.AccountID = Suppliers.AccountID AND Link_Display = 1 
		WHERE ShortCode IN ('#PreserveSingleQuotes(Replace(sCarriers, ",", "','", "ALL"))#')
		AND CustType = <cfqueryparam value="A" cfsqltype="cf_sql_varchar" >
		</cfquery>
		
		<cfreturn qBaggage/>
	</cffunction>

</cfcomponent>