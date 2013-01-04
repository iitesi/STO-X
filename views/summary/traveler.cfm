
<cfset stTraveler 	= (StructKeyExists(session.searches[rc.nSearchID].stTravelers, nTraveler) ? session.searches[rc.nSearchID].stTravelers[nTraveler] : {})>
<cfset sType 		= (StructKeyExists(stTraveler, 'Type') ? stTraveler.Type : 'New')>
<cfoutput>
	<div class="summarydiv">	
		<div id="travelerForm"> </div>
	</div>
</cfoutput>
<!--- <cfdump var="#session.searches[rc.nSearchID].stTravelers#"> --->
<script type="text/javascript">
function setTravelerForm(nTraveler, bCollapse) {
	var nSearchID = $( "#nSearchID" ).val();
	$.ajax({
		type: 'POST',
		url: 'services/traveler.cfc',
		data: {
			method: 'setTravelerForm',
			nTraveler: nTraveler,
			nSearchID: nSearchID,
			bCollapse: bCollapse
		},
		dataType: 'json',
		success: function(data) {
			$( "#travelerForm" ).html(data);
		}
	});
}
function setOtherFields(nTraveler) {
	var nSearchID = $( "#nSearchID" ).val();
	$.ajax({
		type: 'POST',
		url: 'services/traveler.cfc',
		data: {
			method: 'getTraveler',
			nTraveler: nTraveler,
			nSearchID: nSearchID
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
			var sSeat = '';
			if (typeof traveler['WINDOW_AISLE'] != 'undefined') {
				sSeat = traveler['WINDOW_AISLE'];
			}
			//logic to update form fields
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
			console.log(sSeat)
		}
	});
}
function changeTraveler(nTraveler) {
	var nSearchID = $( "#nSearchID" ).val();
	var User_ID = $( "#User_ID" ).val();
	$( "#travelerForm" ).html('<table width="500" height="290"><tr height="23"><td valign="top">Gathering profile data...</td></tr></table>');
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
			setTravelerForm(nTraveler, 1);
			setOtherFields(nTraveler);
		},
		error: function(data, dat, da) {
			$( "#travelerForm" ).html(data);
		}
	});
}
$(document).ready(function() {
	setTravelerForm(1, 1);
	setOtherFields(1);
});
</script>