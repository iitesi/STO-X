<cfcomponent output="false">
	
<!---
baggage
---> 
	<cffunction name="baggage" output="false">
		<cfargument name="sCarriers" required="true">
		
		<cfquery name="local.qBaggage" datasource="Corporate_Production">
		SELECT Name, IsNull(OnlineDomBag1,0) AS OnlineDomBag1, IsNull(DomBag1,0) AS DomBag1, IsNull(OnlineDomBag2,0) AS OnlineDomBag2, IsNull(DomBag2,0) AS DomBag2, Baggage_Link, CreateUpdate_Datetime
		FROM Suppliers LEFT OUTER JOIN OnlineCheckIn_Links ON OnlineCheckIn_Links.AccountID = Suppliers.AccountID AND Link_Display = 1 
		WHERE ShortCode IN ('#Replace(arguments.sCarriers, ",", "','", "ALL")#')
		AND CustType = <cfqueryparam value="A" cfsqltype="cf_sql_varchar" >
		</cfquery>
		
		<cfreturn qBaggage/>
	</cffunction>

</cfcomponent>