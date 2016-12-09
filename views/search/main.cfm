<div class="container-fluid" id="Main">
	<div class="row">
		<cfset tokenInfo = application.fw.factory.getBean( "AuthorizationService" ).createToken(
			acctId = session.acctId,
			userId = session.userId
		)/>
		<cfoutput>
			<iframe frameborder="0" src="/search/index.cfm?bodyColor=FFFFFF&userId=#session.userId#&acctid=#session.acctId#&token=#tokenInfo.token#&date=#tokenInfo.date#" style="width:100%;height:1000px;scroll:auto;"></iframe>
		</cfoutput>
	</div>
</div>