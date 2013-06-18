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
									</li>

								</ul>
							</div>
						</div>
					</div>

			<div class="pull-right">
					<!---
						TODO: figure out how to 'reset' filters globally...
						4:40 PM Monday, June 10, 2013 - Jim Priest - jpriest@shortstravel.com
					--->
				<div>
					<cfoutput>
						<h4>Filters: 123 of #StructCount(session.searches[rc.SearchID].stTrips)# flights displayed <a href="##" id="removefilters" class="pull-right"><i class="icon-refresh"></i> Remove Filters</a></h4>
					</cfoutput>

				</div>
					<div class="navbar filterby">
						<div class="navbar-inner">
							<ul class="nav">
								<li><a href="#" id="airlinebtn" title="Click to view/hide filters">Airlines</a></li>
								<li><a href="#" id="classbtn" title="Click to view/hide filters">Class</a></li>
								<li><a href="#" id="farebtn" title="Click to view/hide filters">Fares</a></li>
								<li><a href="#" id="nonstopbtn" title="Click to view/hide filters">Non-stops</a></li>
								<li><a href="#" id="inpolicybtn" title="Click to view/hide filters">In Policy</a></li>
								<li><a href="#" id="singlecarrierbtn" title="Click to view/hide filters">Single Carrier</a></li>
							</ul>
						</div>
					</div>
			</div>

			<div class="clearfix"></div>

			<div class="well filterselection">
			<div class="row">
			<div class="span12">
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
						<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "Y") OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'YX')>
							<label for="ClassY" class="checkbox" title="Filter by Economy Class"><input type="checkbox" id="ClassY" name="ClassY" value="Y" <!--- <cfif NOT structKeyExists(rc, 'sCabins') OR rc.sCabins EQ 'Y'>checked</cfif> --->>Economy<br/ > <small>(#session.searches[rc.SearchID].stLowFareDetails.stResults.Y# results)</small></label>
						</cfif>
						<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "C")>
							<label for="ClassC" class="checkbox" title="Filter by Business Class"><input type="checkbox" id="ClassC" name="ClassC" value="C" <!--- <cfif NOT structKeyExists(rc, 'sCabins') OR rc.sCabins EQ 'C'>checked</cfif> --->>Business<br /> <small>(#session.searches[rc.SearchID].stLowFareDetails.stResults.C# results)</small></label>
						<cfelseif StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'CX')>
							<label for="ClassC" class="checkbox" title="No results"><input type="checkbox" id="ClassC" name="ClassC" value="C" disabled>Business (no results)</label>
						</cfif>
						<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'CX')>
							<a href="?action=air.lowfare&SearchID=#rc.SearchID#&sCabins=C" title="Find Business Class Fares"><i class="icon-search"></i> Business Class</a><br />
						</cfif>
						<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "F")>
							<label for="ClassF" class="checkbox" title="Filter by First Class"><input type="checkbox" id="ClassF" name="ClassF" value="F" <!--- <cfif NOT structKeyExists(rc, 'sCabins') OR rc.sCabins EQ 'F'>checked</cfif> --->>First<br /><small>(#session.searches[rc.SearchID].stLowFareDetails.stResults.F# results)</small></label>
						<cfelseif StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'FX')>
							<label for="ClassF" class="checkbox" title="No results"><input type="checkbox" id="ClassF" name="ClassF" value="F" disabled>First (no results)</label>
						</cfif>
						<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'FX')>
							<a href="?action=air.lowfare&SearchID=#rc.SearchID#&sCabins=F" title="Find First Class Fares"><i class="icon-search"></i> First Class</a><br />
						</cfif>
					</div>

					<div id="fares" class="span2">
						<b>Fares</b>
						<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "0") OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'X0')>
							<label for="Fare0" class="checkbox" title="Filter by non-refundable fares"><input type="checkbox" id="Fare0" name="Fare0" value="0" <!--- <cfif NOT structKeyExists(rc, 'bRef') OR rc.bRef EQ 0>checked</cfif> --->>Non Refundable <br /><small>(#session.searches[rc.SearchID].stLowFareDetails.stResults[0]# results)</small></label>
						</cfif>
						<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "1") OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'X1')>
							<label for="Fare1" class="checkbox" title="Filter by refundable fares"><input type="checkbox" id="Fare1" name="Fare1" value="1" <!--- <cfif NOT structKeyExists(rc, 'bRef') OR rc.bRef EQ 0>checked</cfif> --->>Refundable <br /><small>(#session.searches[rc.SearchID].stLowFareDetails.stResults[1]# results)</small></label>
						</cfif>
						<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'X1')>
							<a href="?action=air.lowfare&SearchID=#rc.SearchID#&bRefundable=1" title="Find Refundable Fares"><i class="icon-search"></i> Refundable</a><br />
						</cfif>
					</div>

					<div class="span2">
						<b>Non-stops</b>
						<label for="NonStops" class="checkbox" title="Filter by non-stop fares"><input type="checkbox" id="NonStops" name="NonStops"> Non Stops</label>
					</div>

					<div class="span2">
						<b>In-policy</b>
						<label for="InPolicy" class="checkbox" title="Filter by in-policy fares"><input type="checkbox" id="InPolicy" name="InPolicy"> In Policy</label>
					</div>

					<div class="span2">
						<b>Single Carrier</b>
						<label for="SingleCarrier" class="checkbox" title="Filter by single carrier fares"><input type="checkbox" id="SingleCarrier" name="SingleCarrier"> Single Carrier</label>
					</div>
					</cfoutput>
				</div> <!--- // row --->
			</div> <!--- // span12 --->
		</div> <!--- // well filterselection --->

		</div><!-- // class=sixteen columns -->
	</div><!-- // class=row -->
</div><!-- // class=filter -->





<!---
TODO:  Clean up this old filter and sort code when done with filters
3:25 PM Thursday, June 13, 2013 - Jim Priest - jpriest@shortstravel.com
 --->

<!---
<!--- sort --->
<cfif rc.action NEQ 'air.availability'>
<input type="radio" id="fare" name="sort" <cfif rc.action NEQ 'air.lowfare'>checked="checked"</cfif> /><label for="fare">Price</label>
<input type="radio" id="bag" name="sort" /><label for="bag">Price + Bag Fees</label>
</cfif>
<input type="radio" id="duration" name="sort" <cfif rc.action NEQ 'air.availability'>checked="checked"</cfif> />
<label for="duration">Duration</label>
<input type="radio" id="depart" name="sort" /><label for="depart">Departure</label>
<input type="radio" id="arrival" name="sort" /><label for="arrival">Arrival</label>

<!--- filters --->
<input type="checkbox" id="Airlines" name="Airlines"> <label for="Airlines">Airlines</label>
<cfif rc.action NEQ 'air.availability'>
	<cfset aCarriers = session.searches[rc.SearchID].stLowFareDetails.aCarriers>
<cfelse>
	<cfset aCarriers = session.searches[rc.SearchID].stAvailDetails.stCarriers[rc.Group]>
</cfif>

<cfoutput>
	<cfloop array="#aCarriers#" index="Carrier" >
		<span><input id="Carrier#Carrier#" type="checkbox" value="#Carrier#" checked> <label for="Carrier#Carrier#">#application.stAirVendors[Carrier].Name#</label></span>
	</cfloop>
</cfoutput>

<cfif rc.action NEQ 'air.availability'>
	<input type="checkbox" id="Classes" name="Classes"> <label for="Classes">Class</label>
		<cfoutput>
			<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "Y") OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'YX')>
				<input type="checkbox" id="ClassY" name="ClassY" value="Y" <cfif NOT structKeyExists(rc, 'sCabins') OR rc.sCabins EQ 'Y'>checked</cfif>><label for="ClassY">Economy (#session.searches[rc.SearchID].stLowFareDetails.stResults.Y# results)</label>
			</cfif>
			<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "C")>
				<input type="checkbox" id="ClassC" name="ClassC" value="C" <cfif NOT structKeyExists(rc, 'sCabins') OR rc.sCabins EQ 'C'>checked</cfif>><label for="ClassC">Business (#session.searches[rc.SearchID].stLowFareDetails.stResults.C# results)</label>
			<cfelseif StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'CX')>
				<input type="checkbox" id="ClassC" name="ClassC" value="C" disabled><label for="ClassC">Business (no results)</label>
			</cfif>
			<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'CX')>
				<cfoutput>
					<a href="?action=air.lowfare&SearchID=#rc.SearchID#&sCabins=C">Find Business Class Fares</a>
				</cfoutput>
			</cfif>
			<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "F")>
				<input type="checkbox" id="ClassF" name="ClassF" value="F" <cfif NOT structKeyExists(rc, 'sCabins') OR rc.sCabins EQ 'F'>checked</cfif>><label for="ClassF">First (#session.searches[rc.SearchID].stLowFareDetails.stResults.F# results)</label>
			<cfelseif StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'FX')>
				<input type="checkbox" id="ClassF" name="ClassF" value="F" disabled><label for="ClassF">First (no results)</label>
			</cfif>
			<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'FX')>
				<cfoutput>
					<a href="?action=air.lowfare&SearchID=#rc.SearchID#&sCabins=F">Find First Class Fares</a>
				</cfoutput>
			</cfif>
		</cfoutput>


			<input type="checkbox" id="Fares" name="Fares"> <label for="Fares">Fares</label>
			<cfoutput>
				<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "0") OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'X0')>
					<input type="checkbox" id="Fare0" name="Fare0" value="0" <cfif NOT structKeyExists(rc, 'bRef') OR rc.bRef EQ 0>checked</cfif>><label for="Fare0">Non Refundable (#session.searches[rc.SearchID].stLowFareDetails.stResults[0]# results)</label>
				</cfif>
				<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "1") OR StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'X1')>
					<input type="checkbox" id="Fare1" name="Fare1" value="1" <cfif NOT structKeyExists(rc, 'bRef') OR rc.bRef EQ 0>checked</cfif>><label for="Fare1">Refundable (#session.searches[rc.SearchID].stLowFareDetails.stResults[1]# results)</label>
				</cfif>
				<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPricing, 'X1')>
					<cfoutput>
						<a href="?action=air.lowfare&SearchID=#rc.SearchID#&bRefundable=1">Find Refundable Fares</a>
					</cfoutput>
				</cfif>
			</cfoutput>
	</cfif>
			<input type="checkbox" id="NonStops" name="NonStops"> <label for="NonStops">Non Stops</label>
			<input type="checkbox" id="Policy" name="Policy"> <label for="Policy">In Policy</label>
			<input type="checkbox" id="SingleCarrier" name="SingleCarrier" checked> <label for="SingleCarrier">Single Carrier</label>
 --->
