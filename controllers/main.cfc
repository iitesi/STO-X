<cfcomponent extends="abstract" output="false">

	<cffunction name="default" output="false">
		<cfargument name="rc">
		
		<cfif structKeyExists(arguments.rc, 'Filter') AND IsObject(arguments.rc.Filter)>

			<cfif arguments.rc.Filter.getAir()>
				<cfset variables.fw.redirect('air?SearchID=#arguments.rc.SearchID#&group=0')>
			</cfif>

			<cfif arguments.rc.Filter.getHotel()>
				<cfset variables.fw.redirect('hotel.search?SearchID=#arguments.rc.SearchID#')>
			</cfif>

			<cfif arguments.rc.Filter.getCar()>
				<cfset variables.fw.redirect('car.availability?SearchID=#arguments.rc.SearchID#')>
			</cfif>

			<cfset variables.fw.redirect('summary?SearchID=#arguments.rc.SearchID#')>
		</cfif>

	</cffunction>

</cfcomponent>
