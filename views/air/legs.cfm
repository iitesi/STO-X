<cfoutput>
	<div class="legs clearfix">
		<!--- legs start with 1, groups start with 0 --->
		<cfloop array="#rc.Filter.getLegsForTrip()#" item="nLeg" index="nLegIndex">
			<cfif structKeyExists(rc,"group") AND rc.group EQ nLegIndex-1>
				<span class="btn btn-primary legbtn">#nLeg#</span>
			<cfelse>
				<a href="#buildURL('air.availability?SearchID=#rc.Filter.getSearchID()#&Group=#nLegIndex-1#')#" class="btn legbtn airModal" data-modal="Flights for #nLeg#." title="#nLeg#">
				<!--- Show icon indicating this is the leg they selected --->
				<cfif NOT StructIsEmpty(session.searches[rc.SearchID].stSelected[nLegIndex-1])><i class="icon-ok"></i></cfif>
				#nLeg#</a>
			</cfif>
		</cfloop>
	</div>
</cfoutput>