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

	<!--- getOutOfPolicy_Hotel --->
	<cffunction name="getOutOfPolicy_Hotel" output="false" returntype="query">
		<cfargument name="hotelSavingsCode" type="string" required="true">
		<cfargument name="acctID" required="true" type="numeric">
		<cfargument name="tmcID" required="false" type="numeric" default="1">

		<cfquery name="local.qOutOfPolicy_Hotel" datasource="Corporate_Production">
			SELECT
				HotelSavingsCode,
				Description
			FROM
				HotelSavingsCode
			WHERE
				(STO = 1)
				AND (hotelSavingsCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fareSavingsCode#">)
				<cfif arguments.tmcID eq 1 or arguments.tmcID eq 2>
					AND (TMCID = 1)
					AND (acct_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.acctID#">)
				<cfelse>
					AND (TMCID = <cfqueryparam value="#arguments.tmcID#" cfsqltype="cf_sql_integer">)
				</cfif>
			ORDER BY
				HotelSavingsCode
		</cfquery>

		<cfif not local.qOutOfPolicy_Hotel.recordCount>
			<cfquery name="local.qOutOfPolicy_Hotel" datasource="Corporate_Production">
				SELECT
					HotelSavingsCode,
					Description
				FROM
					HotelSavingsCode
				WHERE
					(STO = 1)
					AND (hotelSavingsCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.hotelSavingsCode#">)
					<cfif arguments.tmcID eq 1 or arguments.tmcID eq 2>
						AND (TMCID = 1)
						AND (acct_ID IS NULL)
					<cfelse>
						AND (TMCID = <cfqueryparam value="#arguments.tmcID#" cfsqltype="cf_sql_integer">)
					</cfif>
				ORDER BY
					HotelSavingsCode
			</cfquery>
		</cfif>

		<cfreturn local.qOutOfPolicy_Hotel>
	</cffunction>

	<!--- getOutOfPolicy_Car --->
	<cffunction name="getOutOfPolicy_Car" output="false" returntype="query">
		<cfargument name="vehicleSavingsCode" type="string" required="true">
		<cfargument name="acctID" required="true" type="numeric">
		<cfargument name="tmcID" required="false" type="numeric" default="1">

		<cfquery name="local.qOutOfPolicy_Car" datasource="Corporate_Production">
			SELECT
				VehicleSavingsCode,
				Description
			FROM
				VehicleSavingsCode
			WHERE
				(STO = 1)
				<cfif arguments.tmcID eq 1 or arguments.tmcID eq 2>
					AND (TMCID = 1)
					AND (acct_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.acctID#">)
				<cfelse>
					AND (TMCID = <cfqueryparam value="#arguments.tmcID#" cfsqltype="cf_sql_integer">)
				</cfif>
			ORDER BY
				VehicleSavingsCode
		</cfquery>

		<cfif not local.qOutOfPolicy_Car.recordCount>
			<cfquery name="local.qOutOfPolicy_Car" datasource="Corporate_Production">
				SELECT
					VehicleSavingsCode,
					Description
				FROM
					VehicleSavingsCode
				WHERE
					(STO = 1)
					<cfif arguments.tmcID eq 1 or arguments.tmcID eq 2>
						AND (TMCID = 1)
						AND (acct_ID IS NULL)
					<cfelse>
						AND (TMCID = <cfqueryparam value="#arguments.tmcID#" cfsqltype="cf_sql_integer">)
					</cfif>
				ORDER BY
					VehicleSavingsCode
			</cfquery>
		</cfif>

		<cfreturn local.qOutOfPolicy_Car>
	</cffunction>
</cfcomponent>