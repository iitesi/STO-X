<!--- <cfdump var=#session.Filters[rc.SearchID].getUserID()# abort> --->
<cfoutput>
	<div class="panel panel-default trip">
		<!--- <cfset cleanedSegmentId = replace(replace(Segment.SegmentId, '-', '', 'ALL'), '.', '', 'ALL')> --->
		<!--- <input type="hidden" name="segmentJSON" value="#encodeForHTML(serializeJSON(Segment))#" /> --->
	  	<div class="panel-body">
			<div class="row flight-details-header">
				<!---<span class="#ribbonclass#"></span>--->		
				<div class="col-xs-2 col-lg-1 center airline-col"><!---#structKeyExists(Segment, "IsContracted") AND Segment.IsContracted EQ 'true'  ? 'iscontracted' : ''#--->
					<div class="row">
						<div class="col-xs-12">
							<img class="carrierimg" src="assets/img/rail/#Rail.SupplierCode#.png" title="#Rail.SupplierCode#" width="60">
						</div>
						<!--- <div class="col-xs-12 hidden-xs visible-lg-block">&nbsp;</div> --->
						<cfif Rail.Network EQ 'All'>
							<i class="fa fa-wifi"></i>
						</cfif>
						<cfif Rail.QuietCar EQ 'All'>
							<i class="fa fa-bell-slash"></i>
						</cfif>
						<cfif Rail.Snack EQ 'All'>
							<i class="fa fa-cookie-bite"></i>
						</cfif>
					</div>
				</div>
				<div class="col-xs-10 col-lg-5 results-info-wrapper">
					<div class="row results_collapsed">
						<div class="col-xs-12 col-md-6 ">
							<div class="row">
								<div class="col-xs-12 fs-2 fs-xs-2">
									#timeFormat(Left(Rail.DepartureTime, 16), 'h:mm tt')# - #timeFormat(Left(Rail.ArrivalTime, 16), 'h:mm tt')#
								</div>	
			 				</div>
							<!--- <cfif Segment.Days NEQ 0>
								<div class="row">
									<div class="col-xs-12 fs-1 red">
										+#Segment.Days# day#Segment.Days GT 1 ? 's' : ''#
									</div>
								</div>
							</cfif> --->
							<div class="row">
								<div class="col-xs-12 text-muted fs-1">
									#Rail.TrainNumbers#
								</div>	
							</div>							
						</div>
						<div class="clearfix visible-xs-block"></div>
						<div class="col-xs-6 col-md-3">
							<div class="row">
								<div class="col-xs-6 col-lg-12 fs-xs-1 fs-lg-2 p-xs-0 pl-xs-15">
									#Rail.JourneyDurationInMinutes# 
								</div>	
								<div class="col-xs-6 col-lg-12 text-muted fs-1 p-xs-0 pl-xs-15">
									#Rail.OriginStationName#-#Rail.DestinationStationName#
								</div>	
							</div>
						</div>
						<div class="col-xs-6 col-md-3">		
							<div class="row">
								<div class="col-xs-6 col-lg-12 fs-xs-1 fs-lg-2 p-xs-0 pl-xs-15">
									#Rail.Stops#
								</div>	
								<div class="col-xs-6 col-lg-12 fs-1 text-muted p-xs-0 pr-xs-15">
									<!--- #Segment.Connections# --->
								</div>
							</div>
						</div>
					</div>
					<div class="row results_expanded">
						<div class="col-xs-12 fs-2">
							Departing &middot; #dateTimeFormat(createODBCDateTime(Rail.DepartureTime), 'EEE, mmm dd')#
						</div>	
					</div>
				</div>

				<div class="clearfix visible-xs-block"></div>
				<div class="col-xs-12 col-lg-6">

					<div class="row fare-wrapper">

						<cfloop collection="#Rail.PricedRailFares#" index="PricingIndex" item="Pricing">

							<!--- Form --->
							<cfset key = createGUID()>
							<input type="hidden" id="rail#key#" value="#encodeForHTML(serializeJSON(Rail))#">

							<!--- Display --->
							<div class="fares fare-block" onclick="submitRail.call(this, '#key#');">
								<div class="cabin-class">
									<div class="fs-1 cabin-description overflow-ellipse">
										#Pricing.CabinClass#<br>
										#Pricing.FareName#
									</div>
									<div class="fs-2 fare-display">
										<div class="overflow-ellipse">$#numberFormat(Pricing.TotalAmount.Value, '_,___')#</div>
									</div>
									<div class="fs-s policy-error-hidden"></div>
								</div>

							</div>

						</cfloop>

					</div>

				</div>
			</div>
		</div>
	</div>
	<!--- <cfdump var=#Rail# abort> --->
<!---			<div class="row hidden-xs visible-md-block visible-lg-block">
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
							<div class="segment-details-extras">
								<!--- TODO Hide for now?
								<ul>
									<li><span></span> <span> Carry-on bags restricted </span>
									</li>
									<li> Average legroom (31 in)</li>
									<li> Wi-Fi</li>
									<li> In-seat power outlet</li>
									<li> Stream media to your device</li>
								</ul> --->
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
	</div> --->
</cfoutput>
<!---<cfdump var=#Flight#>--->
