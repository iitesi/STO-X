<!--- TODO: gkernen - I'll move this to shared static asset --->
<style>

.checkmark {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  stroke-width: 2;
  stroke: #fff;
  stroke-miterlimit: 10;
  box-shadow: inset 0px 0px 0px #7ac142;
  animation: fill 0.4s ease-in-out 0.4s forwards, scale 0.3s ease-in-out 0.9s both;
}
.checkmark__circle {
  stroke-dasharray: 166;
  stroke-dashoffset: 166;
  stroke-width: 2;
  stroke-miterlimit: 10;
  stroke: #7ac142;
  fill: none;
  animation: stroke 0.6s cubic-bezier(0.65, 0, 0.45, 1) forwards;
}
.checkmark__check {
  transform-origin: 50% 50%;
  stroke-dasharray: 48;
  stroke-dashoffset: 48;
  animation: stroke 0.3s cubic-bezier(0.65, 0, 0.45, 1) 0.8s forwards;
}
@keyframes stroke {
  100% {
    stroke-dashoffset: 0;
  }
}
@keyframes scale {
  0%, 100% {
    transform: none;
  }
  50% {
    transform: scale3d(1.1, 1.1, 1);
  }
}
@keyframes fill {
  100% {
    box-shadow: inset 0px 0px 0px 30px #7ac142;
  }
}

.confirmation-x {
	text-align: center;
	font-size: 1.5rem;
}

.confirmation-x h3 {
	font-size: 17px !important;
	font-weight: bold !important;
}

</style>

<cfoutput>
	
	<cfif structKeyExists(rc.Sell, 'RecordLocator')
		AND structKeyExists(rc.Sell.RecordLocator, 'UniversalRecordLocatorCode')
		AND structKeyExists(rc.Sell, 'HasErrors')
		AND NOT rc.Sell.HasErrors>

		<div class="confirmation-x ">
			<br><br>
			<h3>Success!</h3>
			<svg class="checkmark" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 52">
				<circle class="checkmark__circle" cx="26" cy="26" r="25" fill="none"/>
				<path class="checkmark__check" fill="none" d="M14.1 27.2l7.1 7.2 16.7-16.8"/>
			</svg>
			<p>
				<br>
				Trip Reference ## #rc.Sell.RecordLocator.UniversalRecordLocatorCode#
			</p>
			<p>
				<br>
				Thank you for booking with Shorts Travel Management.
				You will receive a confirmation email within 24 hours. 
				In the meantime, you can click the View Your Trip button 
				below to see your itinerary.
			</p>
			<p>
				<br>
				<a class="btn btn-primary btn-lg" href="https://viewtrip.travelport.com/itinerary?loc=#rc.Sell.RecordLocator.ProviderRecordLocatorCode#&lName=#session.searches[rc.searchID].Travelers[1].getLastName()#" target="_blank">View Your Trip</a>
				<a class="btn btn-secondary btn-lg" href="#buildURL('purchase.canceltrip?SearchId=#SearchId#&CancelTrip=#rc.Sell.RecordLocator.UniversalRecordLocatorCode#')#">Cancel Trip</a>
			</p>
		</div>

	<cfelse>

		Your trip has been cancelled.

	</cfif>

	<!---
	<cfdump var=#rc.Sell#>
	--->

</cfoutput>