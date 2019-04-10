<cfcomponent extends="abstract" accessors="true">

	<!--- // DEPENDENCY INJECTION --->
	<cfproperty name="airAvailability" setter="true" getter="false">
	<cfproperty name="airPrice" setter="true" getter="false">
	<cfproperty name="email" setter="true" getter="false">
	<cfproperty name="general" setter="true" getter="false">
	<cfproperty name="lowFare" setter="true" getter="false">
	<cfproperty name="lowFareavail" setter="true" getter="false">

	<cffunction name="search" output="false" hint="I assemble low fares for display.">
		<cfargument name="rc">

		<cfset var SearchID = SearchID>

		<cfparam name="arguments.rc.Group" default="0">
		<cfparam name="session.searches[#SearchID#].Selected" default="#structNew('linked')#">
		<!--- <cfset session.searches[#SearchID#].Selected = {}> --->

		<cfloop array="#arguments.rc.Filter.getLegsForTrip()#" index="local.SegmentIndex" item="local.SegmentItem">
			<cfif SegmentIndex-1 GTE arguments.rc.Group>
				<cfset structDelete(session.searches[SearchID].Selected, SegmentIndex-1)>
			</cfif>
		</cfloop>

		<cfif structKeyExists(rc, 'FlightSelected')>
			<cfset session.searches[SearchID].Selected[arguments.rc.Group] = deserializeJSON(form.Segment)>
			<cfset session.searches[SearchID].Selected[arguments.rc.Group].SegmentId = SegmentID>
			<cfset session.searches[SearchID].Selected[arguments.rc.Group].CabinClass = form.CabinClass>
			<cfset session.searches[SearchID].Selected[arguments.rc.Group].SegmentFareId = form.SegmentFareId>
			<cfset session.searches[SearchID].Selected[arguments.rc.Group].Refundable = form.Refundable>

			<!--- <cfdump var=#session.searches[SearchID].Selected# abort> --->
			<cfloop array="#arguments.rc.Filter.getLegsForTrip()#" index="local.SegmentIndex" item="local.SegmentItem">
				<cfif arguments.rc.Group+2 EQ local.SegmentIndex>
					<cfset fw.redirect('air.search?SearchID=#arguments.rc.SearchID#&Group=#SegmentIndex-1#')>
				</cfif>
			</cfloop>

			<!--- <cfdump var=#session.searches[SearchID].Selected# abort> --->
			<cfset variables.fw.redirect('air.review?SearchID=#arguments.rc.SearchID#')>
		</cfif>

		<!--- <cfif structKeyExists(session.searches[SearchID], 'unusedtickets')>
			<cfset session.Filters[SearchID].setUnusedTicketCarriers( variables.general.getUnusedTickets( ProfileID = arguments.rc.Filter.getProfileID() ) )>
			<cfdump var=#session.Filters[SearchID].getUnusedTicketCarriers()# abort>
		</cfif> --->

		<cfset rc.trips = variables.lowfare.doAirSearch(Account = arguments.rc.Account,
														Policy = arguments.rc.Policy,
														Filter = arguments.rc.Filter,
														SearchID = SearchID,
														Group = arguments.rc.Group,
														SelectedTrip = session.searches[SearchID].Selected,
														cabins = '')><!---(structKeyExists(arguments.rc, 'sCabins') ? arguments.rc.sCabins : '')--->

		<cfreturn />
	</cffunction>

	<cffunction name="review" output="false">
		<cfargument name="rc">

		<!--- <cfset var Pricing = variables.airprice.doAirPrice(	Account = arguments.rc.Account,
															Policy = arguments.rc.Policy,
															Filter = arguments.rc.Filter,
															SearchID = SearchID,
															Group = arguments.rc.Group,
															Selected = session.searches[SearchID].Selected,
															Pricing = [],
															CabinClass = '')>

		<cfset var Pricing = variables.airprice.doAirPrice(	Account = arguments.rc.Account,
															Policy = arguments.rc.Policy,
															Filter = arguments.rc.Filter,
															SearchID = SearchID,
															Group = arguments.rc.Group,
															Selected = session.searches[SearchID].Selected,
															Pricing = Pricing,
															CabinClass = 'Economy')>

		<cfset var Pricing = variables.airprice.doAirPrice(	Account = arguments.rc.Account,
															Policy = arguments.rc.Policy,
															Filter = arguments.rc.Filter,
															SearchID = SearchID,
															Group = arguments.rc.Group,
															Selected = session.searches[SearchID].Selected,
															Pricing = Pricing,
															CabinClass = 'Business')>

		<cfset var Pricing = variables.airprice.doAirPrice(	Account = arguments.rc.Account,
															Policy = arguments.rc.Policy,
															Filter = arguments.rc.Filter,
															SearchID = SearchID,
															Group = arguments.rc.Group,
															Selected = session.searches[SearchID].Selected,
															Pricing = Pricing,
															CabinClass = 'First')>

		<cfdump var=#serializeJSON(local.Pricing)# abort> --->

		<cfset rc.Pricing = '[{"TotalFare":"USD532.00","PlatingCarrier":"DL","BookingInfo":[{"CabinClass":"Economy","BookingCode":"V"},{"CabinClass":"Economy","BookingCode":"V"},{"CabinClass":"Economy","BookingCode":"V"},{"CabinClass":"Economy","BookingCode":"V"}],"Refundable":false},{"TotalFare":"USD625.00","PlatingCarrier":"DL","BookingInfo":[{"CabinClass":"PremiumEconomy","BookingCode":"W"},{"CabinClass":"PremiumEconomy","BookingCode":"W"},{"CabinClass":"PremiumEconomy","BookingCode":"W"},{"CabinClass":"PremiumEconomy","BookingCode":"W"}],"Refundable":false},{"TotalFare":"USD840.00","PlatingCarrier":"DL","BookingInfo":[{"CabinClass":"First","BookingCode":"Z"},{"CabinClass":"First","BookingCode":"Z"},{"CabinClass":"First","BookingCode":"Z"},{"CabinClass":"First","BookingCode":"Z"}],"Refundable":false},{"TotalFare":"USD532.00","PlatingCarrier":"DL","BookingInfo":[{"CabinClass":"Economy","BookingCode":"V"},{"CabinClass":"Economy","BookingCode":"V"},{"CabinClass":"Economy","BookingCode":"V"},{"CabinClass":"Economy","BookingCode":"V"}],"Refundable":false},{"TotalFare":"USD625.00","PlatingCarrier":"DL","BookingInfo":[{"CabinClass":"PremiumEconomy","BookingCode":"W"},{"CabinClass":"PremiumEconomy","BookingCode":"W"},{"CabinClass":"PremiumEconomy","BookingCode":"W"},{"CabinClass":"PremiumEconomy","BookingCode":"W"}],"Refundable":false},{"TotalFare":"USD840.00","PlatingCarrier":"DL","BookingInfo":[{"CabinClass":"First","BookingCode":"Z"},{"CabinClass":"First","BookingCode":"Z"},{"CabinClass":"First","BookingCode":"Z"},{"CabinClass":"First","BookingCode":"Z"}],"Refundable":false},{"TotalFare":"USD532.00","PlatingCarrier":"DL","BookingInfo":[{"CabinClass":"Economy","BookingCode":"V"},{"CabinClass":"Economy","BookingCode":"V"},{"CabinClass":"Economy","BookingCode":"V"},{"CabinClass":"Economy","BookingCode":"V"}],"Refundable":false},{"TotalFare":"USD625.00","PlatingCarrier":"DL","BookingInfo":[{"CabinClass":"PremiumEconomy","BookingCode":"W"},{"CabinClass":"PremiumEconomy","BookingCode":"W"},{"CabinClass":"PremiumEconomy","BookingCode":"W"},{"CabinClass":"PremiumEconomy","BookingCode":"W"}],"Refundable":false},{"TotalFare":"USD840.00","PlatingCarrier":"DL","BookingInfo":[{"CabinClass":"First","BookingCode":"Z"},{"CabinClass":"First","BookingCode":"Z"},{"CabinClass":"First","BookingCode":"Z"},{"CabinClass":"First","BookingCode":"Z"}],"Refundable":false},{"TotalFare":"USD532.00","PlatingCarrier":"DL","BookingInfo":[{"CabinClass":"Economy","BookingCode":"V"},{"CabinClass":"Economy","BookingCode":"V"},{"CabinClass":"Economy","BookingCode":"V"},{"CabinClass":"Economy","BookingCode":"V"}],"Refundable":false},{"TotalFare":"USD625.00","PlatingCarrier":"DL","BookingInfo":[{"CabinClass":"PremiumEconomy","BookingCode":"W"},{"CabinClass":"PremiumEconomy","BookingCode":"W"},{"CabinClass":"PremiumEconomy","BookingCode":"W"},{"CabinClass":"PremiumEconomy","BookingCode":"W"}],"Refundable":false},{"TotalFare":"USD840.00","PlatingCarrier":"DL","BookingInfo":[{"CabinClass":"First","BookingCode":"Z"},{"CabinClass":"First","BookingCode":"Z"},{"CabinClass":"First","BookingCode":"Z"},{"CabinClass":"First","BookingCode":"Z"}],"Refundable":false}]'>

		<cfreturn />
	</cffunction>

</cfcomponent>
