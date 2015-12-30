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
	<div class="filter">
		<div>
			<h4>Filter <a href="#" id="clearFilters" name="clearFilters" class="pull-right"><i class="icon-refresh"></i> Clear Filters</a></h4>
		</div>
		<cfoutput>
			<form method="post" action="#buildURL('car.availability?searchID=#rc.searchID#')#">
				<div class="navbar">
					<div class="navbar-inner">
						<ul class="nav">
							<li><a href="##" id="btnCarVendor" class="filterby" title="Click to view/hide filters">Vendors <i class="icon-caret-down"></i></a></li>
							<li><a href="##" id="btnCarCategory" class="filterby" title="Click to view/hide filters">Car Types <i class="icon-caret-down"></i></a></li>
							<li><a href="##" id="btnPolicy" class="filterby" title="Click to view/hide in-policy cars">In Policy</a></li>
							<li>
								Pick-up Location
								<select name="pickUpLocationKey" class="filterby input-large" onChange="submit();">
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
								<cfif rc.Filter.getCarDifferentLocations() EQ 1>
									Drop-off Location
									<select name="dropOffLocationKey" class="filterby input-large" onChange="submit();">
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
								</cfif>
							</li>
						</ul>
					</div>
				</div>
			</form>
		</cfoutput>
		<div class="filter">
			<span id="numFiltered"></span> of <span id="numTotal"></span> cars displayed <cfoutput><cfif structKeyExists(session.searches[rc.SearchID].stItinerary, 'Air') OR structKeyExists(session.searches[rc.SearchID].stItinerary, 'Hotel')><a href="#buildURL('car.skip?SearchID=#rc.SearchID#')#" class="pull-right">Continue without car</a></cfif></cfoutput>
		</div>
		<div class="row well filterselection">
			<cfoutput>
				<div class="span4">
					<div class="row" style="text-align:center;"><b>VENDORS</b></div>
					<div class="row">
						<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="vendorCode">
							<label class="checkbox" for="fltrVendor#LCase(vendorCode)#"><input id="fltrVendor#LCase(vendorCode)#" type="checkbox" name="fltrVendor" value="#vendorCode#"> #StructKeyExists(application.stCarVendors, vendorCode) ? application.stCarVendors[vendorCode] : 'No Car Vendor found'#</label>
						</cfloop>
						<input id="fltrVendorSelectAll" name="fltrVendorSelectAll" type="hidden" value="true" />
					</div>
				</div>
				<div class="span7">
					<div class="row" style="text-align:center;"><b>CAR TYPES</b></div>
					<div class="row">
						<div class="span2">
							<b>Car</b>
							<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="carCategory">
								<cfif Right(carCategory, 3) IS "car" AND NOT structIsEmpty(session.searches[rc.SearchID].stCars[carCategory])>
									<label class="checkbox" for="fltrCategory#LCase(carCategory)#"><input id="fltrCategory#LCase(carCategory)#" type="checkbox" name="fltrCategory" value="#carCategory#"> #Left(carCategory, Len(carCategory)-3)#</label>
								</cfif>
							</cfloop>
						</div>
						<div class="span2">
							<b>Van</b>
							<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="carCategory">
								<cfif Right(carCategory, 3) IS "van" AND NOT structIsEmpty(session.searches[rc.SearchID].stCars[carCategory])>
									<label class="checkbox" for="fltrCategory#LCase(carCategory)#"><input id="fltrCategory#LCase(carCategory)#" type="checkbox" name="fltrCategory" value="#carCategory#"> #Left(carCategory, Len(carCategory)-3)#</label>
								</cfif>
							</cfloop>
						</div>
						<div class="span2">
							<b>SUV</b>
							<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="carCategory">
								<cfif Right(carCategory, 3) IS "suv" AND NOT structIsEmpty(session.searches[rc.SearchID].stCars[carCategory])>
									<label class="checkbox" for="fltrCategory#LCase(carCategory)#"><input id="fltrCategory#LCase(carCategory)#" type="checkbox" name="fltrCategory" value="#carCategory#"> #Left(carCategory, Len(carCategory)-3)#</label>
								</cfif>
							</cfloop>
						</div>
						<input id="fltrCarCategorySelectAll" name="fltrCarCategorySelectAll" type="hidden" value="true" />
					</div>
				</div>
					<br /><br />
					<cfif structCount(session.searches[rc.SearchID].stCarVendors) GT 1>
						<cfset whileVar = structCount(session.searches[rc.SearchID].stCarVendors) - 1 />
						<cfloop condition="whileVar GREATER THAN OR EQUAL TO 1">
							&nbsp;<br />
							<cfset whileVar = whileVar - 1 />
						</cfloop>
					</cfif>
					<span class="pull-right">
						<button type="button" class="closewell close" title="Close filters"><i class="icon-remove"></i></button>
					</span>
			</cfoutput>
		</div>
	</div>
</div>