<cfcomponent output="false" accessors="true">

	<cfproperty name="uAPI" />

	<cffunction name="init" access="public" output="false" returntype="any" hint="I initialize this component" >
		<cfargument name="uAPI" type="any" required="true" />
		<cfset setUAPI( arguments.uAPI ) />
		<cfreturn this />
	</cffunction>

	<cffunction name="finishLowFare" output="false" hint="Do low fare.">
		<cfargument name="SearchID"	required="true">
		<cfargument name="Account"	required="true">
		<cfargument name="Policy"	required="true">

		<!--- Check low fare. --->
		<cfset session.searches[SearchID].stTrips						= addTotalBagFare(session.searches[SearchID].stTrips)>

		<!--- Update the results that are available. --->
		<cfset session.searches[SearchID].stLowFareDetails.stResults 	= findResults(session.searches[arguments.SearchID].stTrips)>

		<!--- Get list of all carriers returned. --->
		<cfset session.searches[SearchID].stLowFareDetails.aCarriers 	= getCarriers(session.searches[arguments.SearchID].stTrips)>

		<!--- Run policy on all the results --->
		<cfset session.searches[SearchID].stLowFareDetails.aSortFare 	= StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'Total')>
		<cfset session.searches[SearchID].stTrips 						= checkPolicy(session.searches[arguments.SearchID].stTrips, arguments.SearchID, session.searches[SearchID].stLowFareDetails.aSortFare[1], 'Fare', arguments.Account, arguments.Policy)>

		<!--- Create javascript structure per trip. --->
		<cfset session.searches[SearchID].stTrips 						= addJavascript(session.searches[SearchID].stTrips)><!--- Policy needs to be checked prior --->

		<!--- Sort the results --->
		<cfset session.searches[SearchID].stLowFareDetails.aSortArrival = StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'Arrival')>
		<cfset session.searches[SearchID].stLowFareDetails.aSortDepart 	= StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'Depart')>
		<cfset session.searches[SearchID].stLowFareDetails.aSortDuration= StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'Duration')>

		<!--- price, price + 1 bag, price + 2 bags --->
		<cfset session.searches[SearchID].stLowFareDetails.aSortFare 	= StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'Total')>
		<cfset session.searches[SearchID].stLowFareDetails.aSortBag 	= StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'TotalBag')>
		<cfset session.searches[SearchID].stLowFareDetails.aSortBag2 	= StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'TotalBag2')>

		<!--- Prices with preferred carriers taken into account --->
		<cfset session.searches[SearchID].stLowFareDetails.aSortFarePreferred 	= sortByPreferred("aSortFare", arguments.SearchID) />
		<cfset session.searches[SearchID].stLowFareDetails.aSortBagPreferred 	= sortByPreferred("aSortBag", arguments.SearchID) />
		<cfset session.searches[SearchID].stLowFareDetails.aSortBag2Preferred 	= sortByPreferred("aSortBag2", arguments.SearchID) />

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
					<cfset local.dArrivalTime = GetToken(dArrivalGMT, 1, '.')>
					<cfset local.dArrivalOffset = GetToken(GetToken(dArrivalGMT, 2, '-'), 1, ':')>

					<!--- this is some ugly nested looping to get flightDetailsRef key so we can pull travelTime from flightDetails --->
					<cfloop array="#local.stAirSegment.xmlChildren#" index="local.jim">
						<cfif StructKeyExists(local.jim.xmlAttributes, "Key")>
							<cfset local.detailKey = local.jim.xmlAttributes.key>
						</cfif>
					</cfloop>
					<cfset local.travelTime = 0>
					<cfloop array="#arguments.stResponse[1].xmlChildren#" index="local.dan">
						<cfif StructKeyExists(local.dan.xmlAttributes, "Key") AND local.dan.xmlAttributes.key EQ local.detailKey>
							<cfset local.travelTime = local.dan.xmlAttributes.travelTime>
						</cfif>
					</cfloop>

					<!--- <cfset local.TravelTime = '#int(local.TravelTime/60)#h #local.TravelTime%60#m'> --->

					<cfset stSegments[local.stAirSegment.XMLAttributes.Key] = {
						ArrivalTime			: ParseDateTime(local.dArrivalTime),
						ArrivalGMT			: ParseDateTime(DateAdd('h', local.dArrivalOffset, local.dArrivalTime)),
						Carrier 			: local.stAirSegment.XMLAttributes.Carrier,
						ChangeOfPlane		: local.stAirSegment.XMLAttributes.ChangeOfPlane EQ 'true',
						DepartureTime		: ParseDateTime(GetToken(local.stAirSegment.XMLAttributes.DepartureTime, 1, '.')),
						DepartureGMT		: dateConvert('local2Utc', local.stAirSegment.XMLAttributes.DepartureTime),
						Destination			: local.stAirSegment.XMLAttributes.Destination,
						Equipment			: (StructKeyExists(local.stAirSegment.XMLAttributes, 'Equipment') ? local.stAirSegment.XMLAttributes.Equipment : ''),
						FlightNumber		: local.stAirSegment.XMLAttributes.FlightNumber,
						FlightTime			: local.stAirSegment.XMLAttributes.FlightTime,
						Group				: local.stAirSegment.XMLAttributes.Group,
						Origin				: local.stAirSegment.XMLAttributes.Origin,
						TravelTime			: local.travelTime
					}>
				</cfloop>

			</cfif>
		</cfloop>

		<cfreturn stSegments />
	</cffunction>

	<cffunction name="parseSearchID" output="false" hint="I get the search ID from uAPI response.">
		<cfargument name="sResponse"	required="true">

		<cfset local.stResponse = XMLParse(arguments.sResponse)>
		<cfset local.sLowFareSearchID = ''>

		<cfset stResponse = stResponse.XMLRoot.XMLChildren[1].XMLChildren[1].XMLAttributes>
		<cfif structKeyExists(stResponse, "sLowFareSearchID")>
			<cfset sLowFareSearchID = stResponse.SearchID>
		</cfif>

		<cfreturn sLowFareSearchID />
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

			<cfif aNextResultReference.XMLName EQ 'common_v19_0:NextResultReference'>
				<cfset sNextRef = aNextResultReference.XMLText>
			</cfif>
		</cfloop>

		<cfreturn sNextRef />
	</cffunction>

	<cffunction name="parseTrips" output="false" hint="I take response and segments and parse trip data.">
		<cfargument name="response" required="true">
		<cfargument name="stSegments" required="true">

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
			<cfif stAirPricingSolution.XMLName EQ 'air:AirPriceResult'>
				<cfloop array="#stAirPricingSolution.XMLChildren#" index="local.test">
					<cfset ArrayAppend(arguments.response, test)>
				</cfloop>
			</cfif>
		</cfloop>

		<!---
		Create a quick struct containing the private fare information
		--->
		<cfset local.fare = {}>
		<cfloop array="#arguments.response#" index="local.fareInfoListIndex" item="local.fareInfoList">
			<cfif fareInfoList.XMLName EQ 'air:FareInfoList'>
				<cfloop array="#fareInfoList.XMLChildren#" index="local.fareInfoIndex" item="local.fareInfo">
					<cfset fare[fareInfo.XMLAttributes.Key].PrivateFare = (StructKeyExists(fareInfo.XMLAttributes, 'PrivateFare') AND fareInfo.XMLAttributes.PrivateFare NEQ '' ? true : false)>
				</cfloop>
			</cfif>
		</cfloop>

		<cfloop array="#arguments.response#" index="local.stAirPricingSolution" item="local.responseNode">

			<cfif responseNode.XMLName EQ 'air:AirPricingSolution'>

				<cfset local.stTrip = {}>
				<cfset stTrip.Segments = StructNew('linked')>

				<cfset nCount = 0>
				<cfset nDuration = 0>
				<cfset local.bPrivateFare = false>
				<cfset local.tripKey = ''>

				<cfloop array="#responseNode.XMLChildren#" index="local.airPricingSolutionIndex" item="local.airPricingSolution">

					<cfif airPricingSolution.XMLName EQ 'air:Journey'>

						<cfloop array="#airPricingSolution.XMLChildren#" index="local.journeyItem" item="local.journey">
							<cfif journey.XMLName EQ 'air:AirSegmentRef'>
								<cfset stTrip.Segments[journey.XMLAttributes.Key] = structKeyExists(arguments.stSegments, journey.XMLAttributes.Key) ? arguments.stSegments[journey.XMLAttributes.Key] : {}>

								<cfloop array="#distinctFields#" index="local.field">
									<cfset tripKey &= stTrip.Segments[journey.XMLAttributes.Key][field]>
								</cfloop>

							</cfif>
						</cfloop>

					<cfelseif airPricingSolution.XMLName EQ 'air:AirSegmentRef'>

						<cfset stTrip.Segments[airPricingSolution.XMLAttributes.Key] = structKeyExists(arguments.stSegments, airPricingSolution.XMLAttributes.Key) ? arguments.stSegments[airPricingSolution.XMLAttributes.Key] : {}>

						<cfloop array="#distinctFields#" index="local.field">
							<cfset tripKey &= stTrip.Segments[airPricingSolution.XMLAttributes.Key][field]>
						</cfloop>

					<cfelseif airPricingSolution.XMLName EQ 'air:AirPricingInfo'>

						<cfset local.sOverallClass = 'E'>
						<cfset local.sPTC = ''>
						<cfset local.nCount = 0>
						<cfset fareRuleKey = []>
						<cfset local.bRefundable = 1>
<!---
MULTI CARRIER AND PF
GET CHEAPEST OF LOOP. MULTIPLE AirPricingInfo
--->
						<cfloop array="#airPricingSolution.XMLChildren#" index="local.airPricingSolution2">
							<cfdump var="#airPricingSolution2.XMLName#" />
							<cfif airPricingSolution2.XMLName EQ 'air:PassengerType'>
								<!--- Passenger type codes --->
								<cfset sPTC = airPricingSolution2.XMLAttributes.Code>
							<cfelseif airPricingSolution2.XMLName EQ 'air:FareInfoRef'>
								<!--- Private fares 1/0 --->
								<cfif fare[airPricingSolution2.XMLAttributes.Key].PrivateFare>
									<cfset bPrivateFare = true>
								</cfif>
								<!--- <cfset arrayAppend(fareRuleKey, fare[airPricingSolution2.XMLAttributes.Key].fareRuleKey)> --->
							<cfelseif airPricingSolution2.XMLName EQ 'air:FareInfo'>
								<!--- Private fares 1/0 --->
								<cfif structKeyExists(airPricingSolution2.XMLAttributes, 'PrivateFare')
									AND airPricingSolution2.XMLAttributes.PrivateFare NEQ ''>
									<cfset bPrivateFare = true>
								</cfif>
								<!--- <cfset arrayAppend(fareRuleKey, fare[airPricingSolution2.XMLAttributes.Key].fareRuleKey)> --->
							<cfelseif airPricingSolution2.XMLName EQ 'air:BookingInfo'>
								<!--- Pricing cabin class --->
								<cfset local.sClass = (StructKeyExists(airPricingSolution2.XMLAttributes, 'CabinClass') ? airPricingSolution2.XMLAttributes.CabinClass : 'Economy')>
								<cfset stTrip.Segments[airPricingSolution2.XMLAttributes.SegmentRef].Class = airPricingSolution2.XMLAttributes.BookingCode>
								<cfset stTrip.Segments[airPricingSolution2.XMLAttributes.SegmentRef].Cabin = local.sClass>
								<cfif sClass EQ 'First'>
									<cfset sOverallClass = 'F'>
								<cfelseif sOverallClass NEQ 'F' AND sClass EQ 'Business'>
									<cfset sOverallClass = 'C'>
								<cfelseif sOverallClass NEQ 'F' AND sOverallClass NEQ 'C'>
									<cfset sOverallClass = 'Y'>
								</cfif>
							<cfelseif airPricingSolution2.XMLName EQ 'air:ChangePenalty'>
								<!--- Refundable or non refundable --->
								<cfset changePenalty = 0>
								<cfloop array="#airPricingSolution2.XMLChildren#" index="local.stFare">
									<cfif changePenalty LTE replace(stFare.XMLText, 'USD', '')>
										<cfset changePenalty = replace(stFare.XMLText, 'USD', '')>
									</cfif>
									<cfset bRefundable = (bRefundable EQ 1 AND replace(stFare.XMLText, 'USD', '') GT 0 ? 0 : 1)>
								</cfloop>
							</cfif>
						</cfloop>
						<cfset stTrip.Base = Mid(airPricingSolution.XMLAttributes.BasePrice, 4)>
						<cfset stTrip.Total = Mid(airPricingSolution.XMLAttributes.TotalPrice, 4)>
						<cfset stTrip.Taxes = Mid(airPricingSolution.XMLAttributes.Taxes, 4)>
						<cfset stTrip.PrivateFare = bPrivateFare>
						<cfset stTrip.PTC = sPTC>
						<cfset stTrip.Class = sOverallClass>
						<cfset stTrip.Ref = bRefundable>
						<!--- <cfset stTrip.fareRuleKey = fareRuleKey> --->
						<cfset stTrip.changePenalty = changePenalty>
						<!--- <cfdump var="#stTrip#" abort="true" /> --->
					</cfif>
				</cfloop>
				<cfset sTripKey = getUAPI().hashNumeric( tripKey&sOverallClass&bRefundable )>
				<cfset stTrips[sTripKey] = stTrip>
			</cfif>
		</cfloop>

		<cfreturn  stTrips/>
	</cffunction>

	<cffunction name="mergeSegments" output="false" hint="I merge passed in segments.">
		<cfargument name="stSegments1" 	required="true">
		<cfargument name="stSegments2" 	required="true">

		<cfset local.stSegments = arguments.stSegments1>
		<cfif IsStruct(stSegments) AND IsStruct(arguments.stSegments2)>
			<cfloop collection="#arguments.stSegments2#" item="local.sSegmentKey">
				<cfif NOT StructKeyExists(stSegments, sSegmentKey)>
					<cfset stSegments[sSegmentKey] = arguments.stSegments2[sSegmentKey]>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset stSegments = arguments.stSegments2>
		</cfif>
		<cfif NOT IsStruct(stSegments)>
			<cfset stSegments = {}>
		</cfif>

		<cfreturn stSegments/>
	</cffunction>

	<cffunction name="mergeTrips" output="false" hint="I merge passed in trips.">
		<cfargument name="stTrips1" 	required="true">
		<cfargument name="stTrips2" 	required="true">

		<cfset local.stCombinedTrips = arguments.stTrips1>
		<cfif IsStruct(stCombinedTrips) AND IsStruct(arguments.stTrips2)>
			<cfloop collection="#arguments.stTrips2#" item="local.sTripKey">
				<cfif StructKeyExists(stCombinedTrips, sTripKey)>
					<cfloop collection="#arguments.stTrips2[sTripKey]#" item="local.sFareKey">
						<cfset stCombinedTrips[sTripKey][sFareKey] = arguments.stTrips2[sTripKey][sFareKey]>
					</cfloop>
				<cfelse>
					<cfset stCombinedTrips[sTripKey] = arguments.stTrips2[sTripKey]>
				</cfif>
			</cfloop>
		<cfelseif IsStruct(arguments.stTrips2)>
			<cfset stCombinedTrips = arguments.stTrips2>
		</cfif>
		<cfif NOT IsStruct(stCombinedTrips)>
			<cfset stCombinedTrips = {}>
		</cfif>

		<cfreturn stCombinedTrips/>
	</cffunction>

	<cffunction name="addPreferred" output="false" hint="I set preferred flag.">
		<cfargument name="stTrips"  required="true">
		<cfargument name="Account"	required="false">

		<cfset local.stTrips = arguments.stTrips>
		<cfloop collection="#stTrips#" item="local.sTripKey">
			<cfset stTrips[sTripKey].Preferred = 0>
			<cfloop array="#arguments.stTrips[sTripKey].Carriers#" index="local.sCarrier">
				<cfif ArrayFindNoCase(arguments.Account.aPreferredAir, sCarrier)>
					<cfset stTrips[sTripKey].Preferred = 1>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn stTrips/>
	</cffunction>

	<cffunction name="addGroups" output="false" hint="I add groups.">
		<cfargument name="stTrips" 	required="true">
		<cfargument name="sType" 	required="false"	default="Fare">

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
			<cfset stGroups = StructNew('linked')>
			<cfset aCarriers = {}>
			<cfset nDuration = 0>
			<cfset nTotalStops = 0>
			<cfloop collection="#trip.Segments#" index="local.segmentIndex" item="local.segment">
				<cfset nOverrideGroup = segment.Group>
				<cfset segment.Group = nOverrideGroup>
				<cfif NOT structKeyExists(stGroups, nOverrideGroup)>
					<cfset stGroups[nOverrideGroup].Segments = StructNew('linked')>
					<cfset stGroups[nOverrideGroup].DepartureTime = segment.DepartureTime>
					<cfset stGroups[nOverrideGroup].Origin = segment.Origin>
					<cfset stGroups[nOverrideGroup].TravelTime = '#int(segment.TravelTime/60)#h #segment.TravelTime%60#m'>
					<cfset nDuration = segment.TravelTime + nDuration>
					<cfset nStops = -1>
				</cfif>
				<cfset stGroups[nOverrideGroup].Segments[segmentIndex] = segment>
				<cfset stGroups[nOverrideGroup].ArrivalTime = segment.ArrivalTime>
				<cfset stGroups[nOverrideGroup].Destination = segment.Destination>
				<cfset local.aCarriers[segment.Carrier] = ''>
				<cfset nStops++>
				<cfset stGroups[nOverrideGroup].Stops = nStops>
				<cfif nStops GT nTotalStops>
					<cfset nTotalStops = nStops>
				</cfif>
			</cfloop>
			<cfset stTrips[tripIndex].Groups = stGroups>
			<cfset stTrips[tripIndex].Duration = nDuration>
			<cfset stTrips[tripIndex].Stops = nTotalStops>
			<cfif arguments.sType EQ 'Avail'>
				<cfset stTrips[tripIndex].Depart = stGroups[nOverrideGroup].DepartureTime>
			<cfelse>
				<cfset stTrips[tripIndex].Depart = stGroups[0].DepartureTime>
			</cfif>
			<cfset stTrips[tripIndex].Arrival = stGroups[nOverrideGroup].ArrivalTime>
			<cfset stTrips[tripIndex].Carriers = structKeyArray(aCarriers)>
			<cfset stTrips[tripIndex].validCarriers = flagBlackListedCarriers(stTrips[tripIndex].Carriers)>
			<cfset StructDelete(stTrips[tripIndex], 'Segments')>
		</cfloop>

		<cfreturn stTrips/>
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
				<cfset deleteTripIndex = ListAppend(local.deleteTripIndex, local.tripIndex)>
			<!--- if carriers array only has one carrier - we don't need to check it --->
			<cfelseif arrayLen(local.trip.carriers) GT 1>
				<cfset local.carrierList = ArrayToList(local.trip.carriers)>

				<cfloop array="#arguments.blackListedCarriers#" index="local.blackListedIndex" item="local.blackListedCarrier">
					<cfset local.blackList = ArrayToList(local.blackListedCarrier)>

					<cfif listFindNoCase( local.carrierList, listGetAt( local.blackList, 1) )
						AND listFindNoCase( local.carrierList, listGetAt( local.blackList, 2) )>

						<!--- <cfoutput>#local.tripIndex#)  #local.blackList# | #local.carrierList#<br></cfoutput> --->

						<!--- if any match is found we can stop checking and go to next flight --->
						<cfset local.deleteTripIndex = ListAppend(local.deleteTripIndex, local.tripIndex)>
						<cfbreak>
					</cfif>
				</cfloop>
			</cfif>
			<!---
			<cfoutput>#local.tripIndex# - #local.deleteFlight#<hr></cfoutput><br>
			--->
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

			<cfif arrayLen(trip.carriers) GT 1
				AND trip.privateFare>
				<cfset deleteTripIndex = ListAppend(deleteTripIndex, tripIndex)>
			</cfif>

		</cfloop>

		<cfloop list="#deleteTripIndex#" item="local.tripIndex">
			<cfset StructDelete(arguments.trips, tripIndex)>
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
				<cfset segmentCount = arrayLen(structKeyArray(group.segments))>
				<cfset tempTwoSegments = (segmentCount EQ 2 ? true : tempTwoSegments)>
				<cfset tempThreeSegments = (segmentCount EQ 3 ? true : tempThreeSegments)>
				<cfset tempFourSegments = (segmentCount EQ 4 ? true : tempFourSegments)>
			</cfloop>
			<cfif tempTwoSegments>
				<cfset arrayAppend(tripsTwo, tripIndex)>
				<cfset twoSegments = true>
			<cfelseif tempThreeSegments>
				<cfset arrayAppend(tripsThree, tripIndex)>
				<cfset threeSegments = true>
			<cfelseif tempFourSegments>
				<cfset arrayAppend(tripsFour, tripIndex)>
				<cfset fourSegments = true>
			</cfif>
		</cfloop>
		<cfif threeSegments
			AND twoSegments>
			<cfset trashSegmentCount = 'tripsThree,tripsFour'>
		<cfelseif fourSegments
			AND threeSegments>
			<cfset trashSegmentCount = 'tripsFour'>
		</cfif>
		<cfif trashSegmentCount NEQ ''>
			<cfloop list="#trashSegmentCount#" index="local.arrayIndex" item="local.arrayName">
				<cfloop array="#local[arrayName]#" index="local.tripIndex" item="local.tripKey">
					<cfset structDelete(arguments.trips, tripKey)>
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
			<cfset validFlight = false>
		<cfelseif arrayLen(arguments.carriers) GT 1>
			<cfset validFlight = true>
			<cfloop array="#arguments.carriers#" index="local.carrierIndex" item="local.carrier">
				<cfif structKeyExists(application.blacklistedCarriers, local.carrier)>
					<cfloop array="#arguments.carriers#" index="local.carrier2Index" item="local.carrier2">
						<cfif carrier NEQ carrier2>
							<cfif structKeyExists(application.blacklistedCarriers[carrier], carrier2)>
								<cfset validFlight = false>
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn local.validFlight/>
	</cffunction>

	<cffunction name="addTotalBagFare" output="false" hint="Set Price + 1 bag and Price + 2 bags.">
		<cfargument name="stTrips" 	required="true">
		<cfloop collection="#arguments.stTrips#" item="local.sTrip">
			<cfif NOT StructKeyExists(stTrips[sTrip], 'TotalBag')>
				<cfset stTrips[sTrip].TotalBag = stTrips[sTrip].Total + application.stAirVendors[stTrips[sTrip].Carriers[1]].Bag1>
			</cfif>
			<cfif NOT StructKeyExists(stTrips[sTrip], 'TotalBag2')>
				<cfset stTrips[sTrip].TotalBag2 = stTrips[sTrip].Total + application.stAirVendors[stTrips[sTrip].Carriers[1]].Bag2>
			</cfif>
		</cfloop>
		<cfreturn stTrips/>
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
			<cfset local.sClass = arguments.stTrips[nTripKey].Class>
			<cfset local.bRef = arguments.stTrips[nTripKey].Ref>

			<cfif NOT structKeyExists(stResults, local.sClass)>
				<cfset stResults[local.sClass] = 0>
			</cfif>
			<cfif NOT structKeyExists(stResults, local.bRef)>
				<cfset stResults[local.bRef] = 0>
			</cfif>

			<cfset stResults[local.sClass] = stResults[local.sClass] + 1>
			<cfset stResults[local.bRef] = stResults[local.bRef] + 1>
		</cfloop>

		<cfreturn local.stResults/>
	</cffunction>

	<cffunction name="addJavascript" output="false" hint="I build javascript for trip info to be used in views">
		<cfargument name="stTrips" 	required="true">
		<cfargument name="sType" 	required="false"	default="Fare">

		<cfif arguments.sType EQ 'Fare'>
			<cfset local.aAllCabins = ['Y','C','F']>
			<cfset local.aRefundable = [0,1]>
		</cfif>
		<!--- Loop through all the trips --->
		<cfloop collection="#arguments.stTrips#" item="local.sTrip">
			<cfset sCarriers = '"#Replace(ArrayToList(arguments.stTrips[sTrip].Carriers), ',', '","', 'ALL')#"'>
			<cfset stTrips[sTrip].sJavascript = addJavascriptPerTrip(sTrip, arguments.stTrips[sTrip], arguments.stTrips[sTrip].Class, arguments.stTrips[sTrip].Ref, sCarriers)>
			<cfset stTrips[sTrip].nTripKey = sTrip>
		</cfloop>

		<cfreturn stTrips/>
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
			<cfset local.nLowFare = stTrips[arguments.nLowFareTripKey].Total+arguments.Policy.Policy_AirLowPad>
		</cfif>

		<cfloop collection="#stTrips#" item="local.nTripKey">
			<cfset stTrip = stTrips[nTripKey]>
			<cfset aPolicy = []>
			<cfset bActive = 1>

			<cfif arguments.sType EQ 'Fare'>
				<!--- Out of policy if the fare plus the padding is greater than the lowest available fare. --->
				<cfif arguments.Policy.Policy_AirLowRule EQ 1
				AND IsNumeric(arguments.Policy.Policy_AirLowPad)
				AND stTrip.Total GT nLowFare>
					<cfset ArrayAppend(aPolicy, 'Not the lowest fare')>
					<cfif arguments.Policy.Policy_AirLowDisp EQ 1>
						<cfset bActive = 0>
					</cfif>
				</cfif>
				<!--- Out of policy if the total fare is over the maximum allowed fare. --->
				<cfif arguments.Policy.Policy_AirMaxRule EQ 1
				AND IsNumeric(arguments.Policy.Policy_AirMaxTotal)
				AND stTrip.Total GT arguments.Policy.Policy_AirMaxTotal>
					<cfset ArrayAppend(aPolicy, 'Fare greater than #DollarFormat(arguments.Policy.Policy_AirMaxTotal)#')>
					<cfif arguments.Policy.Policy_AirMaxDisp EQ 1>
						<cfset bActive = 0>
					</cfif>
				</cfif>
				<!--- Don't display when non refundable --->
				<cfif arguments.Policy.Policy_AirRefRule EQ 1
				AND arguments.Policy.Policy_AirRefDisp EQ 1
				AND stTrip.Ref EQ 0>
					<cfset ArrayAppend(aPolicy, 'Hide non refundable fares')>
					<cfset bActive = 0>
				</cfif>
				<!--- Don't display when refundable --->
				<cfif arguments.Policy.Policy_AirNonRefRule EQ 1
				AND arguments.Policy.Policy_AirNonRefDisp EQ 1
				AND stTrip.Ref EQ 1>
					<cfset ArrayAppend(aPolicy, 'Hide refundable fares')>
					<cfset bActive = 0>
				</cfif>
				<!--- Remove first refundable fares --->
				<cfif stTrip.Class EQ 'F'
				AND stTrip.Ref EQ 1>
					<cfset ArrayAppend(aPolicy, 'Hide UP fares')>
					<cfset bActive = 0>
				</cfif>
			</cfif>
			<!--- Out of policy if they cannot book non preferred carriers. --->
			<cfif arguments.Policy.Policy_AirPrefRule EQ 1
			AND stTrip.Preferred EQ 0>
				<cfset ArrayAppend(aPolicy, 'Not a preferred carrier')>
				<cfif arguments.Policy.Policy_AirPrefDisp EQ 1>
					<cfset bActive = 0>
				</cfif>
			</cfif>
			<!--- Out of policy if the carrier is blacklisted (still shows though). --->
			<cfif bBlacklisted>
				<cfloop array="#stTrip.Carriers#" item="local.sCarrier">
					<cfif ArrayFindNoCase(arguments.Account.aNonPolicyAir, sCarrier)>
						<cfset ArrayAppend(aPolicy, 'Out of policy carrier')>
					</cfif>
				</cfloop>
			</cfif>
			<!--- Departure time is too close to current time. --->
			<cfif DateDiff('h', Now(), stTrip.Depart) LTE 2>
				<cfset ArrayAppend(aPolicy, 'Departure time is within 2 hours')>
				<cfset bActive = 0>
			</cfif>
			<cfif bActive EQ 1>
				<cfset stTrips[nTripKey].Policy = (ArrayIsEmpty(aPolicy) ? 1 : 0)>
				<cfset stTrips[nTripKey].aPolicies = aPolicy>
			<cfelse>
				<cfset temp = StructDelete(stTrips, nTripKey)>
			</cfif>
		</cfloop>

		<cfset local.bAllInactive = 0>
		<!--- Out of policy if the depart date is less than the advance purchase requirement. --->
		<cfif arguments.Policy.Policy_AirAdvRule EQ 1
		AND DateDiff('d', stTrips[nTripKey].Depart_DateTime, Now()) GT arguments.Policy.Policy_AirAdv>
			<cfset bAllInactive = 1>
			<cfif arguments.Policy.Policy_AirAdvDisp EQ 1>
				<cfset stTrips = {}>
			</cfif>
		</cfif>

		<cfreturn stTrips/>
	</cffunction>

	<cffunction name="sortByPreferred" output="false" hint="I take the price sorts and weight the preferred carriers.">
		<cfargument name="StructToSort" required="true" />
		<cfargument name="SearchID" required="true" />

		<cfset local.aSortArray = "session.searches[" & arguments.SearchID & "].stLowFareDetails." & arguments.StructToSort />
		<cfset local.aPreferredSort = [] />
		<cfset local.sortQuery = QueryNew("nTripKey, total, preferred", "varchar, numeric, bit") />
		<cfset local.newRow = QueryAddRow(sortQuery, arrayLen(Evaluate(aSortArray))) />
		<cfset local.queryCounter = 1 />

		<cfloop array="#evaluate(aSortArray)#" index="local.nTripKey">
			<cfif NOT structKeyExists(session.searches[SearchID].stLowFareDetails.stPriced, nTripKey)>
				<cfset local.stTrip = session.searches[SearchID].stTrips[nTripKey] />

				<cfset temp = querySetCell(sortQuery, "nTripKey", nTripKey, queryCounter) />
				<cfset temp = querySetCell(sortQuery, "total", stTrip.total, queryCounter) />
				<cfset temp = querySetCell(sortQuery, "preferred", stTrip.preferred, queryCounter) />
				<cfset queryCounter++ />
			</cfif>
		</cfloop>
		<cfquery name="local.preferredSort" dbtype="query">
			SELECT nTripKey
			FROM sortQuery
			ORDER BY total ASC, preferred DESC
		</cfquery>

		<cfif preferredSort.recordCount>
			<cfset aPreferredSort = listToArray(valueList(preferredSort.nTripKey)) />
		</cfif>

		<cfreturn aPreferredSort />
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