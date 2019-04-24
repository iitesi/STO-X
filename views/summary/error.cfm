<div class="page-header">
<cfoutput>
        <h1>Ooops</h1>
</cfoutput>
</div>
<h3>You haven't selected your services yet</h3>
<ul>
<cfoutput>
	<cfif rc.Filter.getAir()>
            <li><a href="#buildURL('air?SearchID=#rc.SearchID#')#">Search for air</a></li>
	</cfif>
	<cfif rc.Filter.getHotel()>
            <li><a href="#buildURL('hotel.search?SearchID=#rc.SearchID#')#">Search for hotel</a></li>
	</cfif>
	<cfif rc.Filter.getCar()>
            <li><a href="#buildURL('car.availability?SearchID=#rc.SearchID#')#">Search for car</a></li>
	</cfif>
</cfoutput>
</ul>