<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:air="http://www.travelport.com/schema/air_v18_0" xmlns:com="http://www.travelport.com/schema/common_v15_0">
   <soapenv:Header/>
   <soapenv:Body>
      <air:LowFareSearchReq TraceId="?" TokenId="?" AuthorizedBy="?" TargetBranch="?" OverrideLogging="?" EnablePointToPointSearch="false" EnablePointToPointAlternates="false" MaxNumberOfExpertSolutions="0">
         <com:BillingPointOfSaleInfo OriginApplication="?" CIDBNumber="?"/>
         <!--Zero or more repetitions:-->
         <com:AgentIDOverride SupplierCode="?" ProviderCode="?" AgentID="?"/>
         <!--Zero or more repetitions:-->
         <com:NextResultReference ProviderCode="?">?</com:NextResultReference>
         <!--You have a CHOICE of the next 2 items at this level-->
         <!--1 to 9 repetitions:-->
         <air:SearchAirLeg>
            <!--1 or more repetitions:-->
            <air:SearchOrigin>
               <!--You have a CHOICE of the next 5 items at this level-->
               <!--Optional:-->
               <com:Airport Code="?"/>
               <!--Optional:-->
               <com:City Code="?"/>
               <!--Optional:-->
               <com:CityOrAirport Code="?" PreferCity="false"/>
               <!--Optional:-->
               <com:CoordinateLocation latitude="?" longitude="?"/>
               <!--Optional:-->
               <com:RailLocation Code="?"/>
               <!--Optional:-->
               <com:Distance Units="MI" Value="?" Direction="?"/>
            </air:SearchOrigin>
            <!--1 or more repetitions:-->
            <air:SearchDestination>
               <!--You have a CHOICE of the next 5 items at this level-->
               <!--Optional:-->
               <com:Airport Code="?"/>
               <!--Optional:-->
               <com:City Code="?"/>
               <!--Optional:-->
               <com:CityOrAirport Code="?" PreferCity="false"/>
               <!--Optional:-->
               <com:CoordinateLocation latitude="?" longitude="?"/>
               <!--Optional:-->
               <com:RailLocation Code="?"/>
               <!--Optional:-->
               <com:Distance Units="MI" Value="?" Direction="?"/>
            </air:SearchDestination>
            <!--You have a CHOICE of the next 2 items at this level-->
            <!--1 or more repetitions:-->
            <air:SearchDepTime PreferredTime="?">
               <!--You have a CHOICE of the next 2 items at this level-->
               <!--Optional:-->
               <com:TimeRange EarliestTime="?" LatestTime="?"/>
               <!--Optional:-->
               <com:SpecificTime Time="?"/>
               <!--Optional:-->
               <com:SearchExtraDays DaysBefore="?" DaysAfter="?"/>
            </air:SearchDepTime>
            <!--1 or more repetitions:-->
            <air:SearchArvTime PreferredTime="?">
               <!--You have a CHOICE of the next 2 items at this level-->
               <!--Optional:-->
               <com:TimeRange EarliestTime="?" LatestTime="?"/>
               <!--Optional:-->
               <com:SpecificTime Time="?"/>
            </air:SearchArvTime>
            <!--Optional:-->
            <air:AirLegModifiers RequireSingleCarrier="true" ProhibitOvernightLayovers="false" MaxConnectionTime="?" ReturnFirstAvailableOnly="?" AllowDirectAccess="false" MaxConnections="2" MaxStops="2" ProhibitMultiAirportConnection="?" PreferNonStop="false">
               <!--Optional:-->
               <air:PreferredCabins>
                  <air:CabinClass Type="?"/>
               </air:PreferredCabins>
               <!--Optional:-->
               <air:ProhibitedCabins>
                  <!--1 to 3 repetitions:-->
                  <air:CabinClass Type="?"/>
               </air:ProhibitedCabins>
               <!--Optional:-->
               <air:PreferredCarriers>
                  <!--1 or more repetitions:-->
                  <com:Carrier Code="?"/>
               </air:PreferredCarriers>
               <!--Optional:-->
               <air:PermittedCabins>
                  <!--1 to 5 repetitions:-->
                  <air:CabinClass Type="?"/>
               </air:PermittedCabins>
               <!--Optional:-->
               <air:ProhibitedCarriers>
                  <!--1 or more repetitions:-->
                  <com:Carrier Code="?"/>
               </air:ProhibitedCarriers>
               <!--Optional:-->
               <air:PermittedCarriers>
                  <!--1 or more repetitions:-->
                  <com:Carrier Code="?"/>
               </air:PermittedCarriers>
               <!--Optional:-->
               <air:PermittedConnectionPoints>
                  <!--1 or more repetitions:-->
                  <com:ConnectionPoint>
                     <!--You have a CHOICE of the next 3 items at this level-->
                     <!--Optional:-->
                     <com:Airport Code="?"/>
                     <!--Optional:-->
                     <com:City Code="?"/>
                     <!--Optional:-->
                     <com:CityOrAirport Code="?" PreferCity="false"/>
                  </com:ConnectionPoint>
               </air:PermittedConnectionPoints>
               <!--Optional:-->
               <air:ProhibitedConnectionPoints>
                  <!--1 or more repetitions:-->
                  <com:ConnectionPoint>
                     <!--You have a CHOICE of the next 3 items at this level-->
                     <!--Optional:-->
                     <com:Airport Code="?"/>
                     <!--Optional:-->
                     <com:City Code="?"/>
                     <!--Optional:-->
                     <com:CityOrAirport Code="?" PreferCity="false"/>
                  </com:ConnectionPoint>
               </air:ProhibitedConnectionPoints>
               <!--Optional:-->
               <air:PermittedBookingCodes>
                  <!--1 or more repetitions:-->
                  <air:BookingCode Code="?"/>
               </air:PermittedBookingCodes>
               <!--Optional:-->
               <air:PreferredAlliances>
                  <!--1 or more repetitions:-->
                  <air:Alliance Code="?"/>
               </air:PreferredAlliances>
               <!--Optional:-->
               <air:DisfavoredAlliances>
                  <!--1 or more repetitions:-->
                  <air:Alliance Code="?"/>
               </air:DisfavoredAlliances>
            </air:AirLegModifiers>
         </air:SearchAirLeg>
         <!--1 or more repetitions:-->
         <air:SearchSpecificAirSegment DepartureTime="?" Carrier="?" FlightNumber="?" Origin="?" Destination="?" SegmentIndex="?"/>
         <!--Optional:-->
         <air:AirSearchModifiers DistanceType="MI" IncludeFlightDetails="true" RequireSingleCarrier="true" AllowChangeOfAirport="true" ProhibitOvernightLayovers="false" MaxSolutions="300" MaxConnections="2" MaxStops="2" MaxConnectionTime="?" SearchWeekends="?" IncludeExtraSolutions="?" ProhibitMultiAirportConnection="?" PreferNonStop="false">
            <!--Optional:-->
            <air:DisfavoredProviders>
               <!--1 or more repetitions:-->
               <com:Provider Code="?"/>
            </air:DisfavoredProviders>
            <!--Optional:-->
            <air:PreferredProviders>
               <!--1 or more repetitions:-->
               <com:Provider Code="?"/>
            </air:PreferredProviders>
            <!--Optional:-->
            <air:DisfavoredCarriers>
               <!--1 or more repetitions:-->
               <com:Carrier Code="?"/>
            </air:DisfavoredCarriers>
            <!--Optional:-->
            <air:PreferredCarriers>
               <!--1 or more repetitions:-->
               <com:Carrier Code="?"/>
            </air:PreferredCarriers>
            <!--Optional:-->
            <air:PermittedCarriers>
               <!--1 or more repetitions:-->
               <com:Carrier Code="?"/>
            </air:PermittedCarriers>
            <!--Optional:-->
            <air:ProhibitedCarriers>
               <!--1 or more repetitions:-->
               <com:Carrier Code="?"/>
            </air:ProhibitedCarriers>
            <!--Optional:-->
            <air:PreferredAlliances>
               <!--1 or more repetitions:-->
               <air:Alliance Code="?"/>
            </air:PreferredAlliances>
            <!--Optional:-->
            <air:DisfavoredAlliances>
               <!--1 or more repetitions:-->
               <air:Alliance Code="?"/>
            </air:DisfavoredAlliances>
         </air:AirSearchModifiers>
         <!--1 to 9 repetitions:-->
         <com:SearchPassenger Code="?" Age="?" DOB="?" Gender="?" PricePTCOnly="?" BookingTravelerRef="?" Key="?">
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
         </com:SearchPassenger>
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
         <air:Enumeration>
            <!--1 or more repetitions:-->
            <air:SolutionGroup Count="?" TripType="?" Diversification="?" Tag="?" Primary="false">
               <!--Optional:-->
               <air:PermittedAccountCodes>
                  <!--1 or more repetitions:-->
                  <com:AccountCode Code="?" ProviderCode="?" SupplierCode="?" Type="?"/>
               </air:PermittedAccountCodes>
               <!--Optional:-->
               <air:PreferredAccountCodes>
                  <!--1 or more repetitions:-->
                  <com:AccountCode Code="?" ProviderCode="?" SupplierCode="?" Type="?"/>
               </air:PreferredAccountCodes>
               <!--Optional:-->
               <air:ProhibitedAccountCodes>
                  <!--1 or more repetitions:-->
                  <com:AccountCode Code="?" ProviderCode="?" SupplierCode="?" Type="?"/>
               </air:ProhibitedAccountCodes>
               <!--Optional:-->
               <air:PermittedPointOfSales>
                  <!--1 or more repetitions:-->
                  <com:PointOfSale ProviderCode="?" PseudoCityCode="?" Key="?"/>
               </air:PermittedPointOfSales>
               <!--Optional:-->
               <air:ProhibitedPointOfSales>
                  <!--1 or more repetitions:-->
                  <com:PointOfSale ProviderCode="?" PseudoCityCode="?" Key="?"/>
               </air:ProhibitedPointOfSales>
            </air:SolutionGroup>
         </air:Enumeration>
         <!--0 to 5 repetitions:-->
         <com:PointOfSale ProviderCode="?" PseudoCityCode="?" Key="?"/>
         <!--Optional:-->
         <air:AirExchangeModifiers BookingDate="?" TicketingDate="?" AccountCode="?" TicketDesignator="?" AllowPenaltyFares="true" PrivateFaresOnly="false" UniversalRecordLocatorCode="?" ProviderLocatorCode="?" ProviderCode="?"/>
      </air:LowFareSearchReq>
   </soapenv:Body>
</soapenv:Envelope>