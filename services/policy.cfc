<cfcomponent output="false">
	
<!--- init --->
	<cffunction name="init" access="remote" output="false" returntype="any">
		<cfreturn this>
	</cffunction>

<!--- policy : policyair --->
	<cffunction name="policyair" access="remote" output="false" returntype="any">
		<cfargument name="Acct_ID" required="false" type="numeric" default="#session.account.Acct_ID#"> 
		<cfargument name="Search_ID" required="true" type="numeric"> 
		
		<cfquery name="local.getinternational" datasource="Corporate_Production" cachedwithin="#CreateTimespan(0,0,15,0)#">
		SELECT International
		FROM Accounts
		WHERE Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfquery name="local.policyair" datasource="book" cachedwithin="#CreateTimespan(0,0,15,0)#">
		SELECT Policy_ID, Policy_AirRefRule, Policy_AirRefDisp, Policy_AirNonRefRule, Policy_AirNonRefDisp, Policy_AirPrefRule, Policy_AirPrefDisp,
		Policy_AirAdvDisp, Policy_AirAdvRule, Policy_AirMaxRule, Policy_AirMaxDisp, Policy_AirLowRule, Policy_AirLowDisp,
		Policy_AirLowPad, Policy_AirFirstClass, Policy_AirBusinessClass, Policy_AllowRequests, Policy_AirAdv, Policy_AirMaxTotal,
		Policy_AirReasonCode, Policy_AirLostSavings, Round(Policy_Window/2, 0) AS Policy_Window, Air_PF, Air_PTC, Policy_AirBusinessClass, Policy_AirFirstClass,
		#getinternational.International# AS International, CBA_AllDepts, Policy_FinditDays, Policy_FinditDiff, Policy_FinditFee, PCC_Booking
		FROM Account_Policies, Accounts
		WHERE Account_Policies.Acct_ID = <cfqueryparam value="#arguments.Acct_ID#" cfsqltype="cf_sql_integer">
		AND Policy_ID = <cfqueryparam value="#session.searches[arguments.Search_ID].Policy_ID#" cfsqltype="cf_sql_integer">
		AND Account_Policies.Acct_ID = Accounts.Acct_ID
		</cfquery>
		
		<cfreturn policyair />
	</cffunction>

<!--- policy : preferredair --->
	<cffunction name="preferredair" access="remote" output="false" returntype="any">
		
		<cfquery name="local.preferredair" datasource="book" cachedwithin="#CreateTimespan(0,0,15,0)#">
		SELECT Vendor_Code, Vendor_Name
		FROM Preferred_Vendors, lu_Vendors
		WHERE Preferred_Vendors.Acct_ID = <cfqueryparam value="#session.account.Acct_ID#" cfsqltype="cf_sql_integer">
		AND Preferred_Vendors.Type = <cfqueryparam value="A" cfsqltype="cf_sql_varchar">
		AND Preferred_Vendors.Vendor_ID = lu_Vendors.Vendor_Code
		AND Preferred_Vendors.Type = lu_Vendors.Vendor_Type
		ORDER BY Vendor_Name
		</cfquery>
		
		<cfreturn preferredair />
	</cffunction>
	
<!--- policy : policycar --->
	<cffunction name="policycar" access="remote" output="false" returntype="any">
		
		<cfquery name="local.policycar" datasource="book" cachedwithin="#CreateTimespan(0,0,15,0)#">
		SELECT Policy_CarMaxRule, Policy_CarMaxDisp,
		Policy_CarPrefRule, Policy_CarPrefDisp,
		Policy_CarTypeRule, Policy_CarTypeDisp,
		Policy_CarOnlyRates, Policy_CarMaxRate,
		Policy_CarReasonCode
		FROM Account_Policies, Accounts
		WHERE Account_Policies.Acct_ID = <cfqueryparam value="#session.account.Acct_ID#" cfsqltype="cf_sql_integer">
		AND Policy_ID = <cfqueryparam value="#session.Policy_ID#" cfsqltype="cf_sql_integer">
		AND Account_Policies.Acct_ID = Accounts.Acct_ID
		</cfquery>
		
		<cfreturn policycar />
	</cffunction>

<!--- policy : preferredcar --->
	<cffunction name="preferredcar" access="remote" output="false" returntype="any">
		
		<cfquery name="local.preferredcar" datasource="book" cachedwithin="#CreateTimespan(0,0,15,0)#">
		SELECT Vendor_Name
		FROM Preferred_Vendors, lu_Vendors
		WHERE Preferred_Vendors.Acct_ID = <cfqueryparam value="#session.account.Acct_ID#" cfsqltype="cf_sql_integer">
		AND Preferred_Vendors.Type = <cfqueryparam value="C" cfsqltype="cf_sql_varchar">
		AND Preferred_Vendors.Vendor_ID = lu_Vendors.Vendor_Code
		AND Preferred_Vendors.Type = lu_Vendors.Vendor_Type
		ORDER BY Vendor_Name
		</cfquery>
		
		<cfreturn preferredcar />
	</cffunction>

<!--- policy : preferredcartype --->
	<cffunction name="preferredcartype" access="remote" output="false" returntype="any">
		
		<cfquery name="local.preferredcartype" datasource="book" cachedwithin="#CreateTimespan(0,0,15,0)#">
		SELECT Car_Size
		FROM Policy_CarSizes
		WHERE Acct_ID = <cfqueryparam value="#session.account.Acct_ID#" cfsqltype="cf_sql_numeric" />
		AND Policy_ID = <cfqueryparam value="#session.Policy_ID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		
		<cfreturn preferredcartype />
	</cffunction>
	
<!--- policy : policyhotel --->
	<cffunction name="policyhotel" access="remote" output="false" returntype="any">
		
		<cfquery name="local.policyhotel" datasource="book" cachedwithin="#CreateTimespan(0,0,15,0)#">
		SELECT Policy_HotelReasonCode, Policy_HotelNotBooking,
		Policy_HotelPrefRule, Policy_HotelPrefDisp,
		Policy_HotelMaxRule, Policy_HotelMaxDisp,
		Hotel_RateCodes, Policy_HotelMaxRate
		FROM Account_Policies, Accounts
		WHERE Account_Policies.Acct_ID = <cfqueryparam value="#session.account.Acct_ID#" cfsqltype="cf_sql_integer">
		AND Policy_ID = <cfqueryparam value="#session.Policy_ID#" cfsqltype="cf_sql_integer">
		AND Account_Policies.Acct_ID = Accounts.Acct_ID
		</cfquery>
		
		<cfreturn policyhotel />
	</cffunction>
	
<!--- policy : preferredhotels --->
	<cffunction name="preferredhotels" access="remote" returntype="any" output="false">
		
		<cfquery name="local.preferredhotels" datasource="book" cachedwithin="#CreateTimespan(0,0,15,0)#">
		SELECT Vendor_Code, Vendor_Name
		FROM Preferred_Vendors, LU_Vendors
		WHERE Acct_ID = <cfqueryparam value="#session.account.Acct_ID#" cfsqltype="cf_sql_integer">
		AND Preferred_Vendors.Vendor_ID = LU_Vendors.Vendor_Code
		AND Preferred_Vendors.Type = LU_Vendors.Vendor_Type
		AND Type = <cfqueryparam value="H" cfsqltype="cf_sql_varchar">
		ORDER BY Vendor_Name
		</cfquery>
		
		<cfreturn this>
	</cffunction>
		
<!--- policy : finditpolicy --->
	<cffunction name="finditpolicy" access="remote" output="false" returntype="any">
		
		<cfquery name="local.finditpolicy" datasource="book" cachedwithin="#CreateTimespan(0,0,15,0)#">
		SELECT Policy_FindItDays, Policy_FindIt, Policy_FindItFee, Policy_FindItDiff
		FROM Account_Policies, Accounts
		WHERE Account_Policies.Acct_ID = <cfqueryparam value="#session.account.Acct_ID#" cfsqltype="cf_sql_integer">
		AND Policy_ID = <cfqueryparam value="#session.Policy_ID#" cfsqltype="cf_sql_integer">
		AND Account_Policies.Acct_ID = Accounts.Acct_ID
		</cfquery>
		
		<cfreturn this />
	</cffunction>
		
</cfcomponent>