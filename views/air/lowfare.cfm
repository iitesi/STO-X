<cfsilent>
	<cfset variables.bDisplayFare = true>
	<cfset variables.nLegs = ArrayLen(rc.Filter.getLegs())>
	<cfif nLegs EQ 2>
		<cfset variables.minheight = 325>
	<cfelseif nLegs EQ 1>
		<cfset variables.minheight = 225>
	<cfelseif nLegs EQ 3>
		<cfset variables.minheight = 395>
	</cfif>
</cfsilent>

<cfoutput>
	<div class="page-header">
		<cfif rc.filter.getAirType() IS "MD">
			<h1>#UCase(rc.Filter.getAirHeading())#</h1>
			<ul  class="unstyled">
				<cfloop array="#rc.filter.getLegsHeader()#" index="nLeg" item="sLeg">
					<li><h2>#ListFirst(sLeg, '::')# <small>:: #ListLast(sLeg, "::")#<small></h2></li>
				</cfloop>
			</ul>
		<cfelse>
			<h1>
				<a href="#buildURL('air.lowfare&SearchID=#rc.SearchID#')#">
					#ListFirst(UCase(rc.Filter.getAirHeading()), "::")#
					<small>:: #ListLast(UCase(rc.Filter.getAirHeading()), "::")#</small>
				</a>
			</h1>
		</cfif>
	</div>

	<form method="post" action="#buildURL('air.lowfare')#" id="lowfareForm">
		<input type="hidden" name="bSelect" value="1">
		<input type="hidden" name="SearchID" value="#rc.SearchID#">
		<input type="hidden" name="nTrip" id="nTrip" value="">
	</form>

	<cfif structKeyExists(session.searches[rc.SearchID], 'sUserMessage')>
		<div id="usermessage" class="error">#session.searches[rc.SearchID].sUserMessage#</div>
		<cfset structDelete(session.searches[rc.SearchID], 'sUserMessage')>
	</cfif>

	<cfset variables.nDisplayGroup = ''>
	<div id="aircontent">
		<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare")>

			#View('air/legs')#
			#View('air/filter')#

			<br clear="both">

			<!--- Display selected badges (selected via schedule search) --->
			<cfset variables.bSelected = true>
			<cfset variables.nCount = 0>
			<cfloop collection="#session.searches[rc.SearchID].stLowFareDetails.stPriced#" item="variables.nTripKey">
				<cfset variables.stTrip = session.searches[rc.SearchID].stTrips[nTripKey]>
				<cfset nCount++>
				#View('air/badge')#
			</cfloop>

			<!--- Display standard fare based search --->
			<cfset variables.bSelected = false>
			<cfloop array="#session.searches[rc.SearchID].stLowFareDetails.aSortFare#" index="variables.nTripKey">
				<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPriced, nTripKey) AND nCount LTE 50>
					<cfset variables.stTrip = session.searches[rc.SearchID].stTrips[nTripKey]>
					<cfset nCount++>
					#View('air/badge')#
				</cfif>
			</cfloop>

			<script type="application/javascript">

// TODO:  I have no idea why any of these sort vars are being set -= they are referenced no where else but here?
// 2:26 PM Thursday, June 13, 2013 - Jim Priest - jpriest@shortstravel.com
//
// 			var sortarrival = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortArrival)#;
// 			var sortdepart = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortDepart)#;
// 			var sortfare = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortFare)#;
// 			var sortduration = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortDuration)#;
// 			var sortbag = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortBag)#;


			var flightresults = [
				<cfset nCount = 0>
				<cfloop array="#session.searches[rc.SearchID].stLowFareDetails.aSortFare#" index="sTrip">
					<cfif nCount NEQ 0>,</cfif>[#session.searches[rc.SearchID].stTrips[sTrip].sJavascript#]
					<cfset nCount++>
				</cfloop>];

			$(document).ready(function() {
				// setTimeout(function(){
				// 		$("##usermessage").fadeOut("slow", function () {
				// 		$("##usermessage").remove();
				// 	});
				// }, 4000);
			});
			</script>
		<cfelse>
			<h3>No Flights Returned</h2>

<!--- TODO: set change search modal window form link
7:02 PM Monday, June 10, 2013 - Jim Priest - jpriest@shortstravel.com
 --->
			<p>There were no flights found based on your search criteria. Please <a href="">change your search</a> and try again.</p>
		</cfif>
	</div>
</cfoutput>