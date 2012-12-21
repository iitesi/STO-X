<cfset AirSelection = session.searches[url.Search_ID].stItinerary.Air />
<cfset OriginalDate = AirSelection.Depart>

AA2765 DSM-DFW AA W 4/1/2013 9:50 - 14:50<br />
AA894  DFW-DSM AA N 4/4/2013 2:40 - 16:25<br />
<cfoutput>
Base - #AirSelection.Base#<br />
Class - #AirSelection.Class#<br />
Taxes - #AirSelection.Taxes#<br />
Total - #AirSelection.Total#<br /><br />
</cfoutput>

<cfoutput>
	<cfloop from="-7" to="7" index="AddDays">
		<cfif AddDays NEQ 0>
			<cfinvoke component="booking.services.couldyou" method="doAirPriceCouldYou" nSearchID="#url.Search_ID#"
			nTrip="#AirSelection.nTrip#" sCabin="#AirSelection.Class#" bRefundable="#AirSelection.Ref#" nTripDay="#AddDays#" returnvariable="nTotalPrice">

			#DateAdd('d',AddDays,OriginalDate)# - #nTotalPrice#<br>
		<cfelse>
			#OriginalDate# - #AirSelection.Total# - ORIGINAL<br>
		</cfif>
	</cfloop>
</cfoutput>