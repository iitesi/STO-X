<cfcomponent extends="abstract">

<!---
default
--->
	<cffunction name="default" output="false">
		<cfargument name="rc">

		<!--- <cfif NOT structKeyExists(session.searches[rc.SearchID], 'stTravelers')>
			<cfset session.searches[rc.SearchID].stTravelers = {"1":{"Errors":{}},"2":{"Errors":{}},"3":{"Errors":{}},"4":{"Errors":{}}}>
		</cfif>
		<!--- <cfset session.searches[rc.SearchID].stTravelers = {"1":{},"2":{},"3":{},"4":{}}> --->

		<cfif structKeyExists(rc, 'btnConfirm')>
			<cfset variables.fw.service('summary.saveSummary', 'void')>
		</cfif>

		<cfset variables.fw.service('summary.determineFees', 'stFees')>

		<cfset variables.fw.service('summary.getOutOfPolicy', 'qOutOfPolicy')>

		<cfif session.AcctID EQ 235>
			<cfset variables.fw.service('summary.getTXExceptionCodes', 'qTXExceptionCodes')>
		</cfif> --->

		<cfreturn />
	</cffunction>

	<!--- <cffunction name="enddefault" output="false">
		<cfargument name="rc">

		<cfdump var="#session.searches[rc.SearchID].stTravelers#" abort>
		<cfabort>

		<cfreturn />
	</cffunction> --->

</cfcomponent>