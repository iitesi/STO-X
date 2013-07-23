<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfparam name="rc.travelerNumber" default="1">
		<cfset rc.errorMessage = []>
		
		<cfset rc.Traveler = session.searches[rc.searchID].Travelers[rc.travelerNumber]>
		<cfset rc.itinerary = session.searches[rc.searchID].stItinerary>
		<cfset rc.airSelected = (structKeyExists(rc.itinerary, 'Air') ? true : false)>
		<cfset rc.Air = (structKeyExists(session.searches[rc.SearchID].stItinerary, 'Air') ? session.searches[rc.SearchID].stItinerary.Air : '')>
		<cfset rc.hotelSelected = (structKeyExists(rc.itinerary, 'Hotel') ? true : false)>
		<cfset rc.Hotel = (structKeyExists(session.searches[rc.SearchID].stItinerary, 'Hotel') ? session.searches[rc.SearchID].stItinerary.Hotel : '')>
		<cfset rc.vehicleSelected = (structKeyExists(rc.itinerary, 'Vehicle') ? true : false)>
		<cfset rc.Vehicle = (structKeyExists(session.searches[rc.SearchID].stItinerary, 'Vehicle') ? session.searches[rc.SearchID].stItinerary.Vehicle : '')>
				
		<cfset local.providerLocatorCode = ''>
		<cfset local.universalLocatorCode = ''>
		<cfset local.version = -1>

		<!--- Populate sort fields --->
		<cfset local.sort1 = ''>
		<cfset local.sort2 = ''>
		<cfset local.sort3 = ''>
		<cfset local.sort4 = ''>
		<cfloop array="#rc.Traveler.getOrgUnit()#" index="local.orgUnitIndex" item="local.orgUnit">
			<cfif orgUnit.getOUType() EQ 'sort'>
				<cfset local['sort#orgUnit.getOUPosition()#'] = orgUnit.getValueReport()>
			</cfif>
		</cfloop>
		<cfset local.statmentInformation = sort1&' '&sort2&' '&sort3&' '&sort4>
		<cfset statmentInformation = trim(statmentInformation)>

		<!--- Sell Air --->
		<cfif rc.airSelected
			AND rc.Traveler.getBookingDetail().getAirNeeded()>

			<cfset local.trip = fw.getBeanFactory().getBean('AirPrice').doAirPrice( searchID = rc.searchID
																					, Account = rc.Account
																					, Policy = rc.Policy
																					, Class = rc.Air.Class
																					, Ref = rc.Air.Ref
																					, nTrip = rc.Air.nTrip
																					, nCouldYou = 0
																					, bSaveAirPrice = 1
																				 )>
<!--- <cfdump var="#trip#" /><cfabort /> --->
			<cfset local.airPricing = fw.getBeanFactory().getBean('AirCreate').parseTripForPurchase( sXML = trip[rc.Air.nTrip].sXML )>

			<cfset rc.response = fw.getBeanFactory().getBean('AirAdapter').create( Traveler = rc.Traveler
																					, Air = rc.Air
																					, airPricing = airPricing
																					, Filter = rc.Filter
																					, statmentInformation = statmentInformation
																				 )>

<!--- <cfdump var="#rc.response#" /><cfabort /> --->
			<cfset rc.Air = fw.getBeanFactory().getBean('AirAdapter').parseAirRsp( Air = rc.Air
																					, response = rc.response )>

			<!--- <cfif rc.Hotel.getConfirmation() EQ ''>
				<cfset rc.errorMessage = fw.getBeanFactory().getBean('UAPI').parseError( rc.response )>
				<cfdump var="#rc.errorMessage#">
				<cfset providerLocatorCode = ''>
				<cfset universalLocatorCode = ''>
			<cfelse> --->
				<cfset providerLocatorCode = rc.Air.ProviderLocatorCode>
				<cfset universalLocatorCode = rc.Air.UniversalLocatorCode>
				<cfdump var="Air">
				<cfdump var="#providerLocatorCode#">
				<cfdump var="#universalLocatorCode#">
			<!--- </cfif> --->
			<cfset session.searches[rc.SearchID].stItinerary.Air = rc.Air>

			<cfif providerLocatorCode NEQ ''>
				<cfset version++>
			</cfif>
		</cfif>

		<!--- Sell Hotel --->
		<cfif rc.hotelSelected
			AND rc.Traveler.getBookingDetail().getHotelNeeded()
			AND arrayIsEmpty(rc.errorMessage)>

			<cfset rc.Hotel.getProviderLocatorCode('')>
			<cfset rc.Hotel.getUniversalLocatorCode('')>

			<cfset rc.response = fw.getBeanFactory().getBean('HotelAdapter').create( searchID = rc.searchID
																					, Traveler = rc.Traveler
																					, Hotel = rc.Hotel
																					, Filter = rc.Filter
																					, statmentInformation = statmentInformation
																					, providerLocatorCode = providerLocatorCode
																					, universalLocatorCode = universalLocatorCode
																					, version = version )>

			<cfset rc.Hotel = fw.getBeanFactory().getBean('HotelAdapter').parseHotelRsp( Hotel = rc.Hotel
																					, response = rc.response )>

			<cfif rc.Hotel.getConfirmation() EQ ''>
				<cfset rc.errorMessage = fw.getBeanFactory().getBean('UAPI').parseError( rc.response )>
				<cfdump var="#rc.errorMessage#">
			<cfelse>
				<cfset providerLocatorCode = rc.Hotel.getProviderLocatorCode()>
				<cfset universalLocatorCode = rc.Hotel.getUniversalLocatorCode()>
				<cfdump var="Hotel">
				<cfdump var="#providerLocatorCode#">
				<cfdump var="#universalLocatorCode#">
			</cfif>
			<cfset session.searches[rc.SearchID].stItinerary.Hotel = rc.Hotel>

			<cfif providerLocatorCode NEQ ''>
				<cfset version++>	
			</cfif>
		</cfif>

		<!--- Sell Vehicle --->
		<cfif rc.vehicleSelected
			AND rc.Traveler.getBookingDetail().getCarNeeded()
			AND arrayIsEmpty(rc.errorMessage)>

			<cfset rc.Vehicle.getProviderLocatorCode('')>
			<cfset rc.Vehicle.getUniversalLocatorCode('')>

			<!--- Find the correct direct bill and corporate discount numbers --->
			<cfset local.directBillNumber = ''>
			<cfset local.corporateDiscountNumber = ''>
			<cfset local.directBillType = ''>
			<cfloop array="#rc.Traveler.getPayment()#" index="local.paymentIndex" item="local.payment">
				<cfif payment.getCarUse() EQ 1>
					<cfif len(payment.getDirectBillNumber()) GT 0
						AND rc.Traveler.getBookingDetail().getCarFOPID() EQ 'DB_'&payment.getDirectBillNumber()>
						<cfset directBillNumber = payment.getDirectBillNumber()>
						<cfset corporateDiscountNumber = payment.getCorporateDiscountNumber()>
						<cfset directBillType = payment.getDirectBillType()>
					<cfelseif len(payment.getCorporateDiscountNumber()) GT 0
						AND rc.Traveler.getBookingDetail().getCarFOPID() EQ 'CD_'&payment.getDirectBillNumber()>
						<cfset directBillNumber = ''>
						<cfset corporateDiscountNumber = payment.getCorporateDiscountNumber()>
						<cfset directBillType = payment.getDirectBillType()>
					</cfif>
				</cfif>
			</cfloop>

			<!--- Find arriving flight details --->
			<cfset local.carrier = ''>
			<cfset local.flightNumber = ''>
			<cfif isStruct(rc.Air)>
				<cfloop collection="#rc.Air.Groups[0].Segments#" index="local.segmentIndex" item="local.segment">
					<cfset carrier = segment.carrier>
					<cfset flightNumber = segment.flightNumber>
				</cfloop>
			</cfif>
			
			<!--- Sell vehicle --->
			<cfset rc.response = fw.getBeanFactory().getBean('VehicleAdapter').create( Traveler = rc.Traveler
																					, Vehicle = rc.Vehicle
																					, Filter = rc.Filter
																					, directBillNumber = directBillNumber
																					, corporateDiscountNumber = corporateDiscountNumber
																					, directBillType = directBillType
																					, carrier = carrier
																					, flightNumber = flightNumber
																					, statmentInformation = statmentInformation
																					, providerLocatorCode = providerLocatorCode
																					, universalLocatorCode = universalLocatorCode
																					, version = version )>
			<!--- Parse the vehicle --->
			<cfset rc.Vehicle = fw.getBeanFactory().getBean('VehicleAdapter').parseVehicleRsp( Vehicle = rc.Vehicle
																							, response = rc.response )>
			<!--- Validate the confirmation --->
			<cfif rc.Vehicle.getConfirmation() EQ ''>
				<cfset rc.errorMessage = fw.getBeanFactory().getBean('UAPI').parseError( rc.response )>
				<cfdump var="#rc.errorMessage#">
			<cfelse>
				<!--- <cfdump var="#rc.Vehicle#"> --->
				<cfset providerLocatorCode = rc.Vehicle.getProviderLocatorCode()>
				<cfset universalLocatorCode = rc.Vehicle.getUniversalLocatorCode()>
				<cfdump var="Vehicle">
				<cfdump var="#providerLocatorCode#">
				<cfdump var="#universalLocatorCode#">
			</cfif>
			<cfset session.searches[rc.SearchID].stItinerary.Vehicle = rc.Vehicle>

			<cfif providerLocatorCode NEQ ''>
				<cfset version++>
			</cfif>
		</cfif>

		<cfabort>

		<cfreturn />
	</cffunction>

</cfcomponent>