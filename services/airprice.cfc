<cfcomponent output="false" accessors="true">

	<cfproperty name="uAPI" />
	<cfproperty name="uAPISchemas" />
	<cfproperty name="AirParse" />
	<cfproperty name="AirAdapter" />

    <cffunction name="init" access="public" output="false" returntype="any" hint="I initialize this component" >
    	<cfargument name="uAPI" type="any" required="true" />
    	<cfargument name="uAPISchemas" type="any" required="true" />
    	<cfargument name="AirParse" type="any" required="false" default="" />
    	<cfargument name="AirAdapter" type="any" required="false" default="" />

    	<cfset setUAPI( arguments.uAPI ) />
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
		<cfargument name="nTrip" required="false" default="">
		<cfargument name="nCouldYou" required="false" default="0">
		<cfargument name="bSaveAirPrice" required="false" default="0">
		<cfargument name="stSelected" required="false" default="">

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
		<cfset local.TotalFare = 0>

		<cfif arguments.nTrip EQ ''
			AND NOT isStruct(arguments.stSelected)>
			<!--- Selected outbound and return then wanting a price --->
			<cfset stSelected = session.searches[arguments.SearchID].stSelected>
		<cfelseif NOT isStruct(arguments.stSelected)>
			<cfloop collection="#session.searches[arguments.SearchID].stTrips[arguments.nTrip].Groups#" item="local.Group">
				<cfset stSelected[Group].Groups[0] = session.searches[arguments.SearchID].stTrips[arguments.nTrip].Groups[Group]>
			</cfloop>
		<cfelseif isStruct(arguments.stSelected)>
			<cfset stSelected = arguments.stSelected>
		</cfif>

		<!--- Put together the SOAP message. --->
		<cfset sMessage = prepareSoapHeader( stSelected = stSelected
											, sCabin = arguments.sCabin
											, bRefundable = arguments.bRefundable
											, nCouldYou = arguments.nCouldYou )>
		<!--- Call the UAPI. --->
		<cfset sResponse 	= UAPI.callUAPI('AirService', sMessage, arguments.SearchID)>
		<!--- <cfdump var="#sResponse#" abort> --->
		<!--- Format the UAPI response. --->
		<cfset aResponse 	= UAPI.formatUAPIRsp(sResponse)>
		<!--- <cfdump var="#aResponse#" abort> --->
		<!--- Parse the segments. --->
		<cfset stSegments	= AirParse.parseSegments(aResponse)>
		<cfif NOT StructIsEmpty(stSegments)>
			<!--- Parse the trips. --->
			<cfset stTrips = AirParse.parseTrips(aResponse, stSegments)>
			<!--- Add group node --->
			<cfset stTrips = AirParse.addGroups(stTrips)>
			<!--- Check low fare. --->
			<cfset stTrips = AirParse.addTotalBagFare(stTrips)>
			<!--- Mark preferred carriers. --->
			<cfset stTrips = AirParse.addPreferred(stTrips, arguments.Account)>
			<!---<cfdump var="#stTrips#" abort>--->
			<!--- Add trip id to the list of priced items --->
			<cfset nTripKey = getTripKey(stTrips)>
			<cfset stTrips[nTripKey].nTrip = nTripKey>
			<!--- Save XML if needed - AirCreate --->
			<cfif arguments.bSaveAirPrice>
				<cfset stTrips[nTripKey].sXML = sResponse>
				<cfset stTrips[nTripKey].PricingSolution = AirAdapter.parsePricingSolution( response = sResponse )>
			</cfif>
			<cfif arguments.nCouldYou EQ 0>
				<!--- Add trip id to the list of priced items --->
				<cfset session.searches[arguments.SearchID].stLowFareDetails.stPriced = addstPriced(session.searches[arguments.SearchID].stLowFareDetails.stPriced, nTripKey)>
				<!--- Merge all data into the current session structures. --->
				<cfset session.searches[arguments.SearchID].stTrips = AirParse.mergeTrips(session.searches[arguments.SearchID].stTrips, stTrips)>
				<!--- Finish up the results --->
				<cfset void = AirParse.finishLowFare(arguments.SearchID, arguments.Account, arguments.Policy)>
				<!--- <cfdump var="#session.searches[arguments.SearchID].stTrips#" abort> --->
				<!--- Clear out their results --->
				<cfif arguments.sCabin NEQ stTrips[nTripKey].Class>
					<cfset session.searches[arguments.SearchID].sUserMessage = 'Pricing returned '&(stTrips[nTripKey].Class EQ 'Y' ? 'economy' : (stTrips[nTripKey].Class EQ 'C' ? 'business' : 'first'))&' class instead of '&(arguments.sCabin EQ 'Y' ? 'economy' : (arguments.sCabin EQ 'C' ? 'business' : 'first'))&'.'>
				</cfif>
			<cfelse>
				<cfset TotalFare = stTrips[nTripKey].Total>
			</cfif>
		<cfelse>
			<cfset session.searches[arguments.SearchID].sUserMessage = 'Fare type selected is unavailable for pricing.'>
		</cfif>

		<cfreturn stTrips>
	</cffunction>

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
						<air:AirPriceReq
							xmlns:air="#getUAPISchemas().air#"
							xmlns:com="#getUAPISchemas().common#"
							TargetBranch="#arguments.stAccount.sBranch#">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI"/>
							<air:AirItinerary>
								<cfset local.nCount = 0>
								<cfloop collection="#arguments.stSelected#" item="local.stGroup" index="local.nGroup">
									<cfif structKeyExists(stGroup, "Groups")>
										<cfloop collection="#stGroup.Groups#" item="local.stInnerGroup" index="local.nInnerGroup">
											<cfloop collection="#stInnerGroup.Segments#" item="local.stSegment" index="local.nSegment">
												<cfset nCount++>
												<air:AirSegment
													Key="#nCount#T"
													Origin="#stSegment.Origin#"
													Destination="#stSegment.Destination#"
													DepartureTime="#DateFormat(DateAdd('d', arguments.nCouldYou, stSegment.DepartureTime), 'yyyy-mm-dd')#T#TimeFormat(stSegment.DepartureTime, 'HH:mm:ss')#"
													ArrivalTime="#DateFormat(DateAdd('d', arguments.nCouldYou, stSegment.ArrivalTime), 'yyyy-mm-dd')#T#TimeFormat(stSegment.ArrivalTime, 'HH:mm:ss')#"
													Group="#nGroup#"
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
											<com:AccountCode
												Code="#GetToken(sPF, 3, ',')#"
												ProviderCode="1V"
												SupplierCode="#GetToken(sPF, 2, ',')#" />
										</cfloop>
									</air:AccountCodes>
								</cfif>
								<air:PermittedCabins>
									<cfloop array="#aCabins#" index="local.sCabin">
										<air:CabinClass
											Type="#(ListFind('Y,C,F', sCabin) ? (sCabin EQ 'Y' ? 'Economy' : (sCabin EQ 'C' ? 'Business' : 'First')) : sCabin)#" />
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

	<cffunction name="getTripKey" output="false">
		<cfargument name="stTrips" 	required="true">

		<cfset local.nTripKey = ''>
		<cfloop collection="#arguments.stTrips#" item="local.nTrip">
			<cfset nTripKey = nTrip>
		</cfloop>

		<cfreturn nTripKey>
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

		<cfif structKeyExists( session.searches[ arguments.Search.getSearchID() ], "couldYou" )
			AND isStruct( session.searches[ arguments.Search.getSearchID() ].couldYou )
			AND structKeyExists( session.searches[ arguments.Search.getSearchID() ].couldYou, "air" )
			AND isStruct( session.searches[ arguments.Search.getSearchID() ].couldYou.air )
			AND structKeyExists( session.searches[ arguments.Search.getSearchID() ].couldYou.air, dateFormat( arguments.requestedDate, 'mm-dd-yyyy' ) )
			AND arguments.requery IS false>

			<cfset structClear( session.searches[ arguments.Search.getSearchID() ].couldYou.air ) />

		</cfif>

		<cfset var originalDepartDate = createDate( year( arguments.Search.getDepartDateTime() ), month( arguments.Search.getDepartDateTime() ), day( arguments.Search.getDepartDateTime() ) ) />
		<cfset var newDepartDate = createDate( year( arguments.requestedDate ), month( arguments.requestedDate ), day( arguments.requestedDate ) ) />
		<cfset var airArgs = structNew() />

		<cfset airArgs.searchId = arguments.Search.getSearchId() />
		<cfset airArgs.Account = application.accounts[ arguments.Search.getAcctID() ] />
		<cfset airArgs.Policy = application.policies[ arguments.Search.getPolicyId() ] />
		<cfset airArgs.nTrip = session.searches[ arguments.Search.getSearchId() ].stItinerary.Air.nTrip />
		<cfset airArgs.nCouldYou = dateDiff( 'd', originalDepartDate, newDepartDate ) />
		<cfset airArgs.bRefundable = session.searches[ arguments.Search.getSearchId() ].stItinerary.Air.ref />

		<cfset var flight = this.doAirPrice( argumentCollection = airArgs ) />

		<cfif NOT isStruct( flight ) OR structIsEmpty( flight )>
			<cfset flight = "" />
		</cfif>

		<cfif NOT structKeyExists( session.searches[ arguments.Search.getSearchID() ], "couldYou" ) >
			<cfset session.searches[ arguments.Search.getSearchID() ].couldYou = structNew() />
		</cfif>

		<cfset session.searches[ arguments.Search.getSearchID() ].couldYou.air[ dateFormat( arguments.requestedDate, 'mm-dd-yyyy' ) ] = flight />

		<cfreturn flight />

	</cffunction>

</cfcomponent>