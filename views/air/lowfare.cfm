<cfset variables.aAllCabins = ["Y","C","F"]>
<cfset variables.aMyCabins = ListToArray(Replace(LCase(StructKeyList(session.searches[rc.nSearchID].stPricing)), 'f', 'F'))>
<cfset ArraySort(aMyCabins, "text", "desc")>
<cfset variables.aRef = ["0","1"]>
<cfset variables.aRef = ["0"]>
<cfoutput>
	#View('air/legs')#
	#View('air/filter')#
</cfoutput>
<br clear="both">
<cfoutput>
	<div id="aircontent">
		<cfif structKeyExists(session.searches[rc.Search_ID], "stSortFare")>
			<cfset variables.bLinks = 1><!--- Let the view know whether there should be active links or not --->
			<cfloop array="#session.searches[rc.Search_ID].stSortFare#" index="variables.sTrip">
				<cfset variables.stTrip = session.searches[rc.Search_ID].stTrips[variables.sTrip]>
				#View('air/badge')#
			</cfloop>
		</cfif>
	</div>
	<cfif structKeyExists(session.searches[rc.Search_ID], "stSortFare")>
		<script type="application/javascript">
		var sortarrival = #SerializeJSON(session.searches[rc.nSearchID].stSortArrival)#;
		var sortdepart = #SerializeJSON(session.searches[rc.nSearchID].stSortDepart)#;
		var sortfare = #SerializeJSON(session.searches[rc.nSearchID].stSortFare)#;
		var sortduration = #SerializeJSON(session.searches[rc.nSearchID].stSortDuration)#;
		var sortbag = #SerializeJSON(session.searches[rc.nSearchID].stSortBag)#;
		var flightresults = [<cfset nCount = 0><cfloop array="#session.searches[rc.Search_ID].stSortFare#" index="sTrip"><cfset nCount++>[#session.searches[rc.Search_ID].stTrips[sTrip].sJavascript#]<cfif ArrayLen(session.searches[rc.Search_ID].stSortFare) NEQ nCount>,</cfif></cfloop>];
		$(document).ready(function() {
			filterAir();
		});
		</script>

	</cfif>
</cfoutput>