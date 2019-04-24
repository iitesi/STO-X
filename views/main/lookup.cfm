<cfdump var="#rc.Filter.getUserID()#">

	<cftry>
		<cfif rc.view EQ 'trips'>
			<cfdump var="#session.searches[rc.searchID].stTrips#">
		<cfelseif rc.view EQ 'avail'>
			<cfdump var="#structKeyList(session.searches[rc.searchID].stAvailTrips[0])#" label="Group 0 keys">
			<cfdump var="#structKeyList(session.searches[rc.searchID].stAvailTrips[1])#" label="Group 1 keys">
			<cfdump var="#structKeyList(session.searches[rc.searchID].stAvailTrips[2])#" label="Group 2 keys">
			<cfdump var="#structKeyList(session.searches[rc.searchID].stAvailTrips[3])#" label="Group 3 keys">
		<cfelseif rc.view EQ 'storage'>
			<cfdump var="#structKeyList(session.storage)#" label="Storage">
			<cfdump var="#session.storage#" label="Storage">
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