<cfoutput>
	<cfif structKeyExists(rc, 'Filter') AND IsObject(rc.Filter)>
		<nav id="main-nav">
		    <ul>
		    	<cfif rc.action CONTAINS 'confirmation.'>
					<!---Home--->
					<li>
						<a href="#application.sPortalURL#">Home</a>
					</li>
					<!---Logout--->
					<li>
						<a href="##">Logout</a>
					</li>
		    	<cfelse>
					<cfif rc.Filter.getAir()>
						<!---Air--->
						<li <cfif rc.action CONTAINS 'air.'>class="active"</cfif>>
							<a href="#buildURL('air.lowfare?SearchID=#rc.SearchID#')#">Air</a>
						</li>
					</cfif>
					<cfif NOT rc.Filter.getAir()
						OR rc.Filter.getAirType() NEQ 'MD'>
						<!---Hotel--->
						<li <cfif rc.action CONTAINS 'hotel.'>class="active"</cfif>>
							<a href="#buildURL('hotel.search?SearchID=#rc.SearchID#')#">Hotel</a>
						</li>
						<!---Car--->
						<li <cfif rc.action CONTAINS 'car.'>class="active"</cfif>>
							<a href="#buildURL('car.availability?SearchID=#rc.SearchID#')#">Car</a>
						</li>
					</cfif>
					<!---Purchase--->
				    <li <cfif rc.action CONTAINS 'summary.'>class="active"</cfif>>
				        <a href="#buildURL('summary?SearchID=#rc.SearchID#')#">Purchase</a>
					</li>
				</cfif>
			</ul>
		</nav>
	</cfif>
</cfoutput>