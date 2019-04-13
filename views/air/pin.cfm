<cfoutput>
	<cfloop collection="#session.searches[rc.SearchID].stItinerary.Air#" index="index" item="Segment">
		<cfif NOT structIsEmpty(Segment)
			AND index LT Group>
			<div class="panel panel-default">
			  	<div class="panel-body alert-success">
			  		<div class="row">
			  			<div class="container">
				  			<div class="row">
								<!---<span class="#ribbonclass#"></span>--->		
								<div class="col-sm-1 center">
									<img class="carrierimg" src="assets/img/airlines/#Segment.CarrierCode#.png" title="#application.stAirVendors[Segment.CarrierCode].Name#" width="60">
									<small>
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
											<div class="col-sm-12">
												<small>OPERATED BY #Segment.Codeshare#</small>
											</div>
										</div>
									</cfif>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</cfif>
	</cfloop>
</cfoutput>