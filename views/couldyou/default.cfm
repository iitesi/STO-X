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
				<h2>Trip Summary for <span id="tripStartDate">#dateFormat( rc.startDate, "ddd, mmm d" )#</span> to <span id="tripEndDate">#dateFormat( rc.endDate, "ddd, mmm d" )#</span></h2>
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
								<div class="span3">#numberFormat(rc.Air.Base, '$____.__')#</div>
								<div class="span3">#numberFormat(rc.Air.Taxes, '$____.__')#</div>
								<div class="span3" id="airTotalCol">#numberFormat(rc.Air.Total, '$____.__')#</div>
							</div>
							<input type="hidden" id="airTotal" value="#rc.Air.Total#">

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
								<div class="span3"></div>
								<div class="span3">#hotelText#</div>
								<div class="span3" id="hotelTotalCol">#(currency EQ 'USD' ? numberFormat(hotelTotal, '$____.__') : hotelTotal&' '&currency)#</div>
							</div>
							<input type="hidden" id="hotelTotal" value="#hotelTotal#">

							<cfset tripTotal = (currency EQ 'USD' ? tripTotal + hotelTotal : 0)>
							<cfset tripCurrency = (tripCurrency EQ 'USD' ? currency : tripCurrency)>

						</cfif>

						<cfif rc.vehicleSelected>

							<cfset currency = rc.Vehicle.getCurrency()>
							<cfset vehicleTotal = rc.Vehicle.getEstimatedTotalAmount()>

							<div class="minlineheight" id="carTotalRow">
								<div class="span3">Car</div>
								<div class="span3"></div>
								<div class="span3">Quoted at pick-up</div>
								<div class="span3" id="carTotalCol">#(currency EQ 'USD' ? numberFormat(vehicleTotal, '$____.__') : vehicleTotal&' '&currency)#</div>
							</div>
							<input type="hidden" id="carTotal" value="#vehicleTotal#">

							<cfset tripTotal = (currency EQ 'USD' ? tripTotal + vehicleTotal : 0)>
							<cfset tripCurrency = (tripCurrency EQ 'USD' ? currency : tripCurrency)>

						</cfif>

						<div class="minlineheight" id="bookingTotalRow">
							<div class="span3">Booking Fee</div>
							<div class="span3"></div>
							<div class="span3"></div>
							<div class="span3" id="bookingTotalCol">#numberFormat(rc.fees.fee, '$____.__')#</div>
						</div>
						<input type="hidden" id="bookingTotal" value="#rc.fees.fee#">

						<cfif tripCurrency EQ 'USD'>

							<cfset tripTotal = tripTotal + rc.fees.fee>

							<div class="minlineheight">
								<div class="span12 minlineheight"><hr width="100%" style="margin: 0;"></div>
							</div>

							<div class="minlineheight" id="bookingTotalRow">
								<div class="span9 blue"><strong>Trip cost for current traveler</strong></div>
								<div class="span3 blue" id="totalCol"><strong>#numberFormat(tripTotal, '$____.__')#</strong></div>
							</div>

						</cfif>
				</div>

				<div>

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

				</div>
			</div>

			<div class="row-fluid">
				<div class="span6">

					<div id="calendar1"></div>

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