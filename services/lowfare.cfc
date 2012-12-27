<cfcomponent output="false">
	
<!---
init
--->
	<cffunction name="init" output="false">
		
		<cfset variables.objAirParse = CreateObject('component', 'booking.services.airparse').init()>
		
		<cfreturn this>
	</cffunction>

<!---
selectAir
--->
	<cffunction name="selectAir" output="false">
		<cfargument name="nSearchID">
		<cfargument name="nGroup">
		<cfargument name="nTrip">

		<!--- Initialize or overwrite the CouldYou air section --->
		<cfset session.searches[url.Search_ID].CouldYou.Air = {} />
		<!--- Move over the information into the stItinerary --->
		<cfset session.searches[arguments.nSearchID].stItinerary.Air = session.searches[arguments.nSearchID].stTrips[arguments.nTrip]>
		<cfset session.searches[arguments.nSearchID].stItinerary.Air.nTrip = arguments.nTrip>
		<!--- Loop through the searches structure and delete all other searches --->
		<cfloop collection="#session.searches#" index="local.nKey">
			<cfif IsNumeric(nKey) AND nKey NEQ arguments.nSearchID>
				<cfset StructDelete(session.searches, nKey)>
			</cfif>
		</cfloop>

		<cfreturn />
	</cffunction>
	
<!---
threadLowFare
--->
	<cffunction name="threadLowFare" output="false">
		<cfargument name="nSearchID"			required="true">
		<cfargument name="sPriority"			required="false"	default="HIGH">
		<cfargument name="sCabins" 				required="false"	default="X"><!--- Options (list or one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable"			required="false"	default="X"><!--- Options (list or one item) - 0, 1 --->

		<cfset local.sCabins = Replace(Replace(Replace(arguments.sCabins, 'Economy', 'Y'), 'Business', 'C'), 'First', 'F')><!--- Handles the words or codes for classes. --->
		<cfset local.aCabins = ListToArray(sCabins)>
		<cfset local.aRefundable = ListToArray(arguments.bRefundable)>
		<cfset local.stThreads = {}>
		<cfset local.sThreadName = ''>

		<!--- Create a thread for every combination of cabin, fares and PTC. --->
		<cfloop array="#aCabins#" index="local.sCabin">
			<cfloop array="#aRefundable#" index="local.bRefundable">
				<cfset sThreadName = doLowFare(arguments.nSearchID, sCabin, bRefundable, arguments.sPriority)>
				<cfset stThreads[sThreadName] = ''>
			</cfloop>
		</cfloop>

		<!--- Join only if threads where thrown out. --->
		<cfif NOT StructIsEmpty(stThreads) AND arguments.sPriority EQ 'HIGH'>
			<cfthread action="join" name="#structKeyList(stThreads)#" />
			<!--- <cfdump var="#cfthread#" abort> --->
		</cfif>

		<cfreturn >
	</cffunction>
	
<!---
doLowFare
--->
	<cffunction name="doLowFare" output="false">
		<cfargument name="nSearchID"	required="true">
		<cfargument name="sCabin" 		required="true">
		<cfargument name="bRefundable"	required="true">
		<cfargument name="sPriority"	required="true">
		<cfargument name="stPricing" 	required="false"	default="#session.searches[nSearchID].stLowFareDetails.stPricing#">
		
		<cfset local.sThreadName = ''>
		<cfset local[sThreadName] = {}>
		<!--- Don't go back to the UAPI if we already got the data. --->
		<cfif NOT StructKeyExists(arguments.stPricing, arguments.sCabin&arguments.bRefundable)>
			<!--- Name of the thread thrown out. --->
			<cfset sThreadName = arguments.sCabin&arguments.bRefundable>
			<!--- Kick off the thread. --->
			<cfthread
				action="run"
				name="#sThreadName#"
				priority="#arguments.sPriority#"
				nSearchID="#arguments.nSearchID#"
				sCabin="#arguments.sCabin#"
				bRefundable="#arguments.bRefundable#">
				<!--- <cfset thread.arguments = arguments> --->
				<!--- Put together the SOAP message. --->
				<cfset local.sMessage = 	prepareSoapHeader(arguments.nSearchID, arguments.sCabin, arguments.bRefundable)>
				<!--- Call the UAPI. --->
				<cfset local.sResponse = 	application.objUAPI.callUAPI('AirService', sMessage, arguments.nSearchID)>
				<!--- <cfdump var="#sResponse#" abort="true"> --->
				<!--- Format the UAPI response. --->
				<cfset local.aResponse = 	application.objUAPI.formatUAPIRsp(sResponse)>
				<!--- Parse the segments. --->
				<cfset local.stSegments = 	objAirParse.parseSegments(aResponse)>
				<!--- Parse the trips. --->
				<cfset local.stTrips = 		objAirParse.parseTrips(aResponse, stSegments)>
				<!--- Add group node --->
				<cfset stTrips	= 			objAirParse.addGroups(stTrips)>
				<!--- Add group node --->
				<cfset stTrips	= 			objAirParse.addPreferred(stTrips)>
				<!--- If the UAPI gives an error then add these to the thread so it is visible to the developer. --->
				<cfif StructIsEmpty(stTrips)>
					<cfset thread.aResponse = 	aResponse>
					<cfset thread.sMessage =	sMessage>
				</cfif>
				<!--- Merge all data into the current session structures. --->
				<cfset session.searches[arguments.nSearchID].stTrips = objAirParse.mergeTrips(session.searches[arguments.nSearchID].stTrips, stTrips)>
				<cfset session.searches[arguments.nSearchID].stLowFareDetails.stPricing[arguments.sCabin&arguments.bRefundable] = ''>
				<!--- Finish up the results --->
				<cfset void = objAirParse.finishLowFare(arguments.nSearchID)>
			</cfthread>
		</cfif>

		<cfreturn sThreadName>
	</cffunction>


<!---
prepareSOAPHeader
--->
	<cffunction name="prepareSOAPHeader" returntype="string" output="false">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="sCabins" 		required="true"><!--- Options (one item) - Economy, Y, Business, C, First, F (this is coded for a list but none of the calls actually send a list) --->
		<cfargument name="bRefundable"	required="true"><!--- Options (one item) - 0, 1 (this is coded for a list but none of the calls actually send a list) --->
		<cfargument name="stAccount"	required="false"	default="#application.stAccounts[session.Acct_ID]#">
		<cfargument name="stPolicy" 	required="false"	default="#application.stPolicies[session.searches[url.Search_ID].nPolicyID]#">
		
		<cfquery name="local.qSearch">
		SELECT Air_Type, Airlines, International, Depart_City, Depart_DateTime, Depart_TimeType, Arrival_City, Arrival_DateTime, Arrival_TimeType, ClassOfService
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<cfif qSearch.Air_Type EQ 'MD'>
			<cfquery name="local.qSearchLegs">
			SELECT Depart_City, Arrival_City, Depart_DateTime, Depart_TimeType
			FROM Searches_Legs
			WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
			</cfquery>
		</cfif>
		
		<cfset local.bProhibitNonRefundableFares = (arguments.bRefundable NEQ 'X' AND arguments.bRefundable ? 'true' : 'false')><!--- false = non refundable - true = refundable --->
		<cfset local.aCabins = (arguments.sCabins NEQ 'X' ? ListToArray(arguments.sCabins) : [])>
		
		<cfsavecontent variable="local.sMessage">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<air:LowFareSearchReq TargetBranch="#arguments.stAccount.sBranch#" xmlns:air="http://www.travelport.com/schema/air_v18_0" xmlns:com="http://www.travelport.com/schema/common_v15_0" AuthorizedBy="Test">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
							<air:SearchAirLeg>
								<air:SearchOrigin>
									<com:Airport Code="#qSearch.Depart_City#" />
								</air:SearchOrigin>
								<air:SearchDestination>
									<com:Airport Code="#qSearch.Arrival_City#" />
								</air:SearchDestination>
								<air:SearchDepTime PreferredTime="#DateFormat(qSearch.Depart_DateTime, 'yyyy-mm-dd')#" />
								<air:AirLegModifiers>
									<cfif NOT arrayIsEmpty(aCabins)>
										<air:PermittedCabins>
											<cfloop array="#aCabins#" index="local.sCabin">
												<air:CabinClass  Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
											</cfloop>
										</air:PermittedCabins>
									</cfif>
								</air:AirLegModifiers>
							</air:SearchAirLeg>
							<cfif qSearch.Air_Type EQ 'RT'>
								<air:SearchAirLeg>
									<air:SearchOrigin>
										<com:Airport Code="#qSearch.Arrival_City#" />
									</air:SearchOrigin>
									<air:SearchDestination>
										<com:Airport Code="#qSearch.Depart_City#" />
									</air:SearchDestination>
									<air:SearchDepTime PreferredTime="#DateFormat(qSearch.Arrival_DateTime, 'yyyy-mm-dd')#" />
									<air:AirLegModifiers>
										<cfif NOT arrayIsEmpty(aCabins)>
											<air:PermittedCabins>
												<cfloop array="#aCabins#" index="local.sCabin">
													<air:CabinClass  Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
												</cfloop>
											</air:PermittedCabins>
										</cfif>
									</air:AirLegModifiers>
								</air:SearchAirLeg>
							<cfelseif qSearch.Air_Type EQ 'MD'>
								<cfloop query="qSearchLegs">
									<air:SearchAirLeg>
										<air:SearchOrigin>
											<com:Airport Code="#qSearchLegs.Depart_City#" />
										</air:SearchOrigin>
										<air:SearchDestination>
											<com:Airport Code="#qSearchLegs.Arrival_City#" />
										</air:SearchDestination>
										<air:SearchDepTime PreferredTime="#DateFormat(qSearchLegs.Depart_DateTime, 'yyyy-mm-dd')#" />
										<air:AirLegModifiers>
											<cfif NOT arrayIsEmpty(aCabins)>
												<air:PermittedCabins>
													<cfloop array="#aCabins#" index="local.sCabin">
														<air:CabinClass  Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
													</cfloop>
												</air:PermittedCabins>
											</cfif>
										</air:AirLegModifiers>
									</air:SearchAirLeg>
								</cfloop>
							</cfif>
							<air:AirSearchModifiers DistanceType="MI" IncludeFlightDetails="false" RequireSingleCarrier="false" AllowChangeOfAirport="false" ProhibitOvernightLayovers="true" MaxConnections="1" MaxStops="1" ProhibitMultiAirportConnection="true" PreferNonStop="true">
								<air:ProhibitedCarriers>
									<com:Carrier Code="ZK"/>
									<com:Carrier Code="SY"/>
									<com:Carrier Code="NK"/>
									<com:Carrier Code="G4"/>
								</air:ProhibitedCarriers>
							</air:AirSearchModifiers>
							<com:SearchPassenger Code="ADT" />
							<air:AirPricingModifiers ProhibitNonRefundableFares="#bProhibitNonRefundableFares#" FaresIndicator="PublicAndPrivateFares" ProhibitMinStayFares="false" ProhibitMaxStayFares="false" CurrencyType="USD" ProhibitAdvancePurchaseFares="false" ProhibitRestrictedFares="false" ETicketability="Required" ProhibitNonExchangeableFares="false" ForceSegmentSelect="false">
								<cfif NOT ArrayIsEmpty(arguments.stAccount.Air_PF)>
									<air:AccountCodes>
										<cfloop array="#arguments.stAccount.Air_PF#" index="local.sPF">
											<com:AccountCode Code="#GetToken(sPF, 3, ',')#" ProviderCode="1V" SupplierCode="#GetToken(sPF, 2, ',')#" />
										</cfloop>
									</air:AccountCodes>
								</cfif>
							</air:AirPricingModifiers>
							<com:PointOfSale ProviderCode="1V" PseudoCityCode="#arguments.stAccount.PCC_Booking#" />
						</air:LowFareSearchReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn sMessage/>
	</cffunction>

</cfcomponent>