<cfoutput>
<!--- AIR CODES
-----------------------
1 = refundable
0 = non refundable
-----------------------
Y = economy
C = business
F = first
-----------------------
(X) = not selected
 --->

<!---
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
</cfoutput>

<cfsilent>
	<cfset variables.bDisplayFare = true>
	<cfset variables.nLegs = ArrayLen(rc.Filter.getLegs())>
	<cfset variables.minheight = 200>
	<cfif nLegs EQ 2>
		<cfset variables.minheight = 250>
	<cfelseif nLegs EQ 3>
		<cfset variables.minheight = 300>
	</cfif>
</cfsilent>

<cfoutput>
	<div class="page-header">
		<cfif rc.filter.getAirType() IS "MD">
			<h1>#rc.Filter.getAirHeading()#</h1>
			<ul  class="unstyled">
				<cfloop array="#rc.filter.getLegsHeader()#" index="nLeg" item="sLeg">
					<li><h2>#ListFirst(sLeg, '::')# <small>:: #ListLast(sLeg, "::")#</small></h2></li>
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

		<h2><a href="##displaySearchWindow" id="displayModal" class="change-search" data-toggle="modal" data-backdrop="static"><i class="icon-search"></i> Change Search</a></h2>

		<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare")>
				#View('air/legs')#
		</cfif>
	</div>

<!--- TODO: messaging
		christine says we can probably get rid of sUserMessage -need to investigate and remove --->

	<cfif structKeyExists(session.searches[rc.SearchID], 'sUserMessage')>
		<div id="usermessage" class="error">#session.searches[rc.SearchID].sUserMessage#</div>
		<cfset structDelete(session.searches[rc.SearchID], 'sUserMessage')>
	</cfif>

	<cfset variables.nDisplayGroup = ''>
	<div id="aircontent">
		<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare")>

			#View('air/filter')#

			<!--- Display selected badges (selected via schedule search) --->
			<cfset variables.bSelected = true>
			<cfset variables.nCount = 0>
			<cfloop collection="#session.searches[rc.SearchID].stLowFareDetails.stPriced#" item="variables.nTripKey">
				<cfset variables.stTrip = session.searches[rc.SearchID].stTrips[nTripKey]>
				<cfset nCount++>
				#View('air/badge')#
			</cfloop>

			<!--- Display standard fare based search --->
			<cfset variables.bSelected = false>
			<cfloop array="#session.searches[rc.SearchID].stLowFareDetails.aSortFare#" index="variables.nTripKey">

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
	 			var sortbyprice = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortFare)#;
	 			var sortbyprice1bag = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortBag)#;
	 			var sortbyprice2bag = #SerializeJSON(session.searches[rc.SearchID].stLowFareDetails.aSortBag2)#;

				// flightresults is used in booking.js to filter flights
				// here we loop over session searches and stuff all the flights avail in flightresults
				var flightresults = [
					<cfset nCount = 0>
					<cfloop array="#session.searches[rc.SearchID].stLowFareDetails.aSortFare#" index="sTrip">
						<cfif nCount NEQ 0>,</cfif>[#session.searches[rc.SearchID].stTrips[sTrip].sJavascript#]
						<cfset nCount++>
					</cfloop>];
			</script>

		<div class="container noFlightsFound">
			<h1>No Flights Available</h1>
			<p>No flights are available for your filtered criteria. <a href="##" class="removefilters"><i class="icon-refresh"></i> Clear Filters</a> to see all results.</p>
		</div>
	<cfelse>
		<div class="container">
			<h3>No Flights Returned</h2>
			<p>There were no flights found based on your search criteria.</p>
			<p>Please <a href="#application.sPortalURL#">change your search</a> and try again.</p>
			<br /><br /><br /><br /><br /><br />
		</div>
	</cfif>
</div>

	<form method="post" action="#buildURL('air.lowfare')#" id="lowfareForm">
		<input type="hidden" name="bSelect" value="1">
		<input type="hidden" name="SearchID" value="#rc.SearchID#">
		<input type="hidden" name="nTrip" id="nTrip" value="">
	</form>
</cfoutput>

<!-- Modal -->
<div id="myModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-header">
		<h4><i class="icon-spinner icon-spin"></i> One moment, we're searching for...</h4>
	</div>
	<div id="myModalBody" class="modal-body"></div>
</div>