<cfcomponent output="false">
	
<!--- air : policy --->
	<cffunction name="policy" output="true" returntype="void">
		
		<cfset local.aPolicies = ['lowfare', 'maxfare']>
		<cfset local.nLowPadding = 100>
		<cfloop collection="#session.stTrips#" item="local.sTrip">
			<cfset local.stTemp = session.stTrips[sTrip]>
			<cfset stTemp.Policy = {Valid : true, Message : ''}>
			<cfloop array="#aPolicies#" index="sPolicy">
				<cfset stPolicyResult = this[sPolicy](stTemp)>
				<cfset stTemp.Policy.Valid = stTemp.Policy.Valid AND stPolicyResult.Valid>
				<cfset stTemp.Policy.Message = stPolicyResult.Message>
			</cfloop>
		</cfloop>
		
		<cfreturn />
	</cffunction>

<!--- air : lowfare --->
	<cffunction name="lowfare" output="true" returntype="struct">
		<cfargument name="stTemp" required="true" > 
		
		<cfset local.nLowPadding = 100>
		<cfset local.stRet = {
			Valid	:	stTemp.Total LTE (nLowPadding + session.nLowFare)
		}>
		<cfset stRet.Message = stRet.Valid ? '' : 'Not the lowest fare'>
		
		<cfreturn stRet>
	</cffunction>
	
<!--- air : maxfare --->
	<cffunction name="maxfare" output="true" returntype="struct">
		<cfargument name="stTemp" required="true" > 
		
		<cfset local.nLowPadding = 100>
		<cfset local.stRet = {
			Valid	:	stTemp.Total LTE (nLowPadding + session.nLowFare)
		}>
		<cfset stRet.Message = stRet.Valid ? '' : 'Maximum fare'>
		
		<cfreturn stRet>
	</cffunction>
	
	<!--- airfare : sortFare --->
	<cffunction name="sortFare" returntype="struct" output="false">
					
		<cfreturn StructSort(session.stTrips, 'numeric', 'asc', 'Total' )/>
	</cffunction>
			
</cfcomponent>