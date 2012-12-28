
<cfset stTraveler 	= (StructKeyExists(session.searches[rc.nSearchID].stTravelers, nTraveler) ? session.searches[rc.nSearchID].stTravelers[nTraveler] : {})>
<cfset sType 		= (StructKeyExists(stTraveler, 'Type') ? stTraveler.Type : 'New')>
<cfoutput>
	<div class="summarydiv">
<!---
SUMMARY OF TRAVELER
--->			
		<div id="travelerSummary"> </div>
<!---
TRAVELER FORM
--->	
		<div id="travelerForm" style="display:none;"> </div>
	</div>
</cfoutput>
<!--- <cfdump var="#session.searches[rc.nSearchID].stTravelers#"> --->
<script type="text/javascript">
function showTravelerSummary(nTraveler) {
	var nSearchID = $( "#nSearchID" ).val();
	$.ajax({
		type: 'POST',
		url: 'services/traveler.cfc',
		data: {
			method: 'showTravelerSummary',
			nSearchID: nSearchID,
			nTraveler: nTraveler
		},
		dataType: 'json',
		success: function(data) {
			$( "#travelerSummary" ).html(data).show();
			$( "#travelerForm" ).hide();
		}
	});
}
function showForm(nTraveler) {
	var nSearchID = $( "#nSearchID" ).val();
	$.ajax({
		type: 'POST',
		url: 'services/traveler.cfc',
		data: {
			method: 'setTravelerForm',
			nTraveler: nTraveler,
			nSearchID: nSearchID
		},
		dataType: 'json',
		success: function(data) {
			$( "#travelerForm" ).html(data);
			$( "#travelerForm" ).show();
			$( "#travelerSummary" ).hide();
		}
	});
}
function changeTraveler(nTraveler) {
	console.log('ran')
	var nSearchID = $( "#nSearchID" ).val();
	var User_ID = $( "#User_ID" ).val();
	$.ajax({
		type: 'POST',
		url: 'services/traveler.cfc',
		data: {
			method: 'getUser',
			nTraveler: nTraveler,
			nSearchID: nSearchID,
			User_ID: User_ID
		},
		dataType: 'json',
		success: function(data) {
			showForm(nTraveler);
		}
	});
}
function saveTraveler(nTraveler) {
	var nSearchID = $( "#nSearchID" ).val();
	var First_Name = $( "#First_Name" + nTraveler ).val();
	var Middle_Name = $( "#Middle_Name" + nTraveler ).val();
	var Last_Name = $( "#Last_Name" + nTraveler ).val();
	var Phone_Number = $( "#Phone_Number" + nTraveler ).val();
	var Wireless_Phone = $( "#Wireless_Phone" + nTraveler ).val();
	var Email = $( "#Email" + nTraveler ).val();
	var CCEmail = $( "#CCEmail" + nTraveler ).val();
	var Month = $( "#Month" + nTraveler ).val();
	var Day = $( "#Day" + nTraveler ).val();
	var Year = $( "#Year" + nTraveler ).val();
	var Gender = $( "#Gender" + nTraveler ).val();
	$.ajax({
		type: 'POST',
		url: 'services/traveler.cfc',
		data: {
			method: 'saveTraveler',
			nTraveler: nTraveler,
			nSearchID: nSearchID,
			First_Name: First_Name,
			Middle_Name: Middle_Name,
			Last_Name: Last_Name,
			Phone_Number: Phone_Number,
			Wireless_Phone: Wireless_Phone,
			Email: Email,
			CCEmail: CCEmail,
			Month: Month,
			Day: Day,
			Year: Year,
			Gender: Gender
		},
		dataType: 'json',
		success: function(data) {
			$( "#traveler" + nTraveler + "summary" ).html(data);
			$( "#traveler" + nTraveler + "summary" ).show();
			$( "#traveler" + nTraveler + "form" ).hide();
		}
	});
}
$(document).ready(function() {
	showTravelerSummary(1);
});
</script>