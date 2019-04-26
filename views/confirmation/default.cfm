<cfoutput>
	
	<cfif NOT structKeyExists(rc, 'Cancelled')>

		<cfif structKeyExists(rc.Sell, 'RecordLocator')
			AND structKeyExists(rc.Sell.RecordLocator, 'UniversalRecordLocatorCode')
			AND structKeyExists(rc.Sell, 'HasErrors')
			AND NOT rc.Sell.HasErrors>

				Success!
				<br><br>
				Trip Reference #rc.Sell.RecordLocator.UniversalRecordLocatorCode#<br>
				Thank you for booking with Shorts Travel Management.<br>
				You will receive a confirmation email within 24 hours. In the meantime, you can click the View Your Trip button below to see your itinerary.
				<br><br>
				<a href="https://viewtrip.travelport.com/itinerary?loc=#rc.Sell.RecordLocator.ProviderRecordLocatorCode#&lName=#session.searches[rc.searchID].Travelers[1].getLastName()#" target="_blank">View Your Trip</a>
				<br><br>
				<a href="#buildURL('purchase.canceltrip?SearchId=#SearchId#&CancelTrip=#rc.Sell.RecordLocator.UniversalRecordLocatorCode#')#">Cancel Trip</a>
				<br><br>

		<cfelse>

			Error
			<br><br>

		</cfif>

		<cfdump var=#rc.Sell#>

	<cfelse>

		Your trip has been cancelled.

	</cfif>


</cfoutput>