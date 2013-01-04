<cfoutput>
	<a href="?action=couldyou&Search_ID=#url.Search_ID#">CouldYou</a>
</cfoutput>
<cfset stItinerary = session.searches[rc.nSearchID].stItinerary>
<cfset stPolicy = application.stPolicies[session.searches[rc.nSearchID].nPolicyID]>
<cfset nLowestFare = session.searches[rc.nSearchID].stTrips[session.searches[rc.nSearchID].stLowFareDetails.aSortFare[1]].Total>
<cfset bAir = (structKeyExists(stItinerary, 'Air') ? true : false)>
<cfset bHotel = (structKeyExists(stItinerary, 'Hotel') ? true : false)>
<cfset bCar = (structKeyExists(stItinerary, 'Car') ? true : false)>
<cfoutput>
	<form method="post" action="#buildURL('purchase?Search_ID=#rc.nSearchID#')#">
		<input type="hidden" id="nSearchID" value="#rc.nSearchID#">
		<input type="hidden" id="nTraveler" value="1">
		<input type="hidden" id="sCarriers" value="#ArrayToList(stItinerary.Air.Carriers)#">
		<input type="hidden" id="sCarVendor" value="#stItinerary.Car.VendorCode#">
		<cfset nTraveler = 1>
		<cfset bTotalTrip = 0>
		<div id="travelef" class="tab_content" style="display: block;">
			<p>
				#View('summary/traveler')#
				#View('summary/payment')#
				#View('summary/air')#
				<!--- #View('summary/hotel')# --->
				#View('summary/car')#
				#View('summary/buttons')#
			</p>
		</div>
	</form>
</cfoutput>