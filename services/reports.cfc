<cfcomponent output="false" accessors="true">

	<cfsetting showdebugoutput="false">

<!---
getAllTravelers
--->
	<cffunction name="getAllTravelers" output="false">
		<cfargument name="UserID">
		<cfargument name="AcctID">

		<cfstoredproc procedure="sp_travelers" datasource="Corporate_Production" cachedwithin="#CreateTimeSpan(1,0,0,0)#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#arguments.AcctID#">
			<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#arguments.UserID#">
			<cfprocresult name="local.qAllTravelers">
		</cfstoredproc>

		<cfreturn qAllTravelers />

	</cffunction>

<!---
getAllUnusedTickets
--->
	<cffunction name="getAllUnusedTickets" output="false">
		<cfargument name="UserID">
		<cfargument name="qAllTravelers">

		<cfquery name="local.qUnusedTickets" datasource="NonRefundableTickets" cachedwithin="#CreateTimeSpan(1,0,0,0)#">
		SELECT Carrier, Locator, LastName + '/' + FirstName AS Traveler, ExpirationDate, Airfare
        FROM UnusedTickets
        WHERE UDID_31 NOT LIKE '%.%'
        AND IsNumeric(UDID_31) = 1
		AND (UDID_31 = #arguments.UserID#
        OR UDID_31 IN (#ValueList(arguments.qAllTravelers.User_ID)#))
        AND ExpirationDate >= getDate()
        AND Status = 'Open'
        ORDER BY ExpirationDate
		</cfquery>

		<cfreturn qUnusedTickets />

	</cffunction>

<!---
showUnusedTickets
--->
	<cffunction name="showUnusedTickets" output="false" access="remote" returnformat="plain">
		<cfargument name="UserID" 		default="#session.UserID#">
		<cfargument name="AcctID" 		default="#session.AcctID#">

		<cfset local.qAllTravelers = getAllTravelers(arguments.UserID, arguments.AcctID)>
		<cfset local.qUnusedTickets = getAllUnusedTickets(arguments.UserID, qAllTravelers)>

		<cfsavecontent variable="local.sReport">
            <ul class="arrow-list">
			<table>
			<cfoutput query="qUnusedTickets">
				<tr>
                    <td><li>#DollarFormat(Airfare)# on #Carrier#</li></td>
					<td>#DateFormat(ExpirationDate, 'm/d')#</td>
                    <td>#Traveler#</td>
                </tr>
			</cfoutput>
			</table>
			</ul>
		</cfsavecontent>

		<cfreturn serializeJSON(sReport)>
	</cffunction>

</cfcomponent>