<!--- set unique data-attributes for each badge for filtering by time
<cfscript>
dataString = [];
loop collection="#timeFilter#" item="timeFilterItem" index="timeFilterIndex" {
	arrayAppend(dataString, "data-" & timeFilterIndex & '="#timeFilterItem#"');
}
loop collection="#stTrip.Carriers#" item="carrierItem" index="carrierIndex" {
	arrayAppend(dataString, "data-carrier" & '="#carrierItem#"');
}
arrayAppend(dataString, "data-stops" & '="#stops#"');
arrayAppend(dataString, "data-preferred" & '="#stTrip.Preferred#"');
arrayAppend(dataString, "data-carriercount" & '="#arrayLen(stTrip.Carriers)#"');
arrayAppend(dataString, "data-refundable" & '="#stTrip.ref#"');
arrayAppend(dataString, "data-duration" & '="#stTrip.duration#"');
</cfscript> --->
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
	  			<div class="container">
		  			<div class="row">
						<!---<span class="#ribbonclass#"></span>--->		
						<div class="col-sm-1 center">
							<img class="carrierimg" src="assets/img/airlines/#Segment.CarrierCode#.png" title="#application.stAirVendors[Segment.CarrierCode].Name#" width="60">
							<small>
								<a data-toggle="collapse" href="##details#cleanedSegmentId#" role="button" aria-expanded="false" aria-controls="details#cleanedSegmentId#">
									Details
								</a>
								<cfif Segment.IsPoorSegment>
									<i class="material-icons" data-toggle="tooltip" title="Better economy fare and travel times are available" style="font-size:16px;color:##E3132C;">error</i>
								</cfif>
							</small>
						</div>
						<div class="col-sm-5">
							<div class="row">
								<div class="col-sm-5">
									<span class="bold">#timeFormat(Segment.DepartureTime, 'h:mm tt')# - #timeFormat(Segment.ArrivalTime, 'h:mm tt')#</span>
									<cfif Segment.Days NEQ 0>
										<small class="red">+#Segment.Days# day#Segment.Days GT 1 ? 's' : ''#</small>
									</cfif>
								</div>
								<div class="col-sm-3 bold">
									#Segment.TravelTime#
								</div>
								<div class="col-sm-2 bold">
									<cfif Segment.Stops EQ 0>Nonstop<cfelseif Segment.Stops EQ 1>1 stop<cfelse>#Segment.Stops# stops</cfif>
								</div>
							</div>
							<div class="row">
								<div class="col-sm-5">
									<small>#Segment.FlightNumbers#</small>
								</div>
								<div class="col-sm-3">
									<small>#Segment.OriginAirportCode#-#Segment.DestinationAirportCode#</small>
								</div>
								<div class="col-sm-4">
									<small>#Segment.Connections#</small>
								</div>
							</div>
							<cfif Segment.Codeshare NEQ ''>
								<div class="row">
									<div class="col-sm-12" style="color:##BBBBBB;">
										<small>OPERATED BY #Segment.Codeshare#</small>
									</div>
								</div>
							</cfif>
						</div>
						<div class="col-sm-6">
							<div class="container container-fluid">
								<div class="row">
									<cfset BrandedFareIds = ''>
									<cfloop list="Economy,Business,First" index="CabinClass">
										<cfif structKeyExists(SegmentFares, CabinClass)>
											<cfloop collection="#SegmentFares[CabinClass]#" index="brandedFareName" item="brandedFare">
												<cfif brandedFareName NEQ 'TotalFare'
													AND brandedFareName NEQ 'SegmentFareId'
													AND brandedFareName NEQ 'SegmentId'>
													<cfset BrandedFareIds = listAppend(BrandedFareIds, brandedFare.brandedFareID)>
													<div data-refundable="#brandedFare.Refundable#" style="display:inline;float:left;min-width:125px;text-align:center;" class="fares">
														<span class="bold">$#numberFormat(brandedFare.TotalFare, '_,___')#</span>
														<cfif brandedFare.OutOfPolicy>
															<i class="material-icons" data-toggle="tooltip" title="#arrayToList(brandedFare.OutOfPolicyReason)#" style="font-size:16px;color:##E3132C;">priority_high</i>
														</cfif>
														<br>
														<small>#CabinClass#</small><br>
														<cfif CabinClass NEQ brandedFareName><small>#brandedFareName#</small></cfif><br>
														<cfif brandedFare.Bookable>
															<cfset key = hash(Segment.SegmentId&CabinClass&SegmentFares[CabinClass].SegmentFareId&brandedFare.Refundable)>
															<input type="hidden" id="fare#key#" value="#encodeForHTML(serializeJSON(Segment))#">
															<button type="button" class="btn btn-sm" onclick="submitSegment('#Segment.SegmentId#','#CabinClass#','#SegmentFares[CabinClass].SegmentFareId#','#brandedFare.Refundable#','#key#');">Select</button>
														</cfif>
													</div>
												</cfif>
											</cfloop>

										<cfelse>
											<div style="display:inline;float:left;min-width:125px;text-align:center;">
												<br>
												<small>#CabinClass#</small><br>
												<br>
												<cfset key = hash(Segment.SegmentId&CabinClass&0)>
												<input type="hidden" id="fare#key#" value="#encodeForHTML(serializeJSON(Segment))#">
												<button type="button" class="btn btn-sm" onclick="submitSegment('#Segment.SegmentId#','#CabinClass#','','0','#key#');">Select</button>
											</div>
										</cfif>
									</cfloop>
								</div>
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
		</div>
	</div>
</cfoutput>
<!---<cfdump var=#Flight#>--->
