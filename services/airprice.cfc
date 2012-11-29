<cfcomponent output="false">
	
<!---
doAirPrice
--->
	<cffunction name="doAirPrice" output="false">
		<cfargument name="objUAPI"		required="true">
		<cfargument name="objAirParse"	required="true">
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
		<cfset sResponse 	= arguments.objUAPI.callUAPI('AirService', sMessage, arguments.nSearchID)>
		<!--- Format the UAPI response. --->
		<cfset aResponse 	= arguments.objUAPI.formatUAPIRsp(sResponse)>
		<cfdump eval=aResponse>
		<!--- Parse the segments. --->
		<cfset stSegments	= arguments.objAirParse.parseSegments(aResponse)>
		<cfif StructIsEmpty(stSegments)>
			<cfdump eval=aResponse abort>
		</cfif>
		<!--- Parse the trips. --->
		<cfset stTrips		= arguments.objAirParse.parseTrips(aResponse, stSegments)>
		<!--- Add group node --->
		<cfset stTrips		= arguments.objAirParse.addGroups(stTrips)>
		<!--- Check low fare. --->
		<cfset stTrips 		= arguments.objAirParse.addTotalBagFare(stTrips)>
		<!--- Mark preferred carriers. --->
		<cfset stTrips		= arguments.objAirParse.addPreferred(stTrips, arguments.stAccount)>
		<!--- Create javascript structure per trip. --->
		<cfset stTrips 		= arguments.objAirParse.addJavascript(stTrips)>
		<cfdump eval=stTrips>
		<!--- Add trip id to the list of priced items --->
		<cfset session.searches[arguments.nSearchID].stLowFareDetails.aPriced 		= addaPriced(session.searches[arguments.nSearchID].stLowFareDetails.aPriced, stTrips)>
		<!--- Merge all data into the current session structures. --->
		<cfset session.searches[arguments.nSearchID].stTrips 						= arguments.objAirParse.mergeTrips(session.searches[arguments.nSearchID].stTrips, stTrips)>

		<!--- Finish up the results --->
		<cfset stTrips = arguments.objAirParse.finishLowFare(arguments.nSearchID)>

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
addaPriced
--->
	<cffunction name="addaPriced" output="false">
		<cfargument name="aPriced" 	required="true">
		<cfargument name="stTrips" 	required="true">

		<cfset local.aPriced = (IsStruct(arguments.aPriced) ? arguments.aPriced : [])>
		<cfloop collection="#arguments.stTrips#" item="local.nTrip">
			<cfset ArrayAppend(local.aPriced, nTrip)>
		</cfloop>

		<cfreturn local.aPriced>
	</cffunction>
	
</cfcomponent>