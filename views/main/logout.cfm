<cfset session.userId = 0/>
<!--- TODO: STM-7280 STO and SSO account configurability --->
<cfif session.acctId eq 532>
	<cflocation url="?action=dycom.login" addtoken="false">
<cfelse>
	<cflocation url="?action=main.login" addtoken="false">
</cfif>