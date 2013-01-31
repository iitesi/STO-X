<cfcomponent>
	
<!---
init
--->
	<cffunction name="init" output="false">
		
		<cfset variables.objAirPrice = CreateObject('component', 'booking.services.airprice').init()>
		<cfset variables.objAirParse = CreateObject('component', 'booking.services.airparse').init()>
		
		<cfreturn this>
	</cffunction>	

<!---
doAirPrice
--->
	<cffunction name="doAirCreate" output="false">
		<cfargument name="SearchID" 	required="true">

		<cfset local.stAir 			= session.searches[arguments.SearchID].stItinerary.Air>
		<cfset local.nTripKey		= objAirPrice.doAirPrice(arguments.SearchID, stAir.Class, stAir.Ref, stAir.nTrip, 0, 1)>
		<cfset local.stAirPricing	= objAirParse.parseTripForPurchase(session.searches[arguments.SearchID].stTrips[nTripKey].sXML)>

		<cfdump var="#ToString(stAirPricing)#" abort="true">

		<cfreturn >
	</cffunction>

<!---
prepareSoapHeader
--->
	<cffunction name="prepareSoapHeader" returntype="string" output="false">
		<cfargument name="SearchID" 	required="true">
		<cfargument name="nGroup"	 	required="true">
		<cfargument name="sNextRef"	 	required="false" 	default="">
		<cfargument name="stAccount"	required="false" 	default="#application.Accounts[session.AcctID]#">
		<cfargument name="stPolicy"		required="false"	default="#application.Policies[session.searches[url.SearchID].PolicyID]#">
		
		<cfsavecontent variable="local.sMessage">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<air:AirCreateReservationReq TargetBranch="#arguments.stAccount.sBranch#" xmlns:air="http://www.travelport.com/schema/air_v18_0" xmlns:com="http://www.travelport.com/schema/common_v15_0">
							<com:BillingPointOfSaleInfo OriginApplication="uAPI"/>
					         <!--Zero or more repetitions:-->
					         <com:BookingTraveler Key="?" TravelerType="?" Age="?" VIP="false" DOB="?" Gender="?">
					            <com:BookingTravelerName First="#stTraveler.First_Name#" Middle="#stTraveler.Middle_Name#" Last="#stTraveler.Last_Name#"/>
					            <!--Zero or more repetitions:-->
					            <com:DeliveryInfo Type="?" SignatureRequired="?" TrackingNumber="?">
					               <!--Optional:-->
					               <com:ShippingAddress Key="?">
					                  <!--Optional:-->
					                  <com:AddressName>?</com:AddressName>
					                  <!--0 to 5 repetitions:-->
					                  <com:Street>?</com:Street>
					                  <!--Optional:-->
					                  <com:City>?</com:City>
					                  <!--Optional:-->
					                  <com:State>?</com:State>
					                  <!--Optional:-->
					                  <com:PostalCode>?</com:PostalCode>
					                  <!--Optional:-->
					                  <com:Country>?</com:Country>
					                  <!--Zero or more repetitions:-->
					                  <com:ProviderReservationInfoRef Key="?"/>
					               </com:ShippingAddress>
					               <!--Optional:-->
					               
					               <!--Optional:-->
					               
					               <!--Zero or more repetitions:-->
					               <com:GeneralRemark Key="?" Category="?" TypeInGds="?" SupplierType="?" ProviderReservationInfoRef="?" ProviderCode="?" SupplierCode="?" Direction="?" CreateDate="?" UseProviderNativeMode="false">
					                  <com:RemarkData>?</com:RemarkData>
					                  <!--Zero or more repetitions:-->
					                  <com:BookingTravelerRef>?</com:BookingTravelerRef>
					               </com:GeneralRemark>
					               <!--Zero or more repetitions:-->
					               <com:ProviderReservationInfoRef Key="?"/>
					            </com:DeliveryInfo>
					            <com:PhoneNumber Key="000" Type="Wireless" Location="DEN" CountryCode="001" AreaCode="#Left(stTraveler.Wireless_Phone, 3)#" Number="#Right(stTraveler.Wireless_Phone, 7)#" Extension="?"/>
					            <com:Email Key="000" Type="Business" EmailID="#stTraveler.Email#" />
					            <!--Zero or more repetitions:-->
					            <com:LoyaltyCard Key="?" SupplierCode="?" CardNumber="?" Status="?" MembershipStatus="?" FreeText="?" SupplierType="?" Level="?" MembershipProgram="?" PriorityCode="?">
					               <!--Zero or more repetitions:-->
					               <com:ProviderReservationSpecificInfo ProviderReservationLevel="?" ReservationLevel="?">
					                  <!--Zero or more repetitions:-->
					                  <com:OperatedBy>?</com:OperatedBy>
					                  <!--Optional:-->
					                  <com:ProviderReservationInfoRef Key="?"/>
					               </com:ProviderReservationSpecificInfo>
					            </com:LoyaltyCard>
					            <!--0 to 9 repetitions:-->
					            <com:DiscountCard Key="?" Code="?" Description="?" Number="?"/>
					            <!--Zero or more repetitions:-->
					            <com:SSR Key="?" SegmentRef="?" PassiveSegmentRef="?" ProviderReservationInfoRef="?" Type="?" Status="?" FreeText="?" Carrier="?" CarrierSpecificText="?" Description="?" ProviderDefinedType="?" SSRRuleRef="?" URL="?"/>
					            <!--Zero or more repetitions:-->
					            <com:NameRemark Key="?" Category="?">
					               <com:RemarkData>?</com:RemarkData>
					               <!--Zero or more repetitions:-->
					               <com:ProviderReservationInfoRef Key="?"/>
					            </com:NameRemark>
					            <!--Zero or more repetitions:-->
					            <com:AirSeatAssignment Key="?" Status="?" Seat="?" SeatTypeCode="?" SegmentRef="?" FlightDetailsRef="?"/>
					            <!--Zero or more repetitions:-->
					            <com:RailSeatAssignment Key="?" Status="?" Seat="?" RailSegmentRef="?" CoachNumber="?">
					               <!--Zero or more repetitions:-->
					               <com:Characteristic SeatType="?" SeatDescription="?" SeatValue="?" SeatValueDescription="?"/>
					            </com:RailSeatAssignment>
					            <!--Optional:-->
					            <com:EmergencyInfo>?</com:EmergencyInfo>
					            <!--Zero or more repetitions:-->
					            <com:Address Key="?">
					               <!--Optional:-->
					               <com:AddressName>?</com:AddressName>
					               <!--0 to 5 repetitions:-->
					               <com:Street>?</com:Street>
					               <!--Optional:-->
					               <com:City>?</com:City>
					               <!--Optional:-->
					               <com:State>?</com:State>
					               <!--Optional:-->
					               <com:PostalCode>?</com:PostalCode>
					               <!--Optional:-->
					               <com:Country>?</com:Country>
					               <!--Zero or more repetitions:-->
					               <com:ProviderReservationInfoRef Key="?"/>
					            </com:Address>
					            <!--Zero or more repetitions:-->
					            <com:DriversLicense Key="?" LicenseNumber="?"/>
					            <!--Zero or more repetitions:-->
					            <com:AppliedProfile TravelerID="?" TravelerName="?" AccountID="?" AccountName="?" ImmediateParentID="?" ImmediateParentName="?"/>
					            <!--Zero or more repetitions:-->
					            <com:CustomizedNameData Key="?" ProviderReservationInfoRef="?">?</com:CustomizedNameData>
					            <!--Zero or more repetitions:-->
					            <com:TravelComplianceData Key="?" AirSegmentRef="?" PassiveSegmentRef="?" RailSegmentRef="?" ReservationLocatorRef="?">
					               <!--0 to 2 repetitions:-->
					               <com:PolicyCompliance InPolicy="?" PolicyToken="?"/>
					               <!--0 to 2 repetitions:-->
					               <com:ContractCompliance InContract="?" ContractToken="?"/>
					               <!--Zero or more repetitions:-->
					               <com:PreferredSupplier Preferred="?" ProfileType="?"/>
					            </com:TravelComplianceData>
					         </com:BookingTraveler>
				         <!--Zero or more repetitions:-->
				         <com:OSI Key="?" Carrier="?" Code="?" Text="?" ProviderReservationInfoRef="?" ProviderCode="?"/>
				         <!--Zero or more repetitions:-->
				         <com:AccountingRemark Key="?" Category="?" TypeInGds="?" ProviderReservationInfoRef="?" ProviderCode="?" UseProviderNativeMode="false">
				            <com:RemarkData>?</com:RemarkData>
				            <!--Zero or more repetitions:-->
				            <com:BookingTravelerRef>?</com:BookingTravelerRef>
				         </com:AccountingRemark>
				         <!--Zero or more repetitions:-->
				         <com:GeneralRemark Key="?" Category="?" TypeInGds="?" SupplierType="?" ProviderReservationInfoRef="?" ProviderCode="?" SupplierCode="?" Direction="?" CreateDate="?" UseProviderNativeMode="false">
				            <com:RemarkData>?</com:RemarkData>
				            <!--Zero or more repetitions:-->
				            <com:BookingTravelerRef>?</com:BookingTravelerRef>
				         </com:GeneralRemark>
				         <!--Zero or more repetitions:-->
				         <com:XMLRemark Key="?" Category="?">?</com:XMLRemark>
				         <!--Zero or more repetitions:-->
				         <com:UnassociatedRemark ProviderReservationInfoRef="?" ProviderCode="?" Key="?">
				            <com:RemarkData>?</com:RemarkData>
				            <!--Zero or more repetitions:-->
				            <com:BookingTravelerRef>?</com:BookingTravelerRef>
				         </com:UnassociatedRemark>
				         <!--Optional:-->
				         <com:Postscript ProviderReservationInfoRef="?" ProviderCode="?" Key="?">?</com:Postscript>
				         <!--Optional:-->
				         <com:PassiveInfo ProviderCode="?" ProviderLocatorCode="?" SupplierCode="?" SupplierLocatorCode="?">
				            <!--Zero or more repetitions:-->
				            <com:TicketNumber>?</com:TicketNumber>
				            <!--Zero or more repetitions:-->
				            <com:ConfirmationNumber>?</com:ConfirmationNumber>
				            <!--Optional:-->
				            <com:Commission Key="?" Level="?" Type="?" Modifier="?" Amount="?" Percentage="?" BookingTravelerRef="?"/>
				         </com:PassiveInfo>
				         <!--Optional:-->
				         <com:ContinuityCheckOverride Key="?">?</com:ContinuityCheckOverride>
				         <!--Optional:-->
				         <com:AgencyContactInfo Key="?">
				            <!--1 or more repetitions:-->
				            <com:PhoneNumber Key="?" Type="?" Location="?" CountryCode="?" AreaCode="?" Number="?" Extension="?" Text="?">
				               <!--Zero or more repetitions:-->
				               <com:ProviderReservationInfoRef Key="?"/>
				            </com:PhoneNumber>
				         </com:AgencyContactInfo>
				         <!--Optional:-->
				         <com:CustomerID ProviderReservationInfoRef="?" ProviderCode="?" Key="?">?</com:CustomerID>
				         <!--Optional:-->
				         <com:FileFinishingInfo>
				            <!--Optional:-->
				            <com:ShopInformation CabinShopped="?" CabinSelected="?" LowestFareOffered="?">
				               <!--Zero or more repetitions:-->
				               <com:SearchRequest Origin="?" Destination="?" DepartureTime="?" ClassOfService="?"/>
				               <!--Zero or more repetitions:-->
				               <com:FlightsOffered Origin="?" Destination="?" DepartureTime="?" TravelOrder="?" Carrier="?" FlightNumber="?" ClassOfService="?" StopOver="false" Connection="false"/>
				            </com:ShopInformation>
				            <!--Zero or more repetitions:-->
				            <com:PolicyInformation Type="?" Name="?" OutOfPolicy="?" SegmentRef="?">
				               <!--Optional:-->
				               <com:ReasonCode>
				                  <!--Optional:-->
				                  <com:OutOfPolicy>?</com:OutOfPolicy>
				                  <!--Optional:-->
				                  <com:PurposeOfTrip>?</com:PurposeOfTrip>
				                  <!--Optional:-->
				                  <com:Remark Key="?">?</com:Remark>
				               </com:ReasonCode>
				            </com:PolicyInformation>
				            <!--Optional:-->
				            <com:AccountInformation AccountName="?">
				               <!--Optional:-->
				               <com:Address Key="?">
				                  <!--Optional:-->
				                  <com:AddressName>?</com:AddressName>
				                  <!--0 to 5 repetitions:-->
				                  <com:Street>?</com:Street>
				                  <!--Optional:-->
				                  <com:City>?</com:City>
				                  <!--Optional:-->
				                  <com:State>?</com:State>
				                  <!--Optional:-->
				                  <com:PostalCode>?</com:PostalCode>
				                  <!--Optional:-->
				                  <com:Country>?</com:Country>
				                  <!--Zero or more repetitions:-->
				                  <com:ProviderReservationInfoRef Key="?"/>
				               </com:Address>
				               <!--Zero or more repetitions:-->
				               <com:PhoneNumber Key="?" Type="?" Location="?" CountryCode="?" AreaCode="?" Number="?" Extension="?" Text="?">
				                  <!--Zero or more repetitions:-->
				                  <com:ProviderReservationInfoRef Key="?"/>
				               </com:PhoneNumber>
				            </com:AccountInformation>
				            <!--Optional:-->
				            <com:AgencyInformation>
				               <!--Optional:-->
				               <com:Address Key="?">
				                  <!--Optional:-->
				                  <com:AddressName>?</com:AddressName>
				                  <!--0 to 5 repetitions:-->
				                  <com:Street>?</com:Street>
				                  <!--Optional:-->
				                  <com:City>?</com:City>
				                  <!--Optional:-->
				                  <com:State>?</com:State>
				                  <!--Optional:-->
				                  <com:PostalCode>?</com:PostalCode>
				                  <!--Optional:-->
				                  <com:Country>?</com:Country>
				                  <!--Zero or more repetitions:-->
				                  <com:ProviderReservationInfoRef Key="?"/>
				               </com:Address>
				               <!--Zero or more repetitions:-->
				               <com:Email Key="?" Type="?" Comment="?" EmailID="?">
				                  <!--Zero or more repetitions:-->
				                  <com:ProviderReservationInfoRef Key="?"/>
				               </com:Email>
				               <!--Zero or more repetitions:-->
				               <com:PhoneNumber Key="?" Type="?" Location="?" CountryCode="?" AreaCode="?" Number="?" Extension="?" Text="?">
				                  <!--Zero or more repetitions:-->
				                  <com:ProviderReservationInfoRef Key="?"/>
				               </com:PhoneNumber>
				            </com:AgencyInformation>
				            <!--Zero or more repetitions:-->
				            <com:TravelerInformation HomeAirport="?" VisaExpirationDate="?" BookingTravelerRef="?">
				               <!--Optional:-->
				               <com:EmergencyContact Name="?" Relationship="?">
				                  <!--Optional:-->
				                  <com:PhoneNumber Key="?" Type="?" Location="?" CountryCode="?" AreaCode="?" Number="?" Extension="?" Text="?">
				                     <!--Zero or more repetitions:-->
				                     <com:ProviderReservationInfoRef Key="?"/>
				                  </com:PhoneNumber>
				               </com:EmergencyContact>
				            </com:TravelerInformation>
				            <!--Optional:-->
				            <com:CustomProfileInformation/>
				         </com:FileFinishingInfo>
				         <!--Optional:-->
				         <com:CommissionRemark Key="?" ProviderReservationInfoRef="?" ProviderCode="?">
				            <!--You have a CHOICE of the next 2 items at this level-->
				            <com:ProviderReservationLevel Amount="?" Percentage="?" CommissionCap="?"/>
				            <!--1 to 4 repetitions:-->
				            <com:PassengerTypeLevel TravelerType="?" Amount="?" Percentage="?" CommissionCap="?"/>
				         </com:CommissionRemark>
				         <!--Zero or more repetitions:-->
				         <com:InvoiceRemark ProviderReservationInfoRef="?" ProviderCode="?" Key="?">
				            <com:RemarkData>?</com:RemarkData>
				            <!--Zero or more repetitions:-->
				            <com:BookingTravelerRef>?</com:BookingTravelerRef>
				            <!--You have a CHOICE of the next 4 items at this level-->
				            <!--Optional:-->
				            <com:AirSegmentRef Key="?"/>
				            <!--Optional:-->
				            <com:HotelReservationRef LocatorCode="?"/>
				            <!--Optional:-->
				            <com:VehicleReservationRef LocatorCode="?"/>
				            <!--Optional:-->
				            <com:PassiveSegmentRef Key="?"/>
				         </com:InvoiceRemark>
				         <!--Zero or more repetitions:-->
				         <com:SupplierLocator SupplierCode="?" SupplierLocatorCode="?" ProviderReservationInfoRef="?" CreateDateTime="?">
				            <!--Zero or more repetitions:-->
				            <com:SegmentRef Key="?"/>
				         </com:SupplierLocator>
				         <!--Zero or more repetitions:-->
				         <com:ThirdPartyInformation ThirdPartyCode="?" ThirdPartyLocatorCode="?" ThirdPartyName="?" ProviderReservationInfoRef="?" Key="?">
				            <!--Zero or more repetitions:-->
				            <com:SegmentRef Key="?"/>
				         </com:ThirdPartyInformation>
				         <!--Optional:-->
				         <com:PointOfSale ProviderCode="?" PseudoCityCode="?" Key="?"/>
				         <air:AirPricingSolution Key="?" TotalPrice="?" BasePrice="?" ApproximateTotalPrice="?" ApproximateBasePrice="?" EquivalentBasePrice="?" Taxes="?" Fees="?" Services="?">
				            <!--Zero or more repetitions:-->
				            <air:AirSegment Key="?" Status="?" Passive="?" TravelOrder="?" OpenSegment="?" Group="?" Carrier="?" FlightNumber="?" Origin="?" Destination="?" DepartureTime="?" ArrivalTime="?" FlightTime="?" TravelTime="?" Distance="?" ProviderCode="?" SupplierCode="?" ParticipantLevel="?" LinkAvailability="?" PolledAvailabilityOption="?" ClassOfService="?" ETicketability="?" Equipment="?" MarriageGroup="?" NumberOfStops="?" Seamless="?" ChangeOfPlane="false" GuaranteedPaymentCarrier="?" HostTokenRef="?" ProviderReservationInfoRef="?" PassiveProviderReservationInfoRef="?" OptionalServicesIndicator="?" AvailabilitySource="?" APISRequirementsRef="?" BlackListed="?">
				               <!--Zero or more repetitions:-->
				               <com:SegmentRemark Key="?">?</com:SegmentRemark>
				               <!--Optional:-->
				               <air:CodeshareInfo OperatingCarrier="?" OperatingFlightNumber="?">?</air:CodeshareInfo>
				               <!--Zero or more repetitions:-->
				               <air:AirAvailInfo ProviderCode="?" HostTokenRef="?">
				                  <!--1 or more repetitions:-->
				                  <air:BookingCodeInfo CabinClass="?" BookingCounts="?"/>
				                  <!--Zero or more repetitions:-->
				                  <air:FareTokenInfo FareInfoRef="?" HostTokenRef="?"/>
				               </air:AirAvailInfo>
				               <!--Zero or more repetitions:-->
				               <air:FlightDetails Key="?" Origin="?" Destination="?" DepartureTime="?" ArrivalTime="?" FlightTime="?" TravelTime="?" Distance="?" Equipment="?" OnTimePerformance="?" OriginTerminal="?" DestinationTerminal="?">
				                  <!--Optional:-->
				                  <air:Connection ChangeOfPlane="false" ChangeOfTerminal="false" ChangeOfAirport="false" StopOver="false" MinConnectionTime="?" Duration="?" SegmentIndex="?" FlightDetailsIndex="?" IncludeStopOverToFareQuote="?">
				                     <!--Optional:-->
				                     <air:FareNote Key="?" Precedence="?" NoteName="?">?</air:FareNote>
				                  </air:Connection>
				                  <!--Zero or more repetitions:-->
				                  <air:Meals>?</air:Meals>
				                  <!--Zero or more repetitions:-->
				                  <air:InFlightServices>?</air:InFlightServices>
				               </air:FlightDetails>
				               <!--Zero or more repetitions:-->
				               <air:FlightDetailsRef Key="?"/>
				               <!--Zero or more repetitions:-->
				               <air:AlternateLocationDistanceRef Key="?"/>
				               <!--Optional:-->
				               <air:Connection ChangeOfPlane="false" ChangeOfTerminal="false" ChangeOfAirport="false" StopOver="false" MinConnectionTime="?" Duration="?" SegmentIndex="?" FlightDetailsIndex="?" IncludeStopOverToFareQuote="?">
				                  <!--Optional:-->
				                  <air:FareNote Key="?" Precedence="?" NoteName="?">?</air:FareNote>
				               </air:Connection>
				               <!--Zero or more repetitions:-->
				               <com:SellMessage>?</com:SellMessage>
				            </air:AirSegment>
				            <!--Zero or more repetitions:-->
				            <air:AirSegmentRef Key="?"/>
				            <!--Zero or more repetitions:-->
				            <air:LegRef Key="?"/>
				            <!--Zero or more repetitions:-->
				            <air:AirPricingInfo Key="?" CommandKey="?" TotalPrice="?" BasePrice="?" ApproximateTotalPrice="?" ApproximateBasePrice="?" EquivalentBasePrice="?" Taxes="?" Fees="?" Services="?" ProviderCode="?" SupplierCode="?" AmountType="?" IncludesVAT="?" ExchangeAmount="?" ForfeitAmount="?" Refundable="?" Exchangeable="?" LatestTicketingTime="?" PricingMethod="?" Checksum="?" ETicketability="?" PlatingCarrier="?" ProviderReservationInfoRef="?" AirPricingInfoGroup="?" TotalNetPrice="?" Ticketed="?" PricingType="?">
				               <!--Zero or more repetitions:-->
				               <air:FareInfo Key="?" FareBasis="?" PassengerTypeCode="?" Origin="?" Destination="?" EffectiveDate="?" TravelDate="?" DepartureDate="?" Amount="?" PrivateFare="?" NegotiatedFare="?" TourCode="?" WaiverCode="?" NotValidBefore="?" NotValidAfter="?" PseudoCityCode="?" FareFamily="?" PromotionalFare="?">
				                  <!--Zero or more repetitions:-->
				                  <air:FareTicketDesignator Value="?"/>
				                  <!--Zero or more repetitions:-->
				                  <air:FareSurcharge Key="?" Type="?" Amount="?" SegmentRef="?" CouponRef="?"/>
				                  <!--Zero or more repetitions:-->
				                  <com:AccountCode Code="?" ProviderCode="?" SupplierCode="?" Type="?"/>
				                  <!--Zero or more repetitions:-->
				                  <air:ContractCode Code="?" ProviderCode="?" SupplierCode="?"/>
				                  <!--Zero or more repetitions:-->
				                  <com:Endorsement Value="?"/>
				                  <!--Optional:-->
				                  <air:BaggageAllowance>
				                     <!--Optional:-->
				                     <air:NumberOfPieces>?</air:NumberOfPieces>
				                     <!--Optional:-->
				                     <air:MaxWeight value="?" unit="?"/>
				                  </air:BaggageAllowance>
				                  <!--Optional:-->
				                  <air:FareRuleKey FareInfoRef="?" ProviderCode="?">?</air:FareRuleKey>
				                  <!--Optional:-->
				                  <air:FareRuleFailureInfo>
				                     <!--1 or more repetitions:-->
				                     <air:Reason>?</air:Reason>
				                  </air:FareRuleFailureInfo>
				                  <!--Zero or more repetitions:-->
				                  <air:FareRemarkRef Key="?"/>
				               </air:FareInfo>
				               <!--Optional:-->
				               <air:FareStatus Code="?">
				                  <!--Optional:-->
				                  <air:FareStatusFailureInfo Code="?" Reason="?"/>
				               </air:FareStatus>
				               <!--Zero or more repetitions:-->
				               <air:FareInfoRef Key="?"/>
				               <!--Zero or more repetitions:-->
				               <air:BookingInfo BookingCode="?" CabinClass="?" FareInfoRef="?" SegmentRef="?" CouponRef="?" AirItinerarySolutionRef="?"/>
				               <!--Zero or more repetitions:-->
				               <air:TaxInfo Key="?" Category="?" CarrierDefinedCategory="?" SegmentRef="?" FlightDetailsRef="?" CouponRef="?" Amount="?" OriginAirport="?" DestinationAirport="?" CountryCode="?" FareInfoRef="?" TaxExempted="?" ProviderCode="?" SupplierCode="?">
				                  <!--Zero or more repetitions:-->
				                  <air:TaxDetail Amount="?" OriginAirport="?" DestinationAirport="?" CountryCode="?" FareInfoRef="?"/>
				               </air:TaxInfo>
				               <!--Optional:-->
				               <air:FareCalc>?</air:FareCalc>
				               <!--Zero or more repetitions:-->
				               <air:PassengerType Code="?" Age="?" DOB="?" Gender="?" PricePTCOnly="?" BookingTravelerRef="?">
				                  <!--Optional:-->
				                  <com:Name Prefix="?" First="?" Middle="?" Last="?" Suffix="?"/>
				                  <!--Zero or more repetitions:-->
				                  <com:LoyaltyCard Key="?" SupplierCode="?" CardNumber="?" Status="?" MembershipStatus="?" FreeText="?" SupplierType="?" Level="?" MembershipProgram="?" PriorityCode="?">
				                     <!--Zero or more repetitions:-->
				                     <com:ProviderReservationSpecificInfo ProviderReservationLevel="?" ReservationLevel="?">
				                        <!--Zero or more repetitions:-->
				                        <com:OperatedBy>?</com:OperatedBy>
				                        <!--Optional:-->
				                        <com:ProviderReservationInfoRef Key="?"/>
				                     </com:ProviderReservationSpecificInfo>
				                  </com:LoyaltyCard>
				                  <!--0 to 9 repetitions:-->
				                  <com:DiscountCard Key="?" Code="?" Description="?" Number="?"/>
				                  <!--Optional:-->
				                  <air:FareGuaranteeInfo GuaranteeDate="?" GuaranteeType="?"/>
				               </air:PassengerType>
				               <!--Zero or more repetitions:-->
				               <com:BookingTravelerRef Key="?">
				                  <!--Zero or more repetitions:-->
				                  <com:LoyaltyCardRef Key="?"/>
				                  <!--Optional:-->
				                  <com:DriversLicenseRef Key="?"/>
				                  <!--0 to 9 repetitions:-->
				                  <com:DiscountCardRef Key="?"/>
				               </com:BookingTravelerRef>
				               <!--Optional:-->
				               <air:WaiverCode TourCode="?" TicketDesignator="?" Endorsement="?"/>
				               <!--Zero or more repetitions:-->
				               <air:PaymentRef Key="?"/>
				               <!--Optional:-->
				               <air:ChangePenalty>
				                  <!--You have a CHOICE of the next 2 items at this level-->
				                  <air:Amount>?</air:Amount>
				                  <air:Percentage>?</air:Percentage>
				               </air:ChangePenalty>
				               <!--Optional:-->
				               <air:CancelPenalty>
				                  <!--You have a CHOICE of the next 2 items at this level-->
				                  <air:Amount>?</air:Amount>
				                  <air:Percentage>?</air:Percentage>
				               </air:CancelPenalty>
				               <!--Zero or more repetitions:-->
				               <air:FeeInfo Key="?" Amount="?" Code="?" FeeToken="?" PaymentRef="?" ProviderCode="?" SupplierCode="?">
				                  <!--Zero or more repetitions:-->
				                  <air:TaxInfoRef Key="?"/>
				               </air:FeeInfo>
				               <!--Zero or more repetitions:-->
				               <air:Adjustment AdjustedTotalPrice="?" ApproximateAdjustedTotalPrice="?" BookingTravelerRef="?">
				                  <!--You have a CHOICE of the next 2 items at this level-->
				                  <air:Amount>?</air:Amount>
				                  <air:Percent>?</air:Percent>
				               </air:Adjustment>
				               <!--Zero or more repetitions:-->
				               <air:Yield Amount="?" BookingTravelerRef="?"/>
				               <!--Optional:-->
				               <air:AirPricingModifiers ProhibitMinStayFares="false" ProhibitMaxStayFares="false" CurrencyType="?" ProhibitAdvancePurchaseFares="false" ProhibitNonRefundableFares="false" ProhibitRestrictedFares="false" FaresIndicator="?" FiledCurrency="?" PlatingCarrier="?" ETicketability="?" AccountCodeFaresOnly="?" Key="?" ProhibitNonExchangeableFares="false" ForceSegmentSelect="false">
				                  <!--Optional:-->
				                  <air:PermittedBookingCodes>
				                     <!--1 or more repetitions:-->
				                     <air:BookingCode Code="?"/>
				                  </air:PermittedBookingCodes>
				                  <!--Optional:-->
				                  <air:ProhibitedBookingCodes>
				                     <!--1 or more repetitions:-->
				                     <air:BookingCode Code="?"/>
				                  </air:ProhibitedBookingCodes>
				                  <!--Optional:-->
				                  <air:ProhibitedRuleCategories>
				                     <!--1 or more repetitions:-->
				                     <air:FareRuleCategory Category="?"/>
				                  </air:ProhibitedRuleCategories>
				                  <!--Optional:-->
				                  <air:AccountCodes>
				                     <!--1 or more repetitions:-->
				                     <com:AccountCode Code="?" ProviderCode="?" SupplierCode="?" Type="?"/>
				                  </air:AccountCodes>
				                  <!--Optional:-->
				                  <air:PermittedCabins>
				                     <!--1 to 3 repetitions:-->
				                     <air:CabinClass Type="?"/>
				                  </air:PermittedCabins>
				                  <!--Optional:-->
				                  <air:ContractCodes>
				                     <!--1 or more repetitions:-->
				                     <air:ContractCode Code="?" ProviderCode="?" SupplierCode="?"/>
				                  </air:ContractCodes>
				                  <!--Optional:-->
				                  <air:ExemptTaxes AllTaxes="?" TaxTerritory="?" CompanyName="?">
				                     <!--Zero or more repetitions:-->
				                     <air:CountryCode>?</air:CountryCode>
				                     <!--Zero or more repetitions:-->
				                     <air:TaxCategory>?</air:TaxCategory>
				                  </air:ExemptTaxes>
				                  <!--Optional:-->
				                  <air:PenaltyFareInformation ProhibitPenaltyFares="?">
				                     <!--Optional:-->
				                     <air:PenaltyInfo>
				                        <!--You have a CHOICE of the next 2 items at this level-->
				                        <air:Amount>?</air:Amount>
				                        <air:Percentage>?</air:Percentage>
				                     </air:PenaltyInfo>
				                  </air:PenaltyFareInformation>
				                  <!--0 to 9 repetitions:-->
				                  <com:DiscountCard Key="?" Code="?" Description="?" Number="?"/>
				                  <!--Optional:-->
				                  <air:PromoCodes>
				                     <!--1 or more repetitions:-->
				                     <air:PromoCode Code="?" ProviderCode="?" SupplierCode="?"/>
				                  </air:PromoCodes>
				               </air:AirPricingModifiers>
				               <!--Optional:-->
				               <air:TicketingModifiersRef Key="?"/>
				               <!--Zero or more repetitions:-->
				               <air:AirSegmentPricingModifiers AirSegmentRef="?" CabinClass="?" AccountCode="?" ProhibitAdvancePurchaseFares="false" ProhibitNonRefundableFares="false" ProhibitPenaltyFares="false" FareBasisCode="?" FareBreak="?">
				                  <!--Optional:-->
				                  <air:PermittedBookingCodes>
				                     <!--1 or more repetitions:-->
				                     <air:BookingCode Code="?"/>
				                  </air:PermittedBookingCodes>
				               </air:AirSegmentPricingModifiers>
				            </air:AirPricingInfo>
				            <!--Zero or more repetitions:-->
				            <air:FareNote Key="?" Precedence="?" NoteName="?">?</air:FareNote>
				            <!--Zero or more repetitions:-->
				            <air:FareNoteRef Key="?"/>
				            <!--Zero or more repetitions:-->
				            <air:Connection ChangeOfPlane="false" ChangeOfTerminal="false" ChangeOfAirport="false" StopOver="false" MinConnectionTime="?" Duration="?" SegmentIndex="?" FlightDetailsIndex="?" IncludeStopOverToFareQuote="?">
				               <!--Optional:-->
				               <air:FareNote Key="?" Precedence="?" NoteName="?">?</air:FareNote>
				            </air:Connection>
				            <!--Zero or more repetitions:-->
				            <air:MarriageGroup>
				               <!--1 or more repetitions:-->
				               <air:SegmentIndex>?</air:SegmentIndex>
				            </air:MarriageGroup>
				            <!--Zero or more repetitions:-->
				            <com:MetaData Key="?" Value="?"/>
				            <!--Zero or more repetitions:-->
				            <air:AirPricingResultMessage Code="?" Type="?">?</air:AirPricingResultMessage>
				            <!--Zero or more repetitions:-->
				            <air:FeeInfo Key="?" Amount="?" Code="?" FeeToken="?" PaymentRef="?" ProviderCode="?" SupplierCode="?">
				               <!--Zero or more repetitions:-->
				               <air:TaxInfoRef Key="?"/>
				            </air:FeeInfo>
				            <!--Zero or more repetitions:-->
				            <air:TaxInfo Key="?" Category="?" CarrierDefinedCategory="?" SegmentRef="?" FlightDetailsRef="?" CouponRef="?" Amount="?" OriginAirport="?" DestinationAirport="?" CountryCode="?" FareInfoRef="?" TaxExempted="?" ProviderCode="?" SupplierCode="?">
				               <!--Zero or more repetitions:-->
				               <air:TaxDetail Amount="?" OriginAirport="?" DestinationAirport="?" CountryCode="?" FareInfoRef="?"/>
				            </air:TaxInfo>
				            <!--Zero or more repetitions:-->
				            <air:AirItinerarySolutionRef Key="?"/>
				            <!--Zero or more repetitions:-->
				            <com:HostToken Host="?" Key="?">?</com:HostToken>
				            <!--Optional:-->
				            <air:OptionalServices>
				               <!--Optional:-->
				               <air:OptionalServicesTotal TotalPrice="?" BasePrice="?" ApproximateTotalPrice="?" ApproximateBasePrice="?" EquivalentBasePrice="?" Taxes="?" Fees="?" Services="?">
				                  <!--Zero or more repetitions:-->
				                  <air:TaxInfo Key="?" Category="?" CarrierDefinedCategory="?" SegmentRef="?" FlightDetailsRef="?" CouponRef="?" Amount="?" OriginAirport="?" DestinationAirport="?" CountryCode="?" FareInfoRef="?" TaxExempted="?" ProviderCode="?" SupplierCode="?">
				                     <!--Zero or more repetitions:-->
				                     <air:TaxDetail Amount="?" OriginAirport="?" DestinationAirport="?" CountryCode="?" FareInfoRef="?"/>
				                  </air:TaxInfo>
				                  <!--Zero or more repetitions:-->
				                  <air:FeeInfo Key="?" Amount="?" Code="?" FeeToken="?" PaymentRef="?" ProviderCode="?" SupplierCode="?">
				                     <!--Zero or more repetitions:-->
				                     <air:TaxInfoRef Key="?"/>
				                  </air:FeeInfo>
				               </air:OptionalServicesTotal>
				               <!--1 or more repetitions:-->
				               <air:OptionalService ProviderCode="?" SupplierCode="?" OptionalServicesRuleRef="?" Type="?" Confirmation="?" SecondaryType="?" PurchaseWindow="?" Priority="?" Available="?" Entitled="?" PerTraveler="?" CreateDate="?" PaymentRef="?" ServiceStatus="?" Quantity="?" SequenceNumber="?" ServiceSubCode="?" SSRCode="?" IssuanceReason="?" ProviderDefinedType="?" TotalPrice="?" BasePrice="?" ApproximateTotalPrice="?" ApproximateBasePrice="?" EquivalentBasePrice="?" Taxes="?" Fees="?" Services="?" Key="?">
				                  <!--Zero or more repetitions:-->
				                  <com:ServiceData Data="?" AirSegmentRef="?" BookingTravelerRef="?"/>
				                  <!--Optional:-->
				                  <com:ServiceInfo>
				                     <!--1 or more repetitions:-->
				                     <com:Description>?</com:Description>
				                     <!--0 to 2 repetitions:-->
				                     <com:MediaItem caption="?" height="?" width="?" type="?" url="?" icon="?" sizeCode="?"/>
				                  </com:ServiceInfo>
				                  <!--Zero or more repetitions:-->
				                  <com:Remark Key="?">?</com:Remark>
				                  <!--Zero or more repetitions:-->
				                  <air:TaxInfo Key="?" Category="?" CarrierDefinedCategory="?" SegmentRef="?" FlightDetailsRef="?" CouponRef="?" Amount="?" OriginAirport="?" DestinationAirport="?" CountryCode="?" FareInfoRef="?" TaxExempted="?" ProviderCode="?" SupplierCode="?">
				                     <!--Zero or more repetitions:-->
				                     <air:TaxDetail Amount="?" OriginAirport="?" DestinationAirport="?" CountryCode="?" FareInfoRef="?"/>
				                  </air:TaxInfo>
				                  <!--Zero or more repetitions:-->
				                  <air:FeeInfo Key="?" Amount="?" Code="?" FeeToken="?" PaymentRef="?" ProviderCode="?" SupplierCode="?">
				                     <!--Zero or more repetitions:-->
				                     <air:TaxInfoRef Key="?"/>
				                  </air:FeeInfo>
				                  <!--Optional:-->
				                  <air:EMD FulfillmentType="?" AssociatedItem="?" AvailabilityChargeIndicator="?" RefundReissueIndicator="?" Commissionable="?" MileageIndicator="?" Location="?" Date="?"/>
				               </air:OptionalService>
				               <!--Zero or more repetitions:-->
				               <air:GroupedOptions>
				                  <!--2 or more repetitions:-->
				                  <air:GroupedOption OptionalServiceRef="?"/>
				                  <air:GroupedOption OptionalServiceRef="?"/>
				               </air:GroupedOptions>
				               <!--Zero or more repetitions:-->
				               <air:OptionalServiceRules Key="?">
				                  <!--Optional:-->
				                  <com:ApplicationRules RequiredForAllTravelers="?" RequiredForAllSegments="?" RequiredForAllSegmentsInOD="?" UnselectedOptionRequired="?" SecondaryOptionCodeRequired="?"/>
				                  <!--Optional:-->
				                  <com:ApplicationLevel ApplicableLevels="?" ProviderDefinedApplicableLevels="?">
				                     <!--Optional:-->
				                     <com:ApplicationLimits>
				                        <!--1 to 10 repetitions:-->
				                        <com:ApplicationLimit ApplicableLevel="?" ProviderDefinedApplicableLevels="?" MaximumQuantity="?" MinimumQuantity="?"/>
				                     </com:ApplicationLimits>
				                     <!--Zero or more repetitions:-->
				                     <com:ServiceData Data="?" AirSegmentRef="?" BookingTravelerRef="?"/>
				                  </com:ApplicationLevel>
				                  <!--Optional:-->
				                  <com:ModifyRules SupportedModifications="?" ProviderDefinedModificationType="?">
				                     <!--1 or more repetitions:-->
				                     <com:ModifyRule Modification="?" AutomaticallyAppliedOnAdd="false" CanDelete="?" CanAdd="?" Refundable="?" ProviderDefinedModificationType="?"/>
				                  </com:ModifyRules>
				                  <!--Optional:-->
				                  <com:SecondaryTypeRules>
				                     <!--1 or more repetitions:-->
				                     <com:SecondaryTypeRule SecondaryType="?">
				                        <!--0 to 10 repetitions:-->
				                        <com:ApplicationLimit ApplicableLevel="?" ProviderDefinedApplicableLevels="?" MaximumQuantity="?" MinimumQuantity="?"/>
				                     </com:SecondaryTypeRule>
				                  </com:SecondaryTypeRules>
				                  <!--0 to 5 repetitions:-->
				                  <com:Remarks Formatted="?" Language="?" TextFormat="?">?</com:Remarks>
				               </air:OptionalServiceRules>
				            </air:OptionalServices>
				            <!--Optional:-->
				            <air:AvailableSSR>
				               <!--Zero or more repetitions:-->
				               <com:SSR Key="?" SegmentRef="?" PassiveSegmentRef="?" ProviderReservationInfoRef="?" Type="?" Status="?" FreeText="?" Carrier="?" CarrierSpecificText="?" Description="?" ProviderDefinedType="?" SSRRuleRef="?" URL="?"/>
				               <!--Zero or more repetitions:-->
				               <air:SSRRules Key="?">
				                  <!--Optional:-->
				                  <com:ApplicationRules RequiredForAllTravelers="?" RequiredForAllSegments="?" RequiredForAllSegmentsInOD="?" UnselectedOptionRequired="?" SecondaryOptionCodeRequired="?"/>
				                  <!--Optional:-->
				                  <com:ApplicationLevel ApplicableLevels="?" ProviderDefinedApplicableLevels="?">
				                     <!--Optional:-->
				                     <com:ApplicationLimits>
				                        <!--1 to 10 repetitions:-->
				                        <com:ApplicationLimit ApplicableLevel="?" ProviderDefinedApplicableLevels="?" MaximumQuantity="?" MinimumQuantity="?"/>
				                     </com:ApplicationLimits>
				                     <!--Zero or more repetitions:-->
				                     <com:ServiceData Data="?" AirSegmentRef="?" BookingTravelerRef="?"/>
				                  </com:ApplicationLevel>
				                  <!--Optional:-->
				                  <com:ModifyRules SupportedModifications="?" ProviderDefinedModificationType="?">
				                     <!--1 or more repetitions:-->
				                     <com:ModifyRule Modification="?" AutomaticallyAppliedOnAdd="false" CanDelete="?" CanAdd="?" Refundable="?" ProviderDefinedModificationType="?"/>
				                  </com:ModifyRules>
				                  <!--Optional:-->
				                  <com:SecondaryTypeRules>
				                     <!--1 or more repetitions:-->
				                     <com:SecondaryTypeRule SecondaryType="?">
				                        <!--0 to 10 repetitions:-->
				                        <com:ApplicationLimit ApplicableLevel="?" ProviderDefinedApplicableLevels="?" MaximumQuantity="?" MinimumQuantity="?"/>
				                     </com:SecondaryTypeRule>
				                  </com:SecondaryTypeRules>
				                  <!--0 to 5 repetitions:-->
				                  <com:Remarks Formatted="?" Language="?" TextFormat="?">?</com:Remarks>
				               </air:SSRRules>
				            </air:AvailableSSR>
				         </air:AirPricingSolution>
				         <!--Zero or more repetitions:-->
				         <com:ActionStatus Type="?" TicketDate="?" Key="?" ProviderReservationInfoRef="?" QueueCategory="?" AirportCode="?" ProviderCode="?" SupplierCode="?" PseudoCityCode="?" AccountCode="?">
				            <!--Optional:-->
				            <com:Remark Key="?">?</com:Remark>
				         </com:ActionStatus>
				         <!--Zero or more repetitions:-->
				         <com:FormOfPayment Key="?" Type="?" FulfillmentType="?" FulfillmentLocation="?" FulfillmentIDType="?" FulfillmentIDNumber="?" IsAgentType="false" AgentText="?" ReuseFOP="?" ExternalReference="?" Reusable="false">
				            <!--You have a CHOICE of the next 11 items at this level-->
				            <!--Optional:-->
				            <com:CreditCard Type="?" Number="?" ExpDate="?" Name="?" ProfileID="?" Key="?" CVV="?" ApprovalCode="?" ExtendedPayment="?" CustomerReference="?" AcceptanceOverride="?" ThirdPartyPayment="false">
				               <!--Optional:-->
				               <com:PhoneNumber Key="?" Type="?" Location="?" CountryCode="?" AreaCode="?" Number="?" Extension="?" Text="?">
				                  <!--Zero or more repetitions:-->
				                  <com:ProviderReservationInfoRef Key="?"/>
				               </com:PhoneNumber>
				               <!--Optional:-->
				               <com:BillingAddress Key="?">
				                  <!--Optional:-->
				                  <com:AddressName>?</com:AddressName>
				                  <!--0 to 5 repetitions:-->
				                  <com:Street>?</com:Street>
				                  <!--Optional:-->
				                  <com:City>?</com:City>
				                  <!--Optional:-->
				                  <com:State>?</com:State>
				                  <!--Optional:-->
				                  <com:PostalCode>?</com:PostalCode>
				                  <!--Optional:-->
				                  <com:Country>?</com:Country>
				                  <!--Zero or more repetitions:-->
				                  <com:ProviderReservationInfoRef Key="?"/>
				               </com:BillingAddress>
				            </com:CreditCard>
				            <!--Optional:-->
				            <com:Certificate Number="?" Amount="?" DiscountAmount="?" DiscountPercentage="?" NotValidBefore="?" NotValidAfter="?"/>
				            <!--Optional:-->
				            <com:TicketNumber>?</com:TicketNumber>
				            <!--Optional:-->
				            <com:Check MICRNumber="?" RoutingNumber="?" AccountNumber="?" CheckNumber="?"/>
				            <!--Optional:-->
				            <com:DebitCard Type="?" Number="?" ExpDate="?" Name="?" ProfileID="?" Key="?" CVV="?" ApprovalCode="?" IssueNumber="?">
				               <!--Optional:-->
				               <com:PhoneNumber Key="?" Type="?" Location="?" CountryCode="?" AreaCode="?" Number="?" Extension="?" Text="?">
				                  <!--Zero or more repetitions:-->
				                  <com:ProviderReservationInfoRef Key="?"/>
				               </com:PhoneNumber>
				               <!--Optional:-->
				               <com:BillingAddress Key="?">
				                  <!--Optional:-->
				                  <com:AddressName>?</com:AddressName>
				                  <!--0 to 5 repetitions:-->
				                  <com:Street>?</com:Street>
				                  <!--Optional:-->
				                  <com:City>?</com:City>
				                  <!--Optional:-->
				                  <com:State>?</com:State>
				                  <!--Optional:-->
				                  <com:PostalCode>?</com:PostalCode>
				                  <!--Optional:-->
				                  <com:Country>?</com:Country>
				                  <!--Zero or more repetitions:-->
				                  <com:ProviderReservationInfoRef Key="?"/>
				               </com:BillingAddress>
				            </com:DebitCard>
				            <!--Optional:-->
				            <com:Requisition Number="?" Category="?" Type="?"/>
				            <!--Optional:-->
				            <com:MiscFormOfPayment CreditCardType="?" CreditCardNumber="?" ExpDate="?" Text="?" Category="?" AcceptanceOverride="?"/>
				            <!--Optional:-->
				            <com:AgencyPayment AgencyBillingIdentifier="?" AgencyBillingNumber="?" AgencyBillingPassword="?"/>
				            <!--Optional:-->
				            <com:UnitedNations Number="?"/>
				            <!--Optional:-->
				            <com:DirectPayment Text="?"/>
				            <!--Optional:-->
				            <com:AgentVoucher Number="?"/>
				            <!--Zero or more repetitions:-->
				            <com:ProviderReservationInfoRef Key="?"/>
				            <!--Zero or more repetitions:-->
				            <com:SegmentRef Key="?"/>
				         </com:FormOfPayment>
				         <!--Zero or more repetitions:-->
				         <com:Payment Key="?" Type="?" FormOfPaymentRef="?" BookingTravelerRef="?" Amount="?" AmountType="?" ApproximateAmount="?" Status="?"/>
				         <!--Optional:-->
				         <com:DeliveryInfo Type="?" SignatureRequired="?" TrackingNumber="?">
				            <!--Optional:-->
				            <com:ShippingAddress Key="?">
				               <!--Optional:-->
				               <com:AddressName>?</com:AddressName>
				               <!--0 to 5 repetitions:-->
				               <com:Street>?</com:Street>
				               <!--Optional:-->
				               <com:City>?</com:City>
				               <!--Optional:-->
				               <com:State>?</com:State>
				               <!--Optional:-->
				               <com:PostalCode>?</com:PostalCode>
				               <!--Optional:-->
				               <com:Country>?</com:Country>
				               <!--Zero or more repetitions:-->
				               <com:ProviderReservationInfoRef Key="?"/>
				            </com:ShippingAddress>
				            <!--Optional:-->
				            <com:PhoneNumber Key="?" Type="?" Location="?" CountryCode="?" AreaCode="?" Number="?" Extension="?" Text="?">
				               <!--Zero or more repetitions:-->
				               <com:ProviderReservationInfoRef Key="?"/>
				            </com:PhoneNumber>
				            <!--Optional:-->
				            <com:Email Key="?" Type="?" Comment="?" EmailID="?">
				               <!--Zero or more repetitions:-->
				               <com:ProviderReservationInfoRef Key="?"/>
				            </com:Email>
				            <!--Zero or more repetitions:-->
				            <com:GeneralRemark Key="?" Category="?" TypeInGds="?" SupplierType="?" ProviderReservationInfoRef="?" ProviderCode="?" SupplierCode="?" Direction="?" CreateDate="?" UseProviderNativeMode="false">
				               <com:RemarkData>?</com:RemarkData>
				               <!--Zero or more repetitions:-->
				               <com:BookingTravelerRef>?</com:BookingTravelerRef>
				            </com:GeneralRemark>
				            <!--Zero or more repetitions:-->
				            <com:ProviderReservationInfoRef Key="?"/>
				         </com:DeliveryInfo>
				         <!--Zero or more repetitions:-->
				         <air:AutoSeatAssignment SegmentRef="?" Smoking="false" SeatType="?" Group="false" BookingTravelerRef="?"/>
				         <!--Zero or more repetitions:-->
				         <air:SpecificSeatAssignment BookingTravelerRef="?" SegmentRef="?" FlightDetailRef="?" SeatId="?"/>
				         <!--Zero or more repetitions:-->
				         <air:AssociatedRemark ProviderReservationInfoRef="?" ProviderCode="?" Key="?" SegmentRef="?">
				            <com:RemarkData>?</com:RemarkData>
				            <!--Zero or more repetitions:-->
				            <com:BookingTravelerRef>?</com:BookingTravelerRef>
				         </air:AssociatedRemark>
				         <!--Zero or more repetitions:-->
				         <air:PocketItineraryRemark ProviderReservationInfoRef="?" ProviderCode="?" Key="?" SegmentRef="?">
				            <com:RemarkData>?</com:RemarkData>
				            <!--Zero or more repetitions:-->
				            <com:BookingTravelerRef>?</com:BookingTravelerRef>
				         </air:PocketItineraryRemark>
				      </air:AirCreateReservationReq>
				   </soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>

		<cfreturn message/>
	</cffunction>

<!---
parseSegmentKeys
--->
	<cffunction name="parseSegmentKeys" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stSegmentKeys = {}>
		<cfset local.sIndex = ''>
		<!--- Create list of fields that make up a distint segment. --->
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber','TravelTime']>
		<!--- Loop through results. --->
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<cfif stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<!--- Build up the distinct segment string. --->
					<cfset sIndex = ''>
					<cfloop array="#aSegmentKeys#" index="local.sCol">
						<cfset sIndex &= stAirSegment.XMLAttributes[sCol]>
					</cfloop>
					<!--- Create a look up structure for the primary key. --->
					<cfset stSegmentKeys[stAirSegment.XMLAttributes.Key] = {
						HashIndex	: 	application.objUAPI.HashNumeric(sIndex),
						Index		: 	sIndex
					}>
				</cfloop>
			</cfif>
		</cfloop>
			
		<cfreturn stSegmentKeys />
	</cffunction>

<!---
addSegmentRefs
--->
	<cffunction name="addSegmentRefs" output="false">
		<cfargument name="stResponse">
		<cfargument name="stSegmentKeys">
		
		<cfset local.sAPIKey = ''>
		<cfset local.cnt = 0>
		<cfloop array="#arguments.stResponse#" index="local.stAirItinerarySolution">
			<cfif stAirItinerarySolution.XMLName EQ 'air:AirItinerarySolution'>
				<cfloop array="#stAirItinerarySolution.XMLChildren#" index="local.stAirSegmentRef">
					<cfif stAirSegmentRef.XMLName EQ 'air:AirSegmentRef'>
						<cfset sAPIKey = stAirSegmentRef.XMLAttributes.Key>
						<cfset arguments.stSegmentKeys[sAPIKey].nLocation = cnt>
						<cfset cnt++>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
			
		<cfreturn arguments.stSegmentKeys />
	</cffunction>

<!---
parseKeyLookup - schedule
--->
	<cffunction name="parseKeyLookup" output="false">
		<cfargument name="stSegmentKeys">
		
		<cfset local.stSegmentKeyLookUp = {}>
		<cfloop collection="#arguments.stSegmentKeys#" item="local.sKey">
			<cfset stSegmentKeyLookUp[stSegmentKeys[sKey].nLocation] = sKey>
		</cfloop>
		
		<cfreturn stSegmentKeyLookUp />
	</cffunction>

<!---
parseSegments
--->
	<cffunction name="parseSegments" output="false">
		<cfargument name="stResponse"		required="true">
		<cfargument name="stSegmentKeys"	required="true">
		
		<cfset local.stSegments = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<cfif stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<cfset local.dArrivalGMT = stAirSegment.XMLAttributes.ArrivalTime>
					<cfset local.dArrivalTime = GetToken(dArrivalGMT, 1, '.')>
					<cfset local.dArrivalOffset = GetToken(GetToken(dArrivalGMT, 2, '-'), 1, ':')>
					<cfset local.dDepartGMT = stAirSegment.XMLAttributes.DepartureTime>
					<cfset local.dDepartTime = GetToken(dDepartGMT, 1, '.')>
					<cfset local.dDepartOffset = GetToken(GetToken(dDepartGMT, 2, '-'), 1, ':')>
					<cfset stSegments[arguments.stSegmentKeys[stAirSegment.XMLAttributes.Key].HashIndex] = {
						Arrival				: dArrivalGMT,
						ArrivalTime			: ParseDateTime(dArrivalTime),
						ArrivalGMT			: ParseDateTime(DateAdd('h', dArrivalOffset, dArrivalTime)),
						Carrier 			: stAirSegment.XMLAttributes.Carrier,
						ChangeOfPlane		: stAirSegment.XMLAttributes.ChangeOfPlane EQ 'true',
						Departure			: dDepartGMT,
						DepartureTime		: ParseDateTime(dDepartTime),
						DepartureGMT		: ParseDateTime(DateAdd('h', dDepartOffset, dDepartTime)),
						Destination			: stAirSegment.XMLAttributes.Destination,
						Equipment			: stAirSegment.XMLAttributes.Equipment,
						FlightNumber		: stAirSegment.XMLAttributes.FlightNumber,
						FlightTime			: stAirSegment.XMLAttributes.FlightTime,
						Group				: stAirSegment.XMLAttributes.Group,
						Origin				: stAirSegment.XMLAttributes.Origin,
						TravelTime			: stAirSegment.XMLAttributes.TravelTime
					}>
				</cfloop>
			</cfif>
		</cfloop>
			
		<cfreturn stSegments />
	</cffunction>

<!---
parseConnections - schedule
--->
	<cffunction name="parseConnections" output="false">
		<cfargument name="stResponse">
		<cfargument name="stSegments">
		<cfargument name="stSegmentKeys">
		<cfargument name="stSegmentKeyLookUp">
		
		<!--- Create a structure to hold FIRST connection points --->
		<cfset local.stSegmentIndex = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirItinerarySolution">
			<cfif stAirItinerarySolution.XMLName EQ 'air:AirItinerarySolution'>
				<cfloop array="#stAirItinerarySolution.XMLChildren#" index="local.stConnection">
					<cfif stConnection.XMLName EQ 'air:Connection'>
						<cfset stSegmentIndex[stConnection.XMLAttributes.SegmentIndex] = StructNew('linked')>
						<cfset stSegmentIndex[stConnection.XMLAttributes.SegmentIndex][1] = stSegments[stSegmentKeys[stSegmentKeyLookUp[stConnection.XMLAttributes.SegmentIndex]].HashIndex]>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		<!--- Add to that structure the missing connection points --->
		<cfset local.stTrips = {}>
		<cfset local.nCount = 0>
		<cfset local.nSegNum = 1>
		<cfset local.nMaxCount = ArrayLen(StructKeyArray(stSegmentKeys))>
		<cfloop collection="#stSegmentIndex#" item="local.nIndex">
			<cfset nCount = nIndex>
			<cfset nSegNum = 1>
			<cfloop condition="NOT StructKeyExists(stSegmentIndex, nCount+1) AND nCount LT nMaxCount AND StructKeyExists(stSegmentKeyLookUp, nCount+1)">
				<cfset nSegNum++>
				<cfset stSegmentIndex[nIndex][nSegNum] = stSegments[stSegmentKeys[stSegmentKeyLookUp[nCount+1]].HashIndex]>
				<cfset nCount++>
			</cfloop>
		</cfloop>
		<!--- Create an appropriate trip key --->
		<cfset local.stTrips = {}>
		<cfset local.sIndex = ''>
		<cfset local.aCarriers = {}>
		<cfset local.nHashNumeric = ''>
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<cfloop collection="#stSegmentIndex#" item="local.nIndex">
			<cfloop collection="#stSegmentIndex[nIndex]#" item="local.sSegment">
				<cfset sIndex = ''>
				<cfloop array="#aSegmentKeys#" index="local.stSegment">
					<cfset sIndex &= stSegmentIndex[nIndex][sSegment][stSegment]>
				</cfloop>
			</cfloop>
			<cfset nHashNumeric = application.objUAPI.hashNumeric(sIndex)>
			<cfset stTrips[nHashNumeric].Segments = stSegmentIndex[nIndex]>
			<cfset stTrips[nHashNumeric].Class = 'X'>
			<cfset stTrips[nHashNumeric].Ref = 'X'>
		</cfloop>
		
		<cfreturn stTrips />
	</cffunction>
	
</cfcomponent>