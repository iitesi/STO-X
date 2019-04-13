<cfoutput>
	<!--- #view('air/unusedtickets')# --->
	<div class="page-header">
		#View('air/legs')#
	</div>
	<div class="list-view container" id="listcontainer">
		<div class="panel panel-default" >
			<div class="panel-body">
				<cfloop collection="#session.Searches[rc.SearchID].stItinerary.Air#" index="Group" item="Segment">
					<cfif structKeyExists(Segment, 'Flights')>
						<cfloop collection="#Segment.Flights#" index="FlightIndex" item="Flight">
							<!---<span class="#ribbonclass#"></span>--->
							<div class="col-sm-1 center">
								<img class="carrierimg" src="assets/img/airlines/#Flight.CarrierCode#.png" title="#application.stAirVendors[Flight.CarrierCode].Name#" width="60">
							</div>
							<div class="col-sm-11">
								<div class="row">
									<div class="col-sm-5">
										<span class="bold">#timeFormat(Flight.DepartureTime, 'h:mm tt')# - #timeFormat(Flight.ArrivalTime, 'h:mm tt')#</span>
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
										<small>#Flight.FlightNumber#</small>
									</div>
									<div class="col-sm-3">
										<small>#Flight.OriginAirportCode#-#Flight.DestinationAirportCode#</small>
									</div>
									<div class="col-sm-4">
										<small>#Segment.Connections#</small>
									</div>
								</div>
							</div>
						</cfloop>
					</cfif>
				</cfloop>
				<cfloop collection="#rc.Pricing.AirPriceSegments#" index="index" item="Fares">
					<cfloop collection="#Fares.AirPriceFares#" index="index" item="Fare">
						<hr>
						#Fare.CabinClass# -
						#Fare.BrandedFare# -
						Out of Policy:  #YesNoFormat(Fare.OutOfPolicy)# -
						Bookable:  #YesNoFormat(Fare.IsBookable)# -
						 <!---<cfdump var="#Fare.OutOfPolicyReason#"> --->
						#Fare.TotalFare.Currency EQ 'USD' ? '$' : Fare.TotalFare.Currency##NumberFormat(Fare.TotalFare.Value, '0')#
						<!--- <cfdump var=#Fare#> --->
					</cfloop>
				</cfloop>
			</div>
		</div>
	</div>
</cfoutput>

<cfdump var=#session.Searches[rc.SearchID].stItinerary.Air#>
<cfdump var=#rc.Pricing#>