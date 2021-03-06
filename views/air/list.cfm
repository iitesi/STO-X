<cfparam name="Segment.IsFindItMatch" default="false"/>
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
		data-segmentid="#Segment.Segmentid#"
		data-ispreferred="#structKeyExists(Segment, "IsPreferred") AND Segment.IsPreferred EQ 'true' ? 'true' : 'false'#"
		data-longsegment="#Segment.IsLongSegment#"
		data-longandexpensivesegment="#Segment.IsLongAndExpensive#"
		data-finditmatch="#Segment.IsFindItMatch#"
		data-unusedticketmatch="#structKeyExists(session.Filters[rc.SearchId].getUnusedTicketCarriers(), Segment.CarrierCode)#"
		data-flightnumbers="#Replace(ReReplace(Segment.FlightNumbers,"[^0-9/]","", "ALL"), "/", ",",  "ALL")#"
		>
		<cfset cleanedSegmentId = replace(replace(Segment.SegmentId, '-', '', 'ALL'), '.', '', 'ALL')>
		<input type="hidden" name="segmentJSON" value="#encodeForHTML(serializeJSON(Segment))#" />
	  	<div class="panel-body">
			<div class="row flight-details-header">
				<!---<span class="#ribbonclass#"></span>--->		
				<div class="col-xs-2 col-lg-1 center airline-col #structKeyExists(Segment, "IsPreferred") AND Segment.IsPreferred EQ 'true'  ? 'ispreferred' : ''#">
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
								<cfif structKeyExists(session.Filters[rc.SearchId].getUnusedTicketCarriers(), Segment.CarrierCode)>
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
						<div class="col-xs-6 col-md-3 xs-fs-12">
							<div class="row">
								<div class="col-xs-6 col-lg-12 fs-xs-1 fs-lg-2 p-xs-0 pl-xs-15">
									#Segment.TravelTime# 
									<cfif Segment.IsLongSegment>
										<span role="button" 
											data-placement="right" 
											data-toggle="tooltip"
											title="Segment is more than twice as long as the shortest travel time available."
											class="hidden-xs mdi mdi-timer-sand long-flight-alert"></span>
									</cfif>
								</div>	
								<div class="col-xs-6 col-lg-12 text-muted fs-1 p-xs-0 pl-xs-15">
									<cfif rc.Group NEQ 0 
										AND stItinerary.Air[rc.Group-1].DestinationAirportCode NEQ Segment.OriginAirportCode>
										<span 
											role="button" 
											data-placement="right" 
											data-toggle="tooltip"
											title="Double-check: Different departure airport than arrival may require ground transportation"
											class="departure-airport-alert">#Segment.OriginAirportCode#</span>-#Segment.DestinationAirportCode#
									<cfelse>
										#Segment.OriginAirportCode#-#Segment.DestinationAirportCode#
									</cfif>
								</div>	
							</div>
						</div>
						<div class="col-xs-6 col-md-3 xs-fs-12">		
							<div class="row">
								<div class="col-xs-6 col-lg-12 fs-xs-1 fs-lg-2 p-xs-0 pl-xs-15">
									<cfif Segment.Stops EQ 0>Nonstop<cfelseif Segment.Stops EQ 1>1 stop<cfelse>#Segment.Stops# stops</cfif>
								</div>	
								<div class="col-xs-6 col-lg-12 fs-1 text-muted p-xs-0 ">
									#Segment.Layover#
									<font color="white">#Segment.Results#</font>
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

						<cfloop from="0" to="1" index="Refundable">

							<cfset BrandedFareIds = ''>

							<cfloop list="Economy,PremiumEconomy,Business,First" index="CabinClass">

								<cfset DisplayedFare = false>

								<cfif structKeyExists(SegmentFares, CabinClass)>

									<cfloop collection="#SegmentFares[CabinClass]#" index="FareName" item="Fare">

										<cfif FareName NEQ 'TotalFare'
											AND FareName NEQ 'SegmentFareId'
											AND FareName NEQ 'SegmentId'>

											<cfif Fare.Refundable EQ TrueFalseFormat(Refundable)>

												<!--- Form --->
												<cfset BrandedFareIds = listAppend(BrandedFareIds, Fare.brandedFareID)>
												<cfif Fare.Bookable>
													<cfset key = hash(Segment.SegmentId&CabinClass&SegmentFares[CabinClass].SegmentFareId&Fare.Refundable)>
													<input type="hidden" id="segment#key#" value="#encodeForHTML(serializeJSON(Segment))#">
													<input type="hidden" id="fare#key#" value="#encodeForHTML(serializeJSON(Fare))#">
												</cfif>

												<!--- Display --->
												<div class="fares fare-block #Fare.Refundable eq 0 ? '' : 'hidden'#" 
													data-refundable="#Fare.Refundable#"
													data-privatefare="#TrueFalseFormat(Fare.IsPrivateFare)#"
													<cfif Fare.Bookable>
														onclick="submitSegment.call(this, '#Segment.SegmentId#','#CabinClass#','#SegmentFares[CabinClass].SegmentFareId#','#Fare.Refundable#','#key#');"
													</cfif>
												>

													<div class="cabin-class">
														<div class="fs-1 cabin-description overflow-ellipse">
															<cfif FareName NEQ ''>#FareName#<cfelse>#CabinClass EQ 'PremiumEconomy' ? 'Premium Economy' : CabinClass#</cfif>
															<cfif structKeyExists(Fare,'IsPrivateFare') AND Fare.IsPrivateFare>
																<br>Contracted
															</cfif>
														</div>
														<div class="fs-2 fare-display">
															<div class="overflow-ellipse">$#numberFormat(Fare.TotalFare, '_,___')#</div>
														</div>

														<cfif Fare.OutOfPolicy>
															<div class="col-xs-12 fs-s policy-error">
																<div class="fare-warning"
																	role="button"
																	data-placement="top" 
																	data-toggle="tooltip" 
																	title="#arrayToList(Fare.OutOfPolicyReason)#">&nbsp;
																</div>
															</div>
														<cfelse>
															<div class="fs-s policy-error-hidden"></div>
														</cfif>
													</div>

												</div>

											</cfif>

										</cfif>

										<cfset DisplayedFare = true>

									</cfloop>

								</cfif>

								<cfif NOT DisplayedFare
									AND structKeyExists(Segment, 'Availability')
									AND structKeyExists(Segment.Availability, CabinClass)>

									<cfif structKeyExists(Segment.Availability, CabinClass)
										AND Segment.Availability[CabinClass].Available>
										<cfset Status = 'Click to price'>
									<cfelseif structKeyExists(Segment.Availability, CabinClass)
										AND NOT Segment.Availability[CabinClass].Available>
										<cfset Status = 'Unavailable'>
									</cfif>

									<!--- Form --->
									<cfset key = hash(Segment.SegmentId&CabinClass&Refundable)>
									<input type="hidden" id="segment#key#" value="#encodeForHTML(serializeJSON(Segment))#">
									<input type="hidden" id="fare#key#" value="">

									<!--- Display --->
									<div class="nopprice-fares fare-block #status EQ 'Unavailable' ? 'noclick' : ''# #Refundable eq 0 ? '' : 'hidden'#"
										<cfif Status EQ 'Click to price'>
											onclick="submitSegment.call(this, '#Segment.SegmentId#','#CabinClass#','','#Refundable#','#key#');"
										</cfif>
										data-refundable="#Refundable#"
									>
										<div class="cabin-class">
											<div class="fs-1 cabin-description overflow-ellipse">
												#CabinClass EQ 'PremiumEconomy' ? 'Premium Economy' : CabinClass#
											</div>
											<div class="fs-2 fare-display">
												<div class="overflow-ellipse fs-s">
													#Status#
												</div>
											</div>
											<div class="fs-s policy-error-hidden">
												&nbsp;
											</div>
										</div>												
									</div>

								<cfelseif NOT DisplayedFare
									AND (NOT structKeyExists(Segment, 'Availability')
									OR NOT structKeyExists(Segment.Availability, CabinClass))>

									<div class="spacer fare-block #Refundable eq 0 ? '' : 'hidden'#"
										data-refundable="#Refundable#">
										&nbsp;
									</div>
									
								</cfif>

							</cfloop><!--- Cabin Loop --->

						</cfloop><!--- Refundable Flag --->

					</div>

				</div>
			</div>
				
			<div class="row hidden-xs visible-md-block visible-lg-block">
				<div class="col-xs-12 collapse flight-details-container" id="details#cleanedSegmentId#">
					
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
							<div class="segment-details-extras hidden-xs">
								<ul>
									<cfif NOT Segment.FlightNumbers contains "WN" AND NOT Segment.FlightNumbers contains "F9"><li>
										<a class="seatMapOpener" data-toggle="modal" data-target="##seatMapModal" data-id='#serializeJson(Flight)#'>
											<i class="mdi mdi-seat-recline-normal" aria-hidden="true"></i> View Available Seats
										</a>
									</li></cfif>
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
								<ul class="nav nav-tabs flight-detail-tabs" role="tablist">
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
								<li role="presentation" class="">
									<cfset tabuuid = "f#createUUID()#">
									<a href="###tabuuid#" aria-controls="#tabuuid#" role="tab" data-tab="emailform" data-toggle="tab">Email</a>
								</li>
								<cfsavecontent variable="emailtab"><div role="tabpanel" class="tab-pane" id="#tabuuid#">
email form injects here
								</div></cfsavecontent>
								<cfset paneldetails = "#paneldetails##emailtab#">
								</ul>
								<div class="tab-content branded-cabin-details">#paneldetails#</div>
							</cfif>
					  	  </div>
						  <div>
							<cfset Carriers = ''>
							<cfset DisplayFees = 0>
							<cfloop collection="#Segment.Flights#" index="flightIndex" item="Flight">
								<cfif NOT listFind(Carriers, Flight.CarrierCode)
									AND structKeyExists(application.stAirVendors[Flight.CarrierCode], 'Bag1')>
									<cfset DisplayFees++>
									<cfif DisplayFees EQ 1>
										<h3>Baggage Fees</h3>
									</cfif>
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
