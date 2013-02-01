<cfoutput>
	<cfif IsObject(rc.Filter)>
		<nav id="main-nav">
		    <ul>
				<!---Air--->
				<cfif rc.Filter.getAir()>
					<li <cfif rc.action CONTAINS 'air.'>class="active"</cfif>>
						<a href="#buildURL('air.lowfare?SearchID=#rc.SearchID#')#">Air</a>
					</li>
				</cfif>
				<!---Hotel--->
		        <li <cfif rc.action CONTAINS 'hotel.'>class="active"</cfif>>
		            <a href="#buildURL('hotel.search?SearchID=#rc.SearchID#')#">Hotel</a>
				</li>
				<!---Car--->
				<li <cfif rc.action CONTAINS 'car.'>class="active"</cfif>>
					<a href="#buildURL('car.availability?SearchID=#rc.SearchID#')#">Car</a>
				</li>
				<!---Purchase--->
			    <li <cfif rc.action CONTAINS 'summary.'>class="active"</cfif>>
			        <a href="#buildURL('summary?SearchID=#rc.SearchID#')#">Purchase</a>
				</li>
			</ul>
		</nav>
	</cfif>
</cfoutput>