<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="UAPIFactory" />
	<cfproperty name="uAPISchemas" />
	<cfproperty name="AirParse" />
	<cfproperty name="AirAdapter" />

    <cffunction name="init" access="public" output="false" returntype="any" hint="I initialize this component" >
    	<cfargument name="UAPIFactory" type="any" required="true" />
    	<cfargument name="uAPISchemas" type="any" required="true" />
    	<cfargument name="AirParse" type="any" required="false" default="" />
    	<cfargument name="AirAdapter" type="any" required="false" default="" />

    	<cfset setUAPIFactory( arguments.UAPIFactory ) />
    	<cfset setUAPISchemas( arguments.uAPISchemas ) />
    	<cfset setAirParse( arguments.AirParse ) />
    	<cfset setAirAdapter( arguments.AirAdapter ) />

      <cfreturn this />

     </cffunction>

	<cffunction name="doAirPrice" output="false">
		<cfargument name="SearchID" required="true">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="sCabin" required="false" default="Y"><!--- Options (one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable" required="false" default="0"><!--- Options (one item) - 0, 1 --->
		<cfargument name="bRestricted" required="false" default="0"><!--- Options (one item) - 0, 1 --->
		<cfargument name="sFaresIndicator" required="false" default="PublicAndPrivateFares"><!--- Options (one item) - PublicAndPrivateFares, PublicFaresOnly --->
		<cfargument name="bAccountCodes" required="false" default="1"><!--- Options (one item) - 0, 1 --->
		<cfargument name="nTrip" required="false" default="">
		<cfargument name="nCouldYou" required="false" default="0">
		<cfargument name="bSaveAirPrice" required="false" default="0">
		<cfargument name="stSelected" required="false" default="">
		<cfargument name="findIt" required="false" default="0">
		<cfargument name="bIncludeClass" required="false" default="0"><!--- Options (one item) - 0, 1 --->

		<cfset local.stSegment = {}>
		<cfset local.sMessage = ''>
		<cfset local.sResponse = ''>
		<cfset local.aResponse = []>
		<cfset local.stTrips = {}>
		<cfset local.stSelected = StructNew("linked")>
		<cfset local.stSelected[0].Groups = StructNew("linked")>
		<cfset local.stSelected[1].Groups = StructNew("linked")>
		<cfset local.stSelected[2].Groups = StructNew("linked")>
		<cfset local.stSelected[3].Groups = StructNew("linked")>
		<cfset local.stSegments = {}>
		<cfset local.nTripKey = ''>
		<cfset local.TotalFare = 0>

		<cfif arguments.nTrip EQ ''
			AND NOT isStruct(arguments.stSelected)>
			<!--- Selected outbound and return then wanting a price --->
			<cfset local.stSelected = session.searches[arguments.SearchID].stSelected>
		<cfelseif NOT isStruct(arguments.stSelected)>
			<cfloop collection="#session.searches[arguments.SearchID].stTrips[arguments.nTrip].Groups#" item="local.Group">
				<cfset local.stSelected[Group].Groups[0] = session.searches[arguments.SearchID].stTrips[arguments.nTrip].Groups[Group]>
			</cfloop>
		<cfelseif isStruct(arguments.stSelected)>
			<cfset local.stSelected = arguments.stSelected>
		</cfif>

		<!--- Put together the SOAP message. --->
		<cfset local.sMessage = prepareSoapHeader( stSelected = local.stSelected
											, sCabin = arguments.sCabin
											, bRefundable = arguments.bRefundable
											, bRestricted = arguments.bRestricted
											, sFaresIndicator = arguments.sFaresIndicator
											, bAccountCodes = arguments.bAccountCodes
											, nCouldYou = arguments.nCouldYou
											, stAccount = arguments.Account
											, findIt = arguments.findIt
											, bIncludeClass = arguments.bIncludeClass )>
		<!--- Call the UAPI. --->
		<cfset local.sResponse 	= getUAPI().callUAPI('AirService', local.sMessage, arguments.SearchID)>
		<!--- <cfdump var="#sResponse#" abort> --->
		<!--- Format the UAPI response. --->
		<cfset local.aResponse 	= getUAPI().formatUAPIRsp(local.sResponse)>
		<!--- Parse the segments. --->
		<cfset local.stSegments	= AirParse.parseSegments(local.aResponse)>

		<!--- Add faultstring if it exists so we can parse in findIt (STM-2903) --->
		<cfif FindNoCase('faultstring', local.sResponse) NEQ 0>
			<cfset local.faultstring = ''>
			<cfloop array="#local.aResponse#" item="local.faultItem">
				<cfif faultItem.XMLName EQ 'faultstring'>
					<cfset local.faultstring = faultItem.xmlText>
				</cfif>
			</cfloop>
			<cfset local.stTrips.faultMessage = local.faultstring>
		</cfif>

		<cfif NOT StructIsEmpty(local.stSegments)>
			<!--- Parse the trips. --->
			<cfset local.stTrips = AirParse.parseTrips(local.aResponse, local.stSegments)>
			<!--- Add group node --->
			<cfset local.stTrips = AirParse.addGroups(local.stTrips)>
			<!--- Check low fare. --->
			<cfset local.stTrips = AirParse.addTotalBagFare(local.stTrips)>
			<!--- Mark preferred carriers. --->
			<cfset local.stTrips = AirParse.addPreferred(local.stTrips, arguments.Account)>
			<!--- Calculate total trip time--->
			<cfloop collection="#local.stTrips#" item="local.tripKey">
				<cfset local.trip = local.stTrips[ local.tripKey ]/>
				<cfloop collection="#trip.groups#" item="local.group">
					<cfset local.group = local.trip.groups[ local.group ] />
					<cfset local.tripDuration = AirParse.calculateTripTime( local.group.segments ) />
					<cfloop collection="#local.group.segments#" item="local.segment">
						<cfset local.group.segments[ local.segment ].traveltime = local.tripDuration />
					</cfloop>
					<cfset local.group.TravelTime = int( local.tripDuration / 60 ) & 'h' & ' ' & local.tripDuration MOD 60 & 'm' />
				</cfloop>
			</cfloop>
			<!--- Add trip id to the list of priced items --->
			<cfset local.nTripKey = getTripKey(local.stTrips)>
			<cfset local.stTrips[local.nTripKey].nTrip = local.nTripKey>
			<!--- Save XML if needed - AirCreate --->
			<cfif arguments.bSaveAirPrice>
				<cfset local.stTrips[local.nTripKey].sXML = local.sResponse>
				<cfset local.stTrips[local.nTripKey].PricingSolution = AirAdapter.parsePricingSolution( response = local.sResponse )>
			</cfif>
			<cfif arguments.nCouldYou EQ 0>
				<!--- Add trip id to the list of priced items --->
				<cfset session.searches[arguments.SearchID].stLowFareDetails.stPriced = addstPriced(session.searches[arguments.SearchID].stLowFareDetails.stPriced, local.nTripKey)>
				<!--- Merge all data into the current session structures. --->
				<cfset session.searches[arguments.SearchID].stTrips = AirParse.mergeTrips(session.searches[arguments.SearchID].stTrips, local.stTrips)>
				<!--- Finish up the results --->
				<cfset local.void = AirParse.finishLowFare(arguments.SearchID, arguments.Account, arguments.Policy)>
				<!--- Clear out their results --->
				<cfif arguments.sCabin NEQ local.stTrips[local.nTripKey].Class>
					<cfset session.searches[arguments.SearchID].sUserMessage = 'Pricing returned '&(local.stTrips[local.nTripKey].Class EQ 'Y' ? 'economy' : (local.stTrips[local.nTripKey].Class EQ 'C' ? 'business' : 'first'))&' class instead of '&(arguments.sCabin EQ 'Y' ? 'economy' : (arguments.sCabin EQ 'C' ? 'business' : 'first'))&'.'>
				</cfif>
			<cfelse>
				<cfset local.TotalFare = local.stTrips[local.nTripKey].Total>
			</cfif>
		<cfelse>
			<cfset session.searches[arguments.SearchID].sUserMessage = 'Fare type selected is unavailable for pricing.'>
		</cfif>

		<cfreturn local.stTrips>
	</cffunction>

	<cffunction name="prepareSOAPHeader" returntype="string" output="false">
		<cfargument name="stSelected" required="true">
		<cfargument name="sCabin" required="false" default="Y"><!--- Options (one item) - Y, C, F --->
		<cfargument name="bRefundable" required="false" default="0"><!--- Options (one item) - 0, 1 --->
		<cfargument name="bRestricted" required="false" default="0"><!--- Options (one item) - 0, 1 --->
		<cfargument name="sFaresIndicator" required="false" default="PublicAndPrivateFares"><!--- Options (one item) - PublicAndPrivateFares, PublicFaresOnly --->
		<cfargument name="bAccountCodes" required="false" default="1"><!--- Options (one item) - 0, 1 --->
		<cfargument name="nCouldYou" required="false" default="0"><!--- Options (one item) - 0, 1 --->
		<cfargument name="stAccount" required="true">
		<cfargument name="findIt" required="true">
		<cfargument name="bIncludeClass" required="false" default="0"><!--- Options (one item) - 0, 1 --->

		<cfset local.ProhibitNonRefundableFares = (arguments.bRefundable EQ 0 OR arguments.findIt EQ 1 ? 'false' : 'true')><!--- false = non refundable - true = refundable --->
		<cfset local.ProhibitRestrictedFares = (arguments.bRestricted EQ 0 OR arguments.findIt EQ 1 ? 'false' : 'true')><!--- false = unrestricted - true = restricted --->
		<cfset local.aCabins = ListToArray(arguments.sCabin)>

		<!--- Code needs to be reworked and put in a better location --->
		<cfset local.targetBranch = arguments.stAccount.sBranch>
		<cfif arguments.stAccount.Acct_ID EQ 254
			OR arguments.stAccount.Acct_ID EQ 255>
			<cfset local.targetBranch = 'P1601396'>
		</cfif>

		<cfsavecontent variable="local.sMessage">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<air:AirPriceReq xmlns:air="#getUAPISchemas().air#" xmlns:com="#getUAPISchemas().common#" TargetBranch="#targetBranch#">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI"/>
							<air:AirItinerary>
								<cfset local.nCount = 0>
								<cfset local.carriers = []>
								<cfloop collection="#arguments.stSelected#" item="local.stGroup" index="local.nGroup">
									<cfif structKeyExists(local.stGroup, "Groups")>
										<cfloop collection="#local.stGroup.Groups#" item="local.stInnerGroup" index="local.nInnerGroup">
											<cfloop collection="#local.stInnerGroup.Segments#" item="local.stSegment" index="local.nSegment">
												<cfif NOT arrayFind(local.carriers, local.stSegment.Carrier)>
													<cfset arrayAppend(local.carriers, local.stSegment.Carrier)>
												</cfif>
												<cfset local.nCount++>
												<cfif arguments.bIncludeClass>
													<air:AirSegment Key="#local.nCount#T" Origin="#local.stSegment.Origin#" Destination="#local.stSegment.Destination#" DepartureTime="#DateFormat(DateAdd('d', arguments.nCouldYou, local.stSegment.DepartureTime), 'yyyy-mm-dd')#T#TimeFormat(local.stSegment.DepartureTime, 'HH:mm:ss')#" ArrivalTime="#DateFormat(DateAdd('d', arguments.nCouldYou, local.stSegment.ArrivalTime), 'yyyy-mm-dd')#T#TimeFormat(local.stSegment.ArrivalTime, 'HH:mm:ss')#" Group="#local.nGroup#" FlightNumber="#local.stSegment.FlightNumber#" Carrier="#local.stSegment.Carrier#" ProviderCode="1V" ClassOfService="#local.stSegment.Class#" />
												<cfelse>
													<air:AirSegment Key="#local.nCount#T" Origin="#local.stSegment.Origin#" Destination="#local.stSegment.Destination#" DepartureTime="#DateFormat(DateAdd('d', arguments.nCouldYou, local.stSegment.DepartureTime), 'yyyy-mm-dd')#T#TimeFormat(local.stSegment.DepartureTime, 'HH:mm:ss')#" ArrivalTime="#DateFormat(DateAdd('d', arguments.nCouldYou, local.stSegment.ArrivalTime), 'yyyy-mm-dd')#T#TimeFormat(local.stSegment.ArrivalTime, 'HH:mm:ss')#" Group="#local.nGroup#" FlightNumber="#local.stSegment.FlightNumber#" Carrier="#local.stSegment.Carrier#" ProviderCode="1V" />
												</cfif>
											</cfloop>
										</cfloop>
									</cfif>
								</cfloop>
							</air:AirItinerary>
							<air:AirPricingModifiers ProhibitNonRefundableFares="#ProhibitNonRefundableFares#" FaresIndicator="#arguments.sFaresIndicator#" ProhibitMinStayFares="false" ProhibitMaxStayFares="false" CurrencyType="USD" ProhibitAdvancePurchaseFares="false" ProhibitRestrictedFares="#ProhibitRestrictedFares#" ETicketability="Required" ProhibitNonExchangeableFares="false" ForceSegmentSelect="false">
								<cfif arrayLen(arguments.stAccount.Air_PF)
									AND arrayLen(local.carriers) EQ 1
									AND arguments.bAccountCodes EQ 1>
									<air:AccountCodes>
										<cfloop array="#arguments.stAccount.Air_PF#" index="local.sPF">
											<cfif getToken(sPF, 2, ',') EQ local.carriers[1]>
												<com:AccountCode Code="#getToken(local.sPF, 3, ',')#" ProviderCode="1V" SupplierCode="#getToken(local.sPF, 2, ',')#" />
											</cfif>
										</cfloop>
									</air:AccountCodes>
								</cfif>
								<air:PermittedCabins>
									<cfloop array="#local.aCabins#" index="local.sCabin">
										<air:CabinClass Type="#(ListFind('Y,C,F', local.sCabin) ? (local.sCabin EQ 'Y' ? 'Economy' : (local.sCabin EQ 'C' ? 'Business' : 'First')) : local.sCabin)#" />
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

		<cfreturn local.sMessage/>
	</cffunction>

	<cffunction name="getTripKey" output="false">
		<cfargument name="stTrips" 	required="true">

		<cfset local.nTripKey = ''>
		<cfloop collection="#arguments.stTrips#" item="local.nTrip">
			<cfset local.nTripKey = local.nTrip>
		</cfloop>

		<cfreturn local.nTripKey>
	</cffunction>

	<cffunction name="addstPriced" output="false">
		<cfargument name="stPriced" required="true">
		<cfargument name="nTripKey" required="true">

		<cfset local.stPriced = (IsStruct(arguments.stPriced) ? arguments.stPriced : {})>
		<cfset local.stPriced[arguments.nTripKey] = ''>

		<cfreturn local.stPriced>
	</cffunction>

	<cffunction name="doCouldYouSearch" access="public" output="false" returntype="any" hint="">
		<cfargument name="Search" type="any" required="true" />
		<cfargument name="requestedDate" type="date" required="true" />
		<cfargument name="requery" type="boolean" required="false" default="false" />

		<cfset var originalDepartDate = createDate( year( arguments.Search.getDepartDateTime() ), month( arguments.Search.getDepartDateTime() ), day( arguments.Search.getDepartDateTime() ) ) />
		<cfset var newDepartDate = createDate( year( arguments.requestedDate ), month( arguments.requestedDate ), day( arguments.requestedDate ) ) />
		<cfset var airArgs = structNew() />

		<cfset airArgs.searchId = arguments.Search.getSearchId() />
		<cfset airArgs.Account = application.accounts[ arguments.Search.getAcctID() ] />
		<cfset airArgs.Policy = application.policies[ arguments.Search.getPolicyId() ] />
		<cfset airArgs.nTrip = session.searches[ arguments.Search.getSearchId() ].stItinerary.Air.nTrip />
		<cfset airArgs.nCouldYou = dateDiff( 'd', originalDepartDate, newDepartDate ) />
		<cfset airArgs.bRefundable = session.searches[ arguments.Search.getSearchId() ].stItinerary.Air.ref />
		<cfset airArgs.findIt = session.filters[ arguments.Search.getSearchId() ].getFindIt() />

		<cfset var flight = this.doAirPrice( argumentCollection = airArgs ) />

		<cfif NOT isStruct( flight ) OR structIsEmpty( flight )>
			<cfset flight = "" />
		</cfif>

		<cfif NOT structKeyExists( session.searches[ arguments.Search.getSearchID() ], "couldYou" ) >
			<cfset session.searches[ arguments.Search.getSearchID() ].couldYou = structNew() />
		</cfif>

		<cfif NOT structKeyExists( session.searches[ arguments.Search.getSearchID() ].couldYou, "air" ) >
			<cfset session.searches[ arguments.Search.getSearchID() ].couldYou.air = structNew() />
		</cfif>

		<cfset session.searches[ arguments.Search.getSearchID() ].couldYou.air[ dateFormat( arguments.requestedDate, 'mm-dd-yyyy' ) ] = flight />

		<cfreturn flight />

	</cffunction>

</cfcomponent>