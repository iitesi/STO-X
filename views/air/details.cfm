<cfsilent>
	<cfset aRef = ["0","1"]>
	<cfset aMyCabins = ListToArray(Replace(LCase(StructKeyList(session.searches[rc.SearchID].stLowFareDetails.stPricing)), 'f', 'F'))>
	<cfif rc.Group EQ ''>
		<cfset stTrip = session.searches[rc.SearchID].stTrips[rc.nTripID]>
	<cfelse>
		<cfset stTrip = session.searches[rc.SearchID].stAvailTrips[rc.Group][rc.nTripID]>
	</cfif>
</cfsilent>

<cfoutput>


<cfloop collection="#stTrip.Groups#" item="Group" >
	<cfset stGroup = stTrip.Groups[Group]>

	<div class="media">
		<div class="media-body">
			<span class="media-heading"><h3>#application.stAirports[stGroup.Origin]# (#stGroup.Origin#) to #application.stAirports[stGroup.Destination]# (#stGroup.Destination#) <small>:: #DateFormat(stGroup.DepartureTime, 'dddd, mmm d')#</small></h3></span>
			<span class="muted">Trip duration: #stGroup.TravelTime#</span>
		</div>
	</div>

	<cfset nCnt = 0>
	<cfset aKeys = structKeyArray(stGroup.Segments)>
	<cfloop collection="#stGroup.Segments#" item="nSegment" >
		<cfset nCnt++>
		<cfset stSegment = stGroup.Segments[nSegment]>
		<div class="media">
			<a class="pull-left" href="##">
				<img class="carrierimg" src="assets/img/airlines/#stSegment.Carrier#_sm.png">
			</a>
			<div class="media-body">
				<span class="media-heading"><b>#application.stAirVendors[stSegment.Carrier].Name# #stSegment.FlightNumber#</b> :: #TimeFormat(stSegment.DepartureTime, 'h:mm tt')# - #TimeFormat(stSegment.ArrivalTime, 'h:mm tt')# &nbsp;&nbsp; <span class="muted">#stSegment.Origin# - #stSegment.Destination#</span></span>
				<br>
				<span class="muted">
					#int(stSegment.FlightTime/60)#h #stSegment.FlightTime%60#m

					<cfif structKeyExists(application.stEquipment,"#stSegment.Equipment#")>
					:: #application.stEquipment[stSegment.Equipment]#
					</cfif>

					<cfif stSegment.ChangeOfPlane>
					:: <i class="icon-warning-sign"></i> Plane Change
					</cfif>

				</span>
			</div>
		</div>

		<cfif nCnt LT ArrayLen(aKeys)	AND stGroup.Segments[aKeys[nCnt+1]].Group EQ Group>
		<cfset minites = DateDiff('n', stSegment.ArrivalTime, stGroup.Segments[aKeys[nCnt+1]].DepartureTime)>
		<div class="media">
			<span class="pull-left">
				<img class="carrierimg" src="assets/img/airlines/blank.gif">
			</span>
			<div class="media-body">
				<span class="media-heading"><i class="icon-time"></i> #int(minites/60)#h #minites%60#m layover in #application.stAirports[stSegment.Destination]# (#stSegment.Destination#)</span>
			</div>
		</div>
		</cfif>

	</cfloop>
</cfloop>
</cfoutput>
<br><br>