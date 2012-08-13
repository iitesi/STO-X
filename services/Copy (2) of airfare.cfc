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

<!--- airfare : formatXML --->
	<cffunction name="formatXML" returntype="array" output="false">
		<cfargument name="MasterXML" type="string" required="true">
		
		<cfset local.masterAirXML = XMLParse(arguments.MasterXML)>
		<cfset masterAirXML = masterAirXML.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren>
		
		<cfreturn masterAirXML />
	</cffunction>

<!--- airfare : searchkey --->
	<cffunction name="searchkey" returntype="numeric" output="false">
		
		<cfreturn RandRange(1,10000) />
	</cffunction>
	
<!--- airfare : databasesegments --->
	<cffunction name="databasesegments" returntype="void" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="MasterXML" type="array" required="true">
		<cfargument name="Search_Key" type="numeric" required="true">
		
		<cfset local.timer = getTickCount()>
		
		<!--- Database segments --->
		<cfloop array="#arguments.MasterXML#" index="local.stAirDetailsNode">
			<cfif stAirDetailsNode.XMLName EQ 'air:AirSegmentList'>
				<cfquery>
				INSERT INTO Segments
				(Search_ID,
				Search_Key,
				Segment_ID,
				Carrier,
				OperatingCarrier,
				FlightNumber,
				Origin,
				DepartureTime,
				Destination,
				ArrivalTime,
				[Group],
				ClassOfService,
				Equipment,
				ChangeOfPlane,
				ETicketability,
				Distance,
				FlightTime,
				TravelTime,
				BookingCodeInfo)
				<cfsavecontent variable="local.insertData">
					<cfloop array="#stAirDetailsNode.XMLChildren#" index="local.stFlightNode">
						<cfset local.OperatingCarrier = ''>
						<cfset local.BookingCodeInfo = ''>
						<cfloop array="#stFlightNode.XMLChildren#" index="local.stDetailsNode">
							<cfif stDetailsNode.XMLName EQ 'air:CodeshareInfo'>
								<cfset OperatingCarrier = stDetailsNode.XMLAttributes.OperatingCarrier>
							<cfelseif stDetailsNode.XMLName EQ 'air:AirAvailInfo'>
								<cfset BookingCodeInfo = stDetailsNode.XMLChildren[1].XMLAttributes.BookingCounts>
							</cfif>
						</cfloop>
						SELECT
						<cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#arguments.Search_Key#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#stFlightNode.XMLAttributes.key#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#stFlightNode.XMLAttributes.Carrier#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#OperatingCarrier#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#stFlightNode.XMLAttributes.FlightNumber#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#stFlightNode.XMLAttributes.Origin#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#stFlightNode.XMLAttributes.DepartureTime#" cfsqltype="cf_sql_timestamp" >,
						<cfqueryparam value="#stFlightNode.XMLAttributes.Destination#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#stFlightNode.XMLAttributes.ArrivalTime#" cfsqltype="cf_sql_timestamp" >,
						<cfqueryparam value="#stFlightNode.XMLAttributes.Group#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#stFlightNode.XMLAttributes.ClassOfService#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#stFlightNode.XMLAttributes.Equipment#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#stFlightNode.XMLAttributes.ChangeOfPlane#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#stFlightNode.XMLAttributes.ETicketability#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#stFlightNode.XMLAttributes.Distance#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#stFlightNode.XMLAttributes.FlightTime#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#stFlightNode.XMLAttributes.TravelTime#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#BookingCodeInfo#" cfsqltype="cf_sql_varchar" >
						UNION ALL
					</cfloop>
				</cfsavecontent>
				#Left(Trim(insertData), Len(Trim(insertData)) - 10)#
				</cfquery>
			</cfif>
		</cfloop>
		
		<cflog text="airfare.databasesegments 	: #(getTickCount()-timer)# ms" file="airfare.log" type="information">

		<cfreturn />
	</cffunction>
	
<!--- airfare : databasefares --->
	<cffunction name="databasefares" returntype="void" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="MasterXML" type="array" required="true">
		<cfargument name="Search_Key" type="numeric" required="true">
		
		<cfset local.timer = getTickCount()>
		
		<!--- Database fares --->
		<cfloop array="#arguments.MasterXML#" index="local.stAirDetailsNode">
			<cfif stAirDetailsNode.XMLName EQ 'air:FareInfoList'>
				<cfquery>
				INSERT INTO Fares
				(Search_ID,
				Search_Key,
				Fare_ID,
				Currency,
				Amount,
				Origin,
				DepartureDate,
				Destination,
				FareBasis,
				EffectiveDate,
				NotValidAfter,
				NotValidBefore,
				PassengerTypeCode,
				PrivateFare,
				NegotiatedFare)
				<cfsavecontent variable="local.insertData">
					<cfloop array="#stAirDetailsNode.XMLChildren#" index="local.stFareNode">
						SELECT
						<cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#arguments.Search_Key#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#stFareNode.XMLAttributes.key#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#Left(stFareNode.XMLAttributes.Amount, 3)#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#Right(stFareNode.XMLAttributes.Amount, Len(stFareNode.XMLAttributes.Amount)-3)#" cfsqltype="cf_sql_money" >,
						<cfqueryparam value="#stFareNode.XMLAttributes.Origin#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#stFareNode.XMLAttributes.DepartureDate#" cfsqltype="cf_sql_timestamp" >,
						<cfqueryparam value="#stFareNode.XMLAttributes.Destination#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#stFareNode.XMLAttributes.FareBasis#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#stFareNode.XMLAttributes.EffectiveDate#" cfsqltype="cf_sql_timestamp" >,
						<cfqueryparam value="#stFareNode.XMLAttributes.NotValidAfter#" cfsqltype="cf_sql_timestamp" >,
						<cfqueryparam value="#stFareNode.XMLAttributes.NotValidBefore#" cfsqltype="cf_sql_timestamp" >,
						<cfqueryparam value="#stFareNode.XMLAttributes.PassengerTypeCode#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#stFareNode.XMLAttributes.PrivateFare#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#stFareNode.XMLAttributes.NegotiatedFare#" cfsqltype="cf_sql_integer" >
						UNION ALL
					</cfloop>
				</cfsavecontent>
				#Left(Trim(insertData), Len(Trim(insertData)) - 10)#
				</cfquery>
			</cfif>
		</cfloop>
		
		<cflog text="airfare.databasefares 	: #(getTickCount()-timer)# ms" file="airfare.log" type="information">

		<cfreturn />
	</cffunction>
	
<!--- airfare : databasetrips --->
	<cffunction name="databasetrips" returntype="void" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="MasterXML" type="array" required="true">
		<cfargument name="Search_Key" type="numeric" required="true">
		<cfargument name="Start" type="numeric" default="0">
		<cfargument name="Loop" type="numeric" default="1">
			
		<cfset local.timer = getTickCount()>
		
		<!--- Database trip --->
		<cfquery>
		INSERT INTO Trips
		(Search_ID,
		Search_Key,
		Trip_ID,
		Currency,
		BasePrice,
		Taxes,
		TotalPrice,
		ChangePenalty,
		ETicketability,
		PassengerType)
		<cfset local.cnt = 0>
		<cfsavecontent variable="local.insertData">
			<cfloop array="#arguments.MasterXML#" index="local.stAPSolution">
				<cfif stAPSolution.XMLName EQ 'air:AirPricingSolution'>
					<cfif cnt GTE arguments.Start AND cnt LT (arguments.Loop*200)>
						<cfset cnt++>
						<cfset local.Trip_ID = stAPSolution.XMLAttributes.key>
						<cfloop array="#stAPSolution.XMLChildren#" index="local.stAirSegment">
							<cfif stAirSegment.XMLName EQ 'air:AirPricingInfo'>
								<cfset local.ETicketability = stAirSegment.XMLAttributes.ETicketability>
								<cfset local.BasePrice = stAirSegment.XMLAttributes.BasePrice>
								<cfset local.TotalPrice = stAirSegment.XMLAttributes.TotalPrice>
								<cfset local.Taxes = stAirSegment.XMLAttributes.Taxes>
								<cfloop array="#stAirSegment.XMLChildren#" index="local.stFareInfo">
									<cfif stFareInfo.XMLName EQ 'air:PassengerType'>
										<cfset local.PassengerType = stFareInfo.XMLAttributes.Code>
									<cfelseif stFareInfo.XMLName EQ 'air:ChangePenalty'>
										<cfloop array="#stFareInfo.XMLChildren#" index="local.stFare">
											<cfset local.ChangePenalty = stFare.XMLText>
										</cfloop>
									</cfif>
								</cfloop>
							</cfif>
						</cfloop>
						SELECT
						<cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#arguments.Search_Key#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#Trip_ID#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#Left(BasePrice, 3)#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#Right(BasePrice, Len(BasePrice)-3)#" cfsqltype="cf_sql_money" >,
						<cfqueryparam value="#Right(Taxes, Len(Taxes)-3)#" cfsqltype="cf_sql_money" >,
						<cfqueryparam value="#Right(TotalPrice, Len(TotalPrice)-3)#" cfsqltype="cf_sql_money" >,
						<cfqueryparam value="#Right(ChangePenalty, Len(ChangePenalty)-3)#" cfsqltype="cf_sql_money" >,
						<cfqueryparam value="#ETicketability#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#PassengerType#" cfsqltype="cf_sql_varchar" >
						UNION ALL
					</cfif>
				</cfif>
			</cfloop>
		</cfsavecontent>
		#Left(Trim(insertData), Len(Trim(insertData)) - 10)#
		</cfquery>
		
		<cflog text="airfare.databasetrips 	: #(getTickCount()-timer)# ms" file="airfare.log" type="information">
		
		<cfif cnt GTE (arguments.Loop*200)>
			<cfset databasetrips(arguments.Search_ID, arguments.MasterXML, arguments.Search_Key, (arguments.Start + cnt), (arguments.Loop+1))>
		</cfif>
		
		<cfreturn />
	</cffunction>
	
<!--- airfare : databasetripfares --->
	<cffunction name="databasetripfares" returntype="void" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="MasterXML" type="array" required="true">
		<cfargument name="Search_Key" type="numeric" required="true">
		<cfargument name="Start" type="numeric" default="0">
		<cfabort>
		<cfset local.timer = getTickCount()>
		
		<!--- Database trip --->
		<cfquery>
		INSERT INTO Trip_Fares
		(Search_ID,
		Search_Key,
		Trip_ID,
		Fare_ID)
		<cfset local.cnt = arguments.Start>
		<cfsavecontent variable="local.insertData">
			<cfloop array="#arguments.MasterXML#" index="local.stAPSolution">
				<cfif stAPSolution.XMLName EQ 'air:AirPricingSolution'>
					<cfset local.Trip_ID = stAPSolution.XMLAttributes.key>
					<cfloop array="#stAPSolution.XMLChildren#" index="local.airseg">
						<cfif airseg.XMLName EQ 'air:AirPricingInfo'>
							<cfloop array="#airseg.XMLChildren#" index="local.stFareInfo">
								<cfif stFareInfo.XMLName EQ 'air:FareInfoRef'>
									<cfif cnt LTE 1999>
										<cfset cnt++>
										SELECT 
										<cfqueryparam value="#arguments.Search_ID#" cfsqltype="cf_sql_integer" >,
										<cfqueryparam value="#arguments.Search_Key#" cfsqltype="cf_sql_integer" >,
										<cfqueryparam value="#Trip_ID#" cfsqltype="cf_sql_varchar" >,
										<cfqueryparam value="#stFareInfo.XMLAttributes.Key#" cfsqltype="cf_sql_varchar" >
										UNION ALL
									</cfif>
								</cfif>
							</cfloop>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
		</cfsavecontent>
		#Left(Trim(insertData), Len(Trim(insertData)) - 10)#
		</cfquery>
		
		<cflog text="airfare.databasetrips 	: #(getTickCount()-timer)# ms" file="airfare.log" type="information">
		
		<cfif cnt EQ 2000>
			<cfset arguments.Start = cnt>
			<cfset databasetripfares(arguments)>
		</cfif>
		
		<cfreturn />
	</cffunction>
	
</cfcomponent>