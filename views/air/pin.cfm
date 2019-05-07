<cfoutput>
	<cfloop collection="#session.searches[rc.SearchID].stItinerary.Air#" index="index" item="Segment">
		<cfif NOT structIsEmpty(Segment) AND index LT Group>
			<div class="departing-segment__arrow_box">
				<div class="imagewrapper center">
					<img class="carrierimg carrierimg-xs" src="assets/img/airlines/#Segment.CarrierCode#.png" title="#application.stAirVendors[Segment.CarrierCode].Name#" width="60">
				</div>
				<div class="segment-details">
					<div class="segment-details-wrapper">
						<div class="segment-col-a">
							<span class="bold">#timeFormat(Segment.DepartureTime, 'h:mm tt')# - #timeFormat(Segment.ArrivalTime, 'h:mm tt')#</span>
							<cfif Segment.Days NEQ 0>
								<span class="red">+#Segment.Days# day#Segment.Days GT 1 ? 's' : ''#</span>
							</cfif>
						</div>
						<div class="segment-col-b">
							#Segment.TravelTime#
						</div>
						<div class="segment-col-c">
							<cfif Segment.Stops EQ 0>Nonstop<cfelseif Segment.Stops EQ 1>1 stop<cfelse>#Segment.Stops# stops</cfif>
						</div>
					</div>
					<div class="segment-details-wrapper">
						<div class="segment-col-a">
							#Segment.FlightNumbers#
						</div>
						<div class="segment-col-b">
							#Segment.OriginAirportCode#-#Segment.DestinationAirportCode#
						</div>
						<div class="segment-col-c">
							#Segment.Connections#
						</div>
					</div>
				</div>
				<cfif Segment.Codeshare NEQ ''>
					<div class="operatedby">
						Operated By: #lcase(Segment.Codeshare)#
					</div>
				</cfif>
			</div>
		</cfif>
	</cfloop>
</cfoutput>