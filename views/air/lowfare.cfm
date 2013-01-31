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
<cfoutput>
	<form method="post" action="#buildURL('air.lowfare')#" id="lowfareForm">
		<input type="hidden" name="bSelect" value="1">
		<input type="hidden" name="SearchID" value="#rc.SearchID#">
		<input type="hidden" name="nTrip" id="nTrip" value="">
	</form>	
	<cfif structKeyExists(session.searches[rc.SearchID], 'sUserMessage')>
		<div id="usermessage" class="error">#session.searches[rc.SearchID].sUserMessage#</div>
		<cfset structDelete(session.searches[rc.SearchID], 'sUserMessage')>
	</cfif>
	<cfset variables.bDisplayFare = true>
	<cfset variables.nLegs = ArrayLen(rc.Filter.getLegs())>
	<cfif nLegs EQ 2>
		<cfset variables.minheight = 345>
	<cfelseif nLegs EQ 1>
		<cfset variables.minheight = 225>
	<cfelseif nLegs EQ 3>
		<cfset variables.minheight = 395>
	</cfif>
	<!---<cfdump var="#session.searches[rc.searchid].sttrips#">--->
	<cfset variables.nDisplayGroup = ''>
	<div id="aircontent">
		<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare")>
			<!--- Display selected badges (selected via schedule search) --->
			<cfset variables.bSelected = true>
			<cfset variables.nCount = 0>
			<cfloop collection="#session.searches[rc.SearchID].stLowFareDetails.stPriced#" item="variables.nTripKey">
				<cfset variables.stTrip = session.searches[rc.SearchID].stTrips[nTripKey]>
				<cfset nCount++>
				#View('air/badge')#
			</cfloop>
			<!--- Display standard fare based search --->
			<cfset bSelected = false>
			<cfloop array="#session.searches[rc.SearchID].stLowFareDetails.aSortFare#" index="variables.nTripKey">
				<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPriced, nTripKey) AND nCount LTE 50>
					<cfset variables.stTrip = session.searches[rc.SearchID].stTrips[nTripKey]>
					<cfset nCount++>
					#View('air/badge')#
				</cfif>
			</cfloop>
		</cfif>
	</div>
	<!--- <cfdump var="#session.searches[rc.SearchID].sttrips#">
	<cfdump var="#session.searches[rc.SearchID].stLowFareDetails.stpricing#"> --->
	<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare")>
		<script type="application/javascript">
		var sortarrival = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortArrival)#;
		var sortdepart = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortDepart)#;
		var sortfare = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortFare)#;
		var sortduration = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortDuration)#;
		var sortbag = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortBag)#;
		var flightresults = [
			<cfset nCount = 0>
			<cfloop array="#session.searches[rc.SearchID].stLowFareDetails.aSortFare#" index="sTrip">
				<cfif nCount NEQ 0>,</cfif>[#session.searches[rc.SearchID].stTrips[sTrip].sJavascript#]
				<cfset nCount++>
			</cfloop>];
		$(document).ready(function() {
			setTimeout(function(){
					$("##usermessage").fadeOut("slow", function () {
					$("##usermessage").remove();
				});
			}, 4000);
			filterAir();
		});
		</script>
	</cfif>
</cfoutput>