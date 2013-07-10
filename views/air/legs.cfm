<cfoutput>
	<div class="legs clearfix">
		<cfloop array="#rc.Filter.getLegs()#" index="nLeg" item="sLeg">
			<!--- array could contain query - we just want strings --->
			<cfif isSimpleValue(sLeg)>
				<cfset active = "">
				<cfif structKeyExists(rc,"group") AND rc.group EQ nLeg-1>
					<cfset active = "btn-primary">
				</cfif>
				<a href="#buildURL('air.availability?SearchID=#rc.Filter.getSearchID()#&Group=#nLeg-1#')#" class="btn legbtn #active#" title="#sLeg#">
					<!--- Show icon indicating this is the leg they selected --->
					<cfif NOT StructIsEmpty(session.searches[rc.SearchID].stSelected[nLeg-1])><i class="icon-ok"></i></cfif>
					#sLeg#</a>
			</cfif>
		</cfloop>
	</div>
</cfoutput>