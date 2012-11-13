<cfcomponent output="false">
	
<!--- doLocations --->
	<cffunction name="doLocations" output="false">
		<cfargument name="nSearchID" 	required="true">
		
		<cfset local.stAccount = application.stAccounts[session.Acct_ID]>
		<cfset local.stDates = getDates(nSearchID)>
		<cfset local.sLatLong = getAirportLatLong(nSearchID)>
		<cfset local.sMessage = prepareSoapHeader(nSearchID, stDates, stAccount)>
		<cfset local.sResponse = application.objUAPI.callUAPI('VehicleService', sMessage, nSearchID)>
		<cfset local.aResponse = application.objUAPI.formatUAPIRsp(sResponse)>
		<cfset local.stLocations = parseLocations(aResponse)>
		<cfset stLocations = getLatLong(stLocations)>
		<cfset stLocations.Center = sLatLong>
		
		<!---<cfset session.searches[nSearchID].stTrips = addJavascript(stTrips)>--->
		
		<cfreturn stLocations>
	</cffunction>
	
<!--- getDates --->
	<cffunction name="getDates" output="false">
		<cfargument name="nSearchID"	required="true">
		
		<cfset local.stDates = {}>
		<cfset stDates.PickUp_DateTime = ''>
		<cfset stDates.DropOff_DateTime = ''>
		<cfif session.searches[arguments.nSearchID].Air>
			<!--- To Do!! --->
		</cfif>
		<cfif NOT IsDate(stDates.PickUp_DateTime)
		OR NOT IsDate(stDates.DropOff_DateTime)>
			<cfquery name="local.getsearch" datasource="book">
			SELECT Depart_DateTime, Arrival_DateTime
			FROM Searches
			WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
			</cfquery>
			<cfset stDates.PickUp_DateTime = getsearch.Depart_DateTime>
			<cfset stDates.DropOff_DateTime = getsearch.Arrival_DateTime>
		</cfif>
		
		<cfreturn stDates>
	</cffunction>
	
<!--- getAirportLatLong --->
	<cffunction name="getAirportLatLong" output="false">
		<cfargument name="nSearchID"	required="true">
		
		<cfquery name="local.getsearch" datasource="book">
		SELECT Airport_Location
		FROM lu_FullAirports
		WHERE Airport_Code IN (SELECT 'ALO' AS Arrival_City
								FROM Searches
								WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />)
		</cfquery>
		
		<cfset local.sLatLong = ''>
		<cftry>
			<cfhttp method="get" url="https://maps.google.com/maps/geo?q=#getsearch.Airport_Location#&output=xml&oe=utf8\&sensor=false&key=ABQIAAAAIHNFIGiwETbSFcOaab8PnBQ2kGXFZEF_VQF9vr-8nzO_JSz_PxTci5NiCJMEdaUIn3HA4o_YLE757Q" />
			<cfset sLatLong = XMLParse(cfhttp.FileContent)>
			<cfset sLatLong = sLatLong.kml.Response.Placemark.Point.coordinates.XMLText>
			<cfcatch>
				<cfset sLatLong = '0,0'>
			</cfcatch>
		</cftry>
		
		<cfreturn sLatLong />
	</cffunction>
	
<!--- prepareSOAPHeader --->
	<cffunction name="prepareSOAPHeader" output="false">
		<cfargument name="nSearchID" 	required="true">
		<cfargument name="stDates" 		required="true">
		<cfargument name="stAccount" 		required="true">
		
		<cfquery name="local.getsearch" datasource="book">
		SELECT 'ALO' AS Arrival_City
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		
		<cfsavecontent variable="local.sMessage">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
						<veh:VehicleLocationReq TargetBranch="#arguments.stAccount.sBranch#" xmlns:veh="http://www.travelport.com/schema/vehicle_v17_0">
							<com:BillingPointOfSaleInfo OriginApplication="UAPI" xmlns:com="http://www.travelport.com/schema/common_v15_0" />
							<veh:PickupDateLocation Date="#DateFormat(arguments.stDates.PickUp_DateTime, 'yyyy-mm-dd')#" Location="#getsearch.Arrival_City#" LocationType="CityCenterDowntown" />
						</veh:VehicleLocationReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn sMessage/>
	</cffunction>
	
<!--- parseLocations --->
	<cffunction name="parseLocations" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stLocations = StructNew('linked')>
		<cfset local.cnt = 0>
		<cfloop array="#arguments.stResponse#" index="local.stVehicleLocation">
			<cfif stVehicleLocation.XMLName EQ 'vehicle:VehicleLocation'>
				<cfloop array="#stVehicleLocation.XMLChildren#" index="local.stLocation">
					<cfif stLocation.XMLName EQ 'common_v15_0:VendorLocation'>
						<cfset cnt++>
						<cfset stLocations[cnt].VendorLocationID = stLocation.XMLAttributes.VendorLocationID>
						<cfset stLocations[cnt].VendorCode = stLocation.XMLAttributes.VendorCode>
					<cfelseif stLocation.XMLName EQ 'vehicle:LocationInformation'>
						<cfloop array="#stLocation.XMLChildren#" index="local.stAddress">
							<cfif stAddress.XMLName EQ 'vehicle:Address'>
								<cfloop array="#stAddress.XMLChildren#" index="local.stAddressFields">
									<cfset stLocations[cnt][GetToken(stAddressFields.XMLName, 2, ':')] = stAddressFields.XMLText>
								</cfloop>
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfreturn stLocations />
	</cffunction>
	
<!--- getLatLong --->
	<cffunction name="getLatLong" output="false">
		<cfargument name="stLocations"	required="true">
		
		<cfset local.stLocations = arguments.stLocations>
		<cfset local.sLatLong = ''>
		
		<cfquery name="local.qCity">
		SELECT CityName, StateCode
		FROM RCTY
		WHERE Airports LIKE '%#stLocations[1].City#%'
		</cfquery>
		
		<cfloop collection="#stLocations#" item="sLocation">
			<cfset sLatLong = ''>
			<cftry>
				<cfhttp method="get" url="https://maps.google.com/maps/geo?q=#stLocations[sLocation].Street#,#qCity.CityName#,#qCity.StateCode#,#stLocations[sLocation].Country#&output=xml&oe=utf8\&sensor=false&key=ABQIAAAAIHNFIGiwETbSFcOaab8PnBQ2kGXFZEF_VQF9vr-8nzO_JSz_PxTci5NiCJMEdaUIn3HA4o_YLE757Q" />
				<cfset sLatLong = XMLParse(cfhttp.FileContent)>
				<cfset sLatLong = sLatLong.kml.Response.Placemark.Point.coordinates.XMLText>
				<cfcatch>
					<cfset sLatLong = '0,0'>
				</cfcatch>
			</cftry>
			<cfset stLocations[sLocation].sLatLong = sLatLong>
		</cfloop>
		
		<cfreturn stLocations />
	</cffunction>
	
</cfcomponent>