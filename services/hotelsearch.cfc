<cfcomponent>
<!---
init
--->
	<!--- <cffunction name="init" output="false">
		
		<cfset variables.objHotelSearch = CreateObject('component', 'booking.services.hotelsearch').init()>
		
		<cfreturn this>
	</cffunction> --->
	
<!--- doHotelSearch --->
	<cffunction name="doHotelSearch" output="false">
		<cfargument name="nSearchID" />
		<cfargument name="stAccount"	default="#application.stAccounts[session.Acct_ID]#" />
    <cfargument name="stPolicy" 	default="#application.stPolicies[session.searches[url.Search_ID].nPolicyID]#" />
		<cfargument name="sAPIAuth" 	default="#application.sAPIAuth#" />
		
		<cfset local.nSearchID 		= arguments.nSearchID />

		<cfset local.sMessage			= prepareSoapHeader(arguments.stAccount, arguments.stPolicy, nSearchID) />
		<cfset local.sResponse 		= callAPI('HotelService', sMessage, arguments.sAPIAuth, nSearchID) />
		<cfset local.aResponse 		= formatResponse(sResponse) />
		<cfset local.stHotels 		= parseHotels(aResponse) />
		<cfset local.stChains 		= getChains(stHotels)>
		<cfset local.stAmenities 	= getAmenities(stHotels)>
		<cfset local.latlong 			= latlong(getSearch.Hotel_Search,getSearch.Hotel_Airport,getSearch.Hotel_Landmark,getSearch.Hotel_Address,getSearch.Hotel_City,getSearch.Hotel_State,getSearch.Hotel_Zip,getSearch.Hotel_Country,getSearch.Office_ID) />
				
		<!--- Store the hotels, chains, amenities and lat/long into the session --->
		<cfset session.searches[nSearchID].stHotels 			= stHotels />
   	<cfset session.searches[nSearchID].stHotelChains	= stChains />
   	<cfset session.searches[nSearchID].slatlong				= latlong />
   	<cfset session.searches[nSearchID].stAmenities		= stAmenities />
   	<cfset session.searches[nSearchID].stSortHotels 	= StructKeyArray(session.searches[nSearchID].stHotels) />

   	<!--- store the hotel latitude and longitude in the session --->
   	<cfset session.searches[nSearchID]['Hotel']				= 1 />
		<cfset session.searches[nSearchID]['Hotel_Lat'] 	= GetToken(session.searches[nSearchID].slatlong,1,',') />
		<cfset session.searches[nSearchID]['Hotel_Long'] 	= GetToken(session.searches[nSearchID].slatlong,2,',') />

		<!--- check Policy and add the struct into the session--->
		<cfset stHotels = checkPolicy(stHotels, nSearchID, stPolicy, stAccount) />
		<cfset local.stHotels 		= HotelInformationQuery(stHotels, nSearchID) /><!--- add signature_image, latitude and longitude --->

		<cfset local.aThreads = [] />
   	<cfset local.count = 0 />
		<cfloop array="#session.searches[nSearchID].stSortHotels#" index="local.sHotel">
			<cfif count LT 4><!--- Stop the rates after 4. We'll get the rest of the rates later --->
				<!--- <cfthread name="#sHotel#"> --->
					<cfinvoke component="hotelprice" method="doHotelPrice" nSearchID="#nSearchID#" nHotelCode="#sHotel#" sHotelChain="#session.searches[nSearchID].stHotels[sHotel].HotelChain#" returnvariable="HotelPrices" />
				<!--- </cfthread> --->
				<cfset arrayAppend(aThreads,sHotel)>
				<cfset count++ />
			</cfif>
		</cfloop>
		<!--- <cfthread action="join" name="#arraytoList(aThreads)#" />
		<cfdump var="#cfthread#" abort> --->

		<cfreturn />
	</cffunction>
	
<!--- parseHotels --->
	<cffunction name="parseHotels" output="false">
		<cfargument name="stResponse">
		<cfargument name="stAccount" 	default="#application.stAccounts[session.Acct_ID]#">
		<cfargument name="stPolicy" 	default="#application.stPolicies[session.searches[url.Search_ID].nPolicyID]#">
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
								<!--- <com:VendorLocation ProviderCode="1V"  VendorCode="RD" VendorLocationID="86291"/> ---> <!--- 1V - apollo --->
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
								<hot:CheckinDate>#DateFormat(getSearch.CheckIn_Date,'yyyy-mm-dd')#</hot:CheckinDate>
								<hot:CheckoutDate>#DateFormat(getSearch.CheckOut_Date,'yyyy-mm-dd')#</hot:CheckoutDate>
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
		
		<cfset local.bSessionStorage = true /><!--- Testing setting (true - testing, false - live) --->
			
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
						<cfset StructDelete(stHotels[sCategory], HotelChain) />
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
		SELECT CheckIn_Date, Arrival_City, CheckOut_Date, Hotel_Search, Hotel_Airport, Hotel_Landmark, Hotel_Address, Hotel_City, Hotel_State, Hotel_Zip, Hotel_Country, Office_ID
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
			<cfset local.stAmenity = arguments.stHotels[sHotel]['Amenities'] />
			<cfloop collection="#stAmenity#" item="local.OneAmenity">
				<!--- Must be on the list of overall amenities and not already be in the array --->
				<cfif structKeyExists(application.stAmenities,OneAmenity) AND NOT ArrayFind(stAmenities,OneAmenity)>
					<cfset stAmenity[OneAmenity] ? ArrayAppend(stAmenities,OneAmenity) : ''>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn stAmenities />
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
		
		<cfset var LatLong = '0,0'>
		<cfset var getSpecificLongLat = ''>
		<cfset var Search_Location = ''>
		
		<cfif arguments.Hotel_Search EQ 'Airport'>
			<cfquery name="getSpecificLongLat" datasource="book">
			SELECT Long, Lat, Geography_ID
			FROM lu_Geography
			WHERE Location_Display = <cfqueryparam value="#arguments.Hotel_Airport#" cfsqltype="cf_sql_varchar">
			AND Location_Type = 125
			AND Lat <> 0
			AND Long <> 0
			</cfquery>
			<cfif getSpecificLongLat.RecordCount EQ 1>
				<cfset LatLong = getSpecificLongLat.Lat&','&getSpecificLongLat.Long&','&getSpecificLongLat.Geography_ID>
			<cfelseif Len(arguments.Hotel_Airport) EQ 3>
				<cfquery name="getSpecificLongLat" datasource="book">
				SELECT Long, Lat, Geography_ID
				FROM lu_Geography
				WHERE Location_Code = <cfqueryparam value="#arguments.Hotel_Airport#" cfsqltype="cf_sql_varchar">
				AND Location_Type = 125
				AND Lat <> 0
				AND Long <> 0
				</cfquery>
				<cfif getSpecificLongLat.RecordCount EQ 1>
					<cfset LatLong = getSpecificLongLat.Lat&','&getSpecificLongLat.Long&','&getSpecificLongLat.Geography_ID>
				</cfif>
			</cfif>
		<cfelseif arguments.Hotel_Search EQ 'City'>
			<cfquery name="getSpecificLongLat" datasource="book">
			SELECT Long, Lat, Geography_ID
			FROM lu_Geography
			WHERE Location_Display = <cfqueryparam value="#arguments.Hotel_Landmark#" cfsqltype="cf_sql_varchar">
			AND Location_Type = 126
			AND Lat <> 0
			AND Long <> 0
			</cfquery>
			<cfif getSpecificLongLat.RecordCount EQ 1 AND getSpecificLongLat.Lat NEQ '' AND getSpecificLongLat.Long NEQ ''>
				<cfset LatLong = getSpecificLongLat.Lat&','&getSpecificLongLat.Long&','&getSpecificLongLat.Geography_ID>
			</cfif>
		<cfelseif arguments.Hotel_Search EQ 'Office'>
			<cfquery name="getSpecificLongLat" datasource="book">
			SELECT Office_Long, Office_Lat
			FROM Account_Offices
			WHERE Office_ID = <cfqueryparam value="#arguments.Office_ID#" cfsqltype="cf_sql_numeric">
			</cfquery>
			<cfif getSpecificLongLat.RecordCount EQ 1 AND getSpecificLongLat.Office_Lat NEQ '' AND getSpecificLongLat.Office_Long NEQ ''>
				<cfset LatLong = getSpecificLongLat.Office_Lat&','&getSpecificLongLat.Office_Long&',0'>
			</cfif>
		</cfif>
		<cfif LatLong EQ '0,0'>
			<cfif arguments.Hotel_Search EQ 'Airport'>
				<cfset Search_Location = arguments.Hotel_Airport>
			<cfelseif arguments.Hotel_Search EQ 'City'>
				<cfset Search_Location = arguments.Hotel_Landmark>
			<cfelseif arguments.Hotel_Search EQ 'Office'>
				<cfset Search_Location = ''>
			<cfelse>
				<cfset Search_Location = '#Trim(arguments.Hotel_Address)#,#Trim(arguments.Hotel_City)#,#Trim(arguments.Hotel_State)#,#Trim(arguments.Hotel_Zip)#,#Trim(arguments.Hotel_Country)#'>
			</cfif>
			<cfif Search_Location NEQ '' AND Search_Location NEQ ',,,'>
				<cftry>
					<cfhttp method="get" url="https://maps.google.com/maps/geo?q=#Search_Location#&output=xml&oe=utf8\&sensor=false&key=ABQIAAAAIHNFIGiwETbSFcOaab8PnBQ2kGXFZEF_VQF9vr-8nzO_JSz_PxTci5NiCJMEdaUIn3HA4o_YLE757Q" />
					<cfset LatLong = XMLParse(cfhttp.FileContent)>
					<cfset LatLong = LatLong.kml.Response.Placemark.Point.coordinates.XMLText>
					<cfset LatLong = GetToken(LatLong, 2, ',')&','&GetToken(LatLong, 1, ',')&',0'>
					<cfcatch>
						<cfset LatLong = '0,0'>
					</cfcatch>
				</cftry>
			</cfif>
		</cfif>
			
		<cfreturn LatLong>
	</cffunction>

<!--- HotelInformationQuery --->
	<cffunction name="HotelInformationQuery" access="public" output="false" returntype="struct">
		<cfargument name="stHotels">
		<cfargument name="Search_ID">
		<cfargument name="stAmenities" default="#application.stAmenities#" />

		<cfset local.stHotels = arguments.stHotels />
		<cfset local.stAmenities = arguments.stAmenities />
		<cfset local.PropertyIDs = [] />

		<cfloop list="#StructKeyList(stHotels)#" index="sHotel">
			<cfset ArrayAppend(PropertyIDs,sHotel)>
		</cfloop>
		<cfset PropertyIDs = arrayToList(PropertyIDs) />

		<cfquery name="local.HotelInformationQuery" datasource="Book">
		SELECT RIGHT('0000'+CAST(PROPERTY_ID AS VARCHAR),5) PROPERTY_ID, SIGNATURE_IMAGE, LAT, LONG, CHAIN_CODE, 0 AS POLICY<cfloop list="#structKeyList(stAmenities)#" index="local.Amenity">, 0 AS #Amenity#</cfloop>
		FROM lu_hotels
		WHERE Property_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" list="true" value="#PropertyIDs#" />)
		</cfquery>

		<cfloop query="HotelInformationQuery">
			<!--- Pull in the existing hotel information from the structure --->
			<cfset local.stHotelInformation = stHotels[NumberFormat(HotelInformationQuery.Property_ID,'00000')]['HOTELINFORMATION'] />
			<cfset stHotelInformation['SIGNATURE_IMAGE'] = HotelInformationQuery.Signature_Image />
			<cfset stHotelInformation['LATITUDE'] = HotelInformationQuery.Lat />
			<cfset stHotelInformation['LONGITUDE'] = HotelInformationQuery.Long />
			<!--- add the hotel information back into the hotel structure --->
			<cfset stHotels[NumberFormat(HotelInformationQuery.Property_ID,'00000')]['HOTELINFORMATION'] = stHotelInformation />
			
			<cfset local.stHotelAmenities = stHotels[NumberFormat(HotelInformationQuery.Property_ID,'00000')]['Amenities'] />
			<cfloop list="#structKeyList(stHotelAmenities)#" index="local.Amenity">
				<!--- Update query to show yes if hotel amenity is true --->
				<cfset stHotelAmenities[Amenity] ? querySetCell(HotelInformationQuery, Amenity, 1, HotelInformationQuery.CurrentRow) : '' />
			</cfloop>
			<!--- Update policy if value is true. Don't update if false --->
			<cfif stHotels[NumberFormat(HotelInformationQuery.Property_ID,'00000')]['POLICY']>
				<cfset querySetCell(HotelInformationQuery, 'POLICY', 1, HotelInformationQuery.CurrentRow) />
			</cfif>
		</cfloop>

		<!--- Add HotelInformationQuery to the session for filtering --->
		<cfset session.searches[arguments.Search_ID].HotelInformationQuery = HotelInformationQuery />

		<cfreturn stHotels />
	</cffunction>

<!---
selectHotel
--->
	<cffunction name="selectHotel" output="false">
		<cfargument name="nHotelID" default="#listFirst(form.sHotel)#">
		<cfargument name="nRoom" default="#listLast(form.sHotel)#">
		<cfargument name="nSearchID" default="#url.Search_ID#">

		<cfset getSearch = getSearch(arguments.nSearchID) />
		<cfset local.Nights = DateDiff('d',getSearch.CheckIn_Date,getSearch.CheckOut_Date) />
		<cfset local.RoomDescription = session.searches[arguments.nSearchID].stHotels[arguments.nHotelID]['Rooms'][arguments.nRoom] />

		<!--- Initialize or overwrite the CouldYou hotel section --->
		<cfset session.searches[arguments.nSearchID].CouldYou.Hotel = {} />
		<cfset session.searches[arguments.nSearchID]['bHotel'] = true />
		<!--- Move over the information into the stItinerary --->
		<cfset session.searches[arguments.nSearchID].stItinerary.Hotel = {
			HotelID:nHotelID, 
			HotelChain:session.searches[arguments.nSearchID].stHotels[arguments.nHotelID].HotelChain,
			CheckIn:getSearch.CheckIn_Date, 
			CheckOut:getSearch.CheckOut_Date,
			Nights:Nights,
			TotalRate:Nights * RoomDescription.HotelRate.BaseRate,
			RoomDescription: RoomDescription
		} />
		
		<!--- Loop through the searches structure and delete all other searches --->
		<cfloop collection="#session.searches#" index="local.nKey">
			<cfif IsNumeric(nKey) AND nKey NEQ arguments.nSearchID>
				<cfset StructDelete(session.searches, nKey)>
			</cfif>
		</cfloop>
		
		<cfreturn />
	</cffunction>

<!---
skiptHotel
--->
	<cffunction name="skipHotel" output="false">
		<cfargument name="nSearchID">

		<cfset session.searches[arguments.nSearchID].bHotel = 0 />
		
		<cfreturn />
	</cffunction>

</cfcomponent>