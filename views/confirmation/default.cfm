<style>
	.minlineheight {
		line-height: 10px;
	}
	hr {
		margin-bottom: 0px;
	}
	.dashed {
		border: dashed #2E76CF;
		border-width: 1px 0 0 0;
		height: 0;
		line-height: 0px;
		font-size: 0;
		margin: 4px 0 4px 0;
		padding: 0;
	}
	.ribbon {
		position: relative;
	}
</style>

<cfsilent>
<cfset showPreTripText = false />
<cfset showNoPreTripText = false />
<cfset preTripApprovalList = "" />
<cfset noPreTripApprovalList = "" />

<cfloop from="1" to="#arrayLen(rc.Travelers)#" index="travelerIndex">
	<cfset thisTraveler = uCase(rc.Traveler[travelerIndex].getFirstName()) & " " & uCase(rc.Traveler[travelerIndex].getLastName()) />
	<cfif rc.Traveler[travelerIndex].getBookingDetail().getApprovalNeeded()>
		<cfset preTripApprovalList = listAppend(preTripApprovalList, thisTraveler) />
		<cfset showPreTripText = true />
	<cfelse>
		<cfset noPreTripApprovalList = listAppend(noPreTripApprovalList, thisTraveler) />
		<cfset showNoPreTripText = true />
	</cfif>
</cfloop>
</cfsilent>

<div style="width:960px;">
	<div class="container page-header">
		<span>
			<h1>RESERVATION CREATED</h1>
		</span>
		<span style="float:right">
			<cfif (application.es.getCurrentEnvironment() NEQ 'prod'
				AND NOT (application.es.getCurrentEnvironment() EQ 'beta'
					AND rc.Filter.getAcctID() EQ 441))
				OR listFind(application.es.getDeveloperIDs(), rc.Filter.getUserID())>
				<cfoutput>
					<cfif structKeyExists(session.searches[rc.searchID], 'Travelers')>
						<cfloop collection="#session.searches[rc.searchID].Travelers#" index="local.travelerNumber" item="local.Traveler">
							<cfif Traveler.getBookingDetail().getUniversalLocatorCode() NEQ ''>
								<a href="#buildURL('purchase.cancel?searchID=#rc.searchID#')#">
									<span class="icon-large icon-remove-circle"></span> Cancel Reservation #Traveler.getBookingDetail().getUniversalLocatorCode()#
								</a>
							</cfif>
						</cfloop>
					</cfif>
				</cfoutput>
			</cfif>
			&nbsp;&nbsp;&nbsp;&nbsp;<a href="#" onClick="window.print();return false;"><span class="icon-large icon-print"></span> Print View</a>
		</span>
	</div>
	<cfoutput>

		<div>
			<div id="reservationMessage" class="alert alert-success" style="width:920px;">
				<!--- If at least one pre-trip traveler. --->
				<cfif showPreTripText>
					<cfif listLen(preTripApprovalList) GT 1 OR showNoPreTripText>
						#replace(preTripApprovalList, ",", ", ", "all")#:<br />
					</cfif>
					<cfif structKeyExists(rc.Account, "ConfirmationMessage_Required") AND len(rc.Account.ConfirmationMessage_Required)>
						#paragraphFormat(rc.Account.ConfirmationMessage_Required)#
					<cfelse>
						WE HAVE CREATED YOUR RESERVATION AND EMAILED YOUR TRAVEL MANAGER FOR APPROVAL.<br />
						YOU WILL RECEIVE AN EMAIL CONFIRMATION ONCE YOUR MANAGER HAS APPROVED.
					</cfif>
					<cfif showNoPreTripText>
						<br /><br />
					</cfif>
				</cfif>
				<!--- If at least one no pre-trip traveler. --->
				<cfif showNoPreTripText>
					<cfif listLen(noPreTripApprovalList) GT 1 OR showPreTripText>
						#replace(noPreTripApprovalList, ",", ", ", "all")#:<br />
					</cfif>
					<cfif structKeyExists(rc.Account, "ConfirmationMessage_NotRequired") AND len(rc.Account.ConfirmationMessage_NotRequired)>
						#paragraphFormat(rc.Account.ConfirmationMessage_NotRequired)#
					<cfelse>
						WE HAVE CREATED YOUR RESERVATION.<br />
						YOU WILL RECEIVE AN EMAIL CONFIRMATION WITHIN 24 HOURS.
					</cfif>
				</cfif>
			</div>
		</div>
	</cfoutput>
	<div style="height:14px;"></div>
	<div>
		<span class="blue confirm-header">BILLING DETAILS</span>
	</div>
	<cfoutput>
		#view('confirmation/billing')#
	</cfoutput>
	<div>
		<span class="blue confirm-header">ITINERARY</span>
	</div>
	<cfoutput>
		#view('confirmation/itinerary')#
	</cfoutput>
</div>