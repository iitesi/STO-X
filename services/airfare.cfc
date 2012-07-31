<cfcomponent displayname="airfare" output="true">

<!--- airfare : LowFareSearchReq --->
	<cffunction name="LowFareSearchReq" returntype="string" output="false">
		<cfargument name="policyair" type="query" required="true">
		
		<cfset local.message = StructNew()>
		<cfset arguments.Search_ID = session.searches[1].Search_ID>
		
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

<!--- airfare : parse --->
	<cffunction name="parse" returntype="struct" output="false">
		<cfargument name="MasterXML" type="string" required="true">
		
		<cfset local.timer = getTickCount()>
		<cfset local.MasterAirXML = XMLParse(arguments.MasterXML)>
		<cfset MasterAirXML = MasterAirXML.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren>
		
		<cfset local.strAirSegments = {}>
		<cfset local.strFareInfo = {}>
		<cfloop array="#MasterAirXML#" index="local.stAirDetailsNode">
			<!--- strAirSegments : create segment details for lookup for the master structure --->
			<cfif stAirDetailsNode.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#stAirDetailsNode.XMLChildren#" index="local.stFlightNode">
					<cfset local.key = stFlightNode.XMLAttributes.key>
					<cfset strAirSegments[key] = {
						ArrivalTime			: stFlightNode.XMLAttributes.ArrivalTime,
						Carrier 			: stFlightNode.XMLAttributes.Carrier,
						ChangeOfPlane		: stFlightNode.XMLAttributes.ChangeOfPlane,
						ClassOfService		: stFlightNode.XMLAttributes.ClassOfService,
						DepartureTime		: stFlightNode.XMLAttributes.DepartureTime,
						Destination			: stFlightNode.XMLAttributes.Destination,
						Distance			: stFlightNode.XMLAttributes.Distance,
						ETicketability		: stFlightNode.XMLAttributes.ETicketability,
						Equipment			: stFlightNode.XMLAttributes.Equipment,
						FlightNumber		: stFlightNode.XMLAttributes.FlightNumber,
						FlightTime			: stFlightNode.XMLAttributes.FlightTime,
						Group				: stFlightNode.XMLAttributes.Group,
						Origin				: stFlightNode.XMLAttributes.Origin,
						TravelTime			: stFlightNode.XMLAttributes.TravelTime
					}>
					<cfloop array="#stFlightNode.XMLChildren#" index="local.stDetailsNode">
						<cfif stDetailsNode.XMLName EQ 'air:CodeshareInfo'>
							<cfset strAirSegments[key].OperatingCarrier = stDetailsNode.XMLAttributes.OperatingCarrier>
						<cfelseif stDetailsNode.XMLName EQ 'air:AirAvailInfo'>
							<cfset strAirSegments[key].BookingCodeInfo = stDetailsNode.XMLChildren[1].XMLAttributes.BookingCounts>
						</cfif>
					</cfloop>
				</cfloop>
			<!--- strFareInfo : create fare details for lookup for the master structure --->
			<cfelseif stAirDetailsNode.XMLName EQ 'air:FareInfoList'>
				<cfloop array="#stAirDetailsNode.XMLChildren#" index="local.stFareNode">
					<cfset local.key = stFareNode.XMLAttributes.key>
					<cfset strFareInfo[key] = {
						Amount				: stFareNode.XMLAttributes.Amount,
						Destination			: stFareNode.XMLAttributes.Destination,
						EffectiveDate 		: stFareNode.XMLAttributes.EffectiveDate,
						FareBasis			: stFareNode.XMLAttributes.FareBasis,
						NegotiatedFare		: stFareNode.XMLAttributes.NegotiatedFare,
						NotValidAfter		: stFareNode.XMLAttributes.NotValidAfter,
						NotValidBefore		: stFareNode.XMLAttributes.NotValidBefore,
						Origin				: stFareNode.XMLAttributes.Origin,
						PassengerTypeCode 	: stFareNode.XMLAttributes.PassengerTypeCode,
						PrivateFare			: stFareNode.XMLAttributes.PrivateFare
					}>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfset local.strAirPricing = {}>
		<!--- strAirPricing : create master structure --->
		<cfloop array="#MasterAirXML#" index="local.stAPSolution">
			<cfif stAPSolution.XMLName EQ 'air:AirPricingSolution'>
				<cfset local.key = stAPSolution.XMLAttributes.key>
				<cfset strAirPricing[key] = {
							TotalPrice 		: 	stAPSolution.XMLAttributes.TotalPrice
				}>
				<cfloop array="#stAPSolution.XMLChildren#" index="local.stAirSegment">
					<cfif stAirSegment.XMLName EQ 'air:AirSegmentRef'>
						<cfset local.subkey = stAirSegment.XMLAttributes.Key>
						<cfset strAirPricing[key].AirSegmentRef[subkey] = strAirSegments[subkey]>
					<cfelseif stAirSegment.XMLName EQ 'air:AirPricingInfo'>
						<cfset local.subkey = stAirSegment.XMLAttributes.Key>
						<cfset strAirPricing[key].AirPricingInfo[subkey] = {
							ETicketability 	: 	stAirSegment.XMLAttributes.ETicketability,
							BasePrice 		: 	stAirSegment.XMLAttributes.BasePrice,
							TotalPrice 		: 	stAirSegment.XMLAttributes.TotalPrice,
							Taxes 			: 	stAirSegment.XMLAttributes.Taxes
						}>
						<cfloop array="#stAirSegment.XMLChildren#" index="local.stFareInfo">
							<cfif stFareInfo.XMLName EQ 'air:FareInfoRef'>
								<cfset strAirPricing[key].AirPricingInfo[subkey].FareInfoRef[stFareInfo.XMLAttributes.Key] = strFareInfo[stFareInfo.XMLAttributes.Key]>
							<cfelseif stFareInfo.XMLName EQ 'air:PassengerType'>
								<cfset strAirPricing[key].AirPricingInfo[subkey].PassengerType = stFareInfo.XMLAttributes.Code>
							<cfelseif stFareInfo.XMLName EQ 'air:ChangePenalty'>
								<cfset strAirPricing[key].AirPricingInfo[subkey].ChangePenalty = []>
								<cfloop array="#stFareInfo.XMLChildren#" index="local.stFare">
									<cfset ArrayAppend(strAirPricing[key].AirPricingInfo[subkey].ChangePenalty, stFare.XMLText)>
								</cfloop>
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
      
      <cflog text="airfare.parse : #(getTickCount()-timer)# ms" file="airfare.parse.log" type="information">
	
      <cfreturn strAirPricing />
</cffunction>


<!--- airfare : database --->
	<cffunction name="database" returntype="struct" output="false">
		<cfargument name="airpricing" type="string" required="true">
		
		
		
		<cfreturn true />
	</cffunction>

</cfcomponent>