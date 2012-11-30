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
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="sCabin" 		required="false"	default="Y"><!--- Options (one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable"	required="false"	default="0"><!--- Options (one item) - 0, 1 --->
		<cfargument name="nTrip"		required="false"	default="">
		<cfargument name="stAccount" 	required="false"	default="#application.stAccounts[session.Acct_ID]#">

		<cfset local.stSegment = {}>
		<cfset local.sMessage = ''>
		<cfset local.sResponse = ''>
		<cfset local.aResponse = []>
		<cfset local.stTrips = {}>
		<cfset local.stSelected = StructNew("linked")>
		<cfset stSelected[0].Segments = StructNew("linked")>
		<cfset stSelected[1].Segments = StructNew("linked")>
		<cfset stSelected[2].Segments = StructNew("linked")>
		<cfset stSelected[3].Segments = StructNew("linked")>
		<cfset local.stSegments = {}>

		<cfif arguments.nTrip EQ ''>
			<!--- Selected outbound and return then wanting a price --->
			<cfset stSelected = session.searches[arguments.nSearchID].stSelected>
		<cfelse>
			<!--- Selected the plus icon on the low fare page.  Wanting to price a given itinerary differently. --->
			<cfloop collection="#session.searches[arguments.nSearchID].stTrips[arguments.nTrip].Segments#" item="local.nSegment">
				<cfset stSegment = session.searches[arguments.nSearchID].stTrips[arguments.nTrip].Segments[nSegment]>
				<cfset stSelected[stSegment.Group].Segments[nSegment] = stSegment>
			</cfloop>
		</cfif>

		<!--- Put together the SOAP message. --->
		<cfset sMessage 	= prepareSoapHeader(arguments.stAccount, stSelected, arguments.sCabin, arguments.bRefundable)>
		<!--- Call the UAPI. --->
		<cfset sResponse 	= application.objUAPI.callUAPI('AirService', sMessage, arguments.nSearchID)>
		<!--- Format the UAPI response. --->
		<cfset aResponse 	= application.objUAPI.formatUAPIRsp(sResponse)>
		<!--- Parse the segments. --->
		<cfset stSegments	= objAirParse.parseSegments(aResponse)>
		<cfif StructIsEmpty(stSegments)>
			<cfdump eval=aResponse abort>
		</cfif>
		<!--- Parse the trips. --->
		<cfset stTrips		= objAirParse.parseTrips(aResponse, stSegments)>
		<!--- Add group node --->
		<cfset stTrips		= objAirParse.addGroups(stTrips)>
		<!--- Check low fare. --->
		<cfset stTrips 		= objAirParse.addTotalBagFare(stTrips)>
		<!--- Mark preferred carriers. --->
		<cfset stTrips		= objAirParse.addPreferred(stTrips, arguments.stAccount)>
		<!--- Create javascript structure per trip. --->
		<cfset stTrips 		= objAirParse.addJavascript(stTrips)>
		<!--- Add trip id to the list of priced items --->
		<cfset session.searches[arguments.nSearchID].stLowFareDetails.stPriced 		= addstPriced(session.searches[arguments.nSearchID].stLowFareDetails.stPriced, stTrips)>
		<!--- Merge all data into the current session structures. --->
		<cfset session.searches[arguments.nSearchID].stTrips 						= objAirParse.mergeTrips(session.searches[arguments.nSearchID].stTrips, stTrips)>
		<!--- Finish up the results --->
		<cfset void = objAirParse.finishLowFare(arguments.nSearchID)>
		<!--- Clear out their results --->
		<cfset session.searches[arguments.nSearchID].stSelected = StructNew('linked')><!--- Place holder for selected legs --->
		<cfset session.searches[arguments.nSearchID].stSelected[0] = {}>
		<cfset session.searches[arguments.nSearchID].stSelected[1] = {}>
		<cfset session.searches[arguments.nSearchID].stSelected[2] = {}>
		<cfset session.searches[arguments.nSearchID].stSelected[3] = {}>

		<cfreturn >
	</cffunction>

<!---
prepareSOAPHeader
--->
	<cffunction name="prepareSOAPHeader" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="stSelected" 	required="true">
		<cfargument name="sCabin" 		required="false"	default="Y"><!--- Options (one item) - Y, C, F --->
		<cfargument name="bRefundable"	required="false"	default="0"><!--- Options (one item) - 0, 1 --->
		
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
								<cfloop collection="#arguments.stSelected#" item="local.nGroup">
									<cfif structKeyExists(arguments.stSelected[nGroup], "Segments")>			
										<cfloop collection="#arguments.stSelected[nGroup].Segments#" item="local.nSegment">
											<cfset local.stSegment = arguments.stSelected[nGroup].Segments[nSegment]>
											<air:AirSegment
											Key="#nGroup##nSegment#T"
											Origin="#stSegment.Origin#"
											Destination="#stSegment.Destination#"
											DepartureTime="#DateFormat(stSegment.DepartureTime, 'yyyy-mm-dd')#T#TimeFormat(stSegment.DepartureTime, 'HH:mm:ss')#"
											ArrivalTime="#DateFormat(stSegment.ArrivalTime, 'yyyy-mm-dd')#T#TimeFormat(stSegment.ArrivalTime, 'HH:mm:ss')#"
											Group="#nGroup#"
											FlightNumber="#stSegment.FlightNumber#"
											Carrier="#stSegment.Carrier#"
											ProviderCode="1V">
												<air:AirAvailInfo>
													<cfloop array="#aCabins#" index="local.sCabin">
														<air:BookingCodeInfo BookingCounts="1" CabinClass="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
													</cfloop>
												</air:AirAvailInfo>
											</air:AirSegment>
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
addstPriced
--->
	<cffunction name="addstPriced" output="false">
		<cfargument name="stPriced" 	required="true">
		<cfargument name="stTrips" 	required="true">

		<cfset local.stPriced = (IsStruct(arguments.stPriced) ? arguments.stPriced : {})>
		<cfloop collection="#arguments.stTrips#" item="local.nTrip">
			<cfset local.stPriced[nTrip] = ''>
		</cfloop>

		<cfreturn local.stPriced>
	</cffunction>
	
</cfcomponent>