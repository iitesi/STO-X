<cfcomponent hint="Converter">

	<cffunction name="init" access="public" output="false">
		<cfreturn this>
	</cffunction>

	<cffunction name="fromGMTStringToDateObj" access="public" output="false" returnType="date">
		<cfargument name="date" type="string" required="true">

		<cfset local.formatter = CreateObject("java", "java.text.SimpleDateFormat")>
	  <cfset local.formatter.init("yyyy-MM-dd'T'HH:mm:ssX")>
	  <cfset local.parsePosition = CreateObject("java", "java.text.ParsePosition")>
	  <cfset local.parsePosition.init(0)>
	  <cfset local.result = formatter.parse(arguments.date, parsePosition)>
		<cfreturn local.result>

	</cffunction>

</cfcomponent>
