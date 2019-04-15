<cfoutput>
	<div class="panel panel-default trip" 
		data-stops="#Segment.Stops LTE 2 ? Segment.Stops : 2#" 
		data-duration="#Segment.TotalTravelTimeInMinutes#" 
		data-carriercount="#Segment.CarrierCode EQ 'Multi' ? 2 : 1#" 
		data-departure="#dateTimeFormat(createODBCDateTime(Segment.DepartureTime), 'yyyymmddHHnn')#"
		data-arrival="#dateTimeFormat(createODBCDateTime(Segment.ArrivalTime), 'yyyymmddHHnn')#"
		data-economy="#structKeyExists(SegmentFares, 'Economy') ? SegmentFares.Economy.TotalFare : 1000000#"
		data-business="#structKeyExists(SegmentFares, 'Business') ? SegmentFares.Business.TotalFare : 1000000#"
		data-first="#structKeyExists(SegmentFares, 'First') ? SegmentFares.First.TotalFare : 1000000#"
		data-connection="#Segment.Connections#"
		data-airline="#Segment.CarrierCode#"
		>
		<cfset cleanedSegmentId = replace(replace(Segment.SegmentId, '-', '', 'ALL'), '.', '', 'ALL')>
	  	<div class="panel-body">
			<div class="row flight-details-header">
				<!---<span class="#ribbonclass#"></span>--->		
				<div class="col-sm-1 center airline-col">
					<div class="row">
						<div class="col-sm-6 col-md-12">
							<cfif Segment.IsPoorSegment>
								<span role="button" 
									data-placement="right" 
									data-toggle="tooltip" title="Better economy fare and travel times are available"
									class="mdi mdi-alert flight-result-warning"></span>
								<!---span role="button" class="badge badge-pill warning flight-result-warning" 
									data-placement="right" data-toggle="tooltip" title="Better economy fare and travel times are available">
									<i class="fa fas fa-exclamation" aria-hidden="true"></i>
								</span--->
							</cfif>
							<img class="carrierimg" src="assets/img/airlines/#Segment.CarrierCode#.png" title="#application.stAirVendors[Segment.CarrierCode].Name#" width="60">
						</div>
						<div class="col-sm-3 col-md-12">&nbsp;</div>
						<div class="col-sm-3 col-md-12 detail-expander"
							data-toggle="collapse" href="##details#cleanedSegmentId#" role="button" aria-expanded="false" aria-controls="details#cleanedSegmentId#">
							<i class="fa fa-caret-down" aria-hidden="true"></i>(#Segment.Results#)
						</div>
					</div>
				</div>
				<div class="col-sm-5">
					<div class="row results_collapsed">
						<div class="col-sm-6 ">
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
								<div class="col-sm-12 text-muted fs-s overflow-ellipse">
									OPERATED BY #Segment.Codeshare#
								</div>	
							</div>							
						</div>
						<div class="col-sm-3">
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
						<div class="col-sm-3">		
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
					</div>
					<div class="row results_expanded">
						<div class="col-sm-12 fs-2">
							Departing &middot; #dateTimeFormat(createODBCDateTime(Segment.DepartureTime), 'EEE, mmm dd')#
						</div>	
					</div>
				</div>
				
				<div class="col-sm-6">

					<div class="row fare-wrapper">
						<cfset BrandedFareIds = ''>
						<cfloop list="Economy,PremiumEconomy,Business,First" index="CabinClass">
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
													<div class="col-sm-12 fs-1 cabin-description">
														#CabinClass EQ 'PremiumEconomy' ? 'Premium Economy' : CabinClass#
													</div>
													<div class="col-sm-12 fs-s branded-fare-class">
														<cfif CabinClass NEQ brandedFareName>#brandedFareName#<cfelse>&nbsp;</cfif>
													</div>
													<div class="col-sm-12 fs-2 fare-display">
														<div>$#numberFormat(brandedFare.TotalFare, '_,___')#</div>
													</div>
													<cfif brandedFare.OutOfPolicy>
														<div class="col-sm-12 fs-s policy-error">
															<div class="fare-warning"
																role="button"
																data-placement="top" 
																data-toggle="tooltip" 
																title="#arrayToList(brandedFare.OutOfPolicyReason)#">&nbsp;
															</div>
															<!---
															<span  role="button" 
																class="badge badge-pill warning fare-warning"
																data-placement="top" 
																data-toggle="tooltip" 
																title="#arrayToList(brandedFare.OutOfPolicyReason)#">
																<i class="fa fas fa-exclamation" aria-hidden="true"></i>
															</span>
														--->
														</div>
													<cfelse>
														<div class="col-sm-12 fs-s policy-error-hidden"></div>
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
											<div class="col-sm-12 fs-1 cabin-description">
												#CabinClass EQ 'PremiumEconomy' ? 'Premium Economy' : CabinClass#
											</div>
											<div class="col-sm-12 fs-s branded-fare-class">
												&nbsp;
											</div>
											<div class="col-sm-12 fs-2 fare-display">
												<div>&nbsp;</div>
											</div>
											<div class="col-sm-12 fs-s policy-error-hidden">
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
				<div class="col-sm-12 collapse flight-details-container" id="details#cleanedSegmentId#">
					<cfset count = 0>
					<cfloop collection="#Segment.Flights#" index="flightIndex" item="Flight">
						<cfset count++>

						<cfif count NEQ 1>
							<cfset layover = dateDiff('n', previousFlight.ArrivalTime, Flight.DepartureTime)>
							<div class="segment-stopover" data-minutes="#layover#">
								<div class="segment-stopover-row">
									<div>#int(layover/60)#H #layover%60#M layover</div>
									<div class="segment-middot">&middot;</div>
									<div>
										<span>#application.stAirports[previousFlight.DestinationAirportCode].Airport# </span>
										<span>&nbsp;</span>
										<span>(#previousFlight.DestinationAirportCode#)</span></span>
									</div>
								</div>
							</div>
						</cfif>		

						<div class="segment-details">
							<div class="segment-details-flights">
								
		
								<div class="segment-leg">
									<div class="segment-leg-inner">
										<div class="segment-leg-connector"></div>
										<div class="segment-leg-details fs-s1">
											<div class="segment-leg-time"><span>#dateTimeFormat(Flight.DepartureTime, 'h:mm tt - ddd, mmm d')#</span></span></div>
											<div class="segment-middot">&middot;</div>
											<div class="segment-leg-airport">
												<span>#application.stAirports[Flight.OriginAirportCode].Airport#</span>
												<span>&nbsp;</span>
												<span>(#Flight.OriginAirportCode#)</span>
											</div>
										</div>
										<div class="segment-leg-time-inair fs-1">
											<div>Flight time:&nbsp;<span>#Flight.FlightTime#</span></div>
										</div>
										<div class="segment-leg-details segment-leg-arrival fs-s1">
											<div class="segment-leg-time"><span>#dateTimeFormat(Flight.ArrivalTime, 'h:mm tt - ddd, mmm d')#</span></span></div>
											<div class="segment-middot">&middot;</div>
											<div class="segment-leg-airport">
												<span>#application.stAirports[Flight.DestinationAirportCode].Airport#</span>
												<span>&nbsp;</span>
												<span>(#Flight.DestinationAirportCode#)</span>
											</div>
										</div>
									</div>
									<div class="segment-leg-operation-details fs-1">
										<div class="segment-leg-operation-vendor">#application.stAirVendors[Flight.CarrierCode].Name#</div>
										<span class="segment-middot-sm">&middot;</span>
										<div class="segment-leg-operation-equipment">
											<div><span>#structKeyExists(application.stEquipment, Flight.Equipment) ? application.stEquipment[Flight.Equipment] : Flight.Equipment#</span></div>
											<!--div>Basic Economy</div-->
										</div>
										<div class="segment-leg-operation-codes">
											<span class="segment-middot-sm">&middot;</span>
											<!--div><span>Embraer RJ-175</span><span></span></div-->
											<span><span>#Flight.CarrierCode#</span>&nbsp;<span>#Flight.FlightNumber#</span></span>
										</div>
									</div>
									<div class="segment-leg-operation-operatedby fs-s overflow-ellipse">
										<cfif structKeyExists(Flight, 'CodeshareInfo')>
											OPERATED BY #Flight.CodeshareInfo.Value#
										</cfif>
									</div>
								</div>
								#count == 0 ? active : ''#

							</div>
							<div class="segment-details-extras">
								<!--- TODO Hide for now? --->
								<ul>
									<li><span></span> <span> Carry-on bags restricted </span>
									</li>
									<li> Average legroom (31 in)</li>
									<li> Wi-Fi</li>
									<li> In-seat power outlet</li>
									<li> Stream media to your device</li>
								</ul>
							</div>
						</div>
						<cfset previousFlight = Flight>
					</cfloop>
					<div class="segment-details-footer">
						<div>
							<cfif len(BrandedFareIds) GT 0>
								<cfset paneldetails = "">
								<ul class="nav nav-tabs" role="tablist">
								<cfset count = 0>
								<cfloop list="#BrandedFareIds#" index="BrandedFareId">
									<cfif BrandedFareId NEQ 0>
										<cfset cabinuuid = "f#createUUID()#">
										<li role="presentation" class="#count == 0 ? 'active' : ''#">
											<a href="###cabinuuid#" aria-controls="#cabinuuid#" role="tab" data-toggle="tab">#BrandedFares[BrandedFareId].Name#</a>
										</li>
										<cfsavecontent variable="subdetail"><div role="tabpanel" class="tab-pane #count == 0 ? 'active' : ''#" id="#cabinuuid#">
											<cfif len(BrandedFares[BrandedFareId].LongDescription) GT 0>
												<cfset fareString = BrandedFares[BrandedFareId].LongDescription.split("•")>
												<ul><cfloop array="#fareString#" index="line" ><li>#line#</li></cfloop></ul>
											<cfelse>
												#BrandedFares[BrandedFareId].ShortDescription#
											</cfif>
										</div></cfsavecontent>
										<cfset paneldetails = "#paneldetails##subdetail#">
										<cfset count++>
									</cfif>
								</cfloop>
								</ul>
								<div class="tab-content branded-cabin-details">#paneldetails#</div>
							</cfif>
					  	  </div>
						  <div>
							<h3>Baggage Fees</h3>
							<cfset Carriers = ''>
							<cfloop collection="#Segment.Flights#" index="flightIndex" item="Flight">
								<cfif NOT listFind(Carriers, Flight.CarrierCode)>
									<cfset Carriers = listAppend(Carriers, Flight.CarrierCode)>
								<table class="table table-hover table-condensed baggage-fees">
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
	</div>
</cfoutput>
<!---<cfdump var=#Flight#>--->
