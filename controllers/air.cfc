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
			<cfset session.searches[rc.nSearchID].stAvailDetails.stSortSegments[0] = []><!--- Sorting information by group --->
			<cfset session.searches[rc.nSearchID].stAvailDetails.stSortSegments[1] = []>
			<cfset session.searches[rc.nSearchID].stAvailDetails.stSortSegments[2] = []>
			<cfset session.searches[rc.nSearchID].stAvailDetails.stSortSegments[3] = []>
		</cfif>

		
		<cfreturn />
	</cffunction>

<!---
lowfare
--->
	<cffunction name="lowfare" output="false">
		<cfargument name="rc">

			<!--- Throw out a thread for availability --->
			<cfset variables.fw.service('airavailability.threadAvailability', 'void')>	
			<!--- Do the low fare search. --->
			<cfset variables.fw.service('lowfare.threadLowFare', 'void')>

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
		
		<cfif structKeyExists(rc, 'bSelect')>
			<cfloop collection="#session.searches[rc.nSearchID].stLegs#" item="local.nLeg">
				<cfdump eval=session.searches[rc.nSearchID].stSelected[nLeg]>
				<cfif structIsEmpty(session.searches[rc.nSearchID].stSelected[nLeg])>
					<cfset variables.fw.redirect('air.availability?Search_ID=#rc.nSearchID#&nGroup=#nLeg#')>
				</cfif>
			</cfloop>
			<cfset variables.fw.redirect('air.price?Search_ID=#rc.nSearchID#')>
		</cfif>

		<cfreturn />
	</cffunction>
	
<!---
seatmap
--->
	<cffunction name="seatmap" output="true">
		<cfargument name="rc">
		
		<!--- Move needed variables into the rc scope. --->
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

<!---
details
--->
	<cffunction name="details" output="false">
		<cfargument name="rc">
		<!--- No logic needed here. --->

		<cfreturn />
	</cffunction>

<!---
baggage
--->
	<cffunction name="baggage" output="false">
		<cfargument name="rc">

		<cfset variables.fw.service('baggage.baggage', 'qBaggage')>
		
		<cfreturn />
	</cffunction>

<!---
email
--->
	<cffunction name="email" output="false">
		<cfargument name="rc">

		<cfif StructKeyExists(form, 'bSubmit')>
			<cfset variables.fw.service('email.email', 'void')>
		</cfif>
		<cfset rc.nUserID = session.User_ID>
		<cfset variables.fw.service('general.getUser', 'qUser')>
		<cfset rc.nUserID = session.searches[rc.nSearchID].nProfileID>
		<cfset variables.fw.service('general.getUser', 'qProfile')>
		
		<cfreturn />
	</cffunction>
	
</cfcomponent>