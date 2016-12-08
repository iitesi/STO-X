<div id="developers">
<cfoutput>
	<cftry>
		<cfif application.es.getCurrentEnvironment() NEQ "prod"
			AND rc.Filter.getAcctID() NEQ 441>
			<style type="text/css">
			<!--
			.watermark {
				font-size:50px;
				z-index:-1;
				font-weight:bold;
				position: fixed;
				bottom: 0;
				right: 0;
				padding:20px;
				color:##eee;
			}
			-->
			</style>
			<div class="watermark"><cfoutput>#uCase(application.es.getCurrentEnvironment())#</cfoutput></div>
		</cfif>
		<cfif isLocalHost(cgi.remote_addr)
			OR listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID())>
			<style type="text/css">
			<!--
			.dev-dropdown {
				position: absolute;
				top: 0px;
				right: 50px;
				padding:20px;
				color:##eee;
			}
			-->
			</style>
			<div class="dropdown dev-dropdown">
				<a class="dropdown-toggle" data-toggle="dropdown" href="##">Developers <b class="caret"></b></a>
				<ul class="dropdown-menu" role="menu" aria-labelledby="dLabel">
					<li>
						<a href="index.cfm?#cgi.query_string#&reload=true">Reload Application</a>
					</li>
					<!--- <li>
						<a href="index.cfm?#cgi.query_string#&reinit=true">Reset Application Vars</a>
					</li> --->
					<li class="divider"></li>
					<li>
						<a href="http://railoqa/loglive.cfm?searchID=#rc.searchID#&top=5" target="_blank">View Top 2 Logs</a>
					</li>
					<li>
						<a href="http://railoqa/loglive.cfm?searchID=#rc.searchID#&top=10" target="_blank">View Top 10 Logs</a>
					</li>
					<li class="divider"></li>
					<li>
						<a href="#buildURL('main.lookup?searchID=#rc.searchID#&view=trips')#" target="_blank">View Trips</a>
					</li>
					<li>
						<a href="#buildURL('main.lookup?searchID=#rc.searchID#&view=avail')#" target="_blank">View Schedule</a>
					</li>
					<li>
						<a href="#buildURL('main.lookup?searchID=#rc.searchID#&view=cars')#" target="_blank">View Cars</a>
					</li>
					<li>
						<a href="#buildURL('main.lookup?searchID=#rc.searchID#&view=travelers')#" target="_blank">View Travelers</a>
					</li>
				</ul>
			</div>
		</cfif>
	<cfcatch>
	</cfcatch>
	</cftry>
</cfoutput>
</div>