<div class="page-header">
<cfoutput>
        <h1><a href="#buildURL('air.lowfare&SearchID=#rc.SearchID#')#">#UCase(rc.Filter.getHeading())#</a></h1>
</cfoutput>
</div>
<cfoutput>
	#View('air/legs')#
	#View('air/filter')#
</cfoutput>
<br clear="both">
<div id="aircontent">
	<cfoutput>
		<form method="post" action="#buildURL('air.availability')#" id="availabilityForm">
			<input type="hidden" name="bSelect" value="1">
			<input type="hidden" name="SearchID" value="#rc.SearchID#">
			<input type="hidden" name="nTrip" id="nTrip" value="">
			<input type="hidden" name="Group" value="#rc.Group#">
		</form>	
	</cfoutput>
	<cfif structKeyExists(session.searches[rc.SearchID].stAvailDetails.aSortDuration, rc.Group)>
		<cfset variables.minheight = 225>
		<cfset variables.bSelected = false>
		<cfset variables.bDisplayFare = false>
		<cfset variables.nDisplayGroup = rc.Group>
		<cfset variables.nCount = 0>
		<cfloop array="#session.searches[rc.SearchID].stAvailDetails.aSortDuration[rc.Group]#" index="variables.nTripKey">
			<cfset variables.stTrip = session.searches[rc.SearchID].stAvailTrips[rc.Group][nTripKey]>
			<cfoutput>#View('air/badge')#</cfoutput>
		</cfloop>
		<script type="application/javascript">
		var sortarrival = <cfoutput>#SerializeJSON(session.searches[rc.SearchID].stAvailDetails.aSortArrival[rc.Group])#;</cfoutput>
		var sortdepart = <cfoutput>#SerializeJSON(session.searches[rc.SearchID].stAvailDetails.aSortDepart[rc.Group])#;</cfoutput>
		var sortduration = <cfoutput>#SerializeJSON(session.searches[rc.SearchID].stAvailDetails.aSortDuration[rc.Group])#;</cfoutput>
		var flightresults = [
			<cfset nCount = 0>
			<cfloop array="#session.searches[rc.SearchID].stAvailDetails.aSortDepart[rc.Group]#" index="sTrip">
				<cfset nCount++>
				<cfoutput>
					[#session.searches[rc.SearchID].stAvailTrips[rc.Group][sTrip].sJavascript#]
				</cfoutput>
				<cfif ArrayLen(session.searches[rc.SearchID].stAvailDetails.aSortDepart[rc.Group]) NEQ nCount>,</cfif>
			</cfloop>
		];
		$(document).ready(function() {
			filterAir();
		});
		</script>
	</cfif>
</div>