<cfhtmlhead text="
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
" />

<cfparam name="rc.filter" default="">
<a href="##displaySearchWindow" id="displayModal" data-toggle="modal" data-backdrop="static">CHANGE YOUR SEARCH</a>
<cfoutput>
	#view('car/search')#
</cfoutput>

<div class="filter">
	<div class="row">
		<div class="span10">
			<div class="row">
				<div>
					<h4>Filters: <span id="numFiltered"></span> of <span id="numTotal"></span> cars displayed <a href="#" id="clearFilters" name="clearFilters" class="pull-right"><i class="icon-refresh"></i> Clear Filters</a></h4>
				</div>
				<div class="navbar filterby">
					<div class="navbar-inner">
						<ul class="nav">
							<li><a href="#" id="btnCarVendor">Vendors</a></li>
							<li><a href="#" id="btnCarCategory">Car Types</a></li>
							<li><a href="#" id="btnPolicy">In Policy</a></li>
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
						<b>Vendors</b>
						<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="vendorCode">
							<label class="checkbox" for="fltrVendor#LCase(vendorCode)#"><input id="fltrVendor#LCase(vendorCode)#" type="checkbox" name="fltrVendor" value="#vendorCode#" checked="checked"> #StructKeyExists(application.stCarVendors, vendorCode) ? application.stCarVendors[vendorCode] : 'No Car Vendor found'#</label>
						</cfloop>
						<label class="checkbox" for="fltrVendorSelectAll"><input id="fltrVendorSelectAll" type="checkbox" name="selectAll" checked="checked"> Select All</label>
					</div>
					<div class="span4">
						<b>Car Types</b>
						<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="carCategory">
							<label class="checkbox" for="fltrCategory#LCase(carCategory)#"><input id="fltrCategory#LCase(carCategory)#" type="checkbox" name="fltrCategory" value="#carCategory#" checked="checked"> #Left(carCategory, Len(carCategory)-3)#</label>
						</cfloop>
						<label class="checkbox" for="fltrCarCategorySelectAll"><input id="fltrCarCategorySelectAll" type="checkbox" name="selectAll" checked="checked"> Select All</label>
					</div>
					<div class="span2">
						<b>In Policy</b>
						<label class="checkbox" for="fltrPolicy"><input id="fltrPolicy" type="checkbox" name="policy" title="View In Policy Car Rentals"> In Policy</label>
					</div>
				</cfoutput>
			</div>
		</div>
	</div>
</div>

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