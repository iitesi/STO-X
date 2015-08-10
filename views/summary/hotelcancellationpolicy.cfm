<cfoutput>
	<p>
	<span class="bold preferred">Rate Description</span><br>
	#rc.Hotel.getRooms()[1].getPPNRateDescription()#
	</p>
	<p>
	<span class="bold preferred">Pre-Pay Policy and Room Charge Disclosure</span><br>
	#rc.Hotel.getRooms()[1].getDepositPolicy()#
	</p>
	<p>
	<span class="bold preferred">Cancellation Policy</span><br>
	#rc.Hotel.getRooms()[1].getCancellationPolicy()#
	</p>
	<p>
	<span class="bold preferred">Guarantee Policy</span><br>
	#rc.Hotel.getRooms()[1].getGuaranteePolicy()#
	</p>
	<p>
	<span class="bold preferred">Taxes and Fees Policy</span><br>
	#rc.Hotel.getRooms()[1].getTaxPolicy()#
	</p>
</cfoutput>