<!--- prevent layout cascade --->
<cfset request.layout = false>

<!DOCTYPE html>
	<head>
		<meta charset="utf-8">
		<title>
			<cfif structKeyExists(rc, "filter") AND len(rc.filter.getTitle())>
				<cfoutput>#rc.filter.getTitle()#</cfoutput>
			<cfelse>
				STO .:. The New Generation of Corporate Online Booking
			</cfif>
	</title>
	</head>
	<body>
		<cfoutput>#body#</cfoutput>
	</body>
</html>
