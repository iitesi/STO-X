<cfif listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID())>
	<cftry>
		<cfif rc.view EQ 'trips'>
			<cfdump var="#session.searches[rc.searchID].stTrips#">
		<cfelseif rc.view EQ 'avail'>
			<cfdump var="#session.searches[rc.searchID].stAvailTrips#">
		<cfelseif rc.view EQ 'cars'>
			<cfdump var="#session.searches[rc.searchID].stCars#">
		<cfelseif rc.view EQ 'travelers'>
			<cfdump var="#session.searches[rc.searchID].Travelers#">
		</cfif>
	<cfcatch>
		View not found
	</cfcatch>
	</cftry>
</cfif>