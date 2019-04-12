<cfoutput>
	<div class="panel panel-default trip" 
		data-stops="#Segment.Stops LTE 2 ? Segment.Stops : 2#" 
		data-duration="#Segment.TotalTravelTimeInMinutes#" 
		data-carriercount="#Segment.CarrierCode EQ 'Multi' ? 2 : 1#" 
		data-departure="#dateTimeFormat(createODBCDateTime(Segment.DepartureTime), 'yyyymmddHHnn')#"
		data-arrival="#dateTimeFormat(createODBCDateTime(Segment.ArrivalTime), 'yyyymmddHHnn')#"
		data-economy="#structKeyExists(SegmentFares, 'Economy') ? SegmentFares.Economy.TotalFare : 1000000#"
		data-business="#structKeyExists(SegmentFares, 'Business') ? SegmentFares.Business.TotalFare : 1000000#"
		data-first="#structKeyExists(SegmentFares, 'First') ? SegmentFares.First.TotalFare : 1000000#">
		<cfset cleanedSegmentId = replace(replace(Segment.SegmentId, '-', '', 'ALL'), '.', '', 'ALL')>
	  	<div class="panel-body">
			<div class="row">
				<!---<span class="#ribbonclass#"></span>--->		
				<div class="col-sm-1 center airline-col">
					<div class="row">
						<div class="col-sm-3 col-md-12">
							<cfif Segment.IsPoorSegment>
								<span role="button" class="badge badge-pill warning flight-result-warning" 
									data-placement="right" data-toggle="tooltip" title="Better economy fare and travel times are available">
									<i class="fa fas fa-exclamation" aria-hidden="true"></i>
								</span>
							</cfif>
						</div>
						<div class="col-sm-6 col-md-12">
							<img class="carrierimg" src="assets/img/airlines/#Segment.CarrierCode#.png" title="#application.stAirVendors[Segment.CarrierCode].Name#" width="60">
						</div>
						<div class="col-sm-3 col-md-12">
							<a class="flight-expand-details" data-toggle="collapse" href="##details#cleanedSegmentId#" role="button" aria-expanded="false" aria-controls="details#cleanedSegmentId#">
								<i class="fa fa-caret-down" aria-hidden="true"></i>
							</a>
						</div>
					</div>
				</div>
				<div class="col-sm-3 ">
					<div class="row">
						<div class="col-sm-12 fs-2">
							#timeFormat(Segment.DepartureTime, 'h:mm tt')# - #timeFormat(Segment.ArrivalTime, 'h:mm tt')#
						</div>	
					</div>
					<cfif Segment.Days NEQ 0>
					<div class="row">
						<div class="col-sm-12 fs-1 red">
							+#Segment.Days# day#Segment.Days GT 1 ? 's' : ''#
						</div>	
					</div>
					</cfif>
					<div class="row">
						<div class="col-sm-12 text-muted fs-1">
							#Segment.FlightNumbers#
						</div>	
					</div>
					<div class="row">
						<div class="col-sm-12 text-muted fs-s">
							OPERATED BY #Segment.Codeshare#
						</div>	
					</div>							
				</div>
				<div class="col-sm-1">
					<div class="row">
						<div class="col-sm-12 fs-2">
							#Segment.TravelTime#
						</div>	
					</div>
					<div class="row">
						<div class="col-sm-12 text-muted fs-1">
							#Segment.OriginAirportCode#-#Segment.DestinationAirportCode#
						</div>	
					</div>
				</div>
				<div class="col-sm-1">

					<div class="row">
						<div class="col-sm-12 fs-2">
							<cfif Segment.Stops EQ 0>Nonstop<cfelseif Segment.Stops EQ 1>1 stop<cfelse>#Segment.Stops# stops</cfif>
						</div>	
					</div>
					<div class="row">
						<div class="col-sm-12 fs-1 text-muted">
							#Segment.Connections#
						</div>	
					</div>
				</div>
				<div class="col-sm-6">

					<div class="row fare-wrapper">
						<cfset BrandedFareIds = ''>
						<cfloop list="Economy,Business,First" index="CabinClass">
							<cfif structKeyExists(SegmentFares, CabinClass)>
								<cfloop collection="#SegmentFares[CabinClass]#" index="brandedFareName" item="brandedFare">
									<cfif brandedFareName NEQ 'TotalFare'
										AND brandedFareName NEQ 'SegmentFareId'
										AND brandedFareName NEQ 'SegmentId'>
										<cfset BrandedFareIds = listAppend(BrandedFareIds, brandedFare.brandedFareID)>
										<cfif brandedFare.Bookable>
											<cfset key = hash(Segment.SegmentId&CabinClass&SegmentFares[CabinClass].SegmentFareId&brandedFare.Refundable)>
											<input type="hidden" id="fare#key#" value="#encodeForHTML(serializeJSON(Segment))#">
										</cfif>
										<div class="fares col-sm-3 panel panel-default" data-refundable="#brandedFare.Refundable#"
											<cfif brandedFare.Bookable>
												onclick="submitSegment('#Segment.SegmentId#','#CabinClass#','#SegmentFares[CabinClass].SegmentFareId#','#brandedFare.Refundable#','#key#');"
											</cfif>
										>
											<div class="panel-body">
												<div class="row cabin-class">
													<div class="col-sm-12 fs-1 cabin-class">
														#CabinClass#
													</div>
													<div class="col-sm-12 fs-s">
														<cfif CabinClass NEQ brandedFareName>#brandedFareName#<cfelse>&nbsp;</cfif>
													</div>
													<div class="col-sm-12 fs-2 fare-display">
														<div>$#numberFormat(brandedFare.TotalFare, '_,___')#</div>
													</div>
													<cfif brandedFare.OutOfPolicy>
														<div class="col-sm-12 fs-s policy-error">
															<span role="button" 
																class="badge badge-pill warning fare-warning"
																data-placement="top" 
																data-toggle="tooltip" 
																title="#arrayToList(brandedFare.OutOfPolicyReason)#">
																<i class="fa fas fa-exclamation" aria-hidden="true"></i>
															</span>
														</div>
													</cfif>
												</div>												
											</div>
										</div>
									</cfif>
								</cfloop>

							<cfelse>
								<cfset key = hash(Segment.SegmentId&CabinClass&0)>
								<input type="hidden" id="fare#key#" value="#encodeForHTML(serializeJSON(Segment))#">
								<div class="col-sm-3 panel panel-default"
									onclick="submitSegment('#Segment.SegmentId#','#CabinClass#','','0','#key#');"
								>
									<div class="panel-body">
										<div class="row cabin-class">
											<div class="col-sm-12 fs-1 cabin-class">
												#CabinClass#
											</div>
											<div class="col-sm-12 fs-s">
												&nbsp;
											</div>
											<div class="col-sm-12 fs-2 fare-display">
												&nbsp;
											</div>
										</div>												
									</div>
								</div>
							</cfif>
						</cfloop>
					</div>

				</div>
			</div>
			
			<div class="row">
				<div class="collapse" id="details#cleanedSegmentId#" style="padding-left: 50px;padding-right: 50px;padding-top: 50px;">
					<cfset count = 0>
					<cfloop collection="#Segment.Flights#" index="flightIndex" item="Flight">
						<cfset count++>
						<cfif count NEQ 1>
							<cfset layover = dateDiff('n', previousFlight.ArrivalTime, Flight.DepartureTime)>
							<div class="alert alert-secondary" role="alert" style="width:400px;">
								#int(layover/60)#H #layover%60#M
								in 
								#application.stAirports[previousFlight.DestinationAirportCode].Airport# 
								(#previousFlight.DestinationAirportCode#)<br>
							</div>
						</cfif>

						<h3 class="bold">
							#dateTimeFormat(Flight.DepartureTime, 'h:mm tt - ddd, mmm d')#  #repeatString('&nbsp;', 5)#
							#application.stAirports[Flight.OriginAirportCode].Airport# 
							(#Flight.OriginAirportCode#)<br>
						</h3>

							#repeatString('&nbsp;', 5)#Flight Time:  #Flight.FlightTime#<br>

						<h3 class="bold">
							#dateTimeFormat(Flight.ArrivalTime, 'h:mm tt - ddd, mmm d')#  #repeatString('&nbsp;', 5)#
							#application.stAirports[Flight.DestinationAirportCode].Airport# 
							(#Flight.DestinationAirportCode#)<br>
						</h3>
						
						#application.stAirVendors[Flight.CarrierCode].Name# #repeatString('&nbsp;', 5)#
						#structKeyExists(application.stEquipment, Flight.Equipment) ? application.stEquipment[Flight.Equipment] : Flight.Equipment# #repeatString('&nbsp;', 5)#
						#Flight.CarrierCode##Flight.FlightNumber#<br>

						<cfif structKeyExists(Flight, 'CodeshareInfo')>
							OPERATED BY #Flight.CodeshareInfo.Value#<br>
						</cfif>

						<cfset previousFlight = Flight>
					</cfloop>

					<cfloop list="#BrandedFareIds#" index="BrandedFareId">
						<cfif BrandedFareId NEQ 0>
							<div>
								<hr>
								<span class="bold">#BrandedFares[BrandedFareId].Name#</span> :
								<cfif len(BrandedFares[BrandedFareId].LongDescription) GT 0>
									#BrandedFares[BrandedFareId].LongDescription#<br>
								<cfelse>
									#BrandedFares[BrandedFareId].ShortDescription#<br>
								</cfif>
							</div>
						</cfif>
					</cfloop>

					<div>
						<hr>
						<cfset Carriers = ''>
						<cfloop collection="#Segment.Flights#" index="flightIndex" item="Flight">
							<cfif NOT listFind(Carriers, Flight.CarrierCode)>
								<cfset Carriers = listAppend(Carriers, Flight.CarrierCode)>
								<table class="table table-hover table-condensed">
								<thead>
								<tr>
									<td class="bold">#application.stAirVendors[Flight.CarrierCode].Name#</td>
									<td class="bold">Paid at online check-in</td>
									<td class="bold">Paid at airport check-in</td>
								</tr>
								</thead>
								<tbody>
								<tr>
									<td>1st Checked Bag</td>
									<td>#DollarFormat(application.stAirVendors[Flight.CarrierCode].Bag1)#</td>
									<td>#DollarFormat(application.stAirVendors[Flight.CarrierCode].CheckInBag1)#</td>
								</tr>
								<tr>
									<td>2nd Checked Bag</td>
									<td>#DollarFormat(application.stAirVendors[Flight.CarrierCode].Bag2)#</td>
									<td>#DollarFormat(application.stAirVendors[Flight.CarrierCode].CheckInBag2)#</td>
								</tr>
								<tr>
									<td>Total for 2 Bags (each way)</td>
									<td>#DollarFormat(application.stAirVendors[Flight.CarrierCode].Bag1 + application.stAirVendors[Flight.CarrierCode].Bag2)#</td>
									<td>#DollarFormat(application.stAirVendors[Flight.CarrierCode].CheckInBag1 + application.stAirVendors[Flight.CarrierCode].CheckInBag2)#</td>
								</tr>
								<tr>
									<td>3+ or Oversized Bags</td>
									<td colspan="2">Additional Fees Apply</td>
								</tr>
								</tbody>
								</table>
							</cfif>
						</cfloop>
					</div>

				</div>
			</div>
		</div>
	</div>
</cfoutput>
<!---<cfdump var=#Flight#>--->
