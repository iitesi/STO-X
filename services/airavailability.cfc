<cfcomponent>
	
<!--- doAirAvailability --->
	<cffunction name="doAirAvailability" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="stPolicy" 	required="true">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="sAPIAuth" 	required="true">
		
		<cfset local.sMessage = prepareSoapHeader(stAccount, stPolicy, nSearchID)>
		<cfset local.sResponse = callAPI('AirService', sMessage, sAPIAuth, nSearchID)>
		<cfset local.aResponse = formatResponse(sResponse)>
		<cfset local.stSegmentKeys = parseSegmentKeys(aResponse)>
		<cfset local.stSegments = parseSegments(aResponse, stSegmentKeys)>
		<cfset session.searches[nSearchID].stSegments = mergeSegments(session.searches[nSearchID].stSegments, stSegments)>
		<cfset session.searches[nSearchID].stSortSegments = sortSegments(session.searches[nSearchID].stSegments, 'DepartureTime')>
		
<cfdump eval=session.searches[nSearchID].stSortSegments abort>
		<cfset session.searches[nSearchID].stTrips = addJavascript(stTrips)>
		
		<cfreturn >
	</cffunction>

<!--- prepareSoapHeader --->
	<cffunction name="prepareSoapHeader" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="stPolicy" 	required="true">
		<cfargument name="nSearchID" 	required="true">
		
		<cfquery name="local.getsearch" datasource="book">
		SELECT Air_Type, Airlines, International, Depart_City, Depart_DateTime, Depart_TimeType, Arrival_City, Arrival_DateTime, Arrival_TimeType, ClassOfService
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<cfif getsearch.Air_Type EQ 'MD'>
			<cfquery name="local.getsearchlegs" datasource="book">
			SELECT Depart_City, Arrival_City, Depart_DateTime, Depart_TimeType
			FROM Searches_Legs
			WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
			</cfquery>
		</cfif>
		
		<cfsavecontent variable="local.message">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<air:AvailabilitySearchReq TargetBranch="P7003155" xmlns:air="http://www.travelport.com/schema/air_v18_0" xmlns:com="http://www.travelport.com/schema/common_v15_0">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
							<air:SearchAirLeg>
								<air:SearchOrigin>
									<com:Airport Code="#getsearch.Depart_City#" />
								</air:SearchOrigin>
								<air:SearchDestination>
									<com:Airport Code="#getsearch.Arrival_City#" />
								</air:SearchDestination>
								<air:SearchDepTime PreferredTime="#DateFormat(getsearch.Depart_DateTime, 'yyyy-mm-dd')#" />
								<air:AirLegModifiers>
									<air:PermittedCabins>
										<air:CabinClass Type="First"/>
									</air:PermittedCabins>
								</air:AirLegModifiers>								
							</air:SearchAirLeg>
							<cfif getsearch.Air_Type EQ 'RT'>
								<air:SearchAirLeg>
									<air:SearchOrigin>
										<com:Airport Code="#getsearch.Arrival_City#" />
									</air:SearchOrigin>
									<air:SearchDestination>
										<com:Airport Code="#getsearch.Depart_City#" />
									</air:SearchDestination>
									<air:SearchDepTime PreferredTime="#DateFormat(getsearch.Arrival_DateTime, 'yyyy-mm-dd')#" />
									<air:AirLegModifiers>
										<air:PermittedCabins>
											<air:CabinClass Type="First"/>
										</air:PermittedCabins>
									</air:AirLegModifiers>
								</air:SearchAirLeg>
							<cfelseif getsearch.Air_Type EQ 'MD'>
								<cfloop query="getsearchlegs">
									<air:SearchAirLeg>
										<air:SearchOrigin>
											<com:Airport Code="#getsearchlegs.Depart_City#" />
										</air:SearchOrigin>
										<air:SearchDestination>
											<com:Airport Code="#getsearchlegs.Arrival_City#" />
										</air:SearchDestination>
										<air:SearchDepTime PreferredTime="#DateFormat(getsearchlegs.Depart_DateTime, 'yyyy-mm-dd')#" />
										<air:AirLegModifiers>
											<air:PermittedCabins>
												<air:CabinClass Type="First"/>
											</air:PermittedCabins>
										</air:AirLegModifiers>	
									</air:SearchAirLeg>
								</cfloop>
							</cfif>
							<com:SearchPassenger Code="ADT" />
							<com:PointOfSale ProviderCode="1V" PseudoCityCode="1M98" />
						</air:AvailabilitySearchReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn message/>
	</cffunction>
	
<!--- callAPI --->
	<cffunction name="callAPI" returntype="string" output="true">
		<cfargument name="sService"		required="true">
		<cfargument name="sMessage"		required="true">
		<cfargument name="sAPIAuth"		required="true">
		<cfargument name="nSearchID"	required="true">
		
		<cfset local.bSessionStorage = 0>
		
		<cfif NOT bSessionStorage OR NOT StructKeyExists(session.searches[nSearchID], 'sFileContent')>
			<cfhttp method="post" url="https://americas.copy-webservices.travelport.com/B2BGateway/connect/uAPI/#arguments.sService#">
				<cfhttpparam type="header" name="Authorization" value="Basic #arguments.sAPIAuth#" />
				<cfhttpparam type="header" name="Content-Type" value="text/xml;charset=UTF-8" />
				<cfhttpparam type="header" name="Accept" value="gzip,deflate" />
				<cfhttpparam type="header" name="Cache-Control" value="no-cache" />
				<cfhttpparam type="header" name="Pragma" value="no-cache" />
				<cfhttpparam type="header" name="SOAPAction" value="" />
				<cfhttpparam type="body" name="message" value="#Trim(arguments.sMessage)#" />
			</cfhttp>
			<cfif bSessionStorage>
				<cfset session.searches[nSearchID].sFileContent = cfhttp.filecontent>
			</cfif>
		<cfelse>
			<cfset cfhttp.filecontent = session.searches[nSearchID].sFileContent>
		</cfif>
		
		<cfreturn cfhttp.filecontent />
	</cffunction>
	
<!--- formatResponse --->
	<cffunction name="formatResponse" returntype="array" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stResponse = XMLParse(arguments.stResponse)>
		
		<cfreturn stResponse.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren />
	</cffunction>
	
<!--- parseSegmentKeys --->
	<cffunction name="parseSegmentKeys" returntype="struct" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stSegmentKeys = {}>
		<cfset local.sIndex = ''>
		<cfset local.aSegmentKeys = ['Origin', 'Destination', 'DepartureTime', 'ArrivalTime', 'Carrier', 'FlightNumber']>
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<cfif stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<cfset sIndex = ''>
					<cfloop array="#aSegmentKeys#" index="local.sCol">
						<cfset sIndex &= stAirSegment.XMLAttributes[sCol]>
					</cfloop>
					<cfset stSegmentKeys[stAirSegment.XMLAttributes.Key] = {
						HashIndex	: 	HashNumeric(sIndex),
						Index		: 	sIndex
					}>
				</cfloop>
			</cfif>
		</cfloop>
			
		<cfreturn stSegmentKeys />
	</cffunction>
	
<!--- parseSegments --->
	<cffunction name="parseSegments" returntype="struct" output="false">
		<cfargument name="stResponse"	required="true">
		<cfargument name="stSegmentKeys"required="true">
		
		<cfset local.stSegments = {}>
		<cfloop array="#arguments.stResponse#" index="local.stAirSegmentList">
			<cfif stAirSegmentList.XMLName EQ 'air:AirSegmentList'>
				<cfloop array="#stAirSegmentList.XMLChildren#" index="local.stAirSegment">
					<cfset local.sAPIKey = stAirSegment.XMLAttributes.Key>
					<cfset stSegments[arguments.stSegmentKeys[sAPIKey].HashIndex] = {
						ArrivalTime			: ParseDateTime(stAirSegment.XMLAttributes.ArrivalTime),
						Carrier 			: stAirSegment.XMLAttributes.Carrier,
						ChangeOfPlane		: stAirSegment.XMLAttributes.ChangeOfPlane EQ 'true',
						DepartureTime		: ParseDateTime(stAirSegment.XMLAttributes.DepartureTime),
						Destination			: stAirSegment.XMLAttributes.Destination,
						Equipment			: stAirSegment.XMLAttributes.Equipment,
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
	
<!--- mergeSegments --->
	<cffunction name="mergeSegments" returntype="struct" output="false">
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
	
<!--- sortSegments --->
	<cffunction name="sortSegments" returntype="array" output="false">
		<cfargument name="stSegments" 	required="true">
		<cfargument name="sField" 	required="true">
				
		<cfreturn StructSort(arguments.stSegments, 'numeric', 'asc', arguments.sField )/>
	</cffunction>
	
</cfcomponent>