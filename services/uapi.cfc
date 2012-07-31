<cfcomponent>

<!--- call to uapi --->
	<cffunction name="call" returntype="string" output="true">
		<cfargument name="service" 	required="true" 	type="string"	default="AirService">
		<cfargument name="message" 	required="true" 	type="string">
		<cfargument name="auth" 	required="false" 	type="string" 	default="#application.auth#">
		
		<cfhttp method="post" url="https://americas.copy-webservices.travelport.com/B2BGateway/connect/uAPI/#arguments.service#">
			<cfhttpparam type="header" name="Authorization" value="Basic #arguments.auth#" />
			<cfhttpparam type="header" name="Content-Type" value="text/xml;charset=UTF-8" />
			<cfhttpparam type="header" name="Accept" value="gzip,deflate" />
			<cfhttpparam type="header" name="Cache-Control" value="no-cache" />
			<cfhttpparam type="header" name="Pragma" value="no-cache" />
			<cfhttpparam type="header" name="SOAPAction" value="" />
			<cfhttpparam type="header" name="Content-Length" value="#Len(Trim(arguments.message))#" />
			<cfhttpparam type="body" name="message" value="#Trim(arguments.message)#" />
		</cfhttp>
		
		<cfreturn cfhttp.filecontent />
	</cffunction>
	
</cfcomponent>
