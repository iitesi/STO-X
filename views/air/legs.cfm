<cfoutput>
	<div class="legs clearfix">
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