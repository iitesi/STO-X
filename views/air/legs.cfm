<cfoutput>
	<div class="roundtrip">
		<cfset nCount = ArrayLen(rc.Filter.getLegs())-1>
		<cfloop array="#rc.Filter.getLegs()#" index="nLeg" item="sLeg">
				<a href="#buildURL('air.availability?SearchID=#rc.Filter.getSearchID()#&Group=#nLeg#')#">
				<div class="leg"><!--- class="<cfif rc.nGroup EQ nLeg>selected</cfif>"--->
					<cfif NOT StructIsEmpty(session.searches[rc.SearchID].stSelected[nLeg])>
						<img src="assets/img/checkmark.png">
					</cfif>
					#sLeg#
				</div>
			</a>
		</cfloop>
	</div>
	<br clear="all">
	<!---<ul class="smallnav">
		<li class="main">Display As
			<cfoutput>
				<ul>
					<li><a href="?action=air.availability&SearchID=#rc.SearchID#&nGroup=#rc.nGroup#">Badge</a></li>
					<li><a href="?action=air.timeline&SearchID=#rc.SearchID#&nGroup=#rc.nGroup#">Timeline</a></li>
				</ul>
			</cfoutput>
		</li>
	</ul>--->
</cfoutput>