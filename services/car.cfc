<cfcomponent output="false">
	
<!--- doAvailability --->
	<cffunction name="doAvailability" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="stPolicy" 	required="true">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="sAPIAuth" 	required="true">
		
		<cfset local.sJoinThread = ''>
		
		<cfset local.sMessage = prepareSoapHeader(stAccount, stPolicy, nSearchID)>
		<cfset local.sResponse = callAPI('VehicleService', sMessage, sAPIAuth, nSearchID)>
		<cfset local.aResponse = formatResponse(sResponse)>
		<cfset session.searches[nSearchID].stCars = parseCars(aResponse)>
		<cfset session.searches[nSearchID].stCategory = sortCars(session.searches[nSearchID].stCars, 'Category')>
		<cfdump eval=session.searches[nSearchID].stCategory abort>
		
		<cfset session.searches[nSearchID].stTrips = addJavascript(stTrips)>
		
		<cfreturn >
	</cffunction>

<!--- prepareSOAPHeader --->
	<cffunction name="prepareSOAPHeader" returntype="string" output="false">
		<cfargument name="stAccount" 	required="true">
		<cfargument name="stPolicy" 	required="true">
		<cfargument name="nSearchID" 	required="true">
		
		<cfquery name="local.getsearch" datasource="book">
		SELECT Depart_DateTime, Arrival_City, Arrival_DateTime
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		
		<cfsavecontent variable="local.sMessage">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<veh:VehicleSearchAvailabilityReq TargetBranch="#arguments.stAccount.sBranch#" xmlns:com="http://www.travelport.com/schema/common_v15_0" xmlns:veh="http://www.travelport.com/schema/vehicle_v17_0" ReturnExtraRateInfo="true" ReturnApproximateTotal="true" ReturnAllRates="true">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI" />
							<veh:VehicleDateLocation
								ReturnLocationType="Airport"
								PickupLocation="#getsearch.Arrival_City#"
								PickupDateTime="#DateFormat(getsearch.Depart_DateTime, 'yyyy-mm-dd')#T08:00:00.000+01:00"
								PickupLocationType="Airport"
								ReturnLocation="#getsearch.Arrival_City#"
								ReturnDateTime="#DateFormat(getsearch.Arrival_DateTime, 'yyyy-mm-dd')#T17:00:00.000+01:00" />
							<veh:VehicleSearchModifiers>
								<veh:VehicleModifier />
							</veh:VehicleSearchModifiers>
						</veh:VehicleSearchAvailabilityReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn sMessage/>
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
	<cffunction name="formatResponse" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stResponse = XMLParse(arguments.stResponse)>
		
		<cfreturn stResponse.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren />
	</cffunction>
	
<!--- parseCars --->
	<cffunction name="parseCars" returntype="struct" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stCars = {}><!--- Overall structure to pass back from this function --->
		<cfset local.aCarKeys = ['VendorCode', 'VehicleClass']><!--- Distinct columns to make the index --->
		<cfset local.sIndex = ''>
		<cfset local.sHash = ''>
		<cfloop array="#arguments.stResponse#" index="local.stVehicle">
			<cfif stVehicle.XMLName EQ 'vehicle:Vehicle'>
				<!--- Get a primary key for the car --->
				<cfset sIndex = ''>
				<cfloop array="#aCarKeys#" index="local.sCol">
					<cfset sIndex &= stVehicle.XMLAttributes[sCol]>
				</cfloop>
				<cfset sHash = HashNumeric(sIndex)>
				<!--- Populate the car --->
				<cfset stCars[sHash] = {
					DoorCount			: 	(StructKeyExists(stVehicle.XMLAttributes, 'DoorCount') ? stVehicle.XMLAttributes.DoorCount : ''),
					Location			: 	stVehicle.XMLAttributes.Location,
					VendorCode			: 	stVehicle.XMLAttributes.VendorCode,
					VehicleClass		: 	stVehicle.XMLAttributes.VehicleClass,
					TransmissionType	: 	stVehicle.XMLAttributes.TransmissionType,
					Category			: 	stVehicle.XMLAttributes.Category,
					VendorLocationKey	: 	stVehicle.XMLAttributes.VendorLocationKey
				}>
				<cfloop array="#stVehicle.XMLChildren#" index="local.stVehicleRate">
					<cfif stVehicleRate.XMLName EQ 'vehicle:VehicleRate'>
						<cfif NOT StructKeyExists(stCars[sHash], 'EstimatedTotalAmount')
						OR stCars[ssHash].EstimatedTotalAmount GT stVehicleRate.XMLAttributes.EstimatedTotalAmount>
							<cfset stCars[sHash].EstimatedTotalAmount = stVehicleRate.XMLAttributes.EstimatedTotalAmount>
							<cfset stCars[sHash].RateAvailability = stVehicleRate.XMLAttributes.RateAvailability>
							<cfset stCars[sHash].RateCategory = stVehicleRate.XMLAttributes.RateCategory>
							<cfset stCars[sHash].RateCode = stVehicleRate.XMLAttributes.RateCode>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
			
		<cfreturn stCars />
	</cffunction>
	
<!--- lowfare : sortCars --->
	<cffunction name="sortCars" returntype="array" output="false">
		<cfargument name="stCars" 	required="true">
		<cfargument name="sField" 	required="true">
		
		<cfreturn StructSort(arguments.stCars, 'text', 'asc', arguments.sField )/>
	</cffunction>
	
<!--- lowfare : addJavascript --->
	<cffunction name="addJavascript" returntype="struct" output="false">
		<cfargument name="stTrips" 	required="true">
		
		<!---
			 * 	0	Token				DL0211DL1123UA221
			 * 	1	Policy				1/0
			 * 	2 	Multiple Carriers	1/0
			 * 	3 	Carriers			"DL","AA","UA"
			 * 	4	Refundable			1/0
			 * 	5	Total Price			000.00
			 * 	6	Travel Time			000
			 * 	7	Preferred			1/0
			 * 	8	Cabin Class			Economy, Business, First
			 * 	9	Stops				0/1/2
		--->
		<cfset local.aAllCabins = ['Y','C','F']>
		<cfset local.aRefundable = [0,1]>
		<cfloop collection="#arguments.stTrips#" item="local.sTrip">
			<cfset sCarriers = '"#Replace(arguments.stTrips[sTrip].Carriers, ',', '","', 'ALL')#"'>
			<cfloop array="#aAllCabins#" index="local.sCabin">
				<cfif StructKeyExists(arguments.stTrips[sTrip], sCabin)>
					<cfif StructKeyExists(arguments.stTrips[sTrip][sCabin], 0)>
						<cfset stTrips[sTrip].sJavascript = "#sTrip#,1,#(ListLen(arguments.stTrips[sTrip].Carriers) EQ 1 ? 0 : 1)#,[#sCarriers#],0,#arguments.stTrips[sTrip].LowFare#,0,0,'#sCabin#',#arguments.stTrips[sTrip].Stops#">
					</cfif>
					<cfif StructKeyExists(arguments.stTrips[sTrip][sCabin], 1)>
						<cfset stTrips[sTrip].sJavascript = "#sTrip#,1,#(ListLen(arguments.stTrips[sTrip].Carriers) EQ 1 ? 0 : 1)#,[#sCarriers#],1,#arguments.stTrips[sTrip].LowFare#,0,0,'#sCabin#',#arguments.stTrips[sTrip].Stops#">
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn stTrips/>
	</cffunction>
	
</cfcomponent>