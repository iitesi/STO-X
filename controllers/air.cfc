<cfcomponent>

<!---
init
--->
	<cfset variables.fw = ''>
	<cffunction name="init" output="false">
		<cfargument name="fw">

		<cfset variables.fw = arguments.fw>

		<cfreturn this>
	</cffunction>
	
<!---
before - do this before any air calls
--->
	<cffunction name="before" output="false">
		<cfargument name="rc">

		<cfif NOT StructKeyExists(session.searches, rc.nSearchID)>
			<cfset variables.fw.redirect('main?Search_ID=#rc.nSearchID#')>
		</cfif>
		<!--- Clear out results if it needs to be reloaded. --->
		<cfif StructKeyExists(rc, 'bReloadAir')>
			<!--- Air - low fare search --->
			<cfset session.searches[rc.nSearchID].stTrips = {}>
			<cfset session.searches[rc.nSearchID].stLowFareDetails = {}>
			<cfset session.searches[rc.nSearchID].stLowFareDetails.aCarriers = {}>
			<cfset session.searches[rc.nSearchID].stLowFareDetails.stPricing = {}>
			<cfset session.searches[rc.nSearchID].stLowFareDetails.stResults = {}>
			<cfset session.searches[rc.nSearchID].stLowFareDetails.stPriced = {}>
			<cfset session.searches[rc.nSearchID].stLowFareDetails.aSortArrival = []>
			<cfset session.searches[rc.nSearchID].stLowFareDetails.aSortBag = []>
			<cfset session.searches[rc.nSearchID].stLowFareDetails.aSortDepart = []>
			<cfset session.searches[rc.nSearchID].stLowFareDetails.aSortDuration = []>
			<cfset session.searches[rc.nSearchID].stLowFareDetails.aSortFare = []>
			<!--- Air - availability search --->
			<cfset session.searches[rc.nSearchID].stAvailTrips = {}>
			<cfset session.searches[rc.nSearchID].stSelected = StructNew('linked')><!--- Place holder for selected legs --->
			<cfset session.searches[rc.nSearchID].stSelected[0] = {}>
			<cfset session.searches[rc.nSearchID].stSelected[1] = {}>
			<cfset session.searches[rc.nSearchID].stSelected[2] = {}>
			<cfset session.searches[rc.nSearchID].stSelected[3] = {}>
			<cfset session.searches[rc.nSearchID].stAvailTrips[0] = {}><!--- Leg details by group --->
			<cfset session.searches[rc.nSearchID].stAvailTrips[1] = {}>
			<cfset session.searches[rc.nSearchID].stAvailTrips[2] = {}>
			<cfset session.searches[rc.nSearchID].stAvailTrips[3] = {}>
			<cfset session.searches[rc.nSearchID].stAvailDetails.stGroups = {}>
		</cfif>

		
		<cfreturn />
	</cffunction>

<!---
lowfare
--->
	<cffunction name="lowfare" output="false">
		<cfargument name="rc">

		<cfif NOT structKeyExists(rc, 'bSelect')>
			<!--- Throw out a thread for availability --->
			<cfset variables.fw.service('airavailability.threadAvailability', 'void')>
			<!--- Do the low fare search. --->
			<cfset variables.fw.service('lowfare.threadLowFare', 'void')>		
		<cfelse>
			<!--- Select --->
			<cfset variables.fw.service('lowfare.selectAir', 'void')>
		</cfif>

		<cfreturn />
	</cffunction>
	<cffunction name="endlowfare" output="false">
		<cfargument name="rc">

		<cfif structKeyExists(arguments.rc, 'bSelect')>
			<cfif session.searches[arguments.rc.Search_ID].bHotel
			AND NOT StructKeyExists(session.searches[arguments.rc.Search_ID].stItinerary, 'Hotel')>
				<cfset variables.fw.redirect('hotel.search?Search_ID=#arguments.rc.Search_ID#')>
			</cfif>
			<cfif session.searches[arguments.rc.Search_ID].bCar
			AND NOT StructKeyExists(session.searches[arguments.rc.Search_ID].stItinerary, 'Car')>
				<cfset variables.fw.redirect('car.availability?Search_ID=#arguments.rc.Search_ID#')>
			</cfif>
			<cfset variables.fw.redirect('summary?Search_ID=#arguments.rc.Search_ID#')>
		</cfif>

		<cfreturn />
	</cffunction>
	
<!---
availability
--->
	<cffunction name="availability" output="true">
		<cfargument name="rc">
		
		<cfif NOT structKeyExists(rc, 'bSelect')>
			<cfset rc.sPriority = 'LOW'>
			<!--- Throw out a thread for low fare --->
			<cfset variables.fw.service('lowfare.threadLowFare', 'void')>
			<!--- Do the availability search. --->
			<cfset variables.fw.service('airavailability.threadAvailability', 'void')>			
		<cfelse>
			<!--- Select --->
			<cfset variables.fw.service('airavailability.selectLeg', 'void')>
		</cfif>

		<cfreturn />
	</cffunction>
	<cffunction name="endavailability" output="true">
		<cfargument name="rc">

		<cfif structKeyExists(arguments.rc, 'bSelect')>
			<cfloop collection="#session.searches[arguments.rc.Search_ID].stLegs#" item="local.nLeg">
				<cfif structIsEmpty(session.searches[arguments.rc.Search_ID].stSelected[nLeg])>
					<cfset variables.fw.redirect('air.availability?Search_ID=#arguments.rc.Search_ID#&nGroup=#nLeg#')>
				</cfif>
			</cfloop>
			<cfset variables.fw.redirect('air.price?Search_ID=#arguments.rc.Search_ID#')>
		</cfif>

		<cfreturn />
	</cffunction>

<!---
popup
--->	
	<cffunction name="popup" output="true">
		<cfargument name="rc">
		
		<cfset rc.bSuppress = 1>
		<cfif rc.sDetails EQ 'seatmap'>
			<!--- Move needed variables into the rc scope. --->
			<cfset rc.sCabin = 'Y'>
			<cfset rc.nTripID = url.nTripID>
			<cfif structKeyExists(url, "nSegment")>
				<cfset rc.nSegment = url.nSegment>
			</cfif>
			<cfif structKeyExists(url, "nGroup")>
				<cfset rc.nGroup = url.nGroup>
			<cfelse>
				<cfset rc.nGroup = ''>
			</cfif>
			<!--- init objects --->
			<cfset variables.fw.service('uapi.init', 'objUAPI')>
			<!--- Do the search. --->
			<cfset variables.fw.service('seatmap.doSeatMap', 'stSeats')>
		<cfelseif rc.sDetails EQ 'details'>
			<!--- do nothing --->
		<cfelseif rc.sDetails EQ 'baggage'>
			<cfset variables.fw.service('baggage.baggage', 'qBaggage')>
		<cfelseif rc.sDetails EQ 'email'>
			<cfset rc.nUserID = session.User_ID>
			<cfset variables.fw.service('general.getUser', 'qUser')>
			<cfset rc.nUserID = session.searches[rc.nSearchID].nProfileID>
			<cfset variables.fw.service('general.getUser', 'qProfile')>
		</cfif>
		
		<cfreturn />
	</cffunction>
	
<!---
seatmap
--->
	<cffunction name="seatmap" output="true">
		<cfargument name="rc">
		
		<!--- Move needed variables into the rc scope. --->
		<cfset rc.bSuppress = 1>
		<cfset rc.sCabin = 'Y'>
		<cfset rc.nTripID = url.nTripID>
		<cfset rc.nSegment = url.nSegment>
		<cfif structKeyExists(url, "nGroup")>
			<cfset rc.nGroup = url.nGroup>
		<cfelse>
			<cfset rc.nGroup = ''>
		</cfif>
		<!--- init objects --->
		<cfset variables.fw.service('uapi.init', 'objUAPI')>
		<!--- Do the search. --->
		<cfset variables.fw.service('seatmap.doSeatMap', 'stSeats')>
		
		<cfreturn />
	</cffunction>
	
<!---
email
--->
	<cffunction name="email" output="true">
		<cfargument name="rc">
		
		<cfset rc.bSuppress = 1>
		<cfset variables.fw.service('email.email', 'void')>
		
		<cfreturn />
	</cffunction>
	<cffunction name="endemail" output="true">
		<cfargument name="rc">

		<cfset variables.fw.redirect('air.lowfare?Search_ID=#arguments.rc.Search_ID#')>

		<cfreturn />
	</cffunction>

<!---
price
--->
	<cffunction name="price" output="false">
		<cfargument name="rc">
		
		<!--- Do the pricing --->
		<cfset variables.fw.service('airprice.doAirPrice', 'void')>
		
		<cfreturn />
	</cffunction>
	<cffunction name="endprice" output="true">
		<cfargument name="rc">
		
		<cfset variables.fw.redirect('air.lowfare?Search_ID=#rc.nSearchID#&filter=all')>

		<cfreturn />
	</cffunction>
	
</cfcomponent>