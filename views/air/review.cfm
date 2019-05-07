<style>
	/** Tweak some global styles only on this page **/
	#page-content-wrapper {
		height:100%;
	}
</style>

<cfoutput>
	<cfif structKeyExists(rc, 'Order')>
		<br>
		<div class="alert alert-warning">
			Please select the cabin and fare in order before moving to the next section.
		</div>
	</cfif>
	<!--- <cfdump var=#rc.Solutions# abort> --->
	<!--- #view('air/unusedtickets')# --->
	<div class="page-header">
		#View('air/legs')#
	</div>
	<div class="list-view" id="listcontainer">
		<div class="listwrapper">
			<cfloop index="Group" from="0" to="20" >
				<cfif structKeyExists(session.Searches[rc.SearchID].stItinerary.Air, Group)>
					<cfset Segment = session.Searches[rc.SearchID].stItinerary.Air[Group]/>
					<cfif structKeyExists(Segment, 'Flights')>
						<cfloop collection="#Segment.Flights#" index="FlightIndex" item="Flight">

							<div class="panel panel-default trip-segment">
								<div class="panel-heading">
								<h3 class="panel-title">
									<span class="mdi mdi-airplane-takeoff"></span>
									<span>#application.stAirports[Flight.OriginAirportCode].airport#</span>
									<span class="fromto">To</span>
									<span class="mdi mdi-airplane-landing"></span>
									<span>#application.stAirports[Flight.DestinationAirportCode].airport#</span>
								</h3>
								</div>
								<div class="panel-body">
							
									<!--- <cfif structKeyExists(session.Filters[rc.SearchId].getUnusedTicketCarriers(), Segment.CarrierCode)>
										Shane Pitts - Notification for unused tickets UI.
										<i class="material-icons">notifications</i>
									</cfif> --->

									<div class="row">
										<div class="col-xs-3 col-md-2 center">
											<img class="carrierimg" src="assets/img/airlines/#Flight.CarrierCode#.png" title="#application.stAirVendors[Flight.CarrierCode].Name#" width="60">
										</div>
										<div class="col-xs-9 col-md-10">
											<div class="row">
												<div class="col-xs-12">
													<span class="bold">#DateFormat(Flight.DepartureTime, 'ddd, mmm d, yyyy')#</span>
												</div>
												<div class="col-xs-12 col-md-6">
													<span class="bold">#timeFormat(Flight.DepartureTime, 'h:mm tt')# - #timeFormat(Flight.ArrivalTime, 'h:mm tt')#</span>
													<cfif Segment.Days NEQ 0>
														<small class="red">+#Segment.Days# day#Segment.Days GT 1 ? 's' : ''#</small>
													</cfif>
												</div>
												<div class="col-xs-6 col-md-3 bold">
													#Segment.TravelTime#
												</div>
												<div class="col-xs-6 col-md-3 bold">
													<cfif Segment.Stops EQ 0>Nonstop<cfelseif Segment.Stops EQ 1>1 stop<cfelse>#Segment.Stops# stops</cfif>
												</div>
											</div>
											<div class="row">
												<div class="col-xs-12 col-md-6">
													<small>#Flight.FlightNumber#</small>
												</div>
												<div class="col-xs-6 cold-md-3">
													<small>#Flight.OriginAirportCode#-#Flight.DestinationAirportCode#</small>
												</div>
												<div class="col-xs-6 col-md-3">
													<small>#Segment.Connections#</small>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>
						</cfloop>
					</cfif>
				</cfif>
			</cfloop>
		</div>
	</div>
	<cfset ErrorMessage = ''>
	<cfset FaresDisplayed = 0>
	<div class="panel panel-default review-fare-grid">

		<cfloop collection="#rc.Solutions#" index="index" item="Fare">
			<cfif IsStruct(Fare)>
				<cfset FaresDisplayed++>

				<div class="review-fare-column">
					<div class="heading">
						#Fare.CabinClass CONTAINS ',' ? 'Mixed Cabins' : Fare.CabinClass#<br>
						#Fare.BrandedFare CONTAINS ',' ? 'Mixed Branded Fares' : Fare.BrandedFare#
					</div>
					<div class="fare-price">
						#Fare.Currency EQ 'USD' ? '$' : Fare.Currency##NumberFormat(Fare.TotalPrice, '0')#
					</div>
					<cfset key = createUUID()>
					<div onclick="submitSegment('#key#');" class="fare-selection-button">
						<input type="hidden" id="Fare#key#" value="#encodeForHTML(serializeJSON(Fare))#">
						Select This Fare
					</div>
					<div class="out-of-policy">
						Out of Policy:  #YesNoFormat(Fare.OutOfPolicy)#
						<cfif Fare.OutOfPolicy EQ 'Yes'>
						<div>
							<ul>
							<cfloop collection="#Fare.OutOfPolicyreason#" item="ooi">
								<li>#Fare.OutOfPolicyreason[ooi]#</li>
							</cfloop>
							</ul>
						</div>
					</cfif>
					</div>
					<div class="contracted">
						Contracted:  #YesNoFormat(Fare.IsContracted)#
					</div>
					<div class="bookable">
						Bookable:  #YesNoFormat(Fare.IsBookable)#
					</div>
					<div class="class-details">
						<cfif listLen(Fare.CabinClass) GT 1>
							<cfloop collection="#Fare.Flights#" index="i" item="Flight">
								#Flight.CabinClass# - #Flight.BrandedFare# : #Flight.Carrier##Flight.FlightNumber# #Flight.Origin#-#Flight.Destination#<br>
							</cfloop>
						</cfif>
					</div>
					<div class="branded-details">
						<cfloop list="#Fare.BrandedFare#" index="BrandedFare">
							<cfset detailsArray = listToArray(Fare[BrandedFare], "•")/>
							<div class="branded-fare-name">#BrandedFare#</div>
							<ul>
								<cfloop array="#detailsArray#" item="detail">
									<li>#detail#</li>
								</cfloop>
							</ul>
						</cfloop>
					</div>
				</div>						
			<cfelse>
				<cfset ErrorMessage = listAppend(ErrorMessage, Fare)>
			</cfif>
		</cfloop>

	  </div>


	<cfif FaresDisplayed LTE 0>

		#Replace(ListRemoveDuplicates(ErrorMessage), ',', '<br>', 'ALL')#

	</cfif>

	<form method="post" action="##" id="selectFare">
		<input type="hidden" name="FareSelected" value="1">
		<input type="hidden" name="Fare" id="Fare" value="">
	</form>

</cfoutput>

<script type="application/javascript">
	function submitSegment(Key) {
		$("#Fare").val($("#Fare"+Key).val());
		$("#selectFare").submit();
	}
</script>		

<!--- <cfdump var=#session.Searches[rc.SearchID].stItinerary.Air#>
<cfdump var=#rc.Solutions#> --->