<cfcomponent extends="abstract" output="false">

	<cffunction name="default" output="false">
		<cfloop list="#structKeyList(session)#" index="ii">
			<cfif ii NEQ "ACCTID" AND ii NEQ "USERID">
				<cfset "session.#ii#" = "" />
			</cfif>
		</cfloop>
		<cfset session.isAuthorized = false />
		<cfset session.searches = {} />
		<cfset session.filters = {} />
		<cfset session.aMessages = [] />

		<cflocation url="#application.sPortalURL#?Display=Validate/LogOut/act_processLogOut.cfm" addtoken="false" />
	</cffunction>

</cfcomponent>