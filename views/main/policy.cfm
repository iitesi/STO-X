<cfif structKeyExists(rc, 'Policy') AND NOT structIsEmpty(rc.Policy)>
    <div class="one-third column">
        <h3>Air Policy</h3>
    <ul>
	<cfoutput>
		<cfif rc.Policy.Policy_AirLowRule EQ 1>
                <li>Book lowest fare<cfif rc.Policy.Policy_AirLowPad GT 5> within $#NumberFormat(rc.Policy.Policy_AirLowPad)#</cfif></li>
		</cfif>
		<cfif rc.Policy.Policy_AirMaxRule EQ 1>
                <li>Max fare allowed $#NumberFormat(rc.Policy.Policy_AirMaxTotal)#</li>
		</cfif>
		<cfif rc.Policy.Policy_AirAdvRule EQ 1>
                <li>Advance purchase of #rc.Policy.Policy_AirAdv# day<cfif rc.Policy.Policy_AirAdv GT 1>s</cfif></li>
		</cfif>
		<cfif rc.Policy.Policy_AirRefDisp EQ 1>
                <li>Book refundable tickets</li>
		</cfif>
		<cfif rc.Policy.Policy_AirNonRefDisp EQ 1>
                <li>Book non refundable tickets</li>
		</cfif>
		<cfif rc.Policy.Policy_AirPrefRule EQ 1>
			<cfif rc.Policy.Policy_AirPrefDisp EQ 1>
                    <li>Must book preferred carrier</li>
				<cfelse>
                    <li>Book preferred carrier</li>
			</cfif>
		</cfif>
	</cfoutput>
    </ul>
        <h3>Hotel Policy</h3>
    <ul>
	<cfoutput>
		<cfif rc.Policy.Policy_HotelMaxRule EQ 1>
                <li>Max rate allowed $#NumberFormat(rc.Policy.Policy_HotelMaxRate)#</li>
		</cfif>
		<cfif rc.Policy.Policy_HotelPrefRule EQ 1>
                <li>Book preferred chain</li>
		</cfif>
	</cfoutput>
    </ul>
        <h3>Car Policy</h3>
    <ul>
	<cfoutput>
		<cfif rc.Policy.Policy_CarMaxRule EQ 1>
                <li>Max daily rate allowed $#NumberFormat(rc.Policy.Policy_CarMaxRate)#</li>
		</cfif>
		<cfif rc.Policy.Policy_CarTypeRule EQ 1>
                <li>Book specific car types</li>
		</cfif>
		<cfif rc.Policy.Policy_CarPrefRule EQ 1>
			<cfif rc.Policy.Policy_CarPrefDisp EQ 1>
                <li>Must book preferred vendor</li>
			<cfelse>
                <li>Book preferred vendor</li>
			</cfif>
		</cfif>
	</cfoutput>
    </ul>
    </div>
</cfif>