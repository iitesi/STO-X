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
		<cfargument name="SearchID">
		
		<cfset local.bSessionStorage = true><!--- Testing setting (1 - testing, 0 - live) --->
		<cfset local.scfhttp = 'rockstar'&RandRange(1, 1000000)>
		<cfset local.dStart = getTickCount()>

		<cfif NOT bSessionStorage
		OR (bSessionStorage
			AND (NOT StructKeyExists(session, 'aMessages')
				OR NOT ArrayFind(session.aMessages,arguments.sMessage)
				OR NOT ArrayFind(session.aMessages[arguments.sMessage], 'sFileContent')))>
			<cfhttp method="post" url="https://americas.copy-webservices.travelport.com/B2BGateway/connect/UAPI/#arguments.sService#" result="local.#scfhttp#">
				<cfhttpparam type="header" name="Authorization" value="Basic #ToBase64('Universal API/UAPI6148916507-02cbc4d4:Qq7?b6*X5B')#" />
				<cfhttpparam type="header" name="Content-Type" value="text/xml;charset=UTF-8" />
				<cfhttpparam type="header" name="Accept" value="gzip,deflate" />
				<cfhttpparam type="header" name="Cache-Control" value="no-cache" />
				<cfhttpparam type="header" name="Pragma" value="no-cache" />
				<cfhttpparam type="header" name="SOAPAction" value="" />
				<cfhttpparam type="body" name="message" value="#Trim(arguments.sMessage)#" />
			</cfhttp>
			<!--- Place this in the session scope for debugging purposes --->
			<!--- <cfif bSessionStorage> --->
				<!--- <cfset session.aMessages[arguments.sMessage].sFileContent = local[scfhttp].filecontent> --->
			<!--- </cfif> --->
		<cfelse>
			<cfset local[scfhttp].filecontent = session.aMessages[arguments.sMessage].sFileContent>
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

<!---
openSessionSOAP
--->
	<cffunction name="openSessionSOAP" output="false">
		<cfargument name="Account" 	required="true">

		<cfsavecontent variable="local.Message">
			<cfoutput>
                <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
                    <soapenv:Header/>
                    <soapenv:Body>
                        <ns3:CreateTerminalSessionReq Host="1V" TargetBranch="#arguments.Account.sBranch#" xmlns:ns2="http://www.travelport.com/schema/common_v12_0" xmlns:ns3="http://www.travelport.com/schema/terminal_v8_0">
                            <ns2:BillingPointOfSaleInfo OriginApplication="uAPI-3.0"/>
                        </ns3:CreateTerminalSessionReq>
                    </soapenv:Body>
                </soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>

		<cfreturn Message />
	</cffunction>

<!---
closeSessionSOAP
--->
	<cffunction name="closeSessionSOAP" output="false">
		<cfargument name="Account" 	required="true">
		<cfargument name="hostToken"required="true">

		<cfsavecontent variable="local.Message">
			<cfoutput>
                <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
                    <soapenv:Header/>
	                <soapenv:Body>
		                <ter:EndTerminalSessionReq TargetBranch="#arguments.Account.sBranch#" xmlns:ter="http://www.travelport.com/schema/terminal_v8_0" xmlns:com="http://www.travelport.com/schema/common_v12_0">
		                    <com:BillingPointOfSaleInfo OriginApplication="uAPI-3.0"/>
		                    <com:HostToken Host="1V">#arguments.hostToken#</com:HostToken>
		                </ter:EndTerminalSessionReq>
		            </soapenv:Body>
	            </soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>

		<cfreturn Message />
	</cffunction>

<!---
openUAPISession
--->
	<cffunction name="terminalEntrySOAP" output="false">
		<cfargument name="Account"  required="true">
		<cfargument name="hostToken"required="true">
		<cfargument name="command"required="true">

		<cfsavecontent variable="local.Message">
			<cfoutput>
                <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
                    <soapenv:Header/>
                    <soapenv:Body>
                        <ter:TerminalReq TargetBranch="#arguments.Account.sBranch#" xmlns:ter="http://www.travelport.com/schema/terminal_v8_0" xmlns:com="http://www.travelport.com/schema/common_v12_0">
							<com:BillingPointOfSaleInfo OriginApplication="uAPI-3.0"/>
							<com:HostToken Host="1V">#arguments.hostToken#</com:HostToken>
							<!---<ter:TerminalCommand>SEM/1M98/AG</ter:TerminalCommand>--->
							<ter:TerminalCommand>#arguments.command#</ter:TerminalCommand>
							<!---<ter:TerminalCommand>MVPT/149I//SHORTS-LAMONT KRISTIANNE44</ter:TerminalCommand>
							<ter:TerminalCommand>R:STO<ter:TerminalCommand>
							<ter:TerminalCommand>ER<ter:TerminalCommand>
							<ter:TerminalCommand>ER<ter:TerminalCommand>--->
                        </ter:TerminalReq>
                    </soapenv:Body>
                </soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>

		<cfreturn Message />
	</cffunction>

</cfcomponent>
