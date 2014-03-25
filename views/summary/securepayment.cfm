<cfsilent>
	<cfset local.timestamp = now() />
	<cfset local.string = "acctID=#rc.Filter.getAcctID()#&userID=#rc.Filter.getUserID()#&searchID=#rc.searchID#&date=#dateFormat(local.timestamp, 'mm/dd/yyyy')#&time=#timeFormat(local.timestamp, 'HH:mm:ss')#" />
	<cfset local.token = hash(local.string&rc.account.SecurityCode) />
	<cfif cgi.http_host EQ "r.local">
		<cfset local.secureURL = "http://" & cgi.http_host />
	<cfelse>
		<cfset local.secureURL = "https://" & cgi.http_host />
	</cfif>

	<cfset local.coreFrameAddress = local.secureURL & "/secure-sto/index.cfm?action=" />
	<cfset local.coreFrameParameters = "&acctID=#rc.Filter.getAcctID()#" />
	<cfset local.coreFrameParameters = local.coreFrameParameters & "&userID=#rc.Filter.getUserID()#" />
	<cfset local.coreFrameParameters = local.coreFrameParameters & "&searchID=#rc.searchID#" />
	<cfset local.coreFrameParameters = local.coreFrameParameters & "&travelerNumber=#rc.travelerNumber#" />
	<cfset local.coreFrameParameters = local.coreFrameParameters & "&token=#token#" />
	<cfset local.coreFrameParameters = local.coreFrameParameters & "&timestamp=#timestamp#" />

	<cfset local.displayFrameAddress = local.coreFrameAddress & "summary.addPayment" & local.coreFrameParameters />
	<cfset local.stateList = valueList(rc.qStates.State_Code) />
	<cfset local.displayFrameAddress = local.displayFrameAddress & "&states=#stateList#" />

	<cfset local.removeFrameAddress = local.coreFrameAddress & "summary.removePayment" & local.coreFrameParameters />
</cfsilent>

<div id="displayPaymentWindow" class="modal searchForm hide fade" tabindex="-1" role="dialog" aria-labelledby="myPaymentWindow" aria-hidden="true">
	<div class="searchContainer">
		<div class="modal-header">
			<button type="button" class="close" data-dismiss="modal"><i class="icon-remove"></i></button>
			<h3 id="addModalHeader">ENTER CREDIT CARD INFORMATION</h3>
		</div>
		<cfoutput>
			<div class="modal-body">
				<div id="addModalBody">
					<cfoutput>
						<div id="displayFrameAddress" class="hide">#local.displayFrameAddress#</div>
						<iframe
							id="addIframe"
							src=""
							width="540"
							height="382"
							frameBorder="0"></iframe>
					</cfoutput>
				</div>
			</div>
		</cfoutput>
	</div>
</div>

<div id="removePaymentWindow" class="modal searchForm hide fade" tabindex="-1" role="dialog" aria-labelledby="myPaymentWindow" aria-hidden="true">
	<div class="searchContainer">
		<div class="modal-header">
			<button type="button" class="close" data-dismiss="modal"><i class="icon-remove"></i></button>
			<h3 id="removeModalHeader">REMOVE CREDIT CARD INFORMATION</h3>
		</div>
		<cfoutput>
			<div class="modal-body">
				<div id="removeModalBody">
					<cfoutput>
						<div id="removeFrameAddress" class="hide">#local.removeFrameAddress#</div>
						<iframe
							id="removeIframe"
							src=""
							width="540"
							height="82"
							frameBorder="0"></iframe>
					</cfoutput>
				</div>
			</div>
		</cfoutput>
	</div>
</div>