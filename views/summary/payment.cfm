<cfoutput>
	<input type="hidden" name="priceQuotedError" value="#rc.priceQuotedError#">
	<div class="row">
		<h2 class="col s12">PAYMENT</h2>
	</div>
	<cfif rc.airSelected>
		<div id="airPayment">

			<div class="form-group #(structKeyExists(rc.errors, 'airFOPID') ? 'error' : '')#">
				<label class="control-label col-sm-4 col-xs-12" for="airFOPID"><strong>Flight Payment *</strong></label>
				<div class="controls col-sm-8 col-xs-12" id="airFOPIDDiv">
					<i id="airSpinner" class="fa fa-spin fa-spinner"></i>
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

				<div class="mb0 row #(structKeyExists(rc.errors, 'airCCNumber') ? 'error' : '')#">
					<div class="input-field col s12 m10 right">
						<input type="hidden" name="airCCName" id="airCCName">
						<input type="hidden" name="airCCType" id="airCCType">
						<input type="hidden" name="airCCNumber" id="airCCNumber">
						<input type="hidden" name="airCCNumberRight4" id="airCCNumberRight4">
						<input type="text" disabled readonly name="airCCNumberRO" id="airCCNumberRO" value="#rc.Traveler.getBookingDetail().getAirCCNumber()#">
						<label for="airCCNumberRO">Card Number *</label>
					</div>
				</div>

				<div class="mb0 row ">
					<div class="input-field col s6 m5 right #(structKeyExists(rc.errors, 'airCCCVV') ? 'error' : '')#">
						<input type="hidden" name="airCCCVV" id="airCCCVV">
						<input type="text" disabled readonly name="airCCCVVRO" id="airCCCVVRO" value="#rc.Traveler.getBookingDetail().getAirCCCVV()#">
						<label for="airCCCVVRO">CVV Security Code *</label>
					</div>
					<div class="input-field col s6 m5 right #(structKeyExists(rc.errors, 'airCCExpiration') ? 'error' : '')#">
						<input type="hidden" name="airCCExpiration" id="airCCExpiration">
						<input type="hidden" name="airCCMonth" id="airCCMonth">
						<input type="hidden" name="airCCMonthDisplay" id="airCCMonthDisplay">
						<input type="hidden" name="airCCYear" id="airCCYear">
						<cfset airMonthAsString = (len(rc.Traveler.getBookingDetail().getAirCCMonth()) ? monthAsString(rc.Traveler.getBookingDetail().getAirCCMonth()) : '') />
						<input type="text" disabled readonly name="airCCMonthRO" id="airCCMonthRO" value="#airMonthAsString# #rc.Traveler.getBookingDetail().getAirCCYear()#">
						<label for="airCCMonthRO">Expiration *</label>
					</div>
				</div>


				<div class="mb0 row #(structKeyExists(rc.errors, 'airBillingName') ? 'error' : '')#">
					<div class="input-field col s12 m10 right">
						<input type="hidden" name="airBillingName" id="airBillingName">
						<input type="text" disabled readonly name="airBillingNameRO" id="airBillingNameRO" value="#rc.Traveler.getBookingDetail().getAirBillingName()#">
						<label for="airBillingNameRO">Name on Card *</label>
					</div>
				</div>

				<div class="mb0 row #(structKeyExists(rc.errors, 'airBillingAddress') ? 'error' : '')#">
					<div class="input-field col s12 m10 right">
						<input type="hidden" name="airBillingAddress" id="airBillingAddress">
						<input type="text" disabled readonly name="airBillingAddressRO" id="airBillingAddressRO" value="#rc.Traveler.getBookingDetail().getAirBillingAddress()#">
						<label for="airBillingAddressRO">Billing Address *</label>
					</div>
				</div>

				<div class="mb0 row #(structKeyExists(rc.errors, 'airBillingCity') ? 'error' : '')#">
					<div class="input-field col s12 m10 right">
						<input type="hidden" name="airBillingCity" id="airBillingCity">
						<input type="text" disabled readonly name="airBillingCityRO" id="airBillingCityRO" value="#rc.Traveler.getBookingDetail().getAirBillingCity()#">
						<label for="airBillingCityRO">City *</label>
					</div>
				</div>

				<div class="mb0 row #(structKeyExists(rc.errors, 'airBillingState') ? 'error' : '')#">
					<div class="input-field col s12 m10 right">
						<input type="hidden" name="airBillingState" id="airBillingState">
						<input type="hidden" name="airBillingZip" id="airBillingZip">
						<input type="text" disabled readonly name="airBillingStateRO" id="airBillingStateRO" value="#rc.Traveler.getBookingDetail().getAirBillingState()# #rc.Traveler.getBookingDetail().getAirBillingZip()#">
						<label for="airBillingStateRO">State, Zip *</label>
					</div>
				</div>

			</div>

			<div class="bold text-right">
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
				<i id="serviceFeeSpinner" class="fa fa-spin fa-spinner"></i>
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

			<div class="mb0 row #(structKeyExists(rc.errors, 'serviceFeeCCNumber') ? 'error' : '')#">
				<div class="input-field col s12 m10 right">
					<input type="hidden" name="serviceFeeCCName" id="serviceFeeCCName">
					<input type="hidden" name="serviceFeeCCType" id="serviceFeeCCType">
					<input type="hidden" name="serviceFeeCCNumber" id="serviceFeeCCNumber">
					<input type="hidden" name="serviceFeeCCNumberRight4" id="serviceFeeCCNumberRight4">
					<input type="text" disabled readonly name="serviceFeeCCNumberRO" id="serviceFeeCCNumberRO" value="#rc.Traveler.getBookingDetail().getServiceFeeCCNumber()#">
					<label for="serviceFeeCCNumberRO">Card Number *</label>
				</div>
			</div>
		
			<div class="mb0 row ">
				<div class="input-field col s6 m5 right #(structKeyExists(rc.errors, 'serviceFeeCCCVV') ? 'error' : '')#">
					<input type="hidden" name="serviceFeeCCCVV" id="serviceFeeCCCVV">
					<input type="text" disabled readonly name="serviceFeeCCCVVRO" id="serviceFeeCCCVVRO" value="#rc.Traveler.getBookingDetail().getServiceFeeCCCVV()#">
					<label for="serviceFeeCCCVVRO">CVV Security Code *</label>
				</div>
				<div class="input-field col s6 m5 right #(structKeyExists(rc.errors, 'serviceFeeCCExpiration') ? 'error' : '')#">
					<input type="hidden" name="serviceFeeCCExpiration" id="serviceFeeCCExpiration">
					<input type="hidden" name="serviceFeeCCMonth" id="serviceFeeCCMonth">
					<input type="hidden" name="serviceFeeCCMonthDisplay" id="serviceFeeCCMonthDisplay">
					<input type="hidden" name="serviceFeeCCYear" id="serviceFeeCCYear">
					<cfset serviceFeeMonthAsString = (len(rc.Traveler.getBookingDetail().getServiceFeeCCMonth()) ? monthAsString(rc.Traveler.getBookingDetail().getServiceFeeCCMonth()) : '') />
					<input type="text" disabled readonly name="serviceFeeCCMonthRO" id="serviceFeeCCMonthRO" value="#serviceFeeMonthAsString# #rc.Traveler.getBookingDetail().getServiceFeeCCYear()#">
					<label for="serviceFeeCCMonthRO">Expiration *</label>
				</div>
			</div>
		
		
			<div class="mb0 row #(structKeyExists(rc.errors, 'serviceFeeBillingName') ? 'error' : '')#">
				<div class="input-field col s12 m10 right">
					<input type="hidden" name="serviceFeeBillingName" id="serviceFeeBillingName">
					<input type="text" disabled readonly name="serviceFeeBillingNameRO" id="serviceFeeBillingNameRO" value="#rc.Traveler.getBookingDetail().getServiceFeeBillingName()#">
					<label for="serviceFeeBillingNameRO">Name on Card *</label>
				</div>
			</div>
		
			<div class="mb0 row #(structKeyExists(rc.errors, 'serviceFeeBillingAddress') ? 'error' : '')#">
				<div class="input-field col s12 m10 right">
					<input type="hidden" name="serviceFeeBillingAddress" id="serviceFeeBillingAddress">
					<input type="text" disabled readonly name="serviceFeeBillingAddressRO" id="serviceFeeBillingAddressRO" value="#rc.Traveler.getBookingDetail().getServiceFeeBillingAddress()#">
					<label for="serviceFeeBillingAddressRO">Billing Address *</label>
				</div>
			</div>
		
			<div class="mb0 row #(structKeyExists(rc.errors, 'serviceFeeBillingCity') ? 'error' : '')#">
				<div class="input-field col s12 m10 right">
					<input type="hidden" name="serviceFeeBillingCity" id="serviceFeeBillingCity">
					<input type="text" disabled readonly name="serviceFeeBillingCityRO" id="serviceFeeBillingCityRO" value="#rc.Traveler.getBookingDetail().getServiceFeeBillingCity()#">
					<label for="serviceFeeBillingCityRO">City *</label>
				</div>
			</div>
		
			<div class="mb0 row #(structKeyExists(rc.errors, 'serviceFeeBillingState') ? 'error' : '')#">
				<div class="input-field col s12 m10 right">
					<input type="hidden" name="serviceFeeBillingState" id="serviceFeeBillingState">
					<input type="hidden" name="serviceFeeBillingZip" id="serviceFeeBillingZip">
					<input type="text" disabled readonly name="serviceFeeBillingStateRO" id="serviceFeeBillingStateRO" value="#rc.Traveler.getBookingDetail().getServiceFeeBillingState()# #rc.Traveler.getBookingDetail().getServiceFeeBillingZip()#">
					<label for="serviceFeeBillingStateRO">State, Zip *</label>
				</div>
			</div>
		
		</div>
		<br>
		</div>
	</cfif>

	<cfif rc.hotelSelected>
		<div id="hotelPayment">

		<div class="form-group #(structKeyExists(rc.errors, 'hotelFOPID') ? 'error' : '')#">
			<label class="control-label  col-sm-4 col-xs-12" for="hotelFOPID"><strong>Hotel Payment *</strong></label>
			<div class="col-sm-8 col-xs-12" id="hotelFOPIDDiv">
				<i id="hotelSpinner" class="fa fa-spin fa-spinner"></i>
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

			<div class="row" id="copyAirCCDiv">
				<div class="input-field col s12 m10 right">
					<label class="copyAirCC">
						<input type="checkbox" class="filled-in" name="copyAirCC" id="copyAirCC" value="1">
						<span>Copy air payment</span>
					</label>
				</div><br><br>
			</div>

			<div class="mb0 row #(structKeyExists(rc.errors, 'hotelCCNumber') ? 'error' : '')#">
				<div class="input-field col s12 m10 right">
					<input type="hidden" name="hotelCCName" id="hotelCCName">
					<input type="hidden" name="hotelCCType" id="hotelCCType">
					<input type="hidden" name="hotelCCNumber" id="hotelCCNumber">
					<input type="hidden" name="hotelCCNumberRight4" id="hotelCCNumberRight4">
					<input type="text" disabled readonly name="copyAirCCNumber" id="copyAirCCNumber" value="#rc.Traveler.getBookingDetail().getHotelCCNumber()#">
					<label for="copyAirCCNumber">Card Number *</label>
				</div>
			</div>
		
			<div class="mb0 row #(structKeyExists(rc.errors, 'hotelCCExpiration') ? 'error' : '')#">
				<div class="input-field col s12 m10 right">
					<input type="hidden" name="hotelCCExpiration" id="hotelCCExpiration">
					<input type="hidden" name="hotelCCMonth" id="hotelCCMonth">
					<input type="hidden" name="hotelCCMonthDisplay" id="hotelCCMonthDisplay">
					<input type="hidden" name="hotelCCYear" id="hotelCCYear">
					<cfset hotelMonthAsString = (len(rc.Traveler.getBookingDetail().getHotelCCMonth()) ? monthAsString(rc.Traveler.getBookingDetail().getHotelCCMonth()) : '') />
					<input type="text" disabled readonly name="copyAirCCMonthYear" id="copyAirCCMonthYear" value="#hotelMonthAsString# #rc.Traveler.getBookingDetail().getHotelCCYear()#">
					<label for="copyAirCCMonthYear">Expiration *</label>
				</div>
			</div>
		
			<div class="mb0 row #(structKeyExists(rc.errors, 'hotelBillingName') ? 'error' : '')#">
				<div class="input-field col s12 m10 right">
					<input type="hidden" name="hotelBillingName" id="hotelBillingName">
					<input type="text" disabled readonly name="copyAirBillingName" id="copyAirBillingName" value="#rc.Traveler.getBookingDetail().getHotelBillingName()#">
					<label for="copyAirBillingName">Name on Card *</label>
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
			<div class="bold text-center">
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
			<div class="bold text-center">
				<a rel="popover" data-original-title="Hotel payment and cancellation policy" data-content="#hotelPolicies#" href="##" />
					Hotel payment and cancellation policy
				</a>
			</div>
		</cfif>
		<br>
		</div>
	</cfif>

	<cfif rc.vehicleSelected>
		<div id="carPayment">

			<div class="form-group">
				<label class="control-label col-sm-4 col-xs-12" for="carFOPID"><strong>Car Payment *</strong></label>
				<div class="controls col-sm-8 col-xs-12">
					<i id="carSpinner" class="fa fa-spin fa-spinner"></i>
					<select name="carFOPID" id="carFOPID" class="form-control">
					</select>
				</div>
			</div>

			<div class="bold text-center">
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
