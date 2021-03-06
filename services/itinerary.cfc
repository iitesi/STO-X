<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cffunction name="init" output="false" hint="Init method.">

		<cfreturn this />
	</cffunction>

	<cffunction name="selectAir" output="false">
		<cfargument name="form" required="true">
		<cfargument name="Itinerary" required="true">
		<cfargument name="Group" required="false" default="">
		<cfargument name="Groups" required="false" default="">

		<cfset var form = arguments.form>
		<cfset var Itinerary = arguments.Itinerary>
		<cfset var Group = arguments.Group>
		<cfset var Groups = arguments.Groups>

		<cfset var Air = {}>

		<cfset Air = deserializeJSON(form.Segment)>
		<cfset Fare = deserializeJSON(form.Fare)>

		<cfloop list="#form.fieldnames#" index="local.fieldname">
			<cfif fieldname NEQ 'fieldnames'
				AND fieldname NEQ 'Segment'>
				<cfset Air[fieldname] = form[fieldname]>
			</cfif>
		</cfloop>

		<cfset Itinerary.Air[Group] = Air>
		<cfset Itinerary.Air[Group].Fare = Fare>

		<cfloop from="0" to="#Groups-1#" index="local.Count">
			<cfif Count GT Group>
				<cfset Itinerary.Air[Count] = {}>
			</cfif>
		</cfloop>
		
		<cfreturn Itinerary />
 	</cffunction>

	<cffunction name="selectFare" output="false">
		<cfargument name="Fare" required="true">
		<cfargument name="Itinerary" required="true">

		<cfset var Fare = deserializeJSON(arguments.Fare)>
		<cfset var Itinerary = arguments.Itinerary>
		<cfset var SegmentFareId = ''>
		<cfset var OutOfPolicy = false>

		<cfloop collection="#Itinerary#" index="local.GroupKey" item="local.Group">

			<cfset SegmentFareId = ''>
			<cfloop collection="#Group.Flights#" index="index" item="local.Flight">
		
				<cfset SegmentFareId = listAppend(SegmentFareId, Fare.Flights[Flight.FlightId].Carrier&'.'&Fare.Flights[Flight.FlightId].FlightNumber&'.'&Fare.Flights[Flight.FlightId].BookingCode, '-')>
				<cfset Flight.BrandedFare = Fare.Flights[Flight.FlightId].BrandedFare>
				<cfset Flight.Wifi = Fare.Flights[Flight.FlightId].Wifi>
				<cfset Flight.CabinClass = Fare.Flights[Flight.FlightId].CabinClass>
				<cfset Flight.FareBasis = Fare.Flights[Flight.FlightId].FareBasis>
				<cfset Flight.BookingCode = Fare.Flights[Flight.FlightId].BookingCode>

				<cfif Flight.OutOfPolicy>
					<cfset OutOfPolicy = true>
				</cfif>

			</cfloop>

			<cfloop collection="#Fare#" index="local.FareKey">

				<cfif FareKey NEQ 'Flights'>
					<cfset Group[FareKey] = Fare[FareKey]>
				</cfif>

				<cfif Flight.OutOfPolicy>
					<cfset OutOfPolicy = true>
				</cfif>

			</cfloop>
		
			<cfset Itinerary[GroupKey].SegmentFareId = 'G'&GroupKey&'-'&SegmentFareId>
			<cfset structDelete(Itinerary[GroupKey], 'Availability')>
			<cfset structDelete(Itinerary[GroupKey], 'Fare')>

		</cfloop>

		<cfloop from="0" to="#GroupKey#" index="local.GroupIndex">
			<cfset Itinerary[GroupIndex].OutOfPolicy = OutOfPolicy>
		</cfloop>

		<cfreturn Itinerary />
 	</cffunction>

	<cffunction name="selectRail" output="false">
		<cfargument name="form" required="true">
		<cfargument name="Itinerary" required="true">
		<cfargument name="Group" required="false" default="">
		<cfargument name="Groups" required="false" default="">

		<cfset var form = arguments.form>
		<cfset var Itinerary = arguments.Itinerary>
		<cfset var Group = arguments.Group>
		<cfset var Groups = arguments.Groups>

		<cfset Itinerary.Rail[Group] = deserializeJSON(form.Rail)>

		<cfloop from="0" to="#Groups-1#" index="local.Count">
			<cfif Count GT Group>
				<cfset Itinerary.Rail[Count] = {}>
			</cfif>
		</cfloop>
		
		<cfreturn Itinerary />
 	</cffunction>

</cfcomponent>