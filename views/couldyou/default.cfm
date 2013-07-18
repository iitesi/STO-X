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
		</script>
	</cfsavecontent>

	<cfhtmlhead text="#localAssets#" />
</cfsilent>

<cfoutput>
	<!--Page title row-->
	<div class="container">
		<div class="row-fluid">
			<div class="span12">
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
					&nbsp;<br>
					&nbsp;<br>
					&nbsp;<br>
					&nbsp;<br>
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