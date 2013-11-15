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

<cfset epochTotal = []>

<cfoutput>
	<div class="page-header">
		<cfif rc.filter.getAirType() IS "MD">
			<h1>#rc.Filter.getAirHeading()#</h1>
			<ul  class="unstyled">
				<cfloop array="#rc.filter.getLegsHeader()#" item="nLegItem" index="nLegIndex">
					<li><h2>#ListFirst(nLegItem, '::')# <small>:: #ListLast(nLegItem, "::")#</small></h2></li>
				</cfloop>
			</ul>
		<cfelse>
			<h1>
				<a href="#buildURL('air.lowfare&SearchID=#rc.SearchID#')#">
					#ListFirst(rc.Filter.getAirHeading(), "::")#
					<small>:: #ListLast(rc.Filter.getAirHeading(), "::")#</small>
				</a>
			</h1>
		</cfif>

		<cfif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getWidgetUrl()))>
			<cfset frameSrc = (cgi.https EQ 'on' ? 'https' : 'http')&'://'&cgi.Server_Name&'/search/index.cfm?'&rc.filter.getWidgetUrl()&'&token=#cookie.token#&date=#cookie.date#' />
		<cfelse>
			<cfset frameSrc = application.searchWidgetURL  & '?acctid=#rc.filter.getAcctID()#&userid=#rc.filter.getUserId()#&token=#cookie.token#&date=#cookie.date#' />
		</cfif>

		<h2><a href="##" class="change-search searchModalButton" data-framesrc="#frameSrc#&amp;modal=true&amp;requery=true&amp;" title="Search again"><i class="icon-search"></i> Change Search</a></h2>

		<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare")>
			#View('air/legs')#
		</cfif>
	</div>

	<div id="aircontent">
		<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare") AND ArrayLen(session.searches[rc.SearchID].stLowFareDetails.asortFare)>
			<div id="hidefilterfromprint">
				#View('air/filter')#
			</div>
			<!--- Display selected badges (selected via schedule search) --->
			<cfset variables.bSelected = true>
			<cfset variables.nCount = 0>
			<cfloop collection="#session.searches[rc.SearchID].stLowFareDetails.stPriced#" item="variables.nTripKey">
				<cfset variables.stTrip = session.searches[rc.SearchID].stTrips[nTripKey]>
				<cfset nCount++>
				#View('air/badge')#
			</cfloop>

			<cfset variables.bSelected = false>
			<cfloop array="#session.searches[rc.SearchID].stLowFareDetails.aSortFarePreferred#" index="variables.nTripKey">
				<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPriced, nTripKey)>
					<cfset variables.stTrip = session.searches[rc.SearchID].stTrips[nTripKey]>
					<cfset nCount++>
					#View('air/badge')#
				</cfif>
			</cfloop>

			<script type="application/javascript">
				// define for sorting ( see air/filter.js and booking.js airSort() )
	 			var sortbyarrival = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortArrival)#;
	 			var sortbydeparture = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortDepart)#;
	 			var sortbyduration = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortDuration)#;
	 			var sortbyprice = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortFarePreferred)#;
	 			var sortbyprice1bag = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortBagPreferred)#;
	 			var sortbyprice2bag = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortBag2Preferred)#;

				// flightresults is used in booking.js to filter flights
				// here we loop over session searches and stuff all the flights avail in flightresults
				var flightresults = [
					<cfset nCount = 0>
					<cfloop array="#session.searches[rc.SearchID].stLowFareDetails.aSortFarePreferred#" index="sTrip">
						<cfif nCount NEQ 0>,</cfif>[#session.searches[rc.SearchID].stTrips[sTrip].sJavascript#]
						<cfset nCount++>
					</cfloop>];
			</script>

		<div class="clearfix"></div>

		<div class="noFlightsFound">
			<div class="container">
			<h1>No Flights Available</h1>
			<p>No flights are available for your filtered criteria. <a href="##" class="removefilters"><i class="icon-refresh"></i> Clear Filters</a> to see all results.</p>
			</div>
		</div>
	<cfelse>
		<cfset changeSearchURL = application.sPortalURL & "?acctid=#session.acctID#&userID=#session.userID#">
		<div class="container">
			<h3>No Flights Returned</h2>
			<p>There were no flights found based on your search criteria.</p>
			<p>Please <a href="#changeSearchURL#">change your search</a> and try again.</p>
			<br /><br /><br /><br /><br /><br />
		</div>
	</cfif>
</div>

	<form method="post" action="#buildURL('air.lowfare')#" id="lowfareForm">
		<input type="hidden" name="bSelect" value="1">
		<input type="hidden" name="SearchID" value="#rc.SearchID#">
		<input type="hidden" name="nTrip" id="nTrip" value="">
	</form>

<!--- TODO - need to call default loading  --->
#View('modal/popup')#

</cfoutput>



<!--- AIR CODES

*****************************************
PLEASE DON'T DELETE - Used for debugging
*****************************************

1 = refundable
0 = non refundable
-----------------------
Y = economy
C = business
F = first
-----------------------
(X) = not selected

acarriers =  #arraylen(session.searches[rc.searchid].stlowfaredetails.acarriers)#<br>
asortarrival =  #arraylen(session.searches[rc.searchid].stlowfaredetails.asortarrival)#<br>
asortbag =  #arraylen(session.searches[rc.searchid].stlowfaredetails.asortbag)#<br>
asortbag2 =  #arraylen(session.searches[rc.searchid].stlowfaredetails.asortbag2)#<br>
asortdepart =  #arraylen(session.searches[rc.searchid].stlowfaredetails.asortdepart)#<br>
asortduration =  #arraylen(session.searches[rc.searchid].stlowfaredetails.asortduration)#<br>
asortfare =  #arraylen(session.searches[rc.searchid].stlowfaredetails.asortfare)#<br>
<cfdump var="#structcount(session.searches[rc.searchid].stlowfaredetails.stpriced)#" />
<cfdump var="#structcount(session.searches[rc.searchid].stlowfaredetails.stpricing)#" />
<cfdump var="#session.searches[rc.SearchID].stLowFareDetails.stResults#" keys="10" />
<cfdump var="#structcount(session.searches[rc.searchid].stlowfaredetails.stresults)#" />
<cfdump var="#session.searches[rc.SearchID]#"  expand="false" label="session.searches"/>
<cfdump var="#rc#" label="Dump ( RC SCOPE )" expand="false">
--->




<cfset epochTotal = getBeanFactory().getBean('underscore').uniq(epochTotal)>
<cfdump var="#epochTotal#" label="EpochTotal"/>
<cfdump var="#getBeanFactory().getBean('underscore').max(epochTotal)#" label="EpochTotal Max" abort="false"/>
<cfdump var="#getBeanFactory().getBean('underscore').min(epochTotal)#" label="EpochTotal Min" abort="true"/>