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

	<cffunction name="doLowFareSearch" output="false">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">
		<cfargument name="Filter" required="false" default="X">
		<cfargument name="SearchID" default="">
		<cfargument name="Group" default="">
		<cfargument name="SelectedTrip" default="">

		<!--- <cftry> --->
			<cfset local.requestBody = getKrakenService().getFlightSearchRequest( 	Policy = arguments.Policy,
																					Filter = arguments.Filter )>

			<cfset local.response = getStorage().getStorage(	searchID = arguments.searchID,
																request = local.requestBody )>

			<cfif structIsEmpty(local.response)>
				<cfset local.response = getKrakenService().FlightSearch(	body = local.requestBody,
																			SearchID = arguments.SearchID,
																			Group = arguments.Group,
																			SelectedTrip = arguments.SelectedTrip )>

				<cfif structIsEmpty(response)>
					If you get this error, please send it to Chrissy.  Trying to figure out the 'BrandedFareName' error.  :)  Send screenshot and copy/paste the first string.  Thank you!
					<cfdump var=#serializeJSON(local.requestBody)#>
					<cfdump var=#local.requestBody#>
					<cfdump var=#local.response# abort>
				</cfif>

				<cfset getStorage().storeAir(	searchID = arguments.searchID,
												request = local.requestBody,
												storage = local.response )>
			</cfif>
			<!--- <cfcatch>
				If you get this error, please send it to Chrissy.  Trying to figure out the 'BrandedFareName' error.  :)  Send screenshot and copy/paste the first string.  Thank you!
				<cfdump var=#serializeJSON(local.requestBody)#>
				<cfdump var=#local.requestBody#>
				<cfdump var=#local.response# abort>
			</cfcatch>
		</cftry> --->

		<cfreturn local.response>
 	</cffunction>

	<cffunction name="parseBrandedFares" returnType="struct" access="public">
		<cfargument name="response" type="any" required="true">

		<cfset var index = ''>
		<cfset var item = ''>
		<cfset var BrandedFares = {}>

		<cftry>
			<!--- response.brandedfarenames : Create a lookup table for branded fare names. --->
			<!--- response.brandedfarenames[207174] = Branded Fare Details --->
			<cfset BrandedFares[0].Name = ''>
			<cfset BrandedFares[0].LongDescription = ''>
			<cfset BrandedFares[0].ShortDescription = ''>
			<cfloop collection="#arguments.response.BrandedFareDetails#" index="index" item="item">
				<cfset BrandedFares[item.BrandId] = item>
			</cfloop>
			<cfcatch>
				<cfdump var=#serializeJSON(response)#>
				<cfdump var=#response# abort>
			</cfcatch>
		</cftry>

		<!--- <cfdump var=#BrandedFares# abort> --->

		<cfreturn BrandedFares>
	</cffunction>

	<cffunction name="parseSegments" returnType="struct" access="public">
		<cfargument name="response" type="any" required="true">
		<cfargument name="Group" type="any" required="true">

		<cfset var tripIndex = ''>
		<cfset var tripItem = ''>
		<cfset var segmentIndex = ''>
		<cfset var segmentItem = ''>
		<cfset var flightIndex = ''>
		<cfset var flightItem = ''>
		<cfset var segmentCount = ''>
		<cfset var Carrier = ''>
		<cfset var Connections = ''>
		<cfset var FlightNumbers = ''>
		<cfset var Segments = {}>

		<!--- response.Segments : Create a distinct structure of available segments by reference key. --->
		<!--- response.Segments[G0-B6.124] = Full segment structure --->
		<cfloop collection="#arguments.response.FlightSearchResults#" index="tripIndex" item="tripItem">
			<cfloop collection="#tripItem.TripSegments#" index="segmentIndex" item="segmentItem">
				<cfif segmentItem.Group EQ arguments.Group>
					<cfset segmentCount = arrayLen(segmentItem.Flights)>
					<!--- Replace the structure with the SegmentId. --->
					<!--- <cfset Segments.TripSegments[segmentIndex] = segmentItem.SegmentId> --->
					<!--- Create the distinct list of legs.  Also add in some overall leg information for display purposes. --->
					<cfset Segments[segmentItem.SegmentId] 						= segmentItem>
					<cfset Segments[segmentItem.SegmentId].DepartureTimeGMT 	= segmentItem.Flights[1].DepartureTime>
					<cfset Segments[segmentItem.SegmentId].DepartureTime 		= left(segmentItem.Flights[1].DepartureTime, 19)>
					<cfset Segments[segmentItem.SegmentId].OriginAirportCode 	= segmentItem.Flights[1].OriginAirportCode>
					<cfset Segments[segmentItem.SegmentId].ArrivalTimeGMT 		= segmentItem.Flights[segmentCount].ArrivalTime>
					<cfset Segments[segmentItem.SegmentId].ArrivalTime 			= left(segmentItem.Flights[segmentCount].ArrivalTime, 19)>
					<cfset Segments[segmentItem.SegmentId].DestinationAirportCode = segmentItem.Flights[segmentCount].DestinationAirportCode>
					<cfset Segments[segmentItem.SegmentId].TravelTime 			= int(segmentItem.TotalTravelTimeInMinutes/60) &'H '&segmentItem.TotalTravelTimeInMinutes%60&'M'>
					<cfset Segments[segmentItem.SegmentId].Stops 				= segmentCount-1>
					<cfset Segments[segmentItem.SegmentId].Days 				= dateDiff('d', segmentItem.Flights[1].DepartureTime, segmentItem.Flights[segmentCount].ArrivalTime)>
					<cfset Segments[segmentItem.SegmentId].PlatingCarrier		= structKeyExists(tripItem.AvailableFareOptions[1], 'PlatingCarrier') ? tripItem.AvailableFareOptions[1].PlatingCarrier : segmentItem.Flights[1].CarrierCode>
					<!--- Determine the overall carrier(s) and connection(s). --->
					<cfset Carrier = ''>
					<cfset Connections = ''>
					<cfset FlightNumbers = ''>
					<cfset Codeshare = ''>
					<cfloop collection="#segmentItem.Flights#" index="flightIndex" item="flightItem">
						<cfset Carrier = listAppend(Carrier, flightItem.CarrierCode)>
						<cfif structKeyExists(flightItem, 'CodeshareInfo')>
							<cfset Codeshare = listAppend(Codeshare, flightItem.CodeshareInfo.Value)>
						</cfif>
						<cfif segmentCount NEQ flightIndex>
							<cfset Connections = listAppend(Connections, flightItem.DestinationAirportCode)>
						</cfif>
						<cfset flightItem.FlightTime = int(flightItem.FlightDurationInMinutes/60) &'H '&flightItem.FlightDurationInMinutes%60&'M'>
						<cfset structDelete(flightItem, 'DepartureTimeString')>
						<cfset structDelete(flightItem, 'ArrivalTimeString')>
						<cfset FlightNumbers = listAppend(FlightNumbers, flightItem.CarrierCode&flightItem.FlightNumber)>
						<cfset flightItem.DepartureTimeGMT		= flightItem.DepartureTime>
						<cfset flightItem.DepartureTime 		= left(flightItem.DepartureTime, 19)>
						<cfset flightItem.ArrivalTimeGMT		= flightItem.ArrivalTime>
						<cfset flightItem.ArrivalTime 			= left(flightItem.ArrivalTime, 19)>
					</cfloop>
					<cfset Carrier = listRemoveDuplicates(Carrier)>
					<cfset Segments[segmentItem.SegmentId].CarrierCode = listLen(Carrier) EQ 1 ? Carrier : 'Mult'>
					<cfset Segments[segmentItem.SegmentId].Codeshare = listRemoveDuplicates(Codeshare)>
					<cfset Segments[segmentItem.SegmentId].Connections = replace(Connections, ',', ', ', 'ALL')>
					<cfset Segments[segmentItem.SegmentId].FlightNumbers = replace(FlightNumbers, ',', ' / ', 'ALL')>
					<cfset Segments[segmentItem.SegmentId].IsLongAndExpensive = false>
					<cfset Segments[segmentItem.SegmentId].IsLongSegment = false>
					<cfset Segments[segmentItem.SegmentId].Results = 'LowFare'>
					<!--- <cfdump var=#Segments[segmentItem.SegmentId]# abort> --->
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn Segments>
	</cffunction>

	<cffunction name="parseFares" returnType="struct" access="public">
		<cfargument name="response" type="any" required="true">
		<cfargument name="BrandedFares" type="any" required="true">

		<cfset var tripIndex = ''>
		<cfset var tripItem = ''>
		<cfset var fareIndex = ''>
		<cfset var fareItem = ''>
		<cfset var bookingIndex = ''>
		<cfset var bookingItem = ''>
		<cfset var groupIndex = ''>
		<cfset var groupItem = ''>
		<cfset var flightIndex = ''>
		<cfset var flightItem = ''>
		<cfset var segmentCount = ''>
		<cfset var Carrier = ''>
		<cfset var Connections = ''>
		<cfset var FlightNumbers = ''>
		<cfset var SegmentFareId = ''>
		<cfset var BookingDetails = {}>
		<cfset var CabinDetails = {}>
		<cfset var Details = {}>
		<cfset var Fares = {}>

		<!--- response.Fares : Create a distinct structure of available fares by reference key. --->
		<!--- response.Fares[G0-B6.124.S|G1-B6.23.S] = Full fare structure. --->
		<cfloop collection="#arguments.response.FlightSearchResults#" index="tripIndex" item="tripItem">

			<cfloop collection="#tripItem.AvailableFareOptions#" index="fareIndex" item="fareItem">

				<cfset BookingDetails = structNew('linked')>
				<cfset CabinDetails = structNew()>
				<cfloop collection="#fareItem.BookingDetails#" index="bookingIndex" item="bookingItem">

					<cfset bookingItem.PartOfSegmentFareId = bookingItem.CarrierCode&'.'&bookingItem.FlightNumber&'.'&bookingItem.BookingCode>
					<cfset bookingItem.PartOfSegmentId = bookingItem.CarrierCode&'.'&bookingItem.FlightNumber>
					<cfparam name="BookingDetails[#bookingItem.Group#]" default="#structNew('linked')#">
					<cfparam name="CabinDetails[#bookingItem.Group#].CabinCodes" default="">
					<cfparam name="CabinDetails[#bookingItem.Group#].BrandedFareNames" default="">
					<cfparam name="CabinDetails[#bookingItem.Group#].SegmentId" default="">
					<cfparam name="CabinDetails[#bookingItem.Group#].BrandedFareIds" default="">
					<cfset BookingDetails[bookingItem.Group][bookingItem.PartOfSegmentFareId] = bookingItem>
					<cfset BrandedFareBrandId = structKeyExists(bookingItem, 'BrandedFareBrandId') ? bookingItem.BrandedFareBrandId : 0>
					<cfset BookingDetails[bookingItem.Group][bookingItem.PartOfSegmentFareId].BrandedFareName = arguments.BrandedFares[BrandedFareBrandId].Name>
					<cfset CabinDetails[bookingItem.Group].CabinCodes = listAppend(CabinDetails[bookingItem.Group].CabinCodes, bookingItem.CabinClass)>
					<cfset CabinDetails[bookingItem.Group].BrandedFareNames = listAppend(CabinDetails[bookingItem.Group].BrandedFareNames, arguments.BrandedFares[BrandedFareBrandId].Name)>
					<cfset CabinDetails[bookingItem.Group].BrandedFareIds = listAppend(CabinDetails[bookingItem.Group].BrandedFareIds, BrandedFareBrandId)>
					<cfset CabinDetails[bookingItem.Group].SegmentId = listAppend(CabinDetails[bookingItem.Group].SegmentId, bookingItem.PartOfSegmentId, '-')>

				</cfloop>
				<cfset Details = structNew('linked')>
				<cfloop collection="#BookingDetails#" index="groupIndex" item="groupItem">

					<cfset SegmentFareId = 'G#groupIndex#-'&structKeyList(groupItem, '-')>
					<cfset Details[SegmentFareId].Details = []>
					<cfloop collection="#groupItem#" index="flightIndex" item="flightItem">

						<cfset arrayAppend(Details[SegmentFareId].Details, flightItem)>

					</cfloop>
					<cfset Details[SegmentFareId].CabinCode = listRemoveDuplicates(CabinDetails[groupIndex].CabinCodes)>
					<cfset Details[SegmentFareId].BrandedFareName = listRemoveDuplicates(CabinDetails[groupIndex].BrandedFareNames)>
					<cfset Details[SegmentFareId].BrandedFareId = listRemoveDuplicates(CabinDetails[groupIndex].BrandedFareIds)>
					<cfset Details[SegmentFareId].SegmentId = 'G#groupIndex#-'&CabinDetails[groupIndex].SegmentId>
					<cfset Details[SegmentFareId].SegmentFareId = SegmentFareId>

				</cfloop>
				<cfset structDelete(fareItem, 'SegmentFareIds')>
				<cfset structDelete(fareItem, 'BookingDetails')>
				<cfset FareKey = structKeyList(Details, '|')>
				<cfset Fares[FareKey] = fareItem>
				<cfset Fares[FareKey].BookingDetails = Details>

			</cfloop>

		</cfloop>

		<cfreturn Fares>
	</cffunction>

	<cffunction name="parseSegmentFares" returnType="struct" access="public">
		<cfargument name="response" type="any" required="true">
		<cfargument name="Fares" type="any" required="true">
		<cfargument name="Group" type="any" required="true">
		<cfargument name="SelectedTrip" type="any" required="true">

		<cfset var fareIndex = ''>
		<cfset var fareItem = ''>
		<cfset var groupIndex = ''>
		<cfset var groupItem = ''>
		<cfset var SegmentFares = {}>

		<cfset SelectedSegmentFareID = ''>
		<cfset SelectedSegmentID = ''>
		<cfset SelectedRefundable = ''>
		<cfloop collection="#arguments.SelectedTrip#" index="selectedGroupIndex" item="selectedGroupItem">
			<cfif NOT structIsEmpty(selectedGroupItem)
				AND selectedGroupIndex LT arguments.Group>
				<cfset SelectedSegmentFareID = listAppend(SelectedSegmentFareID, selectedGroupItem.SegmentFareID, '|')>
				<cfset SelectedSegmentID = listAppend(SelectedSegmentID, selectedGroupItem.SegmentID, '|')>
				<cfset SelectedRefundable = selectedGroupItem.Refundable>
			</cfif>
		</cfloop>
		<!--- response.SegmentFares : Create a table for G0 lowest fares by cabin and branded fare. --->
		<!--- response.SegmentFares[AS.2289,AS.1076][Economy][RefundableMain][TotalFare] = 1369.6 --->
		<cfset var SegmentFares = {}>
		<!--- <cfset SelectedSegmentFareId = 'G0-AS.2075.B-AS.1424.B-AS.6308.B'> --->
		<!--- G0-AS.2289.B-AS.442.H-AS.4624.H --->
		<!--- <cfdump var=#SelectedSegmentFareID# abort> --->
		<cfif arguments.Group EQ 0
			OR SelectedSegmentFareID NEQ ''>
			<cfloop collection="#arguments.Fares#" index="fareIndex" item="fareItem">
				<!--- <cfif fareIndex CONTAINS 'DL.3862'
					AND fareIndex CONTAINS 'DL.3513'>
					<cfdump var=#fareIndex#>
					<cfdump var=#fareItem#>
				</cfif> --->
				<cfif fareIndex CONTAINS SelectedSegmentFareID>
					<cfloop collection="#fareItem.BookingDetails#" index="groupIndex" item="groupItem">

						<cfif left(groupIndex, 2) EQ 'G#arguments.Group#'
							AND (SelectedRefundable EQ ''
									OR SelectedRefundable EQ fareItem.IsRefundable ? 1 : 0)>
							<!--- Branded fare level : Lowest economy comfort prices. --->
							<cfif NOT structKeyExists(SegmentFares, groupItem.SegmentId)
								OR NOT structKeyExists(SegmentFares[groupItem.SegmentId], groupItem.CabinCode)
								OR NOT structKeyExists(SegmentFares[groupItem.SegmentId][groupItem.CabinCode], groupItem.BrandedFareName)
								OR ( SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].TotalFare GT fareItem.TotalFare.Value
									AND fareItem.IsBookable )>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].TotalFare = fareItem.TotalFare.Value>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].Refundable = fareItem.IsRefundable ? 1 : 0>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].PrivateFare = fareItem.IsPrivateFare>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].OutOfPolicy = fareItem.OutOfPolicy>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].OutOfPolicyReason = fareItem.OutOfPolicyReason>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].BrandedFareId = groupItem.BrandedFareId>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].Bookable = fareItem.IsBookable>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].SegmentFareId = groupItem.SegmentFareId>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode][groupItem.BrandedFareName].Details = groupItem.Details>
							</cfif>
							<!--- Cabin level : Lowest economy/business/first prices. --->
							<cfif NOT structKeyExists(SegmentFares, groupItem.SegmentId)
								OR NOT structKeyExists(SegmentFares[groupItem.SegmentId], groupItem.CabinCode)
								OR NOT structKeyExists(SegmentFares[groupItem.SegmentId][groupItem.CabinCode], 'TotalFare')
								OR ( SegmentFares[groupItem.SegmentId][groupItem.CabinCode].TotalFare GT fareItem.TotalFare.Value
									AND fareItem.IsBookable )>

								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode].TotalFare = fareItem.TotalFare.Value>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode].SegmentFareId = groupIndex>
								<cfset SegmentFares[groupItem.SegmentId][groupItem.CabinCode].SegmentId = groupItem.SegmentId>

							</cfif>
						</cfif>

					</cfloop>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn SegmentFares>
	</cffunction>

	<cffunction name="parsePoorSegments" returnType="struct" access="public">
		<cfargument name="Segments" type="any" required="true">
		<cfargument name="SegmentFares" type="any" required="true">
		<cfargument name="Group" type="any" required="true">

		<cfset var fareIndex = ''>
		<cfset var fareItem = ''>
		<cfset var cabinIndex = ''>
		<cfset var cabinItem = ''>
		<cfset var segmentIndex = ''>
		<cfset var segmentItem = ''>
		<cfset var SegmentIdAlt = ''>
		<cfset var TempSegments = {}>
		<cfset var Economy = {}>
		<cfset var Lowest = {}>
		<cfset var ShortestTravelTime = 100000>

		<!--- Mark segments as poor if they are longer and more expensive. --->

		<cfloop collection="#arguments.SegmentFares#" index="fareIndex" item="fareItem">
			<cfif structKeyExists(fareItem, 'Economy')>
				<cfset Economy = {}>
				<cfset Economy.TotalFare = fareItem.Economy.TotalFare>
				<cfset Economy.TotalTravelTimeInMinutes = Segments[fareItem.Economy.SegmentId].TotalTravelTimeInMinutes>
				<cfset Economy.CarrierCode =Segments[fareItem.Economy.SegmentId].CarrierCode>
				<cfset Economy.SegmentId = fareItem.Economy.SegmentId>
				<cfset DepartureTime = Segments[fareItem.Economy.SegmentId].DepartureTime>
				<cfparam name="TempSegments['#Segments[#fareItem.Economy.SegmentId#].DepartureTime&Economy.CarrierCode#']" default="#arrayNew()#">
				<cfset arrayAppend(TempSegments[Segments[fareItem.Economy.SegmentId].DepartureTime&Economy.CarrierCode], Economy)>
			</cfif>
		</cfloop>

		<cfloop collection="#TempSegments#" index="depatureIndex" item="depatureItem">
			<cfloop collection="#depatureItem#" index="segmentIndex" item="segmentItem">
				<cfif NOT structKeyExists(Lowest, depatureIndex)
					OR Lowest[depatureIndex].TotalFare GT segmentItem.TotalFare
					OR (Lowest[depatureIndex].TotalFare EQ segmentItem.TotalFare
						AND Lowest[depatureIndex].TotalTravelTimeInMinutes GT segmentItem.TotalTravelTimeInMinutes)>
					<cfset Lowest[depatureIndex].TotalFare = segmentItem.TotalFare>
					<cfset Lowest[depatureIndex].TotalTravelTimeInMinutes = segmentItem.TotalTravelTimeInMinutes>
					<cfset Lowest[depatureIndex].SegmentId = segmentItem.SegmentId>
				</cfif>
			</cfloop>
		</cfloop>

		<cfloop collection="#arguments.SegmentFares#" index="segmentIndex" item="segmentItem">
			<cfif structKeyExists(segmentItem, 'Economy')
				AND segmentItem.Economy.SegmentId CONTAINS '2544'>
				<cfset departureIndex = Segments[segmentItem.Economy.SegmentId].DepartureTime&Segments[segmentItem.Economy.SegmentId].CarrierCode>
				<cfif Lowest[departureIndex].TotalFare LTE segmentItem.Economy.TotalFare
					AND Lowest[departureIndex].TotalTravelTimeInMinutes LT Segments[segmentItem.Economy.SegmentId].TotalTravelTimeInMinutes>
					<cfset arguments.Segments[segmentItem.Economy.SegmentId].IsLongAndExpensive = true>
				</cfif>
			</cfif>
		</cfloop>

		<!--- Mark segments as poor if they are twice as long as the shortest route. --->

		<cfloop collection="#Segments#" index="segmentIndex" item="segmentItem">
			<cftry>
			<cfif ShortestTravelTime GT segmentItem.TotalTravelTimeInMinutes>
				<cfset ShortestTravelTime = segmentItem.TotalTravelTimeInMinutes>
			</cfif>
			<cfcatch>
			<cfdump var=#Segments# abort>
			</cfcatch>
		</cftry>
		</cfloop>

		<cfset ShortestTravelTime = ShortestTravelTime * 2>

		<cfloop collection="#Segments#" index="segmentIndex" item="segmentItem">
			<cfif ShortestTravelTime LTE segmentItem.TotalTravelTimeInMinutes>
				<cfset arguments.Segments[segmentIndex].IsLongSegment = true>
			</cfif>
		</cfloop>

		<cfreturn arguments.Segments>
	</cffunction>
 	
</cfcomponent>
