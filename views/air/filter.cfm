<!---
AIR CODES
-----------------------
1 = refundable
0 = non refundable
-----------------------
Y = economy
C = business
F = first
-----------------------
(X) = not selected
 --->

<cfsilent>
	<cfparam name="rc.filter" default="">
	<cfparam name="rc.bRefundable" default="0">
	<cfsavecontent variable="filterHeader">
		<script type='text/javascript' src='assets/js/air/filter.js'></script>
	</cfsavecontent>
	<cfhtmlhead text="#filterHeader#" />
</cfsilent>

<div id="filtermsg" class="alert">
	<button type="button" class="close">&times;</button>
	<span></span>
</div>

<div id="filterbar" class="filter">
	<div class="row">
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
										<li><a href="#" id="sortbyprice1bag"title="Sort by price with 1 bag">Price + 1 Bag</a></li>
										<li><a href="#" id="sortbyprice2bag"title="Sort by price with 2 bags">Price + 2 Bags</a></li>
									</ul>
								<cfelse>
									<li class="disabled"><a title="Sorting by price disabled.">Price</a></li>
								</cfif>
							<li><a href="#" id="sortbyduration" title="Sort by duration">Duration</a></li>
							<li><a href="#" id="sortbydeparture" title="Sort by departure">Departure</a></li>
							<li><a href="#" id="sortbyarrival" title="Sort by arrival">Arrival</a></li>
						</ul>
					</div>
				</div>
			</div>

			<div class="pull-right">
				<h4>Filter</h4>
				<div class="navbar">
					<div class="navbar-inner">
						<ul class="nav">
							<li><a href="#" class="filterby" id="airlinebtn" title="Click to view/hide filters">Airlines <i class="icon-caret-down"></i></a></li>
							<li><a href="#" class="filterby" id="classbtn" title="Click to view/hide filters">Class <i class="icon-caret-down"></i></a></li>
							<li><a href="#" class="filterby" id="farebtn" title="Click to view/hide filters">Fares <i class="icon-caret-down"></i></a></li>
							<li><a href="#" id="nonstopbtn" title="Click to view/hide non-stop flights">Non-stops</a></li>
							<li><a href="#" id="inpolicybtn" title="Click to view/hide in-policy flights">In Policy</a></li>
							<li><a href="#" id="singlecarrierbtn" title="Click to view/hide single carrier flights">Single Carrier</a></li>
						</ul>
					</div>
				</div>
				<div>
					<cfoutput>
						<h4>XXX of #StructCount(session.searches[rc.SearchID].stTrips)# flights displayed <a href="##" id="removefilters" class="pull-right"><i class="icon-refresh"></i> Clear Filters</a></h4>
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
								</div>

								<div id="class" class="span2">
									<b>Class</b>

									<!--- Y = economy/coach --->
									<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "Y") OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'YX')>
										<label for="ClassY" class="checkbox" title="Filter by Economy Class"><input type="checkbox" id="ClassY" name="ClassY" value="Y" <!--- <cfif NOT structKeyExists(rc, 'sCabins') OR rc.sCabins EQ 'Y'>checked</cfif> --->>Economy<br/ > <small>(#session.searches[rc.SearchID].stLowFareDetails.stResults.Y# results)</small></label>
									</cfif>

									<!--- C = business --->
									<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "C")>
										<label for="ClassC" class="checkbox" title="Filter by Business Class"><input type="checkbox" id="ClassC" name="ClassC" value="C" <!--- <cfif NOT structKeyExists(rc, 'sCabins') OR rc.sCabins EQ 'C'>checked</cfif> --->>Business<br /> <small>(#session.searches[rc.SearchID].stLowFareDetails.stResults.C# results)</small></label>
									<cfelseif StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'CX')>
										<label for="ClassC" class="checkbox" title="No results"><input type="checkbox" id="ClassC" name="ClassC" value="C" disabled>Business (no results)</label>
									</cfif>
									<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'CX')>
										<a href="?action=air.lowfare&SearchID=#rc.SearchID#&sCabins=C" title="Find Business Class Fares"><i class="icon-search"></i> Business Class</a><br />
									</cfif>

									<!--- F = first class --->
									<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "F")>
										<label for="ClassF" class="checkbox" title="Filter by First Class"><input type="checkbox" id="ClassF" name="ClassF" value="F">First
										<br /><small>(#session.searches[rc.SearchID].stLowFareDetails.stResults.F# results)</small></label>
									</cfif>
									<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'FX')>
										<a href="?action=air.lowfare&SearchID=#rc.SearchID#&sCabins=F" title="Find First Class Fares"><i class="icon-search"></i> First Class</a><br />
									</cfif>
								</div>

								<div id="fares" class="span3">
									<b>Fares</b>

									<!--- 1 = nonrefundable --->
									<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "0") OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'X0')>
										<label for="Fare0" class="checkbox" title="Filter by non-refundable fares"><input type="checkbox" id="Fare0" name="Fare0" value="0">Non Refundable
										<br /><small>(#session.searches[rc.SearchID].stLowFareDetails.stResults[0]# results)</small></label>
									</cfif>
									<!--- 0 = refundable --->
									<cfif ( structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "1")
										OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'X1')
										) AND rc.bRefundable EQ 1>
										<label for="Fare1" class="checkbox" title="Filter by refundable fares"><input type="checkbox" id="Fare1" name="Fare1" value="1" <cfif rc.bRefundable EQ 1>checked</cfif>>Refundable
										<br /><small>(#session.searches[rc.SearchID].stLowFareDetails.stResults[1]# results)</small></label>
									<cfelse>
										<a href="?action=air.lowfare&SearchID=#rc.SearchID#&bRefundable=1" title="Find Refundable Fares"><i class="icon-search"></i> Refundable</a><br />
									</cfif>
								</div>
							</cfoutput>
							<input type="hidden" id="NonStops" name="NonStops" value="0">
							<input type="hidden" id="InPolicy" name="InPolicy" value="0">
							<input type="hidden" id="SingleCarrier" name="SingleCarrier" value="0">
							</div>
						</div>
					</div> <!--- row --->

					<button type="button" class="closefilterwell close pull-right" title="Close filters"><i class="icon-remove"></i></button>
				</div> <!--- well filterselection --->
			</div>
		</div><!-- // class=sixteen columns -->
	</div><!-- // class=row -->
</div><!-- // class=filter -->