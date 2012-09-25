<cfcomponent>
	
<!--- doHotelSearch --->
	<cffunction name="doHotelSearch" output="false">
		<cfargument name="nSearchID">
		<cfargument name="stAccount" 	default="#application.stAccounts[session.Acct_ID]#">
		<cfargument name="stPolicy" 	default="#application.stPolicies[session.searches[url.Search_ID].Policy_ID]#">
		<cfargument name="sAPIAuth" 	default="#application.sAPIAuth#">
		
		<cfset local.sMessage		= 	prepareSoapHeader(arguments.stAccount, arguments.stPolicy, arguments.nSearchID) />
		<cfset local.sResponse 	= 	callAPI('HotelService', sMessage, arguments.sAPIAuth, arguments.nSearchID) />
		<cfset local.aResponse 	= 	formatResponse(sResponse) />
		<cfset local.stHotels 	= 	parseHotels(aResponse) />
		<cfset local.stChains 	= 	getChains(stHotels)>

		<!--- Store the hotel properties into the session --->
		<cfset session.searches[nSearchID].stHotelProperties 	= stHotels />
   	<cfset session.searches[nSearchID].stHotelChains			= stChains />

   	<cfset session.searches[nSearchID].stSortHotels = StructKeyArray(session.searches[nSearchID].stHotelProperties) />

   	<cfset local.threadnamelist = '' />
   	<cfset local.count = 0 />
		<cfloop array="#session.searches[arguments.nSearchID].stSortHotels#" index="local.sHotel">
			<cfif count LT 4><!--- Stop the rates after 4. We'll get the rest of the rates later --->
				<!--- <cfthread action="run" name="#sHotel#"> --->
					<cfinvoke component="hotelprice" method="doHotelPrice" nSearchID="#arguments.nSearchID#" nHotelCode="#sHotel#" sHotelChain="#session.searches[arguments.nSearchID].stHotelProperties[sHotel].HotelChain#" returnvariable="HotelPrices" />
				<!--- </cfthread> --->
				<cfset threadnamelist = listAppend(threadnamelist,sHotel) />
				<cfset count++ />
			</cfif>
		</cfloop>
		<!--- <cfthread action="join" name="#threadnamelist#"> --->

		<cfreturn >
	</cffunction>
	
<!--- parseHotels --->
	<cffunction name="parseHotels" output="false">
		<cfargument name="stResponse">
		<cfargument name="stAccount" 	default="#application.stAccounts[session.Acct_ID]#">
		<cfargument name="stPolicy" 	default="#application.stPolicies[session.searches[url.Search_ID].Policy_ID]#">
		<cfargument name="sAPIAuth" 	default="#application.sAPIAuth#">
		
		<cfset local.stHotels = {} />
		<cfset local.sIndex = '' />

		<cfloop array="#arguments.stResponse#" index="local.sHotelResultList">

			<cfif sHotelResultList.XMLName EQ 'hotel:HotelSearchResult'>

				<cfset NegotiatedRateCode = '' />
				<!--- The NegotiatedRateCode is not stored in an appropriately named field, so this must be done in its own loop to accurately pull out the code  --->
				<cfloop array="#sHotelResultList.XMLChildren#" index="local.sHotelProperty">
					<cfif sHotelProperty.XMLName CONTAINS 'CorporateDiscountID' AND StructKeyExists(sHotelProperty.xmlAttributes,'NegotiatedRateCode') EQ true>
						<cfset NegotiatedRateCode = sHotelProperty.xmlText />
					</cfif>
				</cfloop>

				<!--- Loop through each properties main attributes --->
				<cfloop array="#sHotelResultList.XMLChildren#" index="local.sHotelProperty">
					
					<cfif structKeyExists(sHotelProperty,'XMLAttributes') AND structKeyExists(sHotelProperty.XMLAttributes,'HotelCode')>
						<!--- Set this as a variable because we'll need it later --->
						<cfset nHotelCode = sHotelProperty.XMLAttributes.HotelCode />
						<cfset nHotelChain = sHotelProperty.XMLAttributes.HotelChain />

						<!--- get the Hotel Property Address which is in a separate node --->
						<cfloop array="#sHotelProperty.XMLChildren#" index="local.sHotelAddress">
							<cfif sHotelAddress.XMLName EQ 'hotel:PropertyAddress'>
								<cfset HotelAddress = sHotelAddress.XMLChildren.1.XMLText />
							</cfif>
						</cfloop>

						<cfset FeaturedProperty = structKeyExists(sHotelProperty.XMLAttributes,'FeaturedProperty') ? sHotelProperty.XMLAttributes.FeaturedProperty : false />
						<cfset stHotels[nHotelCode] = {
							FeaturedProperty : FeaturedProperty,
							HotelChain : nHotelChain,
							HotelLocation : sHotelProperty.XMLAttributes.HotelLocation,
							HotelAddress : HotelAddress,
							Name : sHotelProperty.XMLAttributes.Name,
							NegotiatedRateCode : NegotiatedRateCode,
							RoomsReturned : false
						} />

					</cfif>

				</cfloop>

			</cfif>
		</cfloop>

		<cfreturn stHotels />
	</cffunction>

<!--- prepareSoapHeader --->
	<cffunction name="prepareSoapHeader" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="stPolicy" 	required="true">
		<cfargument name="nSearchID" 	required="true">
		
		<cfquery name="local.getsearch" datasource="book">
		SELECT Depart_DateTime, Arrival_City, Arrival_DateTime
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		
		<cfsavecontent variable="local.message">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<hot:HotelSearchAvailabilityReq TargetBranch="P7003155" xmlns:com="http://www.travelport.com/schema/common_v15_0" xmlns:hot="http://www.travelport.com/schema/hotel_v17_0">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI"/>
							<hot:HotelLocation Location="#getsearch.Arrival_City#" LocationType="Airport">
							</hot:HotelLocation>
							<hot:HotelSearchModifiers NumberOfAdults="1" NumberOfRooms="1">
								#getRateCodes()#
								<!---<PermittedChains>
									<HotelChain Code="ES"/>
									<HotelChain Code="EM"/>
									<HotelChain Code="HY"/>
								</PermittedChains>
								<Distance Value="10" Direction="" xmlns="http://www.travelport.com/schema/common_v16_0"/>
								<RateCategory>All</RateCategory>--->
							</hot:HotelSearchModifiers>
							<hot:HotelStay>
								<hot:CheckinDate>#DateFormat(getSearch.Depart_DateTime,'yyyy-mm-dd')#</hot:CheckinDate>
								<hot:CheckoutDate>#DateFormat(getSearch.Arrival_DateTime,'yyyy-mm-dd')#</hot:CheckoutDate>
							</hot:HotelStay>
							<com:PointOfSale ProviderCode="1V" PseudoCityCode="1M98" xmlns:com="http://www.travelport.com/schema/common_v15_0" />
						</hot:HotelSearchAvailabilityReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn message/>
	</cffunction>
	
<!--- callAPI --->
	<cffunction name="callAPI" output="false">
		<cfargument name="sService">
		<cfargument name="sMessage">
		<cfargument name="sAPIAuth">
		<cfargument name="nSearchID">
		
		<cfset local.bSessionStorage = 1><!--- Testing setting (1 - testing, 0 - live) --->
			
		<cfif NOT bSessionStorage OR NOT StructKeyExists(session.searches[nSearchID], 'sFileContent')>
			<cfhttp method="post" url="https://americas.copy-webservices.travelport.com/B2BGateway/connect/uAPI/#arguments.sService#">
				<cfhttpparam type="header" name="Authorization" value="Basic #arguments.sAPIAuth#" />
				<cfhttpparam type="header" name="Content-Type" value="text/xml;charset=UTF-8" />
				<cfhttpparam type="header" name="Accept" value="gzip,deflate" />
				<cfhttpparam type="header" name="Cache-Control" value="no-cache" />
				<cfhttpparam type="header" name="Pragma" value="no-cache" />
				<cfhttpparam type="header" name="SOAPAction" value="" />
				<cfhttpparam type="body" name="message" value="#Trim(arguments.sMessage)#" />
			</cfhttp>
			<cfif bSessionStorage>
				<cfset session.searches[nSearchID].sFileContent = cfhttp.filecontent />
			</cfif>
		<cfelse>
			<cfset cfhttp.filecontent = session.searches[nSearchID].sFileContent />
		</cfif>
		
		<cfreturn cfhttp.filecontent />
	</cffunction>
	
<!--- formatResponse --->
	<!--- Both fare and schedule search --->
	<cffunction name="formatResponse" output="false">
		<cfargument name="stResponse">
		
		<cfset local.stResponse = XMLParse(arguments.stResponse)>
		
		<cfreturn stResponse.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren />
	</cffunction>
	
<!--- getChains --->
	<cffunction name="getChains" output="false">
		<cfargument name="stHotels">

		<cfset local.stChains = [] />
		<cfloop collection="#arguments.stHotels#" item="local.PropertyID">
			<cfif NOT ArrayFind(stChains, arguments.stHotels[PropertyID].HotelChain)>
				<cfset ArrayAppend(stChains, arguments.stHotels[PropertyID].HotelChain)>
			</cfif>
		</cfloop>

		<cfreturn stChains/>
	</cffunction>
	
<!--- getRateCodes --->
	<cffunction name="getRateCodes" returntype="string" output="false" access="private">
		<cfargument name="HotelRateCodes" default="#application.stAccounts[session.Acct_ID].Hotel_RateCodes#">
		
		<cfset local.sHotelRateCodes = arguments.HotelRateCodes />
		<cfset sHotelRateCodes&= Len(Trim(sHotelRateCodes)) ? '|' : '' />
		<cfset sHotelRateCodes&='HRG|WTT|SHORT' /><!--- Short's hotel discount codes. Backfill if account doesn't have codes listed --->
		<cfset local.getRateCodes = '' />
		<cfset local.count = 0 />

		<cfloop list="#sHotelRateCodes#" index="RateCode" delimiters="|">
			<cfif count LT 3>
				<cfset getRateCodes&='<com:CorporateDiscountID NegotiatedRateCode="true">'&RateCode&'</com:CorporateDiscountID>' />
			</cfif>
			<cfset count++ />
		</cfloop>

		<cfreturn getRateCodes />
	</cffunction>

</cfcomponent>