<cfsilent>
	<cfparam name="rc.filter" default="">
	<cfparam name="rc.bRefundable" default="0">

	<cfsavecontent variable="filterHeader">
		<cfoutput>
			<script type='text/javascript' src='#application.assetURL#/js/air/timeslider.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfhtmlhead text="#filterHeader#" />
</cfsilent>

<!--- hide the filter bar with a loading message until the page has fully rendered --->
<div id="filterbarloading" class="alert alert-block">
	<i class="fa fa-spinner fa-spin"></i> Waiting for all results to display before filtering is active
</div>

<div id="filterbar" class="filter airfilterbar container">
	 <div class="row">
		<div class="col-xs-7 sortby respFilter">

				<div class="navbar navbar-default">
					<div class="container-fluid">
						<div class="navbar-header">
						  <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#sort-navbar-collapse-1" aria-expanded="false">
							<span class="sr-only">Toggle navigation</span>
							<span class="glyphicon glyphicon-sort"></span>


						  </button>
						  <a class="navbar-brand" href="#">Sort</a>
						</div>
						<div class="collapse navbar-collapse" id="sort-navbar-collapse-1">
						<ul class="nav navbar-nav">
							<cfif rc.action NEQ 'air.availability'>
								<li class="dropdown">
									<a href="#" class="dropdown-toggle" data-toggle="dropdown">Price <b class="caret"></b></a>
									<ul class="dropdown-menu">
										<li><a href="#" id="sortbyprice" title="Sort by price">Price</a></li>
										<li><a href="#" id="sortbyprice1bag" title="Sort by price with 1 bag">Price + 1 Bag</a></li>
										<li><a href="#" id="sortbyprice2bag" title="Sort by price with 2 bags">Price + 2 Bags</a></li>
									</ul>
								</li>
							</cfif>
							<li><a href="#" id="sortbyduration" title="Sort by duration">Duration</a></li>
							<li><a href="#" id="sortbydeparture" title="Sort by departure">Departure</a></li>
							<li><a href="#" id="sortbyarrival" title="Sort by arrival">Arrival</a></li>
						</ul>
					</div>
					</div>
				</div>
			</div>
			<div class="col-xs-5 viewToggle">

					 <div class="pull-right">

						 <div class="navbar-text navbar-left">
							 <div class="btn-group" role="group" >
								  <button type="button" class="btn btn-default showGridView" data-view="grid"><i class="fa fa-th" aria-hidden="true"></i><span class="hidden-xs">&nbsp;&nbsp;Grid View</span></button>
								  <button type="button" class="btn btn-default showListView" data-view="list"><i class="fa fa-list" aria-hidden="true"></i><span class="hidden-xs">&nbsp;&nbsp;List View</span></button>
								</div>
						 </div>

				</div>
			</div>


		<div class="col-xs-12 filterbar respFilter">

				<div class="navbar navbar-default">
					<div class="container-fluid">
						<div class="navbar-header">
							  <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#filter-navbar-collapse-1" aria-expanded="false">
								<span class="sr-only">Toggle navigation</span>
								<span class="glyphicon glyphicon-filter"></span>


							  </button>
							  <a class="navbar-brand" href="#">Filter</a>
							</div>
						<div class="collapse navbar-collapse" id="filter-navbar-collapse-1">
						<ul class="nav navbar-nav">
							<li><a href="#" class="filterby" id="airlinebtn" title="Click to view/hide filters">Airlines <b class="caret"></b></a></li>
							<cfif rc.action NEQ 'air.availability'>
								<li><a href="#" class="filterby" id="classbtn" title="Click to view/hide filters">Class <b class="caret"></b></a></li>
								<li><a href="#" class="filterby" id="farebtn" title="Click to view/hide filters">Fares <b class="caret"></b></a></li>
							</cfif>

							<!--- 2:03 PM Wednesday, April 09, 2014 - Jim Priest - priest@thecrumb.com
							only show sliders for one-way and round-trip
							multi-city is going to take a re-write of the badge/filter/slider code
							to accommodate all the permutations that would be possible with multi-city --->
							<cfif rc.filter.getAirType() EQ "OW" OR rc.filter.getAirType() EQ "RT">
								<li><a href="#" class="filterbytime" id="timebtn" title="Click to view/hide time filters">Time</a></li>
							</cfif>
							<!--- <li><a href="#" class="filterbyflight" id="flightbtn" title="Click to view/hide flight number filters">Flight Number</a></li> --->
							<li class="dropdown">
								<a href="#" id="stopdropdown" class="dropdown-toggle" data-toggle="dropdown">Stops <b class="caret"></b></a>
								<ul class="dropdown-menu">
									<li><a href="#" id="nonstopbtn" data-stops="0" data-title="Non-stop" title="Non-stop flights">Non-stop</a></li>
									<li><a href="#" id="nonstopbtn1" data-stops="1" data-title="1 Stop" title="Flights with one stop">1 Stop</a></li>
									<li><a href="#" id="nonstopbtn2" data-stops="2" data-title="2+ Stops" title="Flights with two or more stops">2+ Stops</a></li>
								</ul>
							</li>
							<li><a href="#" id="inpolicybtn" title="Click to view/hide in-policy flights">In Policy</a></li>
							<li><a href="#" id="singlecarrierbtn" title="Click to view/hide single carrier flights">1 Carrier</a></li>
						</ul>
						<cfoutput>
						<ul class="nav navbar-nav navbar-right">
							<li><p class="navbar-text filter"><span id="flightCount">#rc.totalflights#</span> of <span id="flightCount2">#rc.totalflights#</span> flights</p></li>
							<li><span class="spinner"><i class="fa fa-spinner fa-spin"></i> Filtering flights</span>
							<a href="##" class="removefilters"> <i class="fa fa-refresh"></i><span class="hideFirst"> Clear Filters</span></a></li>
						</ul>
						</cfoutput>
					</div>
					</div>
				</div>


				<!--- filter well for airline/class/fares --->
				<div id="filterwell" class="well filterselection">
							<cfoutput>
								<div class="filtergroup" id="airlines" >

									<cfif rc.action NEQ 'air.availability'>
										<cfset aCarriers = session.searches[rc.SearchID].stLowFareDetails.aCarriers>
									<cfelse>
										<cfset aCarriers = session.searches[rc.SearchID].stAvailDetails.stCarriers[rc.Group]>
									</cfif>

									<cfloop array="#aCarriers#" index="Carrier" >
										<div class="col-lg-3 col-md-4 col-sm-6 col-xs-12">
											<label class="checkbox" for="Carrier#Carrier#" title="Filter by #application.stAirVendors[carrier].name#"><input id="Carrier#carrier#" name="carrier" type="checkbox" value="#carrier#"> #application.stAirVendors[Carrier].Name#</label>
										</div>
									</cfloop>

									<cfif Len(rc.filter.getAirlines()) AND session.filterStatus.airlines EQ 0>
										<div class="col-lg-3 col-md-4 col-sm-6 col-xs-12">
											<a href="#buildURL('air.lowfare&SearchID=#rc.SearchID#&airlines=1')#" title="Click to find more airlines" class="airModal" data-modal="... more airlines."><i class="fa fa-plus"></i> More Airlines</a>
										</div>
									</cfif>

								</div>

								<cfif rc.action NEQ 'air.availability'>
									<div class="filtergroup"  id="class" >

										<!--- Y = economy/coach --->
										<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "Y") OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'YX')>
											<div class="col-lg-3 col-md-4 col-sm-6 col-xs-12">
												<label for="ClassY" class="checkbox" title="Filter by Economy Class"><input type="checkbox" id="ClassY" name="ClassY" value="Y" <cfif structKeyExists( URL, "sCabins" ) AND listFindNoCase( URL.sCabins, "Y" )>checked="checked"</cfif>>Economy<br /> <small>(#session.searches[rc.SearchID].stLowFareDetails.stResults.Y# results)</small></label>
											</div>
										</cfif>

										<!--- C = business --->
										<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "C")
											AND (session.searches[rc.SearchID].stLowFareDetails.stResults.C NEQ 0
											OR session.filterStatus.cabinSearch.C NEQ 0)>
											<div class="col-lg-3 col-md-4 col-sm-6 col-xs-12">
												<label for="ClassC" class="checkbox" title="Filter by Business Class"><input type="checkbox" id="ClassC" name="ClassC" value="C" <cfif structKeyExists( URL, "sCabins" ) AND listFindNoCase( URL.sCabins, "C" )>checked="checked"</cfif>> Business
												<br /><small>(#session.searches[rc.SearchID].stLowFareDetails.stResults.C# results)</small></label>
											</div>
										</cfif>

										<!--- F = first class --->
										<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "F")
											AND (session.searches[rc.SearchID].stLowFareDetails.stResults.F NEQ 0
											OR session.filterStatus.cabinSearch.C NEQ 0)>
											<div class="col-lg-3 col-md-4 col-sm-6 col-xs-12">
												<label for="ClassF" class="checkbox" title="Filter by First Class"><input type="checkbox" id="ClassF" name="ClassF" value="F" <cfif structKeyExists( URL, "sCabins" ) AND listFindNoCase( URL.sCabins, "F" )>checked="checked"</cfif>>First
												<br /><small>(#session.searches[rc.SearchID].stLowFareDetails.stResults.F# results)</small></label>
											</div>
										</cfif>

										<cfif session.filterStatus.cabinSearch.C EQ 0>
											<cfset cabinSearchURL = 'air.lowfare&SearchID=#rc.SearchID#&sCabins=C' />
											<cfif structKeyExists( rc, "bRefundable" ) AND rc.bRefundable EQ 1>
												<cfset cabinSearchURL = cabinSearchURL & "&bRefundable=" & rc.bRefundable />
											</cfif>
											<div class="col-lg-3 col-md-4 col-sm-6 col-xs-12">
												<a href="#buildURL(cabinSearchURL)#" title="Click to find more Business Class fares" class="airModal" data-modal="... more business class fares."><i class="fa fa-plus"></i> More Business Class</a><br />
											</div>
										</cfif>
										<cfif session.filterStatus.cabinSearch.F EQ 0>
											<cfset cabinSearchURL = 'air.lowfare&SearchID=#rc.SearchID#&sCabins=F' />
											<cfif structKeyExists( rc, "bRefundable" ) AND rc.bRefundable EQ 1>
												<cfset cabinSearchURL = cabinSearchURL & "&bRefundable=" & rc.bRefundable />
											</cfif>
											<div class="col-lg-3 col-md-4 col-sm-6 col-xs-12">
												<a href="#buildURL(cabinSearchURL)#" title="Click to find more First Class fares" class="airModal" data-modal="... more first class fares."><i class="fa fa-plus"></i> More First Class</a><br />
											</div>
										</cfif>
									</div>

									<div class="filtergroup"  id="fares">

										<!--- 1 = nonrefundable --->
										<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "0")
											OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'X0')>
											<div class="col-lg-3 col-md-4 col-sm-6 col-xs-12">
												<label for="Fare0" class="checkbox" title="Filter by non-refundable fares"><input type="checkbox" id="Fare0" name="Fare0" value="0"> Non Refundable
												<br /><small>(#session.searches[rc.SearchID].stLowFareDetails.stResults[0]# results)</small></label>
											</div>
										</cfif>

										<!--- 0 = refundable --->
										<cfif (structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "1")
											OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'X1'))
											AND (session.searches[rc.SearchID].stLowFareDetails.stResults.1 NEQ 0
											AND session.filterStatus.refundableSearch NEQ 0)>
											<div class="col-lg-3 col-md-4 col-sm-6 col-xs-12">
												<label for="Fare1" class="checkbox" title="Filter by refundable fares"><input type="checkbox" id="Fare1" name="Fare1" value="1" <cfif structKeyExists( URL, "bRefundable" ) AND URL.bRefundable EQ 1>checked="checked"</cfif>> Refundable
												<br /><small>(#session.searches[rc.SearchID].stLowFareDetails.stResults[1]# results)</small></label>
											</div>
										</cfif>

										<cfif session.filterStatus.refundableSearch EQ 0>
											<cfset refundableURL = 'air.lowfare&SearchID=#rc.SearchID#&bRefundable=1' />
											<cfif structKeyExists( rc, "sCabins" )>
												<cfset refundableURL = refundableURL & '&sCabins=' & rc.sCabins />
											</cfif>
											<div class="col-lg-3 col-md-4 col-sm-6 col-xs-12">
												<a href="#buildURL(refundableURL)#" title="Click to find more refundable fares" class="airModal" data-modal="... more refundable fares."><i class="fa fa-plus"></i> More Refundable</a>
											</div>
										</cfif>
									</div>
								</cfif>
							</cfoutput>

							<input type="hidden" id="NonStops" name="NonStops" value="">
							<input type="hidden" id="InPolicy" name="InPolicy" value="0">
							<input type="hidden" id="SingleCarrier" name="SingleCarrier" value="0">

					<div class="clearfix"></div>
					<div>
						<span class="pull-right">
							<button type="button" class="closefilterwell close" title="Close filters"><i class="fa fa-times"></i></button>
						</span>
					</div>
					<div class="clearfix"></div>
				</div> <!--- // well filterselection --->
			</div> <!--- // filterbar --->

			<!--- time sliders --->
			<div class="clearfix"><!--- prevent filterbar from overlapping time filters ---></div>
			<div id="sliderwell" class="well filtertimeselection">
				<div>
					<b>Times</b>
					<button type="button" class="pull-right closesliderwell close" title="Close filters"><i class="fa fa-times"></i></button>
				</div>

				<!--- 11:37 AM Thursday, December 05, 2013 - Jim Priest - jpriest@shortstravel.com
				All the templates need to be seriously refactored here. Using row-fluid here will make
				the sliders smaller as the screen shrinks. Ideally they would stack vertically
				but with skeleton+bootstrap+jqueryui mess something is overriding that --->



						<cfoutput>
							<cfswitch expression="#rc.filter.getAirType()#">
								<cfcase value="RT">
									<!-- SLIDERS -->
									<div id="sliders">
										<div class="row">
											<div class="col-sm-6 col-xs-12">
												<h3>#DateFormat(rc.filter.getDepartDateTime(), "mmmm dd")# :: #rc.filter.getDepartCity()# - #rc.filter.getArrivalCity()#</h3>
												<div class="slider departure-slider">
													<p>Depart #application.stAirports[rc.filter.getDepartCity()].city# <br /><span class="takeoff-time0"></span> - <span class="takeoff-time1"></span></p>
													<div class="takeoff-range0"></div>
												</div>
												<div class="slider arrival-slider">
													<p>Arrive #application.stAirports[rc.filter.getArrivalCity()].city# <br /><span class="landing-time0"></span> - <span class="landing-time1"></span></p>
													<div class="landing-range0"></div>
												</div>
											</div>
											<div class="col-sm-6 col-xs-12">
												<h3>#DateFormat(rc.filter.getArrivalDateTime(), "mmmm dd")# :: #rc.filter.getArrivalCity()# - #rc.filter.getDepartCity()#</h3>
												<div class="slider departure-slider">
													<p>Depart #application.stAirports[rc.filter.getArrivalCity()].city# <br /><span class="takeoff-time2"></span> - <span class="takeoff-time3"></span></p>
													<div class="takeoff-range1"></div>
												</div>
												<div class="slider arrival-slider">
													<p>Arrive #application.stAirports[rc.filter.getDepartCity()].city# <br /><span class="landing-time2"></span> - <span class="landing-time3"></span></p>
													<div class="landing-range1"></div>
												</div>
											</div>

										</div>
									</div>
								</cfcase>

<!--- ONE WAY --->
								<cfcase value="OW">
									<!-- SLIDERS -->
									<div id="sliders">
											<h3>#DateFormat(rc.filter.getDepartDateTime(), "mmmm d")# :: #rc.filter.getDepartCity()# - #rc.filter.getArrivalCity()#</h3>
											<div class="slider departure-slider">
												<p>Depart #application.stAirports[rc.filter.getDepartCity()].city# <br /><span class="takeoff-time0"></span> - <span class="takeoff-time1"></span></p>
												<div class="takeoff-range0"></div>
											</div>
											<div class="slider arrival-slider">
												<p>Arrive #application.stAirports[rc.filter.getArrivalCity()].city# <br /><span class="landing-time0"></span> - <span class="landing-time1"></span></p>
												<div class="landing-range0"></div>
											</div>
										</div>

								</cfcase>
							</cfswitch>
						</cfoutput>

				<div class="clearfix"><!--- prevent badges from overlapping filters ---></div>
			</div> <!--- // filtertimeselection --->

			<!--- flight number slider --->
			<!--- <div class="clearfix"><!--- prevent filterbar from overlapping time filters ---></div>
			<div id="sliderwell" class="well filterflightselection">
				<div>
					<b>Flight Number</b>
					<button type="button" class="pull-right closesliderwell close" title="Close filters"><i class="fa fa-times"></i></button> --->
					        <!--- <div class="well" ng-show="filtersVisible.vendorName">
					            <div class="row">
					                <div class="span4">
					                    <form class="form-inline">
					                        <input type="text" ng-model="propertyNameFilterValue"> <button ng-click="filterHotels()" class="btn btn-primary">Search</button>
					                    </form>
					                </div>
					                <span class="pull-right">
					                    <button type="button" class="closewell close" ng-click="filtersVisible.vendorName=false" title="Close filters"><i class="fa fa-time"></i></button>
					                </span>
					             </div>
					        </div> --->

				<!--- </div>
			</div> --->

		</div> <!-- // row --->
	</div><!--- // filter --->


<!-- Modal -->
<div id="myModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-header">
		<h4><i class="fa fa-spinner fa-spin"></i> One moment, we're searching for...</h4>
	</div>
	<div id="myModalBody" class="modal-body"></div>
</div>

<div class="clearfix"></div>
