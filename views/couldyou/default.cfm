<cfsilent>

	<cfsavecontent variable="localAssets">
		<link href="/booking/assets/css/fullcalendar.css" rel="stylesheet">
		<link href="/booking/assets/css/custom-theme/jquery-ui-1.8.23.custom.css" rel="stylesheet">
		<script src="/booking/assets/js/fullcalendar.min.js"></script>
		<script src="/booking/assets/js/purl.js"></script>
		<script src="/booking/assets/js/date.format.js"></script>
		<script src="/booking/assets/js/couldyou.js?v=20171025"></script>
		<script type="text/javascript">
			<cfoutput>shortstravel.search = #serializeJSON( rc.Filter )#;</cfoutput>
			<cfoutput>shortstravel.itinerary = #serializeJSON( session.searches[ rc.searchID ].stItinerary )#;</cfoutput>
			shortstravel.itinerary.total = 0;
			if( typeof shortstravel.itinerary.Air != 'undefined' ){
				shortstravel.itinerary.total += parseFloat( shortstravel.itinerary.Air.Total );
			}
			if( typeof shortstravel.itinerary.Hotel != "undefined" ){
				if (shortstravel.itinerary.Hotel.Rooms[0].totalForStay != 0) {
					shortstravel.itinerary.total += parseFloat( shortstravel.itinerary.Hotel.Rooms[0].totalForStay );
				}
				else if (shortstravel.itinerary.Hotel.Rooms[0].baseRate != 0) {
					shortstravel.itinerary.total += parseFloat( shortstravel.itinerary.Hotel.Rooms[0].baseRate );
				}
				else {
					checkInDate = new Date(shortstravel.search.checkInDate);
					checkOutDate = new Date(shortstravel.search.checkOutDate);
					dateDiff = (checkOutDate.getTime() - checkInDate.getTime());
					numNights = (dateDiff / (1000*60*60*24));
					hotelTotal = parseFloat( shortstravel.itinerary.Hotel.Rooms[0].dailyRate ) * numNights;
					shortstravel.itinerary.total += hotelTotal;
				}
			}
			if( typeof shortstravel.itinerary.Vehicle != "undefined" ){
					shortstravel.itinerary.total += parseFloat( shortstravel.itinerary.Vehicle.estimatedTotalAmount );
			}
			shortstravel.itinerary.total = Math.round( shortstravel.itinerary.total );
		</script>
	</cfsavecontent>

	<cfhtmlhead text="#localAssets#" />
</cfsilent>

<style>
	.minlineheight {
		line-height:10px;
	}
</style>

<cfoutput>
	<!--Errors and Messages Row-->
	<div class="container">
		<div class="row-fluid">
			<!--Messages row-->
			<div class="alert hide" id="alert-wrapper">
				<button type="button" class="close" data-dismiss="alert">&times;</button>
				<span id="alert-text"></span>
			</div>
		</div>
	</div>

	<!--Page title row-->
	<div class="">
		<div class="row-fluid">
			<div class="span32">
				<div class="page-header">
					<h1>Could you save within 8 days for this same trip?</h1>
					<p>Select a date below to save or continue to purchase</p>
				</div>
			</div>
		</div>
	</div>

	<div class="">
		<div class="row">
			<div class="col-sm-6">
				<h2 style="margin-left: 10px;">Trip Summary for <span class="tripStartDate">#dateFormat( rc.startDate, "ddd, mmm d" )#</span>
					<cfif rc.Filter.getAirType() NEQ "OW">to <span class="tripEndDate">#dateFormat( rc.endDate, "ddd, mmm d" )#</span></cfif></h2>
				<div class="badge hotel">
					<div class="text-right row">
						<div class="col-xs-offset-3 col-xs-3"><strong>Base Rate</strong></div>
						<div class="col-xs-3"><strong>Taxes</strong></div>
						<div class="col-xs-3"><strong>Total</strong></div>
					</div>

						<cfset tripTotal = 0>
						<cfset tripCurrency = 'USD'>

						<cfif rc.airSelected>
							<div class="row text-right" id="airTotalRow">
								<div class="col-xs-3">Flight</div>
								<!--- Per STM-2595, changed "Base" to "ApproximateBase" since Base can be in any currency and ApproximateBase is always in USD. --->
								<div class="col-xs-3">#numberFormat(rc.Air.Base, '$____.__')#</div>
								<!--- <div class="span1">#numberFormat(rc.Air.Base, '$____.__')#</div> --->
								<div class="col-xs-3">#numberFormat(rc.Air.Taxes, '$____.__')#</div>
								<div class="col-xs-3 text-right" id="airTotalCol">#numberFormat(rc.Air.Total, '$____.__')#</div>
							</div>

							<cfset tripTotal = tripTotal + rc.Air.Total>
							<cfset tripCurrency = 'USD'>

						</cfif>
						<cfif rc.hotelSelected>

							<cfset nights = dateDiff('d', rc.Filter.getCheckInDate(), rc.Filter.getCheckOutDate())>
							<cfif rc.Hotel.getRooms()[1].getTotalForStay() GT 0>
								<cfset currency = rc.Hotel.getRooms()[1].getTotalForStayCurrency()>
								<cfset hotelTotal = rc.Hotel.getRooms()[1].getTotalForStay()>
								<cfset hotelText = 'Including taxes'>
							<cfelseif rc.Hotel.getRooms()[1].getBaseRate() GT 0>
								<cfset currency = rc.Hotel.getRooms()[1].getBaseRateCurrency()>
								<cfset hotelTotal = rc.Hotel.getRooms()[1].getBaseRate()>
								<cfset hotelText = 'Quoted at check-in'>
							<cfelse>
								<cfset currency = rc.Hotel.getRooms()[1].getDailyRateCurrency()>
								<cfset hotelTotal = rc.Hotel.getRooms()[1].getDailyRate()*nights>
								<cfset hotelText = 'Quoted at check-in'>
							</cfif>

							<div class="row text-right" id="hotelTotalRow">
								<div class="col-xs-3">Hotel</div>
								<div class="col-xs-3"><span id="hotelBaseRate"></span></div>
								<div class="col-xs-3"><span id="hotelTaxes">#hotelText#</span></div>
								<div class="col-xs-3" ><span id="hotelTotal">#(currency EQ 'USD' ? numberFormat(hotelTotal, '$____.__') : hotelTotal&' '&currency)#</span></div>
							</div>

							<cfset tripTotal = (currency EQ 'USD' ? tripTotal + hotelTotal : 0)>
							<cfset tripCurrency = (tripCurrency EQ 'USD' ? currency : tripCurrency)>

						</cfif>

						<cfif rc.vehicleSelected>

							<cfset currency = rc.Vehicle.getCurrency()>
							<cfset vehicleTotal = rc.Vehicle.getEstimatedTotalAmount()>

								<div class="row text-right" id="carTotalRow">
									<div class="col-xs-3">Car</div>
									<div class="col-xs-3"><span id="carBaseRate"></span></div>
									<div class="col-xs-3"><span id="carTaxes">Quoted at pick-up</span></div>
									<div class="col-xs-3" id="carTotalCol"><span id="carTotal">#(currency EQ 'USD' ? numberFormat(vehicleTotal, '$____.__') : vehicleTotal&' '&currency)#</span></div>
								</div>

							<!--<div class="minlineheight" id="carTotalRow">
								<div class="span3">Car</div>
								<div class="span3"><span id="carBaseRate"></span></div>
								<div class="span3"><span id="carTaxes">Quoted at pick-up</span></div>
								<div class="span3"><span id="carTotal">#(currency EQ 'USD' ? numberFormat(vehicleTotal, '$____.__') : vehicleTotal&' '&currency)#</span></div>
							</div>-->

							<cfset tripTotal = (currency EQ 'USD' ? tripTotal + vehicleTotal : 0)>
							<cfset tripCurrency = (tripCurrency EQ 'USD' ? currency : tripCurrency)>

						</cfif>

						<cfif rc.fees.fee NEQ 0>
							<div class="row text-right" id="bookingTotalRow">
								<div class="col-xs-8">Booking Fee</div>
								<div class="col-xs-4" id="bookingFeeCol">#numberFormat(rc.fees.fee, '$____.__')#</div>
							</div>

							<input type="hidden" id="bookingTotal" value="#rc.fees.fee#">
						</cfif>


						<cfif tripCurrency EQ 'USD'>

							<cfset tripTotal = tripTotal + rc.fees.fee>
								<div class="row text-right" id="bookingTotalRow">
									<div class="col-xs-8 blue"><strong>Trip cost for current traveler</strong></div>
									<div class="col-xs-4 blue" id="totalTotal">
										<strong><span id="tripTotal">#numberFormat(tripTotal, '$____.__')#</span></strong>
									</div>
								</div>

						</cfif>
				</div>

				<div style="margin-left: 20px;">
					<div class="col-xs-4" style="margin-top: 15px; margin-bottom: 15px;"><span class="fc-higherPrice">&nbsp;&nbsp;&nbsp;</span> Higher or Same Price</div>
					<div class="col-xs-4" style="margin-top: 15px; margin-bottom: 15px;"><span class="fc-lowerPrice">&nbsp;&nbsp;&nbsp;</span> Lower Price</div>
					<div class="col-xs-4" style="margin-top: 15px; margin-bottom: 15px;"><span class="fc-maxSavings">&nbsp;&nbsp;&nbsp;</span> Max Savings</div>
				</div>

				<div style="margin-left: 10px; margin-right: 10px;">
					<div id="calendar1"></div>
					<div id="calendar2"></div>
				</div>
			</div>

			<div class="col-sm-6">
				<h2 id="numCheaperDates" style="margin-left: 10px;"></h2>
				<table id="alternativesTable" class="table" width="100%">
					<thead>
						<tr>
							<th class="fc-day-header ui-widget-header fc-first">Trip Cost</th>
							<th class="fc-day-header ui-widget-header">Savings</th>
							<th class="fc-day-header ui-widget-header">Depart</th>
							<th class="fc-day-header ui-widget-header fc-last">Return</th>
						</tr>
					</thead>
					<tbody>

					</tbody>
				</table>

				<div style="margin-top: 30px; margin-right: 30px; text-align: right;">

					<p><b>You are booking <span class="tripStartDate">#dateFormat( rc.startDate, "ddd, mmm d" )#</span>
						<cfif rc.Filter.getAirType() NEQ "OW">to <span class="tripEndDate">#dateFormat( rc.endDate, "ddd, mmm d" )#</span></cfif></b></p>
					<p><button id="btnContinuePurchase" class="btn btn-primary" value="#dateFormat( rc.startDate, "mm-dd-yyyy" )#" onClick="shortstravel.couldyou.continueToPurchase();">CONTINUE TO PURCHASE</button></p>
				</div>
			</div>
		</div>
	</div>
</cfoutput>

<!-- Modal -->
<div id="myModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<h4><i class="fa fa-spinner fa-spin"></i> One moment, we're searching for...</h4>
			</div>
			<div id="myModalBody" class="modal-body">
				Ways to save you money.....

			</div>
		</div>
	</div>
</div>
