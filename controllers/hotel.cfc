<cfcomponent extends="abstract">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfreturn />
	</cffunction>

	<cffunction name="before" output="false">
		<cfargument name="rc">

		<cfset fw.getBeanFactory().getBean('car').doAvailability(argumentcollection=arguments.rc)>

		<cfreturn />
	</cffunction>

	<cffunction name="search" output="false">
		<cfargument name="rc">

		<cfreturn />
	</cffunction>

	<cffunction name="select">
		<cfargument name="rc" />

		<cfif arguments.rc.Filter.getCar() AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Car')>
			<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.Filter.getSearchID()#')>
		</cfif>
		<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>

	</cffunction>


	<cffunction name="skip" output="false">
		<cfargument name="rc" />

		<cfset variables.fw.service('hotelsearch.skipHotel', 'void')>

		<cfif arguments.rc.Filter.getCar() AND NOT StructKeyExists(session.searches[arguments.rc.Filter.getSearchID()].stItinerary, 'Car')>
			<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.Filter.getSearchID()#')>
		</cfif>
		<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.Filter.getSearchID()#')>

		<cfreturn />
	</cffunction>

</cfcomponent>