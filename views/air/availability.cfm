<cfsilent>
	<cfset variables.bDisplayFare = false>
	<cfset variables.bSelected = false>
	<cfset variables.nLegs = ArrayLen(rc.Filter.getLegs())>
	<cfset variables.minheight = 100>
	<cfset variables.nDisplayGroup = rc.Group>
	<cfif nLegs EQ 2>
		<cfset variables.minheight = 200>
	<cfelseif nLegs GT 2>
		<cfset variables.minheight = 250>
	</cfif>
</cfsilent>

<cfoutput>

<div class="page-header">
	<cfif rc.filter.getAirType() IS "MD">
		<h1>#rc.Filter.getAirHeading()#</h1>
		<ul class="unstyled">
			<cfloop array="#rc.filter.getLegsHeader()#" index="nLeg" item="sLeg">
				<li><h2>#ListFirst(sLeg, '::')# <small>:: #ListLast(sLeg, "::")#</small></h2></li>
			</cfloop>
		</ul>
	<cfelse>
		<h1>
			<a href="#buildURL('air.lowfare&SearchID=#rc.SearchID#')#">
				#ListFirst(rc.Filter.getAirHeading(), "::")#
				<small>:: #ListLast(rc.Filter.getAirHeading(), "::")#</small>
			</a>
		</h1>
	</cfif>

	<h2><a href="##displaySearchWindow" id="displayModal" class="change-search" data-toggle="modal" data-backdrop="static"><i class="icon-search"></i> Change Search</a></h2>
	<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare")>
		#View('air/legs')#
	</cfif>
</div>

<div id="aircontent">
	<cfif structKeyExists(session.searches[rc.SearchID].stAvailDetails, "aSortDuration") AND structKeyExists(session.searches[rc.SearchID].stAvailDetails.aSortDuration, rc.Group)>

		#View('air/filter')#

		<cfif (rc.Group EQ 0 AND rc.Filter.getDepartTimeType() IS 'A') OR (rc.Group EQ 1 AND rc.Filter.getArrivalTimeType() IS 'A')>
			<cfset arrayToLoop = session.searches[rc.SearchID].stAvailDetails.aSortArrivalPreferred[rc.Group] />
		<cfelse>
			<cfset arrayToLoop = session.searches[rc.SearchID].stAvailDetails.aSortDepartPreferred[rc.Group] />
		</cfif>

		<cfset variables.nCount = 0>
		<cfloop array="#arrayToLoop#" index="variables.nTripKey">
			<cfset variables.stTrip = session.searches[rc.SearchID].stAvailTrips[rc.Group][nTripKey]>
			#View('air/badge')#
		</cfloop>

		<script type="application/javascript">
			// define for sorting ( see air/filter.js and booking.js airSort() )
			var sortbyarrival = #SerializeJSON(session.searches[rc.SearchID].stAvailDetails.aSortArrival[rc.Group])#;
			var sortbydeparture = #SerializeJSON(session.searches[rc.SearchID].stAvailDetails.aSortDepart[rc.Group])#;
			var sortbyduration = #SerializeJSON(session.searches[rc.SearchID].stAvailDetails.aSortDuration[rc.Group])#;
			var sortbyprice = '';
			var sortbyprice1bag = '';
			var sortbyprice2bag = '';

			// flightresults is used in booking.js to filter flights
			// here we loop over session searches and stuff all the flights avail in flightresults
			var flightresults = [
				<cfset nCount = 0>
				<cfloop array="#session.searches[rc.SearchID].stAvailDetails.aSortDepartPreferred[rc.Group]#" index="sTrip">
					<cfif nCount NEQ 0>,</cfif>[#session.searches[rc.SearchID].stAvailTrips[rc.Group][sTrip].sJavascript#]
					<cfset nCount++>
				</cfloop>];
		</script>

		<div class="clearfix"></div>

		<div class="noFlightsFound">
			<div class="container">
			<h1>No Flights Available</h1>
			<p>No flights are available for your filtered criteria. <a href="##" class="removefilters"><i class="icon-refresh"></i> Clear Filters</a> to see all results.</p>
			</div>
		</div>
	<cfelse>
		<div class="container">
			<h3>No Flights Returned</h2>
			<p>There were no flights found based on your search criteria.</p>
			<p>Please <a href="#application.sPortalURL#">change your search</a> and try again.</p>
			<br /><br /><br /><br /><br /><br />
		</div>
	</cfif>
</div>

	<form method="post" action="#buildURL('air.availability')#" id="availabilityForm">
		<input type="hidden" name="bSelect" value="1">
		<input type="hidden" name="SearchID" value="#rc.SearchID#">
		<input type="hidden" name="nTrip" id="nTrip" value="">
		<input type="hidden" name="Group" value="#rc.Group#">
	</form>

	#View('modal/popup')#
</cfoutput>