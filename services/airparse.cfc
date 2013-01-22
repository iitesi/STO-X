<cfcomponent output="false">
	
<!---
init
--->
	<cffunction name="init" output="false">
		<cfreturn this>
	</cffunction>
	
<!---
doLowFare
--->
	<cffunction name="finishLowFare" output="false">
		<cfargument name="nSearchID"	required="true">
		
		<!--- Check low fare. --->
		<cfset session.searches[nSearchID].stTrips							= addTotalBagFare(session.searches[nSearchID].stTrips)>
		<!--- Update the results that are available. --->
		<cfset session.searches[nSearchID].stLowFareDetails.stResults 		= findResults(session.searches[arguments.nSearchID].stTrips)>
		<!--- Get list of all carriers returned. --->
		<cfset session.searches[nSearchID].stLowFareDetails.aCarriers 		= getCarriers(session.searches[arguments.nSearchID].stTrips)>
		<!--- Run policy on all the results --->
		<cfset session.searches[nSearchID].stLowFareDetails.aSortFare 		= StructSort(session.searches[arguments.nSearchID].stTrips, 'numeric', 'asc', 'Total')>
		<cfset session.searches[nSearchID].stTrips 							= checkPolicy(session.searches[arguments.nSearchID].stTrips, arguments.nSearchID, session.searches[nSearchID].stLowFareDetails.aSortFare[1])>
		<!--- Create javascript structure per trip. --->
		<cfset session.searches[nSearchID].stTrips 							= addJavascript(session.searches[nSearchID].stTrips)><!--- Policy needs to be checked prior --->
		<!--- Sort the results in different mannors. --->
		<cfset session.searches[nSearchID].stLowFareDetails.aSortFare 		= StructSort(session.searches[arguments.nSearchID].stTrips, 'numeric', 'asc', 'Total')>
		<cfset session.searches[nSearchID].stLowFareDetails.aSortDepart 	= StructSort(session.searches[arguments.nSearchID].stTrips, 'numeric', 'asc', 'Depart')>
		<cfset session.searches[nSearchID].stLowFareDetails.aSortArrival 	= StructSort(session.searches[arguments.nSearchID].stTrips, 'numeric', 'asc', 'Arrival')>
		<cfset session.searches[nSearchID].stLowFareDetails.aSortDuration 	= StructSort(session.searches[arguments.nSearchID].stTrips, 'numeric', 'asc', 'Duration')>
		<cfset session.searches[nSearchID].stLowFareDetails.aSortBag 		= StructSort(session.searches[arguments.nSearchID].stTrips, 'numeric', 'asc', 'TotalBag')>
		
		<cfreturn >
	</cffunction>

<!---
parseSegments
--->
	<cffunction name="parseSegments" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stSegments = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<!---
			'air:AirSegmentList' - found in low fare and availability search
			'air:AirItinerary' - found in air pricing
			--->
			<cfif stAirSegmentList.XMLName EQ 'air:AirSegmentList'
			OR stAirSegmentList.XMLName EQ 'air:AirItinerary'>
				<cfloop array="#stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<cfset local.dArrivalGMT = stAirSegment.XMLAttributes.ArrivalTime>
					<cfset local.dArrivalTime = GetToken(dArrivalGMT, 1, '.')>
					<cfset local.dArrivalOffset = GetToken(GetToken(dArrivalGMT, 2, '-'), 1, ':')>

					<cfset stSegments[stAirSegment.XMLAttributes.Key] = {
						ArrivalTime			: ParseDateTime(dArrivalTime),
						ArrivalGMT			: ParseDateTime(DateAdd('h', dArrivalOffset, dArrivalTime)),
						Carrier 			: stAirSegment.XMLAttributes.Carrier,
						ChangeOfPlane		: stAirSegment.XMLAttributes.ChangeOfPlane EQ 'true',
						DepartureTime		: ParseDateTime(GetToken(stAirSegment.XMLAttributes.DepartureTime, 1, '.')),
						DepartureGMT		: dateConvert('local2Utc', stAirSegment.XMLAttributes.DepartureTime),
						Destination			: stAirSegment.XMLAttributes.Destination,
						Equipment			: (StructKeyExists(stAirSegment.XMLAttributes, 'Equipment') ? stAirSegment.XMLAttributes.Equipment : ''),
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
parseTripForPurchase
--->
	<cffunction name="parseTripForPurchase" output="false">
		<cfargument name="sXML">

		<cfset local.sXML = XMLParse(arguments.sXML)>
		<cfset sXML = sXML.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren>
		<cfset local.stSegments = {}>
		<cfset local.stPriceSolution = {}>
		<!--- Move all AirSegment nodes into stSegments --->
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
		<!--- Get AirPricingSolution node --->
		<cfloop array="#sXML#" item="local.stAirPriceResult" index="local.nAirPriceResult">
			<cfif stAirPriceResult.XMLName EQ 'air:AirPriceResult'>
				<cfset stPriceSolution = stAirPriceResult>
				<cfloop array="#stPriceSolution.XMLChildren#" item="local.stAirPricingSolution" index="local.nAirPricingSolution">
					<cfif stAirPricingSolution.XMLName EQ 'air:AirPricingSolution'>
						<cfloop array="#stAirPricingSolution.XMLChildren#" item="local.stChildren" index="local.nChildren">
							<cfif stChildren.XMLName EQ 'air:AirSegmentRef'>
								<!--- Replace the SegmentRef with the air segment details --->
								<cfset stPriceSolution.XMLChildren[nAirPricingSolution].XMLChildren[nChildren] = stSegments[stChildren.XMLAttributes.Key]>
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>

		<cfreturn stPriceSolution />
	</cffunction>

<!---
parseSearchID
--->
	<cffunction name="parseSearchID" output="false">
		<cfargument name="sResponse"	required="true">
		
		<cfset local.stResponse = XMLParse(arguments.sResponse)>
		<cfset local.sLowFareSearchID = ''>

		<cfset stResponse = stResponse.XMLRoot.XMLChildren[1].XMLChildren[1].XMLAttributes>
		<cfif structKeyExists(stResponse, "sLowFareSearchID")>
			<cfset sLowFareSearchID = stResponse.SearchID>
		</cfif>

		<cfreturn sLowFareSearchID />
	</cffunction>

<!---
parseNextReference
--->
	<cffunction name="parseNextReference" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.sNextRef = ''>
		<cfloop array="#arguments.stResponse#" index="local.aNextResultReference">
			<cfif aNextResultReference.XMLName EQ 'common_v15_0:NextResultReference'>
				<cfset sNextRef = aNextResultReference.XMLText>
			</cfif>
		</cfloop>

		<cfreturn sNextRef />
	</cffunction>

<!---
parseTrips
--->
	<cffunction name="parseTrips" output="false">
		<cfargument name="stResponse"		required="true">
		<cfargument name="stSegments"		required="true">
		
		<cfset local.stTrips = {}>
		<cfset local.stTrip = {}>
		<cfset local.sTripKey = ''>
		<cfset local.nCount = 0>
		<cfset local.sSegmentKey = 0>
		<cfset local.sIndex = ''>
		<cfset local.aIndexKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>

		<!---
		Custom code for air pricing to move the 'air:AirPriceResult' up a node to work with the current parsing code.
		--->
		<cfloop array="#arguments.stResponse#" index="local.stAirPricingSolution">
			<cfif stAirPricingSolution.XMLName EQ 'air:AirPriceResult'>
				<cfloop array="#stAirPricingSolution.XMLChildren#" index="local.test">
					<cfset ArrayAppend(arguments.stResponse, test)>
				</cfloop>
			</cfif>
		</cfloop>

		<!--- 
		Create a quick struct containing the private fare information
		--->
		<cfset local.stFares = {}>
		<cfloop array="#arguments.stResponse#" index="local.stFareInfoList">
			<cfif stFareInfoList.XMLName EQ 'air:FareInfoList'>
				<cfloop array="#stFareInfoList.XMLChildren#" index="local.stFareInfo">
					<cfset stFares[stFareInfo.XMLAttributes.Key].PrivateFare = (StructKeyExists(stFareInfo.XMLAttributes, 'PrivateFare') ? stFareInfo.XMLAttributes.PrivateFare EQ 'true' : false)>
				</cfloop>
			</cfif>
		</cfloop>

		<cfloop array="#arguments.stResponse#" index="local.stAirPricingSolution">
			
			<cfif stAirPricingSolution.XMLName EQ 'air:AirPricingSolution'>
				
				<cfset local.stTrip = {}>

				<cfset stTrip.Segments = StructNew('linked')>
				<cfset nCount = 0>
				<cfset nDuration = 0>
				<cfset local.bPrivateFare = false>
				<cfloop array="#stAirPricingSolution.XMLChildren#" index="local.stAirPricingNode">
					
					<cfset sSegmentKey = (StructKeyExists(stAirPricingNode.XMLAttributes, 'Key') ? stAirPricingNode.XMLAttributes.Key : 0)>
				
					<cfif stAirPricingNode.XMLName EQ 'air:AirSegmentRef'>
						
						<cfset stTrip.Segments[sSegmentKey] = arguments.stSegments[sSegmentKey]>
						
					<cfelseif stAirPricingNode.XMLName EQ 'air:AirPricingInfo'>
						<cfset local.sOverallClass = 'E'>
						<cfset local.sPTC = ''>
						<cfset local.nCount = 0>
<!---
MULTI CARRIER AND PF
GET CHEAPEST OF LOOP. MULTIPLE AirPricingInfo
--->
						<cfloop array="#stAirPricingNode.XMLChildren#" index="local.stAirPricingNode2">
							<cfset local.bRefundable = 1>
							<cfif stAirPricingNode2.XMLName EQ 'air:PassengerType'>
								<!--- Passenger type codes --->
								<cfset sPTC = stAirPricingNode2.XMLAttributes.Code>
							<cfelseif stAirPricingNode2.XMLName EQ 'air:FareInfoRef'>
								<!--- Private fares 1/0 --->
								<cfif stFares[stAirPricingNode2.XMLAttributes.Key].PrivateFare>
									<cfset bPrivateFare = true>
								</cfif>
							<cfelseif stAirPricingNode2.XMLName EQ 'air:BookingInfo'>
								<!--- Pricing cabin class --->
								<cfset local.sClass = (StructKeyExists(stAirPricingNode2.XMLAttributes, 'CabinClass') ? stAirPricingNode2.XMLAttributes.CabinClass : 'Economy')>
								<cfset stTrip.Segments[stAirPricingNode2.XMLAttributes.SegmentRef].Class = stAirPricingNode2.XMLAttributes.BookingCode>
								<cfset stTrip.Segments[stAirPricingNode2.XMLAttributes.SegmentRef].Cabin = local.sClass>
								<cfif sClass EQ 'First'>
									<cfset sOverallClass = 'F'>
								<cfelseif sOverallClass NEQ 'F' AND sClass EQ 'Business'>
									<cfset sOverallClass = 'C'>
								<cfelseif sOverallClass NEQ 'F' AND sOverallClass NEQ 'C'>
									<cfset sOverallClass = 'Y'>
								</cfif>
							<cfelseif stAirPricingNode2.XMLName EQ 'air:ChangePenalty'>
								<!--- Refundable or non refundable --->
								<cfloop array="#stAirPricingNode2.XMLChildren#" index="local.stFare">
									<cfset bRefundable = (bRefundable EQ 1 AND stFare.XMLText GT 0 ? 0 : 1)>
								</cfloop>
							</cfif>
						</cfloop>
						<cfset stTrip.Base = Mid(stAirPricingNode.XMLAttributes.BasePrice, 4)>
						<cfset stTrip.Total = Mid(stAirPricingNode.XMLAttributes.TotalPrice, 4)>
						<cfset stTrip.Taxes = Mid(stAirPricingNode.XMLAttributes.Taxes, 4)>
						<cfset stTrip.PrivateFare = bPrivateFare>
						<cfset stTrip.PTC = sPTC>
						<cfset stTrip.Class = sOverallClass>
						<cfset stTrip.Ref = bRefundable>
					</cfif>
				</cfloop>
				<!---
				TRIP KEY
				--->
				<cfset sIndex = ''>
				<cfloop array="#stAirPricingSolution.XMLChildren#" index="local.stAirSegmentRef">
					<cfif stAirSegmentRef.XMLName EQ 'air:AirSegmentRef'>
						<cfloop array="#aIndexKeys#" index="local.stSegment">
							<cfset sIndex &= arguments.stSegments[stAirSegmentRef.XMLAttributes.Key][stSegment]>
						</cfloop>
					</cfif>
				</cfloop>
				<cfset sTripKey = application.objUAPI.hashNumeric(sIndex&sOverallClass&bRefundable)>
				<cfset stTrips[sTripKey] = stTrip>
			</cfif>
		</cfloop>

		<cfreturn  stTrips/>
	</cffunction>

<!---
mergeSegments
--->
	<cffunction name="mergeSegments" output="false">
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

<!---
mergeTrips
--->
	<cffunction name="mergeTrips" output="false">
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

<!--- 
addPreferred
--->
	<cffunction name="addPreferred" output="false">
		<cfargument name="stTrips">
		<cfargument name="stAccount"	required="false" 	default="#application.stAccounts[session.Acct_ID]#">
		
		<cfset local.stTrips = arguments.stTrips>
		<cfloop collection="#stTrips#" item="local.sTripKey">
			<cfset stTrips[sTripKey].Preferred = 0>
			<cfloop array="#arguments.stTrips[sTripKey].Carriers#" index="local.sCarrier">
				<cfif ArrayFindNoCase(arguments.stAccount.aPreferredAir, sCarrier)>
					<cfset stTrips[sTripKey].Preferred = 1>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn stTrips/>
	</cffunction>

<!---
addGroups
--->
	<cffunction name="addGroups" output="false">
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
		<cfloop collection="#stTrips#" item="local.sTrip">
			<cfset stGroups = StructNew('linked')>
			<cfset aCarriers = {}>
			<cfset nDuration = 0>
			<cfset nTotalStops = 0>
			<cfloop collection="#stTrips[sTrip].Segments#" item="local.nSegment">
				<cfset stSegment = stTrips[sTrip].Segments[nSegment]>
				<cfset nOverrideGroup = stSegment.Group>
				<cfset stSegment.Group = nOverrideGroup>
				<cfif NOT structKeyExists(stGroups, nOverrideGroup)>
					<cfset stGroups[nOverrideGroup].Segments 		= StructNew('linked')>
					<cfset stGroups[nOverrideGroup].DepartureTime 	= stSegment.DepartureTime>
					<cfset stGroups[nOverrideGroup].Origin			= stSegment.Origin>
					<cfset stGroups[nOverrideGroup].TravelTime		= '#int(stSegment.TravelTime/60)#h #stSegment.TravelTime%60#m'>
					<cfset nDuration = stSegment.TravelTime + nDuration>
					<cfset nStops = -1>
				</cfif>
				<cfset stGroups[nOverrideGroup].Segments[nSegment]= stSegment>
				<cfset stGroups[nOverrideGroup].ArrivalTime	 	= stSegment.ArrivalTime>
				<cfset stGroups[nOverrideGroup].Destination		= stSegment.Destination>
				<cfset local.aCarriers[stSegment.Carrier] = ''>
				<cfset nStops++>
				<cfset stGroups[nOverrideGroup].Stops				= nStops>
				<cfif nStops GT nTotalStops>
					<cfset nTotalStops = nStops>
				</cfif>
			</cfloop>
			<cfset stTrips[sTrip].Groups 	= stGroups>
			<cfset stTrips[sTrip].Duration 	= nDuration>
			<cfset stTrips[sTrip].Stops 	= nTotalStops>
			<cfif arguments.sType EQ 'Avail'>
				<cfset stTrips[sTrip].Depart= stGroups[nOverrideGroup].DepartureTime>
			<cfelse>
				<cfset stTrips[sTrip].Depart= stGroups[0].DepartureTime>
			</cfif>
			<cfset stTrips[sTrip].Arrival 	= stGroups[nOverrideGroup].ArrivalTime>
			<cfset stTrips[sTrip].Carriers 	= structKeyArray(aCarriers)>
			<cfset StructDelete(stTrips[sTrip], 'Segments')>
		</cfloop>
		
		<cfreturn stTrips/>
	</cffunction>

<!---
addTotalBagFare
--->
	<cffunction name="addTotalBagFare" output="false">
		<cfargument name="stTrips" 	required="true">
		
		<cfloop collection="#arguments.stTrips#" item="local.sTrip">
			<cfif NOT StructKeyExists(stTrips[sTrip], 'TotalBag')>
				<cfset stTrips[sTrip].TotalBag = stTrips[sTrip].Total + application.stAirVendors[stTrips[sTrip].Carriers[1]].Bag1>
			</cfif>
		</cfloop>
		
		<cfreturn stTrips/>
	</cffunction>

<!---
findResults
--->
	<cffunction name="findResults" output="false">
		<cfargument name="stTrips" 	required="true">
		
		<cfset local.stResults = {}>
		<cfset local.sClass = ''>
		<cfset local.bRef = ''>
		<cfloop collection="#arguments.stTrips#" item="local.nTripKey">
			<cfset sClass = arguments.stTrips[nTripKey].Class>
			<cfset bRef = arguments.stTrips[nTripKey].Ref>
			<cfif NOT structKeyExists(stResults, sClass)>
				<cfset stResults[sClass] = 0>
			</cfif>
			<cfif NOT structKeyExists(stResults, bRef)>
				<cfset stResults[bRef] = 0>
			</cfif>
			<cfset stResults[sClass] = stResults[sClass] + 1>
			<cfset stResults[bRef] = stResults[bRef] + 1>
		
		</cfloop>
		
		<cfreturn stResults/>
	</cffunction>

<!---
addJavascript
--->
	<cffunction name="addJavascript" output="false">
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
		</cfloop>
		
		<cfreturn stTrips/>
	</cffunction>

<!---
addJavascriptPerTrip - used only in the above function
--->
	<cffunction name="addJavascriptPerTrip" output="false">
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
		<cfset sJavascript = '"#arguments.sTrip#"'><!--- Token  --->
		<cfset sJavascript = ListAppend(sJavascript, (ArrayIsEmpty(arguments.stTrip.aPolicies) ? 1 : 0))><!--- Policy --->
		<cfset sJavascript = ListAppend(sJavascript, (ListLen(arguments.sCarriers) EQ 1 ? 0 : 1))><!--- Multi Carriers --->
		<cfset sJavascript = ListAppend(sJavascript, '[#arguments.sCarriers#]')><!--- All Carriers --->
		<cfset sJavascript = ListAppend(sJavascript, '"#arguments.bRef#"')><!--- Refundable --->
		<cfset sJavascript = ListAppend(sJavascript, arguments.stTrip.Preferred)><!--- Preferred --->
		<cfset sJavascript = ListAppend(sJavascript, '"#arguments.sCabin#"')><!--- Cabin Class --->
		<cfset sJavascript = ListAppend(sJavascript, arguments.stTrip.Stops)><!--- Stops --->
		
		<cfreturn sJavascript/>
	</cffunction>

<!---
getCarriers
--->
	<cffunction name="getCarriers" output="false">
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

<!---
mergeTripsToAvail
--->
	<cffunction name="mergeTripsToAvail" output="false">
		<cfargument name="stTrips"		required="true">
		<cfargument name="stAvailTrips"	required="true">
		
		<cfset local.stTempTrips = {}>
		<cfset local.nGroup = ''>
		<cfloop collection="#arguments.stTrips#" item="local.sTripKey">
			<cfloop collection="#arguments.stTrips[sTripKey].Segments#" item="local.nSegment">
				<cfset nGroup = arguments.stTrips[sTripKey].Segments[nSegment].Group>
				<cfif NOT structKeyExists(stTempTrips, nGroup)
				OR NOT structKeyExists(stTempTrips[nGroup], sTripKey)>
					<cfset stTempTrips[nGroup][sTripKey] = StructNew('linked')>
				</cfif>
				<cfset stTempTrips[nGroup][sTripKey][nSegment] = arguments.stTrips[sTripKey].Segments[nSegment]>
			</cfloop>
		</cfloop>
		<cfset local.sIndex = ''>
		<cfset local.nHashNumeric = ''>
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<cfloop collection="#stTempTrips#" item="local.nGroup">
			<cfloop collection="#stTempTrips[nGroup]#" item="local.sTripKey">
				<cfset sIndex = ''>
				<cfloop collection="#stTempTrips[nGroup][sTripKey]#" item="local.sSegment">
					<cfloop array="#aSegmentKeys#" index="local.stSegment">
						<cfset sIndex &= stTempTrips[nGroup][sTripKey][sSegment][stSegment]>
					</cfloop>
				</cfloop>
				<cfset nHashNumeric = application.objUAPI.hashNumeric(sIndex)>
				<cfif NOT structKeyExists(arguments.stAvailTrips[nGroup], nHashNumeric)>
					<cfset arguments.stAvailTrips[nGroup][nHashNumeric].Segments = stTempTrips[nGroup][sTripKey]>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn arguments.stAvailTrips/>
	</cffunction>

<!---
checkPolicy
--->
	<cffunction name="checkPolicy" output="false">
		<cfargument name="stTrips"			required="true">
		<cfargument name="nSearchID"		required="true">
		<cfargument name="nLowFareTripKey"	required="true">
		<cfargument name="sType" 			required="false"	default="Fare">
		<cfargument name="stAccount"		required="false"	default="#application.stAccounts[session.Acct_ID]#">
		<cfargument name="stPolicy" 		required="false"	default="#application.stPolicies[session.searches[url.Search_ID].nPolicyID]#">
		
		<cfset local.stTrips = arguments.stTrips>
		<cfset local.stTrip = {}>
		<cfset local.aPolicy = []>
		<cfset local.bActive = 1>
		<cfset local.bBlacklisted = (ArrayLen(arguments.stAccount.aNonPolicyAir) GT 0 ? 1 : 0)>
		<cfif arguments.sType EQ 'Fare'>			
			<cfset local.nLowFare = stTrips[arguments.nLowFareTripKey].Total+arguments.stPolicy.Policy_AirLowPad>
		</cfif>
		
		<cfloop collection="#stTrips#" item="local.nTripKey">
			<cfset stTrip = stTrips[nTripKey]>
			<cfset aPolicy = []>
			<cfset bActive = 1>
			
			<cfif arguments.sType EQ 'Fare'>
				<!--- Out of policy if the fare plus the padding is greater than the lowest available fare. --->
				<cfif arguments.stPolicy.Policy_AirLowRule EQ 1
				AND IsNumeric(arguments.stPolicy.Policy_AirLowPad)
				AND stTrip.Total GT nLowFare>
					<cfset ArrayAppend(aPolicy, 'Not the lowest fare')>
					<cfif arguments.stPolicy.Policy_AirLowDisp EQ 1>
						<cfset bActive = 0>
					</cfif>
				</cfif>
				<!--- Out of policy if the total fare is over the maximum allowed fare. --->
				<cfif arguments.stPolicy.Policy_AirMaxRule EQ 1
				AND IsNumeric(arguments.stPolicy.Policy_AirMaxTotal)
				AND stTrip.Total GT arguments.stPolicy.Policy_AirMaxTotal>
					<cfset ArrayAppend(aPolicy, 'Fare greater than #DollarFormat(arguments.stPolicy.Policy_AirMaxTotal)#')>
					<cfif arguments.stPolicy.Policy_AirMaxDisp EQ 1>
						<cfset bActive = 0>
					</cfif>
				</cfif>
				<!--- Don't display when non refundable --->
				<cfif arguments.stPolicy.Policy_AirRefRule EQ 1
				AND arguments.stPolicy.Policy_AirRefDisp EQ 1
				AND stTrip.Ref EQ 0>
					<cfset ArrayAppend(aPolicy, 'Hide non refundable fares')>
					<cfset bActive = 0>
				</cfif>
				<!--- Don't display when refundable --->
				<cfif arguments.stPolicy.Policy_AirNonRefRule EQ 1
				AND arguments.stPolicy.Policy_AirNonRefDisp EQ 1
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
			<cfif arguments.stPolicy.Policy_AirPrefRule EQ 1
			AND stTrip.Preferred EQ 0>
				<cfset ArrayAppend(aPolicy, 'Not a preferred carrier')>
				<cfif arguments.stPolicy.Policy_AirPrefDisp EQ 1>
					<cfset bActive = 0>
				</cfif>
			</cfif>
			<!--- Out of policy if the carrier is blacklisted (still shows though). --->
			<cfif bBlacklisted>
				<cfloop array="#stTrip.Carriers#" item="local.sCarrier">
					<cfif ArrayFindNoCase(arguments.stAccount.aNonPolicyAir, sCarrier)>
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
		<cfif arguments.stPolicy.Policy_AirAdvRule EQ 1
		AND DateDiff('d', stTrips[nTripKey].Depart_DateTime, Now()) GT arguments.stPolicy.Policy_AirAdv>
			<cfset bAllInactive = 1>
			<cfif arguments.stPolicy.Policy_AirAdvDisp EQ 1>
				<cfset stTrips = {}>
			</cfif>
		</cfif>
		
		<cfreturn stTrips/>
	</cffunction>
	
</cfcomponent>