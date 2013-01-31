<cfcomponent output="false">
	
<!--- init --->
	<cffunction name="init" output="false">
		<cfreturn this>
	</cffunction>


<!--- checkCarPolicy --->
	<cffunction name="checkCarPolicy" output="false">
		<cfargument name="stCars">
		<cfargument name="SearchID">
		<cfargument name="stPolicy">
		<cfargument name="stAccount">
		
		<cfset local.stCars = arguments.stCars>
		<cfset local.aPolicy = {}>
		<cfset local.bActive = 1>
		<cfset local.bBlacklisted = (ArrayLen(arguments.stAccount.aNonPolicyCar) GT 0 ? 1 : 0)>
		
		<cfquery name="local.getsearch" datasource="book">
		SELECT Depart_DateTime, Arrival_DateTime
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.SearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<cfset local.nDays = DateDiff('d', getsearch.Depart_DateTime, getSearch.Arrival_DateTime)>
		
		<cfloop collection="#stCars#" item="local.sCategory">
			<cfloop collection="#stCars[sCategory]#" item="local.sVendor">
				<cfset aPolicy = []>
				<cfset bActive = 1>
				<!--- Out of policy if they cannot book non preferred vendors. --->
				<cfif arguments.stPolicy.Policy_CarPrefRule EQ 1
				AND NOT ArrayFindNoCase(arguments.stAccount.aPreferredCar, sVendor)>
					<cfset ArrayAppend(aPolicy, 'Not a preferred vendor')>
					<cfif arguments.stPolicy.Policy_CarPrefDisp EQ 1>
						<cfset bActive = 0>
					</cfif>
				</cfif>
				<!--- Out of policy if the car type is not allowed.  --->
				<cfif arguments.stPolicy.Policy_CarTypeRule EQ 1
				AND NOT ArrayFindNoCase(arguments.stPolicy.aCarSizes, sCategory)>
					<cfset ArrayAppend(aPolicy, 'Car type not preferred')>
					<cfif arguments.stPolicy.Policy_CarPrefDisp EQ 1>
						<cfset bActive = 0>
					</cfif>
				</cfif>
				<!--- Out of policy if the car vendor is blacklisted (still shows though).  --->
				<cfif bBlacklisted
				AND ArrayFindNoCase(arguments.stAccount.aNonPolicyCar, sVendor)>
					<cfset ArrayAppend(aPolicy, 'Out of policy vendor')>
				</cfif>
				<cfif bActive EQ 1>
					<cfset stCars[sCategory][sVendor].Policy = (ArrayIsEmpty(aPolicy) ? 1 : 0)>
					<cfset stCars[sCategory][sVendor].aPolicies = aPolicy>
				<cfelse>
					<cfset temp = StructDelete(stCars[sCategory], sVendor)>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn stCars/>
	</cffunction>
		
</cfcomponent>