<cfcomponent output="false">
	<cffunction name="init" returntype="any" access="public" output="false" hint="I initialize this component">
		<cfreturn this />
	</cffunction>

	<cffunction name="getOOPReason" returntype="string" access="public" output="false" hint="I return the description for the out-of-policy reason">
		<cfargument name="fareSavingsCode" type="string" required="true" />
		
		<cfquery name="local.qOutOfPolicy" datasource="Corporate_Production">
			SELECT Description
			FROM FareSavingsCode
			WHERE FareSavingsCode = <cfqueryparam value="#arguments.fareSavingsCode#" cfsqltype="cf_sql_varchar" />
		</cfquery>

		<cfreturn qOutOfPolicy.Description />
	</cffunction>
</cfcomponent>