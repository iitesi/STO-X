<cfcomponent output="false">
	
<!---
init
--->
	<cffunction name="init" output="false">
		<cfreturn this>
	</cffunction>
	
<!---
callUAPI
--->
	<cffunction name="callUAPI" output="false">
		<cfargument name="sService">
		<cfargument name="sMessage">
		<cfargument name="nSearchID">
		
		<cfset local.bSessionStorage = 1><!--- Testing setting (1 - testing, 0 - live) --->
		<cfset local.scfhttp = 'rockstar'&RandRange(1, 1000000)>
		<cfset local.dStart = getTickCount()>
		<cfif NOT bSessionStorage
		OR (bSessionStorage
			AND (NOT StructKeyExists(application, arguments.sMessage)
				OR NOT StructKeyExists(application[arguments.sMessage], 'sFileContent')))>
			<cfhttp method="post" url="https://americas.copy-webservices.travelport.com/B2BGateway/connect/uAPI/#arguments.sService#" result="local.#scfhttp#">
				<cfhttpparam type="header" name="Authorization" value="Basic #ToBase64('Universal API/uAPI6148916507-02cbc4d4:Qq7?b6*X5B')#" />
				<cfhttpparam type="header" name="Content-Type" value="text/xml;charset=UTF-8" />
				<cfhttpparam type="header" name="Accept" value="gzip,deflate" />
				<cfhttpparam type="header" name="Cache-Control" value="no-cache" />
				<cfhttpparam type="header" name="Pragma" value="no-cache" />
				<cfhttpparam type="header" name="SOAPAction" value="" />
				<cfhttpparam type="body" name="message" value="#Trim(arguments.sMessage)#" />
			</cfhttp>
			<!--- Place this in the session scope for debugging purposes --->
			<cfif bSessionStorage>
				<cfset application[arguments.sMessage].sFileContent = local[scfhttp].filecontent>
			</cfif>
		<cfelse>
			<cfset local[scfhttp].filecontent = application[arguments.sMessage].sFileContent>
		</cfif>
		<cfset local.nTotal = getTickCount() - dStart>
		<cfset ArrayAppend(session.aMessages, {Message: arguments.sMessage, Response: local[scfhttp].filecontent, _nMS : nTotal, _dTimestamp : Now()})>
			
		<cfreturn local[scfhttp].filecontent />
	</cffunction>

<!---
formatUAPIRsp
--->
	<cffunction name="formatUAPIRsp" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stResponse = XMLParse(arguments.stResponse)>
		
		<cfreturn stResponse.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren />
	</cffunction>

<!---
hashNumeric
--->
	<cffunction name="hashNumeric" output="false">
		<cfargument name="sStringToHash"	required="true">
		
		<cfreturn createObject("java", "java.lang.String").init(arguments.sStringToHash).hashCode() />
	</cffunction>

</cfcomponent>
