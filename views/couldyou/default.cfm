<!--- <cfdump var="#session.searches[url.Search_ID].CouldYou#"> --->
<!--- <cfdump var="#session.searches[url.Search_ID].stItinerary#"> --->

<cfset SelectedTotal = 0 />
<!--- Air --->
<cfif session.searches[url.Search_ID].bAir EQ 1>Air
	<cfset AirSelection = session.searches[url.Search_ID].stItinerary.Air />
	<cfset OriginDate = AirSelection.Depart>
	<cfset SelectedTotal+= AirSelection.Total />
</cfif>
<!--- Car --->
<cfif session.searches[url.Search_ID].bCar EQ 1>Car
	<cfset CarSelection = session.searches[url.Search_ID].stItinerary.Car />
	<cfset SelectedTotal+= Mid(CarSelection.EstimatedTotalAmount,4) />
</cfif>
<!--- Hotel --->
<cfif session.searches[url.Search_ID].bHotel EQ 1>Hotel
	<cfset HotelSelection = session.searches[url.Search_ID].stItinerary.Hotel /> 	
	<cfset HotelChain = session.searches[rc.Search_ID].stHotels[HotelSelection.HotelID].HotelChain />
	<cfset SelectedTotal+= HotelSelection.TotalRate />
</cfif>

<cfset TableSize = 1200 />
<cfoutput>
	<br />Current Total - #DollarFormat(SelectedTotal)#<br />
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
						
						<td class="calendarDay"#tdName#>
						<cfif Start AND viewDay LTE DaysInMonth(calendarDate) AND NOT Done>
							#viewDay# 
							<cfset DateDifference = DateDiff('d',DateFormat(OriginDate,'m/d/yyyy'),DateFormat(CreateDate(Year(calendarDate), Month(calendarDate),viewDay),'m/d/yyyy')) />
							<cfset viewDate = DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),"yyyymmdd") />
							<cfif Len(Trim(tdName))><br />
								<img src="assets/img/ajax-loader.gif" />
								<script type="text/javascript">
								<cfif session.searches[url.Search_ID].bAir EQ 1>couldYouAir(#url.Search_ID#,'#AirSelection.nTrip#','#AirSelection.Class#','#AirSelection.Ref#',#DateDifference#,#viewDate#,#DateDifference#,#SelectedTotal#);</cfif>
								<cfif session.searches[url.Search_ID].bHotel EQ 1>couldYouHotel(#url.Search_ID#,'#HotelSelection.HotelID#','#HotelSelection.HotelChain#',#DateDifference#,#HotelSelection.Nights#,#viewDate#,#SelectedTotal#);</cfif>
								<cfif session.searches[url.Search_ID].bCar EQ 1>couldYouCar(#url.Search_ID#,'#CarSelection.VendorCode#','#CarSelection.VehicleClass##CarSelection.Category#',#DateDifference#,#viewDate#,#SelectedTotal#);</cfif>
								</script>
							</cfif>
							<!--- Existing trip Start Day --->
							<cfif DateFormat(OriginDate,'yyyymmdd') EQ viewDate>
								<br />#DollarFormat(SelectedTotal)#
							</cfif>
						</cfif></td>
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
</cfoutput>

	
<cfoutput>
	<!---
	<table width="800px">
	<tr>
		<td>Date</td>
		<td>Air</td>
		<td>Hotel</td>
		<td>Car</td>
		<td>Total</td>
	</tr>
	<cfloop from="-7" to="7" index="AddDays">
		<tr>
			<td>#DateFormat(DateAdd('d',AddDays,OriginDate),'yyyymmdd')#<cfif AddDays EQ 0> - ORIGINAL</cfif></td>
			<cfif AddDays NEQ 0>
				<cfinvoke component="booking.services.couldyou" method="doAirPriceCouldYou" nSearchID="#url.Search_ID#" nTrip="#AirSelection.nTrip#" sCabin="#AirSelection.Class#" bRefundable="#AirSelection.Ref#" nTripDay="#AddDays#" returnvariable="nTotalPrice">
				<!--- <cfinvoke component="booking.services.couldyou" method="doHotelPriceCouldYou" nSearchID="#url.Search_ID#" nHotelCode="#HotelSelection.HotelID#" sHotelChain="#HotelChain#" nTripDay="#AddDays#" nNights="#HotelSelection.Nights#" returnvariable="nhotelprice">
				<cfinvoke component="booking.services.couldyou" method="doCarPriceCouldYou" nSearchID="#url.Search_ID#" nTripDay="#AddDays#" nNights="#HotelSelection.Nights#" sCarChain="#CarSelection.VendorCode#" sCarType="#CarSelection.VehicleClass##CarSelection.Category#" returnvariable="nCarPrice"> --->
				<td>#nTotalPrice#</td>
				<!--- <td>#nhotelprice#</td>
				<td>#nCarPrice#</td>
				<td>#isNumeric(nTotalPrice) ? nTotalPrice + nhotelprice + nCarPrice : nTotalPrice#</td> --->
			<cfelse>
				<td>#AirSelection.Total#</td>
				<!--- <td>#HotelSelection.TotalRate#</td>
				<td>#Mid(CarSelection.EstimatedTotalAmount,4)#</td>
				<td>#AirSelection.Total + HotelSelection.TotalRate#</td> --->
			</cfif>
		</tr>
	</cfloop>
	</table>
	--->
 	
	<!---
	<cfloop from="-7" to="7" index="AddDays">
		#DateFormat(DateAdd('d',AddDays,OriginDate),'yyyymmdd')#<cfif AddDays EQ 0> - ORIGINAL</cfif>
			<cfif AddDays NEQ 0>
				<cfif AddDays EQ 1>					
					<cfinvoke component="booking.services.couldyou" method="doCarPriceCouldYou" nSearchID="#url.Search_ID#" nTripDay="#AddDays#" nNights="#HotelSelection.Nights#" 
					sCarChain="#CarSelection.VendorCode#" sCarType="#CarSelection.VehicleClass##CarSelection.Category#"
					returnvariable="nTotalPrice">
					#nTotalPrice#<br />
				</cfif>
			<cfelse>
				car total<br />
			</cfif>
		</tr>
	</cfloop>
	--->
</cfoutput>