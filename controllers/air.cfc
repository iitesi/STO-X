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

	    <cfif NOT structKeyExists(rc, 'bSelect')>
			<!--- Throw out a thread for availability --->
			<cfset fw.getBeanFactory().getBean('airavailability').threadAvailability(argumentcollection=arguments.rc)>
			<!--- Do the low fare search. --->
			<cfset fw.getBeanFactory().getBean('lowfare').threadLowFare(argumentcollection=arguments.rc)>
		<cfelse>
			<!--- Select --->
            <cfset fw.getBeanFactory().getBean('lowfare').selectAir(argumentcollection=arguments.rc)>
		</cfif>

		<cfreturn />
	</cffunction>
	<cffunction name="endlowfare" output="false">
		<cfargument name="Filter">
		<cfargument name="bSelect">

		<cfif structKeyExists(arguments, 'bSelect')>
			<cfif arguments.Filter.getHotel()
			AND NOT StructKeyExists(session.searches[arguments.Filter.getSearchID()].stItinerary, 'Hotel')>
				<cfset variables.fw.redirect('hotel.search?Search_ID=#arguments.Filter.getSearchID()#')>
			</cfif>
			<cfif arguments.Filter.getCar()
			AND NOT StructKeyExists(session.searches[arguments.Filter.getSearchID()].stItinerary, 'Car')>
				<cfset variables.fw.redirect('car.availability?Search_ID=#arguments.Filter.getSearchID()#')>
			</cfif>
			<cfset variables.fw.redirect('summary?Search_ID=#arguments.Filter.getSearchID()#')>
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
			<cfset fw.getBeanFactory().getBean('lowfare').threadLowFare(argumentcollection=arguments.rc)>
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
			<cfset rc.UserID = session.searches[rc.nSearchID].ProfileID>
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