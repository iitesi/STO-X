<div class="page-header">
<cfoutput>
        <h1>Ooops</h1>
</cfoutput>
</div>
<h3>You must select air first so we search for the correct pick up and drop off times.</h3>
<ul>
<cfoutput>
	<cfif rc.Filter.getAir()>
        <li><a href="#buildURL('air.lowfare?SearchID=#rc.SearchID#')#">Search for air</a></li>
	</cfif>
</cfoutput>
</ul>