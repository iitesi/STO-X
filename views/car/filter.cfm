<cfsilent>
	<cfparam name="rc.filter" default="" />
	<cfsavecontent variable="filterHeader">
		<script type='text/javascript' src='assets/js/bootstrap-datepicker.js'></script>
		<script type='text/javascript' src='assets/js/date.format.js'></script>
		<script type='text/javascript' src='assets/js/select2.min.js'></script>
		<script type='text/javascript' src='assets/localdata/airports-us.js'></script>
		<script type='text/javascript' src='assets/js/car/search.js'></script>
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
		<div class="navbar">
			<div class="navbar-inner">
				<ul class="nav">
					<li><a href="#" id="btnCarVendor" class="filterby" title="Click to view/hide filters">Vendors <i class="icon-caret-down"></i></a></li>
					<li><a href="#" id="btnCarCategory" class="filterby" title="Click to view/hide filters">Car Types <i class="icon-caret-down"></i></a></li>
					<li><a href="#" id="btnPolicy" class="filterby" title="Click to view/hide in-policy cars">In Policy</a></li>
				</ul>
			</div>
		</div>
		<div class="filter">
			<span id="numFiltered"></span> of <span id="numTotal"></span> cars displayed <a href="#" class="pull-right">Continue without car</a>
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
								<cfif Right(carCategory, 3) IS "car">
									<label class="checkbox" for="fltrCategory#LCase(carCategory)#"><input id="fltrCategory#LCase(carCategory)#" type="checkbox" name="fltrCategory" value="#carCategory#"> #Left(carCategory, Len(carCategory)-3)#</label>
								</cfif>
							</cfloop>
						</div>
						<div class="span2">
							<b>Van</b>
							<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="carCategory">
								<cfif Right(carCategory, 3) IS "van">
									<label class="checkbox" for="fltrCategory#LCase(carCategory)#"><input id="fltrCategory#LCase(carCategory)#" type="checkbox" name="fltrCategory" value="#carCategory#"> #Left(carCategory, Len(carCategory)-3)#</label>
								</cfif>
							</cfloop>
						</div>
						<div class="span2">
							<b>SUV</b>
							<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="carCategory">
								<cfif Right(carCategory, 3) IS "suv">
									<label class="checkbox" for="fltrCategory#LCase(carCategory)#"><input id="fltrCategory#LCase(carCategory)#" type="checkbox" name="fltrCategory" value="#carCategory#"> #Left(carCategory, Len(carCategory)-3)#</label>
								</cfif>
							</cfloop>
						</div>
						<input id="fltrCarCategorySelectAll" name="fltrCarCategorySelectAll" type="hidden" value="true" />
					</div>
				</div>
			</cfoutput>
		</div>
	</div>
</div>


<!--- <a href="##displaySearchWindow" id="displayModal" data-toggle="modal" data-backdrop="static">Change Search</a>
<cfoutput>
	#view('car/search')#
</cfoutput>

<div class="filter">
	<div class="row">
		<div class="span12">
			<div class="row">
				<div>
					<h4>Filters: <span id="numFiltered"></span> of <span id="numTotal"></span> cars displayed <a href="#" id="clearFilters" name="clearFilters" class="pull-right"><i class="icon-refresh"></i> Clear Filters</a></h4>
				</div>
				<div class="navbar filterby">
					<div class="navbar-inner">
						<ul class="nav">
							<li><a href="#" id="btnCarVendor" class="filterby" title="Click to view/hide filters">Vendors <i class="icon-chevron-down"></i></a></li>
							<li><a href="#" id="btnCarCategory" class="filterby" title="Click to view/hide filters">Car Types <i class="icon-chevron-down"></i></a></li>
							<li><a href="#" id="btnPolicy" class="filterby" title="Click to view/hide in-policy cars">In Policy</a></li>
						</ul>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="clearfix"></div>
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
									<cfif Right(carCategory, 3) IS "car">
										<label class="checkbox" for="fltrCategory#LCase(carCategory)#"><input id="fltrCategory#LCase(carCategory)#" type="checkbox" name="fltrCategory" value="#carCategory#"> #Left(carCategory, Len(carCategory)-3)#</label>
									</cfif>
								</cfloop>
							</div>
							<div class="span2">
								<b>Van</b>
								<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="carCategory">
									<cfif Right(carCategory, 3) IS "van">
										<label class="checkbox" for="fltrCategory#LCase(carCategory)#"><input id="fltrCategory#LCase(carCategory)#" type="checkbox" name="fltrCategory" value="#carCategory#"> #Left(carCategory, Len(carCategory)-3)#</label>
									</cfif>
								</cfloop>
							</div>
							<div class="span2">
								<b>SUV</b>
								<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="carCategory">
									<cfif Right(carCategory, 3) IS "suv">
										<label class="checkbox" for="fltrCategory#LCase(carCategory)#"><input id="fltrCategory#LCase(carCategory)#" type="checkbox" name="fltrCategory" value="#carCategory#"> #Left(carCategory, Len(carCategory)-3)#</label>
									</cfif>
								</cfloop>
							</div>
							<input id="fltrCarCategorySelectAll" name="fltrCarCategorySelectAll" type="hidden" value="true" />
						</div>
					</div>
					<!--- <div class="span2">
						<b>In Policy</b>
						<label class="checkbox" for="fltrPolicy"><input id="fltrPolicy" type="checkbox" name="policy" title="View In Policy Car Rentals"> In Policy</label>
					</div> --->
				</cfoutput>
			</div>
		</div>
	</div>
</div> --->

<script type="application/javascript">
<cfoutput>
	var carresults = [
		<cfset nCount = 0>
		<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="sCategory">
			<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="sVendor">
				<cfif nCount NEQ 0>,</cfif>
				<cfset nCount++>
				<cfif structKeyExists(session.searches[rc.SearchID].stCars[sCategory], sVendor)>
					[#session.searches[rc.SearchID].stCars[sCategory][sVendor].sJavascript#]
				<cfelse>
					['#LCase(sCategory)##LCase(sVendor)#','#LCase(sCategory)#','#LCase(sVendor)#',0,0]
				</cfif>
			</cfloop>
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
</script>