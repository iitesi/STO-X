<!---How many searches include air?--->
<cfset nAirCount = 0>
<cfloop collection="#session.filters#" index="filterSearchID">
	<cfif session.filters[filterSearchID].getAir()>
		<cfset nAirCount++>
	</cfif>
</cfloop>

<cfset nTempCount = 0>

<cfoutput>
	<ul class="breadcrumb">
	<cfloop collection="#session.filters#" index="filterSearchID">
			<cfif session.filters[filterSearchID].getAir()>
				<cfset nTempCount++>
				<li>
					<a href="#buildURL('air.lowfare?SearchID=#filterSearchID#')#" <cfif filterSearchID EQ rc.SearchID>class="active"</cfif>>#UCase(session.filters[filterSearchID].getHeading())#</a>
					<i class="icon-remove"></i>
					<cfif nAirCount NEQ nTempCount><span class="divider">/</span></cfif>
				</li>
			</cfif>
		</cfloop>
	</ul>
</cfoutput>
