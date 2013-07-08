<cfoutput>
	<div class="legs clearfix">
		<cfloop array="#rc.Filter.getLegs()#" index="nLeg" item="sLeg">
			<cfif isSimpleValue(sLeg)>
				<!--- array could contain query - we just want strings --->
				<a href="#buildURL('air.availability?SearchID=#rc.Filter.getSearchID()#&Group=#nLeg-1#')#" class="btn legbtn" title="#sLeg#">
					<cfif NOT StructIsEmpty(session.searches[rc.SearchID].stSelected[nLeg-1])>
						<i class="icon-ok"></i>
					</cfif>
					#sLeg#
				</a>
			</cfif>
		</cfloop>
	</div>
</cfoutput>