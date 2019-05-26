<cfsilent>
	<cfparam name="rc.filter" default="" />
	<cfparam name="rc.locationKey" default="">
	<cfsavecontent variable="filterHeader">
		<script type='text/javascript' src='assets/js/bootstrap-datepicker.js'></script>
		<script type='text/javascript' src='assets/js/date.format.js'></script>
		<script type='text/javascript' src='assets/js/select2.min.js'></script>
		<script type='text/javascript' src='assets/localdata/airports-us.js'></script>
		<script type='text/javascript' src='assets/js/car/search.js'></script>
		<script type="text/javascript">
		<cfoutput>
			var carresults = [
				<cfset nCount = 0>
				<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="sCategory">
					<cfif NOT structIsEmpty(session.searches[rc.SearchID].stCars[sCategory])>
						<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="sVendor">
							<cfif nCount NEQ 0>,</cfif>
							<cfset nCount++>
							<cfif structKeyExists(session.searches[rc.SearchID].stCars[sCategory], sVendor)>
								[#session.searches[rc.SearchID].stCars[sCategory][sVendor].sJavascript#]
							<cfelse>
								['#LCase(sCategory)##LCase(sVendor)#','#LCase(sCategory)#','#LCase(sVendor)#',0,0]
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>];

			var carcategories = [
				<cfset nCount = 0>
				<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="sCategory">
					<cfif nCount NEQ 0>,</cfif>
					<cfset nCount++>
					['#LCase(sCategory)#',#(rc.Policy.Policy_CarTypeRule EQ 1 AND NOT ArrayFindNoCase(rc.Policy.aCarSizes, sCategory) ? 0 : 1)#]
				</cfloop>];

			var carvendors = [
				<cfset nCount = 0>
				<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="sVendor">
					<cfif nCount NEQ 0>,</cfif>
					<cfset nCount++>
					['#LCase(sVendor)#',#(rc.Policy.Policy_CarPrefRule EQ 1 AND NOT ArrayFindNoCase(rc.Account.aPreferredCar, sVendor) ? 0 : 1)#]
				</cfloop>];
		</cfoutput>

		function filterCar(howFilter) {
			const dfd = jQuery.Deferred();

			try {
			
				if (howFilter == 'clearAll') {
					$(":checkbox").prop('checked', false);
					$("#btnPolicy").parent().removeClass('active');
					$("#fltrVendorSelectAll").val(true);
					$("#fltrCarCategorySelectAll").val(true);
				}

				// var policy = $("#btnPolicy").parent().hasClass('active');
				var policy = $('input[name=policy]:checked').val() == 'true';
				var nCount = 0;

				// Logic for displaying or not displaying a particular result
				// If (fltrVendorSelectAll is true and fltrCarCategorySelectAll is true)
				// OR (fltrVendorSelectAll is false and that vendor is checked)
				// OR (fltrCarCategorySelectAll is false and that category is checked)
				// AND in policy, show
				// Else, hide
				let allVendors = $('#vendor-all').hasClass('active');
				let allCategories = $('#types-all').hasClass('active');

				// console.log(`All Vendors: ${allVendors}`);
				// console.log(`All Categories: ${allCategories}`);
				for (loopcnt = 0; loopcnt <= (carresults.length-1); loopcnt++) {
					var car = carresults[loopcnt];
					var inpolicy = ((policy == false) || (policy == true && car[3] == 1)) ? true : false;

					if (((allVendors && allCategories)
						|| ((!allVendors && ($( "#fltrVendor" + car[2] ).is(':checked') == true))
							&& (allCategories
								|| !allCategories && ($( "#fltrCategory" + car[1] ).is(':checked') == true)))
						|| ((!allCategories && ($( "#fltrCategory" + car[1] ).is(':checked') == true))
							&& (allVendors
								|| !allVendors && ($( "#fltrVendor" + car[2] ).is(':checked') == true))))
						) {
						$( "#" + car[0] ).removeClass('hidden');//.css('display','table-cell');
						nCount++;
					}
					else {
						$( "#" + car[0] ).addClass('hidden');
					}
				}
				// console.log('./carresults loop --------------------------------------')
				for (loopcnt = 0; loopcnt <= (carcategories.length-1); loopcnt++) {
					var category = carcategories[loopcnt];
					var inpolicy = ((policy == false) || (policy == true && category[1] == 1)) ? true : false;

					if (($("#types-all").is(':checked') || ($( "#fltrCategory" + category[0] ).is(':checked') == true)) && inpolicy) {
						$( '#row' + category ).removeClass('hidden');
					}
					else {
						$( '#row' + category ).addClass('hidden');
					}

					// If all the cars in a category are hidden then hide that category too - don't like empty rows
					if($('#row' + category).find('td:not(.carTypeCol):visible').length > 0) {
						$('#row' + category).removeClass('hidden');
					} else {
						$('#row' + category).addClass('hidden');
					}
				}
				// console.log('./carcategories loop --------------------------------------')
				for (loopcnt = 0; loopcnt <= (carvendors.length-1); loopcnt++) {
					var vendor = carvendors[loopcnt];
					var inpolicy = ((policy == false) || (policy == true && vendor[1] == 1)) ? true : false;
					if (allVendors || ($( "#fltrVendor" + vendor[0] ).is(':checked') && inpolicy)) {
						$( '#vendor' + vendor[0] ).removeClass('hidden');
					}
					else {
						$( '#vendor' + vendor[0] ).addClass('hidden');
					}
				}
				// console.log('./carvendors loop--------------------------------------')

				if(nCount == 0) {
					if(carresults.length == 0) {
						$("#noSearchResults").removeClass("hidden").show();
					}
					else {
						$("#noFilteredResults").removeClass("hidden").show();
					}
					$("#vendorRow").hide();
					$("#categoryRow").hide();
				}
				else {
					$("#noSearchResults").hide();
					$("#noFilteredResults").hide();
					$("#vendorRow").show();
					$("#categoryRow").show();
				}
				postFilter();
				dfd.resolve();

			}
			catch(e){
				postFilter();
				dfd.resolve();
			}

			return dfd;
		}

		function postFilter() {
			syncVendorToLocation();
		}

		function syncVendorToLocation() {
			var vendorInputsSelected = $("input[type=checkbox][id^=fltrVendor]:checked");
			var selectedVendors = vendorInputsSelected.map(function(){
				return this.value;
			}).get();

			$("#pickUpLocationKey option, #dropOffLocationKey option").each(function(){
				$(this).toggle(selectedVendors.includes($(this).data('vendor')));
			});
		}

		function updateCount(){
			$("#numTotal").html($('.carResults tbody .btn').length);
			$("#numFiltered").html($('.carResults tbody .btn:visible').length);
		}

		$(function(){
			$('#filterbar').on('click', 'a.dropdown-toggle', function (e) {
				var $target = $(e.target);
				var $ddown = $target.parent();
				var $others = $('#filterbar a.dropdown-toggle').parent().filter(function(){
					return $(this).attr('id') != $ddown.attr('id');
				})
				$others.removeClass('open')
				$(this).parent().toggleClass('open');
			});
			$('body').on('click', function (e) {
				var $target = $(e.target);
				var $ddown = $target.closest('.dropdown');
				if (!$ddown.length){
					$('#filterbar .dropdown.open').removeClass('open')
				}
			});
			$('#filterbar').on('click', '[data-multiselect-only]', function (e) {
				e.stopImmediatePropagation();
				var $link = $(this);
				var $input = $link.parent().find('input[type=checkbox]')
				var $wrapper = $link.parents('.multifilterwrapper');
				var $switch = $wrapper.find('.switch-input');
				var name = $input.attr('name');
				var value = $input.val();
				
				$switch.prop('checked',false);

				$wrapper.find('.multifilter').each(function(){
					$(this).prop('checked',$(this).val()==value);
				});

				$('#filterbar').trigger('runsearch');
				
			});
			$('#filterbar').on('click', '#filterPolicy input[name=policy]', function (e) {
				$('#filterbar').trigger('runsearch');
			});
			
			$('#filterbar').on('click', '.multifilter', function (e) {
				var $link = $(this);
				var $wrapper = $link.parents('.multifilterwrapper');
				var $inputs = $wrapper.find('input[type=checkbox].multifilter');
				var $checkedInputs = $wrapper.find('input[type=checkbox].multifilter:checked');
				var $switch = $wrapper.find('.switch-input');

				if($switch.length){
					var switchOn = $checkedInputs.length == 0 ? false : $checkedInputs.length == $inputs.length ? true : false;
					$switch.prop('checked', switchOn);
					if (switchOn){
						if(!$switch.hasClass('active')){
							$switch.addClass('active')
						} 
					}
					else {
						$switch.removeClass('active')
					}
				}
				$('#filterbar').trigger('runsearch');
			});

			$('#filterbar').on('click', '.switch-label', function (e) {
				e.stopImmediatePropagation();
				var $label = $(this);
				var $wrapper = $label.parents('.multifilterwrapper');
				var $switch = $wrapper.find('.switch-input');
				$switch.toggleClass('active');
				var onOff = $switch.is(":checked");

				$wrapper.find('.multifilter').each(function(){
					$(this).prop('checked',!onOff);
				});

				$('#filterbar').trigger('runsearch');
			});

			$('#filterbar').on('runsearch', function() {
				filterCar().then(updateCount);
			});

			// first run on load
			$('#filterbar').trigger('runsearch');
			
		});
		</script> 
		<!--- Set the CARINPOLICYDEFAULT javascript variable before calling filter.js which uses this variable --->
		<cfoutput> 
			<script type="text/javascript">
        		var carInPolicyDefault = '#rc.account.carInPolicyDefault#';
    		</script>
    	</cfoutput>
		<!---script type='text/javascript' src='assets/js/car/filter.js'></script--->
		<link rel='stylesheet' type='text/css' href='assets/css/datepicker.css' />
		<link rel='stylesheet' type='text/css' href='assets/css/select2.css' />
		<link rel='stylesheet' type='text/css' href='assets/css/search.css' />
		<style type='text/css'>
			.searchContainer {
				max-width: 680px;
				width: 680px;
			}
			.modal.searchForm {
				position: absolute;
				width: 680px;
				height: 600px;
				margin: -80px 0px 0 -360px;
			}
			.modal-body {
				overflow-y: auto;
			}
			.dropdown-menu {
				max-height: 350px;
				overflow-y: auto;
				overflow-x: hidden;
			}
			.navbar-default {
				background-color: #FFFFFF;
				background-image: none;
				box-shadow: none;
			}
			#filterVendors ul.dropdown-menu {
				width:350px;
			}
			#filterTypes ul.dropdown-menu, #pickupLocation ul.dropdown-menu {
				width:550px;
			}
			#filterPolicy ul.dropdown-menu {
				width:200px;
			}
			
			.vehicleTypeWrapper {
				display:flex;
				flex-direction:row;
				width:100%
			}
			.vehicleTypeWrapper ul {
				list-style-type:none;
				flex:1;
				padding-left:0;
				margin-left:0;
			}
			.vehicleTypeWrapper ul li {
				padding-right:10px;
			}
			.vehicleTypeWrapper ul li:first-child {
				font-weight: bold;
				border-bottom: 1px solid #ddd;
				font-size: 16px;
				padding-bottom: 10px;
			}

			
		</style>
	</cfsavecontent>
	<cfhtmlhead text="#filterHeader#" />
</cfsilent>

<!---First row--->
<div class="text-right">
	<cfoutput>
		<cfif structKeyExists(session.searches[rc.SearchID].stItinerary, 'Air') 
			OR structKeyExists(session.searches[rc.SearchID].stItinerary, 'Hotel')>
			<a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Car&Remove=1')#">Continue without car</a>
		</cfif>
	</cfoutput>
</div>

<div id="filterbar">
	<div class="navbar">
		<div class="filterbar-wrapper">
			<div class="navbar-header">
				<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#filter-navbar-collapse-1" aria-expanded="false">
					<span class="visible-xs">Filter</span>
					<span class="glyphicon glyphicon-filter"></span>
				</button>
			</div>
			<div class = "collapse navbar-collapse" id="filter-navbar-collapse-1">
				<ul class="nav nav-pills">
					<li role="presentation" class="dropdown" id="resultsCount">
						<a href="#" class="dropdown-toggle"><span id="numFiltered"></span> of <span id="numTotal"></span> cars displayed</a>
					</li>

					<li role="presentation" class="dropdown" id="filterVendors">
						<a href="#" class="dropdown-toggle" data-dflt="Vendors">Vendors <b class="caret"></b></a>
						<ul class="dropdown-menu multifilterwrapper" data-type="checkbox" data-name="vendor">
							<li>
								<input type="checkbox" checked id="vendor-all" name="vendor-all" class="switch-input active">
								<label for="vendor-all" class="switch-label">All Vendors</label>
							</li>
							<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="vendorCode">
								<li>
									<div class="md-checkbox">
										<cfoutput>
										<cfset vendorTitle = #StructKeyExists(application.stCarVendors, vendorCode) ? application.stCarVendors[vendorCode] : 'No Car Vendor found'#>
										<input id="fltrVendor#LCase(vendorCode)#" checked
											class="multifilter" 
											type="checkbox" 
											name="fltrVendor" 
											value="#vendorCode#" 
											data-title="#vendorTitle#" 
											title="#vendorTitle#" 
											data-hrv="#vendorTitle#">
										<label for="fltrVendor#LCase(vendorCode)#">
											#StructKeyExists(application.stCarVendors, vendorCode) ? application.stCarVendors[vendorCode] : 'No Car Vendor found'#
										</label>
										<div data-multiselect-only>only</div>
										</cfoutput>
									</div>
								</li>
							</cfloop>
						</ul>
					</li>
					<li role="presentation" class="dropdown" id="filterTypes">
						<a href="#" class="dropdown-toggle" data-dflt="Types">Car Types <b class="caret"></b></a>
						<ul class="dropdown-menu multifilterwrapper" data-type="checkbox" data-name="types">
							<li>
								<input type="checkbox" checked id="types-all" name="types-all" class="switch-input active">
								<label for="types-all" class="switch-label">All Types</label>
							</li>
							<li class="vehicleTypeWrapper">
								<ul>
									<li>Car</li>
									<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="carCategory">
										<cfif Right(carCategory, 3) IS "car" AND NOT structIsEmpty(session.searches[rc.SearchID].stCars[carCategory])>
											<li>
												<div class="md-checkbox">
													<cfoutput>
													<cfset vendorTitle = #StructKeyExists(application.stCarVendors, vendorCode) ? application.stCarVendors[vendorCode] : 'No Car Vendor found'#>
													<input id="fltrCategory#LCase(carCategory)#" checked
														class="multifilter" 
														type="checkbox" 
														name="fltrCategory" 
														value="#carCategory#" 
														data-title="#Left(carCategory, Len(carCategory)-3)#" 
														title="#Left(carCategory, Len(carCategory)-3)#" 
														data-hrv="#Left(carCategory, Len(carCategory)-3)#">
													<label for="fltrCategory#LCase(carCategory)#">
														#Left(carCategory, Len(carCategory)-3)#
													</label>
													<div data-multiselect-only>only</div>
													</cfoutput>
												</div>
											</li>
										</cfif>
									</cfloop>
								</ul>

								<ul>
									<li>Van</li>
									<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="carCategory">
										<cfif Right(carCategory, 3) IS "van" AND NOT structIsEmpty(session.searches[rc.SearchID].stCars[carCategory])>
											<li>
												<div class="md-checkbox">
													<cfoutput>
													<cfset vendorTitle = #StructKeyExists(application.stCarVendors, vendorCode) ? application.stCarVendors[vendorCode] : 'No Car Vendor found'#>
													<input id="fltrCategory#LCase(carCategory)#" checked
														class="multifilter" 
														type="checkbox" 
														name="fltrCategory" 
														value="#carCategory#" 
														data-title="#Left(carCategory, Len(carCategory)-3)#" 
														title="#Left(carCategory, Len(carCategory)-3)#" 
														data-hrv="#Left(carCategory, Len(carCategory)-3)#">
													<label for="fltrCategory#LCase(carCategory)#">
														#Left(carCategory, Len(carCategory)-3)#
													</label>
													<div data-multiselect-only>only</div>
													</cfoutput>
												</div>
											</li>
										</cfif>
									</cfloop>
								</ul>

								<ul>
									<li>SUV</li>
									<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="carCategory">
										<cfif Right(carCategory, 3) IS "suv" AND NOT structIsEmpty(session.searches[rc.SearchID].stCars[carCategory])>
											<li>
												<div class="md-checkbox">
													<cfoutput>
													<cfset vendorTitle = #StructKeyExists(application.stCarVendors, vendorCode) ? application.stCarVendors[vendorCode] : 'No Car Vendor found'#>
													<input id="fltrCategory#LCase(carCategory)#" checked
														class="multifilter" 
														type="checkbox" 
														name="fltrCategory" 
														value="#carCategory#" 
														data-title="#Left(carCategory, Len(carCategory)-3)#" 
														title="#Left(carCategory, Len(carCategory)-3)#" 
														data-hrv="#Left(carCategory, Len(carCategory)-3)#">
													<label for="fltrCategory#LCase(carCategory)#">
														#Left(carCategory, Len(carCategory)-3)#
													</label>
													<div data-multiselect-only>only</div>
													</cfoutput>
												</div>
											</li>
										</cfif>
									</cfloop>
								</ul>
							</li>
							
						</ul>
					</li>
					<li role="presentation" class="dropdown" id="filterPolicy">
						<a href="#" class="dropdown-toggle">In Policy <b class="caret"></b></a>
						<ul class="dropdown-menu dropdown-menu-right">
							<li>
								<div class="md-radio">
									<input id="inpolicy" checked type="radio" name="policy" title="In Policy" value="true">
									<label for="inpolicy">In Policy</label>
								</div>
							</li>
							<li>
								<div class="md-radio">
									<input id="anypolicy" type="radio" name="policy" title="All Options" value="false">
									<label for="anypolicy">All Options</label>
								</div>
							</li>
						</ul>
					</li>
					<li role="presentation" class="dropdown" id="pickupLocation">
						<a href="#" class="dropdown-toggle">Pickup Locations <b class="caret"></b></a>
						<ul class="dropdown-menu dropdown-menu-right">
							<li><cfoutput>
								<form method="post" id="locationFilter" action="#buildURL('car.availability?searchID=#rc.searchID#')#">
									<div id="locations">
										<div class="form-group">
											<label for="pickUpLocationKey" class="control-label col-sm-4 col-xs-12">Pick-up Location</label>
											<div class="col-sm-8 col-xs-12">
												<select id="pickUpLocationKey" name="pickUpLocationKey" class="filterby form-control" onChange="submit();">
													<option value="">#rc.Filter.getCarPickUpAirport()# Terminal</option>
													<cfloop array="#session.searches[rc.searchID].vehicleLocations[rc.Filter.getCarPickUpAirport()]#" index="vehicleLocationIndex" item="vehicleLocation">
														<cfif (rc.Filter.getCarPickUpAirport() EQ vehicleLocation.city)
															OR (listFindNoCase(application.sCityCodes, vehicleLocation.city) NEQ 0)
															OR (vehicleLocation.distance LTE 30)>
															<!--- If the car vendor exists in the zeus.booking.RCAR table --->
															<cfif structKeyExists(application.stCarVendors, vehicleLocation.vendorCode)>
																<option data-vendor="#vehicleLocation.vendorCode#" value="#vehicleLocationIndex#" <cfif rc.pickUpLocationKey EQ vehicleLocationIndex>selected</cfif>>#application.stCarVendors[vehicleLocation.vendorCode]# - #vehicleLocation.street# (#vehicleLocation.city#)
																</option>
															<!--- <cfelse>
																<cfset emailHTML = "Car Vendor Code: " & vehicleLocation.vendorCode & "<br />Address: " & vehicleLocation.street & "(" & vehicleLocation.city & ")<br />Search ID: " & rc.searchID />
																<cfset application.fw.factory.getBean('EmailService').send( developer = false
																		, toAddress = 'weberrors@shortstravel.com;kgoblirsch@shortstravel.com'
																		, subject = 'STO: Missing Car Vendor'
																		, body = emailHTML ) /> --->
															</cfif>
														</cfif>
													</cfloop>
												</select>
											</div>
										</div>
					
										<cfif rc.Filter.getCarDifferentLocations() EQ 1>
										<div class="form-group">
											<label for="dropOffLocationKey" class="control-label col-sm-4 col-xs-12">Drop-off Location</label>
											<div class="col-sm-8 col-xs-12">
												<select id="dropOffLocationKey" name="dropOffLocationKey" class="filterby form-control" onChange="submit();">
													<option value="">#rc.Filter.getCarDropoffAirport()# Terminal</option>
													<cfloop array="#session.searches[rc.searchID].vehicleLocations[rc.Filter.getCarDropoffAirport()]#" index="vehicleLocationIndex" item="vehicleLocation">
														<cfif (rc.Filter.getCarDropoffAirport() EQ vehicleLocation.city)
															OR (listFindNoCase(application.sCityCodes, vehicleLocation.city) NEQ 0)
															OR (vehicleLocation.distance LTE 30)>
															<!--- If the car vendor exists in the zeus.booking.RCAR table --->
															<cfif structKeyExists(application.stCarVendors, vehicleLocation.vendorCode)>
																<option data-vendor="#vehicleLocation.vendorCode#" value="#vehicleLocationIndex#" <cfif rc.dropOffLocationKey EQ vehicleLocationIndex>selected</cfif>>#application.stCarVendors[vehicleLocation.vendorCode]# - #vehicleLocation.street# (#vehicleLocation.city#)
																</option>
															<cfelse>
																<cfset emailHTML = "Car Vendor Code: " & vehicleLocation.vendorCode & "<br />Address: " & vehicleLocation.street & "(" & vehicleLocation.city & ")<br />Search ID: " & rc.searchID />
																<cfset application.fw.factory.getBean('EmailService').send( developer = false
																		, toAddress = 'weberrors@shortstravel.com;kgoblirsch@shortstravel.com'
																		, subject = 'STO: Missing Car Vendor'
																		, body = emailHTML ) />
															</cfif>
														</cfif>
													</cfloop>
												</select>
											</div>
										</div>
										</cfif>
					
									</div>
								</form>
							</cfoutput>
							</li>
						</ul>
					</li>
					<li role="presentation" class="dropdown hidden" id="clearFilters">
						<a href="#" class="removefilters dropdown-toggle clear-all_control__filter">
							Clear All <span class="mdi clear_all_filters mdi-close-circle-outline"></span>
						</a>
					</li>
				</ul>
			</div>
		</div>
	</div>
</div>
