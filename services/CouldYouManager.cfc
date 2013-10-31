<cfcomponent output="false" accessors="true">

	<cfproperty name="BookingDSN"/>

	<cffunction name="init" access="public" output="false" returntype="any" hint="">
		<cfargument name="BookingDSN" type="string" required="true" />

		<cfset setBookingDSN( arguments.BookingDSN ) />

		<cfreturn this>
	</cffunction>

	<cffunction name="logTrip" access="public" output="false" returntype="any" hint="">
		<cfargument name="searchId" type="numeric" required="true" />
		<cfargument name="isOriginal" type="boolean" required="true" />
		<cfargument name="isSelected" type="boolean" required="true" />
		<cfargument name="isWeekendDeparture" type="boolean" required="true" />
		<cfargument name="daysFromOriginal" type="numeric" required="true" />
		<cfargument name="daysFromOriginal" type="numeric" required="true" />
		<cfargument name="airAvailable" type="boolean" required="true" />
		<cfargument name="hotelAvailable" type="boolean" required="true" />
		<cfargument name="vehicleAvailable" type="boolean" required="true" />
		<cfargument name="airCost" type="numeric" required="false" />
		<cfargument name="hotelCost" type="numeric" required="false" />
		<cfargument name="vehicleCost" type="numeric" required="false" />
		<cfargument name="tripCost" type="numeric" required="false" />
		<cfargument name="searchStarted" type="date" required="false" />
		<cfargument name="searchEnded" type="date" required="false" />

		<cfquery datasource="#getBookingDSN()#">
			INSERT INTO CouldYou (
				  searchId
				, isOriginal
				, isSelected
				, isWeekendDeparture
				, daysFromOriginal
				, airAvailable
				, hotelAvailable
				, vehicleAvailable
				<cfif structkeyExists( arguments, "searchStarted" )>
					, searchStarted
				</cfif>
				<cfif structkeyExists( arguments, "searchEnded" )>
					, searchEnded
				</cfif>
				<cfif structkeyExists( arguments, "airCost" )>
					, airCost
				</cfif>
				<cfif structkeyExists( arguments, "hotelCost" )>
					, hotelCost
				</cfif>
				<cfif structkeyExists( arguments, "vehicleCost" )>
					, vehicleCost
				</cfif>
				<cfif structkeyExists( arguments, "tripCost" )>
					, tripCost
				</cfif>
			   )
			Vales(
				  <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.searchId#" />
				, <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.isOriginal#" />
				, <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.isSelected#" />
				, <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.isWeekendDeparture#" />
				, <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.daysFromOriginal#" />
				, <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.airAvailable#" />
				, <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.hotelAvailable#" />
				, <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.vehicleAvailable#" />
				<cfif structkeyExists( arguments, "searchStarted" )>
					, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.searchStarted#" />
				</cfif>
				<cfif structkeyExists( arguments, "searchEnded" )>
					, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.searchEnded#" />
				</cfif>
				<cfif structkeyExists( arguments, "airCost" )>
					, <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.airCost#" />
				</cfif>
				<cfif structkeyExists( arguments, "vehicleCost" )>
					, <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.vehicleCost#" />
				</cfif>
				<cfif structkeyExists( arguments, "tripCost" )>
					, <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.tripCost#" />
				</cfif>

			)

		</cfquery>

	</cffunction>


</cfcomponent>