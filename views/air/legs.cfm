<cfoutput>
	<div class="roundtrip clearfix">
		<cfset nCount = ArrayLen(rc.Filter.getLegs())-1>
		<cfloop array="#rc.Filter.getLegs()#" index="nLeg" item="sLeg">
			<a href="#buildURL('air.availability?SearchID=#rc.Filter.getSearchID()#&Group=#nLeg-1#')#" class="btn" title="#sLeg#">
				<cfif NOT StructIsEmpty(session.searches[rc.SearchID].stSelected[nLeg-1])>
					<i class="icon-ok"></i>
				</cfif>
				#sLeg#
			</a>
		</cfloop>
	</div>
</cfoutput>