<cfsilent>
	<cfset variables.bDisplayFare = false>
	<cfset variables.bSelected = false>
	<cfset variables.nLegs = ArrayLen(rc.Filter.getLegsForTrip())>
	<cfset variables.minheight = 285>
	<cfset variables.nDisplayGroup = rc.Group>
	<cfif variables.nLegs EQ 2>
		<cfset variables.minheight = 340>
	<cfelseif variables.nLegs GT 2>
		<cfset variables.minheight = 380>
	</cfif>
</cfsilent>

<cfoutput>
<script type='text/javascript' src='#application.assetURL#/js/air/filter.js?v=#application.staticAssetVersion#'></script>

<script>
	$(document).ready(function(){
		$('##sortbyduration').click();
		$('##singlecarrierbtn').click();
	});
</script>

#view('air/unusedtickets')#

<div class="page-header">
	<cfif rc.filter.getAirType() IS "MD">
		<h1>#rc.Filter.getAirHeading()#</h1>
		<ul class="unstyled">
			<cfloop array="#rc.filter.getLegsHeader()#" item="nLegItem" index="nLegIndex">
				<li><h2>#ListFirst(nLegItem, '::')# <small>:: #ListLast(nLegItem, "::")#</small></h2></li>
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

	<cfif structKeyExists(session, 'cookieToken')
		AND structKeyExists(session, 'cookieDate')>
		<cfif listFindNoCase("beta,beta.shortstravel.com", cgi.server_name)>
			<cfset frameSrc ="https://beta.shortstravel.com/search/index.cfm?acctid=#rc.filter.getAcctID()#&userid=#rc.filter.getUserId()#&token=#session.cookieToken#&date=#session.cookieDate#">
		<cfelseif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getWidgetUrl()))>
			<cfset frameSrc = (cgi.https EQ 'on' ? 'https' : 'http')&'://'&cgi.Server_Name&'/search/index.cfm?'&rc.filter.getWidgetUrl()&'&token=#session.cookieToken#&date=#session.cookieDate#' />
		<cfelse>
			<cfset frameSrc = application.searchWidgetURL  & '?acctid=#rc.filter.getAcctID()#&userid=#rc.filter.getUserId()#&token=#session.cookieToken#&date=#session.cookieDate#' />
		</cfif>
		<h2><a href="##" class="change-search searchModalButton" data-framesrc="#frameSrc#&amp;modal=true&amp;requery=true&amp;" title="Search again"><i class="fa fa-search"></i> Change Search</a></h2>
	</cfif>

	<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare")>
		#View('air/legs')#
	</cfif>
</div>

<div id="aircontent">
	<cfif structKeyExists(session.searches[rc.SearchID].stAvailDetails, "aSortDuration") AND structKeyExists(session.searches[rc.SearchID].stAvailDetails.aSortDuration, rc.Group)>
		<div id="hidefilterfromprint">
			#View('air/filter')#
		</div>
		<!--- setup ArrayToLoop = array of leg nTripIDs --->
		<cfif (rc.Group EQ 0 AND rc.Filter.getDepartTimeType() IS 'A') OR (rc.Group EQ 1 AND rc.Filter.getArrivalTimeType() IS 'A')>
			<cfset arrayToLoop = session.searches[rc.SearchID].stAvailDetails.aSortArrivalPreferred[rc.Group] />
		<cfelse>
			<cfset arrayToLoop = session.searches[rc.SearchID].stAvailDetails.aSortDepartPreferred[rc.Group] />
		</cfif>

		<cfset variables.nCount = 0>
		<div class="grid-view container hidden">
		<cfloop array="#arrayToLoop#" index="variables.nTripKey">
			<cfset variables.nCount = 0>

			 <cfif StructKeyExists(rc, "southWestMatch") AND rc.southWestMatch EQ true>
				<!--- if they originally picked a southwest flight - only show southwest for other leg(s) --->
				<cfif session.searches[rc.SearchID].stAvailTrips[rc.Group][nTripKey].carriers[1] EQ "WN">
					<cfset variables.stTrip = session.searches[rc.SearchID].stAvailTrips[rc.Group][nTripKey]>

						<cfset nCount++>
						#View('air/badge')#

				</cfif>
			<cfelseif StructKeyExists(rc, "firstSelectedGroup")>
				<!--- if this is not the first segment selected - hide southwest as it can't be booked with other carriers --->
				<cftry>
					<cfif session.searches[rc.SearchID].stAvailTrips[rc.Group][nTripKey].carriers[1] NEQ "WN">
					<cfset variables.stTrip = session.searches[rc.SearchID].stAvailTrips[rc.Group][nTripKey]>

						<cfset nCount++>
						#View('air/badge')#

				</cfif>
				<cfcatch type="any"></cfcatch>
				</cftry>
			<cfelse>
				<!--- this is first view so show everything --->
				<cfset variables.stTrip = session.searches[rc.SearchID].stAvailTrips[rc.Group][nTripKey]>

					<cfset nCount++>
					#View('air/badge')#

			</cfif>
		</cfloop>
		</div> <!-- //.container -->

		<div class="list-view container hidden">
			<br />
			<cfloop array="#arrayToLoop#" index="variables.nTripKey">
				<cfset variables.nCount = 0>

				 <cfif StructKeyExists(rc, "southWestMatch") AND rc.southWestMatch EQ true>
					<!--- if they originally picked a southwest flight - only show southwest for other leg(s) --->
					<cfif session.searches[rc.SearchID].stAvailTrips[rc.Group][nTripKey].carriers[1] EQ "WN">
						<cfset variables.stTrip = session.searches[rc.SearchID].stAvailTrips[rc.Group][nTripKey]>

							<cfset nCount++>
							#View('air/list')#

					</cfif>
				<cfelseif StructKeyExists(rc, "firstSelectedGroup")>
					<!--- if this is not the first segment selected - hide southwest as it can't be booked with other carriers --->
					<cftry>
						<cfif session.searches[rc.SearchID].stAvailTrips[rc.Group][nTripKey].carriers[1] NEQ "WN">
						<cfset variables.stTrip = session.searches[rc.SearchID].stAvailTrips[rc.Group][nTripKey]>

							<cfset nCount++>
							#View('air/list')#

					</cfif>
					<cfcatch type="any"></cfcatch>
					</cftry>
				<cfelse>
					<!--- this is first view so show everything --->
					<cfset variables.stTrip = session.searches[rc.SearchID].stAvailTrips[rc.Group][nTripKey]>

						<cfset nCount++>
						#View('air/list')#

				</cfif>
			</cfloop>
		</div>

		<script type="application/javascript">
			// define for sorting ( see air/filter.js and booking.js airSort() )
			var sortbyarrival = #SerializeJSON(session.searches[rc.SearchID].stAvailDetails.aSortArrival[rc.Group])#;
			var sortbydeparture = #SerializeJSON(session.searches[rc.SearchID].stAvailDetails.aSortDepart[rc.Group])#;
			var sortbyduration = #SerializeJSON(session.searches[rc.SearchID].stAvailDetails.aSortDuration[rc.Group])#;
			var sortbyprice = '';
			var sortbyprice1bag = '';
			var sortbyprice2bag = '';

			// define for filtering
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
			<p>No flights are available for your filtered criteria. <a href="##" class="removefilters"><i class="fa fa-refresh"></i> Clear Filters</a> to see all results.</p>
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

<!--- <cfscript>

	writeDump(session.KrakenSearchResults.RemovedFlightSearchResults);

</cfscript> --->

	<!--- submitted when badge button is pressed via JS --->
	<form method="post" action="#buildURL('air.availability')#" id="availabilityForm">
		<input type="hidden" name="bSelect" value="1">
		<input type="hidden" name="SearchID" value="#rc.SearchID#">
		<input type="hidden" name="nTrip" id="nTrip" value="">
		<input type="hidden" name="Group" value="#rc.Group#">
	</form>

	#View('modal/popup')#
</cfoutput>
