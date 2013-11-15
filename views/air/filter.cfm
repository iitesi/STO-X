<cfsilent>
	<cfparam name="rc.filter" default="">
	<cfparam name="rc.bRefundable" default="0">



	<cfsavecontent variable="filterHeader">
		<cfoutput>
			<script type='text/javascript' src='#application.assetURL#/js/air/filter.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfhtmlhead text="#filterHeader#" />
</cfsilent>

<!--- hide the filter bar with a loading message until the page has fully rendered --->
<div id="filterbarloading" class="alert alert-block">
	<i class="icon-spinner icon-spin"></i> Waiting for all results to display before filtering is active
</div>

<div id="filterbar" class="filter airfilterbar">
	<div class="sixteen columns">
		<div class="sortby pull-left">
			<h4>Sort</h4>
				<div class="navbar">
					<div class="navbar-inner">
						<ul class="nav">
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

			<div class="filterbar">
				<h4>Filter</h4>
				<div class="navbar">
					<div class="navbar-inner">
						<ul class="nav">
							<li><a href="#" class="filterby" id="airlinebtn" title="Click to view/hide filters">Airlines <i class="icon-caret-down"></i></a></li>
							<cfif rc.action NEQ 'air.availability'>
								<li><a href="#" class="filterby" id="classbtn" title="Click to view/hide filters">Class <i class="icon-caret-down"></i></a></li>
								<li><a href="#" class="filterby" id="farebtn" title="Click to view/hide filters">Fares <i class="icon-caret-down"></i></a></li>
							</cfif>
							<li><a href="#" id="nonstopbtn" title="Click to view/hide non-stop flights">Non-stops</a></li>
							<li><a href="#" id="inpolicybtn" title="Click to view/hide in-policy flights">In Policy</a></li>
							<li><a href="#" id="singlecarrierbtn" title="Click to view/hide single carrier flights">Single Carrier</a></li>
						</ul>
					</div>
				</div>
				<div>
					<cfoutput>
						<h4><span id="flightCount">#rc.totalflights# of #rc.totalflights#</span> flights displayed
						 <span class="pull-right">
						 	<span class="spinner"><i class="icon-spinner icon-spin"></i> Filtering flights</span>
						 	<a href="##" class="removefilters"> <i class="icon-refresh"></i> Clear Filters</a>
						 </span>
						</h4>
					</cfoutput>
				</div>

				<!--- new filter well --->
				<div class="well filterselection">
					<div class="row">
						<div class="span7">
							<div class="row">

							<cfoutput>
								<div id="airlines" class="span2">
									<b>Airlines</b>
									<cfif rc.action NEQ 'air.availability'>
										<cfset aCarriers = session.searches[rc.SearchID].stLowFareDetails.aCarriers>
									<cfelse>
										<cfset aCarriers = session.searches[rc.SearchID].stAvailDetails.stCarriers[rc.Group]>
									</cfif>

									<cfloop array="#aCarriers#" index="Carrier" >
										<label class="checkbox" for="Carrier#Carrier#" title="Filter by #application.stAirVendors[carrier].name#"><input id="Carrier#carrier#" name="carrier" type="checkbox" value="#carrier#"> #application.stAirVendors[Carrier].Name#</label>
									</cfloop>

									<cfif Len(rc.filter.getAirlines()) AND session.filterStatus.airlines EQ 0>
										<a href="#buildURL('air.lowfare&SearchID=#rc.SearchID#&airlines=1')#" title="Click to find more airlines" class="airModal" data-modal="... more airlines."><i class="icon-plus-sign"></i> More Airlines</a>
									</cfif>
								</div>

								<cfif rc.action NEQ 'air.availability'>
									<div id="class" class="span3">
										<b>Class</b>
										<!--- Y = economy/coach --->
										<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "Y") OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'YX')>
											<label for="ClassY" class="checkbox" title="Filter by Economy Class"><input type="checkbox" id="ClassY" name="ClassY" value="Y" <cfif structKeyExists( URL, "sCabins" ) AND listFindNoCase( URL.sCabins, "Y" )>checked="checked"</cfif>>Economy<br /> <small>(#session.searches[rc.SearchID].stLowFareDetails.stResults.Y# results)</small></label>
										</cfif>

										<!--- C = business --->
										<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "C")
											AND (session.searches[rc.SearchID].stLowFareDetails.stResults.C NEQ 0
											OR session.filterStatus.cabinSearch.C NEQ 0)>
											<label for="ClassC" class="checkbox" title="Filter by Business Class"><input type="checkbox" id="ClassC" name="ClassC" value="C" <cfif structKeyExists( URL, "sCabins" ) AND listFindNoCase( URL.sCabins, "C" )>checked="checked"</cfif>> Business
											<br /><small>(#session.searches[rc.SearchID].stLowFareDetails.stResults.C# results)</small></label>
										</cfif>

										<!--- F = first class --->
										<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "F")
											AND (session.searches[rc.SearchID].stLowFareDetails.stResults.F NEQ 0
											OR session.filterStatus.cabinSearch.C NEQ 0)>
											<label for="ClassF" class="checkbox" title="Filter by First Class"><input type="checkbox" id="ClassF" name="ClassF" value="F" <cfif structKeyExists( URL, "sCabins" ) AND listFindNoCase( URL.sCabins, "F" )>checked="checked"</cfif>>First
											<br /><small>(#session.searches[rc.SearchID].stLowFareDetails.stResults.F# results)</small></label>
										</cfif>

										<cfif session.filterStatus.cabinSearch.C EQ 0>
											<cfset cabinSearchURL = 'air.lowfare&SearchID=#rc.SearchID#&sCabins=C' />
											<cfif structKeyExists( rc, "bRefundable" ) AND rc.bRefundable EQ 1>
												<cfset cabinSearchURL = cabinSearchURL & "&bRefundable=" & rc.bRefundable />
											</cfif>
											<a href="#buildURL(cabinSearchURL)#" title="Click to find more Business Class fares" class="airModal" data-modal="... more business class fares."><i class="icon-plus-sign"></i> More Business Class</a><br />
										</cfif>
										<cfif session.filterStatus.cabinSearch.F EQ 0>
											<cfset cabinSearchURL = 'air.lowfare&SearchID=#rc.SearchID#&sCabins=F' />
											<cfif structKeyExists( rc, "bRefundable" ) AND rc.bRefundable EQ 1>
												<cfset cabinSearchURL = cabinSearchURL & "&bRefundable=" & rc.bRefundable />
											</cfif>
											<a href="#buildURL(cabinSearchURL)#" title="Click to find more First Class fares" class="airModal" data-modal="... more first class fares."><i class="icon-plus-sign"></i> More First Class</a><br />
										</cfif>
									</div>

									<div id="fares" class="span2">
										<b>Fares</b>
										<!--- 1 = nonrefundable --->
										<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "0")
											OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'X0')>
											<label for="Fare0" class="checkbox" title="Filter by non-refundable fares"><input type="checkbox" id="Fare0" name="Fare0" value="0"> Non Refundable
											<br /><small>(#session.searches[rc.SearchID].stLowFareDetails.stResults[0]# results)</small></label>
										</cfif>

										<!--- 0 = refundable --->
										<cfif (structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "1")
											OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'X1'))
											AND (session.searches[rc.SearchID].stLowFareDetails.stResults.1 NEQ 0
											AND session.filterStatus.refundableSearch NEQ 0)>
											<label for="Fare1" class="checkbox" title="Filter by refundable fares"><input type="checkbox" id="Fare1" name="Fare1" value="1" <cfif structKeyExists( URL, "bRefundable" ) AND URL.bRefundable EQ 1>checked="checked"</cfif>> Refundable
											<br /><small>(#session.searches[rc.SearchID].stLowFareDetails.stResults[1]# results)</small></label>
										</cfif>

										<cfif session.filterStatus.refundableSearch EQ 0>
											<cfset refundableURL = 'air.lowfare&SearchID=#rc.SearchID#&bRefundable=1' />
											<cfif structKeyExists( rc, "sCabins" )>
												<cfset refundableURL = refundableURL & '&sCabins=' & rc.sCabins />
											</cfif>
											<a href="#buildURL(refundableURL)#" title="Click to find more refundable fares" class="airModal" data-modal="... more refundable fares."><i class="icon-plus-sign"></i> More Refundable</a>
										</cfif>
									</div>
								</cfif>
							</cfoutput>
							<input type="hidden" id="NonStops" name="NonStops" value="0">
							<input type="hidden" id="InPolicy" name="InPolicy" value="0">
							<input type="hidden" id="SingleCarrier" name="SingleCarrier" value="0">
							</div>
						</div>
					</div> <!--- row --->
					<br>
					<div>
						<span class="pull-right">
							<button type="button" class="closewell close" title="Close filters"><i class="icon-remove"></i></button>
						</span>
				</div>
				</div> <!--- well filterselection --->
			</div>
		</div><!--- // class=sixteen columns --->
	</div><!--- // class=filter --->


<br><br><br><br><br><br>

<script>
		// Resources
		// http://jsfiddle.net/jrweinb/MQ6VT/
		// http://stackoverflow.com/questions/18095439/jquery-ui-slider-using-time-as-range-not-timeline-js-fixed-width
		// http://marcneuwirth.com/blog/2010/02/21/using-a-jquery-ui-slider-to-select-a-time-range/
		// http://marcneuwirth.com/blog/2011/05/22/revisiting-the-jquery-ui-time-slider/
		// http://stackoverflow.com/questions/1425913/show-hide-div-based-on-value-of-jquery-ui-slider
		// http://stackoverflow.com/questions/10213678/jquery-ui-slider-ajax-result
		// using data-attributes - maybe give each badge a data-takeoff data-landing attribute?
		// http://stackoverflow.com/questions/15582349/modify-this-function-to-show-hide-by-data-attributes-instead-of-by-class

$(function() {
	$( "#slider-range1" ).slider({
		range: true,
		min: 0,
		max: 1439,
		step: 5,
		slide: function( event, ui ) {
			var hours1 = Math.floor(ui.value / 60);
			var minutes1 = ui.value - (hours1 * 60);
			if(hours1.length == 1) hours1 = '0' + hours1;
			if(minutes1.length == 1) minutes1 = '0' + minutes1;

				$( "#amount1" ).html( "Wed " + hours1+':'+minutes1 );
			}
	});

$( "#slider-range2" ).slider({
		range: true,
		min: 0,
		max: 1435,
		step: 5,
		slide: function( event, ui ) {
			var hours2 = Math.floor(ui.value / 60);
			var minutes2 = ui.value - (hours2 * 60);
			if(hours2.length == 1) hours2 = '0' + hours2;
			if(minutes2.length == 1) minutes2 = '0' + minutes2;

				$( "#amount2" ).html( "Sat " + hours2+':'+minutes2 );
			}
	});


	$( "#amount1" ).html( "Wed " + $( "#slider-range" ).slider( "values", 0 ) + " - Thur" + $( "#slider-range" ).slider( "values", 1 ) );
	$( "#amount2" ).html( "Wed " + $( "#slider-range" ).slider( "values", 0 ) + " - Thur" + $( "#slider-range" ).slider( "values", 1 ) );
});
</script>


<cfoutput>
	<b>Times</b>
<div class="row">

					<div id="airlines" class="span3">

						<p>
							<label for="amount1">Take-off #application.stAirports[rc.filter.getArrivalCity()].city#</label>
							<span id="amount1"></span>
						</p>
						<div id="slider-range1"></div>
					</div>

					<div id="airlines" class="span3 offset1">
						another slider goes here

					</div>


					</div>
</div>
</cfoutput>

<br>

<!-- Modal -->
<div id="myModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-header">
		<h4><i class="icon-spinner icon-spin"></i> One moment, we're searching for...</h4>
	</div>
	<div id="myModalBody" class="modal-body"></div>
</div>

<div class="clearfix"></div>