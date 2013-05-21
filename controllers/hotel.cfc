<cfcomponent>

<!--- init --->
	<cfset variables.fw = ''>
	<cffunction name="init" output="false">
		<cfargument name="fw">

		<cfset variables.fw = arguments.fw>

		<cfreturn this>
	</cffunction>

<!--- default --->
	<cffunction name="default" output="false">
		<cfargument name="rc">

        <cfset fw.getBeanFactory().getBean('hotelsearch').doHotelSearch(argumentcollection=arguments.rc)>

		<cfreturn />
	</cffunction>

<!--- before --->
	<cffunction name="before" output="false">
		<cfargument name="rc">

		<cfset fw.getBeanFactory().getBean('car').doAvailability(argumentcollection=arguments.rc)>

		<cfreturn />
	</cffunction>
	
<!--- search --->
	<cffunction name="search" output="false">
		<cfargument name="rc">

		<!---
		<cfif NOT structKeyExists(arguments.rc, 'bSelect')>
            <cfset arguments.rc.Search = fw.getBeanFactory().getBean( "SearchService" ).load( arguments.rc.searchId ) />
			<cfset arguments.rc.hotels = fw.getBeanFactory().getBean( "HotelSearchManager").doHotelSearch( argumentCollection=arguments.rc ) />
		<cfelse>
			<!--- Select --->
			<cfset variables.fw.service('hotelsearch.selectHotel', 'void')>
		</cfif>
		--->
		<cfreturn />
	</cffunction>

<!--- endsearch --->
	<cffunction name="endsearch" output="false">
		<cfargument name="rc">

		<cfif structKeyExists(arguments.rc, 'bSelect')>
			<cfif arguments.rc.Filter.getCar() AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Car')>
				<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.Filter.getSearchID()#')>
			</cfif>
			<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>
		</cfif>

		<cfreturn />
	</cffunction>
	
<!--- skip --->
	<cffunction name="skip" output="false">
		<cfargument name="rc" />
		
		<cfset variables.fw.service('hotelsearch.skipHotel', 'void')>
				
		<cfreturn />
	</cffunction>

<!--- endskip --->
	<cffunction name="endskip" output="false">
		<cfargument name="rc">

		<cfif arguments.rc.Filter.getCar() AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Car')>
			<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.Filter.getSearchID()#')>
		</cfif>
		<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>

		<cfreturn />
	</cffunction>

<!--- popup --->	
	<cffunction name="popup" output="true">
		<cfargument name="rc">
		
		<cfset rc.bSuppress = 1>
		
		<cfreturn />
	</cffunction>
	
</cfcomponent>