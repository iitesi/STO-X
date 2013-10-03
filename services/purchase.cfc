<cfcomponent output="false" accessors="true">

	<cfproperty name="bookingDSN"/>

	<cffunction name="init" output="false">
		<cfargument name="bookingDSN" type="string" requred="true" />

		<cfset setBookingDSN( arguments.bookingDSN ) />

		<cfreturn this>
	</cffunction>

	<cffunction name="databaseInvoices" output="false">
		<cfargument name="Traveler" required="true">
		<cfargument name="itinerary" required="true">
		<cfargument name="Filter" required="true">

		<cfquery datasource="#getBookingDSN()#">
			INSERT INTO Invoices 
				( searchID
				, recloc
				, urRecloc
				, firstName
				, lastName 
				, air
				, airSelection
				, car 
				, carSelection
				, hotel
				, hotelSelection
				, userID
				, valueID
				, policyID
				, profileID
				, filter )
			VALUES
				( <cfqueryparam value="#arguments.Filter.getSearchID()#" cfsqltype="cf_sql_integer" >
				, <cfqueryparam value="#arguments.Traveler.getBookingDetail().getReservationCode()#" cfsqltype="cf_sql_varchar" >
				, <cfqueryparam value="#arguments.Traveler.getBookingDetail().getUniversalLocatorCode()#" cfsqltype="cf_sql_varchar" >
				, <cfqueryparam value="#arguments.Traveler.getFirstName()#" cfsqltype="cf_sql_varchar" >
				, <cfqueryparam value="#arguments.Traveler.getLastName()#" cfsqltype="cf_sql_varchar" >
				, <cfqueryparam value="#arguments.Traveler.getBookingDetail().getAirNeeded()#" cfsqltype="cf_sql_integer" >
				, <cfqueryparam value="#(structKeyExists(arguments.itinerary, 'Air') ? serializeJSON(arguments.itinerary.Air) : '')#" cfsqltype="cf_sql_longvarchar" >
				, <cfqueryparam value="#arguments.Traveler.getBookingDetail().getCarNeeded()#" cfsqltype="cf_sql_integer" >
				, <cfqueryparam value="#(structKeyExists(arguments.itinerary, 'Hotel') ? serializeJSON(arguments.itinerary.Hotel) : '')#" cfsqltype="cf_sql_longvarchar" >
				, <cfqueryparam value="#arguments.Traveler.getBookingDetail().getHotelNeeded()#" cfsqltype="cf_sql_integer" >
				, <cfqueryparam value="#(structKeyExists(arguments.itinerary, 'Vehicle') ? serializeJSON(arguments.itinerary.Vehicle) : '')#" cfsqltype="cf_sql_longvarchar" >
				, <cfqueryparam value="#arguments.Filter.getUserID()#" cfsqltype="cf_sql_integer" >
				, <cfqueryparam value="#arguments.Filter.getValueID()#" cfsqltype="cf_sql_integer" >
				, <cfqueryparam value="#arguments.Filter.getPolicyID()#" cfsqltype="cf_sql_integer" >
				, <cfqueryparam value="#arguments.Filter.getProfileID()#" cfsqltype="cf_sql_integer" >
				, <cfqueryparam value="#serializeJSON(arguments.Filter)#" cfsqltype="cf_sql_longvarchar" > )
		</cfquery>

		<cfreturn />
	</cffunction>

	<cffunction name="cancelInvoice" output="false">
		<cfargument name="searchID" required="true">
		<cfargument name="urRecloc" required="true">

		<cfquery datasource="#getBookingDSN()#">
			UPDATE Invoices 
			SET active = <cfqueryparam value="0" cfsqltype="cf_sql_integer" >
			WHERE searchID = <cfqueryparam value="#arguments.searchID#" cfsqltype="cf_sql_integer" >
				AND urRecloc = <cfqueryparam value="#arguments.urRecloc#" cfsqltype="cf_sql_varchar" >
		</cfquery>

		<cfreturn />
	</cffunction>

	<cffunction name="getErrorMessage" output="false">
		<cfargument name="errorMessage">

		<cfset local.message = 'WE ARE UNABLE TO CONFIRM YOUR RESERVATION. PLEASE CONTACT US TO COMPLETE YOUR PURCHASE.'>
		<cfif isArray(arguments.errorMessage)
			AND NOT arrayIsEmpty(arguments.errorMessage)>

			<cfloop array="#arguments.errorMessage#" index="local.errorIndex" item="local.error">
				<cfquery name="local.getMessage" datasource="#getBookingDSN()#">
					SELECT message
					FROM errorMessages
					WHERE '#error#' LIKE '%' + error + '%'
				</cfquery>
				<cfif getMessage.recordCount>
					<cfset message = getMessage.message>
					<cfbreak>
				</cfif>
			</cfloop>

		</cfif>

		<cfreturn message/>
	</cffunction>

</cfcomponent>