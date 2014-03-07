<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="UAPIFactory" />
	<cfproperty name="searchService" />

	<cffunction name="init" access="public" output="false" returntype="any" hint="I initialize this component" >
		<cfargument name="UAPIFactory" type="any" required="true" />
		<cfargument name="searchService" />

		<cfset setUAPIFactory( arguments.UAPIFactory ) />
		<cfset setSearchService( arguments.SearchService ) />

		<cfreturn this />
	</cffunction>

	<cffunction name="finishLowFare" output="false" hint="Do low fare.">
		<cfargument name="SearchID"	required="true">
		<cfargument name="Account"	required="true">
		<cfargument name="Policy"	required="true">

		<cfif NOT structIsEmpty(session.searches[SearchID].stTrips)>
			<!--- Check low fare. --->
			<cfset session.searches[SearchID].stTrips = addTotalBagFare(session.searches[SearchID].stTrips)>

			<!--- Update the results that are available. --->
			<cfset session.searches[SearchID].stLowFareDetails.stResults = findResults(session.searches[arguments.SearchID].stTrips)>

			<!--- Get list of all carriers returned. --->
			<cfset session.searches[SearchID].stLowFareDetails.aCarriers = getCarriers(session.searches[arguments.SearchID].stTrips)>

			<!--- Run policy on all the results --->
			<cfset session.searches[SearchID].stLowFareDetails.aSortFare = StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'Total')>
			<cfset session.searches[SearchID].stTrips = checkPolicy( session.searches[arguments.SearchID].stTrips
																	, arguments.SearchID
																	, session.searches[SearchID].stLowFareDetails.aSortFare[1]
																	, 'Fare'
																	, arguments.Account
																	, arguments.Policy)>

			<!--- Create javascript structure per trip. --->
			<cfset session.searches[SearchID].stTrips = addJavascript(session.searches[SearchID].stTrips)><!--- Policy needs to be checked prior --->

			<!--- Sort the results --->
			<cfset session.searches[SearchID].stLowFareDetails.aSortArrival = StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'Arrival')>
			<cfset session.searches[SearchID].stLowFareDetails.aSortDepart = StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'Depart')>
			<cfset session.searches[SearchID].stLowFareDetails.aSortDuration = StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'Duration')>

			<!--- price, price + 1 bag, price + 2 bags --->
			<cfset session.searches[SearchID].stLowFareDetails.aSortFare = StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'Total')>
			<cfset session.searches[SearchID].stLowFareDetails.aSortBag = StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'TotalBag')>
			<cfset session.searches[SearchID].stLowFareDetails.aSortBag2 = StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'TotalBag2')>

			<!--- Prices with preferred carriers taken into account --->
			<cfset session.searches[SearchID].stLowFareDetails.aSortFarePreferred = sortByPreferred("aSortFare", arguments.SearchID) />
			<cfset session.searches[SearchID].stLowFareDetails.aSortBagPreferred = sortByPreferred("aSortBag", arguments.SearchID) />
			<cfset session.searches[SearchID].stLowFareDetails.aSortBag2Preferred = sortByPreferred("aSortBag2", arguments.SearchID) />
		</cfif>

		<cfreturn >
	</cffunction>

	<cffunction name="parseSegments" output="false" hint="I take XML from uAPI and parse segments from it.">
		<cfargument name="stResponse"	required="true" hint="Truncated XML object">

		<cfset local.stSegments = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<!---
			'air:AirSegmentList' - found in low fare and availability search
			'air:AirItinerary' - found in air pricing
			--->
			<cfif stAirSegmentList.XMLName EQ 'air:AirSegmentList' OR stAirSegmentList.XMLName EQ 'air:AirItinerary'>

				<cfloop array="#local.stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<cfset local.dArrivalGMT = local.stAirSegment.XMLAttributes.ArrivalTime>
					<cfset local.dArrivalTime = GetToken(local.dArrivalGMT, 1, '.')>
					<cfset local.dArrivalOffset = GetToken(GetToken(local.dArrivalGMT, 2, '-'), 1, ':')>

					<!--- this is some ugly nested looping to get flightDetailsRef key so we can pull travelTime from flightDetails --->
					<cfloop array="#local.stAirSegment.xmlChildren#" index="local.key1">
						<cfif StructKeyExists(local.key1.xmlAttributes, "Key")>
							<cfset local.detailKey = local.key1.xmlAttributes.key>
						</cfif>
					</cfloop>
					<cfset local.travelTime = 0>
					<cfloop array="#arguments.stResponse[1].xmlChildren#" index="local.key2">
						<cfif StructKeyExists(local.key2.xmlAttributes, "Key") AND local.key2.xmlAttributes.key EQ local.detailKey>
							<cfset local.travelTime = local.key2.xmlAttributes.travelTime>
						</cfif>
					</cfloop>

					<cfset local.stSegments[local.stAirSegment.XMLAttributes.Key] = {
						ArrivalTime : ParseDateTime(local.dArrivalTime),
						ArrivalGMT : ParseDateTime(DateAdd('h', local.dArrivalOffset, local.dArrivalTime)),
						Carrier : local.stAirSegment.XMLAttributes.Carrier,
						ChangeOfPlane : local.stAirSegment.XMLAttributes.ChangeOfPlane EQ 'true',
						DepartureTime : ParseDateTime(GetToken(local.stAirSegment.XMLAttributes.DepartureTime, 1, '.')),
						DepartureGMT : dateConvert('local2Utc', local.stAirSegment.XMLAttributes.DepartureTime),
						Destination : local.stAirSegment.XMLAttributes.Destination,
						Equipment : (StructKeyExists(local.stAirSegment.XMLAttributes, 'Equipment') ? local.stAirSegment.XMLAttributes.Equipment : ''),
						FlightNumber : local.stAirSegment.XMLAttributes.FlightNumber,
						FlightTime : local.stAirSegment.XMLAttributes.FlightTime,
						Group : local.stAirSegment.XMLAttributes.Group,
						Origin : local.stAirSegment.XMLAttributes.Origin,
						TravelTime : local.travelTime,
						PolledAvailabilityOption : (StructKeyExists(local.stAirSegment.XMLAttributes, 'PolledAvailabilityOption') ? local.stAirSegment.XMLAttributes.PolledAvailabilityOption : ''),
					}>
				</cfloop>

			</cfif>
		</cfloop>

		<cfreturn local.stSegments />
	</cffunction>

	<cffunction name="parseSearchID" output="false" hint="I get the search ID from uAPI response.">
		<cfargument name="sResponse"	required="true">

		<cfset local.stResponse = XMLParse(arguments.sResponse)>
		<cfset local.sLowFareSearchID = ''>

		<cfset local.stResponse = local.stResponse.XMLRoot.XMLChildren[1].XMLChildren[1].XMLAttributes>
		<cfif structKeyExists(local.stResponse, "sLowFareSearchID")>
			<cfset local.sLowFareSearchID = local.stResponse.SearchID>
		</cfif>

		<cfreturn local.sLowFareSearchID />
	</cffunction>

	<cffunction name="parseNextReference" output="false" hint="I get NextResultReference from uAPI XML response.">
		<cfargument name="stResponse"	required="true">

		<cfset local.sNextRef = ''>
		<cfloop array="#arguments.stResponse#" index="local.aNextResultReference">

		<!--- TODO: need to replace these schema references with something from
			coldspring environment service

			8:28 AM Thursday, August 01, 2013 - Jim Priest - jpriest@shortstravel.com

			Was: common_v15_0:NextResultReference
			Should be: common_v19_0:NextResultReference --->

			<cfif local.aNextResultReference.XMLName EQ 'common_v19_0:NextResultReference'>
				<cfset local.sNextRef = local.aNextResultReference.XMLText>
			</cfif>
		</cfloop>

		<cfreturn local.sNextRef />
	</cffunction>

	<cffunction name="parseTrips" output="false" hint="I take response and segments and parse trip data.">
		<cfargument name="response" required="true">
		<cfargument name="stSegments" required="true">
		<cfargument name="bRefundable" required="false" default="false">

		<cfset local.stTrips = {}>
		<cfset local.stTrip = {}>
		<cfset local.sTripKey = ''>
		<cfset local.nCount = 0>
		<cfset local.sSegmentKey = 0>
		<cfset local.sIndex = ''>
		<cfset local.distinctFields = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<cfset local.changePenalty = 0>
		<!---
		Custom code for air pricing to move the 'air:AirPriceResult' up a node to work with the current parsing code.
        --->
		<cfloop array="#arguments.response#" index="local.stAirPricingSolution">
			<cfif local.stAirPricingSolution.XMLName EQ 'air:AirPriceResult'>
				<cfloop array="#local.stAirPricingSolution.XMLChildren#" index="local.test">
					<cfset ArrayAppend(arguments.response, local.test)>
				</cfloop>
			</cfif>
		</cfloop>

		<!---
		Create a quick struct containing the private fare information
		--->
		<cfset local.fare = {}>
		<cfloop array="#arguments.response#" index="local.fareInfoListIndex" item="local.fareInfoList">
			<cfif local.fareInfoList.XMLName EQ 'air:FareInfoList'>
				<cfloop array="#local.fareInfoList.XMLChildren#" index="local.fareInfoIndex" item="local.fareInfo">
					<cfset local.fare[local.fareInfo.XMLAttributes.Key].PrivateFare = (StructKeyExists(local.fareInfo.XMLAttributes, 'PrivateFare') AND local.fareInfo.XMLAttributes.PrivateFare NEQ '' ? true : false)>
				</cfloop>
			</cfif>
		</cfloop>

		<cfloop array="#arguments.response#" index="local.stAirPricingSolution" item="local.responseNode">

			<cfif local.responseNode.XMLName EQ 'air:AirPricingSolution'>

				<cfset local.stTrip = {}>
				<cfset local.stTrip.Segments = StructNew('linked')>
				<cfset local.nCount = 0>
				<cfset local.nDuration = 0>
				<cfset local.bPrivateFare = false>
				<cfset local.tripKey = ''>

				<cfloop array="#local.responseNode.XMLChildren#" index="local.airPricingSolutionIndex" item="local.airPricingSolution">

					<cfif local.airPricingSolution.XMLName EQ 'air:Journey'>

						<cfloop array="#local.airPricingSolution.XMLChildren#" index="local.journeyItem" item="local.journey">
							<cfif local.journey.XMLName EQ 'air:AirSegmentRef'>
								<cfset local.stTrip.Segments[local.journey.XMLAttributes.Key] = structKeyExists(arguments.stSegments, local.journey.XMLAttributes.Key) ? structCopy(arguments.stSegments[local.journey.XMLAttributes.Key]) : {}>

								<cfloop array="#local.distinctFields#" index="local.field">
									<cfset local.tripKey &= local.stTrip.Segments[local.journey.XMLAttributes.Key][local.field]>
								</cfloop>

							</cfif>
						</cfloop>

					<cfelseif local.airPricingSolution.XMLName EQ 'air:AirSegmentRef'>

						<cfset local.stTrip.Segments[local.airPricingSolution.XMLAttributes.Key] = structKeyExists(arguments.stSegments, local.airPricingSolution.XMLAttributes.Key) ? structCopy(arguments.stSegments[local.airPricingSolution.XMLAttributes.Key]) : {}>

						<cfloop array="#local.distinctFields#" index="local.field">
							<cfset local.tripKey &= local.stTrip.Segments[local.airPricingSolution.XMLAttributes.Key][local.field]>
						</cfloop>

					<cfelseif local.airPricingSolution.XMLName EQ 'air:AirPricingInfo'>

						<cfset local.sOverallClass = 'E'>
						<cfset local.sPTC = ''>
						<cfset local.nCount = 0>
						<cfset local.fareRuleKey = []>
						<cfset local.refundable = false>
						<cfset local.changePenalty = 0>
<!---
MULTI CARRIER AND PF
GET CHEAPEST OF LOOP. MULTIPLE AirPricingInfo
--->
						<cfloop array="#airPricingSolution.XMLChildren#" index="local.airPricingSolution2">
							<cfif local.airPricingSolution2.XMLName EQ 'air:PassengerType'>
								<!--- Passenger type codes --->
								<cfset local.sPTC = local.airPricingSolution2.XMLAttributes.Code>
							<cfelseif local.airPricingSolution2.XMLName EQ 'air:FareInfoRef'>
								<!--- Private fares 1/0 --->
								<cfif fare[local.airPricingSolution2.XMLAttributes.Key].PrivateFare>
									<cfset local.bPrivateFare = true>
								</cfif>
							<cfelseif local.airPricingSolution2.XMLName EQ 'air:FareInfo'>
								<!--- Private fares 1/0 --->
								<cfif structKeyExists(local.airPricingSolution2.XMLAttributes, 'PrivateFare')
									AND local.airPricingSolution2.XMLAttributes.PrivateFare NEQ ''>
									<cfset local.bPrivateFare = true>
								</cfif>
							<cfelseif local.airPricingSolution2.XMLName EQ 'air:BookingInfo'>
								<!--- Pricing cabin class --->
								<cfset local.sClass = (StructKeyExists(local.airPricingSolution2.XMLAttributes, 'CabinClass') ? local.airPricingSolution2.XMLAttributes.CabinClass : 'Economy')>
								<cfset local.stTrip.Segments[local.airPricingSolution2.XMLAttributes.SegmentRef].Class = local.airPricingSolution2.XMLAttributes.BookingCode>
								<cfset local.stTrip.Segments[local.airPricingSolution2.XMLAttributes.SegmentRef].Cabin = local.sClass>
								<cfif local.sClass EQ 'First'>
									<cfset local.sOverallClass = 'F'>
								<cfelseif local.sOverallClass NEQ 'F' AND local.sClass EQ 'Business'>
									<cfset local.sOverallClass = 'C'>
								<cfelseif local.sOverallClass NEQ 'F' AND local.sOverallClass NEQ 'C'>
									<cfset local.sOverallClass = 'Y'>
								</cfif>
							<cfelseif local.airPricingSolution2.XMLName EQ 'air:ChangePenalty'>
								<!--- Refundable or non refundable --->
								<cfloop array="#local.airPricingSolution2.XMLChildren#" index="local.stFare">
									<cfif local.changePenalty LTE replace(local.stFare.XMLText, 'USD', '')>
										<cfset local.changePenalty = replace(local.stFare.XMLText, 'USD', '')>
									</cfif>
								</cfloop>
							</cfif>
						</cfloop>
						<cfset local.stTrip.Base = Mid(local.airPricingSolution.XMLAttributes.BasePrice, 4)>
						<cfset local.stTrip.ApproximateBase = Mid(local.airPricingSolution.XMLAttributes.ApproximateBasePrice, 4)>
						<cfset local.stTrip.Total = Mid(local.airPricingSolution.XMLAttributes.TotalPrice, 4)>
						<cfset local.stTrip.Taxes = Mid(local.airPricingSolution.XMLAttributes.Taxes, 4)>
						<cfset local.stTrip.PrivateFare = local.bPrivateFare>
						<cfset local.stTrip.PTC = local.sPTC>
						<cfset local.stTrip.Class = local.sOverallClass>
						<cfset local.refundable = (structKeyExists(airPricingSolution.XMLAttributes, 'Refundable') AND airPricingSolution.XMLAttributes.Refundable EQ 'true' ? 1 : 0)>
						<cfset local.stTrip.Ref = local.refundable>
						<cfset local.stTrip.RequestedRefundable = (arguments.bRefundable IS 'true' ? 1 : 0)>
						<cfset local.stTrip.changePenalty = changePenalty>
					</cfif>
				</cfloop>
				<cfset local.sTripKey = getUAPI().hashNumeric( local.tripKey&local.sOverallClass&refundable )>
				<cfset local.stTrips[local.sTripKey] = local.stTrip>
			</cfif>
		</cfloop>

<!--- <cfdump var="#attributes.stTrips#" /> --->
<!--- <cfloop collection="#local.stTrips#" index="i" item="trip">
	<cfset segmentnumbers = ''>
	<cfloop collection="#trip.segments#" index="i" item="segment">
		<cfset segmentnumbers = listAppend(segmentnumbers, segment.flightnumber)>
	</cfloop>
	<cfdump var="#segmentnumbers#" />
	<cfif segmentnumbers EQ '5266,1561,1761,5473'>
		<cfdump var="#trip#" />
		<cfabort />
	</cfif>
</cfloop>
<cfabort /> --->

		<cfreturn  local.stTrips/>
	</cffunction>

	<cffunction name="mergeSegments" output="false" hint="I merge passed in segments.">
		<cfargument name="stSegments1" 	required="true">
		<cfargument name="stSegments2" 	required="true">

		<cfset local.stSegments = arguments.stSegments1>
		<cfif IsStruct(local.stSegments) AND IsStruct(arguments.stSegments2)>
			<cfloop collection="#arguments.stSegments2#" item="local.sSegmentKey">
				<cfif NOT StructKeyExists(local.stSegments, local.sSegmentKey)>
					<cfset local.stSegments[local.sSegmentKey] = arguments.stSegments2[local.sSegmentKey]>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset local.stSegments = arguments.stSegments2>
		</cfif>
		<cfif NOT IsStruct(local.stSegments)>
			<cfset local.stSegments = {}>
		</cfif>

		<cfreturn local.stSegments/>
	</cffunction>

	<cffunction name="mergeTrips" output="false" hint="I merge passed in trips.">
		<cfargument name="stTrips1" required="true">
		<cfargument name="stTrips2" required="true">

		<cfset local.stCombinedTrips = structCopy(arguments.stTrips1)>

		<cfif IsStruct(local.stCombinedTrips) AND IsStruct(arguments.stTrips2)>
			<cfloop collection="#arguments.stTrips2#" item="local.sTripKey">

				<cfif ( structKeyExists(local.stCombinedTrips, local.sTripKey)
					AND arguments.stTrips2[local.sTripKey].privateFare )
					OR NOT structKeyExists(local.stCombinedTrips, local.sTripKey)>

					<cfset local.stCombinedTrips[local.sTripKey] = structCopy(arguments.stTrips2[local.sTripKey])>

				</cfif>

			</cfloop>
		<cfelseif IsStruct(arguments.stTrips2)>
			<cfset local.stCombinedTrips = structCopy(arguments.stTrips2)>
		</cfif>

		<cfif NOT IsStruct(local.stCombinedTrips)>
			<cfset local.stCombinedTrips = {}>
		</cfif>

		<cfreturn local.stCombinedTrips/>
	</cffunction>

	<cffunction name="addPreferred" output="false" hint="I set preferred flag.">
		<cfargument name="stTrips"  required="true">
		<cfargument name="Account"	required="false">

		<cfset local.stTrips = arguments.stTrips>
		<cfloop collection="#local.stTrips#" item="local.sTripKey">
			<cfset local.stTrips[local.sTripKey].Preferred = 0>
			<cfloop array="#arguments.stTrips[local.sTripKey].Carriers#" index="local.sCarrier">
				<cfif ArrayFindNoCase(arguments.Account.aPreferredAir, local.sCarrier)>
					<cfset local.stTrips[local.sTripKey].Preferred = 1>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn local.stTrips/>
	</cffunction>

	<cffunction name="addGroups" output="false" hint="I add groups.">
		<cfargument name="stTrips" required="true">
		<cfargument name="sType" required="false" default="Fare">

		<cfset local.stGroups = {}>
		<cfset local.aCarriers = {}>
		<cfset local.stTrips = arguments.stTrips>
		<cfset local.stSegment = ''>
		<cfset local.nStops = ''>
		<cfset local.nTotalStops = ''>
		<cfset local.nDuration = ''>
		<cfset local.nOverrideGroup = 0>
		<!--- Loop through all the trips --->
		<cfloop collection="#stTrips#" index="local.tripIndex" item="local.trip">
			<cfset local.stGroups = StructNew('linked')>
			<cfset local.aCarriers = {}>
			<cfset local.nDuration = 0>
			<cfset local.nTotalStops = 0>
			<cfloop collection="#trip.Segments#" index="local.segmentIndex" item="local.segment">
				<cfset local.nOverrideGroup = local.segment.Group>
				<cfset local.segment.Group = local.nOverrideGroup>
				<cfif NOT structKeyExists(local.stGroups, local.nOverrideGroup)>
					<cfset local.stGroups[local.nOverrideGroup].Segments = StructNew('linked')>
					<cfset local.stGroups[local.nOverrideGroup].DepartureTime = local.segment.DepartureTime>
					<cfset local.stGroups[local.nOverrideGroup].Origin = local.segment.Origin>
					<cfset local.stGroups[local.nOverrideGroup].TravelTime = '#int(local.segment.TravelTime/60)#h #local.segment.TravelTime%60#m'>
					<cfset local.nDuration = local.segment.TravelTime + local.nDuration>
					<cfset local.nStops = -1>
				</cfif>
				<cfset local.stGroups[local.nOverrideGroup].Segments[local.segmentIndex] = local.segment>
				<cfset local.stGroups[local.nOverrideGroup].ArrivalTime = local.segment.ArrivalTime>
				<cfset local.stGroups[local.nOverrideGroup].Destination = local.segment.Destination>
				<cfset local.aCarriers[local.segment.Carrier] = ''>
				<cfset local.nStops++>
				<cfset local.stGroups[local.nOverrideGroup].Stops = local.nStops>
				<cfif local.nStops GT local.nTotalStops>
					<cfset local.nTotalStops = local.nStops>
				</cfif>
			</cfloop>
			<cfset local.stTrips[local.tripIndex].Groups = local.stGroups>
			<cfset local.stTrips[local.tripIndex].Duration = local.nDuration>
			<cfset local.stTrips[local.tripIndex].Stops = local.nTotalStops>
			<cfif arguments.sType EQ 'Avail'>
				<cfset local.stTrips[local.tripIndex].Depart = local.stGroups[local.nOverrideGroup].DepartureTime>
			<cfelse>
				<cfset local.stTrips[local.tripIndex].Depart = local.stGroups[0].DepartureTime>
			</cfif>
			<cfset local.stTrips[tripIndex].Arrival = local.stGroups[local.nOverrideGroup].ArrivalTime>
			<cfset local.stTrips[tripIndex].Carriers = structKeyArray(local.aCarriers)>
			<cfset local.stTrips[tripIndex].validCarriers = flagBlackListedCarriers(local.stTrips[tripIndex].Carriers)>
			<cfset local.stTrips[tripIndex].PlatingCarrier = setPlatingCarrier(local.stTrips[tripIndex].Groups)>
			<cfset StructDelete(local.stTrips[local.tripIndex], 'Segments')>
		</cfloop>

		<cfreturn local.stTrips/>
	</cffunction>

	<cffunction name="removeBlackListedCarriers" output="false" hint="I add remove trips with blacklisted carrier combinations.">
		<cfargument name="trips" required="true">
		<cfargument name="blackListedCarriers" required="true">

		<cfset local.trips = arguments.trips>
		<cfset local.deleteTripIndex = "">

		<!--- Loop through all the trips --->
		<cfloop collection="#local.trips#" index="local.tripIndex" item="local.trip">

			<cfif arrayLen(local.trip.carriers) GT 1
				AND arrayFind(local.trip.carriers, 'WN')>
				<cfset local.deleteTripIndex = ListAppend(local.deleteTripIndex, local.tripIndex)>

			<!--- if carriers array only has one carrier - we don't need to check it --->
			<cfelseif arrayLen(local.trip.carriers) GT 1>
				<cfset local.carrierList = ArrayToList(local.trip.carriers)>

				<cfloop array="#arguments.blackListedCarriers#" index="local.blackListedIndex" item="local.blackListedCarrier">
					<cfset local.blackList = ArrayToList(local.blackListedCarrier)>

					<cfif listFindNoCase( local.carrierList, listGetAt( local.blackList, 1) )
						AND listFindNoCase( local.carrierList, listGetAt( local.blackList, 2) )>

						<!--- if any match is found we can stop checking and go to next flight --->
						<cfset local.deleteTripIndex = ListAppend(local.deleteTripIndex, local.tripIndex)>
						<cfbreak>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>

		<!--- delete the blacklisted flights from stTrips --->
		<cfloop list="#local.deleteTripIndex#" item="local.tripIndex">
			<cfset StructDelete(local.trips, local.tripIndex)>
		</cfloop>

		<cfreturn local.trips/>
	</cffunction>

	<cffunction name="removeMultiCarrierPrivateFares" output="false" hint="I add remove trips with blacklisted carrier combinations.">
		<cfargument name="trips" required="true">

		<cfset local.deleteTripIndex = ''>

		<cfloop collection="#arguments.trips#" index="local.tripIndex" item="local.trip">
			<cfif arrayLen(local.trip.carriers) GT 1
				AND local.trip.privateFare>
				<cfset local.deleteTripIndex = ListAppend(local.deleteTripIndex, local.tripIndex)>
			</cfif>
		</cfloop>

		<cfloop list="#local.deleteTripIndex#" item="local.tripIndex">
			<cfset StructDelete(arguments.trips, local.tripIndex)>
		</cfloop>

		<cfreturn arguments.trips/>
	</cffunction>

	<cffunction name="removeMultiConnections" output="false" hint="I add remove trips with blacklisted carrier combinations.">
		<cfargument name="trips" required="true">

		<cfset local.trashSegmentCount = ''>
		<cfset local.twoSegments = false>
		<cfset local.threeSegments = false>
		<cfset local.fourSegments = false>
		<cfset local.tripsTwo = []>
		<cfset local.tripsThree = []>
		<cfset local.tripsFour = []>
		<!--- Takes into account all groups within the itinerary.  If there are three on the outbound and two on the return it
		will mark that trip as a two segment trip. --->
		<cfloop collection="#arguments.trips#" index="local.tripIndex" item="local.trip">
			<cfset local.tempTwoSegments = false>
			<cfset local.tempThreeSegments = false>
			<cfset local.tempFourSegments = false>
			<cfloop collection="#trip.Groups#" index="local.groupIndex" item="local.group">
				<cfset local.segmentCount = arrayLen(structKeyArray(local.group.segments))>
				<cfset local.tempTwoSegments = (local.segmentCount EQ 2 ? true : local.tempTwoSegments)>
				<cfset local.tempThreeSegments = (local.segmentCount EQ 3 ? true : local.tempThreeSegments)>
				<cfset local.tempFourSegments = (local.segmentCount EQ 4 ? true : local.tempFourSegments)>
			</cfloop>
			<cfif local.tempTwoSegments>
				<cfset arrayAppend(local.tripsTwo, local.tripIndex)>
				<cfset local.twoSegments = true>
			<cfelseif local.tempThreeSegments>
				<cfset arrayAppend(local.tripsThree, local.tripIndex)>
				<cfset local.threeSegments = true>
			<cfelseif local.tempFourSegments>
				<cfset arrayAppend(local.tripsFour, local.tripIndex)>
				<cfset local.fourSegments = true>
			</cfif>
		</cfloop>
		<cfif local.threeSegments
			AND local.twoSegments>
			<cfset local.trashSegmentCount = 'tripsThree,tripsFour'>
		<cfelseif local.fourSegments
			AND local.threeSegments>
			<cfset local.trashSegmentCount = 'tripsFour'>
		</cfif>
		<cfif local.trashSegmentCount NEQ ''>
			<cfloop list="#trashSegmentCount#" index="local.arrayIndex" item="local.arrayName">
				<cfloop array="#local[arrayName]#" index="local.tripIndex" item="local.tripKey">
					<cfset structDelete(arguments.trips, local.tripKey)>
				</cfloop>
			</cfloop>
		</cfif>

		<cfreturn arguments.trips/>
	</cffunction>

	<cffunction name="flagBlackListedCarriers" output="false" hint="I check a trips carriers to see if it is blacklisted.">
		<cfargument name="carriers" required="true">

		<cfset local.validFlight = true>
		<cfif arrayLen(arguments.carriers) GT 1
			AND arrayFind(arguments.carriers, 'WN')>
			<cfset local.validFlight = false>
		<cfelseif arrayLen(arguments.carriers) GT 1>
			<cfset local.validFlight = true>
			<cfloop array="#arguments.carriers#" index="local.carrierIndex" item="local.carrier">
				<cfif structKeyExists(application.blacklistedCarriers, local.carrier)>
					<cfloop array="#arguments.carriers#" index="local.carrier2Index" item="local.carrier2">
						<cfif local.carrier NEQ local.carrier2>
							<cfif structKeyExists(application.blacklistedCarriers[local.carrier], local.carrier2)>
								<cfset local.validFlight = false>
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn local.validFlight/>
	</cffunction>

	<cffunction name="setPlatingCarrier" output="false" hint="I find the plating/validating carrier per trip.">
		<cfargument name="groups" required="true" />

		<cfset local.numGroups = structCount(arguments.groups) />
		<cfset local.platingCarrier = '' />
		<cfset local.isDomesticTrip = true />

		<!--- Check to see if domestic or international trip --->
		<cfloop collection="#arguments.groups#" index="local.groupIndex" item="local.group">
			<cfset local.isDomesticTrip = getSearchService().getTripType(group.origin, group.destination, application.stAirports) />
			<cfif NOT isDomesticTrip>
				<cfbreak>
			</cfif>
		</cfloop>

		<cfloop collection="#arguments.groups#" index="local.groupIndex" item="local.group">
			<cfset local.actualGroupCount = groupIndex + 1 />

			<!--- For domestic trips, the plating or validating carrier is always the carrier in the first segment in the last group --->
			<cfif isDomesticTrip>
				<cfif actualGroupCount EQ numGroups>
					<cfloop collection="#group.Segments#" index="local.segmentIndex" item="local.segment">
						<cfset local.platingCarrier = segment.Carrier />
						<cfbreak>
					</cfloop>
				</cfif>
			<!--- For international trips, the plating or validating carrier is the first carrier over the pond (on the way out) --->
			<cfelse>
				<cfloop collection="#group.Segments#" index="local.segmentIndex" item="local.segment">
					<cfset local.isSegmentDomesticTrip = getSearchService().getTripType(segment.origin, segment.destination, application.stAirports) />
					<cfif NOT isSegmentDomesticTrip>
						<cfset local.platingCarrier = segment.Carrier />
						<cfbreak>
					</cfif>
				</cfloop>
			</cfif>
			<cfif len(local.platingCarrier)>
				<cfbreak>
			</cfif>
		</cfloop>

		<cfreturn local.platingCarrier />
	</cffunction>

	<cffunction name="addTotalBagFare" output="false" hint="Set Price + 1 bag and Price + 2 bags.">
		<cfargument name="stTrips" 	required="true">
		<cfloop collection="#arguments.stTrips#" item="local.sTrip">
			<cfif NOT StructKeyExists(arguments.stTrips[local.sTrip], 'TotalBag')>
				<cfset arguments.stTrips[local.sTrip].TotalBag = arguments.stTrips[local.sTrip].Total + application.stAirVendors[arguments.stTrips[local.sTrip].Carriers[1]].Bag1>
			</cfif>
			<cfif NOT StructKeyExists(arguments.stTrips[local.sTrip], 'TotalBag2')>
				<cfset arguments.stTrips[local.sTrip].TotalBag2 = arguments.stTrips[local.sTrip].Total + application.stAirVendors[arguments.stTrips[local.sTrip].Carriers[1]].Bag2>
			</cfif>
		</cfloop>
		<cfreturn arguments.stTrips/>
	</cffunction>

	<cffunction name="findResults" output="false" hint="I populate the stResults struct with flight numbers for fares and classes (0,1,Y,C,F).">
		<cfargument name="stTrips" 	required="true">

		<cfset local.stResults = {}>

		<!--- set default values for fares and class --->
		<cfset local.stResults.Y = 0>
		<cfset local.stResults.C = 0>
		<cfset local.stResults.F = 0>
		<cfset local.stResults.0 = 0>
		<cfset local.stResults.1 = 0>

		<cfset local.sClass = ''>
		<cfset local.bRef = ''>

		<cfloop collection="#arguments.stTrips#" item="local.nTripKey">
			<cfset local.sClass = arguments.stTrips[local.nTripKey].Class>
			<cfset local.bRef = arguments.stTrips[local.nTripKey].Ref>

			<cfif NOT structKeyExists(local.stResults, local.sClass)>
				<cfset local.stResults[local.sClass] = 0>
			</cfif>

			<cfif NOT structKeyExists(local.stResults, local.bRef)>
				<cfset local.stResults[local.bRef] = 0>
			</cfif>

			<cfset local.stResults[local.sClass] = local.stResults[local.sClass] + 1>
			<cfset local.stResults[local.bRef] = local.stResults[local.bRef] + 1>
		</cfloop>

		<cfreturn local.stResults/>
	</cffunction>

	<cffunction name="addJavascript" output="false" hint="I build javascript for trip info to be used in views">
		<cfargument name="stTrips" 	required="true">
		<cfargument name="sType" 	required="false"	default="Fare">

		<cfset local.stTrips = arguments.stTrips>

		<!--- Loop through all the trips --->
		<cfloop collection="#local.stTrips#" item="local.sTrip">
			<cfset local.sCarriers = '"#Replace(ArrayToList(local.stTrips[local.sTrip].Carriers), ',', '","', 'ALL')#"'>
			<cfset local.stTrips[local.sTrip].sJavascript = addJavascriptPerTrip(local.sTrip, local.stTrips[local.sTrip], local.stTrips[local.sTrip].Class, local.stTrips[local.sTrip].Ref, local.sCarriers)>
			<cfset local.stTrips[local.sTrip].nTripKey = local.sTrip>
		</cfloop>

		<cfreturn local.stTrips/>
	</cffunction>

	<cffunction name="addJavascriptPerTrip" output="false" access="private" hint="addJavascriptPerTrip - used only in the above function">
		<cfargument name="sTrip" 	required="true">
		<cfargument name="stTrip" 	required="true">
		<cfargument name="sCabin" 	required="true">
		<cfargument name="bRef" 	required="true">
		<cfargument name="sCarriers"required="true">

		<cfset local.sJavascript = "">
		<!---
			 * 	0	Token				DL0211DL1123UA221
			 * 	1	Policy				1/0
			 * 	2 	Multiple Carriers	1/0
			 * 	3 	Carriers			"DL","AA","UA"
			 * 	4	Refundable			1/0
			 * 	5	Preferred			1/0
			 * 	6	Cabin Class			Y, C, F
			 * 	7	Stops				0/1/2
		--->
		<cfset local.sJavascript = '"#arguments.sTrip#"'><!--- Token  --->
		<cfset local.sJavascript = ListAppend(local.sJavascript, (ArrayIsEmpty(arguments.stTrip.aPolicies) ? 1 : 0))><!--- Policy --->
		<cfset local.sJavascript = ListAppend(local.sJavascript, (ListLen(arguments.sCarriers) EQ 1 ? 0 : 1))><!--- Multi Carriers --->
		<cfset local.sJavascript = ListAppend(local.sJavascript, '[#arguments.sCarriers#]')><!--- All Carriers --->
		<cfset local.sJavascript = ListAppend(local.sJavascript, '"#arguments.bRef#"')><!--- Refundable --->
		<cfset local.sJavascript = ListAppend(local.sJavascript, arguments.stTrip.Preferred)><!--- Preferred --->
		<cfset local.sJavascript = ListAppend(local.sJavascript, '"#arguments.sCabin#"')><!--- Cabin Class --->
		<cfset local.sJavascript = ListAppend(local.sJavascript, arguments.stTrip.Stops)><!--- Stops --->

		<cfreturn local.sJavascript/>
	</cffunction>

	<cffunction name="getCarriers" output="false" hint="Give a trip I pull out the carriers.">
		<cfargument name="stTrips">

		<cfset local.aCarriers = []>
		<cfloop collection="#arguments.stTrips#" item="local.sTripKey">
			<cfloop array="#arguments.stTrips[sTripKey].Carriers#" index="local.sCarrier">
				<cfif NOT ArrayFind(aCarriers, sCarrier)>
					<cfset ArrayAppend(aCarriers, sCarrier)>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn aCarriers/>
	</cffunction>

	<cffunction name="checkPolicy" output="false" hint="I check the policy.">
		<cfargument name="stTrips" required="true">
		<cfargument name="SearchID" required="true">
		<cfargument name="nLowFareTripKey" required="true">
		<cfargument name="sType" required="false">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">

		<cfset local.stTrips = arguments.stTrips>
		<cfset local.stTrip = {}>
		<cfset local.aPolicy = []>
		<cfset local.bActive = 1>
		<cfset local.bBlacklisted = (ArrayLen(arguments.Account.aNonPolicyAir) GT 0 ? 1 : 0)>
		<cfif arguments.sType EQ 'Fare'>
			<cfset local.nLowFare = local.stTrips[arguments.nLowFareTripKey].Total+arguments.Policy.Policy_AirLowPad>
		</cfif>

		<cfloop collection="#local.stTrips#" item="local.nTripKey">
			<cfset local.stTrip = local.stTrips[local.nTripKey]>
			<cfset local.aPolicy = []>
			<cfset local.bActive = 1>

			<cfif arguments.sType EQ 'Fare'>
				<!--- Out of policy if the fare plus the padding is greater than the lowest available fare. --->
				<cfif arguments.Policy.Policy_AirLowRule EQ 1
				AND IsNumeric(arguments.Policy.Policy_AirLowPad)
				AND local.stTrip.Total GT local.nLowFare>
					<cfset ArrayAppend(local.aPolicy, 'Not the lowest fare')>
					<cfif arguments.Policy.Policy_AirLowDisp EQ 1>
						<cfset local.bActive = 0>
					</cfif>
				</cfif>

				<!--- Out of policy if the total fare is over the maximum allowed fare. --->
				<cfif arguments.Policy.Policy_AirMaxRule EQ 1
				AND IsNumeric(arguments.Policy.Policy_AirMaxTotal)
				AND local.stTrip.Total GT arguments.Policy.Policy_AirMaxTotal>
					<cfset ArrayAppend(local.aPolicy, 'Fare greater than #DollarFormat(arguments.Policy.Policy_AirMaxTotal)#')>
					<cfif arguments.Policy.Policy_AirMaxDisp EQ 1>
						<cfset local.bActive = 0>
					</cfif>
				</cfif>

				<!--- Don't display when non refundable --->
				<cfif arguments.Policy.Policy_AirRefRule EQ 1
				AND arguments.Policy.Policy_AirRefDisp EQ 1
				AND local.stTrip.Ref EQ 0>
					<cfset ArrayAppend(local.aPolicy, 'Hide non refundable fares')>
					<cfset local.bActive = 0>
				</cfif>

				<!--- Don't display when refundable --->
				<cfif arguments.Policy.Policy_AirNonRefRule EQ 1
				AND arguments.Policy.Policy_AirNonRefDisp EQ 1
				AND local.stTrip.Ref EQ 1>
					<cfset ArrayAppend(local.aPolicy, 'Hide refundable fares')>
					<cfset local.bActive = 0>
				</cfif>

				<!--- Remove first refundable fares --->
				<cfif local.stTrip.Class EQ 'F'
				AND local.stTrip.Ref EQ 1>
					<cfset ArrayAppend(local.aPolicy, 'Hide UP fares')>
					<cfset local.bActive = 0>
				</cfif>
			</cfif>

			<!--- Out of policy if they cannot book non preferred carriers. --->
			<cfif arguments.Policy.Policy_AirPrefRule EQ 1
			AND local.stTrip.Preferred EQ 0>
				<cfset ArrayAppend(local.aPolicy, 'Not a preferred carrier')>
				<cfif arguments.Policy.Policy_AirPrefDisp EQ 1>
					<cfset local.bActive = 0>
				</cfif>
			</cfif>

			<!--- Out of policy if the carrier is blacklisted (still shows though). --->
			<cfif local.bBlacklisted>
				<cfloop array="#local.stTrip.Carriers#" item="local.sCarrier">
					<cfif ArrayFindNoCase(arguments.Account.aNonPolicyAir, local.sCarrier)>
						<cfset ArrayAppend(local.aPolicy, 'Out of policy carrier')>
					</cfif>
				</cfloop>
			</cfif>

			<!--- Departure time is too close to current time. --->
			<cfif DateDiff('h', Now(), local.stTrip.Depart) LTE 2>
				<cfset ArrayAppend(aPolicy, 'Departure time is within 2 hours')>
				<cfset local.bActive = 0>
			</cfif>
			<cfif local.bActive EQ 1>
				<cfset local.stTrips[local.nTripKey].Policy = (ArrayIsEmpty(local.aPolicy) ? 1 : 0)>
				<cfset local.stTrips[local.nTripKey].aPolicies = local.aPolicy>
			<cfelse>
				<cfset local.temp = StructDelete(local.stTrips, local.nTripKey)>
			</cfif>
		</cfloop>

		<cfif NOT structKeyExists(local, "nTripKey")
			AND NOT structIsEmpty(stTrips)>
			<cfset local.nTripKey = listGetAt(structKeyList(stTrips), 1)>
		</cfif>

		<cfif structKeyExists(local, "nTripKey")
			AND local.nTripKey NEQ ''>
			<!--- Out of policy if the depart date is less than the advance purchase requirement. --->
			<cfset local.bAllInactive = 0>
			<cfif arguments.Policy.Policy_AirAdvRule EQ 1
			AND DateDiff('d', local.stTrips[local.nTripKey].Depart, Now()) GT arguments.Policy.Policy_AirAdv>
				<cfset local.bAllInactive = 1>
				<cfif arguments.Policy.Policy_AirAdvDisp EQ 1>
					<cfset local.stTrips = {}>
				</cfif>
			</cfif>
		</cfif>

		<cfreturn local.stTrips/>
	</cffunction>

	<cffunction name="sortByPreferred" output="false" hint="I take the price sorts and weight the preferred carriers.">
		<cfargument name="StructToSort" required="true" />
		<cfargument name="SearchID" required="true" />

		<cfset local.aSortArray = "session.searches[" & arguments.SearchID & "].stLowFareDetails." & arguments.StructToSort />
		<cfset local.aPreferredSort = [] />
		<cfset local.sortQuery = QueryNew("nTripKey, total, preferred", "varchar, numeric, bit") />
		<cfset local.newRow = QueryAddRow(local.sortQuery, arrayLen(Evaluate(local.aSortArray))) />
		<cfset local.queryCounter = 1 />

		<cfloop array="#evaluate(local.aSortArray)#" index="local.nTripKey">
			<cfif NOT structKeyExists(session.searches[SearchID].stLowFareDetails.stPriced, local.nTripKey)>
				<cfset local.stTrip = session.searches[SearchID].stTrips[local.nTripKey] />

				<cfset local.temp = querySetCell(local.sortQuery, "nTripKey", local.nTripKey, local.queryCounter) />
				<cfset local.temp = querySetCell(local.sortQuery, "total", local.stTrip.total, local.queryCounter) />
				<cfset local.temp = querySetCell(local.sortQuery, "preferred", local.stTrip.preferred, local.queryCounter) />
				<cfset local.queryCounter++ />
			</cfif>
		</cfloop>
		<cfquery name="local.preferredSort" dbtype="query">
			SELECT nTripKey
			FROM sortQuery
			ORDER BY total ASC, preferred DESC
		</cfquery>

		<cfif local.preferredSort.recordCount>
			<cfset local.aPreferredSort = listToArray(valueList(local.preferredSort.nTripKey)) />
		</cfif>

		<cfreturn local.aPreferredSort />
	</cffunction>

	<cffunction name="calculateTripTime" access="public" output="false" returntype="numeric" hint="I take a group of segments and calculate the total trip time including flight times and layovers">
		<cfargument name="segments" type="struct" required="true" />

		<cfset var keys = structKeyList( arguments.segments ) />
		<cfset var totalTripTime = 0 />

		<cfset var tmpArray = [] />
		<cfloop collection="#arguments.segments#" item="local.segmentId">
			<cfset arrayAppend( tmpArray, arguments.segments[ segmentID ] ) />
		</cfloop>

		<cfset tmpArray = ArrayOfStructSort( tmpArray, "textnocase", "ASC", "DepartureTime") />
		<cfloop from="#arrayLen( tmpArray )#" to="1" step="-1" index="local.i" >
			<cfset totalTripTime = totalTripTime + tmpArray[ i ].FlightTime />

			<cfif i NEQ 1>
				<cfset var layover = abs( dateDiff( "n", tmpArray[ i-1 ].ArrivalTime, tmpArray[ i ].DepartureTime ) ) />
				<cfset totalTripTime = totalTripTime + layover />
			</cfif>
		</cfloop>

		<cfreturn totalTripTime />
	</cffunction>

	<cffunction name="ArrayOfStructSort" returntype="array" access="private">
		<cfargument name="base" type="array" required="yes" />
		<cfargument name="sortType" type="string" required="no" default="text" />
		<cfargument name="sortOrder" type="string" required="no" default="ASC" />
		<cfargument name="pathToSubElement" type="string" required="no" default="" />

		<cfset var tmpStruct = StructNew()>
		<cfset var returnVal = ArrayNew(1)>
		<cfset var i = 0>
		<cfset var keys = "">

		<cfloop from="1" to="#ArrayLen(base)#" index="i">
			<cfset tmpStruct[i] = base[i]>
		</cfloop>

		<cfset keys = StructSort(tmpStruct, sortType, sortOrder, pathToSubElement)>

		<cfloop from="1" to="#ArrayLen(keys)#" index="i">
			<cfset returnVal[i] = tmpStruct[keys[i]]>
		</cfloop>

		<cfreturn returnVal>
	</cffunction>
</cfcomponent>