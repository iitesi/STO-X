<!--- <cfdump var="#session.searches[url.SearchID].CouldYou#"> --->
<!--- <cfdump var="#session.searches[url.SearchID].stItinerary#"> --->

<cfset SelectedTotal = 0 />
<!--- Air --->
<cfif rc.Filter.getAir()>Air
	<cfset AirSelection = session.searches[url.SearchID].stItinerary.Air />
	<cfset OriginDate = AirSelection.Depart>
	<cfset SelectedTotal+= AirSelection.Total />
</cfif>
<!--- Car --->
<cfif rc.Filter.getCar()>Car
	<cfset CarSelection = session.searches[url.SearchID].stItinerary.Car />
	<cfset SelectedTotal+= Mid(CarSelection.EstimatedTotalAmount,4) />
</cfif>
<!--- Hotel --->
<cfif rc.Filter.getHotel()>Hotel
	<cfset HotelSelection = session.searches[url.SearchID].stItinerary.Hotel />
	<cfset HotelChain = session.searches[rc.SearchID].stHotels[HotelSelection.HotelID].HotelChain />
	<cfset SelectedTotal+= HotelSelection.TotalRate />
</cfif>

<cfset TableSize = 1200 />
<cfoutput>
	<br />Current Total - #DollarFormat(SelectedTotal)#<br />
	<table width="#TableSize#px">
	<tr>
	
	<!--- First day of Find It --->
	<cfset calendarStartDate = dateAdd('d',-7,OriginDate) />
	<cfset stCouldYou = session.searches[url.SearchID].CouldYou />
	
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
								<!---
								<img src="assets/img/ajax-loader.gif" />
								<script type="text/javascript">
								<cfif session.searches[url.SearchID].Air EQ 1>couldYouAir(#rc.SearchID#,'#AirSelection.nTrip#','#AirSelection.Class#','#AirSelection.Ref#',#DateDifference#,#viewDate#,#DateDifference#,#SelectedTotal#);</cfif>
								<cfif session.searches[url.SearchID].Hotel EQ 1>couldYouHotel(#rc.SearchID#,'#HotelSelection.HotelID#','#HotelSelection.HotelChain#',#DateDifference#,#HotelSelection.Nights#,#viewDate#,#SelectedTotal#);</cfif>
								<cfif structKeyExists(session.searches[url.SearchID], 'Car') AND session.searches[url.SearchID].Car EQ 1>couldYouCar(#rc.SearchID#,'#CarSelection.VendorCode#','#CarSelection.VehicleClass##CarSelection.Category#',#DateDifference#,#viewDate#,#SelectedTotal#);</cfif>
								</script>
								--->
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