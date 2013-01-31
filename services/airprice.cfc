<cfcomponent output="false">
	
<!---
init
--->
	<cffunction name="init" output="false">
		
		<cfset variables.objAirParse = CreateObject('component', 'booking.services.airparse').init()>
		
		<cfreturn this>
	</cffunction>
	
<!---
doAirPrice
--->
	<cffunction name="doAirPrice" output="false">
		<cfargument name="SearchID" 	required="true">
		<cfargument name="Account"      required="true">
		<cfargument name="sCabin" 		required="false"	default="Y"><!--- Options (one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable"	required="false"	default="0"><!--- Options (one item) - 0, 1 --->
		<cfargument name="nTrip"		required="false"	default="">
		<cfargument name="nCouldYou"	required="false"	default="0">
		<cfargument name="bSaveAirPrice"required="false"	default="0">

		<cfset local.stSegment = {}>
		<cfset local.sMessage = ''>
		<cfset local.sResponse = ''>
		<cfset local.aResponse = []>
		<cfset local.stTrips = {}>
		<cfset local.stSelected = StructNew("linked")>
		<cfset stSelected[0].Groups = StructNew("linked")>
		<cfset stSelected[1].Groups = StructNew("linked")>
		<cfset stSelected[2].Groups = StructNew("linked")>
		<cfset stSelected[3].Groups = StructNew("linked")>
		<cfset local.stSegments = {}>
		<cfset local.nTripKey = ''>

		<cfif arguments.nTrip EQ ''>
			<!--- Selected outbound and return then wanting a price --->
			<cfset stSelected = session.searches[arguments.SearchID].stSelected>
		<cfelse>
			<cfloop collection="#session.searches[arguments.SearchID].stTrips[arguments.nTrip].Groups#" item="local.Group">
				<cfset stSelected[Group].Groups[0] = session.searches[arguments.SearchID].stTrips[arguments.nTrip].Groups[Group]>
			</cfloop>
		</cfif>

		<!--- Put together the SOAP message. --->
		<cfset sMessage 	= prepareSoapHeader(stSelected, arguments.sCabin, arguments.bRefundable, arguments.nCouldYou)>
		<!--- Call the UAPI. --->
		<cfset sResponse 	= application.objUAPI.callUAPI('AirService', sMessage, arguments.SearchID)>
		<!--- Format the UAPI response. --->
		<cfset aResponse 	= application.objUAPI.formatUAPIRsp(sResponse)>
		
		<!--- <cfdump var="#aResponse#"> --->

		<!--- THIS IS BAD. I NEEDED IT FOR COULD YOU --->
		<!--- <cfset variables.objAirParse = CreateObject('component', 'booking.services.airparse').init()> --->
		<!--- THIS IS BAD. I NEEDED IT FOR COULD YOU --->

		<cfif arguments.nCouldYou EQ 0>
			<!--- Parse the segments. --->
			<cfset stSegments	= objAirParse.parseSegments(aResponse)>
			<cfif NOT StructIsEmpty(stSegments)>
				<!--- Parse the trips. --->
				<cfset stTrips		= objAirParse.parseTrips(aResponse, stSegments)>
				<!--- Add group node --->
				<cfset stTrips		= objAirParse.addGroups(stTrips)>
				<!--- Check low fare. --->
				<cfset stTrips 		= objAirParse.addTotalBagFare(stTrips)>
				<!--- Mark preferred carriers. --->
				<cfset stTrips		= objAirParse.addPreferred(stTrips, arguments.Account)>
				<!--- Add trip id to the list of priced items --->
				<cfset nTripKey		= getTripKey(stTrips)>
				<!--- Save XML if needed - aircreate --->
				<cfif arguments.bSaveAirPrice>
					<cfset stTrips[nTripKey].sXML = sResponse>
				</cfif>	
				<cfif arguments.nCouldYou EQ 0>
					<!--- Add trip id to the list of priced items --->
					<cfset session.searches[arguments.SearchID].stLowFareDetails.stPriced 		= addstPriced(session.searches[arguments.SearchID].stLowFareDetails.stPriced, nTripKey)>
					<!--- Merge all data into the current session structures. --->
					<cfset session.searches[arguments.SearchID].stTrips 						= objAirParse.mergeTrips(session.searches[arguments.SearchID].stTrips, stTrips)>
					<!--- Finish up the results --->
					<cfset void = objAirParse.finishLowFare(arguments.SearchID)>
					<!--- <cfdump var="#session.searches[arguments.SearchID].stTrips#" abort> --->
					<!--- Clear out their results --->
					<cfif arguments.sCabin NEQ stTrips[nTripKey].Class>
						<cfset session.searches[arguments.SearchID].sUserMessage = 'Pricing returned '&(stTrips[nTripKey].Class EQ 'Y' ? 'economy' : (stTrips[nTripKey].Class EQ 'C' ? 'business' : 'first'))&' class instead of '&(arguments.sCabin EQ 'Y' ? 'economy' : (arguments.sCabin EQ 'C' ? 'business' : 'first'))&'.'>
					</cfif>
				</cfif>
			<cfelse>
				<cfset session.searches[arguments.SearchID].sUserMessage = 'Fare type selected is unavailable for pricing.'>
			</cfif>

			<cfset session.searches[arguments.SearchID].stSelected = StructNew('linked')><!--- Place holder for selected legs --->
			<cfset session.searches[arguments.SearchID].stSelected[0] = {}>
			<cfset session.searches[arguments.SearchID].stSelected[1] = {}>
			<cfset session.searches[arguments.SearchID].stSelected[2] = {}>
			<cfset session.searches[arguments.SearchID].stSelected[3] = {}>
		<cfelse>
			<cfset nTripKey = aResponse />	
		</cfif>

		<cfreturn nTripKey>
	</cffunction>

<!---
prepareSOAPHeader
--->
	<cffunction name="prepareSOAPHeader" returntype="string" output="false">
		<cfargument name="stSelected" 	required="true">
		<cfargument name="sCabin" 		required="false"	default="Y"><!--- Options (one item) - Y, C, F --->
		<cfargument name="bRefundable"	required="false"	default="0"><!--- Options (one item) - 0, 1 --->
		<cfargument name="nCouldYou"	required="false"	default="0"><!--- Options (one item) - 0, 1 --->
		<cfargument name="stAccount" 	required="true"		default="#application.Accounts[session.AcctID]#">
		
		<cfset local.ProhibitNonRefundableFares = (arguments.bRefundable EQ 0 ? 'false' : 'true')><!--- false = non refundable - true = refundable --->
		<cfset local.aCabins = ListToArray(arguments.sCabin)>
		
		<cfsavecontent variable="local.sMessage">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<air:AirPriceReq TargetBranch="#arguments.stAccount.sBranch#" xmlns:air="http://www.travelport.com/schema/air_v18_0" xmlns:com="http://www.travelport.com/schema/common_v15_0">
							<com:BillingPointOfSaleInfo OriginApplication="uAPI"/>
							<air:AirItinerary>
								<cfset local.nCount = 0>
								<cfloop collection="#arguments.stSelected#" item="local.Group">
									<cfif structKeyExists(arguments.stSelected[Group], "Groups")>
										<cfloop collection="#arguments.stSelected[Group].Groups#" item="local.nInnerGroup">
											<cfloop collection="#arguments.stSelected[Group].Groups[nInnerGroup].Segments#" item="local.nSegment">
												<cfset nCount++>
												<cfset local.stSegment = arguments.stSelected[Group].Groups[nInnerGroup].Segments[nSegment]>
												<air:AirSegment
												Key="#nCount#T"
												Origin="#stSegment.Origin#"
												Destination="#stSegment.Destination#"
												DepartureTime="#DateFormat(DateAdd('d', arguments.nCouldYou, stSegment.DepartureTime), 'yyyy-mm-dd')#T#TimeFormat(stSegment.DepartureTime, 'HH:mm:ss')#"
												ArrivalTime="#DateFormat(DateAdd('d', arguments.nCouldYou, stSegment.ArrivalTime), 'yyyy-mm-dd')#T#TimeFormat(stSegment.ArrivalTime, 'HH:mm:ss')#"
												Group="#Group#"
												FlightNumber="#stSegment.FlightNumber#"
												Carrier="#stSegment.Carrier#"
												ProviderCode="1V" />
											</cfloop>
										</cfloop>
									</cfif>
								</cfloop>
							</air:AirItinerary>
							<air:AirPricingModifiers
							ProhibitNonRefundableFares="#ProhibitNonRefundableFares#"
							FaresIndicator="PublicAndPrivateFares"
							ProhibitMinStayFares="false"
							ProhibitMaxStayFares="false"
							CurrencyType="USD"
							ProhibitAdvancePurchaseFares="false"
							ProhibitRestrictedFares="false"
							ETicketability="Required"
							ProhibitNonExchangeableFares="false"
							ForceSegmentSelect="false">
								<cfif NOT ArrayIsEmpty(arguments.stAccount.Air_PF)>
									<air:AccountCodes>
										<cfloop array="#arguments.stAccount.Air_PF#" index="local.sPF">
											<com:AccountCode Code="#GetToken(sPF, 3, ',')#" ProviderCode="1V" SupplierCode="#GetToken(sPF, 2, ',')#" />
										</cfloop>
									</air:AccountCodes>
								</cfif>
								<air:PermittedCabins>
									<cfloop array="#aCabins#" index="local.sCabin">
										<air:CabinClass Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
									</cfloop>
								</air:PermittedCabins>
							</air:AirPricingModifiers>
							<com:SearchPassenger PricePTCOnly="false" Code="ADT"/>
							<air:AirPricingCommand/>
						</air:AirPriceReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>

		<cfreturn sMessage/>
	</cffunction>
	
<!---
getTripKey
--->
	<cffunction name="getTripKey" output="false">
		<cfargument name="stTrips" 	required="true">

		<cfset local.nTripKey = ''>
		<cfloop collection="#arguments.stTrips#" item="local.nTrip">
			<cfset nTripKey = nTrip>
		</cfloop>

		<cfreturn nTripKey>
	</cffunction>
	
<!---
addstPriced
--->
	<cffunction name="addstPriced" output="false">
		<cfargument name="stPriced" 	required="true">
		<cfargument name="nTripKey" 	required="true">

		<cfset local.stPriced = (IsStruct(arguments.stPriced) ? arguments.stPriced : {})>
		<cfset local.stPriced[arguments.nTripKey] = ''>

		<cfreturn local.stPriced>
	</cffunction>
	
</cfcomponent>