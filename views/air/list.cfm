<!--- <cfdump var=#session.Filters[rc.SearchID].getUserID()# abort> --->
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
				<div class="col-xs-2 col-lg-1 center airline-col">
					<div class="row">
						<div class="col-xs-12">
							<img class="carrierimg" src="assets/img/airlines/#Segment.CarrierCode#.png" title="#application.stAirVendors[Segment.CarrierCode].Name#" width="60">
						
							<div class="warning-icons">
								<cfif Segment.IsLongAndExpensive>
									<span role="button" 
										data-placement="right" 
										data-toggle="tooltip" title="Better economy fare and shorter travel times available."
										class="mdi mdi-cash-multiple flight-result-warning"></span>
								</cfif>
								<cfif Segment.IsLongSegment>
									<span role="button" 
										data-placement="right" 
										data-toggle="tooltip" title="Segment is more than twice as long as the shortest travel time available."
										class="mdi mdi-timer-sand long-flight-alert"></span>
								</cfif>
								<cfif structKeyExists(session.Filters[rc.SearchId].getUnusedTicketCarriers(), Segment.CarrierCode)>
									<!--- Shane Pitts - Notification for unused tickets UI. --->
									<span role="button" 
										data-placement="right" 
										data-toggle="tooltip" title="Unused tickets exist for this carrier."
										class="mdi mdi-ticket-account unused-ticket-alert"></span>
								</cfif>
							</div>
							
						</div>
						<div class="col-xs-12 hidden-xs visible-lg-block">&nbsp;</div>
						<div class="col-xs-12 detail-expander hidden-xs visible-lg-block"
							data-toggle="collapse" href="##details#cleanedSegmentId#" role="button" aria-expanded="false" aria-controls="details#cleanedSegmentId#">
							<i class="fa fa-caret-down" aria-hidden="true"></i>
						</div>
					</div>
				</div>
				<div class="col-xs-10 col-lg-5 results-info-wrapper">
					<div class="row results_collapsed">
						<div class="col-xs-12 col-md-6 ">
							<div class="row">
								<div class="col-xs-12 fs-2 fs-xs-2">
									#timeFormat(Segment.DepartureTime, 'h:mm tt')# - #timeFormat(Segment.ArrivalTime, 'h:mm tt')#
								</div>	
							</div>
							<cfif Segment.Days NEQ 0>
							<div class="row">
								<div class="col-xs-12 fs-1 red">
									+#Segment.Days# day#Segment.Days GT 1 ? 's' : ''#
								</div>	
							</div>
							</cfif>
							<div class="row">
								<div class="col-xs-12 text-muted fs-1">
									#Segment.FlightNumbers#
								</div>	
							</div>
							<div class="row">
								<div class="col-xs-12 text-muted fs-xs-s fs-s overflow-ellipse">
									<cfif Segment.Codeshare NEQ ''>
										OPERATED BY #Segment.Codeshare#
									</cfif>
								</div>	
							</div>							
						</div>
						<div class="clearfix visible-xs-block"></div>
						<div class="col-xs-6 col-md-3">
							<div class="row">
								<div class="col-xs-6 col-lg-12 fs-xs-1 fs-lg-2 p-xs-0 pl-xs-15">
									#Segment.TravelTime#
								</div>	
								<div class="col-xs-6 col-lg-12 text-muted fs-1 p-xs-0 pl-xs-15">
									#Segment.OriginAirportCode#-#Segment.DestinationAirportCode#
								</div>	
							</div>
						</div>
						<div class="col-xs-6 col-md-3">		
							<div class="row">
								<div class="col-xs-6 col-lg-12 fs-xs-1 fs-lg-2 p-xs-0 pl-xs-15">
									<cfif Segment.Stops EQ 0>Nonstop<cfelseif Segment.Stops EQ 1>1 stop<cfelse>#Segment.Stops# stops</cfif>
									<cfif Segment.Results NEQ 'Both'>#Segment.Results#</cfif>
								</div>	
								<div class="col-xs-6 col-lg-12 fs-1 text-muted p-xs-0 pr-xs-15">
									#Segment.Connections#
								</div>	
							</div>
						</div>
					</div>
					<div class="row results_expanded">
						<div class="col-xs-12 fs-2">
							Departing &middot; #dateTimeFormat(createODBCDateTime(Segment.DepartureTime), 'EEE, mmm dd')#
						</div>	
					</div>
				</div>

				<div class="clearfix visible-xs-block"></div>
				<div class="col-xs-12 col-lg-6">

					<div class="row fare-wrapper">
						<cfset BrandedFareIds = ''>
						<cfloop list="Economy,PremiumEconomy,Business,First" index="CabinClass">
							<cfif structKeyExists(SegmentFares, CabinClass)>
								<!--- <cfdump var=#SegmentFares[CabinClass]# abort> --->
								<cfloop collection="#SegmentFares[CabinClass]#" index="brandedFareName" item="brandedFare">
									<cfif brandedFareName NEQ 'TotalFare'
										AND brandedFareName NEQ 'SegmentFareId'
										AND brandedFareName NEQ 'SegmentId'>
										<!--- <cfdump var=#brandedFare# abort> --->
										<cfset BrandedFareIds = listAppend(BrandedFareIds, brandedFare.brandedFareID)>
										<cfif brandedFare.Bookable>
											<cfset key = hash(Segment.SegmentId&CabinClass&SegmentFares[CabinClass].SegmentFareId&brandedFare.Refundable)>
											<input type="hidden" id="segment#key#" value="#encodeForHTML(serializeJSON(Segment))#">
											<input type="hidden" id="fare#key#" value="#encodeForHTML(serializeJSON(brandedFare))#">
										</cfif>
										<div class="fares fare-block" data-refundable="#brandedFare.Refundable#"
											<cfif brandedFare.Bookable>
												onclick="submitSegment('#Segment.SegmentId#','#CabinClass#','#SegmentFares[CabinClass].SegmentFareId#','#brandedFare.Refundable#','#key#');"
											</cfif>
										>
											<div class="cabin-class">
												<div class="fs-1 cabin-description overflow-ellipse">
													<cfif brandedFareName NEQ ''>#brandedFareName#<cfelse>#CabinClass EQ 'PremiumEconomy' ? 'Premium Economy' : CabinClass#</cfif>
												</div>
												<div class="fs-2 fare-display">
													<div class="overflow-ellipse">$#numberFormat(brandedFare.TotalFare, '_,___')#</div>
												</div>
												<cfif brandedFare.OutOfPolicy>
													<div class="col-xs-12 fs-s policy-error">
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
													<div class="fs-s policy-error-hidden"></div>
												</cfif>
											</div>												
										</div>
									</cfif>
								</cfloop>
							<cfelseif structKeyExists(Segment, 'Availability')
								AND structKeyExists(Segment.Availability, CabinClass)>

								<cfset key = hash(Segment.SegmentId&CabinClass&0)>
								<input type="hidden" id="segment#key#" value="#encodeForHTML(serializeJSON(Segment))#">
								<input type="hidden" id="fare#key#" value="">
								<div class="nopprice-fares fare-block"
									onclick="submitSegment('#Segment.SegmentId#','#CabinClass#','','0','#key#');"
								>
									<div class="cabin-class">
										<div class="fs-1 cabin-description overflow-ellipse">
											#CabinClass EQ 'PremiumEconomy' ? 'Premium Economy' : CabinClass#
										</div>
										<div class="fs-2 fare-display">
											<div class="overflow-ellipse fs-s">
												<cfif structKeyExists(Segment.Availability, CabinClass)
												AND Segment.Availability[CabinClass].Available>
												Click to price
											<cfelseif structKeyExists(Segment.Availability, CabinClass)
												AND NOT Segment.Availability[CabinClass].Available>
												Unavailable
											</cfif>
											</div>
										</div>
										<div class="fs-s policy-error-hidden">
											&nbsp;
										</div>
									</div>												
								</div>
							<cfelse>
								<div class="spacer fare-block">
									&nbsp;
								</div>
							</cfif>
						</cfloop>
					</div>

				</div>
			</div>
				
			<div class="row hidden-xs visible-md-block visible-lg-block">
				<div class="col-xs-12 collapse flight-details-container" id="details#cleanedSegmentId#">
					<!--- <cfdump var=#Segment# abort> --->
					<!--- Shane - New code, please fix :) --->
					<!--- <cfset key = hash(Segment.SegmentId)>
					<input type="hidden" id="fare#key#" value="#encodeForHTML(serializeJSON(Segment))#">
					<div class="col-xs-3 panel panel-default" onclick="sendEmail('#key#');" >
						Send Email
					</div>
					<br> --->

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
											<div class="segment-leg-time"><span>#timeFormat(Flight.DepartureTime, 'h:mm tt')# - #dateFormat(Flight.DepartureTime, 'ddd, mmm d')#</span></span></div>
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
											<div class="segment-leg-time"><span>#timeFormat(Flight.ArrivalTime, 'h:mm tt')# - #dateFormat(Flight.ArrivalTime, 'ddd, mmm d')#</span></span></div>
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
									<!--- <div class="segment-leg-operation-operatedby fs-s overflow-ellipse">
										<cfif structKeyExists(Flight, 'CodeshareInfo')>
											OPERATED BY #Flight.CodeshareInfo.Value#
										</cfif>
									</div> --->
								</div>
								#count == 0 ? active : ''#
								<!--- <cfif Segment.SegmentId EQ 'G0-DL.2544-DL.2342'>
									<cfdump var=#Segment# abort>
								</cfif>
								#Segment.SegmentId# --->
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
							<cfif len(BrandedFareIds) GT 0
								OR structKeyExists(Segment, 'Availability')>
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
								<cfif structKeyExists(Segment, 'Availability')>
									<cfset cabinuuid = "f#createUUID()#">
									<li role="presentation" class="#count == 0 ? 'active' : ''#">
										<a href="###cabinuuid#" aria-controls="#cabinuuid#" role="tab" data-toggle="tab">Availability</a>
									</li>
									<cfsavecontent variable="subdetail"><div role="tabpanel" class="tab-pane #count == 0 ? 'active' : ''#" id="#cabinuuid#">
										<cfloop collection="#Segment.Availability#" index="CabinName" item="CabinItem">
											<cfloop collection="#CabinItem#" index="FlightNumber" item="FlightItem">

												<cfif FlightNumber NEQ 'Available'>
													<strong>#CabinName NEQ 'PremiumEconomy' ? CabinName : 'Premium Economy'# on #Replace(FlightNumber, '.', '')#</strong> - #FlightItem.String#<br><br>
												</cfif>

											</cfloop>
										</cfloop>
									</div></cfsavecontent>
									<cfset paneldetails = "#paneldetails##subdetail#">
								</cfif>
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
