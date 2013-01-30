<cfcomponent output="false">
	
<!--- doHotelDetails --->
	<cffunction name="doHotelDetails" output="false" access="remote" returnformat="json" returntype="query">
		<cfargument name="nSearchID" />
		<cfargument name="nHotelCode" />
		<cfargument name="sHotelChain" />
		<cfargument name="sRatePlanType" />
		<cfargument name="sAPIAuth"		default="#application.sAPIAuth#">
		<cfargument name="stAccount" 	default="#application.stAccounts[session.Acct_ID]#">
		
		<cfset local.HotelDetails = HotelDetails(arguments.nHotelCode)>

		<cfif NOT HotelDetails.RecordCount>
			<cfset local.sMessage 	= prepareSoapHeader(arguments.stAccount, arguments.nSearchID, arguments.sHotelChain, arguments.nHotelCode, arguments.sRatePlanType)>
			<cfset local.sResponse 	= callAPI('HotelService', sMessage, arguments.sAPIAuth, arguments.nSearchID, arguments.nHotelCode)>
			<cfset local.stResponse = formatResponse(sResponse)>
			<cfset parseHotelDetails(stResponse, arguments.nHotelCode, arguments.nSearchID)>
			<cfset local.HotelDetails = HotelDetails(arguments.nHotelCode)>
		</cfif>

		<cfreturn HotelDetails />
	</cffunction>
		
<!--- prepareSoapHeader --->
	<cffunction name="prepareSoapHeader" returntype="string" output="false">
		<cfargument name="stAccount" />
		<cfargument name="nSearchID" />
		<cfargument name="sHotelChain" />
		<cfargument name="nHotelCode" />
		<cfargument name="sRatePlanType" />
		
		<cfset local.Search = session.searches[arguments.nSearchID] />

		<cfsavecontent variable="local.message">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<hot:HotelRulesReq TargetBranch="P7003155" xmlns:com="http://www.travelport.com/schema/common_v15_0" xmlns:hot="http://www.travelport.com/schema/hotel_v17_0">
						  <com:BillingPointOfSaleInfo OriginApplication="UAPI" />
						  <hot:HotelRulesLookup Base="" RatePlanType="#arguments.sRatePlanType#">
						  	<hot:HotelProperty HotelChain="#arguments.sHotelChain#" HotelCode="#arguments.nHotelCode#">
						    </hot:HotelProperty>
						    <hot:HotelStay>
									<hot:CheckinDate>#DateFormat(Search.dDepartDate,'yyyy-mm-dd')#</hot:CheckinDate>
									<hot:CheckoutDate>#DateFormat(Search.dArrivalDate,'yyyy-mm-dd')#</hot:CheckoutDate>
						    </hot:HotelStay>
						  </hot:HotelRulesLookup>
						</hot:HotelRulesReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn message />
	</cffunction>
	
<!--- callAPI --->
	<cffunction name="callAPI" returntype="string" output="true">
		<cfargument name="sService"	/>
		<cfargument name="sMessage"	/>
		<cfargument name="sAPIAuth"	/>
		<cfargument name="nSearchID" />
		<cfargument name="nHotelCode"	/>
		
		<cfset local.bSessionStorage = true /><!--- Testing setting (true - testing, false - live) --->

		<cfif NOT bSessionStorage OR NOT StructKeyExists(session.searches[nSearchID]['STHOTELS'][nHotelCode],'HotelDetails')>
			<cfhttp method="post" url="https://americas.copy-webservices.travelport.com/B2BGateway/connect/uAPI/#arguments.sService#">
				<cfhttpparam type="header" name="Authorization" value="Basic #arguments.sAPIAuth#" />
				<cfhttpparam type="header" name="Content-Type" value="text/xml;charset=UTF-8" />
				<cfhttpparam type="header" name="Accept" value="gzip,deflate" />
				<cfhttpparam type="header" name="Cache-Control" value="no-cache" />
				<cfhttpparam type="header" name="Pragma" value="no-cache" />
				<cfhttpparam type="header" name="SOAPAction" value="" />
				<cfhttpparam type="body" name="message" value="#Trim(arguments.sMessage)#" />
			</cfhttp>
			<cfset session.searches[nSearchID]['STHOTELS'][nHotelCode].HotelDetails = cfhttp.filecontent />
		<cfelse>
			<cfset cfhttp.filecontent = session.searches[nSearchID]['STHOTELS'][nHotelCode].HotelDetails />
		</cfif>
		
		<cfreturn cfhttp.filecontent />
	</cffunction>
	
<!--- formatResponse --->
	<cffunction name="formatResponse" returntype="array" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stResponse = XMLParse(arguments.stResponse)>
		
		<cfreturn stResponse.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren />
	</cffunction>
	
<!--- parseHotelDetails --->
	<cffunction name="parseHotelDetails" returntype="struct" output="false">
		<cfargument name="stResponse"	required="true">		
		<cfargument name="nHotelCode"	required="true">		
		<cfargument name="nSearchID"	required="true">			
		
		<cfset local.BadDescriptionList = 'Room rate,Promotional,Rate comment,rate description,min length stay,max length stay' />
		<cfset local.DescriptionStruct = {} />
		<cfdump var="#arguments.stResponse#">
		<cfloop array="#arguments.stResponse#" index="local.stHotelResults">			
			<cfloop array="#stHotelResults.XMLChildren#" index="local.sHotelDescription">
				<cfif sHotelDescription.XMLName EQ 'hotel:RoomRateDescription'>
					<cfif NOT listFindNoCase(BadDescriptionList,trim(sHotelDescription.XMLAttributes.Name))>
						<cfset local.Descriptions = [] />
						<cfloop from="1" to="#arrayLen(sHotelDescription.XMLChildren)#" index="local.OneDescription">
							<cfset arrayAppend(Descriptions,trim(sHotelDescription.XMLChildren[OneDescription].XMLText)) />
						</cfloop>
						<cfset local.DescriptionStruct[trim(sHotelDescription.XMLAttributes.Name)] = arrayToList(Descriptions,'|') />
					</cfif>
				</cfif>
			</cfloop>

			<cfif stHotelResults.XMLName EQ 'hotel:HotelRuleItem'>
				<cfif NOT listFindNoCase(BadDescriptionList,trim(stHotelResults.XMLAttributes.Name))>
					<cfset local.Descriptions = [] />
					<cfloop from="1" to="#arrayLen(stHotelResults.XMLChildren)#" index="local.OneDescription">
						<cfset arrayAppend(Descriptions,trim(stHotelResults.XMLChildren[OneDescription].XMLText)) />
					</cfloop>
					<cfset local.DescriptionStruct[trim(stHotelResults.XMLAttributes.Name)] = arrayToList(Descriptions,'|') />
				</cfif>
			</cfif>
		</cfloop>

		<cfoutput>
			<cfset local.CheckIn = '' />
			<cfset local.CheckOut = '' />
			<cfset local.Commission = '' />
			<cfloop list="#structKeyList(DescriptionStruct)#" index="local.i">
				<cfset local.DeleteKey = false />
				<cfset local.NoSpaceName = replace(i,' ','','all') />
				<cfif uCase(NoSpaceName) EQ 'CHECKIN'>
					<cfset local.CheckIn = MilitaryToStandardTime(DescriptionStruct[i]) />
					<cfset structDelete(DescriptionStruct,i) /><!--- These fields are stored in individual columns. Don't need to store them twice --->
				</cfif>
				<cfif uCase(NoSpaceName) EQ 'CHECKOUT'>
					<cfset local.CheckOut = MilitaryToStandardTime(DescriptionStruct[i]) />
					<cfset structDelete(DescriptionStruct,i) />
				</cfif>
				<cfif uCase(NoSpaceName) EQ 'COMMISSION'>
					<cfset local.Commission = replace(replace(replace(uCase(DescriptionStruct[i]),'COMMISSION',''),'AMT',''),'-','') />
					<cfset structDelete(DescriptionStruct,i) />
				</cfif>
				<cfif uCase(replace(NoSpaceName,' ','','all')) EQ 'CHECKINCHECKOUT'>
					<cfset structDelete(DescriptionStruct,i) />
				</cfif>
			</cfloop>
		</cfoutput>

		<cfset local.DetailsArray = [] />
		<cfloop list="#structKeyList(DescriptionStruct)#" index="local.i">
			<cfset arrayAppend(DetailsArray,i&' - '&DescriptionStruct[i]) />
		</cfloop>

		<cfquery datasource="book">
		UPDATE lu_hotels
		SET CheckIn = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CheckIn#" />,
		CheckOut = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CheckOut#" />,
		Commission = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Commission#" />,
		Details = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arrayToList(DetailsArray,'<br>')#" />,
		details_DateTime = getDate()
		WHERE Property_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nHotelCode#" />
		</cfquery>

		<cfreturn />
	</cffunction>	
	
<!--- HotelDetails --->
	<cffunction name="HotelDetails" output="true">
		<cfargument name="PropertyID" />
		<cfargument name="Type" default="Details" />
		
		<cfset local.HotelDetails = '' />

		<cfquery name="local.HotelDetails" datasource="book">
		SELECT replace(CAST(Details AS VARCHAR(5000)),'|',' ') AS Details, CheckIn, CheckOut
		FROM lu_hotels
		WHERE Property_ID = <cfqueryparam value="#arguments.PropertyID#" cfsqltype="cf_sql_integer">
		AND #arguments.Type#_DateTime > #CreateODBCDateTime(DateAdd('m', -1, Now()))#
		</cfquery>

		<cfreturn HotelDetails />
	</cffunction>
	
<!--- MilitaryToStandardTime --->
	<cffunction name="MilitaryToStandardTime" output="true">
		<cfargument name="Time" />
		
		<cfset local.StandardTime = '' />
		<cfset local.MilitaryTime = Time />

		<cfif Len(Trim(local.MilitaryTime))>
			<cfif local.MilitaryTime LT 1200>
				<cfset local.StandardTime = MilitaryTime&'AM' />
			<cfelse>
				<cfset local.StandardTime = MilitaryTime GT 1200 ? (MilitaryTime - 1200) : '1200' />
				<cfset local.StandardTime&='PM' />
			</cfif>			
		</cfif>

		<cfreturn StandardTime />
	</cffunction>

</cfcomponent>