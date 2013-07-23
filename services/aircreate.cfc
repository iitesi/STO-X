<cfcomponent output="false" accessors="true">

	<cfproperty name="UAPI">
	<cfproperty name="AirParse">
	<cfproperty name="AirPrice">
	<cfproperty name="TerminalEntry">

<!---
init
--->
	<cffunction name="init" output="false">
		<cfargument name="UAPI">
		<cfargument name="AirParse">
		<cfargument name="AirPrice">
		<cfargument name="TerminalEntry">

		<cfset setUAPI(arguments.UAPI)>
		<cfset setAirParse(arguments.AirParse)>
		<cfset setAirPrice(arguments.AirPrice)>
		<cfset setTerminalEntry(arguments.TerminalEntry)>

		<cfreturn this>
	</cffunction>

<!---
doAirPrice
--->
	<cffunction name="doAirCreate" output="false">
		<cfargument name="SearchID" required="true">
		<cfargument name="Account" 	required="true">
		<cfargument name="Filter" 	required="true">
		<cfargument name="Policy" 	required="true">
		<cfargument name="stAir" 	required="true">

		<cfset local.locator = ''>
		<cfset local.Error = {}>
		<!---todo:  bad coding, need to pass in--->
		<cfset local.Traveler = session.searches[arguments.SearchID].stTravelers[1]>
		<cfset local.OrigTraveler = session.OrigTraveler[1]>

		<!---Reprice the flight to get the needed information for the sell--->
		<cfset local.stTrip		= AirPrice.doAirPrice(arguments.SearchID, arguments.Account, arguments.Policy, arguments.stAir.Class, arguments.stAir.Ref, arguments.stAir.nTrip, 0, 1)>
		<!--- <cfdump var="#stTrip#" abort="true"> --->

		<cfset local.AirPricing	= parseTripForPurchase(stTrip[structKeyList(stTrip)].sXML)>
		<!---<cfdump var="#ToString(AirPricing)#">--->

		<!---TE : Open TE session--->
		<cfset local.hostToken	= getTerminalEntry().openSession(arguments.Account, arguments.SearchID)>

		<!---TE : Read profile--->
		<cfset local.profileFound	= getTerminalEntry().readPAR(arguments.Account, hostToken, Traveler.BAR.PCC, Traveler.BAR.Name, Traveler.PAR, arguments.SearchID)>
		<!--- <cfdump var="#Response#" abort> --->

		<cfset local.Message	= prepareSoapHeader(arguments.Filter, arguments.Account, Traveler, Replace(AirPricing, '<?xml version="1.0" encoding="UTF-8"?>', ''), arguments.stAir.Carriers, profileFound, OrigTraveler)>
		<cfdump var="#Message#">

		<cfset local.sResponse 	= getUAPI().callUAPI('AirService', Message, arguments.Filter.getSearchID())>
		<!---<cfdump var="#sResponse#" abort>--->
		<cfset local.stResponse = getUAPI().formatUAPIRsp(sResponse)>

		<cfloop array="#stResponse#" index="local.nParent" item="local.stParent">
			<cfif stParent.XMLName EQ 'faultstring'>
				<!---todo:  SYSTEM ERROR | Some of the prices could not be stored because either flight departure time changes have occurred or some of the segments failed to be sold. Please verify connections, then price and store again.| NEED ATFQ/MODIFY--->
				<cfset Error.message = stParent.XMLText>
			<cfelse>
				<cfloop array="#stParent.XMLChildren#" index="local.nChildren" item="local.stChildren">
					<cfif stChildren.XMLName EQ 'universal:ProviderReservationInfo'>
						<cfset locator = stChildren.XMLAttributes.LocatorCode>
					<cfelseif stChildren.XMLName EQ 'air:AvailabilityErrorInfo'>
						<cfloop array="#stChildren.XMLChildren#" index="local.nSubChildren" item="local.stSubChildren">
							<cfif stSubChildren.XMLName EQ 'air:AirSegmentError'>
								<cfset Error.Details = stSubChildren.XMLChildren>
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		<cfdump var="#Error#">
		<cfdump var="#locator#">
		<cfif locator EQ ''>
			<cfdump var="#stTrip#">
			<cfdump var="#stResponse#" abort>
		</cfif>

		<!--- <cfset locator = 'V6GVR2'> --->

		
		<!---TE : Display PNR--->
		<cfset local.Response	= getTerminalEntry().displayPNR(arguments.Account, hostToken, locator, arguments.SearchID, true)>
		<cfdump var="#Response#">

		<!---TE : Move profile--->
		<cfset local.Response	= getTerminalEntry().moveBARPAR(arguments.Account, hostToken, Traveler.BAR.PCC, Traveler.BAR.Name, Traveler.PAR, arguments.SearchID)>
		<cfdump var="#Response#">

		<!---TE : Add received by--->
		<cfset local.Response	= getTerminalEntry().addReceivedBy(arguments.Account, hostToken, session.UserID, arguments.SearchID)>
		<cfdump var="#Response#">

		<!---TE : Remove the second name field--->
		<cfset local.Response	= getTerminalEntry().removeSecondName(arguments.Account, hostToken, arguments.SearchID)>
		<cfdump var="#Response#">

		<!---TE : Verify the stored price--->
		<cfset local.Response	= getTerminalEntry().verifyStoredFare(arguments.Account, hostToken, arguments.SearchID)>
		<cfdump var="#Response#">

		<!---TE : Queue record--->
		<cfset local.Response	= getTerminalEntry().queueRecord(arguments.Account, hostToken, arguments.SearchID)>
		<cfdump var="#Response#">

		<!---TE : Close TE session--->
		<cfset getTerminalEntry().closeSession(arguments.Account, hostToken, arguments.SearchID)>

		<cfabort>

		<!---

<!---Close the terminal entry session--->
<cfset local.stResponse = getUAPI().formatUAPIRsp(sResponse)>
<cfset local.Message	= getUAPI().closeSessionSOAP(arguments.Account, hostToken)>
<cfset local.sResponse 	= getUAPI().callUAPI('TerminalService', Message, arguments.Filter.getSearchID())>
<cfset local.successText  = stResponse[1].XMLText>
<cfdump var="#locator#">
<cfdump var="#successText#" abort>

        --->

		<cfabort>

		<cfreturn >
	</cffunction>

<!---
parseTripForPurchase
--->
	<cffunction name="parseTripForPurchase" output="false">
		<cfargument name="sXML">

		<cfset local.sXML = XMLParse(arguments.sXML)>
		<cfset sXML = sXML.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren>
		<!--- Move all AirSegment nodes into stSegments --->
		<cfset local.stSegments = {}>
		<cfloop array="#sXML#" index="local.stAirItinerary">
			<cfif stAirItinerary.XMLName EQ 'air:AirItinerary'>
				<cfloop array="#stAirItinerary.XMLChildren#" index="local.stAirSegment">
					<cfif stAirSegment.XMLName EQ 'air:AirSegment'>
						<!--- Get segment information --->
						<cfset stSegments[stAirSegment.XMLAttributes.Key] = stAirSegment>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		<!---<cfdump var="#sXML#">--->
		<cfset local.stPriceSolution = {}>
		<!--- Get AirPricingSolution node --->
		<cfloop array="#sXML#" item="local.stAirPriceResult" index="local.nAirPriceResult">
			<cfif stAirPriceResult.XMLName EQ 'air:AirPriceResult'>
				<cfloop array="#stAirPriceResult.XMLChildren#" item="local.stAirPricingSolution" index="local.nAirPricingSolution">
					<cfif stAirPricingSolution.XMLName EQ 'air:AirPricingSolution'>
						<cfset stPriceSolution = stAirPricingSolution>
						<cfloop array="#stPriceSolution.XMLChildren#" item="local.stChildren" index="local.nChildren">
							<cfif stChildren.XMLName EQ 'air:AirSegmentRef'>
								<!--- Replace the SegmentRef with the air segment details --->
								<cfset stPriceSolution.XMLChildren[nChildren] = stSegments[stChildren.XMLAttributes.Key]>
							<cfelseif stChildren.XMLName EQ 'air:OptionalServices'>
								<!--- Remove Optional Services --->
								<cfset arrayDeleteAt(stPriceSolution.XMLChildren, nChildren)>
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>

		<cfset stPriceSolution = replace(stPriceSolution, '<?xml version="1.0" encoding="UTF-8"?>', '')>

		<cfreturn stPriceSolution />
	</cffunction>

<!---
prepareSoapHeader
--->
	<cffunction name="prepareSoapHeader" returntype="string" output="false">
		<cfargument name="Filter"	    required="true">
		<cfargument name="Account"	    required="true">
		<cfargument name="Traveler"	    required="true">
		<cfargument name="AirPricing"	required="true">
		<cfargument name="Carriers"		required="true">
		<cfargument name="profileFound"	required="true">
		<cfargument name="OrigTraveler"	required="true">

		<cfset local.Filter = arguments.Filter>
		<cfset local.Traveler = arguments.Traveler>
		<cfset local.OrigTraveler = arguments.OrigTraveler>
		<cfsavecontent variable="local.Message">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
                        <air:AirCreateReservationReq xmlns:air="http://www.travelport.com/schema/air_v18_0" TargetBranch="#arguments.Account.sBranch#">
	                        <com:BillingPointOfSaleInfo xmlns:com="http://www.travelport.com/schema/common_v15_0" OriginApplication="UAPI" />
                            <com:BookingTraveler xmlns:com="http://www.travelport.com/schema/common_v15_0" Key="0T" TravelerType="ADT" Gender="#Traveler.Gender#" DOB="#DateFormat(Traveler.Birthdate, 'yyyy-mm-dd')#">
                                <com:BookingTravelerName First="#Traveler.First_Name#" Middle="#Traveler.Middle_Name#" Last="#Traveler.Last_Name#" />
								<cfif profileFound AND OrigTraveler.Wireless_Phone NEQ Traveler.Wireless_Phone>
									<com:PhoneNumber Location="#Filter.getDepartCity()#" Number="#Traveler.Wireless_Phone#" Type="Mobile" />
								</cfif>
								<cfif profileFound AND OrigTraveler.Phone_Number NEQ Traveler.Phone_Number>
									<com:PhoneNumber Location="#Filter.getDepartCity()#" Number="#Traveler.Phone_Number#" Type="Business" />
								</cfif>
								<cfif profileFound AND OrigTraveler.Email NEQ Traveler.Email>
									<com:PhoneNumber Location="#Filter.getDepartCity()#" Number="#Traveler.Email#" Type="Email" />
								</cfif>
								<cfif profileFound AND OrigTraveler.Email NEQ Traveler.Email>
									<com:Email Type="Home" EmailID="#Traveler.Email#" />
								</cfif>
								<cfloop array="#Carriers#" item="sCarrier">
									<cfif Traveler['Air_FF#sCarrier#'] NEQ ''>
										<com:LoyaltyCard SupplierCode="#sCarrier#" CardNumber="#Traveler['Air_FF#sCarrier#']#"/>
									</cfif>
								</cfloop>
                    			<com:SSR Type="DOCS" Status="NN" FreeText="////#UCase(DateFormat(Traveler.Birthdate, 'ddmmmyy'))#/#Traveler.Gender#//#Traveler.Last_Name#/#Traveler.First_Name#/#Traveler.Middle_Name#"/>
								<cfif profileFound AND OrigTraveler.Service_Requests NEQ Traveler.Service_Requests AND Traveler.Service_Requests NEQ ''>
									<com:SSR Type="#Traveler.Service_Requests#" Status="NN" />
								</cfif>
								<com:NameRemark>
									<com:RemarkData>#(structKeyExists(Traveler.OUs, 'Sort1') ? Traveler.OUs.Sort1.Value_Report : '')# #(structKeyExists(Traveler.OUs, 'Sort2') ? Traveler.OUs.Sort2.Value_Report : '')# #(structKeyExists(Traveler.OUs, 'Sort3') ? Traveler.OUs.Sort3.Value_Report : '')# #(structKeyExists(Traveler.OUs, 'Sort4') ? Traveler.OUs.Sort4.Value_Report : '')#</com:RemarkData>
								</com:NameRemark>
							</com:BookingTraveler>
							<OSI xmlns="http://www.travelport.com/schema/common_v15_0" Carrier="YY" Code="#Filter.getDepartCity()#" Text=" CTCM #Filter.getDepartCity()# #Traveler.Wireless_Phone#" ProviderCode="1V" />
							<OSI xmlns="http://www.travelport.com/schema/common_v15_0" Carrier="YY" Code="#Filter.getDepartCity()#" Text=" CTCE #Filter.getDepartCity()# #Replace(Traveler.Email, '@', '//')#" ProviderCode="1V" />
							<AccountingRemark xmlns="http://www.travelport.com/schema/common_v15_0" Category="CA" TypeInGds="Other" ProviderCode="1V" UseProviderNativeMode="true">
		                        <RemarkData>15@066231</RemarkData>
		                    </AccountingRemark>
		                    <AccountingRemark xmlns="http://www.travelport.com/schema/common_v15_0" TypeInGds="Ticket" ProviderCode="1V" UseProviderNativeMode="true">
		                        <RemarkData>T-U25-STANFORD</RemarkData>
		                    </AccountingRemark>
		                    <!--- Each line cannot exceed 85 characters, so you will need to do 1 remark for each 75 characters of the freeform text (because SPCLREQST- is 10 char). Also, strip out special characters from the freeform text.  --->
		                    <GeneralRemark xmlns="http://www.travelport.com/schema/common_v15_0" Category="R" TypeInGds="Alpha" ProviderCode="1V" UseProviderNativeMode="true">
		                        <RemarkData>SPCLREQST-Please use my unused ticket</RemarkData>
		                    </GeneralRemark>
<!--- Would I need to remove the original email?? --->
							<cfif profileFound AND OrigTraveler.Email NEQ Traveler.Email>
								<UnassociatedRemark xmlns="http://www.travelport.com/schema/common_v15_0">
									<RemarkData>EMAIL #Traveler.Email#</RemarkData>
								</UnassociatedRemark>
							</cfif>
							<cfloop list="#Traveler.CCEmail#" delimiters=";" index="local.i">
								<cfif profileFound AND NOT listFindNoCase(OrigTraveler.CCEmail, i, ';')>
									<UnassociatedRemark xmlns="http://www.travelport.com/schema/common_v15_0">
										<RemarkData>EMAIL/CC #i#</RemarkData>
									</UnassociatedRemark>
								</cfif>
							</cfloop>
		                    <!--- <GeneralRemark xmlns="http://www.travelport.com/schema/common_v15_0" Category="S" TypeInGds="Alpha" ProviderCode="1V" UseProviderNativeMode="true">
		                        <RemarkData>Director of Information Technology</RemarkData>
		                    </GeneralRemark> --->

							#arguments.AirPricing#

	                        <com:ActionStatus xmlns:com="http://www.travelport.com/schema/common_v15_0" Type="TAU" TicketDate="#DateFormat(DateAdd('d', 1, Now()), 'yyyy-mm-dd')#T#TimeFormat(Now(), 'HH:mm:ss')#">
	                            <com:Remark><!---HOLD.FOR.APPROVAL--->OK.TO.TKT</com:Remark>
	                        </com:ActionStatus>
	                        <com:FormOfPayment xmlns:com="http://www.travelport.com/schema/common_v15_0" Type="Credit">
	                            <com:CreditCard Type="#Traveler.AirFOP.CC_Code#" Number="#Traveler.AirFOP.CC_Number#" CVV="#Traveler.AirFOP.Billing_CVV#" ExpDate="#DateFormat(Traveler.AirFOP.CC_Expiration, 'yyyy-mm')#" />
	                        </com:FormOfPayment>
	                        <!--- <air:AutoSeatAssignment SeatType="Window" /> Send in either this or SpecificSeatAssignment --->
					        <!--- <air:SpecificSeatAssignment SegmentRef="0T" SeatId="02B" BookingTravelerRef="0T" /> --->
	                    </air:AirCreateReservationReq>
				  	</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>

		<!--- <cfdump var="#xmlParse(Message)#" abort="true"> --->

		<cfreturn Message/>
	</cffunction>
	
</cfcomponent>

<!---
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:univ="http://www.travelport.com/schema/universal_v16_0" xmlns:air="http://www.travelport.com/schema/air_v18_0" xmlns:com="http://www.travelport.com/schema/common_v15_0">
   <soapenv:Header>
      <univ:SupportedVersions urVersion="?" airVersion="?" hotelVersion="?" vehicleVersion="?" passiveVersion="?" railVersion="?"/>
   </soapenv:Header>
   <soapenv:Body>
      <air:AirCreateReservationReq TraceId="?" TokenId="?" AuthorizedBy="?" TargetBranch="?" OverrideLogging="?" UniversalRecordLocatorCode="?" ProviderLocatorCode="?" ProviderCode="?" CustomerNumber="?" Version="?" RetainReservation="None" Source="?">
         <com:BillingPointOfSaleInfo OriginApplication="?" CIDBNumber="?"/>
         <!--Zero or more repetitions:-->
         <com:AgentIDOverride SupplierCode="?" ProviderCode="?" AgentID="?"/>
         <!--Zero or more repetitions:-->
         <com:LinkedUniversalRecord LocatorCode="?" Key="?"/>
         <!--Zero or more repetitions:-->
         <com:BookingTraveler Key="?" TravelerType="?" Age="?" VIP="false" DOB="?" Gender="?">
            <com:BookingTravelerName Prefix="?" First="?" Middle="?" Last="?" Suffix="?"/>
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
            <com:PhoneNumber Key="?" Type="?" Location="?" CountryCode="?" AreaCode="?" Number="?" Extension="?" Text="?">
               <!--Zero or more repetitions:-->
               <com:ProviderReservationInfoRef Key="?"/>
            </com:PhoneNumber>
            <!--Zero or more repetitions:-->
            <com:Email Key="?" Type="?" Comment="?" EmailID="?">
               <!--Zero or more repetitions:-->
               <com:ProviderReservationInfoRef Key="?"/>
            </com:Email>
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
--->