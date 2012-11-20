<cfcomponent>

<!---
email
--->
	<cffunction name="email" output="false">
		<cfargument name="nSearchID">
		<cfargument name="nTripID">
		<cfargument name="Email_Name">
		<cfargument name="Email_Address">
		<cfargument name="To_Address">
		<cfargument name="CC_Address">
		<cfargument name="Email_Subject">
		<cfargument name="Email_Message">

		<cfmail
			from="#arguments.Email_Address#"
			to="#arguments.To_Address#"
			cc="#arguments.CC_Address#"
			subject="#arguments.Email_Subject#"
			type="HTML">
			
				<!DOCTYPE html>
				<html lang="en">
				<head>
					<meta charset="utf-8" />
					<title>STO .:. The New Generation of Corporate Online Booking</title>
					<link rel="stylesheet" href="assets/css/reset.css" media="screen" />
					<link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Capriola|Karla|Chivo" type="text/css">
					<link rel="stylesheet" href="assets/css/style.css" media="screen" />
				</head>
				<body>
				<p>
						<cfset variables.bLinks = 1>
				</p>
			</body>
			</html>
		</cfmail>
		<cfabort>
		<cfreturn />
	</cffunction>
	
</cfcomponent>