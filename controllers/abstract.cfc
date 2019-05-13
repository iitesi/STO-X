<cfcomponent accessors="true" output="false" hint="I am extended by other controllers.">

	<cffunction name="init" output="false">
		<cfargument name="fw" required="true">

		<cfset variables.fw = arguments.fw>
		<cfset variables.bf = fw.getBeanFactory()>

		<cfreturn this>
	</cffunction>

	<cffunction name="before" hint="I run before anything else.">
		<cfargument name="rc" required="true">
		
		<cfif NOT structKeyExists(rc, "message")>
			<cfset rc.message = new booking.helpers.messages()>
		</cfif>

	</cffunction>

</cfcomponent>