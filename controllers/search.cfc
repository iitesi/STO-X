<cfcomponent>

	<cfset variables.fw = "">
	<cffunction name="init" output="false" returntype="any">
		<cfargument name="fw">
		<cfset variables.fw = arguments.fw>
		<cfreturn this>
	</cffunction>
	
<!--- before --->
	<cffunction name="before" output="false">
		<cfargument name="rc">
				
		<cfreturn />
	</cffunction>
	
<!--- addsearchrecord --->
	<cffunction name="addsearchrecord" output="false">
		<cfargument name="rc">
		
		<cfset variables.fw.service('search.addsearchrecord', 'void')>
				
		<cfreturn />
	</cffunction>
	
<!--- addsearchrecord --->
	<cffunction name="displaysearch" output="false">
		<cfargument name="rc">
				
		<cfreturn />
	</cffunction>
	
</cfcomponent>