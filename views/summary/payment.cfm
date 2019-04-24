<cfoutput>
	<input type="hidden" name="priceQuotedError" value="#rc.priceQuotedError#">
	<h2>PAYMENT</h2>
	<cfif rc.airSelected>
		<div id="airPayment">

		<div class="form-group #(structKeyExists(rc.errors, 'airFOPID') ? 'error' : '')#">
			<label class="control-label col-sm-4 col-xs-12" for="airFOPID"><strong>Flight Payment *</strong></label>
			<div class="controls col-sm-8 col-xs-12" id="airFOPIDDiv">
				<i id="airSpinner" class="blue fa fa-spin fa-spinner"></i>
				<select class="form-control" name="airFOPID" id="airFOPID">
				</select>
			</div>
		</div>

		<div id="airNewCard" class="form-group">
			<div id="addAirCC" class="col-sm-offset-4 col-sm-8">
				<label class="control-label" for="addAirCC"><input type="button" name="displayPaymentModal" class="btn btn-primary displayPaymentModal" value="ENTER NEW CARD" data-toggle="modal" data-backdrop="static" data-paymentType="air"></label>
			</div>
			<div id="removeAirCC" class="hide col-sm-offset-4 col-sm-8">
				<label class="control-label" for="removeAirCC"><input type="button" name="removePaymentModal" class="btn btn-primary removePaymentModal" value="REMOVE CARD" data-toggle="modal" data-backdrop="static" data-paymentType="air" data-id="#rc.Traveler.getBookingDetail().getAirFOPID()#"></label>
			</div>
			<input type="hidden" name="newAirCC" id="newAirCC" />
			<input type="hidden" name="newAirCCID" id="newAirCCID" />
		</div>

		<div id="airManual">

			<div class="form-group #(structKeyExists(rc.errors, 'airCCNumber') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="airCCNumber">Card Number *</label>
				<div class="controls col-sm-8">
					<label class="form-control">#rc.Traveler.getBookingDetail().getAirCCNumber()#</label>
					<input type="hidden" name="airCCName" id="airCCName">
					<input type="hidden" name="airCCType" id="airCCType">
					<input type="hidden" name="airCCNumber" id="airCCNumber">
					<input type="hidden" name="airCCNumberRight4" id="airCCNumberRight4">
				</div>
			</div>

			<div class="form-group #(structKeyExists(rc.errors, 'airCCExpiration') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="airCCMonth">Expiration *</label>
				<div class="controls col-sm-8">
					<cfset airMonthAsString = (len(rc.Traveler.getBookingDetail().getAirCCMonth()) ? monthAsString(rc.Traveler.getBookingDetail().getAirCCMonth()) : '') />
					<label class="form-control">#airMonthAsString# #rc.Traveler.getBookingDetail().getAirCCYear()#</label>
					<input type="hidden" name="airCCExpiration" id="airCCExpiration">
					<input type="hidden" name="airCCMonth" id="airCCMonth">
					<input type="hidden" name="airCCMonthDisplay" id="airCCMonthDisplay">
					<input type="hidden" name="airCCYear" id="airCCYear">
				</div>
			</div>

			<div class="form-group #(structKeyExists(rc.errors, 'airCCCVV') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="airCCCVV">CVV Security Code *</label>
				<div class="controls col-sm-8">
					<label class="form-control">#rc.Traveler.getBookingDetail().getAirCCCVV()#</label>
					<input type="hidden" name="airCCCVV" id="airCCCVV">
				</div>
			</div>

			<div class="form-group #(structKeyExists(rc.errors, 'airBillingName') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="airBillingName">Name on Card *</label>
				<div class="controls col-sm-8">
					<label class="form-control">#rc.Traveler.getBookingDetail().getAirBillingName()#</label>
					<input type="hidden" name="airBillingName" id="airBillingName">
				</div>
			</div>

			<div class="form-group #(structKeyExists(rc.errors, 'airBillingAddress') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="airBillingAddress">Billing Address *</label>
				<div class="controls col-sm-8">
					<label class="form-control">#rc.Traveler.getBookingDetail().getAirBillingAddress()#</label>
					<input type="hidden" name="airBillingAddress" id="airBillingAddress">
				</div>
			</div>

			<div class="form-group #(structKeyExists(rc.errors, 'airBillingCity') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="airBillingCity">City *</label>
				<div class="controls col-sm-8">
					<label class="form-control">#rc.Traveler.getBookingDetail().getAirBillingCity()#</label>
					<input type="hidden" name="airBillingCity" id="airBillingCity" maxlength="50">
				</div>
			</div>

			<div class="form-group #(structKeyExists(rc.errors, 'airBillingState') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="airBillingState">State, Zip *</label>
				<div class="controls col-sm-8">
					<label class="form-control">#rc.Traveler.getBookingDetail().getAirBillingState()# #rc.Traveler.getBookingDetail().getAirBillingZip()#</label>
					<input type="hidden" name="airBillingState" id="airBillingState">
					<input type="hidden" name="airBillingZip" id="airBillingZip">
				</div>
			</div>

		</div>

		<div class="blue bold text-right">
			<!--- Dohmen to do --->
			<!--- <a rel="popover" data-original-title="Flight change/cancellation policy"
				data-content="
					Ticket is
					<cfif val(rc.Air.ref) eq 0>
						non-refundable
					<cfelse>
						refundable
					</cfif>
					<br>
					<cfif listFind('DL',rc.Air.platingCarrier) AND val(rc.Air.ref) EQ 0 AND val(rc.Air.changePenalty) EQ 0>
						Changes are not permitted<br>
						No pre-reserved seats
					<cfelse>
						Changes USD #rc.Air.changePenalty# for reissue
					</cfif>
				" href="##"/>
				Flight change/cancellation policy
			</a> --->
		</div>

		</div>
	</cfif>
	<cfif !rc.airSelected AND rc.account.Require_Hotel_Car_Fee>
		<div id="serviceFeePayment">

		<div class="form-group #(structKeyExists(rc.errors, 'serviceFeeFOPID') ? 'error' : '')#">
			<label class="control-label col-sm-4 col-xs-12" for="serviceFeeFOPID"><strong>Service Fees Payment *</strong></label>
			<div class="controls col-sm-8 col-xs-12" id="serviceFeeFOPIDDiv">
				<i id="serviceFeeSpinner" class="blue fa fa-spin fa-spinner"></i>
				<select class="form-control" name="serviceFeeFOPID" id="serviceFeeFOPID">
				</select>
			</div>
		</div>

		<div id="serviceFeeNewCard" class="form-group">
			<div id="addServiceFeeCC" class="col-sm-offset-4 col-sm-8">
				<label class="control-label" for="addServiceFeeCC"><input type="button" name="displayPaymentModal" class="btn btn-primary displayPaymentModal" value="ENTER NEW CARD" data-toggle="modal" data-backdrop="static" data-paymentType="serviceFee"></label>
			</div>
			<div id="removeServiceFeeCC" class="hide col-sm-offset-4 col-sm-8">
				<label class="control-label" for="removeServiceFeeCC"><input type="button" name="removePaymentModal" class="btn btn-primary removePaymentModal" value="REMOVE CARD" data-toggle="modal" data-backdrop="static" data-paymentType="serviceFee" data-id="#rc.Traveler.getBookingDetail().getServiceFeeFOPID()#"></label>
			</div>
			<input type="hidden" name="newServiceFeeCC" id="newServiceFeeCC" />
			<input type="hidden" name="newServiceFeeCCID" id="newServiceFeeCCID" />
		</div>

		<div id="serviceFeeManual">

			<div class="form-group #(structKeyExists(rc.errors, 'serviceFeeCCNumber') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="serviceFeeCCNumber">Card Number *</label>
				<div class="controls col-sm-8">
					<label class="form-control">#rc.Traveler.getBookingDetail().getServiceFeeCCNumber()#</label>
					<input type="hidden" name="serviceFeeCCName" id="serviceFeeCCName">
					<input type="hidden" name="serviceFeeCCType" id="serviceFeeCCType">
					<input type="hidden" name="serviceFeeCCNumber" id="serviceFeeCCNumber">
					<input type="hidden" name="serviceFeeCCNumberRight4" id="serviceFeeCCNumberRight4">
				</div>
			</div>

			<div class="form-group #(structKeyExists(rc.errors, 'serviceFeeCCExpiration') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="serviceFeeCCMonth">Expiration *</label>
				<div class="controls col-sm-8">
					<cfset serviceFeeMonthAsString = (len(rc.Traveler.getBookingDetail().getServiceFeeCCMonth()) ? monthAsString(rc.Traveler.getBookingDetail().getServiceFeeCCMonth()) : '') />
					<label class="form-control">#serviceFeeMonthAsString# #rc.Traveler.getBookingDetail().getServiceFeeCCYear()#</label>
					<input type="hidden" name="serviceFeeCCExpiration" id="serviceFeeCCExpiration">
					<input type="hidden" name="serviceFeeCCMonth" id="serviceFeeCCMonth">
					<input type="hidden" name="serviceFeeCCMonthDisplay" id="serviceFeeCCMonthDisplay">
					<input type="hidden" name="serviceFeeCCYear" id="serviceFeeCCYear">
				</div>
			</div>

			<div class="form-group #(structKeyExists(rc.errors, 'serviceFeeCCCVV') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="serviceFeeCCCVV">CVV Security Code *</label>
				<div class="controls col-sm-8">
					<label class="form-control">#rc.Traveler.getBookingDetail().getServiceFeeCCCVV()#</label>
					<input type="hidden" name="serviceFeeCCCVV" id="serviceFeeCCCVV">
				</div>
			</div>

			<div class="form-group #(structKeyExists(rc.errors, 'serviceFeeBillingName') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="serviceFeeBillingName">Name on Card *</label>
				<div class="controls col-sm-8">
					<label class="form-control">#rc.Traveler.getBookingDetail().getServiceFeeBillingName()#</label>
					<input type="hidden" name="serviceFeeBillingName" id="serviceFeeBillingName">
				</div>
			</div>

			<div class="form-group #(structKeyExists(rc.errors, 'serviceFeeBillingAddress') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="serviceFeeBillingAddress">Billing Address *</label>
				<div class="controls col-sm-8">
					<label class="form-control">#rc.Traveler.getBookingDetail().getServiceFeeBillingAddress()#</label>
					<input type="hidden" name="serviceFeeBillingAddress" id="serviceFeeBillingAddress">
				</div>
			</div>

			<div class="form-group #(structKeyExists(rc.errors, 'serviceFeeBillingCity') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="serviceFeeBillingCity">City *</label>
				<div class="controls col-sm-8">
					<label class="form-control">#rc.Traveler.getBookingDetail().getServiceFeeBillingCity()#</label>
					<input type="hidden" name="serviceFeeBillingCity" id="serviceFeeBillingCity" maxlength="50">
				</div>
			</div>

			<div class="form-group #(structKeyExists(rc.errors, 'serviceFeeBillingState') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="serviceFeeBillingState">State, Zip *</label>
				<div class="controls col-sm-8">
					<label class="form-control">#rc.Traveler.getBookingDetail().getServiceFeeBillingState()# #rc.Traveler.getBookingDetail().getServiceFeeBillingZip()#</label>
					<input type="hidden" name="serviceFeeBillingState" id="serviceFeeBillingState">
					<input type="hidden" name="serviceFeeBillingZip" id="serviceFeeBillingZip">
				</div>
			</div>

		</div>
		
		</div>
	</cfif>

	<cfif rc.hotelSelected>
		<div id="hotelPayment">

		<div class="form-group #(structKeyExists(rc.errors, 'hotelFOPID') ? 'error' : '')#">
			<label class="control-label  col-sm-4 col-xs-12" for="hotelFOPID"><strong>Hotel Payment *</strong></label>
			<div class="col-sm-8 col-xs-12" id="hotelFOPIDDiv">
				<i id="hotelSpinner" class="blue fa fa-spin fa-spinner"></i>
				<select class="form-control" name="hotelFOPID" id="hotelFOPID">
				</select>
			</div>
		</div>

		<div id="hotelNewCard" class="form-group">
			<div id="addHotelCC" class="col-sm-offset-4 col-sm-8">
				<label class="control-label" for="addHotelCC"><input type="button" name="displayPaymentModal" class="btn btn-primary displayPaymentModal" value="ENTER NEW CARD" data-toggle="modal" data-backdrop="static" data-paymentType="hotel"></label>
			</div>
			<div id="removeHotelCC" class="hide col-sm-offset-4 col-sm-8">
				<label class="control-label" for="removeHotelCC"><input type="button" name="removePaymentModal" class="btn btn-primary removePaymentModal" value="REMOVE CARD" data-toggle="modal" data-backdrop="static" data-paymentType="hotel" data-id="#rc.Traveler.getBookingDetail().getHotelFOPID()#"></label>
			</div>
			<input type="hidden" name="newHotelCC" id="newHotelCC" />
			<input type="hidden" name="newHotelCCID" id="newHotelCCID" />
		</div>

		<div id="hotelManual">

			<div class="form-group" id="copyAirCCDiv">
				<div class="controls col-sm-offset-4 col-sm-8">
					<label class="copyAirCC">
						<input type="checkbox" name="copyAirCC" id="copyAirCC" value="1">
						Copy air payment
					</label>
				</div>
			</div>

			<div class="form-group #(structKeyExists(rc.errors, 'hotelCCNumber') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="hotelCCNumber">Card Number *</label>
				<div class="controls col-sm-8">
					<label id="copyAirCCNumber" class="form-control">#rc.Traveler.getBookingDetail().getHotelCCNumber()#</label>
					<input type="hidden" name="hotelCCName" id="hotelCCName">
					<input type="hidden" name="hotelCCType" id="hotelCCType">
					<input type="hidden" name="hotelCCNumber" id="hotelCCNumber">
					<input type="hidden" name="hotelCCNumberRight4" id="hotelCCNumberRight4">
				</div>
			</div>

			<div class="form-group #(structKeyExists(rc.errors, 'hotelCCExpiration') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="hotelCCMonth">Expiration *</label>
				<div class="controls col-sm-8">
					<cfset hotelMonthAsString = (len(rc.Traveler.getBookingDetail().getHotelCCMonth()) ? monthAsString(rc.Traveler.getBookingDetail().getHotelCCMonth()) : '') />
					<label id="copyAirCCMonthYear" class="form-control">#hotelMonthAsString# #rc.Traveler.getBookingDetail().getHotelCCYear()#</label>
					<input type="hidden" name="hotelCCExpiration" id="hotelCCExpiration">
					<input type="hidden" name="hotelCCMonth" id="hotelCCMonth">
					<input type="hidden" name="hotelCCMonthDisplay" id="hotelCCMonthDisplay">
					<input type="hidden" name="hotelCCYear" id="hotelCCYear">
				</div>
			</div>

			<div class="form-group #(structKeyExists(rc.errors, 'hotelBillingName') ? 'error' : '')#">
				<label class="control-label col-sm-4" for="hotelBillingName">Name on Card *</label>
				<div class="controls col-sm-8">
					<label id="copyAirBillingName" class="form-control">#rc.Traveler.getBookingDetail().getHotelBillingName()#</label>
					<input type="hidden" name="hotelBillingName" id="hotelBillingName">
				</div>
			</div>

		</div>

		<cfsavecontent variable="hotelPolicies">
			<cfif rc.Hotel.getRooms()[1].getDepositPolicy() NEQ ''
				OR rc.Hotel.getRooms()[1].getGuaranteePolicy() NEQ ''
				OR rc.Hotel.getRooms()[1].getCancellationPolicy() NEQ ''>
				<cfif rc.Hotel.getRooms()[1].getDepositPolicy() NEQ ''>
					Deposit: #rc.Hotel.getRooms()[1].getDepositPolicy()#<br>
				</cfif>
				<cfif rc.Hotel.getRooms()[1].getGuaranteePolicy() NEQ ''>
					Guarantee: #rc.Hotel.getRooms()[1].getGuaranteePolicy()#
				</cfif>
				Cancellation: #rc.Hotel.getRooms()[1].getCancellationPolicy()#<br>
			<cfelse>
				Hotel policies are not available at this time.
			</cfif>
		</cfsavecontent>
		<cfif UCASE(rc.Hotel.getRooms()[1].getAPISource()) EQ "PRICELINE">
			<div class="blue bold text-right">
				<a rel="popover" href="javascript:$('##displayHotelCancellationPolicy').modal('show');" />
					Hotel payment and cancellation policy
				</a>
			</span>
			<div id="displayHotelCancellationPolicy" class="modal searchForm fade" tabindex="-1" role="dialog" aria-labelledby="displayHotelCancellationPolicy" aria-hidden="true">
				<div class="modal-dialog">
					<div class="modal-content">
						<div class="modal-header popover-content">
							<button type="button" class="close" data-dismiss="modal"><i class="fa fa-remove"></i></button>
							<h3 id="addModalHeader">
								You have selected a web rate. Please read and accept the terms of this rate.
							</h3>
						</div>
						<div class="modal-body popover-content">
							<div id="addModalBody">
								#view( 'summary/hotelcancellationpolicy' )#
							</div>
						</div>
					</div>
				</div>
			</div>
		<cfelse>
			<div class="blue bold text-right">
				<a rel="popover" data-original-title="Hotel payment and cancellation policy" data-content="#hotelPolicies#" href="##" />
					Hotel payment and cancellation policy
				</a>
			</div>
		</cfif>

		</div>
	</cfif>

	<cfif rc.vehicleSelected>
		<div id="carPayment">

		<div class="form-group">
			<label class="control-label col-sm-4 col-xs-12" for="carFOPID"><strong>Car Payment *</strong></label>
			<div class="controls col-sm-8 col-xs-12">
				<i id="carSpinner" class="blue fa fa-spin fa-spinner"></i>
				<select name="carFOPID" id="carFOPID" class="form-control">
				</select>
			</div>
		</div>

		<div class="blue bold text-right">
			<a rel="popover" data-original-title="Car payment and cancellation policy" data-content="Payment is taken by the vendor. You may cancel at anytime for no fee." href="##" />
				Car payment and cancellation policy
			</a>
		</div>

		</div>
	</cfif>

	<div>
		<cfoutput>
			#view('summary/securepayment')#
		</cfoutput>
	</div>

</cfoutput>
