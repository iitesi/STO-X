<!--- Displaying the air, hotel, and car tabs based on whether the custom search widget allows for it. --->
<cfif isDefined("rc.searchId") AND val(rc.searchId) AND structKeyExists(rc,"filter") AND rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getWidgetUrl()))>
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
	<cfset showPurchaseTab = true/>
<cfelseif isDefined("rc.searchId") AND val(rc.searchId) AND structKeyExists(session,"DepartmentPreferences")>
	<cfset showAirTab = ((rc.Filter.getAir() IS TRUE AND session.DepartmentPreferences.STOAir NEQ 0) ? 1 : 0) />
	<cfset showHotelTab = (((NOT rc.Filter.getAir() IS TRUE OR rc.Filter.getAirType() NEQ 'MD') AND session.DepartmentPreferences.STOHotel NEQ 0) ? 1 : 0) />
	<cfset showCarTab = (((NOT rc.Filter.getAir() IS TRUE OR rc.Filter.getAirType() NEQ 'MD') AND session.DepartmentPreferences.STOCar NEQ 0) ? 1 : 0) />
	<cfset showPurchaseTab = true/>
<cfelse>
	<cfset showAirTab = false/>
	<cfset showHotelTab = false/>
	<cfset showCarTab = false/>
	<cfset showPurchaseTab = false/>
</cfif>
<cfscript>
	arrayAppend(request.context.additionalFooterJS, "$('##navbar-collapse-1 a.mdi-ticket-account').tooltip({
		template: ""<div class='tooltip navbar-tooltip' role='tooltip'><div class='tooltip-arrow'></div><div class='tooltip-inner'></div></div>""
	});");
	arrayAppend(request.context.additionalFooterJS, "$('##navbar-collapse-1 a.logged-in-user-circle').tooltip({
		template: ""<div class='tooltip navbar-tooltip' role='tooltip'><div class='tooltip-arrow'></div><div class='tooltip-inner'></div></div>""
	});");
</cfscript>
<cfoutput>
	<cfif structKeyExists(rc, 'Filter') AND IsObject(rc.Filter)>
		 <div class="collapse navbar-collapse" id="navbar-collapse-1" >
			<ul class="nav navbar-nav navbar-right">
				<cfif structKeyExists(session, 'Filters')
					AND structKeyExists(rc, 'SearchId')
					AND structKeyExists(session.Filters, rc.SearchId)
					AND arrayLen(session.Filters[rc.SearchId].getUnusedTickets())>
					<cfsavecontent variable="ticketDetails">
						<div class='unused-ticket-title'>Unused Ticket<cfif arrayLen(session.Filters[rc.SearchId].getUnusedTickets()) GT 1>s</cfif></div>
						<div class='unused-ticket-wrapper'>
						<cfloop array="#session.Filters[rc.SearchId].getUnusedTickets()#" index="UnusedTicketIndex" item="UnusedTicketItem">
							<div class='unused-ticket'>
								$#Round(UnusedTicketItem.Airfare)# 
								expiring #DateFormat(UnusedTicketItem.ExpirationDate, 'mmm d, yyyy')# 
								on #UnusedTicketItem.CarrierName#
							</div>
						</cfloop>
						</div>
					</cfsavecontent>
					<li>
						<a 	class="mdi mdi-ticket-account" 
							href="javascript:void(0);"
							data-html="true" 
							data-placement="bottom"
							title="#ticketDetails#">
							<span class="mat-badge-content mat-badge-active">
								#arrayLen(session.Filters[rc.SearchId].getUnusedTickets())#
							</span>
							<span class='menu-details'>
								Unused Ticket<cfif arrayLen(session.Filters[rc.SearchId].getUnusedTickets()) GT 1>s</cfif>
							</span>
						</a>
					</li>
				</cfif>
				<cfif structKeyExists(cookie,"loginOrigin") AND cookie.loginOrigin EQ "STO">
					<!---Menu-for mobile STO --->
					<li>
						<a href="#buildURL('main.menu')#">Home</a>
					</li>
					<li>
						<a href="#buildURL('main.search')#">Search</a>
					</li>
					<li>
						<a href="#buildURL('main.trips')#">My Trips</a>
					</li>
				<cfelseif rc.filter.getPassthrough() EQ 0 AND rc.filter.getFindit() EQ 0>
					<!---Home--->
					<li>
						<a href="#application.sPortalURL#">Home</a>
					</li>
				</cfif>
				<cfif showAirTab>
					<!---Air--->
					<li <cfif rc.action CONTAINS 'air.'>class="active"</cfif>>
						<a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Air')#">Air</a>
					</li>
				<cfelseif rc.filter.getPassthrough() NEQ 1 AND NOT (structKeyExists(cookie,"loginOrigin") AND cookie.loginOrigin EQ "STO")>
					<!---Air--->
					<li <cfif rc.action CONTAINS 'air.'>class="active"</cfif>>
						<a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Air')#">Air</a>
					</li>
				</cfif>
				<cfif showHotelTab>
					<!---Hotel--->
					<li <cfif rc.action CONTAINS 'hotel.'>class="active"</cfif>>
						<a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Hotel')#">Hotel</a>
					</li>
				</cfif>
				<cfif showCarTab>
					<!---Car--->
					<li <cfif rc.action CONTAINS 'car.'>class="active"</cfif>>
						<a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Car')#">Car</a>
					</li>
				</cfif>
				<cfif showPurchaseTab>
					<!---Purchase--->
				    <li <cfif rc.action CONTAINS 'summary.'>class="active"</cfif>>
				        <a href="#buildURL('main?SearchID=#rc.SearchID#')#">Purchase</a>
					</li>
				</cfif>
				<cfif structKeyExists(cookie,"loginOrigin") AND cookie.loginOrigin EQ "STO">
					<li>
						<a href="#buildURL('main.contact')#">Contact</a>
					</li>
					<li>
						<a 	class="mdi logged-in-user-circle" 
							href="javascript:void(0);"
							data-html="true" 
							data-placement="bottom"
							title="Garett Kernen">
							<span class="mat-badge-content mat-badge-active">
								username: #rc.Filter.getUserId()#
							</span>
						</a>
					</li>
					<li>
						<a href="#buildURL('main.logout')#">Logout</a>
					</li>
				</cfif>
			</ul>
			<cfdump var="#session#">
		</div><!-- /.navbar-collapse -->
	</cfif>
</cfoutput>