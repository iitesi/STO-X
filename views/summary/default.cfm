
<!--- STM-4242 ===============================================================
12:55 PM Tuesday, September 09, 2014 - Jim Priest - jpriest@shortstravel.com
In order to show Accounts what they could be savings by implementing CouldYou,
we want to run CouldYou searches on all STO accounts to get data for each
account. For now, I only want this to run for 1 month (I want to turn off
after 1 month in case we are seeing excess hits charges from Travelport) --->

<cfparam name="rc.account.couldYou" default="0">
<!--- STM-5372: Disabling this to speed things up on the summary page. --->
<!--- <cfif rc.account.couldYou NEQ 1>
	<cfsavecontent variable="localAssets">
		<script src="/booking/assets/js/fullcalendar.min.js"></script>
		<script src="/booking/assets/js/purl.js"></script>
		<script src="/booking/assets/js/date.format.js"></script>
		<script src="/booking/assets/js/couldyou.js"></script>
		<script type="text/javascript">
			<cfoutput>shortstravel.search = #serializeJSON( rc.Filter )#;</cfoutput>
			<cfoutput>shortstravel.itinerary = #serializeJSON( session.searches[ rc.searchID ].stItinerary )#;</cfoutput>
			shortstravel.itinerary.total = 0;
			if( typeof shortstravel.itinerary.AIR != 'undefined' ){
				shortstravel.itinerary.total += parseFloat( shortstravel.itinerary.AIR.TOTAL );
			}
			if( typeof shortstravel.itinerary.HOTEL != "undefined" ){
				shortstravel.itinerary.total += parseFloat( shortstravel.itinerary.HOTEL.Rooms[0].totalForStay );
			}
			if( typeof shortstravel.itinerary.VEHICLE != "undefined" ){
					shortstravel.itinerary.total += parseFloat( shortstravel.itinerary.VEHICLE.estimatedTotalAmount );
			}
			shortstravel.itinerary.total = Math.round( shortstravel.itinerary.total );
		</script>
	</cfsavecontent>
	<cfhtmlhead text="#localAssets#" />
</cfif> --->

<!--- // STM-4242 ======================================================= --->

<!--- to do : move css once it is completed --->
<style>
.form-horizontal select, textarea, input {
	padding: 0px;
}
.hideElement{display:none;}
</style>

<cfoutput>
	<div id="summaryForm">

		<h1>Purchase Reservation</h1>

		<!--- Shane - Style Travelport error messages.  We need to work with Angela to determine verbiage. --->
		<cfif arrayLen(rc.SellErrorMessages)>
			<div class="alert alert-warning clearfix">
				<cfset MessageType = ''>
				<cfloop collection="#rc.SellErrorMessages#" index="MessageIndex" item="MessageItem">
					<cfif NOT isObject(MessageItem)>
						<li>#MessageItem#</li>
					<cfelseif isObject(MessageItem)>
						<cfdump var=#MessageItem#><br>
						<cfset MessageType = 'XML'>
					</cfif>
				</cfloop>
			</div>
		</cfif>

		<form method="post" class="form-horizontal" id="purchaseForm" action="#buildURL('summary?searchID=#rc.searchID#')#"> 
		<cfif arrayLen(session.searches[rc.searchID].Travelers) GT 1>
			<div class="page-header">

				<div class="legs clearfix">
					<cfset count = 0>
					<cfloop array="#session.searches[rc.searchID].Travelers#" index="travIndex" item="trav">
						<cfset count++>
						<cfif trav.getFirstName() NEQ ''>
							<input type="submit" name="trigger" id="travelerNameButton#count#" class="btn legbtn #(rc.travelerNumber EQ travIndex ? 'btn-primary' : '')#" value="#count#. #trav.getFirstName()# #trav.getLastName()#">
						<cfelse>
							<input type="submit" name="trigger" id="travelerNameButton#count#" class="btn legbtn #(rc.travelerNumber EQ travIndex ? 'btn-primary' : '')#" value="#count#. Traveler">
						</cfif>
						<!--- <cfif trav.getFirstName() NEQ ''>
							<a href="#buildURL('summary?searchID=#rc.searchID#&travelerNumber=#travIndex#')#" class="btn legbtn #(rc.travelerNumber EQ travIndex ? 'btn-primary' : '')#">
								#count#. #trav.getFirstName()# #trav.getLastName()#</a>
						<cfelse>
							<a href="#buildURL('summary?searchID=#rc.searchID#&travelerNumber=#travIndex#')#" class="btn legbtn #(rc.travelerNumber EQ travIndex ? 'btn-primary' : '')#">
								#count#. Traveler</a>
						</cfif> --->
						<p class="showOnPhones"></p>
					</cfloop>
					<cfif rc.travelerNumber NEQ 1>
						<a href="#buildURL('summary?searchID=#rc.searchID#&travelerNumber=#rc.travelerNumber#&remove=1')#">
							<span class="fa fa-lg fa-remove"></span> Remove Traveler ###rc.travelerNumber#
						</a>
					</cfif>
				</div>
			</div>
		</cfif> 
			<cfparam name="rc.showAll" default="0">
			<input type="hidden" name="searchID" id="searchID" value="#rc.searchID#">
			<input type="hidden" name="acctID" id="acctID" value="#rc.Filter.getAcctID()#">
			<input type="hidden" name="externalTMC" id="externalTMC" value="#rc.Account.tmc.getIsExternal()#">
			<input type="hidden" name="findit" id="findit" value="#rc.Filter.getFindIt()#">
			<input type="hidden" name="travelerNumber" id="travelerNumber" value="#rc.travelerNumber#">
			<input type="hidden" name="arrangerID" id="arrangerID" value="#rc.Filter.getUserID()#">
			<input type="hidden" name="arrangerAdmin" id="arrangerAdmin" value="#rc.Filter.getUserAdmin()#">
			<input type="hidden" name="arrangerSTMEmployee" id="arrangerSTMEmployee" value="#rc.Filter.getSTMEmployee()#">
			<input type="hidden" name="valueID" id="valueID" value="#rc.Filter.getValueID()#">
			<input type="hidden" name="airSelected" id="airSelected" value="#rc.airSelected#">
			<input type="hidden" name="requireHotelCarFee" id="requireHotelCarFee" value="#rc.account.Require_Hotel_Car_Fee#">
			<input type="hidden" name="carriers" id="carriers" value='[#(rc.airSelected ? '"'&rc.Air[0].PlatingCarrier&'"' : '')#]'>
			<input type="hidden" name="platingcarrier" id="platingcarrier" value=#(rc.airSelected ? rc.Air[1].platingCarrier : '')#>
			<input type="hidden" name="hotelSelected" id="hotelSelected" value="#rc.hotelSelected#">
			<input type="hidden" name="chainCode" id="chainCode" value="#(rc.hotelSelected ? rc.Hotel.getChainCode() : '')#">
			<input type="hidden" name="masterChainCode" id="masterChainCode" value="#(rc.hotelSelected ? rc.Hotel.getMasterChainCode() : '')#">
			<input type="hidden" name="vehicleSelected" id="vehicleSelected" value="#rc.vehicleSelected#">
			<input type="hidden" name="vendor" id="vendor" value="#(rc.vehicleSelected ? rc.Vehicle.getVendorCode() : '')#">
			<input type="hidden" name="auxFee" id="auxFee" value="#rc.fees.auxFee#">
			<input type="hidden" name="airFee" id="airFee" value="#rc.fees.airFee#">
			<input type="hidden" name="requestFee" id="requestFee" value="#rc.fees.requestFee#">
			<input type="hidden" name="errors" id="errors" value="#structKeyList(rc.errors)#">
			<input type="hidden" name="seatFieldNames" id="seatFieldNames" value="">

			<div id="traveler" class="tab_content">
				<p>
					<div class="summarydiv container-fluid" >
						<div class="row">
						 <span class="disclaimer">* denotes required fields</span>
							<div id="travelerForm" class="col-md-6">
								#View('summary/traveler')#
							</div>
							<div id="paymentForm" class="col-md-6">
								#view( 'summary/payment' )#
							</div>
						</div>
					</div>

					<div class="summarydiv container-fluid">
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
					<cfif StructKeyExists(rc,"TravelMessages") AND ArrayLen(rc.TravelMessages) GT 0>
						#view('summary/messages')#
					</cfif>
					<div class="container-fluid">
						<div class="row">
							<div class="col-xs-12" >
								<div class="alert alert-success hide" id="unusedTicketsDiv">
								</div>
							</div>
							<div class="summarydiv col-md-offset-4 col-md-8 col-xs-12" >
								<div>
									#View('summary/tripsummary')#
								</div>
							</div>
						</div>
					</div>
					#View('summary/buttons')#
				</p>
			</div>
			<div id="searchWindow" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="mySearchWindow" aria-hidden="true">
			    <div class="modal-header">
			        <h4 id="myModalHeader"><i class="fa-spinner fa fa-spin"></i> Loading User</h4>
			    </div>
			    <div id="myModalBody" class="modal-body">

			    </div>
			</div>
			<script src="assets/js/summary/summary.js?v=20180713"></script>
		</form>
	</div>

</cfoutput>
