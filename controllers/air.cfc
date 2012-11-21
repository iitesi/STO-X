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

		<cfif NOT StructKeyExists(session.searches, rc.Search_ID)>
			<cfset variables.fw.redirect('main?Search_ID=#rc.Search_ID#')>
		</cfif>
		<!--- Clear out results if it needs to be reloaded. --->
		<cfif StructKeyExists(rc, 'bReloadAir')>
			<cfset session.searches[rc.Search_ID].stTrips = {}>
			<cfset session.searches[rc.Search_ID].stAvailTrips[0] = {}>
			<cfset session.searches[rc.Search_ID].stAvailTrips[1] = {}>
			<cfset session.searches[rc.Search_ID].stAvailTrips[2] = {}>
			<cfset session.searches[rc.Search_ID].stAvailTrips[3] = {}>
			<cfset session.searches[rc.Search_ID].AvailDetails.stGroups = {}>
			<cfset session.searches[rc.Search_ID].FareDetails = {}>
			<cfset session.searches[rc.Search_ID].FareDetails.stPricing = {}>
		</cfif>
		<cfset rc.nSearchID = rc.Search_ID>
		
		<cfreturn />
	</cffunction>

<!---
lowfare
--->
	<cffunction name="lowfare" output="false">
		<cfargument name="rc">

		<!--- init objects --->
		<cfset variables.fw.service('uapi.init', 'objUAPI')>
		<cfset variables.fw.service('airparse.init', 'objAirParse')>
		<!--- Do the search. --->
		<cfset variables.fw.service('lowfare.doLowFare', 'void')>
				
		<cfreturn />
	</cffunction>
	
<!---
availability
--->
	<cffunction name="availability" output="true">
		<cfargument name="rc">
		
		<!--- Move needed variables into the rc scope. --->
		<cfset rc.nGroup = url.Group>
		<!--- init objects --->
		<cfset variables.fw.service('uapi.init', 'objUAPI')>
		<cfset variables.fw.service('airparse.init', 'objAirParse')>
		<!--- Do the search. --->
		<cfset variables.fw.service('airavailability.doAirAvailability', 'void')>
		
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
		<!--- Not used in production.  Just a wrapper to test the ajax call for pricing one itinerary. --->
		
		<cfset rc.Search_ID = rc.nSearchID>
		<cfset variables.fw.service('airprice.doAirPriceTesting', 'void')>
		
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
		<cfset rc.nUserID = session.searches[rc.nSearchID].Profile_ID>
		<cfset variables.fw.service('general.getUser', 'qProfile')>
		
		<cfreturn />
	</cffunction>
	
</cfcomponent>