<!--- cascade the session.acctId --->
<cfif structKeyExists(session,"acctId")>
	<cfset acctId = session.acctId/>
<cfelseif structKeyExists(cookie,"acctId")>
	<cfset acctId = cookie.acctId/>
<cfelse>
	<cfset acctId = 0/>
</cfif>

<!--- clear the session --->
<cfset structClear(session)/>

<!--- TODO: Story to make account configurabe --->
<cfif acctId eq 532>
	<cflocation url="/booking/?action=dycom.login" addtoken="false">
<cfelse>
	<cflocation url="/booking/?action=main.login" addtoken="false">
</cfif>