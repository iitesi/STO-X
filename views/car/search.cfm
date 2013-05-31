<div id="displaySearchWindow" class="modal container hide fade" tabindex="-1" role="dialog" aria-labelledby="mySearchWindow" aria-hidden="true">
	<div class="searchContainer">
		<div class="modal-header">
			<button type="button" class="close" data-dismiss="modal" aria-hidden="true">x</button>
			<h3 id="myModalHeader">CHANGE CAR SEARCH</h3>
		</div>
		<cfoutput>
			<div class="modal-body">
				<div id="myModalBody">
					<form id="carSearchForm" class="form-search">
						<input type="hidden" id="searchID" name="searchID" value="#rc.searchID#" />
						<div id="car-options" class="full-width">
							<!--- <div class="form-search-heading">Change Car Search</div> --->
							<div class="row">
								<div class="form-element-label">
									<label for="car-location">location</label>
								</div>
								<div class="form-element-content">
									<input type="text" class="input-block-level airport-select2" id="car-location" name="car-location" value="" placeholder="#rc.formData.carPickupAirport#" />
								</div>
							</div>
							<div class="row" id="car-pickup-wrapper">
								<div class="form-element-label">
									<label for="return-date">pick up</label>
								</div>
								<div class="form-element-content">
									<div style="width: 50%; float: left;">
										<input id="car-pickup-date" type="text" name="car-pickup-date" class="inline-label" value="#rc.formData.carPickupDate#" placeholder="#rc.formData.carPickupDate#" />
									</div>
									<div style="width: 30%; float: left;">
										<div class="btn-group">
											<button class="btn" id="car-pickup-time" style="width: 125px;" value="#rc.formData.carPickupTimeValue#">#rc.formData.carPickupTimeDisplay#</button>
											<button class="btn dropdown-toggle" data-toggle="dropdown">
												<span class="caret"></span>
											</button>
											<ul class="dropdown-menu">
												<li><a href="##" data-value="00:00">Any time</a></li>
												<li><a href="##" data-value="06:00">Early Morning</a></li>
												<li><a href="##" data-value="10:00">Late Morning</a></li>
												<li><a href="##" data-value="14:00">Afternoon</a></li>
												<li><a href="##" data-value="18:00">Evening</a></li>
												<li><a href="##" data-value="23:00">Red Eye</a></li>
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
										</div>
									</div>
								</div>
							</div>
							<div class="row" id="car-dropoff-wrapper">
								<div class="form-element-label">
									<label for="return-date">drop off</label>
								</div>
								<div class="form-element-content">
									<div style="width: 50%; float: left;">
										<input id="car-dropoff-date" type="text" name="car-dropoff-date" class="inline-label" value="#rc.formData.carDropoffDate#" placeholder="#rc.formData.carDropoffDate#" />
									</div>
									<div style="width: 30%; float: left;">
										<div class="btn-group">
											<button class="btn" id="car-dropoff-time" style="width: 125px;" value="#rc.formData.carDropoffTimeValue#">#rc.formData.carDropoffTimeDisplay#</button>
											<button class="btn dropdown-toggle" data-toggle="dropdown">
												<span class="caret"></span>
											</button>
											<ul class="dropdown-menu">
												<li><a href="##" data-value="00:00">Any time</a></li>
												<li><a href="##" data-value="06:00">Early Morning</a></li>
												<li><a href="##" data-value="10:00">Late Morning</a></li>
												<li><a href="##" data-value="14:00">Afternoon</a></li>
												<li><a href="##" data-value="18:00">Evening</a></li>
												<li><a href="##" data-value="23:00">Red Eye</a></li>
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
										</div>
									</div>
								</div>
							</div>
						</div>
						<div id="calendar-row" class="full-width">
							<div class="row">
								<div class="form-element-label">
									<label>&nbsp;</label>
								</div>
								<div class="form-element-content">
									<div id="start-calendar-wrapper" style="width: 49%; float: left; clear: none;"></div>
									<div id="end-calendar-wrapper" style="width: 49%; float: left; clear: none;"></div>
								</div>
							</div>
						</div>
					</form>
				</div>
			</div>
		</cfoutput>
		<div class="modal-footer">
			<!--- Search button that, when clicked, will trigger modal window before results are displayed. --->
			<div id="submit-wrapper" class="row" style="text-align: right;">
				<a href="#pleaseWait" id="btnFormSubmit" class="btn btn-large btn-primary btn-small" type="submit" data-toggle="modal">Update Search</a>
			</div>

			<!--- Modal window to be displayed while search is occurring. --->
			<div id="pleaseWait" class="modal container hide fade" tabindex="-1" role="dialog" aria-labelledby="myPleaseWaitWindow" aria-hidden="true">
				<div class="modal-header">
					<h3 id="waitModalHeader">Please Wait</h3>
				</div>
				<div id="waitModalBody" class="modal-body">
					<p><i class="icon-spinner icon-spin icon-large"></i> Searching for...</p>
				</div>
			</div>
		</div>
	</div>
</div>