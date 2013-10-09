<cfcomponent extends="abstract" output="false">

	<cffunction name="default" output="false">
		<cfloop list="#structKeyList(session)#" index="local.ii">
			<cfif local.ii NEQ "ACCTID" AND local.ii NEQ "USERID">
				<cfset "session.#local.ii#" = "" />
			</cfif>
		</cfloop>
		<cfset session.isAuthorized = false />
		<cfset session.searches = {} />
		<cfset session.filters = {} />
		<cfset session.aMessages = [] />

		<cfset local.logoutURL = application.sPortalURL />

		<cfif right(logoutURL, 10) IS NOT "/index.cfm">
			<cfif right(logoutURL, 1) IS "/">
				<cfset logoutURL = logoutURL & "index.cfm" />
			<cfelse>
				<cfset logoutURL = logoutURL & "/index.cfm" />
			</cfif>
		</cfif>

		<cflocation url="#logoutURL#?Display=Validate/LogOut/act_processLogOut.cfm" addtoken="false" />
	</cffunction>

</cfcomponent>