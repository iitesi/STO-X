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
			<cfset session.searches[rc.Search_ID].stSegments = {}>
			<cfset session.searches[rc.Search_ID].stPricing = {}>
			<cfset session.searches[rc.Search_ID].stSortArrival = []>
			<cfset session.searches[rc.Search_ID].stSortBag = []>
			<cfset session.searches[rc.Search_ID].stSortDepart = []>
			<cfset session.searches[rc.Search_ID].stSortDuration = []>
			<cfset session.searches[rc.Search_ID].stSortFare = []>
			<cfset session.searches[rc.Search_ID].stCarriers = []>
			<cfset session.searches[rc.Search_ID].stAvailability = {}>
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
	
</cfcomponent>