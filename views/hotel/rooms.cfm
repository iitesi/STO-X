<!--- call the hotelrooms component --->
<cfinvoke component="services.hotelrooms" method="getRooms" nSearchID="#Search_ID#" nHotelCode="#PropertyID#" returnvariable="rates">

<div class="roundall" style="padding:10px;background-color:##FFFFFF; display:table;font-size:11px;width:600px">
<table width="600px">
<cfoutput query="rates">
	<cfset PolicyFlag = rates.Policy ? 1 : 0 />
	<tr>
		<td width="20%">#DollarFormat(rates.Rate)# #rates.CurrencyCode NEQ 'USD' ? rates.CurrencyCode : ''# per night</td>
		<td width="65%">#rates.RoomDescription#</td>
		<td width="15%">#rates.RoomRateCategory# <a href="##" onClick="submitHotel(#rates.PropertyID#&'RoomNumber');return false" class="button#PolicyFlag#policy">Reserve</a>
			<cfif rates.Policy EQ false>
				<font color="##C7151A">Out of Policy</font>
			</cfif></td>
	</tr>
</cfoutput>
</table>
</div>
An abort is necessary, but shouldn't be. <cfabort>
<!---
	//table+=val[5];// rate code
	/* Government rates
	if (val[5].indexOf(hotel_ratecodes) <= 0) {
		table += '</div>';
	}
	else {
		table += '<img src="../img/corprate.gif"></div>';
	}					
	*/
	--->