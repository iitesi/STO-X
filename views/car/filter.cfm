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
			if (howFilter == 'clearAll') {
				$(":checkbox").prop('checked', false);
				$("#btnPolicy").parent().removeClass('active');
				$("#fltrVendorSelectAll").val(true);
				$("#fltrCarCategorySelectAll").val(true);
			}

			var policy = $("#btnPolicy").parent().hasClass('active');
			var nCount = 0;

			// Logic for displaying or not displaying a particular result
			// If (fltrVendorSelectAll is true and fltrCarCategorySelectAll is true)
			// OR (fltrVendorSelectAll is false and that vendor is checked)
			// OR (fltrCarCategorySelectAll is false and that category is checked)
			// AND in policy, show
			// Else, hide

			for (loopcnt = 0; loopcnt <= (carresults.length-1); loopcnt++) {
				var car = carresults[loopcnt];

				var inpolicy = ((policy == false) || (policy == true && car[3] == 1)) ? true : false;

				if (((($("#fltrVendorSelectAll").val() == 'true') && ($("#fltrCarCategorySelectAll").val() == 'true'))
					|| ((($("#fltrVendorSelectAll").val() == 'false') && ($( "#fltrVendor" + car[2] ).is(':checked') == true))
						&& (($("#fltrCarCategorySelectAll").val() == 'true')
							|| ($("#fltrCarCategorySelectAll").val() == 'false') && ($( "#fltrCategory" + car[1] ).is(':checked') == true)))
					|| ((($("#fltrCarCategorySelectAll").val() == 'false') && ($( "#fltrCategory" + car[1] ).is(':checked') == true))
						&& (($("#fltrVendorSelectAll").val() == 'true')
							|| ($("#fltrVendorSelectAll").val() == 'false') && ($( "#fltrVendor" + car[2] ).is(':checked') == true))))
					&& inpolicy) {
					$( "#" + car[0] ).show();
					nCount++;
				}
				else { 
					$( "#" + car[0] ).hide();
				}
			}
			for (loopcnt = 0; loopcnt <= (carcategories.length-1); loopcnt++) {
				var category = carcategories[loopcnt];

				var inpolicy = ((policy == false) || (policy == true && category[1] == 1)) ? true : false;

				if ((($("#fltrCarCategorySelectAll").val() == 'true') || ($( "#fltrCategory" + category[0] ).is(':checked') == true)) && inpolicy) {
					$( '#row' + category ).show();
				}
				else {
					$( '#row' + category ).hide();
				}
				
				// If all the cars in a category are hidden then hide that category too - don't like empty rows
				if($('#row' + category).find('td:not(.empty,.carTypeCol)').length < 1) {
					$('#row' + category).hide();
				} else {
					$('#row' + category).show();
				}
			}
			for (loopcnt = 0; loopcnt <= (carvendors.length-1); loopcnt++) {
				var vendor = carvendors[loopcnt];

				var inpolicy = ((policy == false) || (policy == true && vendor[1] == 1)) ? true : false;

				if ((($("#fltrVendorSelectAll").val() == 'true') || ($( "#fltrVendor" + vendor[0] ).is(':checked') == true)) && inpolicy) {
					$( '#vendor' + vendor[0] ).show();
				}
				else {
					$( '#vendor' + vendor[0] ).hide();
				}
			}

			if(nCount == 0) {
				if(carresults.length == 0) {
					$("#noSearchResults").show();
				}
				else {
					$("#noFilteredResults").show();
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

			return nCount;
		}
		</script>
		<script type='text/javascript' src='assets/js/car/filter.js'></script>
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
				max-height: 260px;
				overflow-y: auto;
				overflow-x: hidden;
			}
		</style>
	</cfsavecontent>
	<cfhtmlhead text="#filterHeader#" />
</cfsilent>

<!---First row--->
<div id="filterbar">
	<div class="filter respFilter">
		<cfoutput>
			<form method="post" action="#buildURL('car.availability?searchID=#rc.searchID#')#">
					
				<div class="navbar navbar-default">
					<div class="container-fluid">
						<div class="navbar-header">
							  <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="##filter-navbar-collapse-1" aria-expanded="false">
								<span class="sr-only">Toggle navigation</span>
								<span class="glyphicon glyphicon-filter"></span>
								
								
							  </button>
							  <a class="navbar-brand" href="##">Filter</a>
						</div>
						<div class="collapse navbar-collapse" id="filter-navbar-collapse-1">
							<ul class="nav navbar-nav">
								<li><a href="##" id="btnCarVendor" class="filterby carFilterBy" title="Click to view/hide filters">Vendors <i class="fa fa-caret-down"></i></a></li>
								<li><a href="##" id="btnCarCategory" class="filterby carFilterBy" title="Click to view/hide filters">Car Types <i class="fa fa-caret-down"></i></a></li>
								<li><a href="##" id="btnPolicy" class="filterby" title="Click to view/hide in-policy cars">In Policy</a></li>
								<li><a href="##" id="btnLocation" class="filterby carFilterBy" title="Click to view/hide filters"><cfif rc.Filter.getCarDifferentLocations() EQ 1>Pickup/Dropoff Location<cfelse>Pickup Location</cfif> <i class="fa fa-caret-down"></i></a></li>
							</ul>
								
							<ul class="nav navbar-nav navbar-right">
								<li><p class="navbar-text filter"><span id="numFiltered"></span> of <span id="numTotal"></span> cars displayed</p></li>
								<li><a href="##" id="clearFilters" name="clearFilters" class="pull-right"><i class="icon-refresh"></i> Clear Filters</a></li>
							</ul>
						
						</div>
					</div>
				</div>
			</form>
		</cfoutput>
		<div class="filter">
			<cfoutput><cfif structKeyExists(session.searches[rc.SearchID].stItinerary, 'Air') OR structKeyExists(session.searches[rc.SearchID].stItinerary, 'Hotel')><a href="#buildURL('car.skip?SearchID=#rc.SearchID#')#" class="pull-right">Continue without car</a></cfif></cfoutput>
		</div>
		<div class="well filterselection">
			<cfoutput>
				<div id="vendors">
					<div class="row" style="text-align:center;"><b>VENDORS</b></div>
					<div class="row">
						<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="vendorCode">
							<div class="col-lg-3 col-md-4 col-sm-6 col-xs-12">
								<label class="checkbox" for="fltrVendor#LCase(vendorCode)#"><input id="fltrVendor#LCase(vendorCode)#" type="checkbox" name="fltrVendor" value="#vendorCode#"> #StructKeyExists(application.stCarVendors, vendorCode) ? application.stCarVendors[vendorCode] : 'No Car Vendor found'#</label>
							</div>
						</cfloop>
						<input id="fltrVendorSelectAll" name="fltrVendorSelectAll" type="hidden" value="true" />
					</div>
				</div>
				<div id="carTypes">
					<div class="row" style="text-align:center;"><strong>CAR TYPES</strong></div>
					<div class="row">
						
							<div class="col-xs-12"><strong>Cars</strong></div>
							<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="carCategory">
								<cfif Right(carCategory, 3) IS "car" AND NOT structIsEmpty(session.searches[rc.SearchID].stCars[carCategory])>
									<div class="col-lg-3 col-md-4 col-sm-6 col-xs-12">
										<label class="checkbox" for="fltrCategory#LCase(carCategory)#"><input id="fltrCategory#LCase(carCategory)#" type="checkbox" name="fltrCategory" value="#carCategory#"> #Left(carCategory, Len(carCategory)-3)#</label>
									</div>
								</cfif>
							</cfloop>
							<div class="col-xs-12">&nbsp;</div>
							<div class="col-xs-12"><strong>Vans</strong></div>
							<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="carCategory">
								<cfif Right(carCategory, 3) IS "van" AND NOT structIsEmpty(session.searches[rc.SearchID].stCars[carCategory])>
									<div class="col-lg-3 col-md-4 col-sm-6 col-xs-12">
										<label class="checkbox" for="fltrCategory#LCase(carCategory)#"><input id="fltrCategory#LCase(carCategory)#" type="checkbox" name="fltrCategory" value="#carCategory#"> #Left(carCategory, Len(carCategory)-3)#</label>
									</div>
								</cfif>
							</cfloop>
							<div class="col-xs-12">&nbsp;</div>
							<div class="col-xs-12"><strong>SUVs</strong></div>
							<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="carCategory">
								<cfif Right(carCategory, 3) IS "suv" AND NOT structIsEmpty(session.searches[rc.SearchID].stCars[carCategory])>
									<div class="col-lg-3 col-md-4 col-sm-6 col-xs-12">
									 <label class="checkbox" for="fltrCategory#LCase(carCategory)#"><input id="fltrCategory#LCase(carCategory)#" type="checkbox" name="fltrCategory" value="#carCategory#"> #Left(carCategory, Len(carCategory)-3)#</label>
									</div>
								</cfif>
							</cfloop>
						
						<input id="fltrCarCategorySelectAll" name="fltrCarCategorySelectAll" type="hidden" value="true" />
					</div>
				</div>
					
					
					
				<div class="form-horizontal" id="locations">
					<div class="form-group">
						<label for="pickUpLocationKey" class="control-label col-sm-4 col-xs-12">Pick-up Location</label>
						<div class="col-sm-8 col-xs-12">
								<select name="pickUpLocationKey" class="filterby form-control" onChange="submit();">
									<option value="">#rc.Filter.getCarPickUpAirport()# Terminal</option>
									<cfloop array="#session.searches[rc.searchID].vehicleLocations[rc.Filter.getCarPickUpAirport()]#" index="vehicleLocationIndex" item="vehicleLocation">
										<cfif (rc.Filter.getCarPickUpAirport() EQ vehicleLocation.city)
											OR (listFindNoCase(application.sCityCodes, vehicleLocation.city) NEQ 0)
											OR (vehicleLocation.distance LTE 30)>
											<!--- If the car vendor exists in the zeus.booking.RCAR table --->
											<cfif structKeyExists(application.stCarVendors, vehicleLocation.vendorCode)>
												<option value="#vehicleLocationIndex#" <cfif rc.pickUpLocationKey EQ vehicleLocationIndex>selected</cfif>>#application.stCarVendors[vehicleLocation.vendorCode]# - #vehicleLocation.street# (#vehicleLocation.city#)
												</option>
											<cfelse>
												<cfset emailHTML = "Car Vendor Code: " & vehicleLocation.vendorCode & "<br />Address: " & vehicleLocation.street & "(" & vehicleLocation.city & ")<br />Search ID: " & rc.searchID />
												<cfset application.fw.factory.getBean('EmailService').send( developer = false
														, toAddress = 'kmyers@shortstravel.com;klamont@shortstravel.com;kgoblirsch@shortstravel.com'
														, subject = 'STO: Missing Car Vendor'
														, body = emailHTML ) />
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
										<select name="dropOffLocationKey" class="filterby form-control" onChange="submit();">
											<option value="">#rc.Filter.getCarDropoffAirport()# Terminal</option>
											<cfloop array="#session.searches[rc.searchID].vehicleLocations[rc.Filter.getCarDropoffAirport()]#" index="vehicleLocationIndex" item="vehicleLocation">
												<cfif (rc.Filter.getCarDropoffAirport() EQ vehicleLocation.city)
													OR (listFindNoCase(application.sCityCodes, vehicleLocation.city) NEQ 0)
													OR (vehicleLocation.distance LTE 30)>
													<!--- If the car vendor exists in the zeus.booking.RCAR table --->
													<cfif structKeyExists(application.stCarVendors, vehicleLocation.vendorCode)>
														<option value="#vehicleLocationIndex#" <cfif rc.dropOffLocationKey EQ vehicleLocationIndex>selected</cfif>>#application.stCarVendors[vehicleLocation.vendorCode]# - #vehicleLocation.street# (#vehicleLocation.city#)
														</option>
													<cfelse>
														<cfset emailHTML = "Car Vendor Code: " & vehicleLocation.vendorCode & "<br />Address: " & vehicleLocation.street & "(" & vehicleLocation.city & ")<br />Search ID: " & rc.searchID />
														<cfset application.fw.factory.getBean('EmailService').send( developer = false
																, toAddress = 'kmyers@shortstravel.com;klamont@shortstravel.com;kgoblirsch@shortstravel.com'
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
			</cfoutput>
			<span class="pull-right">
				<button type="button" class="closewell close" title="Close filters"><i class="fa fa-times"></i></button>
			</span>
			<div class="clearfix"></div>
		</div>
	</div>
</div>