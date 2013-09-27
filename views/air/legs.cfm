<cfset backCount = 1>
<!--- if multicity we need to go back one more because in the getLegs array the first item is a query, not a leg --->
<cfif rc.Filter.getAirType() IS "MD">
	<cfset backCount = 2>
</cfif>

<cfoutput>
	<div class="legs clearfix">
		<cfloop array="#rc.Filter.getLegs()#" index="nLeg" item="sLeg">
			<!--- array could contain query - we just want strings --->
			<cfif isSimpleValue(sLeg)>

				<cfif structKeyExists(rc,"group") AND rc.group EQ nLeg-backCount>
					<span class="btn btn-primary legbtn">#sLeg#</span>
				<cfelse>
					<a href="#buildURL('air.availability?SearchID=#rc.Filter.getSearchID()#&Group=#nLeg-backCount#')#" class="btn legbtn airModal" data-modal="Flights for #sLeg#." title="#sLeg#">
					<!--- Show icon indicating this is the leg they selected --->
					<cfif NOT StructIsEmpty(session.searches[rc.SearchID].stSelected[nLeg-backCount])><i class="icon-ok"></i></cfif>
					#sLeg#</a>
				</cfif>
			</cfif>
		</cfloop>
	</div>


</cfoutput>