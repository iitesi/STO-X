<cfset variables.aCabins = ["Y","C","F"]>
<cfset variables.aRef = ["0","1"]>
<cfoutput>
	#View('air/legs')#
	#View('air/filter')#
</cfoutput>
<br clear="both">
<cfoutput>
	<div id="aircontent">
		<cfif structKeyExists(session.searches[rc.Search_ID].stLowFareDetails, "aSortFare")>

			<cfset variables.bLinks = 1><!--- Let the view know whether there should be active links or not --->
			<cfset variables.minwidth = 345>

			<cfif structKeyExists(session.searches[rc.Search_ID].stLowFareDetails, 'aPriced')>
				<cfloop array="#session.searches[rc.Search_ID].stLowFareDetails.aPriced#" index="variables.sTrip">

					<cfset variables.stTrip = session.searches[rc.Search_ID].stTrips[variables.sTrip]>
								
					#View('air/badge')#
					
				</cfloop>
			</cfif>

			<cfloop array="#session.searches[rc.Search_ID].stLowFareDetails.aSortFare#" index="variables.sTrip">
				<cfif NOT structKeyExists(session.searches[rc.Search_ID].stLowFareDetails, 'aPriced')
				OR NOT ArrayFind(session.searches[rc.nSearchID].stLowFareDetails.aPriced, variables.sTrip)>
					<cfset variables.stTrip = session.searches[rc.Search_ID].stTrips[variables.sTrip]>
								
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
			filterAir();
		});
		</script>

	</cfif>
</cfoutput>