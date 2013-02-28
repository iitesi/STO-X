<cfcomponent output="false" accessors="true">

	<cfproperty name="HotelPrice">

<!---
init
--->
	<cffunction name="init" output="false">
		<cfargument name="HotelPrice">

		<cfset setHotelPrice(arguments.HotelPrice)>

		<cfreturn this>
	</cffunction>

<!--- doHotelSearch --->
	<cffunction name="doHotelSearch" output="false">
		<cfargument name="Filter">
		<cfargument name="Account">
		<cfargument name="Policy">
		<cfargument name="sAPIAuth" 	default="#application.sAPIAuth#" />

		<cfset local.SearchChanged	= checkModifySearch(form,arguments.Filter) />
		<cfset local.Search 				= arguments.Filter />
		<cfset local.SearchID 			= Search.getSearchID() />
		<cfset local.sMessage				= prepareSoapHeader(arguments.Account, arguments.Policy, SearchID, Search, arguments.Account.Hotel_RateCodes) />
		<cfset local.sResponse 			= callAPI('HotelService', sMessage, arguments.sAPIAuth, SearchID, SearchChanged) />
		<cfset local.aResponse 			= formatResponse(sResponse) />
		<cfset local.CurrentHotel 	= structKeyExists(session.searches[SearchID],'stHotels') ? session.searches[SearchID].stHotels : {} />
		<cfset local.stHotels 			= parseHotels(aResponse, CurrentHotel) />
		<cfset local.stChains 			= getChains(stHotels)>
		<cfset local.stAmenities 		= getAmenities(stHotels, application.stAmenities)>
		<cfset local.latlong 				= latlong(Search.getHotel_Search(),Search.getHotel_Airport(),Search.getHotel_Landmark(),Search.getHotel_Address(),Search.getHotel_City(),Search.getHotel_State(),Search.getHotel_Zip(),Search.getHotel_Country(),Search.getOffice_ID()) />
		<cfset local.stHotels 			= checkPolicy(stHotels, SearchID, arguments.Policy, arguments.Account) />
		<cfset local.stHotels 			= HotelInformationQuery(stHotels, SearchID, StructKeyArray(stHotels)) />

		<cfset local.aThreads = [] />
		<cfset local.count = 0 />
		<cfloop array="#StructKeyArray(stHotels)#" index="local.sHotel">
			<cfif count LT 4><!--- Stop the rates after 4. We'll get the rest of the rates later --->
				<cfif NOT stHotels[sHotel]['RoomsReturned']><!--- if rooms were already returned, don't check again --->
					<cfset local.sHotelChain = stHotels[sHotel].HotelChain />
					<cfthread name="#sHotel#" SearchID="#SearchID#" nHotelCode="#sHotel#" sHotelChain="#sHotelChain#">
						<cfset HotelPrice.doHotelPrice(arguments.SearchID,arguments.nHotelCode,arguments.sHotelChain) />
					</cfthread>
					<cfset arrayAppend(local.aThreads,sHotel)>
				</cfif>
				<cfset local.count++ />
			<cfelse>
				<cfbreak />
			</cfif>
		</cfloop>
		<cfthread action="join" name="#arraytoList(local.aThreads)#" />
		<!--- <cfdump var="#cfthread#" abort> --->

		<cfset session.searches[SearchID].Hotel					= true />
		<cfset session.searches[SearchID].Hotel_Lat 		= GetToken(latlong,1,',') />
		<cfset session.searches[SearchID].Hotel_Long		= GetToken(latlong,2,',') />
		<cfset session.searches[SearchID].stHotels 			= stHotels />
		<cfset session.searches[SearchID].stHotelChains	= stChains />
		<cfset session.searches[SearchID].slatlong			= latlong />
		<cfset session.searches[SearchID].stAmenities		=	stAmenities />
		<cfset session.searches[SearchID].stSortHotels 	= StructKeyArray(stHotels) />

		<cfreturn />
	</cffunction>	

<!--- callAPI --->
	<cffunction name="callAPI" output="false">
		<cfargument name="sService">
		<cfargument name="sMessage">
		<cfargument name="sAPIAuth">
		<cfargument name="SearchID">
		<cfargument name="SearchChanged">
		
		<cfset local.bSessionStorage = true /><!--- Testing setting (true - testing, false - live) --->
		<!--- if the search was changed then make sure we go out and re-fetch results otherwise keep what's set --->
		<cfif structKeyExists(arguments,'SearchChanged')>
			<cfset local.bSessionStorage = arguments.SearchChanged ? false : bSessionStorage />
		</cfif>
			
		<cfif NOT bSessionStorage OR NOT StructKeyExists(session.searches[SearchID], 'stHotelsFileContent')>
			<cfhttp method="post" url="https://americas.copy-webservices.travelport.com/B2BGateway/connect/UAPI/#arguments.sService#">
				<cfhttpparam type="header" name="Authorization" value="Basic #arguments.sAPIAuth#" />
				<cfhttpparam type="header" name="Content-Type" value="text/xml;charset=UTF-8" />
				<cfhttpparam type="header" name="Accept" value="gzip,deflate" />
				<cfhttpparam type="header" name="Cache-Control" value="no-cache" />
				<cfhttpparam type="header" name="Pragma" value="no-cache" />
				<cfhttpparam type="header" name="SOAPAction" value="" />
				<cfhttpparam type="body" name="message" value="#Trim(arguments.sMessage)#" />
			</cfhttp>
			<cfif bSessionStorage>
				<cfset session.searches[SearchID].stHotelsFileContent = cfhttp.filecontent />
			</cfif>
		<cfelse>
			<cfset cfhttp.filecontent = session.searches[SearchID].stHotelsFileContent />
		</cfif>
		
		<cfreturn cfhttp.filecontent />
	</cffunction>

<!--- prepareSoapHeader --->
	<cffunction name="prepareSoapHeader" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="stPolicy" 	required="true">
		<cfargument name="SearchID" 	required="true">
		<cfargument name="Filter">
		<cfargument name="RateCodes">
		<cfargument name="Hotel_Radius">
		
		<cfset local.Search = arguments.Filter />
		<cfset local.Hotel_Radius = structKeyExists(arguments,'Hotel_Radius') ? arguments.Hotel_Radius : Search.getHotel_Radius() />

		<cfsavecontent variable="local.message">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<hot:HotelSearchAvailabilityReq TargetBranch="P7003155" xmlns:com="http://www.travelport.com/schema/common_v15_0" xmlns:hot="http://www.travelport.com/schema/hotel_v17_0">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI"/>
							<hot:HotelLocation Location="#Search.getArrival_City()#" LocationType="Airport">
								<!--- <com:VendorLocation ProviderCode="1V"  VendorCode="RD" VendorLocationID="86291"/> ---> <!--- 1V - apollo --->
							</hot:HotelLocation>
							<hot:HotelSearchModifiers NumberOfAdults="1" NumberOfRooms="1">
								#getRateCodes(arguments.RateCodes)#
								<com:Distance Value="#Search.getHotel_Radius()#" Direction="" xmlns="http://www.travelport.com/schema/common_v16_0"/>
								<!---<PermittedChains>
									<HotelChain Code="ES"/>
									<HotelChain Code="EM"/>
									<HotelChain Code="HY"/>
								</PermittedChains>
								<RateCategory>All</RateCategory>--->
							</hot:HotelSearchModifiers>
							<hot:HotelStay>
								<hot:CheckinDate>#DateFormat(Search.getCheckIn_Date(),'yyyy-mm-dd')#</hot:CheckinDate>
								<hot:CheckoutDate>#DateFormat(Search.getCheckOut_Date(),'yyyy-mm-dd')#</hot:CheckoutDate>
							</hot:HotelStay>
							<com:PointOfSale ProviderCode="1V" PseudoCityCode="1M98" xmlns:com="http://www.travelport.com/schema/common_v15_0" />
						</hot:HotelSearchAvailabilityReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn message/>
	</cffunction>
		
<!--- formatResponse --->
	<cffunction name="formatResponse" output="false">
		<cfargument name="stResponse">
		
		<cfset local.stResponse = XMLParse(arguments.stResponse)>
		
		<cfreturn stResponse.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren />
	</cffunction>
	
<!--- parseHotels --->
	<cffunction name="parseHotels" output="false">
		<cfargument name="stResponse">
		<cfargument name="stHotels">
		
		<cfset local.stHotels = arguments.stHotels />
		<cfset local.sIndex = '' />

		<cfloop array="#arguments.stResponse#" index="local.sHotelResultList">

			<cfif sHotelResultList.XMLName EQ 'hotel:HotelSearchResult'>

				<!--- Loop through each properties main attributes --->
				<cfloop array="#sHotelResultList.XMLChildren#" index="local.sHotelProperty">
					
					<cfif structKeyExists(sHotelProperty,'XMLAttributes') AND structKeyExists(sHotelProperty.XMLAttributes,'HotelCode')>
						<!--- Set this as a variable because we'll need it later --->
						<cfset local.nHotelCode = sHotelProperty.XMLAttributes.HotelCode />
						<cfset local.nHotelChain = sHotelProperty.XMLAttributes.HotelChain />

						<!--- get the Hotel Property Address which is in a separate node --->
						<cfloop array="#sHotelProperty.XMLChildren#" index="local.sHotelAddress">
							<cfif sHotelAddress.XMLName EQ 'hotel:PropertyAddress'>
								<cfset local.HotelAddress = sHotelAddress.XMLChildren.1.XMLText />
							</cfif>
						</cfloop>

						<!--- Create a struct with each of the hotel amenities predefined. Set the value to false and set as true when we loop through the amenities --->
						<cfset local.HotelAmenities = {} />
						<cfloop list="#structKeyList(application.stAmenities)#" index="local.i">
							<cfset local.HotelAmenities[local.i] = false />
						</cfloop>
						<!--- get the Hotel Amenities which are in a separate node --->
						<cfloop array="#sHotelProperty.XMLChildren#" index="local.sHotelAmenities">
							<cfif sHotelAmenities.XMLName EQ 'hotel:Amenities'>
								<cfloop from="1" to="#ArrayLen(sHotelAmenities.XMLChildren)#" index="local.sAmenity">
									<cfif structKeyExists(application.stAmenities,sHotelAmenities.XMLChildren[sAmenity].XMLAttributes.code)>
										<cfset local.HotelAmenities[sHotelAmenities.XMLChildren[sAmenity].XMLAttributes.code] = true />
									</cfif>
								</cfloop>
							</cfif>
						</cfloop>

						<cfset local.FeaturedProperty = structKeyExists(sHotelProperty.XMLAttributes,'FeaturedProperty') ? sHotelProperty.XMLAttributes.FeaturedProperty : false />
						<cfset local.stHotels[nHotelCode] = {
							FeaturedProperty : FeaturedProperty,
							HotelChain : nHotelChain,
							HOTELINFORMATION : {
									HotelLocation : sHotelProperty.XMLAttributes.HotelLocation,
									HotelAddress : HotelAddress,
									Name : sHotelProperty.XMLAttributes.Name
								},
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
		<cfargument name="HotelRateCodes">
		
		<cfset local.sHotelRateCodes = arguments.HotelRateCodes />
		<cfset local.sHotelRateCodes&= Len(Trim(sHotelRateCodes)) ? '|' : '' />
		<cfset local.sHotelRateCodes&='H4R|LTS|SHORT' /><!--- Short's hotel discount codes. Backfill if account doesn't have codes listed --->
		<cfset local.getRateCodes = '' />
		<cfset local.count = 0 />

		<cfloop list="#sHotelRateCodes#" delimiters="|" index="local.RateCode">
			<cfif count LT 3>
				<cfset local.getRateCodes&='<com:CorporateDiscountID NegotiatedRateCode="true">'&RateCode&'</com:CorporateDiscountID>' />
			</cfif>
			<cfset local.count++ />
		</cfloop>

		<cfreturn getRateCodes />
	</cffunction>

<!--- checkPolicy --->
	<cffunction name="checkPolicy" output="true">
		<cfargument name="stHotels" type="any" required="false">
		<cfargument name="SearchID">
		<cfargument name="stPolicy">
		<cfargument name="stAccount">
		
		<cfset local.stHotels = arguments.stHotels />
		<cfset local.aPolicy = [] />
		<cfset local.bActive = true />
		<cfset local.bBlacklisted = (ArrayLen(arguments.stAccount.aNonPolicyHotel) GT 0 ? true : false) /><!--- are they allowed to book out of policy hotels? --->
				
		<cfloop collection="#stHotels#" item="local.sCategory">

			<cfloop collection="#stHotels[sCategory]#" item="local.sVendor">
				<cfif sVendor EQ 'HotelChain'>
					<cfset local.HotelChain = stHotels[sCategory]['HOTELCHAIN'] />
					<cfset local.aPolicy = []>
					<cfset local.bActive = true>
					
					<!--- Preferred Chains turned on and hotel is not a preferred chain. --->
					<cfif arguments.stPolicy.Policy_HotelPrefRule EQ 1 AND NOT ArrayFindNoCase(arguments.stAccount.aPreferredHotel, HotelChain)>
						<cfset ArrayAppend(aPolicy, 'Not a preferred vendor')>
						<cfif arguments.stPolicy.Policy_HotelPrefDisp EQ 1><!--- Only display in policy hotels? --->
							<cfset local.bActive = false>
						</cfif>
					</cfif>
					<!--- Out of policy if the hotel chain is blacklisted (still shows though).  --->
					<cfif bBlacklisted AND ArrayFindNoCase(arguments.stAccount.aNonPolicyHotel, HotelChain)>
						<cfset ArrayAppend(aPolicy, 'Out of policy vendor')>
					</cfif>
					<!--- Preferred Chain --->
					<cfset local.stHotels[sCategory].PreferredVendor = arguments.stPolicy.Policy_HotelPrefRule EQ 1 AND ArrayFindNoCase(arguments.stAccount.aPreferredHotel, HotelChain) ? true : false />

					<cfif bActive>
						<cfset local.stHotels[sCategory].Policy = (ArrayIsEmpty(aPolicy) ? true : false) />
						<cfset local.stHotels[sCategory].aPolicies = aPolicy />
					<cfelse>
						<cfset StructDelete(local.stHotels[sCategory], HotelChain) />
						<cfset local.stHotels[sCategory].aPolicies = [] />
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn stHotels />
	</cffunction>

<!--- getAmenities --->
	<cffunction name="getAmenities" output="false">
		<cfargument name="stHotels">
		<cfargument name="stAmenities">

		<cfset local.aAmenities = [] />
		<cfloop list="#structKeyList(arguments.stHotels)#" index="local.sHotel">
			<cfset local.stAmenity = arguments.stHotels[sHotel]['Amenities'] />
			<cfloop collection="#stAmenity#" item="local.OneAmenity">
				<!--- Must be on the list of overall amenities and not already be in the array --->
				<cfif structKeyExists(arguments.stAmenities,OneAmenity) AND NOT ArrayFind(aAmenities,OneAmenity)>
					<cfset ArrayAppend(aAmenities,OneAmenity) />
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn aAmenities />
	</cffunction>

<!--- latlong --->
	<cffunction Name="latlong" access="remote" returntype="string" output="false">
		<cfargument Name="Hotel_Search" />
		<cfargument Name="Hotel_Airport" />
		<cfargument Name="Hotel_Landmark" />
		<cfargument Name="Hotel_Address" />
		<cfargument Name="Hotel_City" />
		<cfargument Name="Hotel_State" />
		<cfargument Name="Hotel_Zip" />
		<cfargument Name="Hotel_Country" />
		<cfargument Name="Office_ID" />
		
		<cfset local.LatLong = '0,0'>
		<cfset local.getSpecificLongLat = ''>
		<cfset local.Search_Location = ''>
		
		<cfif arguments.Hotel_Search EQ 'Airport'>
			<cfquery name="getSpecificLongLat" datasource="book" cachedwithin="#createTimeSpan(1,0,0,0)#">
			SELECT Long, Lat, Geography_ID
			FROM lu_Geography
			WHERE Location_Display = <cfqueryparam value="#arguments.Hotel_Airport#" cfsqltype="cf_sql_varchar">
			AND Location_Type = 125
			AND Lat <> 0
			AND Long <> 0
			</cfquery>
			<cfif getSpecificLongLat.RecordCount EQ 1>
				<cfset local.LatLong = getSpecificLongLat.Lat&','&getSpecificLongLat.Long&','&getSpecificLongLat.Geography_ID>
			<cfelseif Len(arguments.Hotel_Airport) EQ 3>
				<cfquery name="getSpecificLongLat" datasource="book" cachedwithin="#createTimeSpan(1,0,0,0)#">
				SELECT Long, Lat, Geography_ID
				FROM lu_Geography
				WHERE Location_Code = <cfqueryparam value="#arguments.Hotel_Airport#" cfsqltype="cf_sql_varchar">
				AND Location_Type = 125
				AND Lat <> 0
				AND Long <> 0
				</cfquery>
				<cfif getSpecificLongLat.RecordCount EQ 1>
					<cfset local.LatLong = getSpecificLongLat.Lat&','&getSpecificLongLat.Long&','&getSpecificLongLat.Geography_ID>
				</cfif>
			</cfif>
		<cfelseif arguments.Hotel_Search EQ 'City'>
			<cfquery name="getSpecificLongLat" datasource="book" cachedwithin="#createTimeSpan(1,0,0,0)#">
			SELECT Long, Lat, Geography_ID
			FROM lu_Geography
			WHERE Location_Display = <cfqueryparam value="#arguments.Hotel_Landmark#" cfsqltype="cf_sql_varchar">
			AND Location_Type = 126
			AND Lat <> 0
			AND Long <> 0
			</cfquery>
			<cfif getSpecificLongLat.RecordCount EQ 1 AND getSpecificLongLat.Lat NEQ '' AND getSpecificLongLat.Long NEQ ''>
				<cfset local.LatLong = getSpecificLongLat.Lat&','&getSpecificLongLat.Long&','&getSpecificLongLat.Geography_ID>
			</cfif>
		<cfelseif arguments.Hotel_Search EQ 'Office'>
			<cfquery name="getSpecificLongLat" datasource="book" cachedwithin="#createTimeSpan(1,0,0,0)#">
			SELECT Office_Long, Office_Lat
			FROM Account_Offices
			WHERE Office_ID = <cfqueryparam value="#arguments.Office_ID#" cfsqltype="cf_sql_numeric">
			</cfquery>
			<cfif getSpecificLongLat.RecordCount EQ 1 AND getSpecificLongLat.Office_Lat NEQ '' AND getSpecificLongLat.Office_Long NEQ ''>
				<cfset local.LatLong = getSpecificLongLat.Office_Lat&','&getSpecificLongLat.Office_Long&',0'>
			</cfif>
		</cfif>
		<cfif LatLong EQ '0,0'>
			<cfif arguments.Hotel_Search EQ 'Airport'>
				<cfset local.Search_Location = arguments.Hotel_Airport>
			<cfelseif arguments.Hotel_Search EQ 'City'>
				<cfset local.Search_Location = arguments.Hotel_Landmark>
			<cfelseif arguments.Hotel_Search EQ 'Office'>
				<cfset local.Search_Location = ''>
			<cfelse>
				<cfset local.Search_Location = '#Trim(arguments.Hotel_Address)#,#Trim(arguments.Hotel_City)#,#Trim(arguments.Hotel_State)#,#Trim(arguments.Hotel_Zip)#,#Trim(arguments.Hotel_Country)#'>
			</cfif>
			<cfif local.Search_Location NEQ '' AND local.Search_Location NEQ ',,,'>
				<cftry>
					<cfhttp method="get" url="https://maps.google.com/maps/geo?q=#Search_Location#&output=xml&oe=utf8\&sensor=false&key=ABQIAAAAIHNFIGiwETbSFcOaab8PnBQ2kGXFZEF_VQF9vr-8nzO_JSz_PxTci5NiCJMEdaUIn3HA4o_YLE757Q" />
					<cfset local.LatLong = XMLParse(cfhttp.FileContent)>
					<cfset local.LatLong = LatLong.kml.Response.Placemark.Point.coordinates.XMLText>
					<cfset local.LatLong = GetToken(LatLong, 2, ',')&','&GetToken(LatLong, 1, ',')&',0'>
					<cfcatch>
						<cfset local.LatLong = '0,0'>
					</cfcatch>
				</cftry>
			</cfif>
		</cfif>
			
		<cfreturn LatLong>
	</cffunction>

<!--- checkModifySearch --->
	<cffunction name="checkModifySearch" output="false">
		<cfargument name="form">
		<cfargument name="Filter">

		<cfset local.SearchChanged = false />
		<cfset local.form = arguments.form />
		<cfif structKeyExists(form,'ModifySearch') AND form.ModifySearch EQ 'LetsModify!'>
			<cfset local.formfields = 'CheckIn_Date,CheckOut_Date,Hotel_Radius,Hotel_Zip,Hotel_City,Hotel_Address,Hotel_State,Hotel_Landmark,Hotel_Airport,Hotel_Search' />
			<cfloop list="#local.formfields#" index="OneField">
				<cfset local.getFunc = arguments.Filter[ 'get' & OneField ] />
				<cfset local.getFunc( form[OneField] ) />
				<cfif structKeyExists(form,OneField) AND form[OneField] NEQ getFunc( form[OneField] )>
					<cfset local.setFunc = arguments.Filter[ 'set' & OneField ] />
					<cfset local.setFunc( form[OneField] ) />
					<cfset local.SearchChanged = true />
				</cfif>	
			</cfloop>		
		</cfif>

		<cfreturn SearchChanged />
	</cffunction>

<!--- HotelInformationQuery --->
	<cffunction name="HotelInformationQuery" access="public" output="false" returntype="struct">
		<cfargument name="stHotels">
		<cfargument name="SearchID">
		<cfargument name="aHotels">		
		<cfargument name="stAmenities" default="#application.stAmenities#" />

		<cfset local.stHotels = arguments.stHotels />
		<cfset local.aHotels = arguments.aHotels />
		<cfset local.stAmenities = arguments.stAmenities />
		<cfset local.PropertyIDs = arrayToList(local.aHotels) />

		<cfquery name="local.HotelInformationQuery" datasource="Book">
		SELECT RIGHT('0000'+CAST(PROPERTY_ID AS VARCHAR),5) PROPERTY_ID, SIGNATURE_IMAGE, LAT, LONG, CHAIN_CODE, 0 AS POLICY, 0 AS LOWRATE, 0 AS SOLDOUT<cfloop list="#structKeyList(stAmenities)#" index="local.Amenity">, 0 AS #Amenity#</cfloop>
		FROM lu_hotels
		WHERE Property_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" list="true" value="#PropertyIDs#" />)
		<cfif NOT arrayIsEmpty(aHotels)>
			ORDER BY CASE <cfloop array="#local.aHotels#" index="count" item="property">WHEN Property_ID = '#property#' THEN #count# </cfloop>END			
		</cfif>
		</cfquery>

		<cfloop query="HotelInformationQuery">
			<!--- Pull in the existing hotel information from the structure --->
			<cfset local.stHotelInformation = stHotels[NumberFormat(HotelInformationQuery.Property_ID,'00000')]['HOTELINFORMATION'] />
			<cfset local.stHotelInformation['SIGNATURE_IMAGE'] = HotelInformationQuery.Signature_Image />
			<cfset local.stHotelInformation['LATITUDE'] = HotelInformationQuery.Lat />
			<cfset local.stHotelInformation['LONGITUDE'] = HotelInformationQuery.Long />
			<!--- add the hotel information back into the hotel structure --->
			<cfset local.stHotels[NumberFormat(HotelInformationQuery.Property_ID,'00000')]['HOTELINFORMATION'] = stHotelInformation />
			
			<cfset local.stHotelAmenities = stHotels[NumberFormat(HotelInformationQuery.Property_ID,'00000')]['Amenities'] />
			<cfloop list="#structKeyList(stHotelAmenities)#" index="local.Amenity">
				<!--- Update query to show yes if hotel amenity is true --->
				<cfset local.stHotelAmenities[Amenity] ? querySetCell(HotelInformationQuery, Amenity, 1, HotelInformationQuery.CurrentRow) : '' />
			</cfloop>
			<!--- Update policy if value is true. Don't update if false --->
			<cfif stHotels[NumberFormat(HotelInformationQuery.Property_ID,'00000')]['POLICY']>
				<cfset querySetCell(HotelInformationQuery, 'POLICY', 1, HotelInformationQuery.CurrentRow) />
			</cfif>
			<!--- Update lowrate if it exists --->
			<cfif structKeyExists(stHotels[NumberFormat(HotelInformationQuery.Property_ID,'00000')],'LowRate')>
				<cfset querySetCell(HotelInformationQuery, 'POLICY', stHotels[NumberFormat(HotelInformationQuery.Property_ID,'00000')]['LOWRATE'], HotelInformationQuery.CurrentRow) />
			</cfif>
		</cfloop>

		<!--- Add HotelInformationQuery to the session for filtering --->
		<cfset session.searches[arguments.SearchID].HotelInformationQuery = HotelInformationQuery />

		<cfreturn stHotels />
	</cffunction>

<!--- selectHotel --->
	<cffunction name="selectHotel" output="false">
		<cfargument name="nHotelID" default="#form.sHotel#">
		<cfargument name="nRoom" default="#form.sRoomDescription#">
		<cfargument name="Filter">

		<cfset local.Search 					= arguments.Filter />
		<cfset local.SearchID 				= Search.getSearchID() />
		<cfset local.Nights 					= DateDiff('d',Search.getCheckIn_Date(),Search.getCheckOut_Date()) />
		<cfset local.RoomDescription 	= session.searches[arguments.SearchID].stHotels[arguments.nHotelID]['Rooms'][arguments.nRoom] />

		<!--- Initialize or overwrite the CouldYou hotel section --->
		<cfset session.searches[arguments.SearchID].CouldYou.Hotel = {} />
		<cfset session.searches[arguments.SearchID]['Hotel'] = true />
		<!--- Move over the information into the stItinerary --->
		<cfset session.searches[arguments.SearchID].stItinerary.Hotel = {
			HotelID:nHotelID, 
			HotelChain:session.searches[arguments.SearchID].stHotels[arguments.nHotelID].HotelChain,
			CheckIn:Search.getCheckIn_Date(), 
			CheckOut:Search.getCheckOut_Date,
			Nights:Nights,
			TotalRate:Nights * RoomDescription.HotelRate.BaseRate,
			RoomDescription: RoomDescription
		} />
		
		<!--- Loop through the searches structure and delete all other searches --->
		<cfloop collection="#session.searches#" index="local.nKey">
			<cfif IsNumeric(nKey) AND nKey NEQ arguments.SearchID>
				<cfset StructDelete(session.searches, nKey)>
			</cfif>
		</cfloop>
		
		<cfreturn />
	</cffunction>

<!--- skipHotel --->
	<cffunction name="skipHotel" output="false">
		<cfargument name="SearchID">

		<cfset session.searches[arguments.SearchID].Hotel = false />
		
		<cfreturn />
	</cffunction>

</cfcomponent>