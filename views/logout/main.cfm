<cfset session.userId = 0/>
<cfif session.acctId eq 532>
	<cflocation url="?action=login.dycom" addtoken="false">
<cfelse>
	<cflocation url="?action=login.main" addtoken="false">
</cfif>