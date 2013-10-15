<cfparam name="variables.minheight" default="250"/>
<cfset ribbonClass = "">
<cfset carrierList = "">
<cfset thisSelectedLeg = "">

<style>
@media print {
	.page-break	{ display: block; page-break-before: always; }
}

.badge {font-family: Arial, Verdana, san-serif;}

.smalltext {
	font-size: smaller;
	font-family: Verdana, san-serif;
}

.flighttext {
	font-size: .9em;
	font-family: Arial, Verdana, san-serif;
}

#printschedule {
	border-bottom: 1px solid #ccc;
}

.topborder td {
	border-top: 1px solid #e3e3e3;
}

.topborder:first-child td {
    border-top: none;
}

.back {background-color: #F4F4F4;}

</style>




<cfsavecontent variable="sBadge" trim="#true#">
	<cfoutput>
		<div class="badge">
			<table width="600" border="0" id="printschedule" <cfif #nCount# MOD 2>class="back"</cfif>>
			<tr>
				<td align="center" width="125">
					<img class="carrierimg" src="assets/img/airlines/#(ArrayLen(stTrip.Carriers) EQ 1 ? stTrip.Carriers[1] : 'Mult')#.png">
					<br><strong>#(ArrayLen(stTrip.Carriers) EQ 1 ? '<br />'&application.stAirVendors[stTrip.Carriers[1]].Name : '<br />Multiple Carriers')#</strong>
				</td>
				<td>
					<table width="350" cellpadding="0" cellspacing="0" border="0">
						<cfloop collection="#stTrip.Groups#" item="Group">
							<cfset stGroup = stTrip.Groups[Group]>
							<tr class="topborder">
								<td width="100">&nbsp;</td>
								<td width="100"><strong>#stGroup.Origin#</strong></td>
								<td width="100">&nbsp;</td>
								<td width="100"><strong>#stGroup.Destination#</strong></td>
							</tr>
							<tr>
								<td class="flighttext"><strong>#DateFormat(stGroup.DepartureTime, 'ddd')#</strong></td>
								<td class="flighttext">#TimeFormat(stGroup.DepartureTime, 'h:mmt')#</td>
								<td class="flighttext">	-	</td>
								<td class="flighttext">#TimeFormat(stGroup.ArrivalTime, 'h:mmt')#</td>
							</tr>
							<cfset nCnt = 0>
							<cfset segmentCount = arrayLen(structKeyArray(stGroup.Segments))>
							<cfloop collection="#stGroup.Segments#" item="nSegment" >
								<cfset nCnt++>
								<cfset stSegment = stGroup.Segments[nSegment]>
								<cfif NOT listFind(carrierList, stSegment.Carrier)>
									<cfset carrierList = ListAppend(carrierList, stSegment.Carrier)>
								</cfif>
								<tr>
									<td valign="top"class="flighttext">#stSegment.Carrier##stSegment.FlightNumber#</td>
									<td valign="top"class="flighttext">#(bDisplayFare ? stSegment.Cabin : '')#</td>
									<td valign="top"class="flighttext" nowrap>#(nCnt EQ 1 AND segmentCount NEQ 1 ? 'to <span>#stSegment.Destination#</span>' : '')#</td>
									<td valign="top"class="flighttext">
										<cfif nCnt EQ 1>
											#stGroup.TravelTime#
											<cfset nFirstSeg = nSegment>
										</cfif>
									</td>
								</tr>
							</cfloop>
						</cfloop>
					</table>
				</td>
				<td align="center" width="125">
						<strong>$#NumberFormat(stTrip.Total)#</strong><br>
						<span class="smalltext">
						#(stTrip.Class EQ 'Y' ? 'ECONOMY' : (stTrip.Class EQ 'C' ? 'BUSINESS' : 'FIRST'))#<br>
						#(stTrip.Ref EQ 0 ? 'NO REFUNDS' : 'REFUNDABLE')#<br>
						#(stTrip.Policy ? '' : '<span rel="tooltip" class="popuplink" title="#Replace(ArrayToList(stTrip.aPolicies), ",", ", ")#">OUT OF POLICY</span>')#<br>
						<cfif bDisplayFare AND stTrip.PrivateFare AND stTrip.preferred EQ 1>
							PREFERRED / CONTRACTED<br>
						<cfelseif stTrip.preferred EQ 1>
							PREFERRED<br>
						<cfelseif bDisplayFare AND stTrip.PrivateFare>
							CONTRACTED<br>
						</cfif>
						</span>
				</td>
			</tr>
			</table>
		</div>
	</cfoutput>
</cfsavecontent>

<!--- display badge --->
<cfoutput>
	<div>
		#sBadge#
		<cfif nCount MOD 5 EQ 0>
			<div class="page-break"></div>
		</cfif>
	</div>
</cfoutput>