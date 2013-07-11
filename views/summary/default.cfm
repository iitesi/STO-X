<!--- to do : move css once it is completed --->
<style>
.form-horizontal select, textarea, input {
	padding: 0px;
}
</style>
	<cfoutput>
		<a href="?action=couldyou&SearchID=#rc.SearchID#">CouldYou</a> -
		<a href="?action=purchase&SearchID=#rc.SearchID#">Purchase</a> -
		<a href="?action=purchase.car&SearchID=#rc.SearchID#">Car Create</a>-
		<a href="?action=purchase.hotel&SearchID=#rc.SearchID#">Hotel Create</a>
	</cfoutput>

	<form class="form-horizontal">

		<cfoutput>

			<input type="hidden" name="searchID" id="searchID" value="#rc.searchID#">
			<input type="hidden" name="acctID" id="acctID" value="#rc.Filter.getAcctID()#">
			<input type="hidden" name="travelerNumber" id="travelerNumber" value="#rc.travelerNumber#">
			<input type="hidden" name="arrangerID" id="arrangerID" value="#rc.Filter.getUserID()#">
			<input type="hidden" name="valueID" id="valueID" value="#rc.Filter.getValueID()#">
			<input type="hidden" name="airSelected" id="airSelected" value="#rc.airSelected#">
			<input type="hidden" name="hotelSelected" id="hotelSelected" value="#rc.hotelSelected#">
			<input type="hidden" name="vehicleSelected" id="vehicleSelected" value="#rc.vehicleSelected#">
			<input type="hidden" name="vendor" id="vendor" value="#(rc.vehicleSelected ? rc.Vehicle.getVendorCode() : '')#">
			
			<div id="traveler" class="tab_content">
				<p>
					<div class="summarydiv" style="background-color: ##FFF">
						#View('summary/traveler')#
					</div>

					<div class="summarydiv" style="background-color: ##FFF">
						<div id="paymentForm"><td valign="top">#view( 'summary/payment' )#</td></div>
					</div>
					<br class="clearfix">

					<cfset tripTotal = 0>
					
					#View('summary/air')#
					<br class="clearfix">
					#View('summary/vehicle')#
				</p>
			</div>
			
		</cfoutput>
				
		<script src="assets/js/summary/summary.js"></script>
	</form>				
			
		<!--- <form method="post" action="#buildURL('summary')#">
			<input type="hidden" name="SearchID" id="SearchID" value="#rc.SearchID#">
			<input type="hidden" name="Air" id="Air" value="#Air#">
			<input type="hidden" name="Car" id="Car" value="#Car#">
			<input type="hidden" name="Hotel" id="Hotel" value="#Hotel#">
			<input type="hidden" name="nTraveler" id="nTraveler" value="1">
			<cfif air>
				<input type="hidden" name="sCarriers" id="sCarriers" value="#ArrayToList(stItinerary.Air.Carriers)#">
			</cfif>
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
			<cfset variables.tripTotal = 0>
			<cfset variables.stTraveler = (StructKeyExists(session.searches[rc.SearchID].stTravelers, nTraveler) ? session.searches[rc.SearchID].stTravelers[nTraveler] : {})>
			<div id="traveler" class="tab_content">
				<p>
					<div class="summarydiv" style="background-color: ##FFF">
						#View('summary/user')#
					</div>

					<div class="summarydiv" style="background-color: ##FFF">
						<div id="paymentForm"><table width="500"><tr><td></td></tr></table></div>
					</div>
					<br class="clearfix">

					#View('summary/air')#
					<br class="clearfix">

					<cfif Car>
						#View('summary/car')#
						<br class="clearfix">
					</cfif>

					#View('summary/buttons')#
				</p>
			</div>
		</form> --->
		<!---<cfdump var="#session.searches[rc.SearchID].stTravelers#">
		<cfdump var="#stItinerary.Car#">
		<!--- <cfset sType = (StructKeyExists(stTraveler, 'Type') ? stTraveler.Type : 'New')> --->
		<!--- <cfdump var="#session.searches[rc.SearchID].stTravelers#"> --->
		<cfif NOT structKeyExists(session.searches[rc.SearchID].stTravelers[nTraveler], 'User_ID')>
			<cfset userID = rc.Filter.getProfileID()>
		<cfelse>
			<cfset userID = session.searches[rc.SearchID].stTravelers[nTraveler].User_ID>
		</cfif>
		<script type="text/javascript">
		$(document).ready(function() {
			getAuthorizedTravelers(#userID#, #session.acctID#);
			getUser(#userID#);
			getUserCCEmails(#userID#);
			//setUser(User);
			<!---//setTravelerForm(1, 1, #userID#);--->
		});
		</script>--->

<!--- <cfelse>
	<cfoutput>
		#View('summary/error')#
	</cfoutput>
</cfif> --->
