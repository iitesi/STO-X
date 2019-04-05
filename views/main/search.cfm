<div class="container-fluid" id="Main">
	<div class="row">
		<cfset tokenInfo = application.fw.factory.getBean( "AuthorizationService" ).createToken(
			acctId = session.acctId,
			userId = session.userId
		)/>
		<cfoutput>
			<!--- for commandbox ...for now --->
			<cfif cgi.REMOTE_ADDR EQ "10.0.0.1">
				<cfset local.searchWidgetHost = "http://localhost:3001/"/>
			<cfelse>
				<cfset local.searchWidgetHost = "/search/"/>
			</cfif>
			<iframe frameborder="0" src="#local.searchWidgetHost#index.cfm?bodyColor=FFFFFF&userId=#session.userId#&acctid=#session.acctId#&token=#tokenInfo.token#&date=#tokenInfo.date#&sav=#application.staticAssetVersion#" style="width:100%;height:1000px;scroll:auto;"></iframe>
		</cfoutput>
	</div>
</di>