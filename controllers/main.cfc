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
		<cfargument name="rc">

		<cfif session.searches[arguments.rc.Search_ID].bAir
		AND NOT StructKeyExists(session.searches[arguments.rc.Search_ID].stItinerary, 'Air')>
			<cfset variables.fw.redirect('air.lowfare?Search_ID=#arguments.rc.Search_ID#')>
		</cfif>
		<cfif session.searches[arguments.rc.Search_ID].bHotel
		AND NOT StructKeyExists(session.searches[arguments.rc.Search_ID].stItinerary, 'Hotel')>
			<cfset variables.fw.redirect('hotel.search?Search_ID=#arguments.rc.Search_ID#')>
		</cfif>
		<cfif session.searches[arguments.rc.Search_ID].bCar
		AND NOT StructKeyExists(session.searches[arguments.rc.Search_ID].stItinerary, 'Car')>
			<cfset variables.fw.redirect('car.availability?Search_ID=#arguments.rc.Search_ID#')>
		</cfif>
		<cfset variables.fw.redirect('summary?Search_ID=#arguments.rc.Search_ID#')>

		<cfreturn />
	</cffunction>
	
</cfcomponent>