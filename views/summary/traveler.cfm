<script type="text/javascript">
function showForm(nTraveler) {
	var nSearchID = $( "#nSearchID" ).val();
	$.ajax({
		type: 'POST',
		url: 'services/summary.cfc',
		data: {
			method: 'setTravelerForm',
			nTraveler: nTraveler,
			nSearchID: nSearchID
		},
		dataType: 'json',
		success: function(data) {
			$( "#traveler" + nTraveler + "summary" ).hide();
			$( "#traveler" + nTraveler + "form" ).show();
			$( "#traveler" + nTraveler + "form" ).html(data);
		}
	});
}
function addTraveler(nTraveler) {
	var User_ID = $( "#User_ID" + nTraveler ).val();
	var nSearchID = $( "#nSearchID" ).val();
	$.ajax({
		type: 'POST',
		url: 'services/summary.cfc',
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
		url: 'services/summary.cfc',
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
			console.log(data)
			$( "#traveler" + nTraveler + "summary" ).show();
			$( "#traveler" + nTraveler + "form" ).hide();
			$( "#traveler" + nTraveler + "summary" ).html(data);
		}
	});
}
</script>
<cfoutput>
	<input type="hidden" name="nSearchID" id="nSearchID" value="#rc.nSearchID#">
	<table>
	<tr>
		<cfloop from="1" to="4" index="nTraveler">
			<td valign="top" width="200">
				<div class="summarydiv" style="float:left;position:relative;width:200px">
					<!--- <cfdump var="#session.searches[rc.nSearchID].stTravelers#" abort="true"> --->
					<cfset stTraveler = (StructKeyExists(session.searches[rc.nSearchID].stTravelers, nTraveler) ? session.searches[rc.nSearchID].stTravelers[nTraveler] : {})>
					<cfset Type = (StructKeyExists(stTraveler, 'Type') ? stTraveler.Type : 'New')>
<!---
SUMMARY OF TRAVELER
--->			
					<div id="traveler#nTraveler#summary">
						<cfif Type NEQ 'New'>
							<h3>#stTraveler.Last_Name#/#stTraveler.First_Name# #stTraveler.Middle_Name#</h3><br>
							<a href="##" onClick="showForm(#nTraveler#);" style="float:right">edit</a>
							#stTraveler.Phone_Number#<br>
							#stTraveler.Wireless_Phone#<br>
							#stTraveler.Email#<br>
							#stTraveler.CCEmail#<br>
							#DateFormat(stTraveler.Birthdate, 'mmmm d, yyyy')#<br>
							#(stTraveler.Gender EQ 'F' ? 'Female' : 'Male')#
						<cfelse>
							<a href="##" onClick="showForm(#nTraveler#);" style="float:right">+ Add Traveler</a>
						</cfif>
					</div>
<!---
TRAVELER FORM
--->	
					<div id="traveler#nTraveler#form" style="display:none;">
						
					</div>
				</div>
			</td>
		</div>
	</cfloop>
	</tr>
	</table>
</cfoutput>