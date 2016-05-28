<cfsilent>
<!--- Displaying the air, hotel, and car tabs based on whether the custom search widget allows for it. --->
<cfif rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getWidgetUrl()))>
	<cfloop list="#rc.filter.getWidgetUrl()#" delimiters="&" index="item">
		<cfif ListGetAt(item, 1, "=") IS "air">
			<cfset airValue = ListGetAt(item, 2, "=") />
		<cfelseif ListGetAt(item,1,"=") IS "hotel">
			<cfset hotelValue = ListGetAt(item, 2, "=") />
		<cfelseif ListGetAt(item,1,"=") IS "car">
			<cfset carValue = ListGetAt(item, 2, "=") />
		</cfif>
	</cfloop>

	<cfset showAirTab = yesNoFormat(airValue) />
	<!--- The default for hotel is yes/1/true. If not specified, must be displayed. --->
	<cfif len(hotelValue)>
		<cfset showHotelTab = yesNoFormat(hotelValue) />
	<cfelse>
		<cfset showHotelTab = 1 />
	</cfif>
	<cfset showCarTab = yesNoFormat(carValue) />
	<cfset showAirTab = (rc.Filter.getAir() IS TRUE ? 1 : 0) />
<cfelse>
	<cfset showAirTab = ((rc.Filter.getAir() IS TRUE AND session.DepartmentPreferences.STOAir NEQ 0) ? 1 : 0) />
	<cfset showHotelTab = (((NOT rc.Filter.getAir() IS TRUE OR rc.Filter.getAirType() NEQ 'MD') AND session.DepartmentPreferences.STOHotel NEQ 0) ? 1 : 0) />
	<cfset showCarTab = (((NOT rc.Filter.getAir() IS TRUE OR rc.Filter.getAirType() NEQ 'MD') AND session.DepartmentPreferences.STOCar NEQ 0) ? 1 : 0) />
</cfif>
</cfsilent>
<cfoutput>
	<cfif structKeyExists(rc, 'Filter') AND IsObject(rc.Filter)>
		
		    <div class="collapse navbar-collapse" id="navbar-collapse-1" >
				<ul class="nav navbar-nav navbar-right">
				<cfif rc.filter.getPassthrough() EQ 0 AND rc.filter.getFindit() EQ 0>
					<!---Home--->
					<li>
						<a href="#application.sPortalURL#">Home</a>
					</li>
				</cfif>
		    	<cfif rc.action CONTAINS 'confirmation.' AND NOT rc.Account.tmc.getIsExternal() AND rc.filter.getPassthrough() NEQ 1>
					<!---Logout--->
					<!---<li>
						<a href="#buildURL('logout')#">Logout</a>
					</li>--->
		    	<cfelse>
					<cfif showAirTab>
						<!---Air--->
						<li <cfif rc.action CONTAINS 'air.'>class="active"</cfif>>
							<a href="#buildURL('air.lowfare?SearchID=#rc.SearchID#')#">Air</a>
						</li>
					<cfelseif rc.filter.getPassthrough() NEQ 1>
						<!---Air--->
						<li <cfif rc.action CONTAINS 'air.'>class="active"</cfif>>
							<a href="#buildURL('air.addair?SearchID=#rc.SearchID#')#">Air</a>
						</li>
					</cfif>
					<cfif showHotelTab>
						<!---Hotel--->
						<li <cfif rc.action CONTAINS 'hotel.'>class="active"</cfif>>
							<a href="#buildURL('hotel.search?SearchID=#rc.SearchID#')#">Hotel</a>
						</li>
					</cfif>
					<cfif showCarTab>
						<!---Car--->
						<li <cfif rc.action CONTAINS 'car.'>class="active"</cfif>>
							<a href="#buildURL('car.availability?SearchID=#rc.SearchID#')#">Car</a>
						</li>
					</cfif>
					<!---Purchase--->
				    <li <cfif rc.action CONTAINS 'summary.'>class="active"</cfif>>
				        <a href="#buildURL('summary?SearchID=#rc.SearchID#')#">Purchase</a>
					</li>
					<!---<cfif NOT rc.Account.tmc.getIsExternal() AND rc.filter.getPassthrough() NEQ 1>
						<li>
							<a href="#buildURL('logout')#">Logout</a>
						</li>
					</cfif>--->
				</cfif>
			</ul>
		 </div><!-- /.navbar-collapse -->
	</cfif>
</cfoutput>