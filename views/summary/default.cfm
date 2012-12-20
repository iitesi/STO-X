<cfset stItinerary = session.searches[rc.nSearchID].stItinerary>
<cfset stPolicy = application.stPolicies[session.searches[rc.nSearchID].nPolicyID]>
<cfset nLowestFare = session.searches[rc.nSearchID].stTrips[session.searches[rc.nSearchID].stLowFareDetails.aSortFare[1]].Total>
<cfset bAir = (structKeyExists(stItinerary, 'Air') ? true : false)>
<cfset bHotel = (structKeyExists(stItinerary, 'Hotel') ? true : false)>
<cfset bCar = (structKeyExists(stItinerary, 'Car') ? true : false)>
<style type="text/css">
.paymenttable {
	
}
.paymenttd {
	padding:10px 20px 10px 10px;
}
</style>
<cfoutput>
	<table width="100%" class="paymenttable">
	<tr>
		<td width="600" class="paymenttd">
			Could You Goes Here!
		</td>
		<td width="400" class="paymenttd">
			#View('summary/tripsummary')#
		</td>
	</tr>
	</table>
	<cfif bAir>
		<br><br>
		<table width="100%" class="paymenttable" bgcolor="##E3EEF4">
		<tr>
			<td width="600" class="paymenttd">
				#View('summary/air')#
			</td>
			<td width="400" class="paymenttd">
				#View('summary/airoptions')#
			</td>
		</tr>
		</table>
	</cfif>
	<cfif bHotel>
		<br><br>
		<table width="100%" class="paymenttable" bgcolor="##E3EEF4">
		<tr>
			<td width="600" class="paymenttd">
				#View('summary/hotel')#
			</td>
			<td width="400" class="paymenttd">

			</td>
		</tr>
		</table>
	</cfif>
	<br><br>
	<table width="100%" class="paymenttable" bgcolor="##E3EEF4">
	<tr>
		<td width="600" class="paymenttd">
			#View('summary/car')#
		</td>
		<td width="400" class="paymenttd">

		</td>
	</tr>
	</table>
</cfoutput>
<!--- <cfdump var="#rc.stFees#"> --->
<cfdump var="#session.searches[rc.nsearchid].stitinerary.Air#">