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
								<cfif Traveler.getBookingDetail().getAirNeeded() AND rc.Air.Carriers[1] EQ "WN">
									Email onlinesupport@shortstravel.com to cancel this Southwest reservation
								<cfelse>
									<a href="#buildURL('purchase.cancel?searchID=#rc.searchID#')#">
										<span class="icon-large icon-remove-circle"></span> Cancel Reservation #Traveler.getBookingDetail().getUniversalLocatorCode()#
									</a>
									<br />
									<!--- <cfif application.es.getCurrentEnvironment() EQ 'QA'>
										<cfset bookingDS = "bookingQA" />
									<cfelse>
										<cfset bookingDS = "booking" />
									</cfif>
									<cfquery name="getInvoiceID" datasource="#bookingDS#">
										SELECT MAX(invoiceID) AS invoiceID
										FROM Invoices
										WHERE userID = #rc.Filter.getUserID()#
									</cfquery>
									<a href="#buildURL('purchase.cancelPPN?searchID=#rc.searchID#&invoiceID=#getInvoiceID.invoiceID#')#">
										<span class="icon-large icon-remove-circle"></span> Cancel Priceline Reservation
									</a> --->
								</cfif>
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
				<cfset variables.unusedTicketSelected = false>
				<cfloop array="#rc.Travelers#" item="local.traveler" index="travelerIndex">
					<cfif rc.Traveler[travelerIndex].getBookingDetail().getUnusedTickets() NEQ ''>
						<cfset variables.unusedTicketSelected = true>
					</cfif>
				</cfloop>
				<!--- If at least one pre-trip traveler. --->
				<cfif showPreTripText>
					<cfif listLen(preTripApprovalList) GT 1 OR showNoPreTripText>
						#replace(preTripApprovalList, ",", ", ", "all")#:<br />
					</cfif>
					<cfif structKeyExists(rc.Account, "ConfirmationMessage_Required") AND len(rc.Account.ConfirmationMessage_Required)>
						#paragraphFormat(rc.Account.ConfirmationMessage_Required)#<br />
					<cfelse>
						WE HAVE CREATED YOUR RESERVATION AND EMAILED YOUR TRAVEL MANAGER FOR APPROVAL.<br />
						YOU WILL RECEIVE AN EMAIL CONFIRMATION ONCE YOUR MANAGER HAS APPROVED.<br />
					</cfif>
					<cfif rc.airSelected AND structKeyExists(rc.Air, "LatestTicketingTime") AND isDate(rc.Air.LatestTicketingTime)>
						<cfif rc.Filter.getAcctID() NEQ 272>
							<cfset hourDue = 20 />
							<cfset minuteDue = 00 />
						<cfelse>
							<cfset hourDue = 23 />
							<cfset minuteDue = 59 />
						</cfif>
						<cfset responseDueBy = createDateTime(year(rc.Air.LatestTicketingTime), month(rc.Air.LatestTicketingTime), day(rc.Air.LatestTicketingTime), hourDue, minuteDue, 00) />
					<cfelse>
						<cfset responseDueBy = dateAdd('h', 23, now()) />
					</cfif>
					<cfif arrayFind(rc.Air.Carriers, 'F9')>
						<cfset responseDueBy = dateAdd('h', 4, now()) />
					</cfif>
					PLEASE NOTE A MANAGER RESPONSE IS DUE BY #timeFormat(responseDueBy, 'htt')# CENTRAL TIME ON #uCase(dateFormat(responseDueBy, 'mmmm d'))#.
					<cfif showNoPreTripText
						OR unusedTicketSelected>
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
					<cfif unusedTicketSelected>
						<br /><br />
					</cfif>
				</cfif>
				<cfif unusedTicketSelected>
					A TRAVEL CONSULTANT WILL REVIEW THE AIRLINE'S RULES TO DETERMINE IF YOUR UNUSED TICKET CREDIT CAN BE APPLIED TO THIS TICKET. YOUR CONFIRMATION EMAIL WILL REFLECT THE NEW TICKET AMOUNT IF CREDIT CAN BE APPLIED. 
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
