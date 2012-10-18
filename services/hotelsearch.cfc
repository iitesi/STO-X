<cfcomponent>
	
<!--- doHotelSearch --->
	<cffunction name="doHotelSearch" output="false">
		<cfargument name="nSearchID" />
		<cfargument name="stAccount"	default="#application.stAccounts[session.Acct_ID]#" />
    <cfargument name="stPolicy" 	default="#application.stPolicies[session.searches[url.Search_ID].Policy_ID]#" />
		<cfargument name="sAPIAuth" 	default="#application.sAPIAuth#" />
		
		<cfset local.sMessage			= 	prepareSoapHeader(arguments.stAccount, arguments.stPolicy, arguments.nSearchID) />
		<cfset local.sResponse 		= 	callAPI('HotelService', sMessage, arguments.sAPIAuth, arguments.nSearchID) />
		<cfset local.aResponse 		= 	formatResponse(sResponse) />
		<cfset local.stHotels 		= 	parseHotels(aResponse) />
		<cfset local.stChains 		= 	getChains(stHotels)>
		<cfset local.stAmenities 	= 	getAmenities(stHotels)>

		<!--- Store the hotels, chains and amenities into the session --->
		<cfset session.searches[nSearchID].stHotels 			= stHotels />
   	<cfset session.searches[nSearchID].stHotelChains	= stChains />
   	<cfset session.searches[nSearchID].stAmenities		= stAmenities />

   	<cfset session.searches[nSearchID].stSortHotels = StructKeyArray(session.searches[nSearchID].stHotels) />

		<!--- check Policy and add the struct into the session--->
		<cfset stHotels = checkPolicy(stHotels, arguments.nSearchID, stPolicy, stAccount)>

   	<cfset local.threadnamelist = '' />
   	<cfset local.count = 0 />
		<cfloop array="#session.searches[arguments.nSearchID].stSortHotels#" index="local.sHotel">
			<cfif count LT 4><!--- Stop the rates after 4. We'll get the rest of the rates later --->
				<!--- <cfthread action="run" name="#sHotel#"> --->
					<cfinvoke component="hotelprice" method="doHotelPrice" nSearchID="#arguments.nSearchID#" nHotelCode="#sHotel#" sHotelChain="#session.searches[arguments.nSearchID].stHotels[sHotel].HotelChain#" returnvariable="HotelPrices" />
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

						<!--- Create a struct with each of the hotel amenities predefined. Set the value to false and set as true when we loop through the amenities --->
						<cfset local.HotelAmenities = {} />
						<cfloop list="#structKeyList(application.stAmenities)#" index="i">
							<cfset HotelAmenities[i] = false />
						</cfloop>
						<!--- get the Hotel Amenities which are in a separate node --->
						<cfloop array="#sHotelProperty.XMLChildren#" index="local.sHotelAmenities">
							<cfif sHotelAmenities.XMLName EQ 'hotel:Amenities'>
								<cfloop from="1" to="#ArrayLen(sHotelAmenities.XMLChildren)#" index="local.sAmenity">
									<cfif structKeyExists(application.stAmenities,sHotelAmenities.XMLChildren[sAmenity].XMLAttributes.code)>
										<cfset HotelAmenities[sHotelAmenities.XMLChildren[sAmenity].XMLAttributes.code] = true />
									</cfif>
								</cfloop>
							</cfif>
						</cfloop>

						<cfset FeaturedProperty = structKeyExists(sHotelProperty.XMLAttributes,'FeaturedProperty') ? sHotelProperty.XMLAttributes.FeaturedProperty : false />
						<cfset stHotels[nHotelCode] = {
							FeaturedProperty : FeaturedProperty,
							HotelChain : nHotelChain,
							HotelLocation : sHotelProperty.XMLAttributes.HotelLocation,
							HotelAddress : HotelAddress,
							Name : sHotelProperty.XMLAttributes.Name,
							RoomsReturned : false,
							PreferredVendor : false,
							Amenities : HotelAmenities
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
		
		<cfset getSearch = getSearch(arguments.nSearchID) />

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
		
		<cfset local.bSessionStorage = true><!--- Testing setting (true - testing, false - live) --->
			
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

<!--- checkPolicy --->
	<cffunction name="checkPolicy" output="true">
		<cfargument name="stHotels" type="any" required="false">
		<cfargument name="nSearchID">
		<cfargument name="stPolicy">
		<cfargument name="stAccount">
		
		<cfset local.stHotels = arguments.stHotels />
		<cfset local.aPolicy = [] />
		<cfset local.bActive = true />
		<cfset local.bBlacklisted = (ArrayLen(arguments.stAccount.aNonPolicyHotel) GT 0 ? true : false) /><!--- are they allowed to book out of policy hotels? --->
				
		<cfloop collection="#stHotels#" item="local.sCategory">

			<cfloop collection="#stHotels[sCategory]#" item="local.sVendor">
				<cfif sVendor EQ 'HotelChain'>
					<cfset HotelChain = stHotels[sCategory]['HOTELCHAIN'] />
					<cfset aPolicy = []>
					<cfset bActive = true>
					
					<!--- Preferred Chains turned on and hotel is not a preferred chain. --->
					<cfif arguments.stPolicy.Policy_HotelPrefRule EQ 1 AND NOT ArrayFindNoCase(arguments.stAccount.aPreferredHotel, HotelChain)>
						<cfset ArrayAppend(aPolicy, 'Not a preferred vendor')>
						<cfif arguments.stPolicy.Policy_HotelPrefDisp EQ 1><!--- Only display in policy hotels? --->
							<cfset bActive = false>
						</cfif>
					</cfif>
					<!--- Out of policy if the hotel chain is blacklisted (still shows though).  --->
					<cfif bBlacklisted AND ArrayFindNoCase(arguments.stAccount.aNonPolicyHotel, HotelChain)>
						<cfset ArrayAppend(aPolicy, 'Out of policy vendor')>
					</cfif>
					<!--- Preferred Chain --->
					<cfset stHotels[sCategory].PreferredVendor = arguments.stPolicy.Policy_HotelPrefRule EQ 1 AND ArrayFindNoCase(arguments.stAccount.aPreferredHotel, HotelChain) ? true : false />

					<cfif bActive>
						<cfset stHotels[sCategory].Policy = (ArrayIsEmpty(aPolicy) ? true : false) />
						<cfset stHotels[sCategory].aPolicies = aPolicy />
					<cfelse>
						<cfset temp = StructDelete(stHotels[sCategory], HotelChain) />
						<cfset stHotels[sCategory].aPolicies = [] />
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn stHotels />
	</cffunction>

<!--- getsearch --->
	<cffunction name="getsearch" output="false">
		<cfargument name="nSearchID">

		<cfquery name="local.getsearch" datasource="book">
		SELECT Depart_DateTime, Arrival_City, Arrival_DateTime
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		
		<cfreturn getsearch />
	</cffunction>

<!--- getAmenities --->
	<cffunction name="getAmenities" output="false">
		<cfargument name="stHotels">

		<cfset local.stAmenities = [] />
		<cfloop list="#structKeyList(arguments.stHotels)#" index="local.sHotel">
			<cfset local.Amenity = arguments.stHotels[sHotel]['Amenities'] />
			<cfloop collection="#Amenity#" item="local.OneAmenity">
				<!--- Must be on the list of overall amenities and not already be in the array --->
				<cfif structKeyExists(application.stAmenities,Amenity[OneAmenity]) AND NOT ArrayFind(stAmenities,Amenity[OneAmenity])>
					<cfset ArrayAppend(stAmenities,Amenity[OneAmenity])>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn stAmenities />
	</cffunction>
</cfcomponent>