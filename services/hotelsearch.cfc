<cfcomponent output="false" accessors="true">

	<cffunction name="init" output="false">

		<cfreturn this>
	</cffunction>

    <!--- TODO: This needs to be moved to a different class file --->
	<cffunction Name="latlong" access="remote" returntype="string" output="false">
		<cfargument Name="Hotel_Search" />
		<cfargument Name="Hotel_Airport" />
		<cfargument Name="Hotel_Landmark" />
		<cfargument Name="Hotel_Address" />
		<cfargument Name="Hotel_City" />
		<cfargument Name="Hotel_State" />
		<cfargument Name="Hotel_Zip" />
		<cfargument Name="Hotel_Country" required="false" default="USA" />
		<cfargument Name="Office_ID" />
		
		<cfset local.LatLong = '0,0'>
		<cfset local.getSpecificLongLat = ''>
		<cfset local.Search_Location = ''>

		<cfif arguments.Hotel_Search EQ 'Airport'>
			<cfquery name="getSpecificLongLat" datasource="book" cachedwithin="#createTimeSpan(1,0,0,0)#">
			SELECT Long, Lat, Geography_ID
			FROM lu_Geography
			WHERE Location_Display = <cfqueryparam value="#arguments.Hotel_Airport#" cfsqltype="cf_sql_varchar">
			AND Location_Type = 125
			AND Lat <> 0
			AND Long <> 0
			</cfquery>
			<cfif getSpecificLongLat.RecordCount EQ 1>
				<cfset local.LatLong = getSpecificLongLat.Lat&','&getSpecificLongLat.Long&','&getSpecificLongLat.Geography_ID>
			<cfelseif Len(arguments.Hotel_Airport) EQ 3>
				<cfquery name="getSpecificLongLat" datasource="book" cachedwithin="#createTimeSpan(1,0,0,0)#">
				SELECT Long, Lat, Geography_ID
				FROM lu_Geography
				WHERE Location_Code = <cfqueryparam value="#arguments.Hotel_Airport#" cfsqltype="cf_sql_varchar">
				AND Location_Type = 125
				AND Lat <> 0
				AND Long <> 0
				</cfquery>
				<cfif getSpecificLongLat.RecordCount EQ 1>
					<cfset local.LatLong = getSpecificLongLat.Lat&','&getSpecificLongLat.Long&','&getSpecificLongLat.Geography_ID>
				</cfif>
			</cfif>
		<cfelseif arguments.Hotel_Search EQ 'City'>
			<cfquery name="getSpecificLongLat" datasource="book" cachedwithin="#createTimeSpan(1,0,0,0)#">
			SELECT Long, Lat, Geography_ID
			FROM lu_Geography
			WHERE Location_Display = <cfqueryparam value="#arguments.Hotel_Landmark#" cfsqltype="cf_sql_varchar">
			AND Location_Type = 126
			AND Lat <> 0
			AND Long <> 0
			</cfquery>
			<cfif getSpecificLongLat.RecordCount EQ 1 AND getSpecificLongLat.Lat NEQ '' AND getSpecificLongLat.Long NEQ ''>
				<cfset local.LatLong = getSpecificLongLat.Lat&','&getSpecificLongLat.Long&','&getSpecificLongLat.Geography_ID>
			</cfif>
		<cfelseif arguments.Hotel_Search EQ 'Office'>
			<cfquery name="getSpecificLongLat" datasource="book" cachedwithin="#createTimeSpan(1,0,0,0)#">
			SELECT Office_Long, Office_Lat
			FROM Account_Offices
			WHERE Office_ID = <cfqueryparam value="#arguments.Office_ID#" cfsqltype="cf_sql_numeric">
			</cfquery>
			<cfif getSpecificLongLat.RecordCount EQ 1 AND getSpecificLongLat.Office_Lat NEQ '' AND getSpecificLongLat.Office_Long NEQ ''>
				<cfset local.LatLong = getSpecificLongLat.Office_Lat&','&getSpecificLongLat.Office_Long&',0'>
			</cfif>
		</cfif>

		<cfif LatLong EQ '0,0'>
			<cfif arguments.Hotel_Search EQ 'Airport'>
				<cfset local.Search_Location = arguments.Hotel_Airport>
			<cfelseif arguments.Hotel_Search EQ 'City'>
				<cfset local.Search_Location = arguments.Hotel_Landmark>
			<cfelseif arguments.Hotel_Search EQ 'Office'>
				<cfset local.Search_Location = ''>
			<cfelse>
				<cfset local.Search_Location = '#Trim(arguments.Hotel_Address)#,#Trim(arguments.Hotel_City)#,#Trim(arguments.Hotel_State)#,#Trim(arguments.Hotel_Zip)#,#Trim(arguments.Hotel_Country)#'>
			</cfif>

			<cfif Search_Location NEQ '' AND Search_Location NEQ ',,,'>
				<cftry>
					<cfhttp method="get" url="https://maps.google.com/maps/geo?q=#Search_Location#&output=xml&oe=utf8\&sensor=false&key=ABQIAAAAIHNFIGiwETbSFcOaab8PnBQ2kGXFZEF_VQF9vr-8nzO_JSz_PxTci5NiCJMEdaUIn3HA4o_YLE757Q" />
					<cfset local.LatLong = XMLParse(cfhttp.FileContent)>
					<cfset local.LatLong = LatLong.kml.Response.Placemark.Point.coordinates.XMLText>
					<cfset local.LatLong = GetToken(LatLong, 2, ',')&','&GetToken(LatLong, 1, ',')&',0'>
					<cfcatch>
						<cfset local.LatLong = '0,0'>
					</cfcatch>
				</cftry>
			</cfif>
		</cfif>

		<cfreturn LatLong>
	</cffunction>

	<cffunction name="skipHotel" output="false">
		<cfargument name="SearchID">

		<cfset session.searches[arguments.SearchID].Hotel = false />
		
		<cfreturn />
	</cffunction>

</cfcomponent>