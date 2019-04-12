<div class="page-header">
<cfoutput>
        <h1>We're Sorry</h1>
</cfoutput>
</div>
<h3>You must select air first so we search for the correct pick-up and drop-off times.</h3>
<ul>
<cfoutput>
	<cfif rc.Filter.getAir()>
        <li><a href="#buildURL('air.search?SearchID=#rc.SearchID#')#">Search for air</a></li>
	</cfif>
</cfoutput>
</ul>