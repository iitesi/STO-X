<cfoutput><cfdump var="#session.aMessages#" abort>
	<cfset cnt = 0>
	<cfloop from="#ArrayLen(session.aMessages)#" to="1" step="-1" index="i">
		<cfset cnt++>
		<cfif cnt LTE 5>
			<cfdump eval=session.aMessages[i]>
		</cfif>
	</cfloop>
</cfoutput>