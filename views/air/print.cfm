<cfsilent>
	<cfset variables.bDisplayFare = true>
	<cfset variables.nLegs = ArrayLen(rc.Filter.getLegsForTrip())>
	<cfset variables.minheight = 250>
	<cfset variables.nDisplayGroup = "">
	<cfset variables.bSelected = false>
	<cfif variables.nLegs EQ 2>
		<cfset variables.minheight = 325>
	<cfelseif variables.nLegs GT 2>
		<cfset variables.minheight = 375>
	</cfif>
</cfsilent>

<cfoutput>

<style>
.page-header {font-family: Arial, Verdana, sans-serif;}
</style>

	<div class="page-header">
		<cfif rc.filter.getAirType() IS "MD">
			<h2>#rc.Filter.getAirHeading()#</h3>
			<ul  class="unstyled">
				<cfloop array="#rc.filter.getLegsHeader()#" item="nLegItem" index="nLegIndex">
					<li><h3>#ListFirst(nLegItem, '::')#<small>:: #ListLast(nLegItem, "::")#</small></h3></li>
				</cfloop>
			</ul>
		<cfelse>
			<h2>
			#ListFirst(rc.Filter.getAirHeading(), "::")#
			<br><small>#ListLast(rc.Filter.getAirHeading(), "::")#</small>
			</h2>
		</cfif>

		<cfif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getWidgetUrl()))>
			<cfset frameSrc = (cgi.https EQ 'on' ? 'https' : 'http')&'://'&cgi.Server_Name&'/search/index.cfm?'&rc.filter.getWidgetUrl() />
		<cfelse>
			<cfset frameSrc = application.searchWidgetURL  & '?acctid=#rc.filter.getAcctID()#&userid=#rc.filter.getUserId()#' />
		</cfif>
	</div>

	<div id="aircontent">
		<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare") AND ArrayLen(session.searches[rc.SearchID].stLowFareDetails.asortFare)>
			<!--- Display selected badges (selected via schedule search) --->
			<cfset variables.bSelected = true>
			<cfset variables.nCount = 0>
			<cfloop collection="#session.searches[rc.SearchID].stLowFareDetails.stPriced#" item="variables.nTripKey">
				<cfset variables.stTrip = session.searches[rc.SearchID].stTrips[nTripKey]>
				<cfset nCount++>
				#View('air/badge-print')#
			</cfloop>

			<cfset variables.bSelected = false>
			<cfloop array="#session.searches[rc.SearchID].stLowFareDetails.aSortFarePreferred#" index="variables.nTripKey">
				<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPriced, nTripKey)>
					<cfset variables.stTrip = session.searches[rc.SearchID].stTrips[nTripKey]>
					<cfset nCount++>
					#View('air/badge-print')#
				</cfif>
			</cfloop>
		</cfif>
	</div>
</cfoutput>

