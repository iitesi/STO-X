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
lowfare
--->
	<cffunction name="lowfare" output="false">
		<cfargument name="rc">

	    <cfif NOT structKeyExists(arguments.rc, 'bSelect')>
			<!--- Throw out a thread for availability --->
			<!---<cfset fw.getBeanFactory().getBean('airavailability').threadAvailability(argumentcollection=arguments.rc)>--->
			<!--- Do the low fare search. --->
			<cfset rc.stPricing = session.searches[arguments.rc.SearchID].stLowFareDetails.stPricing>
			<cfset fw.getBeanFactory().getBean('lowfare').threadLowFare(argumentcollection=arguments.rc)>
		<cfelse>
			<!--- Select --->
            <cfset fw.getBeanFactory().getBean('lowfare').selectAir(argumentcollection=arguments.rc)>
		</cfif>

		<cfreturn />
	</cffunction>
	<cffunction name="endlowfare" output="false">
		<cfargument name="rc">

		<cfif structKeyExists(arguments.rc, 'bSelect')>
			<cfif arguments.rc.Filter.getHotel()
			AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Hotel')>
				<cfset variables.fw.redirect('hotel.search?SearchID=#arguments.rc.Filter.getSearchID()#')>
			</cfif>
			<cfif arguments.rc.Filter.getCar()
			AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Car')>
				<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.Filter.getSearchID()#')>
			</cfif>
			<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>
		</cfif>

		<cfreturn />
	</cffunction>
	
<!---
availability
--->
	<cffunction name="availability" output="true">
		<cfargument name="rc">
		
		<cfif NOT structKeyExists(arguments.rc, 'bSelect')>
			<cfset arguments.rc.sPriority = 'LOW'>
			<!--- Throw out a thread for low fare --->
			<!---<cfset rc.stPricing = session.searches[arguments.rc.SearchID].stLowFareDetails.stPricing>
			<cfset fw.getBeanFactory().getBean('lowfare').threadLowFare(argumentcollection=arguments.rc)>--->
			<!--- Do the availability search. --->
			<cfset fw.getBeanFactory().getBean('airavailability').threadAvailability(argumentcollection=arguments.rc)>
		<cfelse>
			<!--- Select --->
			<cfset fw.getBeanFactory().getBean('airavailability').selectLeg(argumentcollection=arguments.rc)>
		</cfif>

		<cfreturn />
	</cffunction>
	<cffunction name="endavailability" output="true">
		<cfargument name="rc">

		<cfif structKeyExists(arguments.rc, 'bSelect')>
			<cfloop collection="#session.searches[arguments.rc.SearchID].Legs#" item="local.nLeg">
				<cfif structIsEmpty(session.searches[arguments.rc.SearchID].stSelected[nLeg])>
					<cfset variables.fw.redirect('air.availability?SearchID=#arguments.rc.SearchID#&nGroup=#nLeg#')>
				</cfif>
			</cfloop>
			<cfset variables.fw.redirect('air.price?SearchID=#arguments.rc.SearchID#')>
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
			<cfparam name="rc.bSelection" default="0">
			<!--- init objects --->
			<cfset variables.fw.service('uapi.init', 'objUAPI')>
			<!--- Do the search. --->
			<cfset variables.fw.service('seatmap.doSeatMap', 'stSeats')>
		<cfelseif rc.sDetails EQ 'details'>
			<!--- do nothing --->
		<cfelseif rc.sDetails EQ 'baggage'>
			<cfset variables.fw.service('baggage.baggage', 'qBaggage')>
		<cfelseif rc.sDetails EQ 'email'>
			<cfset rc.UserID = session.User_ID>
			<cfset variables.fw.service('general.getUser', 'qUser')>
			<cfset rc.UserID = session.searches[rc.SearchID].ProfileID>
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

		<cfset variables.fw.redirect('air.lowfare?SearchID=#arguments.rc.SearchID#')>

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
		
		<cfset variables.fw.redirect('air.lowfare?SearchID=#rc.SearchID#&filter=all')>

		<cfreturn />
	</cffunction>
	
</cfcomponent>