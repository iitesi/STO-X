<cfcomponent displayname="airfare" output="true">

<!--- airfare : LowFareSearchReq --->
	<cffunction name="LowFareSearchReq" returntype="string" output="false">
		<cfargument name="Search_ID" 	type="numeric" 		required="true">
		<cfargument name="policyair" 	type="query" 		required="true">
		
		<cfset local.message = StructNew()>
		
		<cfquery name="local.getsearch" datasource="book">
		SELECT Air_Type, Airlines, International, Depart_City, Depart_DateTime, Depart_TimeType, Arrival_City, Arrival_DateTime, Arrival_TimeType, ClassOfService
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<cfif getsearch.Air_Type EQ 'MD'>
			<cfquery name="local.getsearchlegs" datasource="book">
			SELECT Depart_City, Arrival_City, Depart_DateTime, Depart_TimeType
			FROM Searches_Legs
			WHERE Search_ID = <cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_numeric" />
			</cfquery>
		</cfif>
		
		<cfsavecontent variable="message">
			<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
				<soapenv:Header/>
				<soapenv:Body>
					<air:LowFareSearchReq TargetBranch="P7003155" xmlns:air="http://www.travelport.com/schema/air_v18_0" xmlns:com="http://www.travelport.com/schema/common_v15_0" AuthorizedBy="Test">
						<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
						<air:SearchAirLeg>
							<air:SearchOrigin>
								<com:Airport Code="#getsearch.Depart_City#" />
							</air:SearchOrigin>
							<air:SearchDestination>
								<com:Airport Code="#getsearch.Arrival_City#" />
							</air:SearchDestination>
							<air:SearchDepTime PreferredTime="#DateFormat(getsearch.Depart_DateTime, 'yyyy-mm-dd')#" />
							<air:AirLegModifiers RequireSingleCarrier="true" ProhibitOvernightLayovers="true" AllowDirectAccess="false" MaxConnections="2" MaxStops="2" ProhibitMultiAirportConnection="true" PreferNonStop="true">
								<air:PreferredCabins>
									<air:CabinClass Type="Economy" />
								</air:PreferredCabins>
							</air:AirLegModifiers>
						</air:SearchAirLeg>
						<cfif getsearch.Air_Type EQ 'RT'>
							<air:SearchAirLeg>
								<air:SearchOrigin>
									<com:Airport Code="#getsearch.Arrival_City#" />
								</air:SearchOrigin>
								<air:SearchDestination>
									<com:Airport Code="#getsearch.Depart_City#" />
								</air:SearchDestination>
								<air:SearchDepTime PreferredTime="#DateFormat(getsearch.Arrival_DateTime, 'yyyy-mm-dd')#" />
								<air:AirLegModifiers RequireSingleCarrier="true" ProhibitOvernightLayovers="true" AllowDirectAccess="false" MaxConnections="2" MaxStops="2" ProhibitMultiAirportConnection="true" PreferNonStop="true">
									<air:PreferredCabins>
										<air:CabinClass Type="Economy" />
									</air:PreferredCabins>
								</air:AirLegModifiers>
							</air:SearchAirLeg>
						<cfelseif getsearch.Air_Type EQ 'MD'>
							<cfloop query="getsearchlegs">
								<air:SearchAirLeg>
									<air:SearchOrigin>
										<com:Airport Code="#getsearchlegs.Depart_City#" />
									</air:SearchOrigin>
									<air:SearchDestination>
										<com:Airport Code="#getsearchlegs.Arrival_City#" />
									</air:SearchDestination>
									<air:SearchDepTime PreferredTime="#DateFormat(getsearchlegs.Depart_DateTime, 'yyyy-mm-dd')#" />
									<air:AirLegModifiers RequireSingleCarrier="true" ProhibitOvernightLayovers="true" AllowDirectAccess="false" MaxConnections="2" MaxStops="2" ProhibitMultiAirportConnection="true" PreferNonStop="true">
										<air:PreferredCabins>
											<air:CabinClass Type="Economy" />
										</air:PreferredCabins>
									</air:AirLegModifiers>
								</air:SearchAirLeg>
							</cfloop>
						</cfif>
					    <com:SearchPassenger Code="ADT" />
						<com:PointOfSale ProviderCode="1V" PseudoCityCode="1M98" />
					</air:LowFareSearchReq>
				</soapenv:Body>
			</soapenv:Envelope>
		</cfsavecontent>
		
		<cfreturn message/>
	</cffunction>
	
</cfcomponent>