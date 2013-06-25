<!---How many searches include air?--->
<cfset nAirCount = 0>
<cfloop collection="#session.filters#" index="filterSearchID">
	<cfif session.filters[filterSearchID].getAir()>
		<cfset nAirCount++>
	</cfif>
</cfloop>

<cfset nTempCount = 0>

<cfoutput>
	<ul class="breadcrumb upper">
	<cfloop collection="#session.filters#" index="filterSearchID">
			<cfif session.filters[filterSearchID].getAir()>
				<cfset nTempCount++>
				<li>
					<cfif filterSearchID EQ rc.SearchID>
						#session.filters[filterSearchID].getHeading()#
					<cfelse>
						<a href="#buildURL('air.lowfare?SearchID=#filterSearchID#')#" title="Click to view this search">#session.filters[filterSearchID].getHeading()#</a>
					</cfif>
					&nbsp;<a href="#buildURL('air.removeflight?SearchID=#filterSearchID#')#" title="Click to remove this flight from your saved searches"><i class="icon-remove"></i></a>
					<cfif nAirCount NEQ nTempCount><span class="divider">/</span></cfif>
				</li>
			</cfif>
		</cfloop>
	</ul>
</cfoutput>
