<cfsilent>
	<cfset popoverTitle = "Fly roundtrip for as low as $#NumberFormat(session.searches[rc.SearchID].stTrips[session.searches[rc.SearchID].stLowFareDetails.aSortFare[1]].total)#">
	<cfset popoverContent = "Select a flight below or select individual legs by selecting a button to the right.">
	<cfset popoverLink = "">
	<cfif structKeyExists(rc, "group")>
		<cfset popoverTitle = "">
		<cfset popoverContent = "">
		<cfset popoverLink = ""> <!--- back to price page --->
	</cfif>
</cfsilent>

<cfoutput>
	<div class="legs clearfix">
		<cfif structKeyExists(session.searches[rc.SearchID], "stTrips")
			AND structKeyExists(session.searches[rc.SearchID], "stLowFareDetails")
			ANd structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare")>
			<span class="btn btn-primary legbtn popuplink" rel="poptop" data-original-title="#popoverTitle#" data-content="#popoverContent#">Roundtrip From $#NumberFormat(session.searches[rc.SearchID].stTrips[session.searches[rc.SearchID].stLowFareDetails.aSortFare[1]].total)#</span>
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