<cfset stCouldYouResults = session.searches[SearchID].CouldYou />
<cfset OriginDate = session.searches[url.SearchID].stItinerary.Air.Depart />
<cfset CurrentTotal = stCouldYouResults.CurrentTotal>
<!--- <cfdump var="#stCouldYouResults#"> --->

<cfset TableSize = 1200 />
<cfoutput>
	<br />Current Total - #DollarFormat(CurrentTotal)#<br />
	<table width="#TableSize#px">
	<tr>
	
	<!--- First day of Find It --->
	<cfset calendarStartDate = dateAdd('d',-7,OriginDate) />
	<cfset stCouldYou = session.searches[url.SearchID].CouldYou />
	<cfset viewDay = 0 />
	
	<cfloop from="1" to="2" index="MonthOption">
		<cfset calendarDate = MonthOption EQ 2 ? DateAdd('m',1,calendarStartDate) : calendarStartDate />
		<cfset firstOfTheMonth = createDate(year(calendarDate), month(calendarDate), 1)>
		<cfset dow = dayofWeek(firstOfTheMonth)>
		<cfset pad = dow - 1>
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
			<tr>
				<cfif pad GT 0>
				  <td class="calendarDay" colspan="#pad#">&nbsp;</td>
				</cfif>
				<cfset days = daysInMonth(calendarDate)>
				<cfset counter = pad + 1>
				<cfloop from="1" to="#days#" index="x">
					<cfset CurrentDate = CreateODBCDate(Year(calendarDate)&'-'&Month(calendarDate)&'-'&x) />
					<cfset Price = '' />
					<cfset tdbgcolor = '' />
					<cfif structKeyExists(stCouldYouResults.TOTALPRICE,CurrentDate)>
						<cfset Price = stCouldYouResults.TOTALPRICE[CurrentDate].NTOTALPRICE />
						<cfset tdbgcolor = ' bgcolor="#stCouldYouResults.TOTALPRICE[CurrentDate].SCOLOR#"' />
					</cfif>
					<td class="calendarDay"#tdbgcolor#>
				  	#x# 
						<cfif x EQ day(OriginDate) AND month(OriginDate) EQ month(calendarStartDate)>
							<br />#DollarFormat(CurrentTotal)#
						</cfif>
						<cfif structKeyExists(stCouldYouResults.TOTALPRICE,CurrentDate)>
							<br />
							<cfif isNumeric(Price)>
								#DollarFormat(Price)#
							<cfelse>
								#Price#
							</cfif>
						</cfif>
					</td>				   
					<cfset counter++>
					<cfif counter EQ 8>
						</tr>
						<cfif x LT days>
							<cfset counter = 1>
							<tr>
						</cfif>
					</cfif>
				</cfloop>
				<cfif counter NEQ 8>
					<cfset endPad = 8 - counter>
					<td class="calendarDay" colspan="#endPad#">&nbsp;</td>
				</cfif>
			</tr>
			</table>
		</td>
	</cfloop>
	</tr>
	</table>
</cfoutput>