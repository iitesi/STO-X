<cfoutput>
<div id="legs" class="legs clearfix">
	<div class="sixteen columns">
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

		<div class="printlink pull-right">
			<cfoutput>
				<a href="#buildURL('air.print&SearchID=#rc.SearchID#')#" target="_blank"} title="Click for printer friendly version"><i class="icon-print"></i> Print</a>
			</cfoutput>
		</div>
	</div>
</div>
</cfoutput>