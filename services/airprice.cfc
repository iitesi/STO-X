<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="KrakenService">
	<cfproperty name="Storage">

	<cffunction name="init" output="false" hint="Init method.">
		<cfargument name="KrakenService">
		<cfargument name="Storage">

		<cfset setKrakenService(arguments.KrakenService)>
		<cfset setStorage(arguments.Storage)>

		<cfreturn this>
	</cffunction>

	<cffunction name="doAirPrice" output="false">
		<cfargument name="TMC">
		<cfargument name="Account">
		<cfargument name="Itinerary">
		<cfargument name="Solutions">
		<cfargument name="CabinClass">
		<cfargument name="ProhibitNonRefundableFares" default="false">

		<cfset var RequestBody = createAirPriceRequest(Itinerary = arguments.Itinerary,
														Account = arguments.Account,
														CabinClass = arguments.CabinClass,
														ProhibitNonRefundableFares = arguments.ProhibitNonRefundableFares)>
		
		<!--- <cfdump var=#RequestBody#> --->
		
		<cfhttp method="post" url="https://americas.universal-api.travelport.com/B2BGateway/connect/uAPI/AirService">
			<cfhttpparam type="header" name="Authorization" value="Basic #ToBase64(TMC.getUAPIUserName()&':'&TMC.getUAPIPassword())#" />
			<cfhttpparam type="header" name="Content-Type" value="text/xml">
			<cfhttpparam type="body" name="message" value="#Trim(RequestBody)#" />
		</cfhttp>

		<!--- <cfdump var=#cfhttp.filecontent#> --->

		<cfif NOT structKeyExists(cfhttp, 'filecontent')>
			<cfdump var=#cfhttp# abort>
		</cfif>

		<cfset var Solutions = parse(Itinerary = arguments.Itinerary,
									Response = cfhttp.filecontent,
									Solutions = arguments.Solutions)>
		
		<!--- <cfdump var=#Solutions# abort> --->
		
		<cfreturn Solutions />
	</cffunction>

	<cffunction name="createAirPriceRequest" output="false">
		<cfargument name="Account">
		<cfargument name="Itinerary">
		<cfargument name="CabinClass">
		<cfargument name="ProhibitNonRefundableFares">

		<!--- Dohmen ProhibitRestrictedFares="#ProhibitRestrictedFares#" --->
		<!--- Dohmen <cfset local.sFaresIndicator = "PublicOrPrivateFares" /> --->
		<!--- 	<cfset local.bGovtRate = 0 />
				<cfif rc.Air.PTC EQ "GST">
					<cfset local.bGovtRate = 1 />
				</cfif> --->

		<cfset var Itinerary = arguments.Itinerary>
		<cfset var Account = arguments.Account>
		<cfset var PermittedCabins = arguments.CabinClass>
		<cfset var ProhibitNonRefundableFares = arguments.ProhibitNonRefundableFares>
		<cfset var BookingCode = {}>
		<cfset var FareBasis = {}>
		<cfset var CabinClass = {}>
		<cfset var BookingCodeCount = 0>
		<cfset var Carrier = ''>
		<cfset var FlightCount = 0>

		<cfloop collection="#Itinerary#" index="local.GroupIndex" item="local.Group">
			<cfloop collection="#Group.Flights#" index="local.SegmentIndex" item="local.Segment">

				<cfset FlightCount++>
				<cfset Carrier = listAppend(Carrier, Segment.CarrierCode)>
				<cfif NOT len(CabinClass) 
					AND structKeyExists(Itinerary[GroupIndex], 'Fare')
					AND isStruct(Itinerary[GroupIndex].Fare)>

					<cfset BookingCodeCount++>
					<cfset BookingCode[FlightCount] = Itinerary[GroupIndex].Fare.Details[SegmentIndex].BookingCode>
					<cfset FareBasis[FlightCount] = Itinerary[GroupIndex].Fare.Details[SegmentIndex].FareBasis>
					<cfset CabinClass[FlightCount] = Itinerary[GroupIndex].Fare.Details[SegmentIndex].CabinClass>

				</cfif>

			</cfloop>
		</cfloop>
		<cfset Carrier = listRemoveDuplicates(Carrier)>

		<cfsavecontent variable="local.RequestBody">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<air:AirPriceReq xmlns:air="http://www.travelport.com/schema/air_v43_0" xmlns:com="http://www.travelport.com/schema/common_v43_0" TargetBranch="#Account.sBranch#">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI"/>
							<air:AirItinerary>
								<cfset var FlightCount = 0>
								<cfloop collection="#Itinerary#" index="local.GroupIndex" item="local.Group">
									<cfloop collection="#Group.Flights#" index="local.SegmentIndex" item="local.Segment">
										<cfset var FlightCount++>
										<air:AirSegment 
											Key="#FlightCount#T" 
											Group="#GroupIndex#"
											Carrier="#Segment.CarrierCode#" 
											ProviderCode="1V" 
											FlightNumber="#Segment.FlightNumber#" 
											Origin="#Segment.OriginAirportCode#" 
											Destination="#Segment.DestinationAirportCode#" 
											DepartureTime="#dateFormat(Segment.DepartureTime, 'yyyy-mm-dd')#T#timeFormat(Segment.DepartureTime, 'HH:mm:mm')#" 
											ArrivalTime="#dateFormat(Segment.ArrivalTime, 'yyyy-mm-dd')#T#timeFormat(Segment.ArrivalTime, 'HH:mm:mm')#"
											ClassOfService="#structKeyExists(BookingCode, FlightCount) ? BookingCode[FlightCount] : ''#" 
											FareBasis="#structKeyExists(FareBasis, FlightCount) ? FareBasis[FlightCount] : ''#" 
											CabinClass="#structKeyExists(CabinClass, FlightCount) ? CabinClass[FlightCount] : ''#" />
									</cfloop>
								</cfloop>
							</air:AirItinerary>
							<air:AirPricingModifiers
								PlatingCarrier="#Group.PlatingCarrier#" 
								ProhibitUnbundledFareTypes="true" 
								ProhibitMinStayFares="false" 
								ProhibitMaxStayFares="false" 
								CurrencyType="USD" 
								ProhibitAdvancePurchaseFares="false" 
								ETicketability="Required" 
								ProhibitNonExchangeableFares="false" 
								ForceSegmentSelect="false" 
								ProhibitNonRefundableFares="#ProhibitNonRefundableFares#">
								<cfif arrayLen(Account.Air_PF)
									AND Segment.CarrierCode NEQ 'Mult'
									AND listFind(arrayToList(Account.Air_PF), Segment.CarrierCode)>
									<air:AccountCodes>
										<cfloop array="#Account.Air_PF#" index="local.PrivateFare">
											<cfif getToken(PrivateFare, 2, ',') EQ Segment.CarrierCode>
												<com:AccountCode Code="#getToken(PrivateFare, 3, ',')#" ProviderCode="1V" SupplierCode="#getToken(PrivateFare, 2, ',')#" />
											</cfif>
										</cfloop>
									</air:AccountCodes>
								</cfif>
								<air:PermittedCabins>
									<cfif len(PermittedCabins)>
										<com:CabinClass Type="#PermittedCabins#" />
									<cfelse>
										<cfloop from="1" to="#FlightCount#" index="local.Flight">
											<cfif structKeyExists(CabinClass, Flight)>
												<com:CabinClass Type="#CabinClass[Flight]#" />
											</cfif>
										</cfloop>
									</cfif>
								</air:PermittedCabins>
							</air:AirPricingModifiers>
							<!--- <cfif Account.Gov_Rates>
								<com:SearchPassenger Code="GST" PricePTCOnly="true" Key="1">
									<com:PersonalGeography>
										<com:CityCode>DFW</com:CityCode>
									</com:PersonalGeography>
								</com:SearchPassenger>
							<cfelse> --->
								<com:SearchPassenger Code="ADT" PricePTCOnly="false" Key="1" />
							<!--- </cfif> --->
							<air:AirPricingCommand>
								<cfif BookingCodeCount EQ FlightCount>
									<cfloop from="1" to="#FlightCount#" index="local.Flight">
										<cfif structKeyExists(BookingCode, Flight)>
											<air:AirSegmentPricingModifiers AirSegmentRef="#Flight#T">
												<air:PermittedBookingCodes>
													<air:BookingCode Code="#BookingCode[Flight]#"/>
												</air:PermittedBookingCodes>
											</air:AirSegmentPricingModifiers>
										</cfif>
									</cfloop>
								</cfif>
							</air:AirPricingCommand>
						</air:AirPriceReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>

		<!--- <cfdump var=#RequestBody# abort> --->

		<cfreturn RequestBody />
	</cffunction>

	<cffunction name="parse" output="false">
		<cfargument name="Solutions">
		<cfargument name="Itinerary">
		<cfargument name="Response">

		<cfset var Itinerary = arguments.Itinerary>
		<cfset var Response = XMLParse(arguments.Response)>
		<cfset var Solutions = arguments.Solutions>
		<cfset var Fares = {}>
		<cfset var Solution = {}>
		<cfset var Flights = {}>
		<cfset var TotalPrice = 0>

		<cfset Response = Response.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren>

		<cfloop collection="#Response#" index="i" item="ResponseItem">
			<cfif ResponseItem.XMLName EQ 'faultstring'>

				<cfset ArrayAppend(Solutions, ResponseItem.XMLText)>

			</cfif>
		</cfloop>

		<cfloop collection="#Response#" index="i" item="ResponseItem">
			<cfif ResponseItem.XMLName EQ 'air:AirItinerary'>

				<cfloop collection="#ResponseItem.XMLChildren#" index="local.SegmentIndex" item="AirItinerary">
					<cfif AirItinerary.XMLName EQ 'air:AirSegment'>

						<cfset Flights[AirItinerary.XMLAttributes.Key].FightId = AirItinerary.XMLAttributes.Carrier&'.'&AirItinerary.XMLAttributes.FlightNumber>
						<cfset Flights[AirItinerary.XMLAttributes.Key].Carrier = AirItinerary.XMLAttributes.Carrier>
						<cfset Flights[AirItinerary.XMLAttributes.Key].FlightNumber = AirItinerary.XMLAttributes.FlightNumber>
						<cfset Flights[AirItinerary.XMLAttributes.Key].Origin = AirItinerary.XMLAttributes.Origin>
						<cfset Flights[AirItinerary.XMLAttributes.Key].Destination = AirItinerary.XMLAttributes.Destination>

					</cfif>
				</cfloop>

			</cfif>
		</cfloop>

		<cfloop collection="#Response#" index="i" item="ResponseItem">
			<cfif ResponseItem.XMLName EQ 'air:AirPriceResult'>

				<cfloop collection="#ResponseItem.XMLChildren#" index="i" item="AirPricingSolution">
					<cfif AirPricingSolution.XMLName EQ 'air:AirPricingSolution'>

						<cfloop collection="#AirPricingSolution.XMLChildren#" index="i" item="AirPricingInfo">
							<cfif AirPricingInfo.XMLName EQ 'air:AirPricingInfo'>

								<cfset Solution = {}>
								<cfset TotalPrice = AirPricingInfo.XMLAttributes.TotalPrice>
								<cfset Solution.Currency = left(TotalPrice, 3)>
								<cfset Solution.TotalPrice = right(TotalPrice, len(TotalPrice)-3)>
								<cfset Solution.PlatingCarrier = AirPricingInfo.XMLAttributes.PlatingCarrier>
								<cfset Solution.Refundable = structKeyExists(AirPricingInfo.XMLAttributes, 'Refundable') ? AirPricingInfo.XMLAttributes.Refundable : false>
								<cfset Solution.CabinClass = ''>
								<cfset Solution.BrandedFare = ''>
								<cfset Solution.IsContracted = false>

								<cfloop collection="#AirPricingInfo.XMLChildren#" index="i" item="BookingInfo">

									<cfif BookingInfo.XMLName EQ 'air:FareInfo'>

										<cfset Fares[BookingInfo.XMLAttributes.Key].FareBasis = BookingInfo.XMLAttributes.FareBasis>
										<cfset Solution.IsContracted = structKeyExists(BookingInfo.XMLAttributes, 'PrivateFare') AND BookingInfo.XMLAttributes.PrivateFare EQ 'AirlinePrivateFare' ? true : false>

										<cfloop collection="#BookingInfo.XMLChildren#" index="i" item="FareInfo">

											<cfif FareInfo.XMLName EQ 'air:Brand'>
												
												<cfloop collection="#FareInfo.XMLChildren#" index="i" item="Brand">

													<cfif Brand.XMLName EQ 'air:Title'
														AND Brand.XMLAttributes.Type EQ 'External'>

														<cfparam name="Fares['#BookingInfo.XMLAttributes.Key#'].BrandedFare" default="">
														<cfset Fares[BookingInfo.XMLAttributes.Key].BrandedFare = Brand.XMLAttributes.Type EQ 'External' AND NOT Len(Fares[BookingInfo.XMLAttributes.Key].BrandedFare) ? Brand.XMLText : ''>

													<cfelseif Brand.XMLName EQ 'air:Text'
														AND Brand.XMLAttributes.Type EQ 'MarketingConsumer'>

														<cfset Fares[BookingInfo.XMLAttributes.Key].Description = Brand.XMLAttributes.Type EQ 'MarketingConsumer' ? Brand.XmlText : ''>

													<cfelseif Brand.XMLName EQ 'air:OptionalServices'>
											
														<cfloop collection="#Brand.XMLChildren#" index="i" item="OptionalServices">
														
															<cfif OptionalServices.XMLName EQ 'air:OptionalService'
																AND OptionalServices.XMLAttributes.Tag EQ 'Wifi'>
																		
																	<cfloop collection="#OptionalServices.XMLChildren#" index="i" item="ServiceData">

																		<cfif ServiceData CONTAINS 'ServiceData'>

																			<cfset Flights[ServiceData.XMLAttributes.AirSegmentRef].Wifi = true>

																		</cfif>

																	</cfloop>

															</cfif>

														</cfloop>

													</cfif>

												</cfloop>


											</cfif>

										</cfloop>

									<cfelseif BookingInfo.XMLName EQ 'air:BookingInfo'>

										<cfset Solution.Flights[Flights[BookingInfo.XMLAttributes.SegmentRef].FightId] = {
											CabinClass = BookingInfo.XMLAttributes.CabinClass,
											BookingCode = BookingInfo.XMLAttributes.BookingCode,
											FareBasis = Fares[BookingInfo.XMLAttributes.FareInfoRef].FareBasis,
											BrandedFare = structKeyExists(Fares[BookingInfo.XMLAttributes.FareInfoRef], 'BrandedFare') ? Fares[BookingInfo.XMLAttributes.FareInfoRef].BrandedFare : '',
											Carrier = Flights[BookingInfo.XMLAttributes.SegmentRef].Carrier,
											FlightNumber = Flights[BookingInfo.XMLAttributes.SegmentRef].FlightNumber,
											Origin = Flights[BookingInfo.XMLAttributes.SegmentRef].Origin,
											Destination = Flights[BookingInfo.XMLAttributes.SegmentRef].Destination,
											Wifi = structKeyExists(Flights[BookingInfo.XMLAttributes.SegmentRef], 'Wifi') ? true : false
										}>
										<cfif structKeyExists(Fares[BookingInfo.XMLAttributes.FareInfoRef], 'BrandedFare')>
											<cfset Solution[Fares[BookingInfo.XMLAttributes.FareInfoRef].BrandedFare] =  structKeyExists(Fares[BookingInfo.XMLAttributes.FareInfoRef], 'Description') ? Fares[BookingInfo.XMLAttributes.FareInfoRef].Description : ''>
											<cfset Solution.BrandedFare = listAppend(Solution.BrandedFare, Fares[BookingInfo.XMLAttributes.FareInfoRef].BrandedFare)>
										</cfif>
										<cfset Solution.CabinClass = listAppend(Solution.CabinClass, BookingInfo.XMLAttributes.CabinClass)>

									<cfelseif BookingInfo.XMLName EQ 'air:PassengerType'>

										<cfset Solution.PassengerType = BookingInfo.XMLAttributes.Code>

									</cfif>
								</cfloop>

								<cfset Solution.CabinClass = listRemoveDuplicates(Solution.CabinClass)>
								<cfset Solution.BrandedFare = listRemoveDuplicates(Solution.BrandedFare)>
								<cfset ArrayAppend(Solutions, Solution)>

							</cfif>
						</cfloop>

					</cfif>
				</cfloop>

			</cfif>
		</cfloop>

		<cfreturn Solutions />
	</cffunction>

</cfcomponent>