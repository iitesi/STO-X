<cfcomponent output="false" accessors="true">

	<cfproperty name="UAPI">
	<cfproperty name="General">

<!---
init
--->
	<cffunction name="init" output="false">
		<cfargument name="UAPI">
		<cfargument name="General">

		<cfset setUAPI(arguments.UAPI)>
		<cfset setGeneral(arguments.General)>

		<cfreturn this>
	</cffunction>
	
<!---
openSession
--->
	<cffunction name="openSession" output="false">
		<cfargument name="Account" 	required="true">
		<cfargument name="SearchID"	required="true">

		<!--- Create the SOAP message to sign in. --->
		<cfsavecontent variable="local.message">
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

		<cfset local.sResponse 	= getUAPI().callUAPI('TerminalService', message, arguments.SearchID)>
		<cfset local.stResponse = getUAPI().formatUAPIRsp(sResponse)>
		<cfset local.hostToken  = stResponse[1].XMLText>

		<cfreturn hostToken />
	</cffunction>

<!---
closeSession
--->
	<cffunction name="closeSession" output="false">
		<cfargument name="Account" 	required="true">
		<cfargument name="hostToken"required="true">
		<cfargument name="searchID" required="true">

		<cfsavecontent variable="local.message">
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
		<cfset local.response 	= getUAPI().callUAPI('TerminalService', message, arguments.searchID)>

		<!--- Not error checking. --->
		<!---<cfset local.response 	= getUAPI().formatUAPIRsp(response)>
		<cfset local.successText  = response[1].XMLText>
		successText would equal 'Terminal End Session Successful'--->

	</cffunction>

<!---
terminalEntrySOAP
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
            <ter:TerminalCommand>#arguments.command#</ter:TerminalCommand>
            </ter:TerminalReq>
            </soapenv:Body>
            </soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>

		<cfreturn Message />
	</cffunction>

<!---
doTerminalEntry
--->
	<cffunction name="doTerminalEntry" output="false">
		<cfargument name="Account" 			required="true">
		<cfargument name="hostToken"		required="true">
		<cfargument name="terminalEntry"	required="true">
		<cfargument name="searchID" 		required="true">

		<cfset local.message	= terminalEntrySOAP(arguments.Account, arguments.hostToken, arguments.terminalEntry)>
		<cfset local.response 	= getUAPI().callUAPI('TerminalService', message, arguments.searchID)>
		<cfset local.response 	= getUAPI().formatUAPIRsp(response)>

		<cfreturn response>
	</cffunction>

<!---
doTerminalEntry
--->
	<cffunction name="blankResponse" output="false">

		<cfset local.Response = {}>
		<cfset Response.Error = false>
		<cfset Response.Message = []>

		<cfreturn Response>
	</cffunction>

<!---
displayPNR
--->
	<cffunction name="displayPNR" output="false">
		<cfargument name="Account" 	required="true">
		<cfargument name="hostToken"required="true">
		<cfargument name="pnr"		required="true">
		<cfargument name="searchID" required="true">

		<!--- Create a blank response structure. --->
		<cfset local.Response	= blankResponse()>

		<!--- Do the terminal entry.  Create SOAP header, call the UAPI and format the response. --->
		<cfset local.apiResponse	= doTerminalEntry(arguments.Account, arguments.hostToken, '*#arguments.pnr#', arguments.searchID)>

		<!--- Loop through the response and check for errors. --->
		<cfloop array="#apiResponse[1].XMLChildren#" index="local.void" item="local.stResponse">
			<cfif stResponse.XMLText CONTAINS 'INVLD'>
				<cfset Response.Error = true>
				<cfset arrayAppend(Response.Message, stResponse.XMLText)>
			</cfif>
			<!--- For debugging purposes. --->
			<!---<cfdump var="#stResponse.XMLText#">--->
		</cfloop>

		<cfreturn Response>
	</cffunction>

<!---
readPAR
--->
	<cffunction name="readPAR" output="false">
		<cfargument name="Account" 	required="true">
		<cfargument name="hostToken"required="true">
		<cfargument name="pcc"		required="true">
		<cfargument name="bar"		required="true">
		<cfargument name="par"		required="true">
		<cfargument name="searchID" required="true">

		<!--- Create a blank response structure. --->
		<cfset local.profileFound = true>

		<!--- Do the terminal entry.  Create SOAP header, call the UAPI and format the response. --->
		<cfset local.apiResponse	= doTerminalEntry(arguments.Account, arguments.hostToken, 'S*#arguments.pcc#/#arguments.bar#-#arguments.par#1', arguments.searchID)>

		<!--- Loop through the response and check for errors. --->
		<cfloop array="#apiResponse[1].XMLChildren#" index="local.void" item="local.stResponse">
			<cfif stResponse.XMLText CONTAINS 'SIMILAR TITLES LIST'
			OR stResponse.XMLText CONTAINS 'UNABLE TO LOCATE TITLE'>
				<cfset profileFound = false>
			</cfif>
		</cfloop>

		<cfreturn profileFound>
	</cffunction>

<!---
moveBARPAR
--->
	<cffunction name="moveBARPAR" output="false">
		<cfargument name="Account" 	required="true">
		<cfargument name="hostToken"required="true">
		<cfargument name="pcc"		required="true">
		<cfargument name="bar"		required="true">
		<cfargument name="par"		required="true">
		<cfargument name="searchID" required="true">

		<!--- Create a blank response structure. --->
		<cfset local.Response	= blankResponse()>

		<!--- Do the terminal entry.  Create SOAP header, call the UAPI and format the response. --->
		<cfset local.apiResponse	= doTerminalEntry(arguments.Account, arguments.hostToken, 'MVPT/#arguments.pcc#//#arguments.bar#-#arguments.par#', arguments.searchID)>

		<!--- Loop through the response and check for errors. --->
		<cfloop array="#apiResponse[1].XMLChildren#" index="local.void" item="local.stResponse">
			<cfif stResponse.XMLText CONTAINS 'SIMILAR TITLES LIST'
			OR stResponse.XMLText CONTAINS 'UNABLE TO LOCATE TITLE'>
				<cfset Response.Error = true>
			</cfif>
			<!--- For debugging purposes. --->
			<!---<cfdump var="#stResponse.XMLText#">--->
		</cfloop>

		<cfif Response.Error>
			<!--- Create a blank response structure. --->
			<cfset local.Response	= blankResponse()>

			<!--- Do the terminal entry.  Create SOAP header, call the UAPI and format the response. --->
			<cfset local.apiResponse	= doTerminalEntry(arguments.Account, arguments.hostToken, 'MVBT/#arguments.pcc#//#arguments.bar#', arguments.searchID)>

			<!--- Loop through the response and check for errors. --->
			<cfloop array="#apiResponse[1].XMLChildren#" index="local.void" item="local.stResponse">
				<cfif stResponse.XMLText CONTAINS 'SIMILAR TITLES LIST'
				OR stResponse.XMLText CONTAINS 'UNABLE TO LOCATE TITLE'>
					<cfset Response.Error = true>
					<cfset arrayAppend(Response.Message, stResponse.XMLText)>
				</cfif>
				<!--- For debugging purposes. --->
				<!---<cfdump var="#stResponse.XMLText#">--->
			</cfloop>
		</cfif>

		<cfreturn Response>
	</cffunction>

<!---
addReceivedBy
--->
	<cffunction name="addReceivedBy" output="false">
		<cfargument name="Account" 	required="true">
		<cfargument name="hostToken"required="true">
		<cfargument name="userID"	required="true">
		<cfargument name="searchID" required="true">

		<!--- Create a blank response structure. --->
		<cfset local.Response = blankResponse()>

		<!--- Get the user logged in. --->
		<cfset local.qUser = getGeneral().getUser(arguments.userID)>

		<!--- Do the terminal entry.  Create SOAP header, call the UAPI and format the response. --->
		<cfset local.apiResponse	= doTerminalEntry(arguments.Account, arguments.hostToken, 'R:#qUser.First_Name# #qUser.Last_Name# #qUser.Phone_Number#', arguments.searchID)>

		<!--- No error checking. Unknown possible errors. --->

		<cfreturn Response>
	</cffunction>

<!---
removeSecondName
--->
	<cffunction name="removeSecondName" output="false">
		<cfargument name="Account" 	required="true">
		<cfargument name="hostToken"required="true">
		<cfargument name="searchID" required="true">

		<!--- Create a blank response structure. --->
		<cfset local.Response = blankResponse()>

		<!--- Do the terminal entry.  Create SOAP header, call the UAPI and format the response. --->
		<cfset local.apiResponse	= doTerminalEntry(arguments.Account, arguments.hostToken, 'C:2N:', arguments.searchID)>

		<!--- No error checking. Only error would be if only the BAR moved over.  Response would be 'NO SUCH ITEM/NOT ENT/N:'. --->

		<cfreturn Response>
	</cffunction>

<!---
verifyStoredFare
--->
	<cffunction name="verifyStoredFare" output="false">
		<cfargument name="Account" 	required="true">
		<cfargument name="hostToken"required="true">
		<cfargument name="searchID" required="true">

		<!--- Create a blank response structure. --->
		<cfset local.Response = blankResponse()>

		<!--- Do the terminal entry.  Create SOAP header, call the UAPI and format the response. --->
		<cfset local.apiResponse	= doTerminalEntry(arguments.Account, arguments.hostToken, 'T:V', arguments.searchID)>

		<!--- Loop through the response and check for errors. --->
		<cfset Response.Error = true>
		<cfloop array="#apiResponse[1].XMLChildren#" index="local.void" item="local.stResponse">
			<cfif stResponse.XMLText CONTAINS 'FARE GUARANTEED AT TICKET ISSUANCE'>
				<cfset Response.Error = false>
			</cfif>
			<cfset arrayAppend(Response.Message, stResponse.XMLText)>
		</cfloop>

		<!--- Clear out the message if there is no error. --->
		<cfif NOT Response.Error>
			<cfset Response.Message = []>
		<!--- If error dump the messages.  I want to see it if it ever comes up. --->
		<cfelse>
			<cfdump var="#Response#" abort>
		</cfif>

		<cfreturn Response>
	</cffunction>

<!---
queueRecord
--->
	<cffunction name="queueRecord" output="false">
		<cfargument name="Account" 	required="true">
		<cfargument name="hostToken"required="true">
		<cfargument name="searchID" required="true">

		<!--- Create a blank response structure. --->
		<cfset local.Response = blankResponse()>

		<!--- Do the terminal entry.  Create SOAP header, call the UAPI and format the response. --->
		<cfset local.apiResponse	= doTerminalEntry(arguments.Account, arguments.hostToken, 'QEP/161C/90', arguments.searchID)>

		<!--- No error checking. Unknown possible errors. --->

		<cfreturn Response>
	</cffunction>

</cfcomponent>
