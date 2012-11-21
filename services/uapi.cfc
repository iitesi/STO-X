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
		
		<cfset local.bSessionStorage = 0><!--- Testing setting (1 - testing, 0 - live) --->
		
		<cfif NOT bSessionStorage
		OR (bSessionStorage
			AND (NOT StructKeyExists(session.searches[nSearchID], arguments.sMessage)
				OR NOT StructKeyExists(session.searches[nSearchID][arguments.sMessage], 'sFileContent')))>
			<cfhttp method="post" url="https://americas.copy-webservices.travelport.com/B2BGateway/connect/uAPI/#arguments.sService#">
				<cfhttpparam type="header" name="Authorization" value="Basic #ToBase64('Universal API/uAPI6148916507-02cbc4d4:Qq7?b6*X5B')#" />
				<cfhttpparam type="header" name="Content-Type" value="text/xml;charset=UTF-8" />
				<cfhttpparam type="header" name="Accept" value="gzip,deflate" />
				<cfhttpparam type="header" name="Cache-Control" value="no-cache" />
				<cfhttpparam type="header" name="Pragma" value="no-cache" />
				<cfhttpparam type="header" name="SOAPAction" value="" />
				<cfhttpparam type="body" name="message" value="#Trim(arguments.sMessage)#" />
			</cfhttp>
			<cfif bSessionStorage>
				<cfset session.searches[arguments.nSearchID][arguments.sMessage].sFileContent = cfhttp.filecontent>
			</cfif>
		<cfelse>
			<cfset cfhttp.filecontent = session.searches[arguments.nSearchID][arguments.sMessage].sFileContent>
		</cfif>
		
		<cfreturn cfhttp.filecontent />
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
sortStructure
--->
	<cffunction name="sortStructure" returntype="array" output="false">
		<cfargument name="stStructure" 	required="true">
		<cfargument name="sField" 	required="true">
				
		<cfreturn StructSort(arguments.stStructure, 'numeric', 'asc', arguments.sField )/>
	</cffunction>

</cfcomponent>
