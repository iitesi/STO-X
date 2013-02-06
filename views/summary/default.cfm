<cfif application.Accounts[session.AcctID].CouldYou>
	<cfoutput>
		<a href="?action=couldyou&SearchID=#url.SearchID#">CouldYou</a>
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
function setTravelerForm(nTraveler, bCollapse) {
	var SearchID = $( "#SearchID" ).val();
	$.ajax({
		type: 'POST',
		url: 'services/traveler.cfc',
		data: {
			method: 'setTravelerForm',
			nTraveler: nTraveler,
			SearchID: SearchID,
			bCollapse: bCollapse
		},
		dataType: 'json',
		success: function(data) {
			$( "#travelerForm" ).html(data);
		}
	});
}
function setPaymentForm(nTraveler) {
	var SearchID = $( "#SearchID" ).val();
	var Air = $( "#Air" ).val();
	var Car = $( "#Car" ).val();
	var Hotel = $( "#Hotel" ).val();
	var bCD = $( "#bCD" ).val();
	var bDB = $( "#bDB" ).val();
	$.ajax({
		type: 'POST',
		url: 'services/traveler.cfc',
		data: {
			method: 'setPaymentForm',
			nTraveler: nTraveler,
			SearchID: SearchID,
			Air: Air,
			Car: Car,
			Hotel: Hotel,
			bCD: bCD,
			bDB: bDB
		},
		dataType: 'json',
		success: function(data) {
			$( "#paymentForm" ).html(data);
		}
	});
}
function setOtherFields(nTraveler) {
	var SearchID = $( "#SearchID" ).val();
	$.ajax({
		type: 'POST',
		url: 'services/traveler.cfc',
		data: {
			method: 'getTraveler',
			nTraveler: nTraveler,
			SearchID: SearchID
		},
		dataType: 'json',
		success: function(traveler) {
			//set global variables
			var sCarriers = $( "#sCarriers" ).val().split(',');
			var sCarVendor = $( "#sCarVendor" ).val();
			//set variables if defined
			var stAirFFs = new Object();
			if (typeof traveler['STFFACCOUNTS'] != 'undefined'
			&& typeof traveler['STFFACCOUNTS']['A'] != 'undefined') {
				stAirFFs = traveler['STFFACCOUNTS']['A'];
			}
			var stCarFFs = new Object();
			if (typeof traveler['STFFACCOUNTS'] != 'undefined'
			&& typeof traveler['STFFACCOUNTS']['C'] != 'undefined') {
				stCarFFs = traveler['STFFACCOUNTS']['C'];
			}
			var stHotelFFs = new Object();
			if (typeof traveler['STFFACCOUNTS'] != 'undefined'
			&& typeof traveler['STFFACCOUNTS']['H'] != 'undefined') {
				stHotelFFs = traveler['STFFACCOUNTS']['H'];
			}
			var stFOPs = new Object();
			if (typeof traveler['STFOPS'] != 'undefined') {
				stFOPs = traveler['STFOPS'];
			}
			var sSeat = '';
			if (typeof traveler['WINDOW_AISLE'] != 'undefined') {
				sSeat = traveler['WINDOW_AISLE'];
			}
			//logic to update form fields
			for (var i = 0; i < stFOPs.length; i++) {
				console.log(stFOPs[i]);
				
			}
			for (var i = 0; i < sCarriers.length; i++) {
				if (typeof stAirFFs[sCarriers[i]] != 'undefined') {
					$( "#Air_FF" + sCarriers[i] ).val(stAirFFs[sCarriers[i]]);
				}
				else {
					$( "#Air_FF" + sCarriers[i] ).val('');
				}
			}
			if (typeof stCarFFs[sCarVendor] != 'undefined') {
				$( "#Car_FF" ).val(stCarFFs[sCarVendor]);
			}
			else {
				$( "#Car_FF" ).val('');
			}
			$( "#Seats" ).val(sSeat);
		}
	});
}
function changeTraveler(nTraveler) {
	var SearchID = $( "#SearchID" ).val();
	var UserID = $( "#User_ID" ).val();
	$( "#travelerForm" ).html('<table width="500" height="290"><tr height="23"><td valign="top">Gathering profile data...</td></tr></table>');
	$.ajax({
		type: 'POST',
		url: 'services/traveler.cfc',
		data: {
			method: 'getUser',
			nTraveler: nTraveler,
			SearchID: SearchID,
			UserID: UserID
		},
		dataType: 'json',
		success: function(data) {
			setTravelerForm(nTraveler, 1);
			setPaymentForm(nTraveler);
			setOtherFields(nTraveler);
		},
		error: function(data, dat, da) {
			$( "#travelerForm" ).html(data);
		}
	});
}
$(document).ready(function() {
	setTravelerForm(1, 1);
	setPaymentForm(1);
	setOtherFields(1);
});
</script>