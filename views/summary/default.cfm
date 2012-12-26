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
	padding:8px;
	font-family:"Merriweather",Georgia,Times,serif,Times,serif;
}
form div input[type="submit"] { 
	cursor: pointer;
	float: right;
	margin: 0px !important;
	padding: 4px 6px !important;
	position: relative;
	right: 4px;
	top: -29px;
}
input[type="text"] {
	background: #fff;
	border:1px solid rgba(0,0,0,0.3);
	padding:8px;
}
textarea {
	background: #fff;
	border:1px solid rgba(0,0,0,0.3);
	padding:8px;
}
</style>
<cfoutput>
	<!--- <table width="100%" class="paymenttable">
	<tr>
		<td width="600" class="paymenttd">
			Could You Goes Here!
		</td>
		<td width="400" class="paymenttd">
			#View('summary/tripsummary')#
		</td>
	</tr>
	</table> --->
	<br><br>
	#View('summary/traveler')#
	<cfif bAir>
		<br><br>
		<div class="summarydiv background">
			#View('summary/air')#
		</div>
	</cfif>
	<!--- <cfif bHotel>
		<br><br>
		<div class="car">
			<table width="100%" class="paymenttable" bgcolor="##E3EEF4">
			<tr>
				<td width="600" class="paymenttd">
					#View('summary/hotel')#
				</td>
				<td width="400" class="paymenttd">

				</td>
			</tr>
			</table>
		</div>
	</cfif>
	<br><br>--->
	<cfif bCar>
		<div class="summarydiv background">
			#View('summary/car')#
		</div>
	</cfif>
</cfoutput>
<!--- <cfdump var="#rc.stFees#"> --->
<!--- <cfdump var="#session.searches[rc.nsearchid].stitinerary.Air#"> --->