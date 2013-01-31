<cfcomponent>

	<cfset variables.fw = '' />
	<cffunction name="init" output="false" returntype="any">
		<cfargument name="fw" />

		<cfset variables.fw = arguments.fw />
		
		<cfreturn this />
	</cffunction>
	
<!--- search --->
	<cffunction name="search" output="false">
		<cfargument name="rc">

		<cfif NOT structKeyExists(arguments.rc, 'bSelect')>
			<cfset variables.fw.service('hotelsearch.doHotelSearch', 'void') />
		<cfelse>
			<!--- Select --->
			<cfset variables.fw.service('hotelsearch.selectHotel', 'void')>
		</cfif>
				
		<cfreturn />
	</cffunction>
	<cffunction name="endsearch" output="false">
		<cfargument name="rc">

		<cfif structKeyExists(arguments.rc, 'bSelect')>
			<cfif arguments.rc.Filter.getCar()
			AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Car')>
				<cfset variables.fw.redirect('car.availability?Search_ID=#arguments.rc.Filter.getSearchID()#')>
			</cfif>
			<cfset variables.fw.redirect('summary?Search_ID=#arguments.rc.Filter.getSearchID()#')>
		</cfif>

		<cfreturn />
	</cffunction>
	
<!--- skip --->
	<cffunction name="skip" output="false">
		<cfargument name="rc" />
		
		<cfset variables.fw.service('hotelsearch.skipHotel', 'void')>
				
		<cfreturn />
	</cffunction>
	<cffunction name="endskip" output="false">
		<cfargument name="rc">

		<cfif arguments.rc.Filter.getCar()
		AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Car')>
			<cfset variables.fw.redirect('car.availability?Search_ID=#arguments.rc.Filter.getSearchID()#')>
		</cfif>
		<cfset variables.fw.redirect('summary?Search_ID=#arguments.rc.Filter.getSearchID()#')>

		<cfreturn />
	</cffunction>

<!---
popup
--->	
	<cffunction name="popup" output="true">
		<cfargument name="rc">
		
		<cfset rc.bSuppress = 1>
		
		<cfreturn />
	</cffunction>
	
</cfcomponent>