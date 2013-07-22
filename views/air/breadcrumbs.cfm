<!---How many searches include air?--->
<cfset nAirCount = 0>
<cfset nTempCount = 0>

<cfloop collection="#session.filters#" index="filterSearchID">
	<cfif session.filters[filterSearchID].getAir()>
		<cfset nAirCount++>
	</cfif>
</cfloop>


<cfoutput>
	<ul class="breadcrumb upper">
	<cfloop collection="#session.filters#" index="filterSearchID">
			<cfif session.filters[filterSearchID].getAir()>
				<cfset nTempCount++>
				<cfif filterSearchID EQ rc.SearchID>
						<li class="active">
							#session.filters[filterSearchID].getHeading()#
					<cfelse>
						<li>
							<a href="#buildURL('air.lowfare?SearchID=#filterSearchID#')#" class="breadcrumbModal" title="Click to view this search">#session.filters[filterSearchID].getHeading()#</a>
					</cfif>
					<cfif StructCount(session.filters) GT 1>
						&nbsp;<a href="#buildURL('air.removeflight?SearchID=#filterSearchID#')#" title="Click to remove this flight from your saved searches"><i class="icon-remove"></i></a>
					</cfif>
					<cfif nAirCount NEQ nTempCount><span class="divider">/</span></cfif>
				</li>
			</cfif>
		</cfloop>
	</ul>
</cfoutput>
