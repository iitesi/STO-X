<cfcomponent output="false" accessors="true">

	<cfproperty name="UAPI">
	<cfproperty name="AirParse">

<!---
init
--->
	<cffunction name="init" output="false">
		<cfargument name="UAPI">
		<cfargument name="AirParse">

		<cfset setUAPI(arguments.UAPI)>
		<cfset setAirParse(arguments.AirParse)>
		
		<cfreturn this>
	</cffunction>
	
<!---
threadLowFare
--->
	<cffunction name="threadLowFare" output="false">
		<cfargument name="sPriority"		required="false"	default="HIGH">
		<cfargument name="sCabins" 			required="false"	default="X"><!--- Options (list or one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable"		required="false"	default="X"><!--- Options (list or one item) - 0, 1 --->
		<cfargument name="Filter"			required="false"	default="X"><!--- Options (list or one item) - 0, 1 --->
		<cfargument name="stPricing" 		required="true">

		<cfset local.sCabins = Replace(Replace(Replace(arguments.sCabins, 'Economy', 'Y'), 'Business', 'C'), 'First', 'F')><!--- Handles the words or codes for classes. --->
		<cfset local.aCabins = ListToArray(sCabins)>
		<cfset local.aRefundable = ListToArray(arguments.bRefundable)>
		<cfset local.stThreads = {}>
		<cfset local.sThreadName = ''>

		<!--- Create a thread for every combination of cabin, fares and PTC. --->
		<cfloop array="#aCabins#" index="local.sCabin">
			<cfloop array="#aRefundable#" index="local.bRefundable">
				<cfset sThreadName = doLowFare(arguments.Filter, sCabin, bRefundable, arguments.sPriority, arguments.stPricing, arguments.Account, arguments.Policy)>
				<cfset stThreads[sThreadName] = ''>
			</cfloop>
		</cfloop>

		<!--- Join only if threads where thrown out. --->
		<cfif NOT StructIsEmpty(stThreads) AND arguments.sPriority EQ 'HIGH'>
			<cfthread action="join" name="#structKeyList(stThreads)#" />
			<!---<cfdump var="#cfthread#" abort>--->
			<!--- If sMessage is defined then no results pulled back.  cfdump for dev purposes only. --->
			<!--- <cfloop collection="#cfthread#" index="local.sKey">
				<cfif structKeyExists(cfthread[sKey], 'sMessage')>
					<cfdump var="#cfthread[sKey]#" abort>
				</cfif>
			</cfloop> --->
		</cfif>
		<!--- <cfdump var="#session.searches[arguments.SearchID].stTrips#" abort> --->
	
		<cfreturn >
	</cffunction>
	
<!---
doLowFare
--->
	<cffunction name="doLowFare" output="false">
		<cfargument name="Filter"		required="true">
		<cfargument name="sCabin" 		required="true">
		<cfargument name="bRefundable"	required="true">
		<cfargument name="sPriority"	required="true">
		<cfargument name="stPricing" 	required="true">
		<cfargument name="Account"      required="true">
		<cfargument name="Policy"       required="true">
		<cfargument name="sLowFareSearchID"	required="false"	default="">
		
		<cfset local.sThreadName = ''>
		<!---<cfset arguments.stPricing = {}>--->
		<!--- Don't go back to the UAPI if we already got the data. --->
		<cfif NOT StructKeyExists(arguments.stPricing, arguments.sCabin&arguments.bRefundable)>
			<!--- Name of the thread thrown out. --->
			<cfset sThreadName = arguments.sCabin&arguments.bRefundable>
			<cfset local[sThreadName] = {}>
			<!--- Kick off the thread. --->
			<cfthread
				action="run"
				name="#sThreadName#"
				priority="#arguments.sPriority#"
				Filter="#arguments.Filter#"
				sCabin="#arguments.sCabin#"
				Account="#arguments.Account#"
				Policy="#arguments.Policy#"
				bRefundable="#arguments.bRefundable#">
				<!--- <cfset thread.arguments = arguments> --->
				<!--- Put together the SOAP message. --->
				<cfset sMessage 	= prepareSoapHeader(arguments.Filter, arguments.sCabin, arguments.bRefundable, '', arguments.Account)>
				<!--- <cfdump var="#sMessage#" abort> --->
				<!--- Call the UAPI. --->
				<cfset sResponse 	= getUAPI().callUAPI('AirService', sMessage, arguments.Filter.getSearchID())>
				<!---<cfdump var="#sResponse#" abort>--->
				<!--- Get the next reference key --->
				<!---<cfset thread.sLowFareSearchID = getAirParse().parseSearchID(sResponse)>--->
				<!--- <cfdump var="#sLowFareSearchID#" abort> --->
				<!--- <cfdump var="#sResponse#"> --->
				<!--- Format the UAPI response. --->
				<cfset aResponse 	= getUAPI().formatUAPIRsp(sResponse)>
				<!---<cfdump var="#aResponse#" abort>--->
				<!--- Parse the segments. --->
				<cfset stSegments 	= getAirParse().parseSegments(aResponse)>
				<!--- Parse the trips. --->
				<cfset stTrips 		= getAirParse().parseTrips(aResponse, stSegments)>
				<!--- Add group node --->
				<cfset stTrips 		= getAirParse().addGroups(stTrips)>
				<!--- Add group node --->
				<cfset stTrips 		= getAirParse().addPreferred(stTrips, arguments.Account)>
				<!--- If the UAPI gives an error then add these to the thread so it is visible to the developer. --->
				<cfif NOT StructIsEmpty(stTrips)>
					<!--- Merge all data into the current session structures. --->
					<cfset session.searches[arguments.Filter.getSearchID()].stTrips = getAirParse().mergeTrips(session.searches[arguments.Filter.getSearchID()].stTrips, stTrips)>
					<!---<cfset session.searches[arguments.SearchID].stLowFareDetails.stPricing[arguments.sCabin&arguments.bRefundable] = ''>--->
					<!--- Finish up the results --->
					<cfset void = getAirParse().finishLowFare(arguments.Filter.getSearchID(), arguments.Account, arguments.Policy)>
				<cfelse>
					<cfset thread.aResponse = aResponse>
					<cfset thread.sMessage = sMessage>
				</cfif>
				<cfset thread.sMessage = sMessage>
				<cfset thread.stTrips =	session.searches[arguments.Filter.getSearchID()].stTrips>
			</cfthread>
		</cfif>

		<cfreturn sThreadName>
	</cffunction>


<!---
prepareSOAPHeader
--->
	<cffunction name="prepareSOAPHeader" returntype="string" output="false">
		<cfargument name="Filter"		    required="true">
		<cfargument name="sCabins" 			required="true"><!--- Options (one item) - Economy, Y, Business, C, First, F (this is coded for a list but none of the calls actually send a list) --->
		<cfargument name="bRefundable"		required="true"><!--- Options (one item) - 0, 1 (this is coded for a list but none of the calls actually send a list) --->
		<cfargument name="sLowFareSearchID"	required="false"	default="">
		<cfargument name="Account"			required="false"	default="">

		<cfif arguments.Filter.getAirType() EQ 'MD'>
			<cfquery name="local.qSearchLegs">
			SELECT Depart_City, Arrival_City, Depart_DateTime, Depart_TimeType
			FROM Searches_Legs
			WHERE Search_ID = <cfqueryparam value="#arguments.Filter.getSearchID()#" cfsqltype="cf_sql_numeric" />
			ORDER BY Depart_DateTime
			</cfquery>
		</cfif>
		
		<cfset local.bProhibitNonRefundableFares = (arguments.bRefundable NEQ 'X' AND arguments.bRefundable ? 'true' : 'false')><!--- false = non refundable - true = refundable --->
		<cfset local.aCabins = (arguments.sCabins NEQ 'X' ? ListToArray(arguments.sCabins) : [])>
		<cfdump var="#arguments.filter#">
		<cfsavecontent variable="local.sMessage">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<cfif arguments.sLowFareSearchID EQ ''>
							<air:LowFareSearchReq TargetBranch="#arguments.Account.sBranch#" xmlns:air="http://www.travelport.com/schema/air_v18_0" xmlns:com="http://www.travelport.com/schema/common_v15_0" AuthorizedBy="Test">
								<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
								<cfif arguments.Filter.getAirType() EQ 'RT'
								OR arguments.Filter.getAirType() EQ 'OW'>
									<air:SearchAirLeg>
										<air:SearchOrigin>
											<com:Airport Code="#arguments.Filter.getDepartCity()#" />
										</air:SearchOrigin>
										<air:SearchDestination>
											<com:Airport Code="#arguments.Filter.getArrivalCity()#" />
										</air:SearchDestination>
										<air:SearchDepTime PreferredTime="#DateFormat(arguments.Filter.getDepartDateTime(), 'yyyy-mm-dd')#" />
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
								</cfif>
								<cfif arguments.Filter.getAirType() EQ 'RT'>
									<air:SearchAirLeg>
										<air:SearchOrigin>
											<com:Airport Code="#arguments.Filter.getArrivalCity()#" />
										</air:SearchOrigin>
										<air:SearchDestination>
											<com:Airport Code="#arguments.Filter.getDepartCity()#" />
										</air:SearchDestination>
										<air:SearchDepTime PreferredTime="#DateFormat(arguments.Filter.getArrivalDateTime(), 'yyyy-mm-dd')#" />
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
								<cfelseif arguments.Filter.getAirType() EQ 'MD'>
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
									<!---TODO <cfif NOT ArrayIsEmpty(arguments.stAccount.Air_PF)>
										<air:AccountCodes>
											<cfloop array="#arguments.stAccount.Air_PF#" index="local.sPF">
												<com:AccountCode Code="#GetToken(sPF, 3, ',')#" ProviderCode="1V" SupplierCode="#GetToken(sPF, 2, ',')#" />
											</cfloop>
										</air:AccountCodes>
									</cfif>--->
								</air:AirPricingModifiers>
								<com:PointOfSale ProviderCode="1V" PseudoCityCode="1M98" /><!---TODO #arguments.stAccount.PCC_Booking#--->
							</air:LowFareSearchReq>
						<cfelse>
							<air:RetrieveLowFareSearchReq TargetBranch="#arguments.stAccount.sBranch#" SearchId="#arguments.sLowFareSearchID#" ProviderCode="1V" PartNumber="1">
								<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
							</air:RetrieveLowFareSearchReq>
						</cfif>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn sMessage/>
	</cffunction>

<!---
selectAir
--->
	<cffunction name="selectAir" output="false">
		<cfargument name="SearchID">
		<cfargument name="Group">
		<cfargument name="nTrip">

<!--- Initialize or overwrite the CouldYou air section --->
		<cfset session.searches[arguments.SearchID].CouldYou.Air = {} />
		<cfset session.searches[arguments.SearchID]['Air'] = true />
<!--- Move over the information into the stItinerary --->
		<cfset session.searches[arguments.SearchID].stItinerary.Air = session.searches[arguments.SearchID].stTrips[arguments.nTrip]>
		<cfset session.searches[arguments.SearchID].stItinerary.Air.nTrip = arguments.nTrip>
<!--- Loop through the searches structure and delete all other searches --->
		<cfloop collection="#session.searches#" index="local.nKey">
			<cfif IsNumeric(nKey) AND nKey NEQ arguments.SearchID>
				<cfset StructDelete(session.searches, nKey)>
			</cfif>
		</cfloop>

		<cfreturn />
	</cffunction>

</cfcomponent>