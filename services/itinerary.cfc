<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cffunction name="init" output="false" hint="Init method.">

		<cfreturn this />
	</cffunction>

	<cffunction name="selectAir" output="false">
		<cfargument name="form" required="true">
		<cfargument name="stSelected" required="true">
		<cfargument name="Group" required="false" default="">
		<cfargument name="Groups" required="false" default="">

		<cfset var form = arguments.form>
		<cfset var stSelected = arguments.stSelected>
		<cfset var Group = arguments.Group>
		<cfset var Groups = arguments.Groups>

		<cfset var Air = {}>

		<cfset Air = deserializeJSON(form.Segment)>
		<cfloop list="#arguments.form.fieldnames#" index="local.fieldname">
			<cfif fieldname NEQ 'fieldnames'
				AND fieldname NEQ 'Segment'>
				<cfset Air[fieldname] = arguments.form[fieldname]>
			</cfif>
		</cfloop>
		<cfset stSelected[Group] = Air>
		<cfloop from="0" to="#arguments.Groups-1#" index="local.Count">
			<cfif Count GT Group>
				<cfset stSelected[Count] = {}>
			</cfif>
		</cfloop>
		<!--- <cfset stSelected = orderItinerary(stSelected)> --->

		<cfreturn stSelected />
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