<!--- to do : move css once it is completed --->
<style>
.form-horizontal select, textarea, input {
	padding: 0px;
}
</style>

<cfoutput>
	<div style="width:1000px;" id="summaryForm">
		
		<span style="float:right">
			<cfif NOT rc.hotelSelected
				AND rc.Filter.getAirType() NEQ 'MD'>
				<a href="#buildURL('summary?searchID=#rc.searchID#')#&add=hotel">
					<span class="icon-large icon-plus"></span> Add Hotel
				</a>&nbsp;&nbsp;&nbsp;&nbsp;
			</cfif>

			<cfif NOT rc.vehicleSelected
				AND rc.Filter.getAirType() NEQ 'MD'>
				<a href="#buildURL('summary?searchID=#rc.searchID#')#&add=car">
					<span class="icon-large icon-plus"></span> Add Car
				</a>
			</cfif>
		</span>

		<h1>Purchase Reservation</h1>

		<cfif arrayLen(session.searches[rc.searchID].Travelers) GT 1>
			<div class="page-header">
				<div class="legs clearfix">
					<cfset count = 0>
					<cfloop array="#session.searches[rc.searchID].Travelers#" index="travIndex" item="trav">
						<cfset count++>
						<cfif trav.getFirstName() NEQ ''>
							<a href="#buildURL('summary?searchID=#rc.searchID#&travelerNumber=#travIndex#')#" class="btn legbtn #(rc.travelerNumber EQ travIndex ? 'btn-primary' : '')#">
								#count#. #trav.getFirstName()# #trav.getLastName()#</a>
						<cfelse>
							<a href="#buildURL('summary?searchID=#rc.searchID#&travelerNumber=#travIndex#')#" class="btn legbtn #(rc.travelerNumber EQ travIndex ? 'btn-primary' : '')#">
								#count#. Traveler</a>
						</cfif>
					</cfloop>
					<cfif rc.travelerNumber NEQ 1>
						<a href="#buildURL('summary?searchID=#rc.searchID#&travelerNumber=#rc.travelerNumber#&remove=1')#">
							<span class="icon-large icon-remove-sign"></span> Remove Traveler ###rc.travelerNumber# 
						</a>
					</cfif>
				</div>
			</div>
		</cfif>

		<form method="post" class="form-horizontal" action="#buildURL('summary?searchID=#rc.searchID#')#">

			<cfparam name="rc.showAll" default="0">

			<input type="hidden" name="searchID" id="searchID" value="#rc.searchID#">
			<input type="hidden" name="acctID" id="acctID" value="#rc.Filter.getAcctID()#">
			<input type="hidden" name="travelerNumber" id="travelerNumber" value="#rc.travelerNumber#">
			<input type="hidden" name="arrangerID" id="arrangerID" value="#rc.Filter.getUserID()#">
			<input type="hidden" name="valueID" id="valueID" value="#rc.Filter.getValueID()#">
			<input type="hidden" name="airSelected" id="airSelected" value="#rc.airSelected#">
			<input type="hidden" name="carriers" id="carriers" value=#(rc.airSelected ? serializeJSON(rc.Air.Carriers) : '')#>
			<input type="hidden" name="hotelSelected" id="hotelSelected" value="#rc.hotelSelected#">
			<input type="hidden" name="chainCode" id="chainCode" value="#(rc.hotelSelected ? rc.Hotel.getChainCode() : '')#">
			<input type="hidden" name="vehicleSelected" id="vehicleSelected" value="#rc.vehicleSelected#">
			<input type="hidden" name="vendor" id="vendor" value="#(rc.vehicleSelected ? rc.Vehicle.getVendorCode() : '')#">
			<input type="hidden" name="auxFee" id="auxFee" value="#rc.fees.auxFee#">
			<input type="hidden" name="airFee" id="airFee" value="#rc.fees.airFee#">
			<input type="hidden" name="requestFee" id="requestFee" value="#rc.fees.requestFee#">
			
			<div id="traveler" class="tab_content">
				<p>
					<div class="summarydiv" style="background-color: ##FFF;wdith:1000px;">
						<table width="1000">
							<tr>
								<td valign="top">
									<div id="travelerForm">
										#View('summary/traveler')#
									</div>
								</td>
								<td valign="top">
									<div id="paymentForm" style="padding-left:20px;">
										#view( 'summary/payment' )#
									</div>
								</td>
							</tr>
						</table>
					</div>

					<div class="summarydiv" style="background-color: ##FFF;wdith:1000px;">
						<div id="airDiv" class="clearfix">
							#View('summary/air')#
						</div>
						<div id="hotelDiv" class="clearfix">
							#View('summary/hotel')#
						</div>
						<div id="carDiv" class="clearfix">
							#View('summary/vehicle')#
						</div>
					</div>
					#View('summary/tripsummary')#
					#View('summary/buttons')#
				</p>
			</div>
				
			<script src="assets/js/summary/summary.js"></script>
		</form>
	</div>

</cfoutput>
<cfdump var="#rc.traveler.getbookingdetail()#" />