<cfoutput>
	<!--- <cfdump var=#rc.Solutions# abort> --->
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
				<cfloop collection="#rc.Solutions#" index="index" item="Fare">
					<hr>
					<strong>
						#Fare.CabinClass CONTAINS ',' ? 'Mixed Cabins' : Fare.CabinClass# -
						#Fare.BrandedFare CONTAINS ',' ? 'Mixed Branded Fares' : Fare.BrandedFare#<br>
						<cfif listLen(Fare.CabinClass) GT 1>
							<cfloop collection="#Fare.Flights#" index="i" item="Flight">
								#Flight.CabinClass# - #Flight.BrandedFare# : #Flight.Carrier##Flight.FlightNumber# #Flight.Origin#-#Flight.Destination#<br>
							</cfloop>
						</cfif>
						<!--- Out of Policy:  #YesNoFormat(Fare.OutOfPolicy)# -
						Bookable:  #YesNoFormat(Fare.IsBookable)# - --->
						 <!---<cfdump var="#Fare.OutOfPolicyReason#"> --->
						#Fare.Currency EQ 'USD' ? '$' : Fare.Currency##NumberFormat(Fare.TotalPrice, '0')#<br>
					</strong>
					<cfloop list="#Fare.BrandedFare#" index="BrandedFare">
						<strong>#BrandedFare#</strong> : #Fare[BrandedFare]#<br>
					</cfloop><br>
					
					<cfset key = createUUID()>
					<div onclick="submitSegment('#key#');">
						<input type="hidden" id="Fare#key#" value="#encodeForHTML(serializeJSON(Fare))#">
						Select Fare
					</div>

				</cfloop>
			</div>
		</div>
	</div>

	<form method="post" action="##" id="selectFare">
		<input type="hidden" name="FareSelected" value="1">
		<input type="text" name="Fare" id="Fare" value="">
	</form>

</cfoutput>

<script type="application/javascript">
	function submitSegment(Key) {
		$("#Fare").val($("#Fare"+Key).val());
		$("#selectFare").submit();
	}
</script>		

<cfdump var=#session.Searches[rc.SearchID].stItinerary.Air#>
<cfdump var=#rc.Solutions#>