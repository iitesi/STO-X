<cfsilent>

	<cfset buttonPrice = "">

	<!--- if for some reason aSortFare or aSortFarePreferred is empty - we'll give the roundtrip button some friendly text w/no price --->
	<cfif structKeyExists(session.searches[rc.SearchID], "stLowFareDetails")>
		<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare")
			AND IsArray(session.searches[rc.SearchID].stLowFareDetails.aSortFare)
			AND ArrayLen(session.searches[rc.SearchID].stLowFareDetails.aSortFare) GT 0>
			<cfset buttonPrice = session.searches[rc.SearchID].stTrips[session.searches[rc.SearchID].stLowFareDetails.aSortFare[1]].total> 
		<cfelseif structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFarePreferred")
			AND IsArray(session.searches[rc.SearchID].stLowFareDetails.aSortFarePreferred)
			AND ArrayLen(session.searches[rc.SearchID].stLowFareDetails.aSortFarePreferred) GT 0>
			<cfset buttonPrice = session.searches[rc.SearchID].stTrips[session.searches[rc.SearchID].stLowFareDetails.aSortFarePreferred[1]].total>
		</cfif>
	</cfif>
	<cfif buttonPrice EQ "">
		<cfset popoverTitle = "View roundtrip fares">
		<cfset buttonText = "Roundtrip Fares">
	<cfelse>
		<cfif rc.Filter.getAirType() EQ 'OW'>
			<cfset popoverTitle = "Fly one-way for as low as $#NumberFormat( buttonPrice )#">
			<cfset buttonText = "One-Way From $#NumberFormat( buttonPrice )#">
		<cfelse>
			<cfset popoverTitle = "Fly roundtrip for as low as $#NumberFormat( buttonPrice )#">
			<cfset buttonText = "Roundtrip From $#NumberFormat( buttonPrice )#">
		</cfif>
	</cfif>

	<cfset popoverContent = "Select a flight below or select individual legs by selecting a button to the right.">
	<cfset popoverLink = "##">
	<cfset popoverButtonClass = "active">

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
		<ul class="nav nav-pills">

		<cfif rc.Filter.getAirType() NEQ 'OW' AND rc.Filter.getAirType() NEQ 'MD'>
			<cfloop array="#rc.Filter.getLegsForTrip()#" index="nLegIndex" item="nLegItem">
				<cfif structKeyExists(rc,"group") AND rc.group EQ nLegIndex-1>
					<li role="presentation" class="active"><a href="">#nLegItem#</a></li>
				<cfelse>
					<li role="presentation"><a href="#buildURL('air.availability?SearchID=#rc.Filter.getSearchID()#&Group=#nLegIndex-1#')#" class="airModal" data-modal="Flights for #nLegItem#." title="#nLegItem#">
					<!--- Show icon indicating this is the leg they selected --->
					<cfif NOT StructIsEmpty(session.searches[rc.SearchID].stSelected[nLegIndex-1])><i class="icon-ok"></i></cfif>
					#nLegItem#</a></li>
				</cfif>
			</cfloop>
		</cfif>
		<cfif structKeyExists(session.searches[rc.SearchID], "stTrips")
			AND structKeyExists(session.searches[rc.SearchID], "stLowFareDetails")
			ANd structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare")>
			<li role="presentation" class="#popoverButtonClass#"><a href="#popoverLink#" <cfif popoverButtonClass EQ 'active'>class=" legbtn"<cfelse>class="airModal legbtn"</cfif> rel="poptop" data-modal="Roundtrip Flights" data-original-title="#popoverTitle#" data-content="#popoverContent#">#buttonText#</a></li>
		</cfif>
		</ul>
	</div>
</cfoutput>
