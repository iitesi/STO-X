<cfparam name="variables.minheight" default="50"/>
<cfset ribbonClass = "">
<cfset carrierList = []>
<cfset thisSelectedLeg = "">
	<cfsavecontent variable="sBadge" trim="#true#">
	<cfscript>
		/* create ribbon
			Note: Please do not display "CONTRACTED" flag on search results for Southwest.
		*/

		if(bDisplayFare AND stTrip.PrivateFare AND stTrip.preferred EQ 1) {
			if(stTrip.Carriers[1] EQ "WN") {
				if(structKeyExists(stTrip, "PTC") AND stTrip.PTC EQ "GST")
					ribbonClass = "ribbon-l-pref-govt";
				else
					ribbonClass = "ribbon-l-pref";
			}
			else ribbonClass = "ribbon-l-pref-cont";
		}
		else if(stTrip.preferred EQ 1) {
			if(structKeyExists(stTrip, "PTC") AND stTrip.PTC EQ "GST")
				ribbonClass = "ribbon-l-pref-govt";
			else
				ribbonClass = "ribbon-l-pref";
		}
		else if(bDisplayFare AND stTrip.PrivateFare AND stTrip.Carriers[1] NEQ "WN")
			ribbonClass = "ribbon-l-cont";
		else if(bDisplayFare AND (structKeyExists(stTrip, "PTC") AND stTrip.PTC EQ "GST"))
			ribbonClass = "ribbon-l-govt";

		// finally add default 'ribbon' class
		if(Len(ribbonClass))
			ribbonClass = "ribbon " & ribbonClass;

		if(len(rc.Group) AND structKeyExists(session.searches[rc.SearchID].stSelected[rc.Group], "nTripKey")){
			bSelected = false;
			thisSelectedLeg = session.searches[rc.SearchID].stSelected[rc.Group].nTripKey;
			if(nTripKey EQ thisSelectedLeg)
				bSelected = true;
		}
	</cfscript>
	<cfoutput>
		<!--<div class="screenbadge badge"> -->
		<div class="panel panel-default">
	  	<div class="panel-body">
	  		<div class="row" style="vertical-align: middle;">
			<!--- display ribbon --->
			<span class="#ribbonclass#"></span>

			<!--- TODO: uncomment for debugging - this will display on each badge!
			<cfif IsLocalHost(cgi.local_addr)>
						<p align="center">DEBUGGING: #nTripKey# | Policy: #stTrip.Policy# | #ncount# [ #stTrip.preferred# | #bDisplayFare# | <cfif structKeyExists(stTrip,"privateFare")>#stTrip.PrivateFare#</cfif> ] </p>
			</cfif>
			--->
			<cfscript>
			flightnumbers = [];
			loop collection="#stTrip.Groups#" item="Group" {
				stGroup = stTrip.Groups[Group];
				loop collection="#stGroup.Segments#" item="nSegment" {
					//stSegment = stGroup.Segments[nSegment];
					arrayAppend(flightnumbers, stGroup.Segments[nSegment].flightNumber);
				}
			}
			</cfscript>
					<div class="col-md-2 center" style="font-weight: bold;">
						<img class="carrierimg" src="assets/img/airlines/#(ArrayLen(stTrip.Carriers) EQ 1 ? stTrip.Carriers[1] : 'Mult')#.png">
						#(ArrayLen(stTrip.Carriers) EQ 1 ? '<br />'&application.stAirVendors[stTrip.Carriers[1]].Name : '<br />Multiple Carriers')#
					</div>



<!-- BEGIN -->
<cfloop collection="#stTrip.Groups#" item="Group">
	<cfscript>
	stGroup = stTrip.Groups[Group];

	// set times for badges, and get total times so we can set time sliders in filter
	departureTime = (hour(stGroup.DepartureTime)*60) + (minute(stGroup.DepartureTime));
	arrivalTime = (hour(stGroup.ArrivalTime)*60) + (minute(stGroup.ArrivalTime));
	timeFilter["departureTime#group#"] = departureTime;
	timeFilter["arrivalTime#group#"] = arrivalTime;

	</cfscript>
	<!--- 4:40 PM Wednesday, December 04, 2013 - Jim Priest - jpriest@shortstravel.com
	STM-2544 need to create a container of min/max times so we can use to set filters
	See code in lowfare.cfm

	<cfset arrayAppend(timeFilterTotal, departureTime)>
	<cfset arrayAppend(timeFilterTotal, arrivalTime)>
	--->
	<div class="col-md-3" style="vertical-align: middle;margin-top: 1.5em;">
		Depart #stGroup.Origin# <strong>#DateFormat(stGroup.DepartureTime, 'ddd')# #TimeFormat(stGroup.DepartureTime, 'h:mmt')#</strong><br />
		Arrive #stGroup.Destination# <strong>#TimeFormat(stGroup.ArrivalTime, 'h:mmt')#</strong><br />
		<small>Travel Time: #stGroup.TravelTime#</small>
	</div>

<!--	<cfset nCnt = 0>
	<cfset segmentCount = structCount(stGroup.Segments)>
	<cfloop collection="#stGroup.Segments#" item="nSegment" >
		<cfscript>
		nCnt++;
		stSegment = stGroup.Segments[nSegment];
		if(NOT arrayFind(carrierList, stSegment.Carrier))
			arrayAppend(carrierList, stSegment.Carrier);
		</cfscript>
		<tr>
			<td valign="top" title="#application.stAirVendors[stSegment.Carrier].Name# Flt ###stSegment.FlightNumber#">#stSegment.Carrier##stSegment.FlightNumber#</td>
			<td valign="top">
				#Left((structKeyExists(stSegment,'CabinClass') ? stSegment.CabinClass : findClass(stTrip.Class)),4)# -->
				<!--- #(stTrip.Class EQ 'Y' ? 'Economy' : (stTrip.Class EQ 'C' ? 'Business' : 'First'))# --->
			<!--</td>
			<td valign="top" title="#application.stAirports[stSegment.Destination].airport#">
				<span>#stSegment.Origin# to #stSegment.Destination#</span></td>
			<td valign="top">
				<cfif nCnt EQ 1>
					#stGroup.TravelTime#
					<cfset nFirstSeg = nSegment>
					<cfset sClass = (bDisplayFare ? stSegment.Class : 'Y') />
				</cfif>
			</td>
		</tr>
	</cfloop> -->
</cfloop>
<!-- END -->

				  <div class="col-md-4 center price">

				<!--<td colspan="2"> -->
					<cfset btnClass = "">
					<cfif bDisplayFare>
						#findClass(stTrip.Class)#
						<!--- #(stTrip.Class EQ 'Y' ? 'ECONOMY' : (stTrip.Class EQ 'C' ? 'BUSINESS' : 'FIRST'))# --->
						<br>
						<cfif stTrip.policy EQ 1>
							<cfset btnClass = "btn-primary">
						</cfif>
						<cfif bSelected>
							<cfset btnClass = "btn-success">
						</cfif>
						<input type="submit" class="btn #btnClass# btnmargin" value="$#NumberFormat(stTrip.Total)#" onClick="submitLowFare(#nTripKey#);" title="Click to purchase!">
						<br>
						<span rel="popover" class="popuplink" data-original-title="Flight Change / Cancellation Policy"
							data-content="
								Ticket is
								<cfif val(stTrip.ref) eq 0>
									non-refundable
								<cfelse>
									refundable
								</cfif>
								<br>
								<cfif listFind('DL',stTrip.platingCarrier) AND val(stTrip.ref) EQ 0 AND val(stTrip.changePenalty) EQ 0>
									Changes are not permitted<br>
									No pre-reserved seats
								<cfelse>
									Changes USD #stTrip.changePenalty# for reissue
								</cfif>
							" href="##"/>
							#(stTrip.Ref EQ 0 ? 'NO REFUNDS' : 'REFUNDABLE')#
						</span>
						<cfif arrayFind( structKeyArray(rc.Filter.getUnusedTicketCarriers()), stTrip.platingCarrier )>
							<br><span rel="popover" class="popuplink" style="width:1000px" data-original-title="UNUSED TICKETS - #application.stAirVendors[stTrip.platingCarrier].Name#" data-content="#rc.Filter.getUnusedTicketCarriers()[stTrip.platingCarrier]#" href="##" />UNUSED TKT AVAIL</span>
						</cfif>
					<cfelse>
						<input type="submit" class="btn btn-primary btnmargin" value="Select" onClick="submitAvailability(#nTripKey#);" title="Click to select this flight.">
					</cfif>
				<!--</td>-->



			<cfif bSelected OR !stTrip.Policy>
				<tr align="center">
					<td colspan="2">#(NOT bSelected ? '' : '<span class="medium green bold">SELECTED</span>')#</td>
					<td colspan="2">
						<span rel="tooltip" class="popuplink" title="#Replace(ArrayToList(stTrip.aPolicies), ",", ", ")#">#(stTrip.Policy ? '' : 'OUT OF POLICY<br>')#</span>
					</td>
				</tr>
			</cfif>

			<!--- set bag fee into var so we can display in a tooltip below --->
			<cfsavecontent variable="tooltip">
				<cfloop array="#carrierList#" item="carrier">
					#application.stAirVendors[Carrier].Name#:&nbsp;<span class='pull-right'><i class='fa fa-suitcase'></i> = $#application.stAirVendors[Carrier].Bag1#&nbsp;&nbsp;<i class='fa fa-suitcase'></i>&nbsp;<i class='fa fa-suitcase'></i> = $#application.stAirVendors[Carrier].Bag2#</span><br>
				</cfloop>
			</cfsavecontent>
			<br />
			<small>

					<cfset sURL = 'SearchID=#rc.SearchID#&nTripID=#nTripKey#&Group=#nDisplayGroup#'>
					<a data-url="?action=air.popup&sDetails=details&#sURL#" class="popupModal" data-toggle="modal" data-target="##popupModal">
						Details
						<span class="divider">/</span>
					</a>
					<cftry>
						<cfif NOT ArrayFind(stTrip.Carriers, 'WN') AND NOT ArrayFind(stTrip.Carriers, 'FL')>
							<a data-url="?action=air.popup&sDetails=seatmap&#sURL#&sClass=#sClass#" class="popupModal" data-toggle="modal" data-target="##popupModal">
								Seats
								<span class="divider">/</span>
							</a>
						</cfif>
						<cfcatch type="any"></cfcatch>
					</cftry>
					<a data-url="?action=air.popup&sDetails=baggage&#sURL#" class="popupModal" data-toggle="modal" data-target="##popupModal" rel="poptop" data-placement="top" data-content="#tooltip#" data-original-title="Baggage Fees">
						Bags
						<span class="divider">/</span>
					</a>
					<a data-url="?action=air.popup&sDetails=email&#sURL#" class="popupModal" data-toggle="modal" data-target="##popupModal">
						Email
					</a>
					<!--- <cfif (application.es.getCurrentEnvironment() NEQ 'prod'
						AND application.es.getCurrentEnvironment() NEQ 'beta')
						OR listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID())>
						<span class="divider">/</span>
						<a href="?action=findit.send&SearchID=#rc.searchID#&nTripID=#nTripKey#">FindIt</a>
					</cfif> --->

			</small>
		</div> <!-- /.price -->
	</div> <!-- /.row -->
</div> <!-- /.panel-body -->
</div> <!-- / .panel -->
	</cfoutput>
</cfsavecontent>


<!--- set unique data-attributes for each badge for filtering by time --->
<cftry>
<cfscript>
dataString = [];
loop collection="#timeFilter#" item="timeFilterItem" index="timeFilterIndex" {
	arrayAppend(dataString, "data-" & timeFilterIndex & '="#timeFilterItem#"');
}
</cfscript>
<cfcatch type="any"></cfcatch></cftry>
<!--- display badge --->
<cfoutput>
	<div class="flight#nTripKey#" #dataString.toList(' ')# class="">#sBadge#</div>
</cfoutput>

<cffunction name="findClass">
	<cfargument name="classOfService" required="true"/>
	<cfif ListFindNoCase('y,x',classOfService) GT 0>
		<cfreturn 'Economy'/>
	<cfelseif ListFindNoCase('f',classOfService) GT 0>
		<cfreturn 'First'/>
	<cfelseif ListFindNoCase('c',classOfService) GT 0>
		<cfreturn 'Business'/>
	<cfelse>
		<cfreturn 'Economy'/>
	</cfif>
</cffunction>
