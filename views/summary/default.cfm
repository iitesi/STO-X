<cfset stItinerary = session.searches[rc.nSearchID].stItinerary>
<cfset stPolicy = application.stPolicies[session.searches[rc.nSearchID].nPolicyID]>
<cfset nLowestFare = session.searches[rc.nSearchID].stTrips[session.searches[rc.nSearchID].stLowFareDetails.aSortFare[1]].Total>
<cfset bAir = (structKeyExists(stItinerary, 'Air') ? true : false)>
<cfset bHotel = (structKeyExists(stItinerary, 'Hotel') ? true : false)>
<cfset bCar = (structKeyExists(stItinerary, 'Car') ? true : false)>
<style type="text/css">
form { 
	right: 20px;
	top: -8px;
	z-index: 400;
}
form div{
	max-height: 33px;
	position: relative;
	width: 275px;
}
select {
	margin-top:8px;
	border:1px solid rgba(0,0,0,0.3);
	padding:2px;
	font-family:"Merriweather",Georgia,Times,serif,Times,serif;
}
input[type="text"] {
	margin-top:8px;
	background: #fff;
	padding:2px;
	border:1px solid rgba(0,0,0,0.3);
}
input[type="submit"] { 
	cursor: pointer;
	float: right;
	margin: 0px !important;
	padding: 4px 6px !important;
	position: relative;
	right: 4px;
	top: -29px;
}
textarea {
	background: #fff;
	border:1px solid rgba(0,0,0,0.3);
	padding:8px;
}
.fulldiv {
	width:1000px;
	position: relative;
	float: left;
}
</style>
<cfoutput>
	<input type="hidden" id="nSearchID" value="#rc.nSearchID#">
	<input type="hidden" id="nTraveler" value="1">
	<cfset nTraveler = 1>
	<div id="travelef" class="tab_content" style="display: block;">
		<p>
            #View('summary/traveler')#
            #View('summary/payment')#
			#View('summary/air')#
		</p>
	</div>	
</cfoutput>