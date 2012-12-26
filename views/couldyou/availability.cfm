<script type="text/javascript">
function couldYouAir(search_id,trip,cabin,refundable,adddays,startdate,viewDay) {
	$.ajax({type:"POST",
		url:"services/couldyou.cfc?method=doAirPriceCouldYou",
		data:"nSearchID="+search_id+"&nTrip="+trip+"&sCabin="+cabin+"&bRefundable="+refundable+"&nTripDay="+adddays+"&nStartDate="+startdate,
		async: true,
		dataType: 'json',
		timeOut: 5000,
		success:function(data) {
			var AirTotal = '$' + data;
			if (AirTotal == '$0') {
				AirTotal = 'Flight Does not Operate';
			}
			$("#Air"+startdate).html('<a href="##" title="Air - '+AirTotal+'">'+viewDay+'</a>');
		},
		error:function(test, tes, te) {
			console.log(startdate);
			console.log(test);
			console.log(tes);
			console.log(te);
		}
	});
	return false;
}
</script>

<cfif NOT structKeyExists(session.searches[url.Search_ID],'CouldYou')>
	<cfset session.searches[url.Search_ID].CouldYou = {} />
</cfif>
<cfset AirSelection = session.searches[url.Search_ID].stItinerary.Air />
<cfset OriginDate = AirSelection.Depart>
 
AA2765 DSM-DFW AA W 4/1/2013 9:50 - 14:50<br />
AA894  DFW-DSM AA N 4/4/2013 2:40 - 16:25<br />
<cfoutput>
	Base - #AirSelection.Base#<br />
	Class - #AirSelection.Class#<br />
	Taxes - #AirSelection.Taxes#<br />
	Total - #AirSelection.Total#<br /><br />

	<table>
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
			<table>
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
								<cfif Len(Trim(tdName))>
									<script type="text/javascript">
									couldYouAir(#url.Search_ID#, '#AirSelection.nTrip#', '#AirSelection.Class#', '#AirSelection.Ref#', '#datediff("d",DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),"m/d/yyyy"),DateFormat(OriginDate,"m/d/yyyy"))#', '#DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),"yyyymmdd")#',#viewDay#);
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
</cfoutput>
<br> 

<cfoutput>
	<cfloop from="-7" to="7" index="AddDays">
		<cfif AddDays NEQ 0>
			<cfinvoke component="booking.services.couldyou" method="doAirPriceCouldYou" nSearchID="#url.Search_ID#"
			nTrip="#AirSelection.nTrip#" sCabin="#AirSelection.Class#" bRefundable="#AirSelection.Ref#" nTripDay="#AddDays#" returnvariable="nTotalPrice">
			
			<!---
			<script type="text/javascript">
				couldYouAir(#url.Search_ID#, '#AirSelection.nTrip#', '#AirSelection.Class#', '#AirSelection.Ref#', '#AddDays#', '#DateFormat(OriginDate,"m/d/yyyy")#');
			</script>
			<a href="http://localhost:8888/booking/services/couldyou.cfc?method=doAirPriceCouldYou&nSearchID=#search_id#&nTrip=#AirSelection.nTrip#&sCabin=#AirSelection.Class#&bRefundable=#AirSelection.Ref#&nTripDay=#adddays#">Link</a>
			--->
			#DateFormat(DateAdd('d',AddDays,OriginDate),'yyyymmdd')#<!---  - #nTotalPrice# ---><br>
		<cfelse>
			#DateFormat(OriginDate,'yyyymmdd')# - #AirSelection.Total# - ORIGINAL<br>
		</cfif>
	</cfloop>
</cfoutput>