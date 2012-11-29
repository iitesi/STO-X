<cfoutput>
	#View('air/legs')#
	#View('air/filter')#
</cfoutput>
<br clear="both">
<cfoutput>
	<div id="aircontent">
		<cfif structKeyExists(session.searches[rc.Search_ID].stAvailDetails.stSortSegments, rc.Group)>

			<cfset variables.bLinks = 1><!--- Let the view know whether there should be active links or not --->
			<cfloop array="#session.searches[rc.Search_ID].stAvailDetails.stSortSegments[rc.Group]#" index="variables.sTrip">

				<cfset variables.stTrip = session.searches[rc.Search_ID].stAvailTrips[rc.Group][variables.sTrip]>
				<cfset variables.minwidth = 225>
				<cfset variables.id = sTrip&'XX'>
				
				#View('air/badge')#
				
			</cfloop>

		</cfif>
	</div>
	<cfif structKeyExists(session.searches[rc.Search_ID].stAvailDetails.stSortSegments, rc.Group)>
		<!--- var sortarrival = #SerializeJSON(session.searches[rc.nSearchID].stAvailDetails.aSortArrival)#;
		var sortdepart = #SerializeJSON(session.searches[rc.nSearchID].stAvailDetails.aSortDepart)#;
		var sortduration = #SerializeJSON(session.searches[rc.nSearchID].stAvailDetails.aSortDuration)#; --->
		<script type="application/javascript">
		var flightresults = [<cfset nCount = 0><cfloop array="#session.searches[rc.Search_ID].stAvailDetails.stSortSegments[rc.Group]#" index="sTrip"><cfset nCount++>[#session.searches[rc.Search_ID].stAvailTrips[rc.Group][variables.sTrip].sJavascript#]<cfif ArrayLen(session.searches[rc.Search_ID].stAvailDetails.stSortSegments[rc.Group]) NEQ nCount>,</cfif></cfloop>];
		$(document).ready(function() {
			filterAir();
		});
		</script>
	</cfif>
</cfoutput>