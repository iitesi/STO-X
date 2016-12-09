<cfset session.userId = 0/>
<cfif session.acctId eq 532>
	<cflocation url="?action=dycom.login" addtoken="false">
<cfelse>
	<cflocation url="?action=main.login" addtoken="false">
</cfif>