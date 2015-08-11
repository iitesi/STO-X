<cfoutput>
<cfif len(LTRIM(RTRIM(rc.Hotel.getRooms()[1].getPPNRateDescription())))>
<p>
<span class="bold">Rate Description</span><br>
#rc.Hotel.getRooms()[1].getPPNRateDescription()#
</p>
</cfif>
<cfif len(LTRIM(RTRIM(rc.Hotel.getRooms()[1].getDepositPolicy())))>
<p>
<span class="bold">Pre-Pay Policy and Room Charge Disclosure</span><br>
#rc.Hotel.getRooms()[1].getDepositPolicy()#
</p>
</cfif>
<cfif len(LTRIM(RTRIM(rc.Hotel.getRooms()[1].getCancellationPolicy())))>
<p>
<span class="bold">Cancellation Policy</span><br>
#rc.Hotel.getRooms()[1].getCancellationPolicy()#
</p>
</cfif>
<cfif len(LTRIM(RTRIM(rc.Hotel.getRooms()[1].getGuaranteePolicy())))>
<p>
<span class="bold">Guarantee Policy</span><br>
#rc.Hotel.getRooms()[1].getGuaranteePolicy()#
</p>
</cfif>
</cfoutput>