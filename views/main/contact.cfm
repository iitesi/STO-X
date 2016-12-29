<cfset qryContactinfo = application.fw.factory.getBean("AccountManager").getContactinfo(acctId=session.acctId)/>
<div class="container-fluid" id="Main">
	<div class="row">
		<div class="col-md-10 col-md-offset-1">
			<div class="panel panel-default">
				<div class="panel-heading">
					<h1 class="panel-title">Contact info</h1>
				</div>
				<div class="panel-body" style="padding:25px;">
					<cfoutput query="qryContactInfo">
						<p>
							<div style="color:##696969;font-size:15px;font-weight:bold;">
								#Description#
							</div>
							<div style="padding:5px 0 0 0;font-size:13px;white-space:normal;word-wrap:break-word;">
								<cfif len(trim(Address))>
									#Address#<br>
									#City#, #State#<br>
									#Zip#<br>
								</cfif>
								<cfif len(trim(TollFreePhone))><a href="tel:#TollFreePhone#">#TollFreePhone#</a><br></cfif>
								<cfif len(trim(Email))><a href="mailto:#Email#">#Email#</a><br></cfif>
							</div>
						</p>
					</cfoutput>
				</div>
			</div>
		</div>
	</div>
</div>