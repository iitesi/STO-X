<style type="text/css">
	.navbar-default {
		background-color: #FFFFFF;
		background-image: none;
		box-shadow: none;
	}
</style>

<div id="filterbar">
	<div class="navbar">
		<div class="filterbar-wrapper">
			<div class="navbar-header">
				<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#filter-navbar-collapse-1" aria-expanded="false">
					<span class="visible-xs">Filter Flights</span>
					<span class="glyphicon glyphicon-filter"></span>
				</button>
			</div>
			<div class = "collapse navbar-collapse" id="filter-navbar-collapse-1">
				<ul class="nav nav-pills">
					<li role="presentation" class="dropdown" id="resultsCount">
						<a href="#" class="dropdown-toggle"><span>29</span> Results</b></a>
					</li>
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
						<a href="#" class="dropdown-toggle" data-dflt="Airlines">Airlines <b class="caret"></b></a>
						<ul class="dropdown-menu dropdown-menu-right multifilterwrapper" data-type="checkbox" data-name="airline">
							<li>
								<input type="checkbox" checked id="airline-all" name="airline-all" class="switch-input">
								<label for="airline-all" class="switch-label">All Airlines</label>
							</li>
						</ul>
					</li>
					<li role="presentation" class="dropdown" id="filterStops">
						<a href="#" class="dropdown-toggle" data-dflt="Stops">Stops <b class="caret"></b></a>
						<ul class="dropdown-menu dropdown-menu-right singlefilterwrapper">
							<li>
								<div class="md-radio">
									<input id="stops-a" checked class="singlefilter" type="radio" name="stops" value="-1" data-title="Any number of stops" title="Any number of stops">
									<label for="stops-a">Any Number of Stops</label>
								</div>
							</li>
							<li>
								<div class="md-radio">
									<input id="stops-0" class="singlefilter" type="radio" name="stops" value="0" data-title="Nonstop" title="Nonstop">
									<label for="stops-0">Nonstop</label>
								</div>
							</li>
							<li>
								<div class="md-radio">
									<input id="stops-1" class="singlefilter" type="radio" name="stops" value="1" data-title="1 Stop" title="1 Stop">
									<label for="stops-1">1 Stop</label>
								</div>
							</li>
							<li>
								<div class="md-radio">
									<input id="stops-2" class="singlefilter" type="radio" name="stops" value="2" data-title="2+ Stop" title="2+ Stops">
									<label for="stops-2">2+ Stops</label>
								</div>
							</li>
						</ul>
					</li>
					<li role="presentation" class="dropdown" id="filterTimes">
						<a href="#" class="dropdown-toggle" data-dflt="Times">Times <b class="caret"></b></a>
						<ul class="dropdown-menu dropdown-menu-right">
							<li class="with-irs time-slider" data-name="departure" data-selector="trip" data-datafield="departure">
								<div class="irs-title">
									<span class="mdi mdi-airplane-takeoff"></span> Departure Time
								</div>
								<input type="text" class="js-range-slider" name="departure-range" value="" />
							</li>
							<li class="with-irs time-slider" data-name="arrival" data-selector="trip" data-datafield="arrival">
								<div class="irs-title">
									<span class="mdi mdi-airplane-landing"></span>Arrival time
								</div>
								<input type="text" class="js-range-slider" name="arrival-range" value="" />
							</li>
						</ul>
					</li>
					<li role="presentation" class="dropdown" id="filterConnecting">
						<a href="#" class="dropdown-toggle" data-dflt="Connecting Airports">Connecting Airports <b class="caret"></b></a>
						<ul class="dropdown-menu dropdown-menu-right multifilterwrapper range-slider" data-type="checkbox" data-name="connection" data-selector="segment-stopover" data-datafield="minutes">
							<li class="with-irs">
								<div class="irs-title">Layover Duration</div>
								<input type="text" class="js-range-slider" id="layover-range-slider" name="layover-range" value="" />
							</li>
							<li>
								<input type="checkbox" checked id="connection-all" name="connection-all" class="switch-input">
								<label for="connection-all" class="switch-label">All Connecting Airports</label>
							</li>
						</ul>
					</li>
					<li role="presentation" class="dropdown" id="filterFlightNumber">
						<div class="form-field form-field__filter">
							<div class="form-field__control__filter">
								<label for="flight_number" class="form-field__label__filter">Flight #</label>
								<input id="flight_number" name="flight_number" type="text" class="form-field__input__filter" />
							</div>
						</div>
					</li>

					<li role="presentation" class="dropdown" id="filterMore">
						<a href="#" class="dropdown-toggle" data-dflt="More">More <b class="caret"></b></a>
						<ul class="dropdown-menu dropdown-menu-right singlefilterwrapper range-slider" data-type="checkbox" data-name="duration" data-selector="trip" data-datafield="duration">
							<li class="with-irs">
								<div class="irs-title">Trip Length</div>
								<input type="text" class="js-range-slider" id="duration-range-slider" name="duration-range" value="" />
							</li>	
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
</div>
