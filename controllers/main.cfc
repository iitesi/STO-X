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
	<cffunction name="enddefault" output="false">
		<cfargument name="Filter">

		<cfif arguments.Filter.getAir()
		AND NOT StructKeyExists(session.searches[arguments.Filter.getSearchID()].stItinerary, 'Air')>
			<cfset variables.fw.redirect('air.lowfare?Search_ID=#arguments.Filter.getSearchID()#')>
		</cfif>
		<cfif arguments.Filter.getHotel()
		AND NOT StructKeyExists(session.searches[arguments.Filter.getSearchID()].stItinerary, 'Hotel')>
			<cfset variables.fw.redirect('hotel.search?Search_ID=#arguments.Filter.getSearchID()#')>
		</cfif>
		<cfif arguments.Filter.getCar()
		AND NOT StructKeyExists(session.searches[arguments.Filter.getSearchID()].stItinerary, 'Car')>
			<cfset variables.fw.redirect('car.availability?Search_ID=#arguments.Filter.getSearchID()#')>
		</cfif>
		<cfset variables.fw.redirect('summary?Search_ID=#arguments.Filter.getSearchID()#')>

		<cfreturn />
	</cffunction>
	
</cfcomponent>