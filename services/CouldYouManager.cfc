<cfcomponent output="false" accessors="true">

	<cfproperty name="BookingDSN"/>

	<cffunction name="init" access="public" output="false" returntype="any" hint="">
		<cfargument name="BookingDSN" type="string" required="true" />

		<cfset setBookingDSN( arguments.BookingDSN ) />

		<cfreturn this>
	</cffunction>

	<cffunction name="saveTrip" access="public" output="false" returntype="any" hint="">
		<cfargument name="searchId" type="numeric" required="true" />
		<cfargument name="searchStarted" type="date" required="true" />
		<cfargument name="searchEnded" type="date" required="true" />
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

		<cfquery datasource="#getBookingDSN()#">
			INSERT INTO CouldYou ( )

		</cfquery>

	</cffunction>


</cfcomponent>