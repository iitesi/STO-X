<cfoutput>
	<!--- #view('air/unusedtickets')# --->
	<div class="page-header">
		#View('air/legs')#
	</div>
	<div id="aircontent">
		<div class="list-view container" id="listcontainer">
			#View('air/itinerary')#
		</div>
	</div>
</cfoutput>

<cfdump var=#session.Searches[rc.SearchID].Selected#>