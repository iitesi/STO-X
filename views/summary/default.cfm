<cfif NOT structIsEmpty(session.searches[rc.SearchID].stItinerary)>
	<cfif application.Accounts[session.AcctID].CouldYou>
		<cfoutput>
            <a href="?action=couldyou&SearchID=#url.SearchID#">CouldYou</a> -
            <a href="?action=purchase&SearchID=#url.SearchID#">Purchase</a>
		</cfoutput>
	</cfif>
	<cfset variables.stItinerary = session.searches[rc.SearchID].stItinerary>
	<cfset variables.nLowestFare = session.searches[rc.SearchID].stTrips[session.searches[rc.SearchID].stLowFareDetails.aSortFare[1]].Total>
	<cfset variables.Air = (structKeyExists(stItinerary, 'Air') ? true : false)>
	<cfset variables.Hotel = (structKeyExists(stItinerary, 'Hotel') ? true : false)>
	<cfset variables.Car = (structKeyExists(stItinerary, 'Car') ? true : false)>
	<cfoutput>
		<form method="post" action="#buildURL('summary')#">
			<input type="hidden" name="SearchID" id="SearchID" value="#rc.SearchID#">
			<input type="hidden" id="Air" value="#Air#">
			<input type="hidden" id="Car" value="#Car#">
			<input type="hidden" id="Hotel" value="#Hotel#">
			<input type="hidden" name="nTraveler" id="nTraveler" value="1">
			<input type="hidden" id="sCarriers" value="#ArrayToList(stItinerary.Air.Carriers)#">
			<cfif Car>
				<input type="hidden" id="sCarVendor" value="#stItinerary.Car.VendorCode#">
			</cfif>
			<!---<cfif StructKeyExists(Policy, 'CDNumbers')
			AND StructKeyExists(Policy.CDNumbers, stItinerary.Car.VendorCode)>
				<cfset variables.stCD = Policy.stCDNumbers[stItinerary.Car.VendorCode]>
			<cfelse>todo--->
				<cfset variables.stCD.DB = ''>
				<cfset variables.stCD.CD = ''>
			<!---</cfif>--->
			<input type="hidden" id="bDB" value="#stCD.DB#">
			<input type="hidden" id="bCD" value="#stCD.CD#">
			<cfset variables.nTraveler = 1>
			<cfset variables.bTotalTrip = 0>
			<cfset variables.stTraveler 	= (StructKeyExists(session.searches[rc.SearchID].stTravelers, nTraveler) ? session.searches[rc.SearchID].stTravelers[nTraveler] : {})>
			<div id="traveler" class="tab_content">
				<p>
					<div class="summarydiv" style="background-color: ##FFF">
						<div id="travelerForm"> </div>
					</div>

					<div class="summarydiv" style="background-color: ##FFF">
						<div id="paymentForm"> </div>
					</div>

					<br class="clearfix">

					#View('summary/air')#

					<br class="clearfix">

					<!---
					#View('summary/hotel')#
					<br class="clearfix">
					 --->
					<cfif Car>
						#View('summary/car')#
					</cfif>

					<br class="clearfix">

					#View('summary/buttons')#
				</p>
			</div>
		</form>
	</cfoutput>
<!--- <cfdump var="#session.searches[rc.SearchID].stTravelers#"> --->
	<cfset sType 		= (StructKeyExists(stTraveler, 'Type') ? stTraveler.Type : 'New')>
	<!--- <cfdump var="#session.searches[rc.SearchID].stTravelers#"> --->
    <script type="text/javascript">
    $(document).ready(function() {
        setTravelerForm(1, 1);
        setPaymentForm(1);
        setOtherFields(1);
    });
    </script>
<cfelse>
	<cfoutput>
		#View('summary/error')#
	</cfoutput>
</cfif>
