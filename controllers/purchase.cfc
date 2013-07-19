<cfcomponent extends="abstract" output="false">

	<cfset variables.fw = "">
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="fw">

		<cfset variables.fw = arguments.fw>
		<cfset variables.bf = fw.getBeanFactory()>

		<cfreturn this>
	</cffunction>

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<!--- <cfset rc.stAir = session.searches[arguments.rc.SearchID].stItinerary.Air>
		<cfset variables.bf.getBean("AirCreate").doAirCreate(argumentcollection=arguments.rc)> --->
		<!--- <cfset session.Users[1] = fw.getBeanFactory().getBean('TravelerService').load(3605, 1)>
		<cfset rc.stItinerary = session.searches[rc.SearchID].stItinerary> --->

		<cfreturn />
	</cffunction>

	<cffunction name="hotel" output="false">
		<cfargument name="rc">

		<cfparam name="rc.travelerNumber" default="1">
		
		<cfset rc.Hotel = session.searches[rc.searchID].stItinerary.Hotel>
		<cfset rc.Traveler = session.searches[rc.searchID].Travelers[rc.travelerNumber]>

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

		<cfset rc.response = fw.getBeanFactory().getBean('HotelAdapter').create( Traveler = rc.Traveler
																				, Hotel = rc.Hotel
																				, Filter = rc.Filter
																				, statmentInformation = statmentInformation )>

		<cfset rc.Hotel = fw.getBeanFactory().getBean('HotelAdapter').parseHotelRsp( Hotel = rc.Hotel
																				, response = rc.response )>

		<cfif rc.Hotel.getConfirmation() EQ ''>
			<cfset rc.errorMessage = fw.getBeanFactory().getBean('UAPI').parseError( rc.response )>
			<cfdump var="#rc.errorMessage#" abort="true">
		<cfelse>
			<cfdump var="#rc.Hotel#" abort="true">
		</cfif>

		<!--- <cfdump var="#rc.Traveler#">
		<cfdump var="#rc.Payment#">
		<cfdump var="#rc.Vehicle#">
		<cfdump var="#rc.Filter#"> --->

		<cfabort>

		<cfreturn />
	</cffunction>

	<cffunction name="car" output="false">
		<cfargument name="rc">

		<cfparam name="rc.travelerNumber" default="1">

		<cfset rc.Vehicle = session.searches[rc.SearchID].stItinerary.Vehicle>
		<cfset rc.Air = (structKeyExists(session.searches[rc.SearchID].stItinerary, 'Air') ? session.searches[rc.SearchID].stItinerary.Air : '')>
		<cfset rc.Traveler = session.searches[rc.searchID].Travelers[rc.travelerNumber]>

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
		
		<!--- Call the UAPI to sell the vehicle --->
		<cfset rc.response = fw.getBeanFactory().getBean('VehicleAdapter').create( Traveler = rc.Traveler
																				, Vehicle = rc.Vehicle
																				, Filter = rc.Filter
																				, directBillNumber = directBillNumber
																				, corporateDiscountNumber = corporateDiscountNumber
																				, directBillType = directBillType
																				, carrier = carrier
																				, flightNumber = flightNumber
																				, statmentInformation = statmentInformation )>
		<!--- Parse the vehicle --->
		<cfset rc.Vehicle = fw.getBeanFactory().getBean('VehicleAdapter').parseVehicleRsp( Vehicle = rc.Vehicle
																						, response = rc.response )>
		<!--- Validate the confirmation --->
		<cfif rc.Vehicle.getConfirmation() EQ ''>
			<cfset rc.errorMessage = fw.getBeanFactory().getBean('UAPI').parseError( rc.response )>
			<cfdump var="#rc.errorMessage#">
		<cfelse>
			<cfdump var="#rc.Vehicle#">
		</cfif>
		<cfset session.searches[rc.SearchID].stItinerary.Vehicle = rc.Vehicle>

		<cfabort>

		<cfreturn />
	</cffunction>

</cfcomponent>