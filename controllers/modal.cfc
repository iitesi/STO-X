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
default
--->
	<cffunction name="default" output="false">
		<cfargument name="rc">

		<!--- <cfif structKeyExists(arguments.rc, 'Filter') AND IsObject(arguments.rc.Filter)>
			<cfif arguments.rc.Filter.getAir()
			AND NOT StructKeyExists(session.searches[arguments.rc.SearchID].stItinerary, 'Air')>
				<cfset variables.fw.redirect('air.lowfare?SearchID=#arguments.rc.SearchID#')>
			</cfif>
			<cfif arguments.rc.Filter.getHotel()
			AND NOT StructKeyExists(session.searches[arguments.rc.SearchID].stItinerary, 'Hotel')>
				<cfset variables.fw.redirect('hotel.search?SearchID=#arguments.rc.SearchID#')>
			</cfif>
			<cfif arguments.rc.Filter.getCar()
			AND NOT StructKeyExists(session.searches[arguments.rc.SearchID].stItinerary, 'Car')>
				<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.SearchID#')>
			</cfif>
			<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.SearchID#')>
		</cfif> --->

		<cfreturn />
	</cffunction>
	
</cfcomponent>