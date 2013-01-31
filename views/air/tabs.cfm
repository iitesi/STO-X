<cfif rc.action CONTAINS 'air'>
	<cfloop array="#StructKeyArray(session.searches)#" index="filterSearchID">
		<cfif rc.Filter.getAir()>
            <a href="#buildURL('air.lowfare?SearchID=#filterSearchID#')#">
			<cfoutput>#UCase(rc.Filter.getHeading())#</cfoutput> <span class="divider">/</span></li>
        </a>
		</cfif>
	</cfloop>
</cfif>