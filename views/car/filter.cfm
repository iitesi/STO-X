<cfhtmlhead text="
	<script type='text/javascript' src='assets/js/bootstrap-datepicker.js'></script>
	<script type='text/javascript' src='assets/js/date.format.js'></script>
	<script type='text/javascript' src='assets/js/select2.min.js'></script>
	<script type='text/javascript' src='assets/localdata/airports-us.js'></script>
	<script type='text/javascript' src='assets/js/car/search.js'></script>
	<link rel='stylesheet' type='text/css' href='assets/css/datepicker.css' />
	<link rel='stylesheet' type='text/css' href='assets/css/select2.css' />
	<link rel='stylesheet' type='text/css' href='assets/css/search.css' />
	<style type='text/css'>
		.searchContainer {
			max-width: 680px;
			width: 680px;			
		}
		.modal {
			position: absolute;
			top: 10%;
			width: 680px;
			height: 600px;
			margin: -80px 0px 0 -360px;
		}
		.modal.fade.in {
			top: 0;
		}
		.modal-body {
			overflow-y: auto;
		}
	</style>
" />

<cfparam name="rc.filter" default="">

<a href="##displaySearchWindow" id="displayModal" data-toggle="modal">CHANGE YOUR SEARCH</a>
<cfoutput>
	#view('car/search')#
</cfoutput>

<ul id="filter">
	<table>
	<tr>
		<td>
			<div class="filterheader">Filter By</div>
		</td>
<!---
VENDORS
--->
		<td>
			<li>
				<input type="checkbox" id="btnCarVendor" name="btnCarVendor"> <label for="btnCarVendor">Vendors</label>
				<ul>
					<cfoutput>
						<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="VendorCode">
							<div id="vendorButtons"><li><input id="btnVendor#LCase(VendorCode)#" type="checkbox" name="Vendor#VendorCode#" value="#VendorCode#" class="checkUncheck" checked="checked" onClick="filterCar()"> <label for="btnVendor#LCase(VendorCode)#">#StructKeyExists(application.stCarVendors, VendorCode) ? application.stCarVendors[VendorCode] : 'No Car Vendor found'#</label></li></div>
						</cfloop>
					</cfoutput>
				</ul>
			</li>
		</td>
<!---
CATEGORIES
--->
		<td>
			<li>
				<input type="checkbox" id="btnCarCategory" name="btnCarCategory"> <label for="btnCarCategory">Car Types</label>
				<ul>
					<li>
					<table width="400px">
					<tr>
						<td width="33%"><strong>Car</strong></td>
						<td width="33%"><strong>Van</strong></td>
						<td width="33%"><strong>SUV</strong></td>
					</tr>
					<tr>
					<cfoutput>
						<cfset temp = ''>
						<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="sCategory">
							<cfif temp NEQ Right(sCategory, 3)>
								<cfif temp NEQ ''>
									</td>
								</cfif>
								<td valign="top">
								<cfset temp = Right(sCategory, 3)>
							</cfif>
							<div id="categoryButtons"><input id="btnCategory#LCase(sCategory)#" type="checkbox" checked="checked" name="sCategory" value="#sCategory#" class="checkUncheck" onClick="filterCar()"> <label for="btnCategory#LCase(sCategory)#">#Left(sCategory, Len(sCategory)-3)#</label><br></div>
						</cfloop>
						</td>
					</cfoutput>
					</tr>
					</table>
					</li>
				</ul>
			</li>
		</td>
<!---
POLICY
--->
		<td>
			<input type="checkbox" id="Policy" name="Policy" checked> <label for="Policy">In Policy</label>
		</td>
<!---
DISPLAY RESULTS/REMOVE FILTERS
--->
		<td>
			<div class="filterresults">
				xxx of xxx cars displayed<br />
				<a href="#" id="clearFilters" name="clearFilters">Remove filters</a>
			</div>
		</td>
	</tr> 
	</table>
</ul>

<script type="application/javascript">

$(document).ready(function() {
	$( "#btnCarVendor" ).button().click(function() { filterCar(); });
	$( "#btnCarCategory" ).button().click(function() { filterCar(); });
	$( "#Policy" ).button().change(function() { filterCar(); });
	$( "#clearFilters" ).click(function() { filterCar('clearAll'); });
	var nCount = filterCar();
	if (nCount == 0) {
		$( "#Policy" ).prop('checked', false);
		$( "#Policy" ).button( "refresh" );
		filterCar();
	}
	//alert(carresults);

	/* $("#displayModal").click(function() {
		var url = $("#modalWindow").data("url");
		var modalHeader = $("#modalWindow").data("header");
		var modalBody = $("#modalWindow").data("view");
		var modalHeight = $("#modalWindow").data("height");
		var modalWidth = $("#modalWindow").data("width");

		$.get(url, function(data) {
			$("#modalContainer").html(data);
			$(".modal-header #myModalHeader").html(modalHeader);
			$(".modal-body #myIFrame").attr('src', modalBody).attr('height', modalHeight).attr('width', modalWidth);

			$("#modalWindow").modal("show");
		});
	});

	$("#modalWindow").on("hidden", function() {
		$(this).removeData("modal");
	}); */
});
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
