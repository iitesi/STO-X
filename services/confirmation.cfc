<cfcomponent output="false">
	<cffunction name="init" returntype="any" access="public" output="false" hint="I initialize this component">
		<cfreturn this />
	</cffunction>

	<cffunction name="getOOPReason" returntype="string" access="public" output="false" hint="I return the description for the out-of-policy reason">
		<cfargument name="fareSavingsCode" type="string" required="true" />
		<cfargument name="acctID" type="numeric" required="true" />
		<cfargument name="tmcID" type="numeric" required="false" default="1" />
		
		<cfquery name="local.qOutOfPolicy" datasource="Corporate_Production">
			SELECT Description
			FROM FareSavingsCode
			WHERE STO = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
				AND FareSavingsCode = <cfqueryparam value="#arguments.fareSavingsCode#" cfsqltype="cf_sql_varchar" />
				<!--- Short's/Internal TMC --->
				<cfif listFind('1,2', arguments.tmcID)>
					AND TMCID = <cfqueryparam value="1" cfsqltype="cf_sql_integer" />
					<!--- State of Texas, NASCAR --->
					<cfif listFind('235,348', arguments.acctID)>
						AND Acct_ID = <cfqueryparam value="#arguments.acctID#" cfsqltype="cf_sql_integer" />
					<cfelse>
						AND Acct_ID IS NULL
					</cfif>
				<!--- External TMC --->
				<cfelse>
					AND TMCID = <cfqueryparam value="#arguments.tmcID#" cfsqltype="cf_sql_integer" />
				</cfif>
		</cfquery>

		<cfreturn qOutOfPolicy.Description />
	</cffunction>
</cfcomponent>