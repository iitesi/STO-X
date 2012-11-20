<table class="popUpTable">
<tr>
	<td>&nbsp;</td>
	<td colspan="2">
	<p>&nbsp;</p>
	<h4>We will email this itinerary to you. Please note, this itinerary is not confirmed.</h4>
	<p>&nbsp;</p>
	<p>Rates and availability are subject to change until booked.  You will need to return 
	to the website and perform your<br> search again when you are ready to book.</p>
	<p>&nbsp;</p>
	</td>
</tr>
<cfoutput>
	<form id="emailform" action="#buildURL('air.email?Search_ID=#rc.nSearchID#&bSuppress=1')#" method="post">
		<input type="hidden" name="nSearchID" value="#rc.nSearchID#">
		<input type="hidden" name="nTripID" value="#rc.nTripID#">
		<input type="hidden" name="bSubmit" value="1">
		<tr height="23">
			<td>&nbsp;</td>
			<td><label for="Email_Name">Your Name *</label></td>
			<td><input type="text" name="Email_Name" id="Email_Name" size="40" value="#rc.qUser.First_Name# #rc.qUser.Last_Name#" disabled></td>
		</tr>
		<tr height="23">
			<td>&nbsp;</td>
			<td><label for="Email_Address">Your Email *</label></td>
			<td><input type="text" name="Email_Address" id="Email_Address" size="40" value="#rc.qUser.Email#" disabled></td>
		</tr>
		<tr height="23">
			<td>&nbsp;</td>
			<td><label for="To_Address">To Email *</label></td>
			<td><input type="text" name="To_Address" id="To_Address" size="40" value="#rc.qProfile.Email#"></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><label for="CC_Address">CC Email</label></td>
			<td><input type="text" name="CC_Address" id="CC_Address" size="60" value="#rc.qProfile.Email#"></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><label for="Email_Subject">Subject Line *</label></td>
			<td><input type="text" name="Email_Subject" id="Email_Subject" size="60" value="Tentative Itinerary for #rc.qProfile.First_Name# #rc.qProfile.Last_Name# departing #DateFormat(session.searches[rc.nSearchID].Depart_DateTime, 'ddd, mmm d')#"></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><label for="Email_Message">Message</label></td>
			<td><textarea name="Email_Message" id="Email_Message" cols="50" rows="2"></textarea></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td colspan="2"><div class="button-wrapper" style="float:right;"><a href="##" class="button" onClick="emailform.submit();"><span>SEND EMAIL</span></a></div></td>
		</tr>
		<tr>
			<td colspan="3">&nbsp;</td>
		</tr>
	</form>
</cfoutput>
</table>