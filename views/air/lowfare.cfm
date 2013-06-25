<cfoutput>
<!---
AIR CODES
-----------------------
1 = refundable
0 = non refundable
-----------------------
Y = economy
C = business
F = first
-----------------------
(X) = not selected


0	number	106
1	number	225  331

C	number	18
F	number	19
Y	number	294  331
 --->

<cfset totalFlights = 0>

<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "1")>
	<cfset totalFlights = totalFlights + session.searches[rc.SearchID].stLowFareDetails.stResults.1>
</cfif>

<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails.stResults, "0")>
	<cfset totalFlights = totalFlights + session.searches[rc.SearchID].stLowFareDetails.stResults.0>
</cfif>

<p>Total Flights (1+0) =  #totalFlights#</p>



FROM SESSION.SEARCHES0[rc.SearchID]<br>
================================================================================<br>
acarriers =  #arraylen(session.searches[rc.searchid].stlowfaredetails.acarriers)#<br>
asortarrival =  #arraylen(session.searches[rc.searchid].stlowfaredetails.asortarrival)#<br>
asortbag =  #arraylen(session.searches[rc.searchid].stlowfaredetails.asortbag)#<br>
asortbag2 =  #arraylen(session.searches[rc.searchid].stlowfaredetails.asortbag2)#<br>
sortdepart =  #arraylen(session.searches[rc.searchid].stlowfaredetails.asortdepart)#<br>
sortduration =  #arraylen(session.searches[rc.searchid].stlowfaredetails.asortduration)#<br>
asortfare =  #arraylen(session.searches[rc.searchid].stlowfaredetails.asortfare)#<br>
<cfdump var="#structcount(session.searches[rc.searchid].stlowfaredetails.stpriced)#" />
<cfdump var="#structcount(session.searches[rc.searchid].stlowfaredetails.stpricing)#" />
<cfdump var="#structcount(session.searches[rc.searchid].stlowfaredetails.stresults)#" />
<cfdump var="#session.searches[rc.SearchID].stLowFareDetails.stResults#" keys="10" />
</cfoutput>









<cfsilent>
	<cfset variables.bDisplayFare = true>
	<cfset variables.nLegs = ArrayLen(rc.Filter.getLegs())>
	<cfif nLegs EQ 2>
		<cfset variables.minheight = 250>
	<cfelseif nLegs EQ 1>
		<cfset variables.minheight = 150>
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
					<li><h2>#ListFirst(sLeg, '::')# <small>:: #ListLast(sLeg, "::")#<small></h2></li>
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

	<cfif structKeyExists(session.searches[rc.SearchID], 'sUserMessage')>
		<div id="usermessage" class="error">#session.searches[rc.SearchID].sUserMessage#</div>
		<cfset structDelete(session.searches[rc.SearchID], 'sUserMessage')>
	</cfif>

	<cfset variables.nDisplayGroup = ''>
	<div id="aircontent">
		<cfif structKeyExists(session.searches[rc.SearchID].stLowFareDetails, "aSortFare")>

			#View('air/filter')#

			<br clear="both">



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

				<cfif NOT StructKeyExists(session.searches[rc.SearchID].stLowFareDetails.stPriced, nTripKey)
					AND nCount LTE 150>

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

			<!---
			TODO: add message when there are no flights when filtering
			3:45 PM Thursday, June 20, 2013 - Jim Priest - jpriest@shortstravel.com
			--->
			<br clear="both">
			<h1>SOMETHING SHOULD GO HERE IF THERE ARE NO FLIGHTS WHEN FILTERING</h1>

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

