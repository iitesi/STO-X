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
			<cfloop collection="#session.searches[rc.searchID].Travelers#" index="local.travelerNumber" item="local.Traveler">
				<cfdump var="#Traveler.getBookingDetail()#">
			</cfloop>
		</cfif>
	<cfcatch>
		View not found
	</cfcatch>
	</cftry>
</cfif>