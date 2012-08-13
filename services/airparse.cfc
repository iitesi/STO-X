<cfcomponent>

<!--- airparse : formatXML --->
	<cffunction name="formatXML" returntype="array" output="false">
		<cfargument name="MasterXML" type="string" required="true">
		
		<cfset local.masterAirXML = XMLParse(arguments.MasterXML)>
		<cfset masterAirXML = masterAirXML.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren>
		
		<cfreturn masterAirXML />
	</cffunction>

<!--- airparse : searchkey --->
	<cffunction name="searchkey" returntype="numeric" output="false">
		
		<cfreturn RandRange(1,10000) />
	</cffunction>
	
<!--- airparse : dbsegments --->
	<cffunction name="dbsegments" returntype="struct" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="MasterXML" type="array" required="true">
		<cfargument name="Search_Key" type="numeric" required="true">
		
		<cfset local.timer = getTickCount()>
		
		<cfset local.strAirSegments = {}>
		
		<cftry>
		<cfloop array="#arguments.MasterXML#" index="local.stAirDetailsNode">
			<cfif stAirDetailsNode.XMLName EQ 'air:AirSegmentList'>
				<cfquery name="insertSegments">
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
						#arguments.Search_ID#,
						#arguments.Search_Key#,
						'#stFlightNode.XMLAttributes.Key#',
						'#stFlightNode.XMLAttributes.Carrier#',
						'#OperatingCarrier#',
						#stFlightNode.XMLAttributes.FlightNumber#,
						'#stFlightNode.XMLAttributes.Origin#',
						#CreateODBCDateTime(stFlightNode.XMLAttributes.DepartureTime)#,
						'#stFlightNode.XMLAttributes.Destination#',
						#CreateODBCDateTime(stFlightNode.XMLAttributes.ArrivalTime)#,
						#stFlightNode.XMLAttributes.Group#,
						'#(StructKeyExists(stFlightNode.XMLAttributes, 'ClassOfService') ? stFlightNode.XMLAttributes.ClassOfService : '')#',
						'#stFlightNode.XMLAttributes.Equipment#',
						#(stFlightNode.XMLAttributes.ChangeOfPlane EQ 'Yes' ? 1 : 0)#,
						#(stFlightNode.XMLAttributes.ETicketability EQ 'Yes' ? 1 : 0)#,
						'#(StructKeyExists(stFlightNode.XMLAttributes, 'Distance') ? stFlightNode.XMLAttributes.Distance : '')#',
						#stFlightNode.XMLAttributes.FlightTime#,
						#stFlightNode.XMLAttributes.TravelTime#,
						'#BookingCodeInfo#'
						UNION ALL
						<cfset strAirSegments[stFlightNode.XMLAttributes.key] = stFlightNode.XMLAttributes.Carrier&stFlightNode.XMLAttributes.FlightNumber>
					</cfloop>
				</cfsavecontent>
				#Left(Trim(insertData), Len(Trim(insertData)) - 10)#
				</cfquery>
			</cfif>
		</cfloop>
		<cfcatch>
			<cfdump eval=arguments.MasterXML abort>
		</cfcatch>
		</cftry>
		
		<cflog text="airparse.dbsegments 		: #(getTickCount()-timer)# ms" file="airparse.log" type="information">

		<cfreturn strAirSegments/>
	</cffunction>
	
<!--- airparse : dbfares --->
	<cffunction name="dbfares" returntype="void" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="MasterXML" type="array" required="true">
		<cfargument name="Search_Key" type="numeric" required="true">
		
		<cfset local.timer = getTickCount()>
		
		<cfloop array="#arguments.MasterXML#" index="local.stAirDetailsNode">
			<cfif stAirDetailsNode.XMLName EQ 'air:FareInfoList'>
				<cfquery name="insertFares">
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
						#arguments.Search_ID#,
						#arguments.Search_Key#,
						'#stFareNode.XMLAttributes.key#',
						'#Left(stFareNode.XMLAttributes.Amount, 3)#',
						#Right(stFareNode.XMLAttributes.Amount, Len(stFareNode.XMLAttributes.Amount)-3)#,
						'#stFareNode.XMLAttributes.Origin#',
						#CreateODBCDateTime(stFareNode.XMLAttributes.DepartureDate)#,
						'#stFareNode.XMLAttributes.Destination#',
						'#stFareNode.XMLAttributes.FareBasis#',
						#CreateODBCDateTime(stFareNode.XMLAttributes.EffectiveDate)#,
						#(StructKeyExists(stFareNode.XMLAttributes, 'NotValidAfter') ? CreateODBCDateTime(stFareNode.XMLAttributes.NotValidAfter) : '''''')#,
						#(StructKeyExists(stFareNode.XMLAttributes, 'NotValidBefore') ? CreateODBCDateTime(stFareNode.XMLAttributes.NotValidBefore) : '''''')#,
						'#stFareNode.XMLAttributes.PassengerTypeCode#',
						#(stFareNode.XMLAttributes.PrivateFare EQ 'Yes' ? 1 : 0)#,
						#(stFareNode.XMLAttributes.NegotiatedFare EQ 'Yes' ? 1 : 0)#
						UNION ALL
					</cfloop>
				</cfsavecontent>
				#Left(Trim(insertData), Len(Trim(insertData)) - 10)#
				</cfquery>
			</cfif>
		</cfloop>
		
		<cflog text="airparse.dbfares 		: #(getTickCount()-timer)# ms" file="airparse.log" type="information">

		<cfreturn />
	</cffunction>
	
<!--- airparse : dbtrips --->
	<cffunction name="dbtrips" returntype="void" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="MasterXML" type="array" required="true">
		<cfargument name="Search_Key" type="numeric" required="true">
		<cfargument name="strAirSegments" type="struct" required="true">
			
		<cfset local.timer = getTickCount()>
		
		<cftry>
			<cfquery name="insertTrips">
			INSERT INTO Trips
			(Search_ID,
			Search_Key,
			Trip_ID,
			Token,
			Currency,
			BasePrice,
			Taxes,
			TotalPrice,
			ChangePenalty,
			ETicketability,
			PassengerType)
			<cfsavecontent variable="local.insertData">
				<cfloop array="#arguments.MasterXML#" index="local.stAPSolution">
					<cfset local.token = StructNew()>
					<cfif stAPSolution.XMLName EQ 'air:AirPricingSolution'>
						<cfset local.Trip_ID = stAPSolution.XMLAttributes.key>
						<cfset local.ETicketability = 'Yes'>
						<cfset local.BasePrice = 'USD0'>
						<cfset local.TotalPrice = 'USD0'>
						<cfset local.Taxes = 'USD0'>
						<cfset local.PassengerType = 'ADT'>
						<cfset local.ChangePenalty = 'USD0'>
						<cfloop array="#stAPSolution.XMLChildren#" index="local.stAirSegment">
							<cfif stAirSegment.XMLName EQ 'air:AirSegmentRef'>
								<cfset token[strAirSegments[stAirSegment.XMLAttributes.Key]] = ''>
							<cfelseif stAirSegment.XMLName EQ 'air:AirPricingInfo'>
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
						#arguments.Search_ID#,
						#arguments.Search_Key#,
						'#Trip_ID#',
						'#Replace(StructKeyList(token), ',', '', 'ALL')#',
						'#Left(BasePrice, 3)#',
						#Right(BasePrice, Len(BasePrice)-3)#,
						#Right(Taxes, Len(Taxes)-3)#,
						#Right(TotalPrice, Len(TotalPrice)-3)#,
						#Right(ChangePenalty, Len(ChangePenalty)-3)#,
						#(ETicketability EQ 'Yes' ? 1 : 0)#,
						'#PassengerType#'
						UNION ALL
					</cfif>
				</cfloop>
			</cfsavecontent>
			#Left(Trim(insertData), Len(Trim(insertData)) - 10)#
			</cfquery>
		<cfcatch>
			<cfdump eval=arguments.MasterXML abort>
		</cfcatch>
		</cftry>
		
		<cflog text="airparse.dbtrips 		: #(getTickCount()-timer)# ms" file="airparse.log" type="information">
				
		<cfreturn />
	</cffunction>
	
<!--- airfare : dbtripsshell --->
	<cffunction name="dbtripsshell" returntype="void" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="MasterXML" type="array" required="true">
		<cfargument name="Search_Key" type="numeric" required="true">
		<cfargument name="strAirSegments" type="struct" required="true">
			
		<cfset local.timer = getTickCount()>
		
		<cfloop array="#arguments.MasterXML#" index="local.stAirDetailsNode">
			<cfif stAirDetailsNode.XMLName EQ 'air:AirSegmentList'>
				<cfquery name="insertShellTrips">
				INSERT INTO Trips
				(Search_ID,
				Search_Key,
				Trip_ID,
				Token)
				<cfsavecontent variable="local.insertData">
					<cfloop array="#stAirDetailsNode.XMLChildren#" index="local.stFlightNode">
						SELECT
						#arguments.Search_ID#,
						#arguments.Search_Key#,
						'#stFlightNode.XMLAttributes.Key#',
						'#arguments.strAirSegments[stFlightNode.XMLAttributes.key]#'
						UNION ALL
					</cfloop>
				</cfsavecontent>
				#Left(Trim(insertData), Len(Trim(insertData)) - 10)#
				</cfquery>
			</cfif>
		</cfloop>
		
		<cflog text="airfare.dbtripsshell 		: #(getTickCount()-timer)# ms" file="airfare.log" type="information">
				
		<cfreturn />
	</cffunction>
		
<!--- airparse : dbtripfares --->
	<cffunction name="dbtripfares" returntype="void" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="MasterXML" type="array" required="true">
		<cfargument name="Search_Key" type="numeric" required="true">
		
		<cfset local.timer = getTickCount()>
		
		<cfquery name="insertTripFares">
		INSERT INTO Trip_Fares
		(Search_ID,
		Search_Key,
		Trip_ID,
		Fare_ID)
		<cfsavecontent variable="local.insertData">
			<cfloop array="#arguments.MasterXML#" index="local.stAPSolution">
				<cfif stAPSolution.XMLName EQ 'air:AirPricingSolution'>
					<cfset local.Trip_ID = stAPSolution.XMLAttributes.key>
					<cfloop array="#stAPSolution.XMLChildren#" index="local.airseg">
						<cfif airseg.XMLName EQ 'air:AirPricingInfo'>
							<cfloop array="#airseg.XMLChildren#" index="local.stFareInfo">
								<cfif stFareInfo.XMLName EQ 'air:FareInfoRef'>
									SELECT 
									#arguments.Search_ID#,
									#arguments.Search_Key#,
									'#Trip_ID#',
									'#stFareInfo.XMLAttributes.Key#'
									UNION ALL
								</cfif>
							</cfloop>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
		</cfsavecontent>
		#Left(Trim(insertData), Len(Trim(insertData)) - 10)#
		</cfquery>
		
		<cflog text="airparse.dbtripfares 		: #(getTickCount()-timer)# ms" file="airparse.log" type="information">
		
		<cfreturn />
	</cffunction>
		
<!--- airparse : dbtripsegments --->
	<cffunction name="dbtripsegments" returntype="void" output="false">
		<cfargument name="Search_ID" type="numeric" required="true">
		<cfargument name="MasterXML" type="array" required="true">
		<cfargument name="Search_Key" type="numeric" required="true">
		<cfargument name="Start" type="numeric" default="0">
		<cfargument name="End" type="numeric" default="600">
		
		<cfset local.timer = getTickCount()>
		<cfset local.cnt = 0>
		<cfset local.max = 0>
		<cfset local.increments = 600>
		
		<cfquery name="insertTripSegments">
		INSERT INTO Trip_Segments
		(Search_ID,
		Search_Key,
		Trip_ID,
		Segment_ID,
		CabinClass,
		SegmentNum)
		<cfsavecontent variable="local.insertData">
			<cfloop array="#arguments.MasterXML#" index="local.stAPSolution">
				<cfset local.SegmentNum = 0>
				<cfif stAPSolution.XMLName EQ 'air:AirPricingSolution'>
					<cfset local.Trip_ID = stAPSolution.XMLAttributes.key>
					<cfloop array="#stAPSolution.XMLChildren#" index="local.stAirSegment">
						<cfif stAirSegment.XMLName EQ 'air:AirSegmentRef'>
							<cfset cnt++>
							<cfset local.SegmentNum = SegmentNum + 1>
							<cfif cnt GTE arguments.Start AND cnt LTE arguments.End>
								<cfset local.CabinClass = ''> 
								<cfloop array="#stAPSolution.XMLChildren#" index="local.strAirPricingInfo">
									<cfif strAirPricingInfo.XMLName EQ 'air:AirPricingInfo'>
										<cfloop array="#strAirPricingInfo.XMLChildren#" index="local.strBookingInfo">
											<cfif strBookingInfo.XMLName EQ 'air:BookingInfo'>
												<cfif stAirSegment.XMLAttributes.Key EQ strBookingInfo.XMLAttributes.SegmentRef>
													<cfset local.CabinClass = (StructKeyExists(strBookingInfo.XMLAttributes, 'CabinClass') ? strBookingInfo.XMLAttributes.CabinClass : 'Economy')>
												</cfif>
											</cfif>
										</cfloop>
									</cfif>
								</cfloop>
								<cfset local.max = cnt>
								SELECT 
								#arguments.Search_ID#,
								#arguments.Search_Key#,
								'#Trip_ID#',
								'#stAirSegment.XMLAttributes.Key#',
								'#local.CabinClass#',
								#SegmentNum#
								UNION ALL
								<cfif max EQ arguments.End>
									<cfbreak>
								</cfif>
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
		</cfsavecontent>
		#Left(Trim(insertData), Len(Trim(insertData)) - 10)#
		</cfquery>
		
		<cflog text="airparse.dbtripsegments 	: #(getTickCount()-timer)# ms" file="airparse.log" type="information">
		
		<cfif max EQ arguments.End>
			<cfset blah = dbtripsegments(arguments.Search_ID, arguments.MasterXML, arguments.Search_Key, arguments.End, arguments.End+increments)>
		</cfif>
		
		<cfreturn />
	</cffunction>
	
</cfcomponent>