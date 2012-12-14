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
			<cfset local.stHotels 	= parseHotelDetails(stResponse, arguments.nHotelCode, arguments.nSearchID)>
			<cfdump var="#stResponse#" abort>
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
		
		<cfquery name="local.getSearch" datasource="book">
		SELECT Depart_DateTime, Arrival_City, Arrival_DateTime
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>

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
									<hot:CheckinDate>#DateFormat(getSearch.Depart_DateTime,'yyyy-mm-dd')#</hot:CheckinDate>
									<hot:CheckoutDate>#DateFormat(getSearch.Arrival_DateTime,'yyyy-mm-dd')#</hot:CheckoutDate>
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
		
		<cfoutput>
			<cfloop array="#arguments.stResponse#" index="local.stHotelResults">			
				<cfloop array="#stHotelResults.XMLChildren#" index="local.sHotelDescription">
					<cfif sHotelDescription.XMLName EQ 'hotel:RoomRateDescription'>						
						#sHotelDescription.XMLAttributes.Name# - 
						<cfloop from="1" to="#arrayLen(sHotelDescription.XMLChildren)#" index="local.OneDescription">
							#sHotelDescription.XMLChildren[OneDescription].XMLText#	<cfif OneDescription NEQ arrayLen(sHotelDescription.XMLChildren)>	 |	</cfif>
						</cfloop><br>		
					</cfif>
				</cfloop>

				<cfif stHotelResults.XMLName EQ 'hotel:HotelRuleItem'>
					#stHotelResults.XMLAttributes.Name# - 
					<cfloop from="1" to="#arrayLen(stHotelResults.XMLChildren)#" index="local.OneDescription">
						#stHotelResults.XMLChildren[OneDescription].XMLText#	<cfif OneDescription NEQ arrayLen(stHotelResults.XMLChildren)>	 |	</cfif>
					</cfloop><br>	
				</cfif>

			</cfloop>
		
		</cfoutput>
		<cfdump var="#arguments.stResponse#" abort>
		<!--- Update the struct so we know we've received rates and we don't pull them again later --->
		<cfset stHotels[nHotelCode]['RoomsReturned'] = true />

		<cfreturn stHotels />
	</cffunction>	
	
<!--- HotelDetails --->
	<cffunction name="HotelDetails" output="true">
		<cfargument name="PropertyID" />
		<cfargument name="Type" default="Details" />

		
		<cfset local.HotelDetails = '' />

		<cfquery name="HotelDetails" datasource="book">
		SELECT ServiceDetail,FacilityDetail,RoomDetail,RecreationDetail,CheckIn,CheckOut
		FROM lu_hotels
		WHERE Property_ID = <cfqueryparam value="#arguments.PropertyID#" cfsqltype="cf_sql_integer">
		AND #arguments.Type#_DateTime > #CreateODBCDateTime(DateAdd('m', -1, Now()))#
		</cfquery>

		<cfreturn HotelDetails />
	</cffunction>

</cfcomponent>