<div id="displaySearchWindow" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="mySearchWindow" aria-hidden="true">
	<div class="modal-dialog" role="document">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"><i class="fa fa-remove"></i></button>
				<h3 id="myModalHeader">CHANGE CAR SEARCH</h3>
			</div>
			<cfoutput>
				<div class="modal-body form form-horizontal">
					<form id="carSearchForm" class="form-search">
							<input type="hidden" id="searchID" name="searchID" value="#rc.searchID#" />
							<div id="car-options" class="full-width">
								<div class="form-group">
									<div class="control-label">
										<label>&nbsp;</label>
									</div>
									<div class="form-element-content">
										<div id="car-dropoff-option" class="btn-group" data-toggle="buttons-radio" style="float:left; text-align:right;">
											<button id="car-dropoff-same" class="car-dropoff-option btn btn-mini <cfif rc.formData.carDifferentLocations EQ 0>btn-primary</cfif>" value="same">Same Drop-off</button>
											<button id="car-dropoff-different" class="car-dropoff-option btn btn-mini <cfif rc.formData.carDifferentLocations EQ 1>btn-primary</cfif>" value="different">Different Drop-off</button>
										</div>
									</div>
								</div>
								<div class="form-group">
									
									<label for="car-pickup-airport" class="col-sm-3 control-label">Pick-up</label>
									
									<div class="col-sm-9">
										<input type="text" class="input-block-level airport-select2" id="car-pickup-airport" name="car-pickup-airport" value="#rc.formData.carPickupAirport#" placeholder="#rc.formData.carPickupAirport#" />
										<div id="car-pickup-airport_hidden" class="hidden" style="float:left;">
											<span class="required">Pick-up airport is missing or invalid. Begin typing to select your airport from the list.</span>
										</div>
									</div>
								</div>
								<div class="form-group" id="car-pickup-wrapper">
									
										<label class="col-sm-3 control-label" for="return-date">Pick-up</label>
									
								
										<div class="col-sm-4">
											<input id="car-pickup-date" type="text" name="car-pickup-date" class="inline-label start-date form-control" value="#rc.formData.carPickupDate#" placeholder="#rc.formData.carPickupDate#" data-date-format="mm/dd/yyyy" />
										</div>
										<div class="col-sm-5">
											<select class="form-control" id="car-pickup-time">
												<option value="06:00">6:00 AM</option>
												<option value="07:00">7:00 AM</option>
												<option value="08:00">8:00 AM</option>
												<option value="09:00">9:00 AM</option>
												<option value="10:00">10:00 AM</option>
												<option value="11:00">11:00 AM</option>
												<option value="12:00">12:00 PM</option>
												<option value="13:00">1:00 PM</option>
												<option value="14:00">2:00 PM</option>
												<option value="15:00">3:00 PM</option>
												<option value="16:00">4:00 PM</option>
												<option value="17:00">5:00 PM</option>
												<option value="18:00">6:00 PM</option>
												<option value="19:00">7:00 PM</option>
												<option value="20:00">8:00 PM</option>
												<option value="21:00">9:00 PM</option>
												<option value="22:00">10:00 PM</option>
												<option value="23:00">11:00 PM</option>
											</select>
											<script type="text/javascript">
												$('##car-pickup-time option[value="#rc.formData.carPickupTimeValue#"]').prop('selected', true);
											</script>
											<!--<div class="btn-group">
												<button class="btn" id="car-pickup-time" style="width: 125px;" value="#rc.formData.carPickupTimeValue#">#rc.formData.carPickupTimeDisplay#</button>
												<button class="btn dropdown-toggle" data-toggle="dropdown">
													<span class="caret"></span>
												</button>
												<ul class="dropdown-menu">
													<!--- <li><a href="##" data-value="Anytime">Anytime</a></li>
													<li><a href="##" data-value="Early Morning">Early Morning</a></li>
													<li><a href="##" data-value="Late Morning">Late Morning</a></li>
													<li><a href="##" data-value="Afternoon">Afternoon</a></li>
													<li><a href="##" data-value="Evening">Evening</a></li>
													<li><a href="##" data-value="Red Eye">Red Eye</a></li> --->
													<li><a href="##" data-value="06:00"> 6:00 AM</a></li>
													<li><a href="##" data-value="07:00"> 7:00 AM</a></li>
													<li><a href="##" data-value="08:00"> 8:00 AM</a></li>
													<li><a href="##" data-value="09:00"> 9:00 AM</a></li>
													<li><a href="##" data-value="10:00">10:00 AM</a></li>
													<li><a href="##" data-value="11:00">11:00 AM</a></li>
													<li><a href="##" data-value="12:00">12:00 PM</a></li>
													<li><a href="##" data-value="13:00"> 1:00 PM</a></li>
													<li><a href="##" data-value="14:00"> 2:00 PM</a></li>
													<li><a href="##" data-value="15:00"> 3:00 PM</a></li>
													<li><a href="##" data-value="16:00"> 4:00 PM</a></li>
													<li><a href="##" data-value="17:00"> 5:00 PM</a></li>
													<li><a href="##" data-value="18:00"> 6:00 PM</a></li>
													<li><a href="##" data-value="19:00"> 7:00 PM</a></li>
													<li><a href="##" data-value="20:00"> 8:00 PM</a></li>
													<li><a href="##" data-value="21:00"> 9:00 PM</a></li>
													<li><a href="##" data-value="22:00">10:00 PM</a></li>
													<li><a href="##" data-value="23:00">11:00 PM</a></li>
												</ul>
											</div> -->
										</div>
										<div id="car-pickup-date_hidden" class="hidden" style="float:left;">
											<span class="required">Pick-up date is missing or invalid (must be in 'mm/dd/yyyy' format). Select your date from the calendar below.</span>
										</div>
									
								</div>
								<div class="form-group hidden" id="car-dropoff-airport-wrapper">
									
										<label  class="col-sm-3 control-label" for="car-dropoff-airport">Drop-off</label>
									
									<div class="col-sm-9">
										<input type="text" class="input-block-level airport-select2" id="car-dropoff-airport" name="car-dropoff-airport" value="#rc.formData.carDropoffAirport#" placeholder="#rc.formData.carDropoffAirport#" />
										<div id="car-dropoff-airport_hidden" class="hidden" style="float:left;">
											<span class="required">Drop-off airport is missing or invalid. Begin typing to select your airport from the list.</span>
										</div>
									</div>
								</div>
								<div class="form-group" id="car-dropoff-wrapper">
									
									<label class="col-sm-3 control-label" for="return-date">drop-off</label>
									
									<div class="col-sm-4">
											<input id="car-dropoff-date" type="text" name="car-dropodd-date" class="inline-label end-date form-control" value="#rc.formData.carDropoffDate#" placeholder="#rc.formData.carDropoffDate#" data-date-format="mm/dd/yyyy" />
										</div>
									<div class="col-sm-5">
										<select class="form-control" id="car-dropoff-time">
											<option value="06:00">6:00 AM</option>
											<option value="07:00">7:00 AM</option>
											<option value="08:00">8:00 AM</option>
											<option value="09:00">9:00 AM</option>
											<option value="10:00">10:00 AM</option>
											<option value="11:00">11:00 AM</option>
											<option value="12:00">12:00 PM</option>
											<option value="13:00">1:00 PM</option>
											<option value="14:00">2:00 PM</option>
											<option value="15:00">3:00 PM</option>
											<option value="16:00">4:00 PM</option>
											<option value="17:00">5:00 PM</option>
											<option value="18:00">6:00 PM</option>
											<option value="19:00">7:00 PM</option>
											<option value="20:00">8:00 PM</option>
											<option value="21:00">9:00 PM</option>
											<option value="22:00">10:00 PM</option>
											<option value="23:00">11:00 PM</option>
										</select>
										<script type="text/javascript">
											$('##car-dropoff-time option[value="#rc.formData.carDropoffTimeValue#"]').prop('selected', true);
										</script>
										<!--<div class="btn-group">
											<button class="btn" id="car-pickup-time" style="width: 125px;" value="#rc.formData.carPickupTimeValue#">#rc.formData.carPickupTimeDisplay#</button>
											<button class="btn dropdown-toggle" data-toggle="dropdown">
												<span class="caret"></span>
											</button>
											<ul class="dropdown-menu">
												<!--- <li><a href="##" data-value="Anytime">Anytime</a></li>
												<li><a href="##" data-value="Early Morning">Early Morning</a></li>
												<li><a href="##" data-value="Late Morning">Late Morning</a></li>
												<li><a href="##" data-value="Afternoon">Afternoon</a></li>
												<li><a href="##" data-value="Evening">Evening</a></li>
												<li><a href="##" data-value="Red Eye">Red Eye</a></li> --->
												<li><a href="##" data-value="06:00"> 6:00 AM</a></li>
												<li><a href="##" data-value="07:00"> 7:00 AM</a></li>
												<li><a href="##" data-value="08:00"> 8:00 AM</a></li>
												<li><a href="##" data-value="09:00"> 9:00 AM</a></li>
												<li><a href="##" data-value="10:00">10:00 AM</a></li>
												<li><a href="##" data-value="11:00">11:00 AM</a></li>
												<li><a href="##" data-value="12:00">12:00 PM</a></li>
												<li><a href="##" data-value="13:00"> 1:00 PM</a></li>
												<li><a href="##" data-value="14:00"> 2:00 PM</a></li>
												<li><a href="##" data-value="15:00"> 3:00 PM</a></li>
												<li><a href="##" data-value="16:00"> 4:00 PM</a></li>
												<li><a href="##" data-value="17:00"> 5:00 PM</a></li>
												<li><a href="##" data-value="18:00"> 6:00 PM</a></li>
												<li><a href="##" data-value="19:00"> 7:00 PM</a></li>
												<li><a href="##" data-value="20:00"> 8:00 PM</a></li>
												<li><a href="##" data-value="21:00"> 9:00 PM</a></li>
												<li><a href="##" data-value="22:00">10:00 PM</a></li>
												<li><a href="##" data-value="23:00">11:00 PM</a></li>
											</ul>
										</div> -->
									</div>
									<div id="car-dropoff-date_hidden" class="hidden" style="float:left;">
										<span class="required">Drop-off date is missing or invalid (must be in 'mm/dd/yyyy' format). Select your date from the calendar below.</span>
									</div>
										
								</div>
							</div>
							
							<div id="calendar-row" class="modal-calendar-row">
								<div class="row">
									<div class="col-sm-5" id="hotel-date-wrapper">
										<div class="form-group">
											<label class="control-label">Pick-up Date</label>
											
										</div>
										<div id="start-calendar-wrapper" class="calender-wrapper"></div>
									</div>
									<div class="col-sm-offset-2 col-sm-5">
										<div class="form-group">
											<label class="control-label">Drop-off Date</label>
											
										</div>
										<div id="end-calendar-wrapper" class="calender-wrapper"> </div>
									</div>
								</div>
							</div>
						</form>
				</div>
			</cfoutput>
			<div class="modal-footer">
			<!--- Search button that, when clicked, will trigger modal window before results are displayed. --->
			<div id="submit-wrapper" class="row" style="text-align: right;">
				<!--- <a href="#pleaseWait" id="btnFormSubmit" class="btn btn-large btn-primary btn-small" type="submit" data-toggle="modal" data-backdrop="static">Update Search</a> --->
				<a href="##" id="btnFormSubmit" class="btn btn-large btn-primary btn-small" type="submit">Update Search</a>
			</div>
		</div>
		</div>
	</div>
</div>

<!--- Modal window to be displayed while search is occurring. --->
<div id="pleaseWait" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myPleaseWaitWindow" aria-hidden="true">
	<div class="modal-dialog" role="document">
		<div class="modal-content">
			<div class="modal-header">
				<h4 id="myModalHeader"><i class="fa fa-spinner fa-spin"></i> One moment, we're searching for...</h4>
			</div>
			<div id="waitModalBody" class="modal-body"></div>
		</div>
	</div>
</div>