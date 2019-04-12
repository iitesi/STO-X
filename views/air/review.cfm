<cfoutput>
	<!--- #view('air/unusedtickets')# --->
	<div class="page-header">
		#View('air/legs')#
	</div>
	<div id="aircontent">
		<div class="list-view container" id="listcontainer">
			<div class="panel panel-default" >
				<div class="panel-body">
					<div class="row">
						<div class="container">
							<div class="row">
								<cfloop collection="#session.Searches[rc.SearchID].stSelected#" index="Group" item="Segment">
									<cfif structKeyExists(Segment, 'Flights')>
										<cfloop collection="#Segment.Flights#" index="FlightIndex" item="Flight">
											<!---<span class="#ribbonclass#"></span>--->
											<div class="col-sm-1 center">
												<img class="carrierimg" src="assets/img/airlines/#Flight.CarrierCode#.png" title="#application.stAirVendors[Flight.CarrierCode].Name#" width="60">
											</div>
											<div class="col-sm-5">
												<div class="row">
													<div class="col-sm-5">
														<span class="bold">#timeFormat(Flight.DepartureTime, 'h:mm tt')# - #timeFormat(Flight.ArrivalTime, 'h:mm tt')#</span>
														<!--- <cfif Segment.Days NEQ 0>
															<small class="red">+#Segment.Days# day#Segment.Days GT 1 ? 's' : ''#</small>
														</cfif>--->
													</div>
													<div class="col-sm-3 bold">
														<!--- #Segment.TravelTime# --->
													</div>
													<div class="col-sm-2 bold">
														<!--- <cfif Segment.Stops EQ 0>Nonstop<cfelseif Segment.Stops EQ 1>1 stop<cfelse>#Segment.Stops# stops</cfif> --->
													</div>
												</div>
												<div class="row">
													<div class="col-sm-5">
														<small>#Flight.FlightNumber#</small>
													</div>
													<div class="col-sm-3">
														<small>#Flight.OriginAirportCode#-#Flight.DestinationAirportCode#</small>
													</div>
													<div class="col-sm-4">
														<!--- <small>#Segment.Connections#</small> --->
													</div>
												</div>
											</div>
										</cfloop>
									</cfif>
								</cfloop>
								<!--- <div class="col-sm-6">
									<div class="container container-fluid">
										<div class="row">
											<cfset brandedFareIds = ''>
											<cfloop list="Economy,Business,First" index="CabinClass">
												<cfif structKeyExists(SegmentFares, CabinClass)>
													<cfloop collection="#SegmentFares[CabinClass]#" index="brandedFareName" item="brandedFare">
														<cfif brandedFareName NEQ 'TotalFare'
															AND brandedFareName NEQ 'SegmentFareId'
															AND brandedFareName NEQ 'SegmentId'>
															<cfif structKeyExists(brandedFare, 'BrandedFareId')>
																<cfset brandedFareIds = listAppend(brandedFareIds, brandedFare.BrandedFareId)>
															</cfif>
															<div data-refundable="#brandedFare.Refundable#" style="display:inline;float:left;min-width:125px;text-align:center;" class="fares">
																<span class="bold">$#numberFormat(brandedFare.TotalFare, '_,___')#</span>
																<cfif brandedFare.OutOfPolicy>
																	<i class="material-icons" data-toggle="tooltip" title="#arrayToList(brandedFare.OutOfPolicyReason)#" style="font-size:16px;color:##E3132C;">priority_high</i>
																</cfif>
																<br>
																<small>#CabinClass#</small><br>
																<cfif CabinClass NEQ brandedFareName><small>#brandedFareName#</small></cfif><br>
																<cfif brandedFare.Bookable>
																<!--- Dohmen To Do : Encode properly.  There has to be a better way!!  Just ran out of time. --->
																<cfset Flights = []>
																<cfloop collection="#Segment.Flights#" index="flightIndex" item="Flight">
																	<cfset Leg = {	ArrivalTime:#Flight.ArrivalTime#,
																					BookingCode:#Flight.BookingCode#,
																					CabinClass:#Flight.CabinClass#,
																					CarrierCode:#Flight.CarrierCode#,
																					DepartureTime:#Flight.DepartureTime#,
																					DestinationAirportCode:#Flight.DestinationAirportCode#,
																					FlightNumber:#Flight.FlightNumber#,
																					OriginAirportCode:#Flight.OriginAirportCode#
																				}>
																	<cfset ArrayAppend(Flights, Leg)>
																</cfloop>
																	<button type="button" class="btn btn-sm" onclick="submitSegment('#Segment.SegmentId#','#CabinClass#','#SegmentFares[CabinClass].SegmentFareId#','#replace(serializeJSON(Flights), '"', '$', 'ALL')#');">Select</button>
																</cfif>
																<!---<h6>#SegmentFares[CabinClass].SegmentFareId#</h6><br>--->
															</div>
														</cfif>
													</cfloop>

												<cfelse>
													<div style="display:inline;float:left;min-width:125px;text-align:center;">
														<br>
														<small>#CabinClass#</small><br>
														<br>
														<!--- Dohmen To Do : Encode properly.  There has to be a better way!!  Just ran out of time. --->
														<cfset Flights = []>
														<cfloop collection="#Segment.Flights#" index="flightIndex" item="Flight">
															<cfset Leg = {	ArrivalTime:#Flight.ArrivalTime#,
																			CabinClass:#Flight.CabinClass#,
																			CarrierCode:#Flight.CarrierCode#,
																			DepartureTime:#Flight.DepartureTime#,
																			DestinationAirportCode:#Flight.DestinationAirportCode#,
																			FlightNumber:#Flight.FlightNumber#,
																			OriginAirportCode:#Flight.OriginAirportCode#
																		}>
															<cfset ArrayAppend(Flights, Leg)>
														</cfloop>
														<button type="button" class="btn btn btn-sm" onclick="submitSegment('#Segment.SegmentId#','#CabinClass#','','#replace(serializeJSON(Flights), '"', '$', 'ALL')#');">Select</button>
													</div>
												</cfif>
											</cfloop>
										</div>
									</div>
								</div>--->
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</cfoutput>

<cfdump var=#session.Searches[rc.SearchID].stSelected#>