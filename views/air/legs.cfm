<cfsilent>
	<cfset popoverTitle = "Fly roundtrip for as low as $#NumberFormat(session.searches[rc.SearchID].stTrips[session.searches[rc.SearchID].stLowFareDetails.aSortFare[1]].total)#">
	<cfset popoverContent = "Select a flight below or select individual legs by selecting a button to the right.">
	<cfset popoverLink = "##">
	<cfset popoverButtonClass = "btn-primary">

	<cfif structKeyExists(rc, "group") AND Len(rc.group)>
		<cfset popoverTitle = "">
		<cfset popoverContent = "Click to return to main search results">
		<cfset popoverLink = "index.cfm?action=air.lowfare&SearchID=#rc.searchID#&clearSelected=1"> <!--- back to price page --->
		<cfset popoverButtonClass = "">
	</cfif>

	<cfif StructKeyExists(rc, "clearSelected") AND rc.clearSelected EQ 1>
		<cfset session.searches[rc.SearchID].stSelected = StructNew('linked')><!--- Place holder for selected legs --->
		<cfset session.searches[rc.SearchID].stSelected[0] = {}>
		<cfset session.searches[rc.SearchID].stSelected[1] = {}>
		<cfset session.searches[rc.SearchID].stSelected[2] = {}>
		<cfset session.searches[rc.SearchID].stSelected[3] = {}>
	</cfif>
</cfsilent>

<cfoutput>
	<div id="legs" class="legs clearfix">
		<cfif structKeyExists(session.searches[rc.SearchID], "stTrips")
			AND structKeyExists(session.searches[rc.SearchID], "stLowFareDetails")
			ANd structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare")>
			<a href="#popoverLink#" class="btn #popoverButtonClass# legbtn popuplink" rel="poptop" data-original-title="#popoverTitle#" data-content="#popoverContent#">Roundtrip From $#NumberFormat(session.searches[rc.SearchID].stTrips[session.searches[rc.SearchID].stLowFareDetails.aSortFare[1]].total)#</a>
		</cfif>

		<cfloop array="#rc.Filter.getLegsForTrip()#" index="nLegIndex" item="nLegItem">
			<cfif structKeyExists(rc,"group") AND rc.group EQ nLegIndex-1>
				<span class="btn btn-primary legbtn">#nLegItem#</span>
			<cfelse>
				<a href="#buildURL('air.availability?SearchID=#rc.Filter.getSearchID()#&Group=#nLegIndex-1#')#" class="btn legbtn airModal" data-modal="Flights for #nLegItem#." title="#nLegItem#">
				<!--- Show icon indicating this is the leg they selected --->
				<cfif NOT StructIsEmpty(session.searches[rc.SearchID].stSelected[nLegIndex-1])><i class="icon-ok"></i></cfif>
				#nLegItem#</a>
			</cfif>
		</cfloop>
	</div>
</cfoutput>