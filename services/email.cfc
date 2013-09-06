<cfcomponent>
	<cffunction name="email" output="false" hint="Send email">
		<cfargument name="SearchID">
		<cfargument name="nTripID">
		<cfargument name="Group">
		<cfargument name="Email_Name">
		<cfargument name="Email_Address">
		<cfargument name="To_Address">
		<cfargument name="CC_Address">
		<cfargument name="Email_Subject">
		<cfargument name="Email_Message">

		<cfset local.toAddress = arguments.To_Address>
		<cfset local.ccAddress = arguments.CC_Address>
		<cfif IsLocalHost(cgi.local_addr)>
			<cfset local.toAddress = "jpriest@shortstravel.com">
			<cfset local.ccAddress = "jpriest@shortstravel.com">
		</cfif>

		<cfmail
			from="#arguments.Email_Address#"
			to="#local.toAddress#"
			cc="#local.ccAddress#"
			subject="#arguments.Email_Subject#"
			type="HTML">
				<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
				<html>
				<head>
					<meta charset="utf-8" />
					<title>STO .:. The New Generation of Corporate Online Booking</title>
					<link rel="stylesheet" href="assets/css/reset.css" media="screen" />
					<link rel="stylesheet" href="assets/css/style.css" media="screen" />
				</head>
				<body>
					<cfif arguments.Group EQ ''>
						<cfset local.stTrip = session.searches[arguments.SearchID].stTrips[arguments.nTripID]>
					<cfelse>
						<cfset local.stTrip = session.searches[arguments.SearchID].stAvailTrips[arguments.Group][arguments.nTripID]>
					</cfif>
					<table width="700" align="center" style="padding:15px;">
					<cfif arguments.Email_Message NEQ ''>
						<tr>
							<td colspan="6">#arguments.Email_Message#</td>
						</tr>
						<tr>
							<td colspan="6">&nbsp;</td>
						</tr>
					</cfif>
					<tr>
						<td colspan="6"><h3>Itinerary</h3></td>
					</tr>
					<cfloop collection="#stTrip.Groups#" item="Group" >
						<cfset stGroup = stTrip.Groups[Group]>
						<tr>
							<td colspan="6">&nbsp;</td>
						</tr>
						<tr>
							<td colspan="6"><strong>#DateFormat(stGroup.DepartureTime, 'ddd, mmm d, yyyy')#</strong></td>
						</tr>
						<cfloop collection="#stGroup.Segments#" item="nSegment">
							<tr>
								<td>#stGroup.Segments[nSegment].Carrier##stGroup.Segments[nSegment].FlightNumber#</td>
								<td>#stGroup.Segments[nSegment].Origin#</td>
								<td>#stGroup.Segments[nSegment].Destination#</td>
								<td>#TimeFormat(stGroup.Segments[nSegment].DepartureTime, 'h:mmt')#</td>
								<td>#TimeFormat(stGroup.Segments[nSegment].ArrivalTime, 'h:mmt')#</td>
								<cfif arguments.Group EQ ''>
									<td>#stGroup.Segments[nSegment].Cabin#</td>
								</cfif>
							</tr>
						</cfloop>
					</cfloop>
					<tr>
						<td colspan="6"><br><br>
						Thanks,<br>
						Short's Travel Management</td>
					</tr>
					</table>
				</body>
				</html>
			</cfmail>
		<cfreturn />
	</cffunction>
</cfcomponent>