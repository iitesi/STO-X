<style type="text/css">
.navbar-default {
    background-color: #FFFFFF;
    background-image: none;
    box-shadow: none;
}
</style>

<div id="filterbar" class="container" style="font-size:12px">
	<div class="row">
		<div class="panel">
			<div class="navbar navbar-default">
				<div class="container-fluid">
					<div class="navbar-header">
						<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#filter-navbar-collapse-1" aria-expanded="false">
							<span class="sr-only">Toggle navigation</span>
							<span class="glyphicon glyphicon-filter"></span>
						</button>
					</div>
					<ul class="nav navbar-nav">
						<li class="dropdown">
							<a href="#" class="dropdown-toggle" data-toggle="dropdown">Sort <b class="caret"></b></a>
							<ul class="dropdown-menu">
								<li><a href="#" id="sortbyprice" title="Sort by price" onClick="sortTrips('economy');">Economy Class Fares</a></li>
								<li><a href="#" id="sortbyprice" title="Sort by price" onClick="sortTrips('business');">Business Class Fares</a></li>
								<li><a href="#" id="sortbyprice" title="Sort by price" onClick="sortTrips('first');">First Class Fares</a></li>
								<li><a href="#" id="sortbyduration" title="Sort by duration" onClick="sortTrips('duration');">Duration</a></li>
								<li><a href="#" id="sortbydeparture" title="Sort by departure" onClick="sortTrips('departure');">Departure</a></li>
								<li><a href="#" id="sortbyarrival" title="Sort by arrival" onClick="sortTrips('arrival');">Arrival</a></li>
							</ul>
						</li>
						<li class="dropdown">
							<a href="#" class="dropdown-toggle" data-toggle="dropdown">Stops <b class="caret"></b></a>
							<ul class="dropdown-menu">
								<li><a href="#" class="filteroption" data-stops="0" data-title="Nonstop" title="Nonstop flights">Nonstop</a></li>
								<li><a href="#" class="filteroption" data-stops="1" data-title="1 Stop" title="Flights with one stop">1 Stop</a></li>
								<li><a href="#" class="filteroption" data-stops="2" data-title="2+ Stops" title="Flights with two or more stops">2+ Stops</a></li>
							</ul>
						</li>
						<li class="dropdown">
							<a href="#" class="dropdown-toggle" data-toggle="dropdown">Fare Type <b class="caret"></b></a>
							<ul class="dropdown-menu">
								<li><a href="#" data-refundable="0" data-title="0" title="Non Refundable" onclick="refundable(0)">Non Refundable</a></li>
								<li><a href="#" data-refundable="1" data-title="1" title="Refundable" onclick="refundable(1)">Refundable</a></li>
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
</div>