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
						<cfset firstFlight = Segment.Flights[1]/>
						<cfset lastFlight = Segment.Flights[ArrayLen(Segment.Flights)]/>
						<div class="panel panel-default trip-segment">
							<div class="panel-heading">
							<h3 class="panel-title" style="position:relative;">
								<span class="mdi mdi-airplane-takeoff hide-small"></span>
								<span class="hide-small">#application.stAirports[firstFlight.OriginAirportCode].airport#</span>
								<span class="fromto hide-small">To</span>
								<span class="mdi mdi-airplane-landing hide-small"></span>
								<span class="hide-small">#application.stAirports[lastFlight.DestinationAirportCode].airport#</span>
								<div class="panel-date">
									<span class="mdi mdi-calendar"></span>
									#DateFormat(firstFlight.DepartureTime, 'ddd, mmm d, yyyy')#
								</div>
							</h3>
							</div>
							<div class="panel-body">
								<cfset count = 0>
						<cfloop collection="#Segment.Flights#" index="FlightIndex" item="Flight">
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
											<div class="carrier-img-wrapper">
												<img class="carrierimg" src="assets/img/airlines/#Flight.CarrierCode#.png" title="#application.stAirVendors[Flight.CarrierCode].Name#" width="60">
											</div>
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
											</div>
											<div class="segment-leg-operation-codes">
												<span class="segment-middot-sm">&middot;</span>
												<span><span>#Flight.CarrierCode#</span>&nbsp;<span>#Flight.FlightNumber#</span></span>
											</div>
										</div>
									</div>
								</div>
								<div class="segment-details-extras">&nbsp;</div>
							</div>
							<cfset previousFlight = Flight>
						</cfloop>
					</div>
				</div>
					</cfif>
				
				</cfif>
			</cfloop>
		</div>
	</div>
	<cfset ErrorMessage = ''>
	<cfset FaresDisplayed = 0>
	<cfset cabinFares = arrayNew(1)/>
	<a name="selectfare"></a>
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
						<cfscript>ArrayAppend(cabinFares,NumberFormat(Fare.TotalPrice, '0'))</cfscript>
					</div>
					<cfset key = createUUID()>
					<div class="fare-selection-button">
						<input type="hidden" id="Fare#key#" value="#encodeForHTML(serializeJSON(Fare))#">
						<a href="javascript:submitSegment('#key#');" class="btn btn-primary">
							Select This Fare
						</a>
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
					<div>
						#Fare.Refundable ? 'Refundable' : 'Non Refundable'#
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

	$(function(){
		try {
			let cabinFares = <cfoutput>#serializeJSON(cabinFares)#</cfoutput>;
			var fareRangeLink = $('#fare-range-html');

			if(fareRangeLink.length && cabinFares.length){
				cabinFares.sort();
				let fareHtml = '$' + cabinFares[0];
				if(cabinFares.length > 1){
					fareHtml = fareHtml + ' to $' + cabinFares[cabinFares.length-1];
					fareRangeLink.html(fareHtml);
				}
			}
		}
		catch(e){
			console ? console.log(e) : '';
		}
	});
</script>		

<!--- <cfdump var=#session.Searches[rc.SearchID].stItinerary.Air#>
<cfdump var=#rc.Solutions#> --->