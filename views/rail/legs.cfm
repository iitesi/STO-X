<cfoutput>
	<cfif rc.filter.getAirType() IS "MD">
		<h1>#rc.Filter.getAirHeading()#</h1>
		<ul class="unstyled">
			<cfloop array="#rc.filter.getLegsHeader()#" item="nLegItem" index="nLegIndex">
				<li><h2>#ListFirst(nLegItem, '::')# <small>:: #ListLast(nLegItem, "::")#</small></h2></li>
			</cfloop>
		</ul>
	<cfelse>
		<h1>
			<a href="#buildURL('air&SearchID=#rc.SearchID#')#">
				#ListFirst(rc.Filter.getAirHeading(), "::")#
				<small>:: #ListLast(rc.Filter.getAirHeading(), "::")#</small>
			</a>
		</h1>
	</cfif>

	<cfif structKeyExists(session, 'cookieToken')
		AND structKeyExists(session, 'cookieDate')>
		<cfif listFindNoCase("beta,beta.shortstravel.com", cgi.server_name)>
			<cfset frameSrc ="https://beta.shortstravel.com/search/index.cfm?acctid=#rc.filter.getAcctID()#&userid=#rc.filter.getUserId()#&token=#session.cookieToken#&date=#session.cookieDate#">
		<cfelseif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getWidgetUrl()))>
			<cfset frameSrc = (cgi.https EQ 'on' ? 'https' : 'http')&'://'&cgi.Server_Name&'/search/index.cfm?'&rc.filter.getWidgetUrl()&'&token=#session.cookieToken#&date=#session.cookieDate#' />
		<cfelse>
			<cfset frameSrc = application.searchWidgetURL  & '?acctid=#rc.filter.getAcctID()#&userid=#rc.filter.getUserId()#&token=#session.cookieToken#&date=#session.cookieDate#' />
		</cfif>
		<h2><a href="##" class="change-search searchModalButton" data-framesrc="#frameSrc#&amp;modal=true&amp;requery=true&amp;" title="Search again"><i class="fa fa-search"></i> Change Search</a></h2>
	</cfif>
</cfoutput>

<cfsilent>

	<cfset buttonPrice = "">

	<!--- if for some reason aSortFare or aSortFarePreferred is empty - we'll give the roundtrip button some friendly text w/no price --->
	<cfif structKeyExists(session.searches[rc.SearchID], "stLowFareDetails")>
		<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare")
			AND IsArray(session.searches[rc.SearchID].stLowFareDetails.aSortFare)
			AND ArrayLen(session.searches[rc.SearchID].stLowFareDetails.aSortFare) GT 0>
			<cfset buttonPrice = session.searches[rc.SearchID].stTrips[session.searches[rc.SearchID].stLowFareDetails.aSortFare[1]].total> 
		<cfelseif structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFarePreferred")
			AND IsArray(session.searches[rc.SearchID].stLowFareDetails.aSortFarePreferred)
			AND ArrayLen(session.searches[rc.SearchID].stLowFareDetails.aSortFarePreferred) GT 0>
			<cfset buttonPrice = session.searches[rc.SearchID].stTrips[session.searches[rc.SearchID].stLowFareDetails.aSortFarePreferred[1]].total>
		</cfif>
	</cfif>
	<cfif buttonPrice EQ "">
		<cfset popoverTitle = "View roundtrip fares">
		<cfset buttonText = "Roundtrip Fares">
	<cfelse>
		<cfif rc.Filter.getAirType() EQ 'OW'>
			<cfset popoverTitle = "Fly one-way for as low as $#NumberFormat( buttonPrice )#">
			<cfset buttonText = "One-Way From $#NumberFormat( buttonPrice )#">
		<cfelse>
			<cfset popoverTitle = "Fly roundtrip for as low as $#NumberFormat( buttonPrice )#">
			<cfset buttonText = "Roundtrip From $#NumberFormat( buttonPrice )#">
		</cfif>
	</cfif>

	<cfset popoverContent = "Select a flight below or select individual legs by selecting a button to the right.">
	<cfset popoverLink = "##">
	<cfset popoverButtonClass = "active">

	<cfif structKeyExists(rc, "group") AND Len(rc.group)>
		<cfset popoverTitle = "">
		<cfset popoverContent = "Click to return to main search results">
		<cfset popoverLink = "index.cfm?action=air&SearchID=#rc.searchID#&clearSelected=1"> <!--- back to price page --->
		<cfset popoverButtonClass = "">
	</cfif>
</cfsilent>

<cfoutput>
	<div id="legs" class="legs clearfix">
		<ul class="nav nav-pills">

		<cfif rc.Filter.getAirType() NEQ 'OW' AND rc.Filter.getAirType() NEQ 'MD'>
			<cfloop array="#rc.Filter.getLegsForTrip()#" index="nLegIndex" item="nLegItem">
				<cfif structKeyExists(rc,"group") AND rc.group EQ nLegIndex-1>
					<li role="presentation" class="active"><a href="">#nLegItem#</a></li>
				<cfelse>
					<li role="presentation" onclick="document.location.href='#buildURL('main?SearchID=#rc.SearchID#&Service=Air&&Group=#nLegIndex-1#')#'"><a href="##" class="airModal changeme" data-modal="Flights for #nLegItem#." title="#nLegItem#">
						<!--- Show icon indicating this is the leg they selected --->
						<cfif structKeyExists(session.searches[rc.SearchID].stSelected, nLegIndex-1)
							AND NOT StructIsEmpty(session.searches[rc.SearchID].stSelected[nLegIndex-1])>
							<i class="icon-ok"></i>
						</cfif>
						#nLegItem#</a>
						<div class="changeme">Change</div>
					</li>
				</cfif>
			</cfloop>
		</cfif>
		</ul>
	</div>
</cfoutput>
