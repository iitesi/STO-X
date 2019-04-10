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
		ribbonClass = "ribbon ribbon-adjusted " & ribbonClass;

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
				<!--- TODO: uncomment for debugging - this will display on each badge!
				<cfif IsLocalHost(cgi.local_addr)>
							<p align="center">DEBUGGING: #nTripKey# | Policy: #stTrip.Policy# | #ncount# [ #stTrip.preferred# | #bDisplayFare# | <cfif structKeyExists(stTrip,"privateFare")>#stTrip.PrivateFare#</cfif> ] </p>
				</cfif>
				--->
<!--- Logic --->				
				<cfscript>
					flightnumbers = [];
					carriernames = '';
					loop collection="#stTrip.Groups#" index="groupIndex" item="stGroup" {
						loop collection="#stGroup.Segments#" item="nSegment" {
							//stSegment = stGroup.Segments[nSegment];
							arrayAppend(flightnumbers, stGroup.Segments[nSegment].flightNumber);
							carriernames = carriernames&', '&application.stAirVendors[stTrip.Carriers[1]].Name;
						}
					}
					gCnt = 0;
					carriernames = listRemoveDuplicates(carriernames);
				</cfscript>
				<cfset groupCount = structCount(stTrip.Groups)>
				<cfloop collection="#stTrip.Groups#" index="groupIndex" item="stGroup">
					<cfset nCnt = 0>
					<cfset details = "">
					<cfset aKeys = structKeyArray(stGroup.Segments)>
					<cfloop collection="#stGroup.Segments#" item="nSegment" >
						<cfscript>
							nCnt++;
							stSegment = stGroup.Segments[nSegment];

							if(NOT arrayFind(carrierList, stSegment.Carrier))
								arrayAppend(carrierList, stSegment.Carrier);
							//if(len(details))
							//	details = details & '<br />';
							//details = details & '<strong>' & application.stAirVendors[stSegment.Carrier].Name & ' ' & stSegment.FlightNumber & '</strong> - ' & stSegment.Origin & ' to ' & stSegment.Destination & ' ('& int(stSegment.FlightTime/60) &'h '&stSegment.FlightTime%60&'m)';
							if( nCnt LT ArrayLen(aKeys)	AND stGroup.Segments[aKeys[nCnt+1]].Group EQ groupIndex) {
								minites = DateDiff('n', stSegment.ArrivalTime, stGroup.Segments[aKeys[nCnt+1]].DepartureTime);
								details = details & "<br /><i class='fa fa-clock-o'></i> " & int(minites/60) & 'h ' & minites%60 & 'm layover in ' & stSegment.Destination;
							}

							if (nCnt eq 1 AND structKeyExists(stSegment,"Source")) {
								variables.tripSource = stSegment.Source;
							}
						</cfscript>
						<cfif nCnt EQ 1>
							<cfset nFirstSeg = nSegment>
							<cfset sClass = (bDisplayFare ? Left((structKeyExists(stSegment,'CabinClass') ? stSegment.CabinClass : findClass(stTrip.Class)),4) : 'Y') />
						</cfif>
						<span class="flightNumberFilter" style="display:none;">#reReplace(stSegment.FlightNumber,"^\D+","all")#</span>
					</cfloop>
					<cfscript>
					gCnt++;
					// set times for badges, and get total times so we can set time sliders in filter
					departureTime = (hour(stGroup.DepartureTime)*60) + (minute(stGroup.DepartureTime));
					arrivalTime = (hour(stGroup.ArrivalTime)*60) + (minute(stGroup.ArrivalTime));
					timeFilter["departureTime#groupIndex#"] = departureTime;
					timeFilter["arrivalTime#groupIndex#"] = arrivalTime;
					variables.tripSource = "";
					</cfscript>
				</cfloop>
<!--- Display --->	
				<span class="#ribbonclass#"></span>		
				<div class="col-sm-6">
					<cfloop collection="#stTrip.Groups#" index="groupIndex" item="stGroup">
						<cfset stops = structCount(stGroup.Segments)-1>
						<div class="row">
							<div class="col-sm-2">
								<cfif ArrayLen(stTrip.Carriers) EQ 1>
									<img class="carrierimg" src="assets/img/airlines/#stTrip.Carriers[1]#.png" title="#application.stAirVendors[stTrip.Carriers[1]].Name#" width="60">
								<cfelse>
									<img class="carrierimg" src="assets/img/airlines/Mult.png" width="75%">
								</cfif>
							</div>
							<div class="col-sm-10">
								<div class="row">
									<div class="col-sm-5 bold">
										#timeFormat(stGroup.DepartureTime, 'h:mm tt')# - #timeFormat(stGroup.ArrivalTime, 'h:mm tt')#
									</div>
									<div class="col-sm-3 bold">
										#stGroup.TravelTime#
									</div>
									<div class="col-sm-2 bold">
										<cfif stops EQ 0>Nonstop<cfelseif stops EQ 1>1 stop<cfelse>#stops# stops</cfif>
									</div>
								</div>
								<div class="row">
									<div class="col-sm-5">
										#carriernames#
									</div>
									<div class="col-sm-3">
										#stGroup.Origin#-#stGroup.Destination#
									</div>
									<div class="col-sm-4">
										<cfloop collection="#stGroup.Segments#" item="stSegment" index="segmentIndex">
											<cfif stGroup.Destination NEQ stSegment.Destination>#stSegment.Destination#</cfif>
										</cfloop>
									</div>
								</div>
							</div>
						</div>
					</cfloop>
				</div>
				<div class="col-sm-4">
					<cfset btnClass = "">
					<cfif bDisplayFare
						AND NOT isDefined("tripID")>
						<cfif stTrip.policy EQ 1>
							<cfset btnClass = "btn-primary">
						</cfif>
						<cfif bSelected>
							<cfset btnClass = "btn-success">
						</cfif>
						<input type="submit" class="btn #btnClass# btnmargin" value="$#NumberFormat(stTrip.Total)# - #findClass(stTrip.Class)#" onClick="submitLowFare(#nTripKey#);" title="Click to purchase!">
						<br>
						<cfif bSelected OR !stTrip.Policy>
							<tr align="center">
								<td colspan="2">#(NOT bSelected ? '' : '<span class="medium green bold">SELECTED</span><br/>')#</td>
								<td colspan="2">
									<span rel="tooltip" class="popuplink" title="#Replace(ArrayToList(stTrip.aPolicies), ",", ", ")#"><small>#(stTrip.Policy ? '' : 'OUT OF POLICY<br/>')#</small></span>
								</td>
							</tr>
						</cfif>
						<span rel="popover" class="popuplink" data-original-title="Flight Change / Cancellation Policy"
							data-content="
								Ticket is
								<cfif stTrip.ref eq 0>
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
							<small>#(stTrip.Ref EQ 0 ? 'NO REFUNDS' : 'REFUNDABLE')#</small>
						</span>
						<cfif arrayFind( structKeyArray(rc.Filter.getUnusedTicketCarriers()), stTrip.platingCarrier )>
							<br><span rel="popover" class="popuplink" style="width:1000px" data-original-title="UNUSED TICKETS - #application.stAirVendors[stTrip.platingCarrier].Name#" data-content="#rc.Filter.getUnusedTicketCarriers()[stTrip.platingCarrier]#" href="##" />UNUSED TKT AVAIL</span>
						</cfif>
					<cfelseif isDefined("tripID")>
<!---Remove table.  Sloppy coding, tired of fighting with the divs!! --->
						<table width="100%">
						<td width="25%">
							<cfif structKeyExists(stLowFareAvail, 'Economy')>
								$#numberFormat(stLowFareAvail.Economy.Total, '_,___')#
							<cfelse>
								<small>Select to price</small>
							</cfif>	<br>
							<small>Economy</small>
							<input type="submit" class="btn btn-primary btnmargin" value="Select" onClick="submitLowFareAvail(#nTripKey#);" title="Click to select this flight.">
						</td>
						<td width="25%">
							<cfif structKeyExists(stLowFareAvail, 'Branded')>
								$#numberFormat(stLowFareAvail.Branded.Total, '_,___')#
							<cfelse>
								<small>Select to price</small>
							</cfif>	<br>
							<small>Branded</small>
							<input type="submit" class="btn btn-primary btnmargin" value="Select" onClick="submitLowFareAvail(#nTripKey#);" title="Click to select this flight.">
						</td>
						<td width="25%">
							<cfif structKeyExists(stLowFareAvail, 'Business')>
								$#numberFormat(stLowFareAvail.Business.Total, '_,___')#
							<cfelse>
								<small>Select to price</small>
							</cfif>	<br>
							<small>Business</small>
							<input type="submit" class="btn btn-primary btnmargin" value="Select" onClick="submitLowFareAvail(#nTripKey#);" title="Click to select this flight.">
						</td>
						<td width="25%">
							<cfif structKeyExists(stLowFareAvail, 'First')>
								$#numberFormat(stLowFareAvail.First.Total, '_,___')#
							<cfelse>
								<small>Select to price</small>
							</cfif><br>
							<small>First</small>
							<input type="submit" class="btn btn-primary btnmargin" value="Select" onClick="submitLowFareAvail(#nTripKey#);" title="Click to select this flight.">
						</td>
						</table>
					<cfelse>
						<input type="submit" class="btn btn-primary btnmargin" value="Select" onClick="submitAvailability(#nTripKey#);" title="Click to select this flight.">
					</cfif>
					<!--- set bag fee into var so we can display in a tooltip below --->
					<cfsavecontent variable="tooltip">
						<cfloop array="#carrierList#" item="carrier">
							#application.stAirVendors[Carrier].Name#:&nbsp;<span class='pull-right'><i class='fa fa-suitcase'></i> = $#application.stAirVendors[Carrier].Bag1#&nbsp;&nbsp;<i class='fa fa-suitcase'></i>&nbsp;<i class='fa fa-suitcase'></i> = $#application.stAirVendors[Carrier].Bag2#</span><br>
						</cfloop>
					</cfsavecontent>
				<div>
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
				</small>
					</div>
				</div> <!-- /.price -->
			</div> <!-- /.row -->
		</div> <!-- /.panel-body -->
	</div> <!-- / .panel -->
</cfoutput>
</cfsavecontent>

<!--- set unique data-attributes for each badge for filtering by time --->
<cfscript>
dataString = [];
loop collection="#timeFilter#" item="timeFilterItem" index="timeFilterIndex" {
	arrayAppend(dataString, "data-" & timeFilterIndex & '="#timeFilterItem#"');
}
loop collection="#stTrip.Carriers#" item="carrierItem" index="carrierIndex" {
	arrayAppend(dataString, "data-carrier" & '="#carrierItem#"');
}
arrayAppend(dataString, "data-stops" & '="#stops#"');
arrayAppend(dataString, "data-preferred" & '="#stTrip.Preferred#"');
arrayAppend(dataString, "data-carriercount" & '="#arrayLen(stTrip.Carriers)#"');
arrayAppend(dataString, "data-refundable" & '="#stTrip.ref#"');
arrayAppend(dataString, "data-duration" & '="#stTrip.duration#"');
</cfscript>
	

<!--- display badge --->
<cfoutput>
	<div class="flight#nTripKey#" #dataString.toList(' ')#>
		#dataString.toList(' ')# <br>
		#sBadge#
</div>
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