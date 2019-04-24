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
		
		<!--- <cfdump var=#Itinerary# abort> --->
		
		<cfreturn Itinerary />
 	</cffunction>


	<cffunction name="selectFare" output="false">
		<cfargument name="Fare" required="true">
		<cfargument name="Itinerary" required="true">

		<cfset var Fare = deserializeJSON(arguments.Fare)>
		<cfset var Itinerary = arguments.Itinerary>
		<cfset var SegmentFareId = ''>

		<cfloop collection="#Itinerary#" index="local.GroupKey" item="local.Group">

			<cfset SegmentFareId = ''>
			<cfloop collection="#Group.Flights#" index="index" item="local.Flight">
		
				<cfset SegmentFareId = listAppend(SegmentFareId, Fare.Flights[Flight.FlightId].Carrier&'.'&Fare.Flights[Flight.FlightId].FlightNumber&'.'&Fare.Flights[Flight.FlightId].BookingCode, '-')>
				<cfset Flight.BrandedFare = Fare.Flights[Flight.FlightId].BrandedFare>
				<cfset Flight.Wifi = Fare.Flights[Flight.FlightId].Wifi>
				<cfset Flight.CabinClass = Fare.Flights[Flight.FlightId].CabinClass>
				<cfset Flight.FareBasis = Fare.Flights[Flight.FlightId].FareBasis>
				<cfset Flight.BookingCode = Fare.Flights[Flight.FlightId].BookingCode>

			</cfloop>

			<cfloop collection="#Fare#" index="local.FareKey">

				<cfif FareKey NEQ 'Flights'>
					<cfset Group[FareKey] = Fare[FareKey]>
				</cfif>

			</cfloop>
		
			<cfset Itinerary[GroupKey].SegmentFareId = 'G'&GroupKey&'-'&SegmentFareId>
			<cfset structDelete(Itinerary[GroupKey], 'Availability')>
			<cfset structDelete(Itinerary[GroupKey], 'Fare')>

		</cfloop>

		<!--- <cfdump var=#Itinerary# abort> --->

		<cfreturn Itinerary />
 	</cffunction>

	<!--- <cffunction name="removeSegment" output="false">
		<cfargument name="Itinerary" required="true">
		<cfargument name="SegmentType" required="true">
		<cfargument name="Segment" required="true">
		<cfargument name="Group" required="false" default="">
		<cfargument name="Groups" required="false" default="">

		<cfset var Itinerary = arguments.Itinerary>
		<cfset var SegmentType = arguments.SegmentType>
		<cfset var Segment = arguments.Segment>
		<cfset var Group = arguments.Group>

		<cfif Group NEQ ''>
			<cfloop from="0" to="#arguments.Groups-1#" index="local.Count">
				<cfif Count GTE Group>
					<cfset Itinerary[SegmentType][Count] = {}>
				</cfif>
			</cfloop>
			<cfif Group EQ 0>
				<cfset Itinerary[SegmentType&'Selected'] = false>
			</cfif>
		<!--- <cfelse>
			<cfset Itinerary[SegmentType&'Selected'] = false>
			<cfset structDelete(Itinerary, SegmentType)>
		</cfif> --->
		<cfset Itinerary = orderItinerary(Itinerary)>

		<cfreturn Itinerary />
 	</cffunction> --->

	<cffunction name="orderItinerary" output="false">
		<cfargument name="Itinerary" required="true">

		<cfset var Itinerary = arguments.Itinerary>
		<cfset var Ordering = structNew()>

		<cfif Itinerary.AirSelected>
		    <cfloop collection="#Itinerary.Air#" item="local.Group" index="local.GroupIndex">
		    	<cfif NOT structIsEmpty(Group)>
			        <cfset Ordering['Air#GroupIndex#'] = Group.DepartureTime>
			    </cfif>
		    </cfloop>
		</cfif>
		<!--- <cfif Itinerary.RailSelected>
		    <cfloop collection="#Itinerary.Rail#" item="local.Group" index="local.GroupIndex">
		    	<cfif NOT structIsEmpty(Group)>
			        <cfset Ordering['Rail#GroupIndex#'] = Group.DepartureTime>
			    </cfif>
		    </cfloop>
		</cfif> --->
		<cfif Itinerary.HotelSelected AND isDate(Itinerary.Hotel.getCheckIn())>
		    <cfset Ordering['Hotel'] = createDateTime(year(Itinerary.Hotel.getCheckIn()), month(Itinerary.Hotel.getCheckIn()), day(Itinerary.Hotel.getCheckIn()), 23, 59)>
		</cfif>
		<cfif Itinerary.CarSelected AND isDate(Itinerary.Car.getPickUpDateTime())>
		    <cfset Ordering['Car'] = Itinerary.Car.getPickUpDateTime()>
		</cfif>
		<cfset Itinerary.Order = structSort(Ordering)>

		<cfreturn Itinerary />
 	</cffunction>

</cfcomponent>