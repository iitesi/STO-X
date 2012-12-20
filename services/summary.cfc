<cfcomponent output="false">
	
	<cffunction name="determinFees" access="remote" output="false">
		<cfargument name="Acct_ID" 		default="#session.Acct_ID#">
		<cfargument name="User_ID" 		default="#session.User_ID#">
		<cfargument name="stItinerary" 	default="#session.searches[url.Search_ID].stItinerary#">
		<cfargument name="sAirType"		default="#session.searches[url.Search_ID].sAirType#">
		
		<cfset local.stFees = {}>
		<cfset local.bAir = false>
		<cfset local.sFeeType = ''>
		<!--- Determine if an agent is booking for the traveler --->
		<cfquery name="local.qAgentSine" datasource="Corporate_Production">
		SELECT AccountID
		FROM Payroll_Users
		WHERE User_ID = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfif StructKeyExists(arguments.stItinerary, 'Air')>
			<cfset local.bAir = true>
			<cfif qAgentSine.AccountID EQ ''>
				<cfset sFeeType = 'ODOM'>
			<cfelse>
				<cfset sFeeType = 'DOM'>
			</cfif>
			<cfset local.stCities = {}>
			<cfset local.nSegments = 0>
			<cfloop collection="#arguments.stItinerary.Air.Groups#" item="local.nGroup">
				<cfloop collection="#arguments.stItinerary.Air.Groups[nGroup].Segments#" item="local.sSegment">
					<cfset stCities[arguments.stItinerary.Air.Groups[nGroup].Segments[sSegment].Origin] = ''>
					<cfset stCities[arguments.stItinerary.Air.Groups[nGroup].Segments[sSegment].Destination] = ''>
					<cfset nSegments++>
				</cfloop>
			</cfloop>
			<cfquery name="local.qSearch">
			SELECT Country_Code
			FROM lu_Geography
			WHERE Location_Code IN (<cfqueryparam value="#StructKeyList(stCities)#" cfsqltype="cf_sql_varchar">)
			AND Location_Type = <cfqueryparam value="125" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfloop query="qSearch">
				<cfif qSearch.Country_Code NEQ 'US'>
					<cfif qAgentSine.AccountID EQ ''>
						<cfset sFeeType = 'OINTL'>
					<cfelse>
						<cfset sFeeType = 'INTL'>
					</cfif>
				</cfif>
			</cfloop>
			<cfif (sFeeType EQ 'OINTL' OR sFeeType EQ 'INTL')
			AND (ArrayLen(arguments.stItinerary.Air.Carriers) GT 1
				OR arguments.sAirType EQ 'MD'
				OR nSegments GT 6)>
					<cfif qAgentSine.AccountID EQ ''>
						<cfset sFeeType = 'OINTLRD'>
					<cfelse>
						<cfset sFeeType = 'INTLRD'>
					</cfif>
			</cfif>
		<cfelse>
			<cfif qAgentSine.AccountID EQ ''>
				<cfset sFeeType = 'OAUX'>
			<cfelse>
				<cfset sFeeType = 'MAUX'>
			</cfif>
		</cfif>
		<cfquery name="local.qRequest" datasource="Corporate_Production">
		SELECT IsNull(Fee_Amount, 0) AS Fee_Amount
		FROM Account_Fees
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		AND Fee_Type = <cfqueryparam value="ORQST" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfquery name="local.qSpecificFee" datasource="Corporate_Production">
		SELECT IsNull(Fee_Amount, 0) AS Fee_Amount
		FROM Account_Fees
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		AND Fee_Type = <cfqueryparam value="#sFeeType#" cfsqltype="cf_sql_varchar">
		</cfquery>
<!--- TO DO : Traveler Count --->
		<cfset stFees.nRequestFee = qRequest.Fee_Amount>
		<cfset stFees.nSpecificFee = qSpecificFee.Fee_Amount>
		<cfset stFees.bComplex = (sFeeType NEQ 'OINTLRD' AND sFeeType NEQ 'INTLRD' ? false : true)>
		<cfset stFees.sAgent = qAgentSine.AccountID>
<!--- TO DO : Special requests --->
		<!--- <cfif bAir AND qAgentSine.AccountID EQ '' AND getAllTravelers.Special_Requests NEQ ''>
			<cfset Fee = RequestFee + Fee>
		</cfif> --->
		
		<cfreturn stFees />
	</cffunction>
	
	<cffunction name="getOutOfPolicy" output="false">
		<cfargument name="Acct_ID" default="#session.Acct_ID#">
		
		<cfquery name="local.qOutOfPolicy" datasource="Corporate_Production" cachedwithin="#CreateTimeSpan(30,0,0,0)#">
		SELECT FareSavingsCode, Description
		FROM FareSavingsCode
		WHERE STO = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		AND FareSavingsCodeID NOT IN (35)
		<cfif arguments.Acct_ID NEQ 348>
			AND Acct_ID IS NULL
		<cfelse>
			AND Acct_ID = <cfqueryparam value="348" cfsqltype="cf_sql_integer">
		</cfif>
		ORDER BY FareSavingsCode
		</cfquery>
		
		<cfreturn qOutOfPolicy>
	</cffunction>
	
	<cffunction name="getTXExceptionCodes" access="public" returntype="query" output="false">
		
		<cfquery name="local.qTXExceptionCodes" datasource="Corporate_Production" cachedwithin="#CreateTimeSpan(30,0,0,0)#">
		SELECT *
		FROM FareSavingsCode
		WHERE Acct_ID = <cfqueryparam value="235" cfsqltype="cf_sql_integer">
		AND STO = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		ORDER BY FareSavingsCode
		</cfquery>
		
		<cfreturn qTXExceptionCodes>
	</cffunction>

</cfcomponent>