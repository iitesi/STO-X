<cfsilent>

	<cfsavecontent variable="localAssets">
		<link href="/booking/assets/css/fullcalendar.css" rel="stylesheet">
		<link href="/booking/assets/css/custom-theme/jquery-ui-1.8.23.custom.css" rel="stylesheet">
		<script src="/booking/assets/js/fullcalendar.min.js"></script>
		<script src="/booking/assets/js/purl.js"></script>
		<script src="/booking/assets/js/date.format.js"></script>
		<script src="/booking/assets/js/couldyou.js"></script>
		<script type="text/javascript">
			<cfoutput>shortstravel.search = #serializeJSON( rc.Filter )#;</cfoutput>
			<cfoutput>shortstravel.itinerary = #serializeJSON( session.searches[ rc.searchID ].stItinerary )#;</cfoutput>
			shortstravel.itinerary.total = 0;
			if( typeof shortstravel.itinerary.AIR != 'undefined' ){
				shortstravel.itinerary.total += parseFloat( shortstravel.itinerary.AIR.TOTAL );
			}
			if( typeof shortstravel.itinerary.HOTEL != "undefined" ){
				shortstravel.itinerary.total += parseFloat( shortstravel.itinerary.HOTEL.Rooms[0].totalForStay );
			}
			if( typeof shortstravel.itinerary.VEHICLE != "undefined" ){
					shortstravel.itinerary.total += parseFloat( shortstravel.itinerary.VEHICLE.estimatedTotalAmount );
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
	<div class="container">
		<div class="row-fluid">
			<div class="span32">
				<div class="page-header">
					<h1>Could you save within 14 days for this same trip?<br><small> We are finding an average of $<span id="dollarSavings">XXX.XX</span> in <span id="percentSavings">XX</span>% of searches</small></h1>
					<p>Select a date below to save or continue to purchase</p>
				</div>
			</div>
		</div>
	</div>

	<div class="container">
		<div class="row-fluid">
			<div class="span6">
				<h2 style="margin-left: 10px;">Trip Summary for <span class="tripStartDate">#dateFormat( rc.startDate, "ddd, mmm d" )#</span>
					<cfif rc.Filter.getAirType() NEQ "OW">to <span class="tripEndDate">#dateFormat( rc.endDate, "ddd, mmm d" )#</span></cfif></h2>
				<div class="badge hotel">

						<div class="minlineheight">
							<div class="span3"></div>
							<div class="span3"><strong>Base Rate</strong></div>
							<div class="span3"><strong>Taxes</strong></div>
							<div class="span3"><strong>Total</strong></div>
						</div>

						<cfset tripTotal = 0>
						<cfset tripCurrency = 'USD'>

						<cfif rc.airSelected>

							<div class="minlineheight" id="airTotalRow">
								<div class="span3">Flight</div>
								<div class="span3"><span id="airBaseRate">#numberFormat(rc.Air.Base, '$____.__')#</span></div>
								<div class="span3"><span id="airTaxes">#numberFormat(rc.Air.Taxes, '$____.__')#</span></div>
								<div class="span3" id="airTotalCol"><span id="airTotal">#numberFormat(rc.Air.Total, '$____.__')#</span></div>
							</div>

							<cfset tripTotal = tripTotal + rc.Air.Total>
							<cfset tripCurrency = 'USD'>

						</cfif>
						<cfif rc.hotelSelected>

							<cfif rc.Hotel.getRooms()[1].getTotalForStay() GT 0>
								<cfset currency = rc.Hotel.getRooms()[1].getTotalForStayCurrency()>
								<cfset hotelTotal = rc.Hotel.getRooms()[1].getTotalForStay()>
								<cfset hotelText = 'Including taxes'>
							<cfelse>
								<cfset currency = rc.Hotel.getRooms()[1].getBaseRateCurrency()>
								<cfset hotelTotal = rc.Hotel.getRooms()[1].getBaseRate()>
								<cfset hotelText = 'Quoted at check-in'>
							</cfif>

							<div class="minlineheight" id="hotelTotalRow">
								<div class="span3">Hotel</div>
								<div class="span3"><span id="hotelBaseRate"></span></div>
								<div class="span3"><span id="hotelTaxes">#hotelText#</span></div>
								<div class="span3"><span id="hotelTotal">#(currency EQ 'USD' ? numberFormat(hotelTotal, '$____.__') : hotelTotal&' '&currency)#</span></div>
							</div>

							<cfset tripTotal = (currency EQ 'USD' ? tripTotal + hotelTotal : 0)>
							<cfset tripCurrency = (tripCurrency EQ 'USD' ? currency : tripCurrency)>

						</cfif>

						<cfif rc.vehicleSelected>

							<cfset currency = rc.Vehicle.getCurrency()>
							<cfset vehicleTotal = rc.Vehicle.getEstimatedTotalAmount()>

							<div class="minlineheight" id="carTotalRow">
								<div class="span3">Car</div>
								<div class="span3"><span id="carBaseRate"></span></div>
								<div class="span3"><span id="carTaxes">Quoted at pick-up</span></div>
								<div class="span3"><span id="carTotal">#(currency EQ 'USD' ? numberFormat(vehicleTotal, '$____.__') : vehicleTotal&' '&currency)#</span></div>
							</div>

							<cfset tripTotal = (currency EQ 'USD' ? tripTotal + vehicleTotal : 0)>
							<cfset tripCurrency = (tripCurrency EQ 'USD' ? currency : tripCurrency)>

						</cfif>

						<cfif rc.fees.fee NEQ 0>
							<div class="minlineheight" id="bookingTotalRow">
								<div class="span3">Booking Fee</div>
								<div class="span3"></div>
								<div class="span3"></div>
								<div class="span3" id="bookingTotalCol">#numberFormat(rc.fees.fee, '$____.__')#</div>
							</div>
							<input type="hidden" id="bookingTotal" value="#rc.fees.fee#">
						</cfif>


						<cfif tripCurrency EQ 'USD'>

							<cfset tripTotal = tripTotal + rc.fees.fee>

							<div class="minlineheight">
								<div class="span12 minlineheight"><hr width="100%" style="margin: 0;"></div>
							</div>

							<div class="minlineheight" id="bookingTotalRow">
								<div class="span9 blue"><strong>Trip cost for current traveler</strong></div>
								<div class="span3 blue" id="totalCol"><strong><span id="tripTotal">#numberFormat(tripTotal, '$____.__')#</span></strong></div>
							</div>

						</cfif>
				</div>

				<div style="margin-left: 20px;">
					<div class="span4" style="margin-top: 15px; margin-bottom: 15px;"><span class="fc-higherPrice">&nbsp;&nbsp;&nbsp;</span> Higher or Same Price</div>
					<div class="span4" style="margin-top: 15px; margin-bottom: 15px;"><span class="fc-lowerPrice">&nbsp;&nbsp;&nbsp;</span> Lower Price</div>
					<div class="span4" style="margin-top: 15px; margin-bottom: 15px;"><span class="fc-maxSavings">&nbsp;&nbsp;&nbsp;</span> Max Savings</div>
				</div>

				<div style="margin-left: 10px; margin-right: 10px;">
					<div id="calendar1"></div>
					<div id="calendar2"></div>
				</div>
			</div>

			<div class="span6">
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
<div id="myModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-header">
		<h4><i class="icon-spinner icon-spin"></i> One moment, we're searching for...</h4>
	</div>
	<div id="myModalBody" class="modal-body">
		Ways to save you money.....

	</div>
</div>