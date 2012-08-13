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
	
<!--- airfare : dbsegments --->
	<cffunction name="dbsegments" returntype="void" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="MasterXML" type="array" required="true">
		<cfargument name="Search_Key" type="numeric" required="true">
		
		<cfset local.timer = getTickCount()>
		<cfset local.insertData = ''>
		
		<cfloop array="#arguments.MasterXML#" index="local.stAirDetailsNode">
			<cfif stAirDetailsNode.XMLName EQ 'air:AirSegmentList'>
				<cfsavecontent variable="insertData">
					<cfprocessingdirective suppressWhiteSpace="yes">
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
							#arguments.Search_ID#,#arguments.Search_Key#,#stFlightNode.XMLAttributes.key#,#stFlightNode.XMLAttributes.Carrier#,#OperatingCarrier#,#stFlightNode.XMLAttributes.FlightNumber#,#stFlightNode.XMLAttributes.Origin#,#DateFormat(stFlightNode.XMLAttributes.DepartureTime, 'mm/dd/yyyy')# #TimeFormat(stFlightNode.XMLAttributes.DepartureTime, 'HH:mm')#,#stFlightNode.XMLAttributes.Destination#,#DateFormat(stFlightNode.XMLAttributes.ArrivalTime, 'mm/dd/yyyy')# #TimeFormat(stFlightNode.XMLAttributes.ArrivalTime, 'HH:mm')#,#stFlightNode.XMLAttributes.Group#,#stFlightNode.XMLAttributes.ClassOfService#,#stFlightNode.XMLAttributes.Equipment#,#(stFlightNode.XMLAttributes.ChangeOfPlane EQ 'Yes' ? 1 : 0)#,#(stFlightNode.XMLAttributes.ETicketability EQ 'Yes' ? 1 : 0)#,#stFlightNode.XMLAttributes.Distance#,#stFlightNode.XMLAttributes.FlightTime#,#stFlightNode.XMLAttributes.TravelTime#,#BookingCodeInfo#
						</cfloop>
					</cfprocessingdirective>
				</cfsavecontent>
			</cfif>
		</cfloop>
		
		<cffile action="write" file="\\zeus\c$\booking\Segments_#arguments.Search_ID#_#arguments.Search_Key#.csv" output="#Trim(insertData)#" >
		
		<!---<cfquery>
		BULK INSERT Segments 
	    FROM 'C:\booking\Segments_#arguments.Search_ID#_#arguments.Search_Key#.csv' 
	    WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n' )
		</cfquery>--->
		
		<cflog text="airfare.dbsegments	: #(getTickCount()-timer)# ms" file="airfare.log" type="information">
				
		<cfreturn />
	</cffunction>
	
<!--- airfare : dbfares --->
	<cffunction name="dbfares" returntype="void" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="MasterXML" type="array" required="true">
		<cfargument name="Search_Key" type="numeric" required="true">
		
		<cfset local.timer = getTickCount()>
		<cfset local.insertData = ''>
		
		<cfloop array="#arguments.MasterXML#" index="local.stAirDetailsNode">
			<cfif stAirDetailsNode.XMLName EQ 'air:FareInfoList'>
				<cfsavecontent variable="insertData">
					<cfprocessingdirective suppressWhiteSpace="yes">
						<cfloop array="#stAirDetailsNode.XMLChildren#" index="local.stFareNode">
							#arguments.Search_ID#,#arguments.Search_Key#,#stFareNode.XMLAttributes.key#,#Left(stFareNode.XMLAttributes.Amount, 3)#,#Right(stFareNode.XMLAttributes.Amount, Len(stFareNode.XMLAttributes.Amount)-3)#,#stFareNode.XMLAttributes.Origin#,#DateFormat(stFareNode.XMLAttributes.DepartureDate, 'mm/dd/yyyy')# #TimeFormat(stFareNode.XMLAttributes.DepartureDate, 'HH:mm')#,#stFareNode.XMLAttributes.Destination#,#stFareNode.XMLAttributes.FareBasis#,#DateFormat(stFareNode.XMLAttributes.EffectiveDate, 'mm/dd/yyyy')#,#DateFormat(stFareNode.XMLAttributes.NotValidAfter, 'mm/dd/yyyy')#,#DateFormat(stFareNode.XMLAttributes.NotValidBefore, 'mm/dd/yyyy')#,#stFareNode.XMLAttributes.PassengerTypeCode#,#(stFareNode.XMLAttributes.PrivateFare EQ 'Yes' ? 1 : 0)#,#(stFareNode.XMLAttributes.NegotiatedFare EQ 'Yes' ? 1 : 0)#
						</cfloop>
					</cfprocessingdirective>
				</cfsavecontent>
			</cfif>
		</cfloop>
		
		<cffile action="write" file="\\zeus\c$\booking\Fares_#arguments.Search_ID#_#arguments.Search_Key#.csv" output="#Trim(insertData)#" >
		
		<!---<cfquery>
		BULK INSERT Fares 
	    FROM 'C:\booking\Fares_#arguments.Search_ID#_#arguments.Search_Key#.csv' 
	    WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n' )
		</cfquery>--->
		
		<cflog text="airfare.dbfares 	: #(getTickCount()-timer)# ms" file="airfare.log" type="information">
				
		<cfreturn />
	</cffunction>
	
<!--- airfare : dbtrips --->
	<cffunction name="dbtrips" returntype="void" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="MasterXML" type="array" required="true">
		<cfargument name="Search_Key" type="numeric" required="true">
			
		<cfset local.timer = getTickCount()>
		
		<cfsavecontent variable="local.insertData">
			<cfprocessingdirective suppressWhiteSpace="yes">
				<cfloop array="#arguments.MasterXML#" index="local.stAPSolution">
					<cfif stAPSolution.XMLName EQ 'air:AirPricingSolution'>
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
						<cfsavecontent variable="test" >#arguments.Search_ID#|#arguments.Search_Key#|#Trip_ID#|#Left(BasePrice, 3)#|#Right(BasePrice, Len(BasePrice)-3)#|#Right(Taxes, Len(Taxes)-3)#|#Right(TotalPrice, Len(TotalPrice)-3)#|#Right(ChangePenalty, Len(ChangePenalty)-3)#|#(ETicketability EQ 'Yes' ? 1 : 0)#|#PassengerType#|</cfsavecontent>
						<cffile action="append" file="\\zeus\c$\booking\Trips_#arguments.Search_ID#_#arguments.Search_Key#.csv" output="#test#" >
					</cfif>
				</cfloop>
			</cfprocessingdirective>
		</cfsavecontent>
		
		
		<cfquery>
		BULK INSERT Trips 
	    FROM 'C:\booking\Trips_#arguments.Search_ID#_#arguments.Search_Key#.csv' 
	    WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '|\n' )
		</cfquery>
		
		<cflog text="airfare.dbtrips 	: #(getTickCount()-timer)# ms" file="airfare.log" type="information">
		<cfdump eval=(insertdata) >
			
		
			
		<cfreturn />
	</cffunction>
	
<!--- airfare : dbtripfares --->
	<cffunction name="dbtripfares" returntype="void" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="MasterXML" type="array" required="true">
		<cfargument name="Search_Key" type="numeric" required="true">
		
		<cfset local.timer = getTickCount()>
		
		<cfsavecontent variable="local.insertData">
			<cfprocessingdirective suppressWhiteSpace="yes">
				<cfloop array="#arguments.MasterXML#" index="local.stAPSolution">
					<cfif stAPSolution.XMLName EQ 'air:AirPricingSolution'>
						<cfset local.Trip_ID = stAPSolution.XMLAttributes.key>
						<cfloop array="#stAPSolution.XMLChildren#" index="local.airseg">
							<cfif airseg.XMLName EQ 'air:AirPricingInfo'>
								<cfloop array="#airseg.XMLChildren#" index="local.stFareInfo">
									<cfif stFareInfo.XMLName EQ 'air:FareInfoRef'>
										#arguments.Search_ID#,#arguments.Search_Key#,#Trip_ID#,#stFareInfo.XMLAttributes.Key#
									</cfif>
								</cfloop>
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
			</cfprocessingdirective>
		</cfsavecontent>
		
		<cffile action="write" file="\\zeus\c$\booking\Trip_Fares_#arguments.Search_ID#_#arguments.Search_Key#.csv" output="#insertData#" >
		
		<cfquery>
		BULK INSERT Trip_Fares 
	    FROM 'C:\booking\Trip_Fares_#arguments.Search_ID#_#arguments.Search_Key#.csv' 
	    WITH (FIRSTROW = 3, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n' )
		</cfquery>
		
		<cflog text="airfare.dbtripfares 	: #(getTickCount()-timer)# ms" file="airfare.log" type="information">
		
		<cfreturn />
	</cffunction>
		
<!--- airfare : dbtripsegments --->
	<cffunction name="dbtripsegments" returntype="void" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="MasterXML" type="array" required="true">
		<cfargument name="Search_Key" type="numeric" required="true">
		<cfargument name="Start" type="numeric" default="1">
		<cfargument name="End" type="numeric" default="200">
		
		<cfset local.timer = getTickCount()>
		
		<cfsavecontent variable="local.insertData">
			<cfprocessingdirective suppressWhiteSpace="yes">
				<cfloop array="#arguments.MasterXML#" index="local.stAPSolution">
					<cfif stAPSolution.XMLName EQ 'air:AirPricingSolution'>
						<cfset local.Trip_ID = stAPSolution.XMLAttributes.key>
						<cfloop array="#stAPSolution.XMLChildren#" index="local.stAirSegment">
							<cfif stAirSegment.XMLName EQ 'air:AirSegmentRef'>
								#arguments.Search_ID#,#arguments.Search_Key#,#Trip_ID#,#stAirSegment.XMLAttributes.Key#
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
			</cfprocessingdirective>
		</cfsavecontent>
		
		<cffile action="write" file="\\zeus\c$\booking\Trip_Segments_#arguments.Search_ID#_#arguments.Search_Key#.csv" output="#insertData#" >
		
		<cfquery>
		BULK INSERT Trip_Segments 
	    FROM 'C:\booking\Trip_Segments_#arguments.Search_ID#_#arguments.Search_Key#.csv' 
	    WITH (FIRSTROW = 3, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n' )
		</cfquery>
		
		<cflog text="airfare.dbtripsegments : #(getTickCount()-timer)# ms" file="airfare.log" type="information">
		
		<cfreturn />
	</cffunction>
	
</cfcomponent>