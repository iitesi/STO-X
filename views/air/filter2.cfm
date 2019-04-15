<style type="text/css">
	.navbar-default {
		background-color: #FFFFFF;
		background-image: none;
		box-shadow: none;
	}
</style>

<div id="filterbar">
	<div class="navbar">
		<div class="container-fluid">
			<div class="navbar-header">
				<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#filter-navbar-collapse-1" aria-expanded="false">
					<span class="sr-only">Toggle navigation</span>
					<span class="glyphicon glyphicon-filter"></span>
				</button>
			</div>
			<ul class="nav nav-pills">
				<li role="presentation" class="dropdown" id="filterSort">
					<a role="button" href="#" class="dropdown-toggle" aria-haspopup="true">
						<span>Sort</span>
						<span class="caret"></span>
					</a>
					<ul class="dropdown-menu dropdown-menu-right">
						<li>
							<div class="md-radio">
								<input id="sortbyprice-a" checked type="radio" name="sort" title="Sort by price" onClick="sortTrips('economy');">
								<label for="sortbyprice-a">Economy Class Fares</label>
							</div>
						</li>
						<li>
							<div class="md-radio">
								<input id="sortbyprice-b" type="radio" name="sort" title="Sort by price" onClick="sortTrips('business');">
								<label for="sortbyprice-b">Business Class Fares</label>
							</div>
						</li>
						<li>
							<div class="md-radio">
								<input id="sortbyprice-c" type="radio" name="sort" title="Sort by price" onClick="sortTrips('first');">
								<label for="sortbyprice-c">First Class Fares</label>
							</div>
						</li>
						<li>
							<div class="md-radio">
								<input id="sortbyduration" type="radio" name="sort" title="Sort by duration" onClick="sortTrips('duration');">
								<label for="sortbyduration">Duration</label>
							</div>
						</li>
						<li>
							<div class="md-radio">
								<input id="sortbydeparture" type="radio" name="sort" title="Sort by departure" onClick="sortTrips('departure');">
								<label for="sortbydeparture">Departure</label>
							</div>
						</li>
						<li>
							<div class="md-radio">
								<input id="sortbyarrival" type="radio" name="sort" title="Sort by arrival" onClick="sortTrips('arrival');">
								<label for="sortbyarrival">Arrival</label>
							</div>
						</li>
					</ul>
				</li>
				<li role="presentation" class="dropdown" id="filterAirline">
					<a href="#" class="dropdown-toggle">Airlines <b class="caret"></b></a>
					<ul class="dropdown-menu dropdown-menu-right multifilterwrapper" data-type="checkbox" data-name="airline">
						<li>
							<input type="checkbox" checked id="airline-all" name="airline-all" class="switch-input">
							<label for="airline-all" class="switch-label">All Airlines</label>
						</li>
					</ul>
				</li>
				<li role="presentation" class="dropdown" id="filterStops">
					<a href="#" class="dropdown-toggle">Stops <b class="caret"></b></a>
					<ul class="dropdown-menu dropdown-menu-right">
						<li>
							<div class="md-radio">
								<input id="stops-a" checked class="singlefilter" type="radio" name="stops" value="-1" data-title="Any number of stops" title="Any number of stops">
								<label for="stops-a">Any Number of Stops</label>
							</div>
						</li>
						<li>
							<div class="md-radio">
								<input id="stops-0" class="singlefilter" type="radio" name="stops" value="0" data-title="Nonstop" title="Nonstop flights">
								<label for="stops-0">Nonstop</label>
							</div>
						</li>
						<li>
							<div class="md-radio">
								<input id="stops-1" class="singlefilter" type="radio" name="stops" value="1" data-title="1 Stop" title="Flights with one stop">
								<label for="stops-1">1 Stop</label>
							</div>
						</li>
						<li>
							<div class="md-radio">
								<input id="stops-2" class="singlefilter" type="radio" name="stops" value="2" data-title="2+ Stop" title="Flights with two or more stops">
								<label for="stops-2">2+ Stops</label>
							</div>
						</li>
					</ul>
				</li>
				<li role="presentation" class="dropdown" id="filterFares">
					<a href="#" class="dropdown-toggle">Fare Type <b class="caret"></b></a>
					<ul class="dropdown-menu dropdown-menu-right">
						<li>
							<div class="md-radio">
								<input id="refundable-a" checked class="singlefilter" type="radio" name="refundable" data-element="fares" value="-1" data-title="Any Fare Type" title="Any Fare Type">
								<label for="refundable-a">Any Fare Type</label>
							</div>
						</li>
						<li>
							<div class="md-radio">
								<input id="refundable-0" class="singlefilter" type="radio" name="refundable" data-element="fares" value="0" data-title="0" title="Non Refundable">
								<label for="refundable-0">Non Refundable</label>
							</div>
						</li>
						<li>
							<div class="md-radio">
								<input id="refundable-1" class="singlefilter" type="radio" name="refundable" data-element="fares" value="1" data-title="1" title="Refundable">
								<label for="refundable-1">Refundable</label>
							</div>
						</li>
					</ul>
				</li>
				<li role="presentation" class="dropdown" id="filterDuration">
					<a href="#" class="dropdown-toggle">Trip Length <b class="caret"></b></a>
					<ul class="dropdown-menu dropdown-menu-right range-slider" data-type="checkbox" data-name="duration" data-selector="trip" data-datafield="duration">
						<li class="with-irs">
							<div class="irs-title">Trip Length</div>
							<input type="text" class="js-range-slider" name="duration-range" value="" />
						</li>
					</ul>
				</li>
				<li role="presentation" class="dropdown" id="filterConnecting">
					<a href="#" class="dropdown-toggle">Connecting Airports <b class="caret"></b></a>
					<ul class="dropdown-menu dropdown-menu-right multifilterwrapper range-slider" data-type="checkbox" data-name="connection" data-selector="segment-stopover" data-datafield="minutes">
						<li class="with-irs">
							<div class="irs-title">Layover Duration</div>
							<input type="text" class="js-range-slider" name="layover-range" value="" />
						</li>
						<li>
							<input type="checkbox" checked id="connection-all" name="connection-all" class="switch-input">
							<label for="connection-all" class="switch-label">All Connecting Airports</label>
						</li>
					</ul>
				</li>
				<li role="presentation" class="dropdown" id="resultsCount">
					<a href="#" class="dropdown-toggle"><span>29</span> Results</b></a>
				</li>
				<!---
				<li class="dropdown">
					<a href="#" class="dropdown-toggle" data-toggle="dropdown">Carrier <b class="caret"></b></a>
					<ul class="dropdown-menu">
						<li><a href="#" class="filteroption" data-stops="0" data-title="Single" title="Single Carrier Trips">Single Carrier Trips</a></li>
						<li><a href="#" class="filteroption" data-stops="1" data-title="All" title="Multiple and Single Carrier Trips">Include Multiple Carrier Trips</a></li>
					</ul>
				</li>
			--->
			</ul>
		</div>
	</div>
</div>
