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

	<cffunction name="fromGMTStringToDateObj" access="public" output="false" returnType="date">
		<cfargument name="date" type="string" required="true">

		<cfset local.formatter = CreateObject("java", "java.text.SimpleDateFormat")>
	  <cfset local.formatter.init("yyyy-MM-dd'T'HH:mm:ssX")>
	  <cfset local.parsePosition = CreateObject("java", "java.text.ParsePosition")>
	  <cfset local.parsePosition.init(0)>
	  <cfset local.result = formatter.parse(arguments.date, parsePosition)>
		<cfreturn local.result>

	</cffunction>

	<cffunction name="finishLowFare" output="false" hint="Do low fare.">
		<cfargument name="SearchID"	required="true">
		<cfargument name="Account"	required="true">
		<cfargument name="Policy"	required="true">

		<cfif NOT structIsEmpty(session.searches[arguments.SearchID].stTrips)>
			<!--- Check low fare. --->
			<cfset session.searches[arguments.SearchID].stTrips = addTotalBagFare(session.searches[arguments.SearchID].stTrips)>

			<!--- Update the results that are available. --->
			<cfset session.searches[arguments.SearchID].stLowFareDetails.stResults = findResults(session.searches[arguments.SearchID].stTrips)>

			<!--- Get list of all carriers returned. --->
			<cfset session.searches[arguments.SearchID].stLowFareDetails.aCarriers = getCarriers(session.searches[arguments.SearchID].stTrips)>

			<!--- Run policy on all the results --->
			<cfset session.searches[arguments.SearchID].stLowFareDetails.aSortFare = StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'Total')>
			<cfset session.searches[arguments.SearchID].stTrips = checkPolicy( session.searches[arguments.SearchID].stTrips
																	, arguments.SearchID
																	, session.searches[arguments.SearchID].stLowFareDetails.aSortFare[1]
																	, 'Fare'
																	, arguments.Account
																	, arguments.Policy)>

			<!--- Create javascript structure per trip. --->
			<cfset session.searches[arguments.SearchID].stTrips = addJavascript(session.searches[arguments.SearchID].stTrips)><!--- Policy needs to be checked prior --->

			<!--- Sort the results --->
			<cfset session.searches[arguments.SearchID].stLowFareDetails.aSortArrival = StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'Arrival')>
			<cfset session.searches[arguments.SearchID].stLowFareDetails.aSortDepart = StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'Depart')>
			<cfset session.searches[arguments.SearchID].stLowFareDetails.aSortDuration = StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'Duration')>

			<!--- price, price + 1 bag, price + 2 bags --->
			<cfset session.searches[arguments.SearchID].stLowFareDetails.aSortFare = StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'Total')>
			<cfset session.searches[arguments.SearchID].stLowFareDetails.aSortBag = StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'TotalBag')>
			<cfset session.searches[arguments.SearchID].stLowFareDetails.aSortBag2 = StructSort(session.searches[arguments.SearchID].stTrips, 'numeric', 'asc', 'TotalBag2')>

			<!--- Prices with preferred carriers taken into account --->
			<cfset session.searches[arguments.SearchID].stLowFareDetails.aSortFarePreferred = sortByPreferred("aSortFare", arguments.SearchID) />
			<cfset session.searches[arguments.SearchID].stLowFareDetails.aSortBagPreferred = sortByPreferred("aSortBag", arguments.SearchID) />
			<cfset session.searches[arguments.SearchID].stLowFareDetails.aSortBag2Preferred = sortByPreferred("aSortBag2", arguments.SearchID) />
		</cfif>

		<cfreturn >
	</cffunction>

	<cffunction name="parseSegments" output="false" hint="I take XML from uAPI and parse segments from it.">
		<cfargument name="stResponse"	required="true" hint="Truncated XML object">
		<cfargument name="attachXML" default="false">

		<cfset local.stSegments = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<!---
			'air:AirSegmentList' - found in low fare and availability search
			'air:AirItinerary' - found in air pricing
			--->
			<cfif local.stAirSegmentList.XMLName EQ 'air:AirSegmentList' OR local.stAirSegmentList.XMLName EQ 'air:AirItinerary'>

				<cfloop array="#local.stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<cfset local.XML = (arguments.attachXML ? local.stAirSegment : "attachXML need to be true to dump XML used to create segments")>
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
							<cftry>
								<cfif structKeyExists(local.key2.xmlAttributes, "TravelTime")>
									<cfset local.travelTime = local.key2.xmlAttributes.travelTime>
								<cfelseif structKeyExists(local.key2.xmlAttributes, "FlightTime")>
									<cfset local.travelTime = local.key2.xmlAttributes.flightTime>
								</cfif>
								<cfcatch type="any">
								</cfcatch>
							</cftry>
						</cfif>
					</cfloop>
					<cfset local.tempKey = getUAPI().hashNumeric(local.stAirSegment.XMLAttributes.Key)>
					<cfset local.stSegments[local.tempKey] = {
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
						Key : local.stAirSegment.XMLAttributes.Key,
						PolledAvailabilityOption : (StructKeyExists(local.stAirSegment.XMLAttributes, 'PolledAvailabilityOption') ? local.stAirSegment.XMLAttributes.PolledAvailabilityOption : ''),
						XML : local.XML}>
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

			<cfif local.aNextResultReference.XMLName EQ 'common_v33_0:NextResultReference'>
				<cfset local.sNextRef = local.aNextResultReference.XMLText>
			</cfif>
		</cfloop>

		<cfreturn local.sNextRef />
	</cffunction>

	<cffunction name="parseTrips" output="false" hint="I take response and segments and parse air availability trip data.">
		<cfargument name="response" required="true">
		<cfargument name="stSegments" required="true">
		<cfargument name="bRefundable" required="false" default="false">
		<cfargument name="bFirstPrice" required="false" default="false">
		<cfargument name="attachXML" default="false">

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
				<cfset local.stopOvers = {}>
				<cfset local.stTrip.XML = (arguments.attachXML ? local.responseNode : "attachXML need to be true to dump XML used to create segments")>

				<cfloop array="#local.responseNode.XMLChildren#" index="local.airPricingSolutionIndex" item="local.airPricingSolution">

					<cfif local.airPricingSolution.XMLName EQ 'air:Journey'>
						<cfloop array="#local.airPricingSolution#" index="local.journeyItem" item="local.journey">
							<cfset local.totalTravelTime = local.airPricingSolution.XMLAttributes.TravelTime />
						</cfloop>
						<!--- TravelTime looks like "P1DT1H46M0S" --->
						<cfset local.totalTravelTime = replaceNoCase(local.totalTravelTime, "P", "") />
						<cfset local.totalTravelTime = replaceNoCase(local.totalTravelTime, "M0S", "") />
						<cfset local.dayhours = left(local.totalTravelTime, 1) * 24 />
						<cfset local.totalTravelTime = removeChars(local.totalTravelTime, 1, 3) />
						<cfset local.hours = listFirst(local.totalTravelTime, "H") />
						<cfset local.minutes = listLast(local.totalTravelTime, "H") />
						<cfset local.totalTravelTime = (((local.dayhours + local.hours) * 60) + local.minutes) />

						<cfloop array="#local.airPricingSolution.XMLChildren#" index="local.journeyItem" item="local.journey">
							<cfif local.journey.XMLName EQ 'air:AirSegmentRef'>
								<cfset local.tempJourneyKey = getUAPI().hashNumeric(local.journey.XMLAttributes.Key)>
								<cfset local.stTrip.Segments[local.tempJourneyKey] = structKeyExists(arguments.stSegments, local.tempJourneyKey) ? structCopy(arguments.stSegments[local.tempJourneyKey]) : {}>

								<cfloop array="#local.distinctFields#" index="local.field">
									<cfset local.tripKey &= local.stTrip.Segments[local.tempJourneyKey][local.field]>
								</cfloop>
							</cfif>
							<cfset local.stTrip.Segments[local.tempJourneyKey].TravelTime = local.totalTravelTime />
						</cfloop>

					<cfelseif local.airPricingSolution.XMLName EQ 'air:AirSegmentRef'>
						<cfset local.tempJourneyKey = getUAPI().hashNumeric(local.airPricingSolution.XMLAttributes.Key)>
						<cfset local.stTrip.Segments[local.tempJourneyKey] = structKeyExists(arguments.stSegments, local.tempJourneyKey) ? structCopy(arguments.stSegments[local.tempJourneyKey]) : {}>
						<cfloop array="#local.distinctFields#" index="local.field">
							<cfset local.tripKey &= local.stTrip.Segments[local.tempJourneyKey][local.field]>
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

							<!--- 9:57 AM Saturday, March 29, 2014 - Jim Priest - jpriest@shortstravel.com
										fareCalc used for travelTech reporting only. Please do not remove.
							<cfelseif airPricingSolution2.XMLName EQ 'air:FareCalc'>
								<cfset local.fareCalc = airPricingSolution2.xmlText>
							--->

							<cfelseif local.airPricingSolution2.XMLName EQ 'air:BookingInfo'>
								<!--- Pricing cabin class --->
								<cfset local.segKey = getUAPI().hashNumeric(local.airPricingSolution2.XMLAttributes.SegmentRef)>

								<cfset local.sClass = (StructKeyExists(local.airPricingSolution2.XMLAttributes, 'CabinClass') ? local.airPricingSolution2.XMLAttributes.CabinClass : 'Economy')>
								<cfset local.stTrip.Segments[local.segKey].Class = local.airPricingSolution2.XMLAttributes.BookingCode>
								<cfset local.stTrip.Segments[local.segKey].Cabin = local.sClass>
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
						<cfset local.stTrip.Key = local.airPricingSolution.XMLAttributes.Key>
						<cfset local.stTrip.Base = Mid(local.airPricingSolution.XMLAttributes.BasePrice, 4)>
						<cfset local.stTrip.ApproximateBase = Mid(local.airPricingSolution.XMLAttributes.ApproximateBasePrice, 4)>
						<cfset local.stTrip.Total = Mid(local.airPricingSolution.XMLAttributes.TotalPrice, 4)>
						<cfset local.stTrip.Taxes = Mid(local.airPricingSolution.XMLAttributes.Taxes, 4)>
						<cfset local.stTrip.PrivateFare = local.bPrivateFare>
						<cfset local.stTrip.PTC = local.sPTC>
						<cfset local.stTrip.Class = local.sOverallClass>
						<cfset local.stTrip.CabinClass = local.sClass>
						<cfset local.refundable = (structKeyExists(airPricingSolution.XMLAttributes, 'Refundable') AND airPricingSolution.XMLAttributes.Refundable EQ 'true' ? 1 : 0)>
						<cfset local.stTrip.Ref = local.refundable>
						<cfset local.stTrip.RequestedRefundable = (arguments.bRefundable IS 'true' ? 1 : local.stTrip.Ref)>
						<cfset local.stTrip.changePenalty = changePenalty>
					</cfif>
				</cfloop>

				<cfset local.sTripKey = getUAPI().hashNumeric( local.tripKey&local.sOverallClass&refundable )>
				<cfif NOT(structKeyExists(local.stTrips,local.sTripKey))>
					<cfset local.stTrips[local.sTripKey] = local.stTrip>
				<cfelse>
					<cfset local.stTrips[local.sTripKey] = local.stTrips[local.sTripKey].Total GT local.stTrip.Total ? local.stTrip : local.stTrips[local.sTripKey]>
				</cfif>
			</cfif>
		</cfloop>

		<cfset local.minFare = StructNew()>
		<cfloop collection = "#local.stTrips#" item="local.sTripKey">
			<cfif NOT(structKeyExists(local.minFare,"minTrip"))>
				<cfset local.minFare.minTrip = local.stTrips[local.sTripKey]>
				<cfset local.minFare.sTripKey = local.sTripKey>
			<cfelse>
				<cfset local.minFare.minTrip = local.stTrips[local.sTripKey].Total LT local.minFare.minTrip.Total ? local.stTrips[local.sTripKey] : local.minFare.minTrip>
				<cfset local.minFare.sTripKey = local.stTrips[local.sTripKey].Total LT local.minFare.minTrip.Total ? local.sTripKey : local.minFare.sTripKey>
			</cfif>
		</cfloop>
		<cfset local.Trip = StructNew()>
		<cfset local.Trip[local.minFare.sTripKey] = local.minFare.minTrip>
		<cfreturn  local.Trip/>

	</cffunction>

	<!--- Below was created because of different results initially being returned with the uAPI version upgrade; keeping in case we have to account for such parsing in the future. --->
	<!--- <cffunction name="parseLowfareTrips" output="false" hint="I take response and segments and parse lowfare trip data.">
		<cfargument name="response" required="true">
		<cfargument name="stSegments" required="true">
		<cfargument name="bRefundable" required="false" default="false">

		<cfset local.stTrips = {}>
		<cfset local.stTrip = {}>
		<cfset local.sTripKey = ''>
		<cfset local.distinctFields = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<cfset local.changePenalty = 0>
		<!---
		Custom code for air pricing to move the 'air:AirPriceResult' up a node to work with the current parsing code.
        --->
		<!--- <cfloop array="#arguments.response#" index="local.stAirPricingSolution">
			<cfif local.stAirPricingSolution.XMLName EQ 'air:AirPriceResult'>
				<cfloop array="#local.stAirPricingSolution.XMLChildren#" index="local.test">
					<cfset ArrayAppend(arguments.response, local.test)>
				</cfloop>
			</cfif>
		</cfloop> --->

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

		<cfloop array="#arguments.response#" index="local.stAirPricePointList" item="local.pricePointList">
			<cfif local.pricePointList.XMLName EQ 'air:AirPricePointList'>
				<cfloop array="#local.pricePointList.XMLChildren#" index="local.stAirPricePoint" item="local.pricePoint">
					<cfset local.bPrivateFare = false>
					<cfloop array="#local.pricePoint.XMLChildren#" index="local.stAirPricingInfo" item="local.pricingInfo">
						<cfset local.sOverallClass = 'E'>
						<cfset local.sPTC = ''>
						<cfset local.refundable = false>
						<cfset local.changePenalty = 0>
<!---
MULTI CARRIER AND PF
GET CHEAPEST OF LOOP. MULTIPLE AirPricingInfo
--->
						<cfloop array="#pricingInfo.XMLChildren#" index="local.pricingInfo2">
							<cfif local.pricingInfo2.XMLName EQ 'air:PassengerType'>
								<!--- Passenger type codes --->
								<cfset local.sPTC = local.pricingInfo2.XMLAttributes.Code>
							<cfelseif local.pricingInfo2.XMLName EQ 'air:FareInfoRef'>
								<!--- Private fares 1/0 --->
								<cfif fare[local.pricingInfo2.XMLAttributes.Key].PrivateFare>
									<cfset local.bPrivateFare = true>
								</cfif>
							<cfelseif local.pricingInfo2.XMLName EQ 'air:FareInfo'>
								<!--- Private fares 1/0 --->
								<cfif structKeyExists(local.pricingInfo2.XMLAttributes, 'PrivateFare')
									AND local.pricingInfo2.XMLAttributes.PrivateFare NEQ ''>
									<cfset local.bPrivateFare = true>
								</cfif>

							<!--- 9:57 AM Saturday, March 29, 2014 - Jim Priest - jpriest@shortstravel.com
										fareCalc used for travelTech reporting only. Please do not remove.
							<cfelseif pricingInfo2.XMLName EQ 'air:FareCalc'>
								<cfset local.fareCalc = pricingInfo2.xmlText>
							--->

							<cfelseif local.pricingInfo2.XMLName EQ 'air:ChangePenalty'>
								<!--- Refundable or non refundable --->
								<cfloop array="#local.pricingInfo2.XMLChildren#" index="local.stFare">
									<cfif local.changePenalty LTE replace(local.stFare.XMLText, 'USD', '')>
										<cfset local.changePenalty = replace(local.stFare.XMLText, 'USD', '')>
									</cfif>
								</cfloop>
							<cfelseif local.pricingInfo2.XMLName EQ 'air:FlightOptionsList'>
								<cfset local.legOptions = [] />
								<cfloop array="#local.pricingInfo2.XMLChildren#" item="local.flightOptionsList" index="local.optionIndex">
									<!--- Each air:FlightOption is a leg and each air:Option within is an option for that leg --->
									<cfset local.legOptions[local.optionIndex] = [] />
									<cfloop array="#local.flightOptionsList.XMLChildren#" item="local.flightOption" index="local.optionIndex2">
										<cfset local.legOptions[local.optionIndex][local.optionIndex2] = {} />
										<cfset local.totalTravelTime = local.flightOption.XMLAttributes.TravelTime />
										<!--- TravelTime looks like "P1DT1H46M0S" --->
										<cfset local.totalTravelTime = replaceNoCase(local.totalTravelTime, "P", "") />
										<cfset local.totalTravelTime = replaceNoCase(local.totalTravelTime, "M0S", "") />
										<cfset local.dayhours = left(local.totalTravelTime, 1) * 24 />
										<cfset local.totalTravelTime = removeChars(local.totalTravelTime, 1, 3) />
										<cfset local.hours = listFirst(local.totalTravelTime, "H") />
										<cfset local.minutes = listLast(local.totalTravelTime, "H") />
										<cfset local.totalTravelTime = (((local.dayhours + local.hours) * 60) + local.minutes) />

										<cfset local.legOptions[local.optionIndex][local.optionIndex2].Segments = [] />
										<cfset local.legOptions[local.optionIndex][local.optionIndex2].OptionKey = local.flightOption.XMLAttributes.Key />
										<cfloop array="#local.flightOption.XMLChildren#" item="local.airOption" index="local.airIndex">
											<cfif local.airOption.XMLName EQ 'air:BookingInfo'>
												<cfset local.legOptions[local.optionIndex][local.optionIndex2].Segments[local.airIndex] = structKeyExists(arguments.stSegments, local.airOption.XMLAttributes.SegmentRef) ? structCopy(arguments.stSegments[local.airOption.XMLAttributes.SegmentRef]) : {}>
												<!--- Pricing cabin class --->
												<cfset local.sClass = (StructKeyExists(local.airOption.XMLAttributes, 'CabinClass') ? local.airOption.XMLAttributes.CabinClass : 'Economy')>
												<cfset local.legOptions[local.optionIndex][local.optionIndex2].Segments[local.airIndex].Class = local.airOption.XMLAttributes.BookingCode />
												<cfset local.legOptions[local.optionIndex][local.optionIndex2].Segments[local.airIndex].Cabin = local.sClass />
												<cfif local.sClass EQ 'First'>
													<cfset local.sOverallClass = 'F'>
												<cfelseif local.sOverallClass NEQ 'F' AND local.sClass EQ 'Business'>
													<cfset local.sOverallClass = 'C'>
												<cfelseif local.sOverallClass NEQ 'F' AND local.sOverallClass NEQ 'C'>
													<cfset local.sOverallClass = 'Y'>
												</cfif>
											</cfif>
										</cfloop>
									</cfloop>
									<cfset local.numLegs = local.optionIndex />
								</cfloop>
							</cfif>
						</cfloop>
					</cfloop>

					<cfset local.stTrip = {} />
					<cfset local.stTrip.Base = Mid(local.pricingInfo.XMLAttributes.BasePrice, 4)>
					<cfset local.stTrip.ApproximateBase = Mid(local.pricingInfo.XMLAttributes.ApproximateBasePrice, 4)>
					<cfset local.stTrip.Total = Mid(local.pricingInfo.XMLAttributes.TotalPrice, 4)>
					<cfset local.stTrip.Taxes = Mid(local.pricingInfo.XMLAttributes.Taxes, 4)>
					<cfset local.stTrip.PrivateFare = local.bPrivateFare>
					<cfset local.stTrip.PTC = local.sPTC>
					<cfset local.stTrip.Class = local.sOverallClass>
					<cfset local.refundable = (structKeyExists(pricingInfo.XMLAttributes, 'Refundable') AND pricingInfo.XMLAttributes.Refundable EQ 'true' ? 1 : 0)>
					<cfset local.stTrip.Ref = local.refundable>
					<cfset local.stTrip.RequestedRefundable = (arguments.bRefundable IS 'true' ? 1 : local.stTrip.Ref)>
					<cfset local.stTrip.changePenalty = changePenalty>
					<cfset local.stTrip.Segments = structNew('linked') />
					<!--- Looping through the first leg of the journey --->
					<cfloop array="#local.legOptions[1]#" item="local.legOption1" index="local.legIndex1">
						<cfset local.optionKey = local.legOption1.OptionKey />
						<cfif structKeyExists(local, "legSegmentKeys1") AND len(local.legSegmentKeys1)>
							<cfloop list="#local.legSegmentKeys1#" index="local.key">
								<cfset structDelete(local.stTrip.Segments, "#local.key#") />
							</cfloop>
						</cfif>
						<cfset local.legSegmentKeys1 = "" />
						<!--- Looping through each of the options for the first leg --->
						<cfloop array="#local.legOption1.Segments#" item="local.segment1" index="local.segmentIndex1">
							<cfset local.segmentKey1 = local.segment1.Key />
							<!--- Get all of the segments for this option --->
							<cfset local.stTrip.Segments[local.segmentKey1] = structCopy(local.segment1) />
							<cfset local.stTrip.Segments[local.segmentKey1].TravelTime = local.totalTravelTime />
							<cfset local.legSegmentKeys1 = listAppend(local.legSegmentKeys1, local.segmentKey1) />
						</cfloop>
						<cfif arrayLen(local.legOptions) GT 1>
							<!--- Looping through the second leg of the journey --->
							<cfloop array="#local.legOptions[2]#" item="local.legOption2" index="local.legIndex2">
								<cfset local.optionKey2 = listAppend(local.optionKey, local.legOption2.OptionKey, ":") />
								<cfif structKeyExists(local, "legSegmentKeys2") AND len(local.legSegmentKeys2)>
									<cfloop list="#local.legSegmentKeys2#" index="local.key">
										<cfset structDelete(local.stTrip.Segments, "#local.key#") />
									</cfloop>
								</cfif>
								<cfset local.legSegmentKeys2 = "" />
								<!--- Looping through each of the options --->
								<cfloop array="#local.legOption2.Segments#" item="local.segment2" index="local.segmentIndex2">
									<cfset local.segmentKey2 = local.segment2.Key />
									<cfset local.stTrip.Segments[local.segmentKey2] = structCopy(local.segment2) />
									<cfset local.stTrip.Segments[local.segmentKey2].TravelTime = local.totalTravelTime />
									<cfset local.legSegmentKeys2 = listAppend(local.legSegmentKeys2, local.segmentKey2) />
								</cfloop>
								<cfset local.sTripKey = getUAPI().hashNumeric(local.optionKey2&local.sOverallClass&refundable)>
							</cfloop>
						<cfelse>
							<cfset local.sTripKey = getUAPI().hashNumeric(local.optionKey&local.sOverallClass&refundable)>
						</cfif>
					</cfloop>
					<cfset local.stTrips[local.sTripKey] = local.stTrip>
				</cfloop>
			</cfif>
		</cfloop>

		<cfreturn local.stTrips />
	</cffunction> --->
	<cffunction name="removeInvalidTrips" output="false" hint="Due to inconsistent uAPI results, this method does sanity check on results">
		<cfargument name="trips" required="true">
		<cfargument name="filter" required="true">
		<cfargument name="tripTypeOverride" default=""/>
		<cfargument name="chosenGroup" default="-1"/>

		<cfset var searchDepart = arguments.filter.getDepartCity()>
		<cfset var searchArrive = arguments.filter.getArrivalCity()>
		<cfset var departDay = DayOfYear(arguments.filter.getDepartDateTime())>
		<cfset var arriveDay = ((arguments.filter.getAirType() NEQ 'OW' AND IsDate(arguments.filter.getArrivalDateTime())) ? DayOfYear(arguments.filter.getArrivalDateTime()) : 0)>
		<cfset var tripsToVerify = arguments.trips>
		<cfset var ctr = 1>
		<cfset var tripType = (len(arguments.tripTypeOverride) ? arguments.tripTypeOverride : arguments.filter.getAirType())>
		<cfloop collection="#tripsToVerify#" item="local.trip">
			<cfif tripType NEQ 'MD'
					  AND StructKeyExists(tripsToVerify,local.trip)
						AND (!verifyTripsWithGroups(tripsToVerify[local.trip],searchDepart,searchArrive,tripType) OR !verifyTripDates(tripsToVerify[local.trip],departDay,arriveDay,arguments.chosenGroup))>
				<cfset StructDelete(tripsToVerify, local.trip)>
			</cfif>
			<cfset ctr++>
		</cfloop>
		<cfreturn tripsToVerify>
	</cffunction>

	<cffunction name="verifyTripsWithGroups" returnType="boolean" output="false" hint="Checks a trip's group for valid segments">
		<cfargument name="trip" required="true">
		<cfargument name="searchDepart" required="true">
		<cfargument name="searchArrive" required="true">
		<cfargument name="tripType" default="RT">

		<cfif StructKeyExists(arguments.trip,'Groups')>
			<cfset var groups = arguments.trip.Groups>
			<cfset var ctr = 0>
			<!---This checks Roundtrip flights have more than one group (required)--->
			<cfif (arguments.tripType EQ 'RT' AND StructCount(groups) LT 2) OR (arguments.tripType EQ 'OW' AND StructCount(groups) NEQ 1)>
				<cfreturn false>
			</cfif>
			<cfloop collection="#groups#" item="group">
				<cfset var g = groups[group]>
				<cfset var gDepart = g.origin>
				<cfset var gArrive = g.destination>
				<!---This checks if the group departs/arrives either on the trip there or the trip back (so depart/arrive are switched)--->
				<cfif group EQ 0 AND
						  (
								!checkMetro(arguments.searchDepart,gDepart) OR (arguments.searchDepart NEQ gDepart AND !isMetroArea(arguments.searchDepart)) OR
								!checkMetro(arguments.searchArrive,gArrive) OR (arguments.searchArrive NEQ gArrive AND !isMetroArea(arguments.searchArrive))
						  ) AND
							(
								!checkMetro(arguments.searchArrive,gDepart) OR (arguments.searchArrive NEQ gDepart AND !isMetroArea(arguments.searchArrive)) OR
								!checkMetro(arguments.searchDepart,gArrive) OR (arguments.searchDepart NEQ gArrive AND !isMetroArea(arguments.searchDepart))
						  )>
					<cfreturn false>

				<cfelseif group EQ 1 AND
						  (
								!checkMetro(arguments.searchArrive,gDepart) OR (arguments.searchArrive NEQ gDepart AND !isMetroArea(arguments.searchArrive)) OR
								!checkMetro(arguments.searchDepart,gArrive) OR (arguments.searchDepart NEQ gArrive AND !isMetroArea(arguments.searchDepart))
						  ) >
					<cfreturn false>
				</cfif>
				<cfset var segments = g.segments>
				<cfset var tempDepart = ''>
				<cfset var tempArrive = ''>
				<cfset var startCtr = 1>
				<cfset var segmentCount = StructCount(segments)>

				<cfif segmentCount GT 1>
					<!---Need to make sure each segment 'makes sense' if there are multiple--->
					<!---Only multiple because single segment groups are derived from the single segment and no need to check against metro again which is exp--->
					<cfloop collection="#segments#" item="segment">
						<cftry>
							<cfset var s = segments[segment]>
							<cfset var sDepart = s.origin>
							<cfset var sArrive = s.destination>
							<cfif startCtr GT 1 AND sDepart NEQ tempArrive> <!---segment other than first doesn't have depart the same as previous arrive--->
								<cfreturn false>
							</cfif>
							<cfset tempDepart = s.origin>
							<cfset tempArrive = s.destination>
						<cfcatch type="any">
							<!---Couldn't find the segment--->
							<cfreturn false>
						</cfcatch>
						</cftry>
						<cfset startCtr++>
					</cfloop>
				</cfif>
			</cfloop>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="verifyTripDates" returnType="boolean" output="false" hint="Checks a trip's group for valid departure/arrival days">
		<cfargument name="trip" required="true">
		<cfargument name="departDay" required="true">
		<cfargument name="arriveDay" required="true">
		<cfargument name="chosenGroup" default="-1">

		<cfif StructKeyExists(arguments.trip,'Groups')>
			<cfset var groups = arguments.trip.Groups>
			<cfset var ctr = 0>
			<cfloop collection="#groups#" item="local.group">
				<cfset groupToCheck = ((chosenGroup GTE 0) ? arguments.chosenGroup : local.group)>
				<cfset var g = groups[group]>
				<cfset var gDepart = DayOfYear(g.departureTime)>
				<!---This checks if the group depart/arrive day is not the same as what is picked (group 0 is depart, group 1 is arrive)--->
				<cfif groupToCheck EQ 0  AND departDay NEQ gDepart>
					<cfreturn false>
				<cfelseif groupToCheck EQ 1 AND arriveDay NEQ gDepart>
					<cfreturn false>
				</cfif>
				<cfreturn true>
			</cfloop>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="getMetroList" returnType="string" output="false" hint="I gather all the metro city pairs STO supports">
		<!---STM-989 has the list--->
		<cfset var metroList = 'DTT,YEA,YMQ,NYC,YTO,WAS,CHI,LON,BUE,SAO,BJS,OSA,SPK,SEL,TYO,BER,BUH,MIL,MOW,PAR,ROM,STO,RIO,HOU,DFW,HAR,MIA'>
		<cfreturn metroList>
	</cffunction>

	<cffunction name="isMetroArea" returnType="boolean" output="false" hint="I check an airport code against metro area list">
		<cfargument name="airport" required="true">
		<cfset var metroList = getMetroList()>
		<cfif ListFind(metroList,arguments.airport)>
				<cfreturn true>
		<cfelse>
				<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="checkMetro" returnType="boolean" output="false" hint="I check against metro list and ensure it is a valid airport">
		<cfargument name="airportOrMetro" required="true">
		<cfargument name="airportToCheck" required="true">

		<cfif isMetroArea(arguments.airportOrMetro)>
				<cfset var airportList = metroAirportList(arguments.airportOrMetro)>
				<cfif ListLen(airportList) LTE 0 OR ListFind(metroAirportList(arguments.airportOrMetro),airportToCheck)>
					<cfreturn true>
				<cfelse>
					<cfreturn false>
				</cfif>
		<cfelse>
			<cfreturn true> <!---NOT A METRO, LET THE OTHER CHECKS HAPPEN--->
		</cfif>
	</cffunction>

	<cffunction name="metroAirportList" returnType="string" output="false" hint="I check an airport code against metro area list">
		<cfargument name="airport" required="true">
		<cfswitch expression="#arguments.airport#">
			<cfcase value="NYC">
				<cfset var returnList = 'JFK,JRA,JRB,LGA,NBP,NES,NWK,NWS,QNY,ZME,ZRP,ZYP'>
			</cfcase>
			<cfcase value="WAS">
				<cfset var returnList = 'BOF,GBO,IAD,MTN,ZBP,ZRZ,ZWU,DCA,BWI'>
			</cfcase>
			<cfcase value="DFW">
				<cfset var returnList = 'ADS,AFW,DAL,DFW,FWH,JDB,RBD'>
			</cfcase>
			<cfcase value="HOU">
				<cfset var returnList = 'DWH,EFD,HOU,IAH,JDX,JGP,JGQ,JWH'>
			</cfcase>
			<cfcase value="HOU">
				<cfset var returnList = 'DWH,EFD,HOU,IAH,JDX,JGP,JGQ,JWH'>
			</cfcase>
			<cfcase value="CHI">
				<cfset var returnList = 'DPA,MDW,ORD,PWK,RFD,ZUK,ZUN,ZWV'>
			</cfcase>
			<cfcase value="HAR">
				<cfset var returnList = 'HAR,MDT'>
			</cfcase>
			<cfcase value="MIA">
				<cfset var returnList = 'PBI,FLL,MIA'>
			</cfcase>
			<cfdefaultcase>
				<cfset var returnList = ''>
			</cfdefaultcase>
		</cfswitch>
		<cfreturn returnList>
	</cffunction>

	<cffunction name="mergeTrips" output="false" hint="I merge passed in trips.">
		<cfargument name="stTrips1" required="true">
		<cfargument name="stTrips2" required="true">

		<cfset local.stCombinedTrips = structCopy(arguments.stTrips1)>

		<cfif IsStruct(local.stCombinedTrips) AND IsStruct(arguments.stTrips2)>
			<cfloop collection="#arguments.stTrips2#" item="local.sTripKey">

				<cfif NOT structKeyExists(local.stCombinedTrips, local.sTripKey) OR
					(structKeyExists(local.stCombinedTrips, local.sTripKey) AND
						((((structKeyExists(arguments.stTrips2[local.sTripKey], 'privateFare') AND arguments.stTrips2[local.sTripKey].privateFare)
							OR (structKeyExists(arguments.stTrips2[local.sTripKey], 'PTC') AND arguments.stTrips2[local.sTripKey].PTC EQ 'GST'))
							AND (structKeyExists(arguments.stTrips2[local.sTripKey], "Total") AND arguments.stTrips2[local.sTripKey].Total LTE local.stCombinedTrips[local.sTripKey].Total))
						OR (structKeyExists(arguments.stTrips2[local.sTripKey], "Total") AND arguments.stTrips2[local.sTripKey].Total LT local.stCombinedTrips[local.sTripKey].Total)))>
				<!--- <cfif ( structKeyExists(local.stCombinedTrips, local.sTripKey)
						AND (structKeyExists(arguments.stTrips2[local.sTripKey], 'privateFare')
							AND arguments.stTrips2[local.sTripKey].privateFare )
						OR (structKeyExists(arguments.stTrips2[local.sTripKey], 'PTC')
							AND arguments.stTrips2[local.sTripKey].PTC EQ 'GST'))
					OR NOT structKeyExists(local.stCombinedTrips, local.sTripKey)> --->
				<!--- <cfif ( structKeyExists(local.stCombinedTrips, local.sTripKey)
					AND structKeyExists(arguments.stTrips2[local.sTripKey], 'privateFare')
					AND arguments.stTrips2[local.sTripKey].privateFare )
					OR NOT structKeyExists(local.stCombinedTrips, local.sTripKey)> --->

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
		<cfargument name="Filter" required="false">

		<cfset local.stGroups = {}>
		<cfset local.aCarriers = {}>
		<cfset local.stTrips = arguments.stTrips>
		<cfset local.stSegment = ''>
		<cfset local.nStops = ''>
		<cfset local.nTotalStops = ''>
		<cfset local.nDuration = ''>
		<cfset local.nOverrideGroup = ''>
		<!--- Loop through all the trips --->
		<cfloop collection="#stTrips#" index="local.tripIndex" item="local.trip">
			<cfset local.stGroups = StructNew('linked')>
			<cfset local.aCarriers = {}>
			<cfset local.nDuration = 0>
			<cfset local.nTotalStops = 0>
			<cfset local.travelTime = ''>
			<cfloop collection="#trip.Segments#" index="local.segmentIndex" item="local.segment">
				<cfif local.segment.Group NEQ local.nOverrideGroup>
					<cfset local.nOverrideGroup = local.segment.Group />
					<cfset local.firstSegment = true />
				<cfelse>
					<cfset local.firstSegment = false />
				</cfif>
				<cfif NOT structKeyExists(local.stGroups, local.nOverrideGroup)>
					<cfset local.stGroups[local.nOverrideGroup].Segments = StructNew('linked')>
					<cfset local.stGroups[local.nOverrideGroup].DepartureTime = local.segment.DepartureTime>
					<cfset local.stGroups[local.nOverrideGroup].Origin = local.segment.Origin>
					<cfset local.nStops = -1>
				</cfif>
				<cfif local.firstSegment OR local.segment.TravelTime GT local.nDuration>
					<cfset local.nDuration = local.nDuration + local.segment.TravelTime />
					<cfset local.travelTime = '#int(local.segment.TravelTime/60)#h #local.segment.TravelTime%60#m' />
				</cfif>
				<cfset local.stGroups[local.nOverrideGroup].Segments[local.segmentIndex] = local.segment>
				<cfset local.stGroups[local.nOverrideGroup].ArrivalTime = local.segment.ArrivalTime>
				<cfset local.stGroups[local.nOverrideGroup].Destination = local.segment.Destination>
				<cfset local.stGroups[local.nOverrideGroup].TravelTime = local.travelTime>
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
				<cftry>
				<cfset local.stTrips[local.tripIndex].Depart = local.stGroups[local.nOverrideGroup].DepartureTime>
				<cfcatch type="any">
						<cfif StructKeyExists(arguments,"Filter")>
							<cfset local.stTrips[local.tripIndex].Depart = arguments.Filter.getDepartDateTime()>
						</cfif>
				</cfcatch>
				</cftry>
			<cfelse>
				<cftry>
				<cfset local.stTrips[local.tripIndex].Depart = local.stGroups[0].DepartureTime>
				<cfcatch type="any">
						<cfif StructKeyExists(arguments,"Filter")>
							<cfset local.stTrips[local.tripIndex].Depart = arguments.Filter.getDepartDateTime()>
						</cfif>
				</cfcatch>
				</cftry>
			</cfif>
			<cftry>
			<cfset local.stTrips[local.tripIndex].Arrival = local.stGroups[local.nOverrideGroup].ArrivalTime>
			<cfcatch type="any">
					<cfif StructKeyExists(arguments,"Filter")>
						<cfset local.stTrips[local.tripIndex].Arrival = arguments.Filter.getArrivalDateTime()>
					</cfif>
			</cfcatch>
			</cftry>
			<cfset local.stTrips[tripIndex].Carriers = structKeyArray(local.aCarriers)>
			<cfset local.stTrips[tripIndex].validCarriers = flagBlackListedCarriers(local.stTrips[tripIndex].Carriers)>
			<cfset local.stTrips[tripIndex].PlatingCarrier = setPlatingCarrier(local.stTrips[tripIndex].Groups)>
			<cfset StructDelete(local.stTrips[local.tripIndex], 'Segments')>
		</cfloop>

		<cfreturn local.stTrips/>
	</cffunction>

	<cffunction name="removeBlackListedCarrierPairings" output="false" hint="I remove trips with blacklisted carrier combinations.">
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

	<cffunction name="removeBlackListedCarriers" output="false" hint="I remove trips with blacklisted carriers.">
		<cfargument name="trips" required="true">
		<cfargument name="blackListedCarriers" required="true">

		<cfset local.trips = arguments.trips>
		<cfset local.deleteTripIndex = "">

		<cfif len(arguments.blackListedCarriers)>
			<!--- Loop through all the trips --->
			<cfloop collection="#local.trips#" index="local.tripIndex" item="local.trip">
				<cfloop array="#local.trip.carriers#" index="local.carrier">
					<cfif listFindNoCase(arguments.blackListedCarriers, local.carrier)>
						<cfset local.deleteTripIndex = listAppend(local.deleteTripIndex, local.tripIndex) />
						<cfbreak>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>

		<!--- delete the blacklisted flights from stTrips --->
		<cfloop list="#local.deleteTripIndex#" item="local.tripIndex">
			<cfif structKeyExists(local.trips, local.tripIndex)>
				<cfset structDelete(local.trips, local.tripIndex)>
			</cfif>
		</cfloop>

		<cfreturn local.trips/>
	</cffunction>

	<cffunction name="removeMultiCarrierPrivateFares" output="false" hint="I remove trips with blacklisted carrier combinations.">
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

	<cffunction name="removeMultiConnections" output="false" hint="I remove trips with blacklisted carrier combinations.">
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
					<cfset arguments.stTrips[local.sTrip].TotalBag = arguments.stTrips[local.sTrip].Total + application.stAirVendors[arguments.stTrips[local.sTrip].Carriers[1]].Bag1>
					<cfset arguments.stTrips[local.sTrip].TotalBag2 = arguments.stTrips[local.sTrip].Total + application.stAirVendors[arguments.stTrips[local.sTrip].Carriers[1]].Bag2>
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
			<cfset local.nLowFare = local.stTrips[arguments.nLowFareTripKey].Total>
		</cfif>

		<!--- check if the flight is out of policy based on advance purchase rules --->
		<!--- this is a one time check because the depart dates are all the same --->
		<cfset local.firstKey = listFirst(structKeyList(local.stTrips))>
		<cfset local.outOfPolicyBasedOnAdvPurchRule = false>
		<cfif arguments.Policy.Policy_AirAdvRule EQ 1 AND !structIsEmpty(stTrips) AND DateDiff('d', Now(), local.stTrips[local.firstKey].Depart) LT arguments.Policy.Policy_AirAdv>
			<cfset local.outOfPolicyBasedOnAdvPurchRule = true>
		</cfif>

		<cfloop collection="#local.stTrips#" item="local.nTripKey">
			<cfset local.stTrip = local.stTrips[local.nTripKey]>
			<cfset local.aPolicy = []>
			<cfset local.bActive = 1>

			<cfif local.outOfPolicyBasedOnAdvPurchRule>
				<cfset arrayAppend(local.aPolicy, "Cannot book flights less than #arguments.Policy.Policy_AirAdv# days in the future")>
			</cfif>

			<cfif arguments.sType EQ 'Fare'>
				<!--- Low fare --->
				<cfset local.policyResults = policyLowFare( Policy = arguments.Policy
															, total = local.stTrip.Total
															, lowestfare = local.nLowFare )>
				<cfif local.policyResults.message NEQ ''>
					<cfset arrayAppend( local.aPolicy, local.policyResults.message )>
					<cfset local.bActive = local.policyResults.active>
				</cfif>
				<!--- Max fare --->
				<cfset local.policyResults = policyMaxFare( Policy = arguments.Policy
															, total = local.stTrip.Total )>
				<cfif local.policyResults.message NEQ ''>
					<cfset arrayAppend( local.aPolicy, local.policyResults.message )>
					<cfset local.bActive = local.policyResults.active>
				</cfif>
				<!--- Non refundable / Refundable --->
				<cfset local.policyResults = policyRefundable( Policy = arguments.Policy
																, refundable = local.stTrip.Ref )>
				<cfif local.policyResults.message NEQ ''>
					<cfset arrayAppend( local.aPolicy, local.policyResults.message )>
					<cfset local.bActive = local.policyResults.active>
				</cfif>
				<!--- UP fares--->
				<cfset local.policyResults = policyUpFares( Policy = arguments.Policy
															, refundable = local.stTrip.Ref
															, class = local.stTrip.Class )>
				<cfif local.policyResults.message NEQ ''>
					<cfset arrayAppend( local.aPolicy, local.policyResults.message )>
					<cfset local.bActive = local.policyResults.active>
				</cfif>
				<!--- Class Check --->
				<cfset local.policyResults = policyClass( Policy = arguments.Policy
															, stTrip= local.stTrip)>
				<cfif local.policyResults.message NEQ ''>
					<cfset arrayAppend( local.aPolicy, local.policyResults.message )>
					<cfset local.bActive = local.policyResults.active>
				</cfif>
			</cfif>

			<!--- Non preferred --->
			<cfset local.policyResults = policyNonPreferred( Policy = arguments.Policy
															, preferred = local.stTrip.Preferred )>
			<cfif local.policyResults.message NEQ ''>
				<cfset arrayAppend( local.aPolicy, local.policyResults.message )>
				<cfset local.bActive = local.policyResults.active>
			</cfif>

			<!--- Non preferred --->
			<cfset local.policyResults = policyBlacklisted( Policy = arguments.Policy
															, carriers = local.stTrip.Carriers
															, blacklisted = local.bBlacklisted )>
			<cfif local.policyResults.message NEQ ''>
				<cfset arrayAppend( local.aPolicy, local.policyResults.message )>
				<cfset local.bActive = local.policyResults.active>
			</cfif>

			<!--- Time --->
			<cfset local.policyResults = policyTime( depart = local.stTrip.Depart )>
			<cfif local.policyResults.message NEQ ''>
				<cfset arrayAppend( local.aPolicy, local.policyResults.message )>
				<cfset local.bActive = local.policyResults.active>
			</cfif>

			<!--- F9 Time --->
			<cfset local.policyResults = policyF9Time( depart = local.stTrip.Depart
													, carriers = local.stTrip.Carriers )>
			<cfif local.policyResults.message NEQ ''>
				<cfset arrayAppend( local.aPolicy, local.policyResults.message )>
				<cfset local.bActive = local.policyResults.active>
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
			<cfif arguments.Policy.Policy_AirAdvRule EQ 1 AND structKeyExists(local.stTrips, local.nTripKey)
				AND DateDiff('d', Now(), local.stTrips[local.nTripKey].Depart) LT arguments.Policy.Policy_AirAdv>
				<cfset local.bAllInactive = 1>
				<cfif arguments.Policy.Policy_AirAdvDisp EQ 1>
					<cfset local.stTrips = {}>
				</cfif>
			</cfif>
		</cfif>

		<cfreturn local.stTrips/>
	</cffunction>

	<cffunction name="policyLowFare" output="false" hint="I check the policy.">
		<cfargument name="Policy" required="true">
		<cfargument name="total" required="true">
		<cfargument name="lowestfare" required="true">

		<cfset local.policy.message = ''>
		<cfset local.policy.active = 1>
		<cfset local.policy.policy = 1>

		<!--- Out of policy if the fare plus the padding is greater than the lowest available fare. --->
		<cfif arguments.Policy.Policy_AirLowRule EQ 1
			AND isNumeric(arguments.Policy.Policy_AirLowPad)
			AND arguments.total GT (arguments.lowestfare + arguments.Policy.Policy_AirLowPad)>
			<cfset local.policy.message = 'Not the lowest fare'>
			<cfset local.policy.policy = 0>
			<cfif arguments.Policy.Policy_AirLowDisp EQ 1>
				<cfset local.policy.active = 0>
			</cfif>
		</cfif>

		<cfreturn local.policy />
	</cffunction>

	<cffunction name="policyMaxFare" output="false" hint="I check the policy.">
		<cfargument name="Policy" required="true">
		<cfargument name="total" required="true">

		<cfset local.policy.message = ''>
		<cfset local.policy.active = 1>
		<cfset local.policy.policy = 1>

		<!--- Out of policy if the total fare is over the maximum allowed fare. --->
		<cfif arguments.Policy.Policy_AirMaxRule EQ 1
			AND isNumeric(arguments.Policy.Policy_AirMaxTotal)
			AND arguments.total GT arguments.Policy.Policy_AirMaxTotal>
			<cfset local.policy.message = 'Fare greater than #DollarFormat(arguments.Policy.Policy_AirMaxTotal)#'>
			<cfset local.policy.policy = 0>
			<cfif arguments.Policy.Policy_AirMaxDisp EQ 1>
				<cfset local.policy.active = 0>
			</cfif>
		</cfif>

		<cfreturn local.policy />
	</cffunction>

	<cffunction name="policyRefundable" output="false" hint="I check the policy.">
		<cfargument name="Policy" required="true">
		<cfargument name="refundable" required="true">

		<cfset local.policy.message = ''>
		<cfset local.policy.active = 1>
		<cfset local.policy.policy = 1>

		<!--- Don't display when non refundable / refundable --->
		<cfif arguments.Policy.Policy_AirRefRule EQ 1
			AND arguments.Policy.Policy_AirNonRefRule EQ 0
			AND arguments.refundable EQ 0>
			<cfset local.policy.message = 'Hide non refundable fares'>
			<cfset local.policy.policy = 0>
			<cfset local.policy.active = 1>
		<cfelseif arguments.Policy.Policy_AirNonRefRule EQ 1
			AND arguments.Policy.Policy_AirRefRule EQ 0
			AND arguments.refundable EQ 1>
			<cfset local.policy.message = 'Hide refundable fares'>
			<cfset local.policy.policy = 0>
			<cfset local.policy.active = 1>
		</cfif>

		<cfreturn local.policy />
	</cffunction>

	<cffunction name="policyUpFares" output="false" hint="I check the policy.">
		<cfargument name="Policy" required="true">
		<cfargument name="refundable" required="true">
		<cfargument name="class" required="true">
		<cfargument name="useUpPolicy" required="false" default="false">
		<cfset local.policy.message = ''>
		<cfset local.policy.active = 1>
		<cfset local.policy.policy = 1>
		<!--- Remove first refundable fares --->
		<cfif arguments.class EQ 'F'
			AND arguments.refundable EQ 1 AND
			((arguments.useUpPolicy AND (!arguments.Policy.Policy_AirRefRule OR !arguments.Policy.Policy_AirFirstClass))
				OR !arguments.useUpPolicy)>
			<cfset local.policy.message = 'Hide UP fares'>
			<cfset local.policy.policy = 0>
			<cfset local.policy.active = 0>
		</cfif>

		<cfreturn local.policy />
	</cffunction>

	<cffunction name="policyNonPreferred" output="false" hint="I check the policy.">
		<cfargument name="Policy" required="true">
		<cfargument name="preferred" required="true">

		<cfset local.policy.message = ''>
		<cfset local.policy.active = 1>
		<cfset local.policy.policy = 1>

		<!--- Out of policy if they cannot book non preferred carriers. --->
		<cfif arguments.Policy.Policy_AirPrefRule EQ 1
			AND arguments.preferred EQ 0>
			<cfset local.policy.message = 'Not a preferred carrier'>
			<cfset local.policy.policy = 0>
			<cfif arguments.Policy.Policy_AirPrefDisp EQ 1>
				<cfset local.policy.active = 0>
			</cfif>
		</cfif>

		<cfreturn local.policy />
	</cffunction>

	<cffunction name="policyBlacklisted" output="false" hint="I check the policy.">
		<cfargument name="Policy" required="true">
		<cfargument name="carriers" required="true">
		<cfargument name="blacklisted" required="true">

		<cfset local.policy.message = ''>
		<cfset local.policy.active = 1>
		<cfset local.policy.policy = 1>

		<!--- Out of policy if the carrier is blacklisted (still shows though). --->
		<cfif arguments.blacklisted>
			<cfloop array="#arguments.carriers#" item="local.sCarrier">
				<cfif arrayFindNoCase(arguments.Account.aNonPolicyAir, local.sCarrier)>
					<cfset local.policy.message = 'Out of policy carrier'>
					<cfset local.policy.policy = 0>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn local.policy />
	</cffunction>

	<cffunction name="policyTime" output="false" hint="I check the policy.">
		<cfargument name="depart" required="true">

		<cfset local.policy.message = ''>
		<cfset local.policy.active = 1>
		<cfset local.policy.policy = 1>

		<!--- Departure time is too close to current time. --->
		<cfif DateDiff('h', Now(), arguments.depart) LTE 2>
			<cfset local.policy.message = 'Departure time is within 2 hours'>
			<cfset local.policy.policy = 0>
			<cfset local.policy.active = 0>
		</cfif>

		<cfreturn local.policy />
	</cffunction>

	<cffunction name="policyF9Time" output="false" hint="I check the policy.">
		<cfargument name="depart" required="true">
		<cfargument name="carriers" required="true">

		<cfset local.policy.message = ''>
		<cfset local.policy.active = 1>
		<cfset local.policy.policy = 1>

		<cfset local.carriers = arrayToList(arguments.carriers)>
		<!--- Departure time is too close to current time. --->
		<cfif dateDiff('h', now(), arguments.depart) LTE 24
			AND local.carriers CONTAINS 'F9'>
			<cfset local.policy.message = 'Frontier departure time is within 24 hours'>
			<cfset local.policy.policy = 0>
			<cfset local.policy.active = 0>
		</cfif>

		<cfreturn local.policy />
	</cffunction>

	<cffunction name="policyClass" output="false" hint="I check the policy.">

		<cfargument name="Policy" type="struct" required="true"/>
		<cfargument name="stTrip" type="struct" required="false" default="#structNew()#"/>
		<cfargument name="class"  type="string" required="false" default=""/>

		<cfset local.policy.message = ""/>
		<cfset local.policy.active = 1/>
		<cfset local.policy.policy = 1/>

		<cfif len(trim(arguments.class))><!--- The legacy class argument passed by FindIt --->
			<cfif arguments.class EQ "F" AND !val(arguments.Policy.Policy_AirFirstClass)>
				<cfset local.policy.message = "Cannot book first class"/>
				<cfset local.policy.policy = 0/>
				<cfset local.policy.active = 0/>
			<cfelseif arguments.class EQ "C" AND !val(arguments.Policy.Policy_AirBusinessClass)>
				<cfset local.policy.message = "Cannot book business class"/>
				<cfset local.policy.policy = 0/>
				<cfset local.policy.active = 0/>
			</cfif>
		<cfelseif structCount(arguments.stTrip)>
			<cfif arguments.stTrip.class EQ "F" AND !val(arguments.Policy.Policy_AirFirstClass)>
				<cfset local.policy.message = "Cannot book first class"/>
				<cfset local.policy.policy = 1/>
				<cfset local.policy.active = 1/>
			<cfelseif arguments.stTrip.class EQ "C" AND !val(arguments.Policy.Policy_AirBusinessClass)>
				<cfset local.policy.message = "Cannot book business class"/>
				<cfset local.policy.policy = 1/>
				<cfset local.policy.active = 1/>
			<cfelseif arguments.stTrip.class EQ "C" AND val(arguments.Policy.Policy_AirBusinessClass) AND val(arguments.Policy.Policy_AirBusinessClass_Hours)>
				<cfset local.tripSegments = arguments.stTrip.groups[listFirst(structKeyList(arguments.stTrip.groups))].segments/>
				<cfset local.fligtTimeMinusLayovers1 = round(calculateTripTime(segments=local.tripSegments,includeLayoverTime=false)/60)/>
				<cfset local.fligtTimeMinusLayovers2 = 0/>
				<!--- Is there a return flight? --->
				<cfif listLen(structKeyList(arguments.stTrip.groups)) gt 1>
					<cfset local.tripSegments = arguments.stTrip.groups[listLast(structKeyList(arguments.stTrip.groups))].segments/>
					<cfset local.fligtTimeMinusLayovers2 = round(calculateTripTime(segments=local.tripSegments,includeLayoverTime=false)/60)/>
				</cfif>
				<!--- Get the greater flight time of the 2 --->
				<cfset local.fligtTimeMinusLayovers = max(local.fligtTimeMinusLayovers1,local.fligtTimeMinusLayovers2)>
				<cfif local.fligtTimeMinusLayovers lt arguments.Policy.Policy_AirBusinessClass_Hours>
					<cfset local.policy.message = "Flight time is less than #local.fligtTimeMinusLayovers# hours"/>
					<cfset local.policy.policy = 1/>
					<cfset local.policy.active = 1/>
				</cfif>
			</cfif>
		</cfif>

		<cfreturn local.policy/>
	</cffunction>

	<cffunction name="sortByPreferred" output="false" hint="I take the price sorts and weight the preferred carriers.">
		<cfargument name="StructToSort" required="true" />
		<cfargument name="SearchID" required="true" />
		<cfscript>
		local.aSortArray = session.searches[arguments.SearchID].stLowFareDetails[arguments.StructToSort];
		local.aPreferredSort = [];
		local.sortQuery = QueryNew("nTripKey, total, preferred", "varchar, numeric, bit");
		local.newRow = QueryAddRow(local.sortQuery, arrayLen(local.aSortArray));
		local.queryCounter = 1;

		loop array="#local.aSortArray#" index="local.nTripKey" {
			if(NOT structKeyExists(session.searches[arguments.SearchID].stLowFareDetails.stPriced, local.nTripKey)) {
				local.stTrip = session.searches[arguments.SearchID].stTrips[local.nTripKey];

				querySetCell(sortQuery, "nTripKey", local.nTripKey, local.queryCounter);
				querySetCell(sortQuery, "total", local.stTrip.total, local.queryCounter);
				querySetCell(sortQuery, "preferred", local.stTrip.preferred, local.queryCounter);
				local.queryCounter++;
			}
		}

		// sort and remove columns
		sortQuery.sort("total,preferred","asc,desc");
		sortQuery.deleteColumn("total");
		sortQuery.deleteColumn("preferred");
		local.preferredSort=sortQuery;
		</cfscript>
		<!--- replaced slow QoQ with code above
		<cfquery name="local.preferredSort" dbtype="query">
			SELECT nTripKey
			FROM sortQuery
			ORDER BY total ASC, preferred DESC
		</cfquery> --->


		<cfif local.preferredSort.recordCount>
			<cfset local.aPreferredSort = listToArray(valueList(local.preferredSort.nTripKey)) />
		</cfif>

		<cfreturn local.aPreferredSort />
	</cffunction>

	<cffunction name="calculateTripTime" access="public" output="false" returntype="numeric" hint="I take a group of segments and calculate the total trip time including flight times and layovers">

		<cfargument name="segments" type="struct" required="true"/>
		<cfargument name="includeLayoverTime" type="boolean" required="false" default="true"/>

		<cfset var keys = structKeyList( arguments.segments ) />
		<cfset var totalTripTime = 0 />

		<cfset var tmpArray = [] />
		<cfloop collection="#arguments.segments#" item="local.segmentId">
			<cfset arrayAppend( tmpArray, arguments.segments[ segmentID ] ) />
		</cfloop>

		<cfset tmpArray = ArrayOfStructSort( tmpArray, "textnocase", "ASC", "DepartureTime") />
		<cfloop from="#arrayLen( tmpArray )#" to="1" step="-1" index="local.i" >
			<cfset totalTripTime = totalTripTime + tmpArray[ i ].FlightTime />
			<cfif arguments.includeLayoverTime>
				<cfif i NEQ 1>
					<cfset var layover = abs( dateDiff( "n", tmpArray[ i-1 ].ArrivalTime, tmpArray[ i ].DepartureTime ) ) />
					<cfset totalTripTime = totalTripTime + layover />
				</cfif>
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
