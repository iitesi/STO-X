
<script type="text/javascript">
function couldYouCar(search_id,hotelcode,hotelchain,viewDay,nights,startdate) {
	$.ajax({type:"POST",
		url:"services/couldyou.cfc?method=doHotelPriceCouldYou",
		data:"nSearchID="+search_id+"&nHotelCode="+hotelcode+"&sHotelChain="+hotelchain+"&nTripDay="+viewDay+"&nNights="+nights,
		async: true,
		dataType: 'json',
		timeOut: 5000,
		success:function(data) {
			var HotelTotal = '$' + data;
			$("#Air"+startdate).append('<a href="##" title="Hotel - '+HotelTotal+'">'+viewDay+'</a>' + ' Hotel - ' + HotelTotal + '<br />');
		},
		error:function(test, tes, te) {
			console.log(test);
			console.log(tes);
			console.log(te);
		}
	});
	return false;
}
</script>

<!--- <cfdump eval=session.searches[url.Search_ID].CouldYou> --->

<cfset AirSelection = session.searches[url.Search_ID].stItinerary.Air />
<cfset OriginDate = AirSelection.Depart>
 
<cfset HotelSelection = session.searches[url.Search_ID].stItinerary.Hotel />
<!--- <cfdump eval=HotelSelection> --->
<cfset HotelChain = session.searches[rc.Search_ID].stHotels[HotelSelection.HotelID].HotelChain />

<cfset CarSelection = session.searches[url.Search_ID].stItinerary.Car />
<!--- <cfdump eval=CarSelection> --->

<cfset TableSize = 1200 />
<cfoutput>
	<table width="#TableSize#px">
	<tr>
	
	<!--- First day of Find It --->
	<cfset calendarStartDate = dateAdd('d',-7,OriginDate) />
	
	<cfloop from="1" to="2" index="MonthOption">
		<cfset calendarDate = MonthOption EQ 2 ? DateAdd('m',1,calendarStartDate) : calendarStartDate />
		<cfset Start = false>
		<cfset Done = false>
		<cfif MonthOption EQ 2>
			<td>&nbsp;&nbsp;&nbsp;</td>
		</cfif>
		<td valign="top">
			<table width="#TableSize / 2#px">
			<tr>
				<td colspan="7" align="center" class="columnHeading"><strong>#MonthAsString(Month(calendarDate))# #Year(calendarDate)#</strong></td>
			</tr>
			<tr>
			<cfloop from="1" to="7" index="i">
				<td>#Left(DayOfWeekAsString(i),2)#</td>
			</cfloop>
			</tr>

			<cfloop from="1" to="8" index="week">
				<tr>
					<cfloop from="1" to="7" index="day">
						<cfif DayOfWeek(CreateDate(Year(calendarDate), Month(calendarDate), 1)) EQ day AND NOT Start>
							<cfset Start = true>
							<cfset viewDay = 0>
						</cfif>
						<cfif Start AND viewDay LT DaysInMonth(calendarDate)>
							<cfset viewDay++>
						</cfif>

						<cfset tdName = '' />
						<cfif Start AND abs(datediff('d',DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),'m/d/yyyy'),DateFormat(OriginDate,'m/d/yyyy'))) LTE 7 AND abs(datediff('d',DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),'m/d/yyyy'),DateFormat(OriginDate,'m/d/yyyy'))) NEQ 0>
							<cfset tdName = ' id="Air#DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),'yyyymmdd')#"' />
						</cfif>
						
						<td valign="top" width="14%" style="border:1px solid ##E6E9F3; text-align:center;"#tdName#>
						<cfif Start AND viewDay LTE DaysInMonth(calendarDate) AND NOT Done>
							#viewDay#
							<cfif Len(Trim(tdName))><br />
								<script type="text/javascript">
								couldYouAir(#url.Search_ID#, '#AirSelection.nTrip#', '#AirSelection.Class#', '#AirSelection.Ref#', '#datediff("d",DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),"m/d/yyyy"),DateFormat(OriginDate,"m/d/yyyy"))#', '#DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),"yyyymmdd")#',#viewDay#);
								couldYouHotel(#url.Search_ID#, '#HotelSelection.HotelID#', '#HotelSelection.HotelChain#', #viewDay#, #HotelSelection.Nights#, '#DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),"yyyymmdd")#');
								</script>
							</cfif>
						</cfif>&nbsp;</td>
						<cfset Done = Start AND viewDay EQ DaysInMonth(calendarDate) ? true : false>
					</cfloop>
				</tr>
				<cfif Done>
					<cfbreak>
				</cfif>
			</cfloop>

			</table>
		</td>
	</cfloop>

	</tr>
	</table>


	<!--- 
	<table width="400px">
	<tr>
		<td>Date</td>
		<td>Air</td>
		<td>Hotel</td>
		<td>Total</td>
	</tr>
	<cfloop from="-7" to="7" index="AddDays">
		<tr>
			<td>#DateFormat(DateAdd('d',AddDays,OriginDate),'yyyymmdd')#<cfif AddDays EQ 0> - ORIGINAL</cfif></td>
			<cfif AddDays NEQ 0>
				<cfinvoke component="booking.services.couldyou" method="doAirPriceCouldYou" nSearchID="#url.Search_ID#" nTrip="#AirSelection.nTrip#" sCabin="#AirSelection.Class#" bRefundable="#AirSelection.Ref#" nTripDay="#AddDays#" returnvariable="nTotalPrice">
				<cfinvoke component="booking.services.couldyou" method="doHotelPriceCouldYou" nSearchID="#url.Search_ID#" nHotelCode="#HotelSelection.HotelID#" sHotelChain="#HotelChain#" nTripDay="#AddDays#" nNights="#HotelSelection.Nights#" returnvariable="nhotelprice">
				<td>#nTotalPrice#</td>
				<td>#nhotelprice#</td>
				<td>#nTotalPrice + nhotelprice#</td>
			<cfelse>
				<td>#AirSelection.Total#</td>
				<td>#HotelSelection.TotalRate#</td>
				<td>#AirSelection.Total + HotelSelection.TotalRate#</td>
			</cfif>
		</tr>
	</cfloop>
	</table>
	--->

	<!--- <cfloop from="-7" to="7" index="AddDays">
		#DateFormat(DateAdd('d',AddDays,OriginDate),'yyyymmdd')#<cfif AddDays EQ 0> - ORIGINAL</cfif>
			<cfif AddDays NEQ 0>
				<cfinvoke component="booking.services.couldyou" method="doCarPriceCouldYou" nSearchID="#url.Search_ID#" nTripDay="#AddDays#" nNights="#HotelSelection.Nights#" 
				sCarChain="#CarSelection.VendorCode#" sCarType="#CarSelection.VehicleClass##CarSelection.Category#"
				returnvariable="nTotalPrice">
				<!--- #nTotalPrice# --->
			<cfelse>
				car total
			</cfif>
		</tr>
	</cfloop> --->
</cfoutput>