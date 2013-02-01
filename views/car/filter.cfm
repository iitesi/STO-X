<div id="filterbar">
	<div>
		<div class="filterheader">Filter By</div>
	</div>
</div>
<ul id="filter">
	<table>
	<tr>
<!---
VENDORS
--->		<td>
			<li>
				<input type="checkbox" id="btnCarVendor" name="btnCarVendor"> <label for="btnCarVendor">Vendors</label>
				<ul>
					<cfoutput>
						<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="VendorCode">
							<li><input id="btnVendor#LCase(VendorCode)#" type="checkbox" name="Vendor#VendorCode#" value="#VendorCode#" checked="checked" onClick="filterCar()"> <label for="btnVendor#LCase(VendorCode)#">#StructKeyExists(application.stCarVendors, VendorCode) ? application.stCarVendors[VendorCode] : 'No Car Vendor found'#</label></li>
						</cfloop>
					</cfoutput>
				</ul>
			</li>
		</td>

<!---
CATEGORIES
--->		<td>
			<li>
				<input type="checkbox" id="btnCarCategory" name="btnCarCategory"> <label for="btnCarCategory">Categories</label>
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
							<input id="btnCategory#LCase(sCategory)#" type="checkbox" checked="checked" name="sCategory" value="#sCategory#" onClick="filterCar()"> <label for="btnCategory#LCase(sCategory)#">#Left(sCategory, Len(sCategory)-3)#</label><br>
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
	</tr> 
	</table>
</ul>

<script type="application/javascript">

$(document).ready(function() {
	$( "#btnCarVendor" ).button().click(function() { filterCar(); });
	$( "#btnCarCategory" ).button().click(function() { filterCar(); });
	$( "#Policy" ).button().change(function() { filterCar(); });
	var nCount = filterCar();
	if (nCount == 0) {
		$( "#Policy" ).prop('checked', false);
		$( "#Policy" ).button( "refresh" );
		filterCar();
	}
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
