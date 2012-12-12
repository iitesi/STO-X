<cfoutput>
	#View('air/legs')#
	#View('air/filter')#
</cfoutput>
<br clear="both">
<cfoutput>
	<cfoutput>
		<form method="post" action="#buildURL('air.lowfare')#" id="lowfareForm">
			<input type="hidden" name="bSelect" value="1">
			<input type="hidden" name="Search_ID" value="#rc.nSearchID#">
			<input type="hidden" name="nTrip" id="nTrip" value="">
		</form>	
	</cfoutput>
	<cfif structKeyExists(session.searches[rc.Search_ID], 'sUserMessage')>
		<div id="usermessage" class="error">#session.searches[rc.Search_ID].sUserMessage#</div>
		<cfset structDelete(session.searches[rc.Search_ID], 'sUserMessage')>
	</cfif>
	<cfset bDisplayFare = true>
	<cfset nLegs = ArrayLen(StructKeyArray(session.searches[rc.Search_ID].stLegs))>
	<cfif nLegs EQ 2>
		<cfset minheight = 345>
	<cfelseif nLegs EQ 1>
		<cfset minheight = 225>
	<cfelseif nLegs EQ 3>
		<cfset minheight = 395>
	</cfif>
	<cfset nDisplayGroup = ''>
	<div id="aircontent">
		<cfif structKeyExists(session.searches[rc.Search_ID].stLowFareDetails, "aSortFare")>
			<!--- Display selected badges (selected via schedule search) --->
			<cfset bSelected = true>
			<cfloop collection="#session.searches[rc.Search_ID].stLowFareDetails.stPriced#" item="nTripKey">
				<cfset stTrip = session.searches[rc.Search_ID].stTrips[nTripKey]>
				#View('air/badge')#
			</cfloop>
			<!--- Display standard fare based search --->
			<cfset bSelected = false>
			<cfloop array="#session.searches[rc.Search_ID].stLowFareDetails.aSortFare#" index="nTripKey">
				<cfif NOT StructKeyExists(session.searches[rc.nSearchID].stLowFareDetails.stPriced, nTripKey)>
					<cfset stTrip = session.searches[rc.Search_ID].stTrips[nTripKey]>
					#View('air/badge')#
				</cfif>
			</cfloop>
		</cfif>
	</div>
	<cfif structKeyExists(session.searches[rc.Search_ID].stLowFareDetails, "aSortFare")>
		<script type="application/javascript">
		var sortarrival = #SerializeJSON(session.searches[rc.nSearchID].stLowFareDetails.aSortArrival)#;
		var sortdepart = #SerializeJSON(session.searches[rc.nSearchID].stLowFareDetails.aSortDepart)#;
		var sortfare = #SerializeJSON(session.searches[rc.nSearchID].stLowFareDetails.aSortFare)#;
		var sortduration = #SerializeJSON(session.searches[rc.nSearchID].stLowFareDetails.aSortDuration)#;
		var sortbag = #SerializeJSON(session.searches[rc.nSearchID].stLowFareDetails.aSortBag)#;
		var flightresults = [
			<cfset nCount = 0>
			<cfloop array="#session.searches[rc.Search_ID].stLowFareDetails.aSortFare#" index="sTrip">
				<cfif nCount NEQ 0>,</cfif>[#session.searches[rc.Search_ID].stTrips[sTrip].sJavascript#]
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